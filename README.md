# mlx-bun

Native MLX inference for Bun. Run quantized LLMs on Apple Silicon from
TypeScript — no Python, no sidecar server, one runtime.

## Why

MLX is Apple's ML framework: hand-tuned Metal kernels for Apple Silicon,
with official bindings for Python, C++, Swift, and C — but no JavaScript
story. Today, a JS/TS app that wants local MLX inference must shell out to
a Python server (mlx-lm, optiq) and accept that stack's fragility: venv
setup, brittle download tooling, segfaults on exit, monkey-patched HTTP
layers.

The performance-critical work — every matmul, every attention pass — lives
in MLX's C++/Metal core and is exposed through `mlx-c`. The Python layer on
top is pure orchestration: model loading, tokenization, the sampling loop,
serving. That layer is performance-neutral (the GPU dominates), so it can
be rewritten in any runtime without losing speed — and Bun is the right
one:

- **`bun:ffi`** — lowest-overhead FFI of any JS runtime; binds `mlx-c`
  directly, no node-gyp, no binding compilation.
- **`Bun.mmap`** — safetensors weights map zero-copy; model "load" becomes
  page-table setup, restarts are near-instant on warm pages.
- **Fast JSON + base64** — vision requests embed multi-MB base64 images in
  JSON; JavaScriptCore parses them dramatically faster than CPython.
- **`bun:sqlite`** — built-in storage for the model registry, KV-cache
  index, and eval results.
- **One binary, one toolchain** — runtime, package manager, test runner.
  No environment activation. The appliance stays boring.
- **Ecosystem position** — the agent-tooling stack (pi, OpenClaw) runs on
  Bun. mlx-bun puts local inference *in-process* with the agents instead
  of behind an HTTP sidecar.

## What it is not

- Not a kernel library. All GPU compute comes from MLX's tuned Metal
  kernels via mlx-c. We write orchestration, not (initially) shaders.
- Not a Python-ecosystem replacement. Training, research, and exotic
  architectures stay in mlx-lm. We target the handful of model families
  people actually serve locally.
- Not cross-platform. Apple Silicon only, by design — that's where MLX is.

## Goals

1. **Correctness first**: token-for-token logit parity with mlx-lm on the
   same weights before any optimization work.
2. **Serve Gemma-class quantized models** (OptiQ mixed-precision included)
   with an OpenAI-compatible HTTP API: text, vision, tools, streaming.
3. **Beat the Python stack where it's actually weak**: time-to-first-token
   (prompt-cache persistence), startup time (mmap), robustness (no
   crash-loop babysitting), payload handling (vision JSON).
4. **A real model registry**: SQLite index over the HF cache — query
   models by size, capability, quant, sidecars, instead of shell
   archaeology.
5. **Memory contracts**: deterministic fit reports per Apple Silicon SKU —
   "fits on 16 GB at 32k context, ~25 tok/s" as a computed, enforced
   guarantee, not a vibe. Over-budget requests fail fast with clear
   errors, never via Metal OOM.
6. **A platform for inference experiments**: speculative decoding,
   fused-sampling, custom Metal kernels for specific configs — measured,
   on real hardware (M4 Pro, 24 GB).

## Status

Pre-alpha. See [PLAN.md](./PLAN.md) for phases and current progress.

## License

MIT
