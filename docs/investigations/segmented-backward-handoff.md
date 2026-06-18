# Handoff — segmented backward training (2026-06-16)

Current-state report for the segmented-backward LoRA training work. Deep dossier
(design, proofs, every measurement): [`docs/design/segmented-backward-training.md`](../design/segmented-backward-training.md)
§9 (MiniCPM5) and §10 (e4b). Branch: `segmented-backward-training`,
PR [#9](https://github.com/joshuarossi/mlx-bun/pull/9).

## TL;DR

Long-context LoRA SFT that **streams the backward segment-by-segment** so only one
segment's activations are live at a time — training fits at context lengths where
the full backward spikes. Two phases, both working:

- **MiniCPM5 (Phase A): done, production-ready.** Bit-exact mechanism, no memory
  leak, trains end-to-end. Real 300-iter chunk fine-tune → **chunk-eval 95.10/100**
  (beats the 91.70 non-segmented baseline; pre-tune 11.89).
- **e4b / gemma-3n (Phase B): built + validated.** Forward bit-exact; grads
  bf16-class; trains **all 42 layers at 8K context** where `mlx_lm.lora` OOMs.

**Parity:** our **non-segmented** training is **bit-exact with mlx-lm** at 2k
(forward, loss, AND gradient — verified by running mlx-lm's own `default_loss` /
`nn.value_and_grad`). The **segmented** path is **bf16-class (~2%)** off, a
grouping-controllable bf16 non-associativity (not a logic bug).

## What was built

| file | what |
|---|---|
| `src/train/segmented.ts` | `SegmentedBackward` (MiniCPM5) + `SegmentedBackwardGemma4` (e4b) + `planSegmentsBySize`; the per-segment vjp driver, `detachLeaf` |
| `src/mlx/autograd.ts` | `Vjp` — `mlx_vjp` binding (the backward primitive; see "leak" below) |
| `src/mlx/ffi.ts` | `mlx_vjp` FFI decl |
| `src/mlx/array.ts` | `MlxArray.fromBytesCopy` — graph-free leaf copy (row-major) |
| `src/model/minicpm5.ts` | `runLayerRange` (forwardLayers delegates) |
| `src/model/gemma4.ts` | `runLayerRange` + `makeTrainingMasks` + `embedForSegmented` + `reusedDonors` (additive; forwardLayers untouched) |
| `src/train/trainer.ts` | `TrainConfig.segmentSize`; gated segmented path (MiniCPM5 + Gemma4) |
| `src/train/loss.ts` | exported `responseOnlyCe`, `maskedCe` |

**Enable:** set `segmentSize` (layers per segment) > 0 in the train config, or
`SEG=n` in `scripts/chunk-finetune.ts`. 0 = the normal full backward.

How it works (B=1 SFT): forward saves a DETACHED boundary (graph-free leaf) at each
segment edge → a loss-head `mlx_vjp` gives `dh` for the last boundary → reverse
per-segment `mlx_vjp`s thread `dh` and the segment's LoRA params, accumulating
grads. Only one segment's activations are live. e4b adds two boundary streams: the
per-layer-input tensor (a pure constant) and the **KV-shared donor K/V** (a second
boundary stream WITH cotangent accumulation — the intricate part; docs §10).

## What was validated (honest numbers)

**Correctness**
- MiniCPM5 segmented grads vs the full value_and_grad: **bit-exact under flash**
  (relNorm 0.0000%). Under `ops.sdpa`, ~6% — a *pre-existing* `ops.sdpa`
  eager-vs-autograd forward divergence, not segmentation.
- e4b: forward **bit-exact** vs full; single-consumer donor reuse **bit-exact**;
  natural-cut donor-KV grads **~1% (bf16 non-associativity)** — single-consumer
  exact, flat in consumer count, tracks summand count (donor 22's 15 sharers
  ≈0.46% vs donor 23's 3 ≈0%), grouping-dependent for both bf16 AND fp32. fp32
  accumulation does NOT help (the term is mlx's within-vjp bf16 sum). **Controllable
  by the segment cut** (coarser sharer grouping → tighter, down to bit-exact at
  1 consumer), not the dtype.
- **Parity vs mlx-lm (ran their code):** forward/loss — denominator (`M` vs
  `ntoks`) bit-exact across 6 mask spans incl. edges; response-only CE == our
  full-masked CE (a pure memory optimization); loss bit-exact on 4/6 spans, 0.5
  float32-ulp on 2/6 (a logsumexp/reduction f32 effect, ~5e-5%, harmless).
  Gradient — our FULL (non-segmented) `dB` over all 42 q_proj **bit-exact** with
  mlx-lm; segmented `dB` ~2.3% (the bf16 donor-KV effect).

**Memory leak (found + fixed).** The first cut used a surrogate-loss
`value_and_grad`; it leaked ~32 MB/segment/step (mlx-level, not GC/cache/sync
reclaimable). **Fixed by using `mlx_vjp`** (the natural primitive — no surrogate).
End-to-end now flat (active constant across a 300-iter run). Repro:
`scripts/vag-leak-test.ts` (MODE=layers leaks via value_and_grad; MODE=vjp flat).

**Memory vs the real reference** (`mlx_lm.lora --grad-checkpoint`, the way a user
trains — it loads the OptiQ e4b directly). mlx-lm checkpoints **per-layer**; ours
groups `segmentSize` layers. Matched grouping (both per-layer = segSize 1, all 42
layers, batch 1):

| L | mlx-lm (per-layer) | ours (segSize=1) |
|---|---|---|
| 2048 | 12.84 GB | 8.76 GB |
| 4096 | 20.87 GB | 10.93 GB |
| 8192 | **OOM** (25.7 GB @16 layers) | 15.29 GB |

Ours lower at every length AND trains all 42 layers at 8K where mlx-lm OOMs. **Two
confounds, not isolated:** (1) mlx-lm materializes the full `[1,L,262k]` logits
(~4 GB @4K) while we use response-only CE; (2) our full backward streaming vs
mlx-lm's per-layer checkpoint. So the gap is part CE-optimization, part mechanism —
not purely "segmentation beats checkpointing." (Earlier "reference crashes at 4K /
~70 GB" was WRONG — it used mlx-bun's *own* ineffective checkpoint as the baseline.)

## How to run an adapter

The fine-tune saves a hot-swap adapter dir (`adapters.safetensors` +
`optiq_lora_config.json` + `adapter_config.json`).

**One-off generate** (verified working) — `scripts/run-adapter.ts`:
```sh
ADAPTER=~/.cache/mlx-bun-finetunes/minicpm5-chunk-segmented \
  PROMPT="Split into chunks and return JSON: ..." \
  MAXTOK=256 bun scripts/run-adapter.ts
# omit ADAPTER for the base model; MODEL=<dir> to change base; SYSTEM=... TEMP=...
```

**Score it on the chunk task:**
```sh
ADAPTER=~/.cache/mlx-bun-finetunes/minicpm5-chunk-segmented bun scripts/chunk-eval.ts
```

**Serve it** (you run the server; mount via the API):
```sh
# 1) start: mlx-bun serve <model-dir>
# 2) mount:  curl -X POST localhost:PORT/v1/adapters -d '{"id":"chunk","path":"<adapter-dir>"}'
# 3) list:   curl localhost:PORT/v1/adapters     # unmount: DELETE /v1/adapters/chunk
```
The adapter activates per request through `loraState`; in code the pattern is
`new AdapterManager(model).mount(id, dir)` then `model.loraState.active = [id]`.

**Train a new adapter** (segmented):
```sh
# MiniCPM5, seq 4096, segments of 4 layers:
MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 \
  SEQ=4096 ITERS=300 SEG=4 DATA=<data-dir> ADAPTER=<out-dir> \
  bun scripts/chunk-finetune.ts
# e4b: add MODEL=<e4b-dir> and use SEG=2 (or 1) for ≥8K to keep peak down.
```
Training REQUIRES `MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0` (those fused kernels
have no vjp). Use `MLX_BUN_TRAIN_ATTN=flash` for exact grads (slower).

## What's next / open

1. **e4b @8K toward ~10 GB** (currently 15.3 GB segSize=1): the §5 full-attention
   ISOLATION `planSegments` — put each O(L²) full-attn layer (5,11,17,23,29,35,41)
   in its own short segment. Mechanism + tuning knob are proven; this is peak-shaving.
2. **Isolate the memory confound** (optional): run ours at segSize=1 with full-logits
   CE to separate the response-only-CE saving from the streaming mechanism.
3. **mlx-bun's own gradient checkpoint is ineffective** (23 GB @2048 vs mlx-lm's
   12.8) — orthogonal bug; segmented sidesteps it.
4. Scale knobs: `segmentSize` is the peak↔grad-fidelity knob (finer = lower peak,
   more donor-KV bf16 deviation).

## Diagnostic scripts (kept)

`scripts/segmented-grad-test.ts` (MiniCPM5 grads + peak + leak loop),
`segmented-grad-test-e4b.ts` (e4b grads + peak; RANGES/SEG_ONLY/SEG_DUMP),
`parity-vs-mlxlm.ts` + `grad-parity-vs-mlxlm.ts` (mlx-lm parity; Python sides in
`/tmp/mlxlm-*.py`), `vag-leak-test.ts`, `seg-debug.ts`, `gemma4-runlayerrange-test.ts`,
`run-adapter.ts`, `chunk-{finetune,eval}.ts`.
