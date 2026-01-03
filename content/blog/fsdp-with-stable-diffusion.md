---
title: "Latent Diffusion Model Training with PyTorch FSDP"
date: 2023-09-26
slug: "fsdp-pytorch-diffusion"
description: "Scaling diffusion model training using Fully Sharded Data Parallel (FSDP)"
draft: true
tags: ["pytorch", "fsdp", "diffusion", "distributed-training"]
math: true
toc: true
---

Coming soon.

<!--
## Introduction

Training large diffusion models requires distributing both data and model parameters across multiple GPUs. PyTorch FSDP (Fully Sharded Data Parallel) enables this by sharding model parameters, gradients, and optimizer states.

## FSDP Basics

The diffusion loss can be written as:

$$
\mathcal{L} = \mathbb{E}_{t, x_0, \epsilon} \left[ \| \epsilon - \epsilon_\theta(x_t, t) \|^2 \right]
$$

where $\epsilon_\theta$ is the noise prediction network.

## Wrapping the Model

```python
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP

model = FSDP(
    unet,
    sharding_strategy=ShardingStrategy.FULL_SHARD,
    mixed_precision=MixedPrecision(param_dtype=torch.bfloat16),
)
```
-->

