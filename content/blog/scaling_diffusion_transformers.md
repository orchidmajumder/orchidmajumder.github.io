+++
title = "Scaling Diffusion Transformers for Text to Image Generation"
date = "15 Jun 2025"
slug = "scaling_diffusion_transformers"
description = "A summary of our study on which diffusion transformer design scales best for text to image generation, and what more data and better captions add."
tags = ["diffusion", "transformers", "scaling"]
toc = true
+++

In this post I summarize our paper on efficiently scaling diffusion transformers for text to image generation ([arXiv 2412.12391](https://arxiv.org/abs/2412.12391)). I worked on it with my colleagues at Amazon AGI and AWS AI Labs.

## The question

For years the UNet was the standard backbone for image diffusion models. Diffusion transformers (DiTs) replaced the UNet with a transformer, and many DiT variants followed. They differ mainly in their block design and in how they bring the text prompt into the model.

Still, a careful comparison of these designs, and of DiTs against UNets, was missing. Training settings differ from paper to paper and the models are expensive to train, so a fair comparison is hard. We wanted to answer two questions. If everything else is held fixed, which DiT design scales best for text to image generation? And how much do more data and better captions help?

## How we set it up

We compared three text conditioned DiT designs:

* **PixArt α** and **LargeDiT** bring in the text through cross attention: inside each block, the image tokens attend to the text tokens.
* **UViT** treats every input as a token. The text tokens and the image tokens go into one sequence, each block applies self attention over all of them, and long skip connections link the shallow and deep blocks.

All models used the same autoencoder (from SDXL), the same text encoder (OpenCLIP) and the same training settings. We trained them from scratch, without pretrained DiT weights or ImageNet pretraining. We scaled each design by changing the hidden size, the depth and the number of attention heads, from 0.3B up to 8B parameters.

Most runs used LensArt, a curated set of 250M image and text pairs, at 256 by 256 resolution with a batch size of 2048 for up to 600K steps. For the data scaling study we added SSTK, a second set of 350M pairs, for 600M in total. We trained SD2 and SDXL UNets in the same setting as baselines.

We measured two things. TIFA asks a visual question answering model questions about each image, to check that the image matches its prompt. ImageReward is a model trained to approximate human preference.

## Finding 1: UViT scales best

The cross attention designs gained less from scale. PixArt α, scaled up to 3B parameters, still could not match the SD2 UNet within the same number of training steps. LargeDiT passed the SD2 UNet at 2.9B, but its 7.6B version performed about the same as its 4.4B version and still trailed the SDXL UNet.

UViT scaled more effectively. At a small scale (0.6B) it learned more slowly than the other two designs but caught up later in training. At around 2B parameters it learned faster than both LargeDiT and PixArt α.

Our explanation lies in how the text is handled. In a cross attention design, the text tokens stay the same in every block. In UViT, the text tokens pass through the transformer together with the image tokens and change after every block, so the blocks act partly like a text encoder that is being fine tuned. Our experiments fit this view. Fine tuning the text encoder helped all the cross attention models. For UViT, a larger model with a frozen text encoder came close to a smaller model with a fine tuned one, and fine tuning did not add much for larger UViT models.

UViT also depends on its long skip connections. When we turned them off in a small UViT, it trained clearly worse.

## Finding 2: a 2.3B UViT matches SDXL and runs faster

We grew UViT in steps. We started from a 0.6B model with hidden size 1152, depth 28 and 16 heads, then increased depth and width to get a 1.3B model with hidden size 1536 and depth 42. Raising the hidden size to 2048 gave a 2.3B model. It performed clearly better than the SD2 UNet, and after 500K steps it matched the SDXL UNet on both TIFA and ImageReward.

Going bigger did not help much. Increasing the depth to 56 gave a 3.1B model, and increasing the hidden size to 2560 gave a 3.7B model. Neither was significantly better than the 2.3B model.

The 2.3B UViT is also fast. On H100 GPUs with 50 DDIM sampling steps, its end to end latency is 75% lower than the SDXL UNet at 256 by 256 and 66% lower at 512 by 512, even though it needs more than three times the theoretical compute. At 1024 by 1024 it needs 3.2 times the compute of the SDXL UNet but is only 41% slower.

For training at 1024 by 1024, we found it critical to adjust the noise schedule. Keeping the schedule we used at 256 and 512 led to forgotten backgrounds and concepts, and to color issues.

## Finding 3: new conditions are just more tokens

Since UViT treats every input as a token, adding a new kind of condition is simple: turn it into tokens and add them to the sequence. We tried this for image inpainting, starting from the 2.3B UViT trained at 1024 by 1024. We fed in the input image and its mask as extra tokens, instead of the usual approach of stacking them with the noisy image along the channel dimension. The token approach scored 0.887 versus 0.881 on TIFA (measured on its COCO prompts) and 1.30 versus 1.24 on ImageReward. It also beat BrushNet, a leading inpainting method, on every BrushBench metric except aesthetic score, where the two were close.

The same recipe works for canny edge maps. That model beat the SD3 Medium Canny ControlNet on all the metrics we compared, without a specialized adapter.

## Finding 4: more data and denser captions

LensArt's original captions come from web alt text, so they are short, noisy and often do not match the image well. We generated long synthetic captions with a multimodal language model (LLaVA 1.6 with Mistral 7B). A 0.6B UViT trained on LensArt with a mix of original and long captions reached better TIFA scores than the same model trained on the original captions or on SSTK.

We also grew the training set from 250M images (LensArt) to 600M (LensArt plus SSTK), this time without the long captions. More data improved TIFA and ImageReward for every architecture, and UViT gained more from it than the SDXL UNet did. On LensArt alone, UViT needed 400K to 500K steps to match SDXL. When we scaled the data up to 600M images, UViT started to pass SDXL within 150K steps.

Why do long captions and SSTK both help? We checked how many of the things TIFA asks about, such as objects, colors and counts, actually appear in the captions. Both the long captions and the SSTK captions mention more of them than the original LensArt captions, in almost every category. So the key is a caption's information density, not its length.

## Takeaways

* Compare architectures in a controlled setting: keep the autoencoder, the text encoder, the data and the training recipe the same.
* UViT, which applies self attention over the text and image tokens together and keeps long skip connections, scaled better than the cross attention designs we tested.
* A 2.3B UViT matched the SDXL UNet while running much faster at 256 and 512 resolution. Going past 2.3B did not help much in our setting.
* New conditions such as inpainting masks or edge maps can be added as extra tokens, without specialized adapters.
* More data helped every architecture, and helped UViT more than the SDXL UNet. Captions with more information improve how well images follow their prompts.

## Paper

Hao Li, Shamit Lal, Zhiheng Li, Yusheng Xie, Ying Wang, Yang Zou, Orchid Majumder, R. Manmatha, Zhuowen Tu, Stefano Ermon, Stefano Soatto and Ashwin Swaminathan. Efficient Scaling of Diffusion Transformers for Text to Image Generation. arXiv 2412.12391, 2024. [Read the paper on arXiv](https://arxiv.org/abs/2412.12391).
