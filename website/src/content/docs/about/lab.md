---
title: The lab
description: The experimental side of mlx-bun — training research, speculative decoding, sampling curve design, and the write-ups behind them.
---

mlx-bun is also an AI lab: parity work, kernels, training methods, and
sampling experiments live next to the runtime that actually serves them. The
polished features you use started here, and the research trail is public —
every experiment gets a design doc or investigation write-up in the repo.

Everything on this page is **experimental by design**: opt-in, honestly
labeled, and held to the same rule as the rest of the project — measured
numbers or it didn't happen.

## Fine-tuning on your Mac

LoRA fine-tuning (SFT / DPO / ORPO) runs natively — `mlx-bun train <model>
--data <dir>` — with a memory stack built for Apple Silicon's constraints:

- a **flash-CCE Metal head** that never materializes the `[tokens, vocab]`
  logits matrix,
- a **segmented backward pass** (gradient-checkpointed layer activations), and
- **prefix-sharing** for preference data (one forward over
  `[prompt; chosen; rejected]`).

Together they brought an 8192-token ORPO step on a 4B model from
out-of-memory to ~13 GB. Watch a run live with `mlx-bun train-watch`.

Start here: [Fine-tuning quickstart](/guides/fine-tuning-quickstart/) · full
[training reference](/reference/training/) · design write-ups:
[segmented backward](https://github.com/joshuarossi/mlx-bun/blob/main/docs/design/segmented-backward-training.md),
[ORPO training](https://github.com/joshuarossi/mlx-bun/blob/main/docs/design/orpo-training.md).

## The curve designer

Sampling research: HLG (hybrid-log-gamma) sampling treats the logit
distribution like a photographic tone curve — roll off the top, boost the
mids, gentle the tail. The server exposes it (`--hlg-sampling`, per-request
`hlg` overrides), and the **interactive curve designer ships in the server UI
at `/curves`** — design a curve against live logits and see what it does to
the distribution.

Write-ups:
[HLG sampling design](https://github.com/joshuarossi/mlx-bun/blob/main/docs/design/hlg-sampling.md),
[the investigation](https://github.com/joshuarossi/mlx-bun/blob/main/docs/investigations/hlg-sampling-investigation.md).

## Speculative decoding (DSpark)

An implementation of DFlash-style KV-injection drafting — a small drafter
model trained to speculate multiple tokens for a larger target. The
architecture is built and validated; making it a net speedup on real targets
is ongoing research.

Write-ups:
[DSpark design](https://github.com/joshuarossi/mlx-bun/blob/main/docs/design/dspark-speculative-decoding.md),
[research handoff](https://github.com/joshuarossi/mlx-bun/blob/main/docs/investigations/dspark-handoff.md).

## Diffusion Gemma

A port of a diffusion-based text model (block-parallel denoising instead of
autoregressive decode) into the same runtime — exploring what non-AR decoding
looks like on Apple Silicon.

Write-up:
[diffusion-gemma port](https://github.com/joshuarossi/mlx-bun/blob/main/docs/design/diffusion-gemma-port.md).

## Where the research lives

- [`docs/design/`](https://github.com/joshuarossi/mlx-bun/tree/main/docs/design)
  — design docs for features and experiments.
- [`docs/investigations/`](https://github.com/joshuarossi/mlx-bun/tree/main/docs/investigations)
  — dated research journals and handoffs, including the dead ends.
- [`benchmarks/RESULTS.md`](https://github.com/joshuarossi/mlx-bun/blob/main/benchmarks/RESULTS.md)
  — the curated numbers everything above is held to.
