+++
title = "Scaling Diffusion Transformers for Text to Image Generation"
date = "27 Oct 2026"
slug = "scaling_diffusion_transformers"
description = "A summary of our study on which diffusion transformer design scales best for text to image generation, and how much data and captions help."
tags = ["diffusion", "transformers", "scaling"]
toc = true
+++

In this post I summarize our paper on efficiently scaling diffusion transformers for text to image generation ([arXiv 2412.12391](https://arxiv.org/abs/2412.12391)). I worked on it with my colleagues at Amazon AGI and AWS AI Labs.

## The question

Diffusion models for images started out with convolutional UNet backbones. Transformers have since become a popular replacement, and several diffusion transformer (DiT) designs have appeared. They differ mostly in how they bring the text prompt into the model. Most papers report results for one design, trained with its own data and recipe, so it is hard to tell which choices matter at scale.

We wanted a clean answer to a simple question. If you hold everything else fixed, which diffusion transformer design gives the best text to image model as you make it bigger? And once you pick a design, how much do more data and better captions help?

## How we set it up

We compared three text conditioned designs:

* **PixArt α** and **LargeDiT** add cross attention, so the image tokens can look at the text tokens.
* **UViT** uses only self attention. The text tokens and the image tokens are joined into one sequence, and every block attends over all of them.

To keep the comparison fair, all models shared the same autoencoder and the same text encoder, and all were trained from scratch. We scaled them by changing the hidden size, the depth and the number of attention heads, covering models from 0.3B to 8B parameters. Training used datasets of up to 600M images.

We measured two things. TIFA checks how well an image matches its prompt, and ImageReward is a learned model of human preference.

## Finding 1: plain self attention scales best

UViT scaled more effectively than the cross attention designs. It is also the simplest of the three. There is no separate path for the text, so the prompt is just more tokens in the sequence. This makes it easy to add other conditions or modalities later: you add their tokens to the same sequence.

## Finding 2: a 2.3B UViT reaches SDXL quality

We grew UViT in steps. We started from a 0.6B model with hidden size 1152, depth 28 and 16 attention heads. Increasing the depth and width gave a 1.3B model with hidden size 1536 and depth 42. Raising the hidden size to 2048 gave a 2.3B model.

In our controlled setting, this 2.3B UViT clearly beat the SD2 UNet. After about 500K training steps it matched or beat the SDXL UNet on TIFA and ImageReward. It also did better than much larger PixArt α and LargeDiT models.

Going bigger did not pay off in this setting. The 3.1B and 3.7B versions were not much better than the 2.3B model. My reading is that model size and data have to grow together. A bigger model alone is not enough.

## Finding 3: data and captions matter

Model size is only half of the story, so we also studied the training data. Larger datasets and longer, richer captions both improved how well the images match their prompts. They also made training more efficient. With more data, UViT also improved faster relative to the SDXL UNet.

## Takeaways

* When you compare architectures, control everything else: the autoencoder, the text encoder, the data and the training recipe.
* A plain self attention transformer like UViT is a strong and simple default for text to image diffusion. It scales well and is easy to extend.
* Bigger is not automatically better. In our setting, the gains flattened out after about 2.3B parameters.
* Invest in data. More images and better captions improve prompt alignment and make training more efficient.

## Paper

Hao Li, Shamit Lal, Zhiheng Li, Yusheng Xie, Ying Wang, Yang Zou, Orchid Majumder, R. Manmatha, Zhuowen Tu, Stefano Ermon, Stefano Soatto and Ashwin Swaminathan. Efficient Scaling of Diffusion Transformers for Text to Image Generation. arXiv 2412.12391, 2024. [Read the paper on arXiv](https://arxiv.org/abs/2412.12391).
