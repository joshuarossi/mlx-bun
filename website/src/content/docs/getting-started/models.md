---
title: Choosing a model
description: Supported model families, what fits your Mac, and the deterministic fit check.
---

Scope is deliberate: a few model families held to **bit-exact** logit parity
with the Python reference, rather than dozens held to none. Currently MiniCPM5,
the Gemma-4 OptiQ quants, and Qwen3.5-4B.

## Supported models

| Model | Download | Fits on | Vision | Notes |
|---|---|---|---|---|
| [`MiniCPM5-1B-OptiQ-4bit`](https://huggingface.co/mlx-community/MiniCPM5-1B-OptiQ-4bit) | 0.92 GB | 8 GB | — | Sub-GB starter for 8 GB machines; bit-exact 100-step oracle parity, tool calling + agent loop verified |
| [`Qwen3.5-4B-OptiQ-4bit`](https://huggingface.co/mlx-community/Qwen3.5-4B-OptiQ-4bit) | 3.1 GB | 8 GB | — | bf16-KV bit-exact parity (vs mlx-lm); thinking + tool calling; ~74 tok/s predicted |
| [`gemma-4-e4b-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-e4b-it-OptiQ-4bit) | 7.0 GB | 16 GB | ✓ | **Recommended starter** (16 GB+); ~54 tok/s |
| [`gemma-4-12B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-12B-it-OptiQ-4bit) | 8.4 GB | 16 GB | ✓ | Vision sidecar + tool calling, both verified end-to-end |
| [`gemma-4-26B-A4B-it-OptiQ-4bit`](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit) | 18 GB | 24 GB | — | MoE (top-8 of 128 experts); ~54 tok/s — the Python servers crash loading it on 24 GB |

The larger `Qwen3.6-27B` is in bring-up — see
[PLAN.md](https://github.com/joshuarossi/mlx-bun/blob/main/PLAN.md).

## Will it fit? Ask `fit`

`fit` is deterministic, not vibes. It reads the weight bytes from safetensors
headers, computes KV bytes/token from the config (sliding-window layers capped,
MoE active-expert bytes for decode), adds a calibrated prefill transient, and
compares against your machine's wired-memory ceiling.

```sh
mlx-bun fit gemma --ctx 32768          # fits? max context? predicted tok/s
mlx-bun fit gemma --ctx 8192 --skus    # ...the same, across the Apple Silicon lineup
```

Predictions are recorded next to measured peaks in the eval DB, so the numbers
are accountable.

## Downloading

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit   # resumable, checksum-verified
mlx-bun scan                                          # index your HF cache
```

Downloads resume across interruption, every blob is sha-verified, and the cache
layout is exactly Hugging Face's — so an existing HF cache is picked up as-is.
If a Hugging Face download stalls at 0%, `mlx-bun get` uses plain HTTPS (no Xet)
and resumes where it left off.

For the cache layout, listing filters, and reclaiming disk from superseded
snapshots, see [Model management](/guides/model-management/).
