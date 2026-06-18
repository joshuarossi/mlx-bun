---
title: Introduction
description: What mlx-bun is, what it's for, and its deliberate scope.
---

**mlx-bun** is native MLX inference for [Bun](https://bun.sh): run quantized
LLMs on Apple Silicon from TypeScript — no Python, no sidecar server, one
runtime. It is two things at once:

- a **local LLM server** that speaks the OpenAI, Anthropic, and OpenAI
  Responses protocols, so anything that talks to those APIs can point at it; and
- a **TypeScript library** you can `import` to drive generation directly
  inside a Bun process.

## The idea

MLX is Apple's ML framework — hand-tuned Metal kernels for Apple Silicon,
with official bindings for Python, C++, Swift, and C, but **no JavaScript
story**. Today a JS/TS app that wants local MLX inference has to shell out to
a Python server (mlx-lm, optiq) and accept that stack's fragility: venv setup,
brittle download tooling, segfaults on exit, monkey-patched HTTP layers.

The performance-critical work — every matmul, every attention pass — lives in
MLX's C++/Metal core and is exposed through `mlx-c`. The Python layer on top
is pure orchestration: model loading, tokenization, the sampling loop,
serving. That layer is performance-neutral (the GPU dominates), so it can be
rewritten in any runtime without losing speed — and Bun is the right one.
[Read the full rationale →](/about/why/)

## Deliberate scope

mlx-bun supports a **few model families held to bit-exact logit parity** with
the Python reference, rather than dozens held to none. Currently MiniCPM5 plus
the Gemma-4 OptiQ quants — see [Choosing a model](/getting-started/models/).

## Requirements

- An **Apple Silicon Mac** (MLX is Metal-only, so macOS only by design).
- For the source/bunx paths: [Bun](https://bun.sh) ≥ 1.3.14. The Homebrew and
  direct-download binaries bundle everything and need no toolchain.

Ready? Head to [Installation](/getting-started/installation/).
