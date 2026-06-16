# Segmented backward: long-context LoRA training that beats the reference

**Status: Phase A (MiniCPM5) COMPLETE — bit-exact, no leak, trains end-to-end.
2026-06-16. Phase B (e4b) is next.** §1–8 are the original design dossier; **§9 is
the Phase-A implementation + results (read it first for current state).**

## 0. The one-paragraph version

mlx-bun (and Python mlx) gradient checkpointing does NOT stream the backward —
it holds all 42 layers' recompute activations at once, so e4b's training backward
spikes to **23 GB live @2048** (resting is only 6.95 GB) and **crashes at 4096+**.
We proved a fix — **segmented backward** — that forces per-segment streaming:
forward saves detached boundary activations at segment edges, then backprop runs
segment-by-segment via a surrogate-loss `value_and_grad`. Only one segment's
activations are ever live. On an activation-dominated toy it beat per-layer
checkpointing (4.26 vs 5.97 GB) with **bit-exact gradients**. Extrapolated to e4b
this lands at **~10 GB @8K** — fitting on the 32 GB M1 Max, where the optiq/mlx-lm
reference cannot (it crashes on e4b @2048+). Next: wire it into the trainer,
MiniCPM5 first (clean), then e4b (handle KV-sharing + per-layer-input + the
O(L²) full-attention layers + mixed-precision quant in the segmentation plan).

---

## 1. What is already done and CORRECT (do not redo)

All committed-worthy, validated this session:

- **Chunk fine-tune experiment (the original goal) — DONE on MiniCPM5-1B.**
  Baseline 11.89/100 → fine-tuned **91.70/100** on lucien's 25-case chunk holdout
  (valid-JSON rate 12% → 100%). Full mlx-bun loop: train → save adapter (hot-swap
  format) → `AdapterManager.mount` → generate. Writeup:
  `docs/investigations/chunk-finetune-experiment.md`. Scripts: `scripts/chunk-eval.ts`,
  `scripts/chunk-finetune.ts`, `scripts/chunk-filter.ts`. Adapter:
  `~/.cache/mlx-bun-finetunes/minicpm5-chunk-final`.

- **`ops.sdpa` is CORRECT** (NOT the inverse of an earlier wrong claim). Validated
  vs autograd ground truth (`scripts/sdpa-vs-manual.ts`): dQ/dK/dV all 0.00%. Use
  it for training. It's O(L²) memory in the backward (mlx autographs the fused op).

- **Flash dK kernel FIXED.** The dKV Metal kernel emitted dK with its (Tkv,D) axes
  transposed in the buffer; fix in `flashBackward` (`src/model/flash-attention.ts`):
  `reshape(ops.contiguous(transposeAxes(dK,[0,1,3,2])), [B,Hkv,Tkv,D])`. Validated
  vs autograd: dK 0.06% non-GQA, 0.12% GQA D=256 (e4b geom). flash is now correct +
  O(L) memory. (But flash is ~30× slower per iter and crashes on e4b at 42-layer
  scale — see §6. Default training attn is ops.sdpa; flash is opt-in via
  `MLX_BUN_TRAIN_ATTN=flash`.)

- **Combined-eval fix in the trainer.** `trainer.ts` used to eval `value` (forward)
  separately via `value.toFloat32()` before `globalNorm(grads)` — that frees the
  forward and forces the backward to recompute+hold everything, crippling
  checkpointing. Now one `evalAll([value, ...grads])` (Python's `mx.eval(v,g)`
  pattern). Verified no MiniCPM5 regression. Toy: separate-eval 0.3% reduction →
  combined-eval 16%.

- **Per-step memory instrumentation.** `MLX_BUN_MEM_LOG=1` logs
  `PEAK(live) / active / cache` per step in `trainer.ts`.

## 2. The diagnosis (why naive checkpointing fails) — measured, not guessed

Measurement methodology (the key unlock, courtesy of the active-vs-cache insight):
`mlx_get_peak_memory` = **peak LIVE (active)**, NOT active+cache (proved: toy
active-after 8.66 + cache-after 6.61 = 15.27 > peak 14.90, impossible if peak were
total). MLX holds freed buffers in a **cache** (not returned to OS) so RSS overstates
live memory; use `activeMemory()` / `cacheMemory()` / `clearCache()` to separate
them (`src/mlx/ffi.ts`). Caveat from the MoE expert-offload work
(`docs/investigations/expert-offload-single-user-moe.md`): `clearCache()` does NOT
reliably return device-buffer RAM to the OS — only the mmap clean-page path does.

Facts established:
- **Forward memory is FLAT** (~8 GB at any seq) — the forward streams fine. The
  whole per-token cost is in the BACKWARD.
- **e4b @2048 (ops.sdpa + grad-ckpt): peak-live 23.2 GB, resting 6.95 GB.** The
  16 GB spike is per-layer MLP/hidden activations held across ALL 42 layers — the
  checkpointed backward does NOT stream.
- **Checkpointing works and matches Python** (toy: both remove exactly 2.28 GB).
  The earlier "checkpoint is 0%/broken" claim was a measurement artifact
  (separate-eval + peak-vs-live confusion). It's NOT broken — it just doesn't
  stream, and neither does Python's (optiq crashes on e4b @2048+ too).
- **e4b @4096 crashes immediately at ~7 GB RSS** (not gradual OOM). A 28 GB
  `set_memory_limit` forcing cache eviction/reuse did NOT help → it's a genuine
  backward-eval allocation failure, not cache non-reuse.
- Memory scales LINEARLY in seq: `peak(L) ≈ 7.7 GB + 7.6 MB/token`. @4096 ≈ 38 GB
  (> 32 → crash). At the IDEAL streamed rate (~0.2–0.5 MB/tok) e4b@8K ≈ 10 GB.

## 3. The fix: segmented backward (PROVEN)

Reference implementation + proof: **`scripts/ckpt-mem-test.ts`** (`SEG=n` mode).

Algorithm:
1. **Forward, saving boundaries.** Run the layer stack; at each segment edge (group
   of `n` layers) materialize (`eval`) and **detach** (`stopGradient`) the hidden
   state into a boundary leaf. Discard intra-segment interiors. Boundaries are
   small (one [B,L,hidden] per edge) and cheap.
2. **Compute the loss** from the final hidden (LM head + response-only CE) and its
   gradient w.r.t. the final hidden — this `dh_out` seeds the last layer segment.
3. **Backward, reverse over segments.** For each segment k (last→first), build a
   `value_and_grad` over `[boundary_leaf_k, ...segment_LoRA_params]` whose loss is
   the surrogate `sum(stop_gradient(dh_out) ⊙ segment_forward(boundary_leaf, params))`
   (the optiq chunked-CE surrogate, generalized to the whole backward). It returns
   `[dh_in, ...dLoRA_segment]`. `dh_in` becomes `dh_out` for segment k−1; accumulate
   `dLoRA`. Only segment k's activations are live during its `value_and_grad`.

Why it's exact: `d/dx sum(stop_grad(dh)⊙y) = (dy/dx)ᵀ dh = dLoss/dx`, and likewise
for params — this is reverse-mode AD done in segments. Verified **0.000%** vs the
full `value_and_grad`.

Proof numbers (activation-dominated toy, `L=8192 D=1024 LAYERS=24`, the e4b regime):

| method | peak | grads |
|---|---|---|
| full, no checkpoint | 6.81 GB | — |
| per-layer `Checkpoint` | 5.97 GB | — |
| **segmented (SEG=4)** | **4.26 GB** (active-live 2.52 ≈ resting 1.68 + 1 segment) | **0.000%** |
| segmented (SEG=2) | 4.66 GB | 0.000% |

Segmented beats per-layer checkpointing and approaches the ideal floor. **Optimal
granularity exists** (SEG=4 < SEG=2): a few layers/segment keeps kernel fusion while
still streaming. NOT all-at-once (spikes), NOT each-tiny-op (loses fusion).

Recompute cost: each segment's backward recomputes its own layers' forward once →
total recompute overhead ≈ **1× forward, independent of segment count**. So segment
count is a knob for PEAK, with ~fixed time cost (plus minor per-`value_and_grad`
and boundary-materialization overhead). The wall-clock target (finish the chunk
task in budget) is mostly set by this fixed 1× recompute, not the segment count.

## 4. Integration plan

### Phase A — MiniCPM5-1B first (clean real-model proof)
Plain 24-layer Llama: no KV-sharing, no per-layer-input, no sliding window, uniform-ish
quant. The trivial case to validate the machinery on a real model.

1. **Model:** add `Gemma4Model`/`MiniCPM5Model` method `runLayerRange(h, aIdx, bIdx,
   cache, ...) -> h'` that runs layers `[aIdx, bIdx)` on hidden `h` (the existing
   `forwardLayers` loop body, parameterized by range). Keep `forwardLayers` as the
   non-segmented path.
2. **Trainer:** add a `segmented` training path (flag `TrainConfig.segments` or auto;
   gate alongside the existing `gradCheckpoint`). It:
   - runs the segmented forward (save detached boundaries),
   - computes response-only CE loss + `dFinalHidden` (already memory-bounded),
   - runs the reverse per-segment surrogate `value_and_grad`, threading the LoRA
     params for each segment as that `value_and_grad`'s argnums, accumulating grads,
   - also handles the embedding + (e4b) per-layer-input grads from the first
     segment's `dh_in`.
3. **Validate:** grads bit-match the current trainer (response-only CE, same seed);
   measure peak drop with `MLX_BUN_MEM_LOG=1`. Expect a clear reduction even though
   MiniCPM5 already fits — it's the template.

### Phase B — e4b (the goal). Extra boundary state to thread across segments:
- **KV-shared donor cache.** Layers [0,24) are donors (own caches); [24,42) are
  sharers reusing the last same-type donor's K/V. Concretely (verified in
  `gemma4.ts`: `numDonors = numHiddenLayers − numKvSharedLayers = 24`,
  `previousKvs`/`cacheIndex`): all sliding sharers reuse **donor 22**'s K/V, all
  full sharers reuse **donor 23**'s K/V. So when a sharer falls in a later segment
  than its donor, **save that donor's K/V (rope-applied) as a detached boundary**
  and thread it into the sharer's segment forward AND its recompute. K/V are tiny
  ([B,2,L,256] ≈ 1 KB/tok per donor), so this is cheap. (Note: `runCheckpointedLayer`
  already threads shared K/V as checkpoint outputs — reuse that plumbing.)
- **Per-layer-input** (`computePerLayerInputs`): [B,L,42,256] computed once from the
  embedding, sliced per layer. Compute it in the forward, **detach + save as a
  boundary**, slice per layer inside each segment. Its gradient (back to the embed /
  projection) accumulates from the per-segment grads.
- **Sliding vs full attention.** 7 full-attention layers (5,11,17,23,29,35,41); the
  rest sliding (window 512). With ops.sdpa the **full layers are O(L²)** in the
  backward (≈1 GB bf16 @8K for the [1,8,L,L] scores); sliding are O(L·512). The
  segmentation must treat a full layer as a heavy unit (see §5).
- **Masks:** one per attention type (sliding/full), built at offset 0; pass into each
  segment (cheap; the sliding [L,L] mask is the only quadratic term besides the full
  attention — already handled by the current trainer).

## 5. The segmentation strategy (the part to get right)

NOT a naive "divide by N". Compute the split points from the model:

**Constraints & inputs (all readable from the model/config):**
- Layer attention type per index (`layer_types`): sliding vs full. Full = O(L²) heavy.
- KV donor/sharer boundary at layer 24 (donors below, sharers above); donor→sharer
  edges that must become saved boundaries (donors 22, 23).
- Per-layer mixed-precision quant bits (e.g. MiniCPM5's OptiQ config has layer-0 at
  8-bit, others 4/8 mixed; e4b's HF config is default 4-bit but the strategy must
  read per-layer bits generically). Bits affect **compute time** per layer (8-bit
  matmul slower than 4-bit), slightly the weight residency — NOT the activation size.
- Uniform per-layer activation size (hidden 2560 + MLP gate/up 2×10240, bf16).

**Memory cost model** (per candidate segmentation):
```
peak ≈ resting(model + grads + optimizer + saved boundaries)
       + max_over_segments( Σ_layers_in_seg uniform_activation(L)
                            + Σ_full_layers_in_seg attn_OL2(L) )   [+ backward transient]
```
At 8K: uniform_activation ≈ 0.38 MB/tok·layer; attn_OL2(full, ops.sdpa) ≈ ~1 GB.
So a 6-layer segment with one full layer @8K ≈ 6·0.38·8192 ≈ 2.3 GB + ~1–2 GB full
≈ 3.3–4.3 GB; with resting ~6.95 GB that's ~10–11 GB. **To stay ≤10 GB, isolate
full-attention layers** (put each in a short segment) and group sliding layers.

**Time cost model:** total ≈ base(fwd+bwd) + 1×fwd recompute (≈fixed) +
per-segment `value_and_grad`/boundary overhead (∝ segment count, small). Weight
per-layer forward time by quant bits + attention type. Target: ≤ a chosen
wall-clock for the chunk task (e.g. N iters × per-iter ≤ budget).

**Natural alignment:** the 6-layer period (`sssssF`) makes 7 segments of 6 (one full
layer each) the obvious first cut, with the donor/sharer boundary at 24 respected
(segments 0–3 = donors, 4–6 = sharers). If peak still > target at 8K, split each
6-group around its full layer (e.g. [0–4 sliding][5 full] …) so no segment carries a
full layer plus many sliding layers. The optimizer picks split points to **minimize
peak subject to the time budget**, respecting: (a) KV donor→sharer boundaries become
saved K/V, (b) don't split mid-attention-pair unnecessarily, (c) keep ≥~3 layers per
segment for fusion.

**Deliverable:** a `planSegments(model, {L, peakTargetGB, timeBudget})` function that
returns the split indices + which donor K/V to save, computed from the above.

## 6. Notes, risks, alternatives
- **Flash vs ops.sdpa for the full layers.** Flash (now dK-correct) is O(L) and would
  remove the full-attention O(L²) term entirely — but flash is ~30× slower per iter
  and currently crashes on e4b at 42-layer scale (immediate C++ exception; separate
  bug). With segmented backward, the full-attention O(L²) is only transient within
  one segment, so ops.sdpa may suffice; revisit flash only if the full term blows the
  budget at 8K AND its e4b crash is fixed.
- The chunk data needs ≥4096 (median 4092; 0% ≤2048; 98% ≤8192). Success = e4b
  trains at 8192 ≤ ~10 GB AND the chunk eval (`scripts/chunk-eval.ts`) shows a
  quality delta on e4b like MiniCPM5's.
- Training requires `MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0` (those fused
  CustomKernels have no vjp).
- MLX `Date.now()`/random caveats don't apply here; standard determinism via seed.

## 7. Key files
- `scripts/ckpt-mem-test.ts` — segmented-backward proof + memory harness (SEG/CKPT/REUSE, active/cache/peak).
- `scripts/ft-chunk-smoke.ts` — e4b train/fwd/infer smoke (GRAD_CKPT, MEM_LIMIT_GB, MLX_BUN_MEM_LOG).
- `scripts/sdpa-vs-manual.ts`, `scripts/flash-dk-debug.ts`, `scripts/flash-grad-test.ts` — gradient correctness.
- `scripts/chunk-{eval,finetune,filter}.ts` — the chunk experiment pipeline.
- `src/train/trainer.ts` — training loop (combined-eval, mem-log, gradCkpt ctx). Add the segmented path here.
- `src/train/forward.ts`, `src/train/loss.ts` — training forward + response-only CE.
- `src/model/gemma4.ts` — e4b model: `forwardLayers`, `runCheckpointedLayer`, `computePerLayerInputs`, KV-sharing (`numDonors`, `previousKvs`, `cacheIndex`), `layer_types`. Add `runLayerRange`.
- `src/model/minicpm5.ts` — MiniCPM5 (Phase A target).
- `src/mlx/autograd.ts` (`ValueAndGrad`), `src/mlx/checkpoint.ts` (`Checkpoint`), `src/mlx/ffi.ts` (memory fns, `stopGradient`, `evalAll`).
- Memory: `[[e4b-lora-training-seqlen-ceiling]]` (full findings), `[[opssdpa-dk-vjp-bug]]`, `[[three-level-fidelity-tree-model]]`.

## 8. First action on resume
Phase A step 1: add `runLayerRange` to `MiniCPM5Model`, then a segmented training
path in `trainer.ts`, validate bit-exact grads + measure peak on
`scripts/ft-chunk-smoke.ts`-style MiniCPM5 run. Then Phase B (e4b) with the §5 plan.

---

## 9. Phase A IMPLEMENTED + validated (2026-06-16, session 2)

Phase A is built and the mechanism is **proven on the real MiniCPM5 model**.
Two findings landed (one a win, one a blocker). Code:
- `src/model/minicpm5.ts` — `runLayerRange(h, aIdx, bIdx, cache)` (added;
  `forwardLayers` now delegates to it). NOTE it does **not** dispose its input
  `h` (the caller / autograd owns the boundary leaf).
- `src/train/segmented.ts` — `SegmentedBackward` class (build once, `.step(batch)`
  per iter) + `planSegmentsBySize`. Reusable per-segment value_and_grads.
- `src/train/trainer.ts` — `TrainConfig.segmentSize` (0 = off; >0 = layers per
  segment). Gated in `sftLoop`, mutually exclusive with `gradCheckpoint`,
  MiniCPM5-only for now. `src/train/job.ts` threads `segment_size`.
- `src/mlx/array.ts` — `MlxArray.fromBytesCopy(bytes, shape, dtype)` (a COPYING
  leaf constructor via `mlx_array_new_data`, page-aligned, unlike `fromView`).
- `src/train/loss.ts` — `responseOnlyCe` is now exported.
- Harness: `scripts/segmented-grad-test.ts` (correctness + peak + `LEAK_LOOP`),
  `scripts/seg-debug.ts` (forward-fidelity bisect), `scripts/vag-leak-test.ts`
  (minimal value_and_grad leak repro). `scripts/chunk-finetune.ts` takes `SEG=n`.

### 9.1 Correctness — the mechanism is exact
`scripts/segmented-grad-test.ts` (MiniCPM5, synthetic B=1 batch):
- **Under flash attention: grads bit-match the full value_and_grad — relNorm
  0.0000%, maxAbs 0.0, loss identical.** The segmentation algorithm (forward
  boundaries → loss-head dh → reverse per-segment surrogate) is reverse-mode AD
  done in segments, exactly equal to one big backward. PROVEN.
- Run training with `MLX_BUN_TRAIN_ATTN=flash` for bit-exact segmented grads.

### 9.2 Forward-fidelity finding: `ops.sdpa` fused-eager ≠ autograd forward
Under the default `ops.sdpa`, the segmented grads diverge ~6% (relNorm) from the
full value_and_grad — **not** a segmentation bug. Root cause (bisected in
`scripts/seg-debug.ts`): mlx's fused `ops.sdpa` computes a **different bf16 result
in its eager forward (12.0712) than in its autograd-decomposed forward (12.0568)**
— a 0.12% gap, independent of LoRA (holds at lora scale 0). Flash uses one forward
for both → no gap. Consequences:
- The **existing non-segmented trainer already trains against the autograd forward
  (12.0568) while inference uses the eager forward (12.0712)** — pre-existing, not
  introduced here.
- Segmented saves boundaries with the eager forward but recomputes/backprops with
  the autograd forward, so the dh seed is inconsistent under `ops.sdpa` → ~6% grad
  perturbation (bf16-class; segmented's *loss* still matches the true eager forward
  exactly). Fine for LoRA fine-tuning; use flash if you want exactness.

### 9.3 Memory — the win is real and large
`MLX_BUN_MEM_LOG=1`, MiniCPM5 (24 layers, hidden 1536), peak LIVE:

| seq | full backward | segmented (SEG=4) | saved |
|---|---|---|---|
| 512  | 3.15 GB | 1.87 GB | 1.3 GB |
| 2048 | 10.91 GB | 3.44 GB | **7.5 GB (3.2×)** |
| 4096 | **21–26 GB** (spikes) | 6–8 GB | ~3× |

This is the thesis confirmed: at 4096 the full backward spikes to 21–26 GB (would
crash e4b); segmented stays at 6–8 GB. Segmented makes long-context training FIT.

### 9.4 A per-segment memory leak — FOUND and FIXED (use mlx_vjp, not value_and_grad)
The first segmented implementation used the optiq surrogate-loss trick — a
`value_and_grad` of `sum(stop_grad(dh) (.) segment_forward(...))` per segment. It
**leaked ~32 MB of genuinely-live memory per segment per step** (linear, no
plateau: `LEAK_LOOP` 1.12 → 6.61 GB over 30 iters at SEG=4/2048; ~0.19 GB/step;
would OOM well before a 300-iter run). The leak survived `clearCache`,
`Bun.gc(true)`, `synchronize`, disposing every returned array, and reusing the
value_and_grads across steps. It was segmented-specific (the non-segmented trainer
is flat). Minimal repro that pins it to `value_and_grad`: `vag-leak-test`
**MODE=layers** (runLayerRange under value_and_grad) leaks ~6 MB/iter; **MODE=vjp**
(the same forward via mlx_vjp) is **flat**.

**Fix:** drive each segment's backward with **`mlx_vjp`** (the natural primitive:
forward + an explicit cotangent `dh`) instead of a surrogate-loss `value_and_grad`.
New binding `Vjp` in `src/mlx/autograd.ts` (+ `mlx_vjp` in `ffi.ts`). Per segment:
`vjp.apply([boundary, ...LoRA], [dh])` returns outputs (the segment output, unused)
and vjps `[dh_in, ...dLoRA]` — exactly what the chain needs, no surrogate scalar.
The loss head is likewise a vjp of `responseOnlyCe(finalNorm(boundary))` with a
scalar cotangent 1.0, returning the loss and `dh`. Result: **active is flat**
(0.93 GB × 15 iters in `LEAK_LOOP`; 1.04 GB × 12 iters end-to-end through the
trainer at SEQ=4096), with the memory win intact (peak 10.91 → 3.29 GB @2048).

NOTE on the OTHER memory fix that is also in place: mlx `eval` does **not** detach —
an eval'd array keeps its upstream graph. Each forward boundary is therefore copied
into a fresh leaf via `detachLeaf` (`MlxArray.fromBytesCopy`), otherwise each
boundary drags a whole layer-stack's activations (~0.1 GB per 4-layer segment of
*within-step* retention before this fix). This is independent of the vjp fix.

### 9.5 STATUS: Phase A complete. Next actions
Phase A (MiniCPM5) is done and production-ready: mechanism bit-exact (flash),
memory win confirmed, no leak, trains end-to-end through `scripts/chunk-finetune.ts`
(`SEG=n`). Remaining:
1. Run the real chunk fine-tune (`SEG=4 SEQ=4096 ITERS=300 bun scripts/chunk-finetune.ts`,
   ideally `MLX_BUN_TRAIN_ATTN=flash` for exact grads) and confirm `scripts/chunk-eval.ts`
   quality matches the non-segmented baseline (91.70).
2. **Phase B (e4b)** with the §5 plan (KV-sharing, per-layer-input, full-attn O(L²)
   isolation). e4b adds `runLayerRange` to `Gemma4Model` with donor-KV /
   per-layer-input boundary threading; the `SegmentedBackward` + vjp machinery and
   the §5 segmentation strategy carry over. This is the path to the original goal:
   e4b @8K under ~10 GB where the optiq/mlx-lm reference crashes.

---

## 10. Phase B (e4b) design — model side LANDED, trainer side specified (2026-06-16)

**Model side DONE** (`src/model/gemma4.ts`, additive — `forwardLayers` untouched):
- `runLayerRange(h, aIdx, bIdx, cache, masks, perLayer, donorKvIn) -> {h, donorKvOut}`
  — runs layers `[aIdx,bIdx)`, slices `perLayer` per layer, threads KV-shared
  donors: a sharer reads its donor's K/V from `donorKvIn` (earlier segment) or
  `donorKvOut` (same range); reused donors' K/V (e4b: {22,23}) are returned for
  later segments, non-reused donors' K/V disposed. Does NOT dispose `h`.
- `makeTrainingMasks(cache, L)` — sliding + full masks, built once.
- `embedForSegmented(ids) -> {hScaled, perLayer}` — scaled input embedding (first
  boundary) + the `[B,L,nLayers,width]` per-layer-input tensor.
- `reusedDonors` getter ({22,23} for e4b, ∅ for dense).
- **Validate first** (when GPU free): running the full range through `runLayerRange`
  must bit-match `forwardLayers` (a forward-equivalence check on the 12B/e4b parity
  harness) before trusting the backward.

**Trainer side — `SegmentedBackwardGemma4` (to build + validate):** same skeleton as
the MiniCPM5 `SegmentedBackward`, with TWO additions.

(a) **per-layer-input is a pure constant boundary — NO gradient threading.** The
`per_layer_input_gate` / `per_layer_projection` LoRA live INSIDE the layer (applied
to the sliced `pls`), so they're differentiated within each segment's vjp normally.
The `perLayer` tensor itself feeds in as a constant (its grad would flow to the
embed / `per_layer_model_projection`, neither a LoRA target) — so detach it once and
slice per segment; discard its cotangent. Easy.

(b) **the KV-shared donor K/V is a SECOND boundary stream WITH its own cotangent.**
The donor's K/V depend on the donor layer's q/k/v LoRA and are attended by every
sharer, so `dLoss/d(donor LoRA)` gets contributions from the donor's own attention
AND all sharers. Threading:
- **Forward (boundary-saving):** when a segment produces a reused donor's K/V
  (`donorKvOut`), detach it (rope-applied K + V, tiny — ~1 KB/tok) and save as a
  boundary; later sharer segments pass it in via `donorKvIn`.
- **Backward (reverse), two extra pieces:**
  - keep a cotangent accumulator `dKV[d]` per reused donor d (init zero).
  - a SHARER segment's vjp differentiates `[boundary_h, donorK, donorV, ...LoRA]`
    with cotangent `[dh]`; its vjps for `donorK/donorV` are ACCUMULATED into `dKV[d]`.
  - a DONOR segment (produces donor d's K/V) has a MULTI-OUTPUT forward
    `[h_out, donorK, donorV]`; its vjp takes cotangents `[dh, dKV[d].k, dKV[d].v]`
    (the `Vjp` class already supports nOut>1 + multiple cotangents) and returns
    `[dh_in, ...donor LoRA]`. This folds the sharers' gradient back into the donor.
  - donors 22 (sliding) and 23 (full) are each reused by all sharers of their type;
    if both live in one segment, that segment's forward outputs 5 arrays
    `[h, k22, v22, k23, v23]` with 5 cotangents.
- **Segmentation (the §5 plan):** respect the donor/sharer split at layer 24 and
  ISOLATE the 7 full-attention layers (5,11,17,23,29,35,41) — each is O(L²) in the
  backward under ops.sdpa (~1 GB bf16 @8K), so put each full layer in a short
  segment and group the sliding layers. The natural first cut is the 6-layer
  `sssssF` period → 7 segments of 6 (one full layer each). `planSegments` from §5
  returns the split indices + which donor K/V to save.

Everything else (forward boundaries via `detachLeaf`, head vjp with cotangent 1.0,
reverse `dh` chain, `mlx_vjp` not surrogate) is identical to the MiniCPM5 path.
Target: e4b @8K ≤ ~10 GB, then `chunk-eval` quality on e4b (the original goal —
chunk data is mostly 3.4–8.2K, useless at the ≤2K the reference is capped to).
