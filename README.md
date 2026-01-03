# Personal Website (Hugo-based)

## Local Development

```bash
hugo server -D   # -D includes drafts
```

Open http://localhost:1313

## Creating a Blog Post

```bash
hugo new blog/my-post.md
```

## Blog Post Template

```markdown
---
title: "Your Post Title"
date: 2026-01-03
slug: "your-post-slug"
description: "Brief description for SEO"
draft: false
tags: ["pytorch", "cuda", "ml"]
math: true
toc: true
---

## Introduction

Your intro text here.

## Math Equations

Inline math: $\alpha + \beta = \gamma$

Block math:

$$
\mathcal{L} = \mathbb{E}_{t, x_0, \epsilon} \left[ \| \epsilon - \epsilon_\theta(x_t, t) \|^2 \right]
$$

Numbered equation:

$$
\tag{1}
\sigma(t) = \frac{1}{1 + e^{-t}}
$$

## Code Examples

Python:

```python
import torch

def train_step(model, batch, optimizer):
    optimizer.zero_grad()
    loss = model(batch)
    loss.backward()
    optimizer.step()
    return loss.item()
```

C++/CUDA:

```cpp
__global__ void matmul_kernel(float* A, float* B, float* C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (row < N && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < N; k++) {
            sum += A[row * N + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}
```

## Images

![Alt text](/images/my-image.png)

Or with caption:

{{< figure src="/images/my-image.png" caption="Figure 1: Description" >}}
```

## Front Matter Options

| Option | Description |
|--------|-------------|
| `math: true` | Enable LaTeX rendering |
| `toc: true` | Show table of contents |
| `draft: true` | Hide from production |
| `tags: [...]` | Post tags |
