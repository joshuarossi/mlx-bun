---
title: Why mlx-bun
description: Why rewrite the MLX serving layer in Bun instead of shelling out to Python.
---

MLX is Apple's ML framework: hand-tuned Metal kernels for Apple Silicon, with
official bindings for Python, C++, Swift, and C — but **no JavaScript story**.
Today, a JS/TS app that wants local MLX inference must shell out to a Python
server (mlx-lm, optiq) and accept that stack's fragility: venv setup, brittle
download tooling, segfaults on exit, monkey-patched HTTP layers.

## The performance-neutral layer

The performance-critical work — every matmul, every attention pass — lives in
MLX's C++/Metal core and is exposed through `mlx-c`. The Python layer on top is
**pure orchestration**: model loading, tokenization, the sampling loop, serving.
That layer is performance-neutral (the GPU dominates), so it can be rewritten in
any runtime without losing speed.

## Why Bun specifically

- **`bun:ffi`** — the lowest-overhead FFI of any JS runtime; binds `mlx-c`
  directly, no node-gyp, no binding compilation.
- **Lazy native weight loading** — MLX's loader materializes tensors on first
  use, so opening an 8.9 GB model takes milliseconds, and warm restarts are
  near-instant on cached pages.
- **`Bun.Image`** — native OS image codecs (HEIC, AVIF, WebP, JPEG, …) for the
  vision path, EXIF auto-orientation included.
- **`bun:sqlite`** — built-in storage for the model registry and eval DB.
- **One binary, one toolchain** — runtime, package manager, test runner.

The result is a single binary with no Python anywhere — and, served over HTTP,
[the fastest startup and TTFT of any stack tested](/about/benchmarks/), with
[bit-exact correctness](/about/correctness/) against the Python reference.
