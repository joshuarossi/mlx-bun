---
title: How it compares
description: Where mlx-bun sits next to its inspirations mlx-lm and mlx-optiq, and the bit-exact parity it holds to both.
---

mlx-bun stands on the shoulders of two projects, and credits them as both
**inspirations** and **correctness oracles**:

- **[mlx-lm](https://github.com/ml-explore/mlx-lm)** — Apple's MLX language-model
  library: a broad, mature toolkit for running, training, quantizing, and serving
  LLMs on Apple Silicon, across many model architectures. Its bf16 logits are
  mlx-bun's **L1 parity oracle**.
- **[mlx-optiq](https://mlx-optiq.com/)** — a full quantize / fine-tune / serve
  suite built on top of that, with sensitivity-based mixed-precision
  quantization, quantized-KV attention, a vision sidecar, and more. Its quantized
  outputs are mlx-bun's **L2 parity oracle**.

Both do **far more** than mlx-bun, and they're the projects to reach for when you
want breadth — more model families, training at scale, and capabilities well
beyond mlx-bun's. For what they offer, **their docs are the source of truth.**
mlx-bun isn't competing on features; it's a faithful, narrow reimplementation of
a slice of what they do, in a different runtime.

## What mlx-bun is

A Bun/TypeScript-native serving and library layer that runs a few model families
on Apple Silicon with **no Python** — shippable as a single signed, notarized
binary.

It's both a [library](/guides/library/) you import and an
[HTTP server](/guides/http-api/) speaking the OpenAI, Anthropic, and OpenAI
Responses protocols, with tool calling, vision input on Gemma-4, a byte-capped
prompt cache, per-request LoRA hot-swap, quantized and mixed-precision KV, and
memory admission control. It can also [create quantized models](/guides/library/)
and do LoRA fine-tuning, including a segmented backward pass that keeps
long-context training within tight memory.

The supported families are deliberately few — Gemma-4 (e2b/e4b/12B/26B-A4B MoE),
MiniCPM5, and Qwen3.5 — because the whole point is holding each one bit-for-bit
faithful to the references, which takes a hand-ported op composition per
architecture. See [Choosing a model](/getting-started/models/).

## What it doesn't do (yet)

Honestly, and about mlx-bun specifically:

- **Broad model coverage** — it's a handful of families, not the dozens mlx-lm
  supports. Adding one is real work (parity, per-architecture).
- **Batched training** — the SFT loss and backward run per-row (B=1). It batches
  data loading and the forward prefill, but not true B>1 training.
- **Pixel-exact vision** — vision features are ~1% off the reference
  (greedy-faithful, sufficient for agent tasks), not yet fully bit-exact.

For any of these, mlx-lm and mlx-optiq are the right tools — and mlx-bun stays
faithful to both by design.

## Parity: what's bit-exact, and to what

This is the axis mlx-bun is built around. "Bit-exact" means identical token IDs
and logits to the reference — not "close."

The key thing to understand: mlx-bun has **two reference-faithful modes, and you
run one at a time** — it does not claim to match both at once.

- **bf16 KV** matches **mlx-lm** bit-for-bit (the L1 oracle).
- **optiq mixed-precision KV** matches **mlx-optiq** bit-for-bit (the L2 oracle).
  This is the *typical* quantized setup — and because quantizing the KV cache is
  a genuinely different computation, it is **not** bit-exact to mlx-lm's bf16.
  That's by design, not a regression: in this mode optiq is the reference, not
  mlx-lm.

So read the table per column — in each mode, mlx-bun reproduces *that mode's*
oracle exactly:

| Model family | bf16 KV → vs mlx-lm (**L1**) | mixed-precision KV → vs mlx-optiq (**L2**) |
|---|---|---|
| MiniCPM5-1B | ✅ bit-exact logits | ✅ bit-exact |
| Gemma-4-12B | ✅ bit-exact logits | ✅ bit-exact |
| Gemma-4-e4b | ✅ bit-exact logits | ✅ bit-exact |
| Gemma-4-26B-A4B (MoE) | ✅ bit-exact logits | ✅ bit-exact |
| Qwen3.5 (dense) | ✅ bit-exact logits | ✅ bit-exact |
| Vision (SigLIP, e4b) | — | ⚠️ ~1% RMSE (greedy-faithful, not yet bit-exact) |

Optional performance kernels (`MLX_BUN_FUSED_GELU`, `MLX_BUN_PERF_KERNEL`, …) are
a third tier (**L3**): off by default, gated to a small KL tolerance rather than
bit-exactness. See [Correctness](/about/correctness/).
