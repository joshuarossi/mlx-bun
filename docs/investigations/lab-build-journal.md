# Build journal — mlx-bun Lab (web UI + native quantize/train/dataset + pi web chat)

*Branch `web-ui-and-native-lab`, 2026-06-13/14. Visual summary:
[archive/mlx-bun-lab-report.html](../../archive/mlx-bun-lab-report.html). Evidence
artifact: [benchmarks/lab-verification.json](../../benchmarks/lab-verification.json).*

## Goal

Re-implement the whole mlx-bun web surface as one beautiful, keynote-grade SPA
with five sections — a **full pi-agent chat**, plus **Quantize**, **Fine-tune**,
and **Build Dataset** ported from the OptIQ "lab" — while keeping the status
page. Compute is **native Bun/MLX (no Python)** per Josh's decision.

## The decisions that shaped it

1. **The big fork (asked up front).** Quantize + fine-tune compute could be (a)
   native via mlx-c, (b) orchestrate the installed OptIQ Python, or (c) proxy
   the running `optiq lab`. Josh chose **(a) native** — truest to mlx-bun's "the
   buggy layer doesn't need Python" thesis. Chat = **full pi agent** (all tools).
   Verification = **real tiny runs, pausing for go-ahead** before heavy jobs.

2. **Gate the riskiest unknown first.** Native LoRA needs autograd across the
   FFI boundary. Rather than discover mid-build that it's infeasible, the first
   thing built was `spikes/phase-train-vag.ts`: a tiny LoRA-shaped loss
   (`mean((x + (x@A)@B − y)²)`) differentiated by `mlx_value_and_grad` through a
   `bun:ffi` JSCallback closure, checked against central finite differences.
   **PASS (<1e-2), exactly 2 grads returned (base frozen).** Only then was the
   trainer worth writing. This single check de-risked the entire subsystem.

3. **One SPA, hash-routed, text-imported.** Kept the exact single-binary
   embedding (`with { type: "text" }`) the status page already used — no
   bundler, no asset-resolution to patch in `build-binary.sh`. Design tokens
   lifted from `status-page.html` so the five sections feel like one product.

4. **Mixed job-execution model by safety class.** Async Metal command-buffer
   OOM is **uncatchable** (it `std::terminate`s). So GPU jobs (quantize,
   finetune) run as **crash-isolated child `mlx-bun` subprocesses** behind a GPU
   lease; dataset jobs (pure JS + loopback HTTP) run **in-process**. Both write
   the same NDJSON event log + SQLite row, so the SSE/tail path is uniform.

5. **Open-book ports, not inventions.** Each engine follows a readable source:
   dataset → `optiq/lab/dataset_templates.py` (13 templates, field-for-field);
   trainer → `optiq/lora/{trainer,dpo,config}.py` + mlx-lm `default_loss`;
   quantize → mlx-lm `convert.py` rules + the on-disk OptIQ model format; jobs →
   `optiq/lab/{jobs,db}.py`; chat → pi SDK `examples/sdk/12-full-control.ts`.

## How it was built — parallel orchestration

After laying the shared job contract (`src/jobs/types.ts`), six subsystems were
fanned out to concurrent sub-agents on **non-overlapping files**, then
integrated centrally:

| subsystem | files | how verified |
|---|---|---|
| shared jobs | `src/jobs/*` | 12 tests (lifecycle, GPU lease, crash isolation, zombie, SSE) |
| dataset | `src/dataset/*` | 32 tests (generators, CSV, 90/10 split, 13 templates) |
| quantize | `src/quantize/*` | 6 tests + real-model e2e |
| trainer | `src/train/*`, `src/mlx/autograd.ts` | 19 fast + real-model e2e |
| web SPA | `src/web/app.html` | 7 in-process route tests |
| pi embed | `src/pi-web.ts` | 9 unit + live chat turn |

Shared/owned-by-me files were edited centrally to avoid conflicts:
`src/server.ts` (websocket + Lab routes + serve the SPA), `src/mlx/{ffi,ops}.ts`
(autograd/random/save bindings), `src/cli.ts`, `package.json` (pinned
`@earendil-works/pi-coding-agent@0.79.3`).

## Key technical findings

- **`mlx_save_safetensors` exists** (mlx-c `io.h`) — the quantizer writes real
  HF-layout shards natively; no hand-rolled byte writer, no dtype/alignment bugs.
- **`mlx_value_and_grad` + `mlx_closure_new_func_payload`** are drivable from a
  `bun:ffi` JSCallback (the repo already uses one for the mlx error handler).
  The closure swaps the differentiated primals into `LoraWeights.{a,b}`, builds
  the loss graph, and restores; mlx's graph keeps its own refs, so only A/B
  differentiate and the quantized base stays frozen.
- **No optimizer in mlx-c** → AdamW hand-rolled as array ops (m/v EMA, bias
  correction, decoupled weight decay), each step swapping the leaf handle back
  into the `LoraWeights` so the next forward sees the update.
- **pi tool-approval gate** is a real pre-execution hook: an inline extension
  via `DefaultResourceLoader.extensionFactories` registers `pi.on("tool_call")`
  returning `{block:true}` to deny — read-only tools auto-allow, bash/edit/write
  await a browser decision (120s auto-deny).

## Bugs found and fixed (during the real-model runs)

- **LoRA init key shape** — `mlx_random_normal` got a `[1,2]` key (a row slice of
  the split-keys array) but mlx wants `[2]`. Reshaped the per-module subkey.
- **Quantize e2e path** — the gated test passed a model *id* to
  `quantizeModelDir` instead of a resolved snapshot *path* (the job runner
  resolves via the registry; the direct call didn't). Pointed it at
  `SNAPSHOT_MINICPM5`.
- **Flaky chat test** — the agent sometimes takes a tool-call turn before
  emitting text; the test resolved on the first `turn_end` and saw no tokens.
  Fixed to settle on the first turn that actually streams text. The embed was
  always correct (a debug run showed 25+ text deltas + a tool execution).

## Measured evidence (M4 Pro, MiniCPM5-1B, on-disk)

- **Quantize:** 170 modules → **4.50 bits/weight**, **0.62 GB** dir, **7.0 s**,
  reopened correctly through the loader (quantized embed_tokens as `uint32`).
- **Train:** 20 SFT iters, **loss 4.48 → 0.68** in **4.6 s**, 168 adapters
  mounted. Behavior changed — on "Tell me about your day": base replies normally,
  the UPPERCASE-fixture adapter replies `"MY DAY AHEAD. APPROVE AND PROPERLY…"`.
- **Chat:** a real WebSocket turn streamed text + executed a tool to completion.
- **Tests:** 85+ new, all green; `tsc --noEmit` clean; existing server suite
  17/17 (no regressions).

## Scope: shipped vs designed-seam

- **Shipped (v1):** full SPA (5 sections), pi web chat with tools + approval
  gate, native uniform-affine quantize, native SFT + DPO LoRA, 12/13 dataset
  templates, shared job system, real tiny-run verification.
- **Designed seams (follow-ups):** OptIQ sensitivity+knapsack mixed-precision
  quantization (`QuantizeOptions` already carries the params; throws today);
  batched (B>1) training; `hf_dataset_import`; HF push-to-hub; folding pi's
  assets into the compiled single binary.
