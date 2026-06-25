# MiniCPM5 Decode Megakernel — end-to-end build plan (handoff)

**Read this top to bottom, then execute the phases in order. Each phase has an
exact validation gate; do not advance until it passes. At the end you have one
resident Metal kernel that computes the entire decode forward (all 24 layers →
logits) in a single dispatch, never handing MLX's planner a graph to mis-plan.**

This document is self-contained. You should not need to ask anything to execute it.

---

## 0. Why this exists (the problem, settled)

The inference forward composes per-op MLX nodes (`quantized_matmul`, `sdpa`, …).
We tried to insert our own fused `fast.metal_kernel`s (steel `BlockMMA` GEMM) into
that forward to fuse+speed it up. **Confirmed dead end:** MLX's lazy buffer planner
corrupts *chained* `BlockMMA` custom kernels (nondeterministic NaN/garbage/crash) —
the pointwise `fused-gelu` chains fine, ours do not, and ≥2 of ours in one lazy
graph corrupt. The only robust fixes are (a) a per-kernel eval boundary (24 syncs/
forward → net **slower**, 0.5–0.8×), or (b) **don't give the planner anything to
chain: one resident kernel for the whole forward.** This plan builds (b).

The training path already proved the shape: its forward is MLX ops (which chain
fine) + **one** terminal fused kernel (flash-CCE loss), `detachLeaf` at coarse
segment boundaries (`src/train/segmented.ts`). Our megakernel is the inference
analogue — but because inference has no terminal heavy-reduction, the "one kernel"
must be the *whole forward*, resident, coordinating its own stages.

**Scope = DECODE (single new token, M=1).** This is the only case physically
expressible as one dispatch: a single Metal dispatch cannot barrier across
threadgroups, so cross-token prefill attention can't be one kernel — but one token
attending to the *cached* KV has no cross-token dependency. Decode is also the
latency path that *is* serving speed (`[[serving-speed-is-the-user-metric]]`).
Prefill stays on the existing (correct, fast, parity) MLX-ops path.

**Honest perf expectation:** decode is weight-bandwidth-bound (reading ~1 GB of
4/8-bit weights per token is the floor for any method). The megakernel's win is
(1) eliminating ~240 per-op dispatch launches/token, (2) no intermediate device
round-trips (hidden stays resident), (3) zero MLX-planner involvement. Expect a
modest but real decode-latency win (overhead elimination), not a bandwidth
miracle. The *architectural* win (no corruption, fully ours) is the point.

---

## 1. Success criteria (definition of done)

1. A function `decodeMegakernel(model, tokenId, position) → logits[V]` that runs the
   entire MiniCPM5 decode forward in **one** `MetalKernel.apply` dispatch.
2. **Correctness gate (L1, bf16 KV):** teacher-forced greedy trajectory matches
   `goldens/minicpm5-parity.json` — argmax agreement **≥ 98/100**, mean per-step
   logit maxDiff small (this is an L3 path: ~1–2 bf16 ULP/op accumulating; it will
   NOT be bit-exact, gate by teacher-forced agreement + KL like
   `tests/perf-kernel-oracle.test.ts`, threshold ≥ 56/64-style). DETERMINISTIC
   across runs (no nondeterminism — that was the corruption signature).
3. **Perf gate:** decode tok/s ≥ the serial baseline on a paired same-process A/B
   (`scripts/experiments/` style). Not slower. (Stretch: measurably faster.)
4. Default **OFF** behind `MLX_BUN_MEGAKERNEL=1`; the existing forward untouched;
   `bun test tests/minicpm5-*.test.ts` stays green with it off.
5. Wired into the real decode loop (`src/generate.ts`) for `--megakernel` / env.

---

## 2. Hard facts (MiniCPM5-1B-OptiQ-4bit) — do not re-derive

**Snapshot:** `/Users/joshrossi/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`

**Config:** `hidden_size H=1536`, `num_hidden_layers=24`, `num_attention_heads=16`,
`num_key_value_heads=2` (GQA, `nRep=8`), `head_dim=128`, `intermediate_size I=4608`,
`vocab_size V=130560`, `rms_norm_eps=1e-6`, **`rope_theta=5_000_000`** (NOT 10000 —
the code reads `t.ropeParameters.full_attention?.ropeTheta`), `tie_word_embeddings=false`.
`attention scale = head_dim^-0.5 = 128^-0.5`. Plain Llama: **no MiniCPM residual
scaling** (verified — `LlamaLayer.forward` is `inputNorm→attn→+x→postAttnNorm→mlp→+h`).

**Per-layer attention output dims:** q_proj out = `16*128=2048`; k_proj/v_proj out =
`2*128=256`; o_proj in = `2048`, out = `1536`. MLP: gate/up out = `4608`, down in =
`4608`, out = `1536`. lm_head out = `130560`, in = `1536`. embed = quantized 8-bit.

**Per-TENSOR mixed precision (weight quant):** every linear has its OWN `{bits,
group_size}` baked in `config.quantization` (group_size always 64; bits ∈ {4,8}).
This is why the megakernel must be **generated/de-branched per model** — bits is a
compile-time literal per (layer, matrix), not a runtime value. Full table is in
`config.json` under `quantization`; read it with `quantFor(config.quantization,
path)` (`src/model/gemma4-base.ts`). Examples: L0 all 8-bit; L1 q4/k4/v8/o8/g4/u4/d8;
L7 q8/k4/v4/o8/g4/u8/d4; L23 all 8-bit. **Read the table programmatically per build —
do not hardcode.**

**Quantized weight layout** (`QuantizedLinear`, `src/model/gemma4-base.ts:76`):
- `.w`: packed `uint32` `[N_out, K_in*bits/32]`. `.scales`,`.biases`: `bf16`
  `[N_out, K_in/group_size]` (affine: `deq = scale*q + bias`).
- Dequant math is in `STEEL_QMM_HEADER` (`dequantize<T,N,bits>`, `get_pack_factor`,
  `get_bytes_per_pack`) — `src/train/steel-qmm-header.ts`. REUSE IT.

**KV cache:** L1 path = `KVCache` (bf16, `src/model/gemma4-base.ts:243`); its
`updateAndFetch(k,v)` appends `[1,heads,1,D]` at `cache.offset` and returns the full
`[1,heads,offset+1,D]`. `cache.offset` is the position. L2 path = per-layer
`QuantizedKVCache` (mixed bits from `config.kvQuant`) — DEFER to Phase 4.

**RoPE** (`ops.rope`, `src/mlx/ops.ts:100`): `rope(x[B,heads,L,D], dims=head_dim,
base=rope_theta, offset, scale=null)`. For decode L=1, offset=position. The
in-kernel formula (standard NeoX/Llama interleaved-half): for dim pair `i<D/2`,
`theta_i = position / base^(2i/D)`; rotate `(x[i], x[i+D/2])` by `theta_i`. **Match
`ops.rope`'s exact convention** — confirm against `src/mlx/ops.ts` rope binding and
a 1-token parity probe before trusting it (Phase 2 gate catches mismatch).

**Validation goldens (ALREADY EXIST, no regen needed):**
- L1: `goldens/minicpm5-parity.json` (prompt_ids `[0,608,4894,304,6918,357]`,
  greedy_ids[100], vocab 130560) + `goldens/minicpm5-logits-step{0..99}.bin`
  (f32 last-position logits). Produced by `scripts/regen-minicpm5-goldens.ts`.
- L2: `goldens/minicpm5-kv-parity.json` + `…-kv-logits-step*.bin`.

**Reference forward to copy (the source of truth for correctness):**
`src/model/minicpm5.ts` — `LlamaAttention.forward` (95–193), `LlamaMLP.forward`,
`LlamaLayer.forward`, `MiniCPM5Model.forwardHidden/forwardLayers/logitsFromHidden`.
Transcribe THIS op-for-op into the kernel.

---

## 3. Already-built, validated building blocks (reuse, don't rebuild)

All default-OFF, `bun test tests/minicpm5-*.test.ts` green. From this session:
- `src/train/steel-qmm-header.ts` — `STEEL_QMM_HEADER`: MLX's verbatim quantized
  `BlockMMA` GEMM + `dequantize`/`QuantizedBlockLoader`/`BlockLoader`. The GEMM
  building blocks for every projection. `qmm_t_impl` (line 1334) is the full GEMM
  reference (takes dims as `constant int&` — for our metal_kernel we inline the
  `BlockMMA` loop with templateInt dims instead, as `FWD_STEEL_SOURCE` does).
- `src/model/fused-mlp-kernel.ts` — `fusedMlp`: whole MLP (gate+up+silu+down +
  absorbed residual) in ONE dispatch, `hidden` never materialized, per-loader
  mixed-precision bits baked, atomic-accumulated f32 output. **1.9–3.4× standalone
  @ M=8–256, ~1 ULP correct.** This is a working prototype of one megakernel STAGE
  and the dequant/GEMV patterns to copy. (Note: it currently corrupts when CHAINED
  in the lazy graph — that's the whole reason for the megakernel; the kernel math
  itself is correct, proven by `scripts/experiments/fused-mlp-check.ts`.)
- `src/model/steel-linear-kernel.ts` — `steelLinear`: plain quantized linear as our
  dispatch (q/k/v/o/down), ~1 ULP vs `ops.quantizedMatmul`. The projection GEMV
  pattern.
- `src/mlx/metal-kernel.ts` — `MetalKernel`: `apply(inputs, {outputShapeFn|outputs,
  grid, threadGroup, templateInts, templateDtypes, atomicOutputs, initValue})`.
  `*_shape` helpers available in-kernel. `metalCapture` for Xcode GPU traces.
- `src/train/segmented.ts:81` `detachLeaf` (contiguous→eval→`fromBytesCopy`) — the
  graph-break primitive (replicated in `minicpm5.ts`).

**Probe scripts (templates for new validation):** `scripts/experiments/swiglu-*.ts`,
`fused-mlp-*.ts`, `steel-linear-check.ts`, `swiglu-teacherforced.ts` (the
teacher-forced gate harness — copy it).

---

## 4. Architecture of the megakernel

### 4.1 The shape

One resident dispatch. State lives in **device** buffers (shared across
threadgroups); the kernel walks layer 0→23 as a sequence of **stages**, with a
**grid-wide barrier** between stages so stage N+1 sees all of stage N.

Per layer, the stages (each a grid-wide-parallel step, barrier after):
1. `xn = RMSNorm(hidden, inputNorm_w)`  → device `xn[H]`
2. `q = Wq·xn` (`[2048]`), `k = Wk·xn` (`[256]`), `v = Wv·xn` (`[256]`) — quantized
   GEMVs, outputs split across threadgroups → device
3. `rope(q, pos)`, `rope(k, pos)` (per head, D=128)
4. write `k,v` into KV cache at `pos` (device)
5. **attention:** for each of 16 q-heads (GQA: head h uses kv-head `h/8`), online
   softmax of `q_h · K[0..pos]` over the `pos+1` cached keys (scale `128^-0.5`),
   weighted sum of `V[0..pos]` → `attn[2048]`
6. `o = Wo·attn` (`[1536]`); `hidden += o` (residual)
7. `hn = RMSNorm(hidden, postAttnNorm_w)` → device `hn[H]`
8. MLP: `gate = Wg·hn`,`up = Wu·hn` (`[4608]`), `silu(gate)·up`, `down = Wd·(…)`
   (`[1536]`); `hidden += down` (residual)  — the `fusedMlp` body, inlined
After 24 layers: `RMSNorm(hidden, finalNorm_w)` → `lmHead·hidden` → `logits[V]`.

### 4.2 The grid-wide barrier (the crux)

A single dispatch has no built-in cross-threadgroup barrier. Implement a
**persistent-kernel software barrier** via two device atomics (`atomic_uint`):
`arrive` (count) + `sense` (phase). Each barrier: `tg_leader` does
`atomic_fetch_add(arrive,1)`; if it was the last (`==G`), reset `arrive=0` and flip
`sense`; all threadgroups spin-read `sense` until it flips; `threadgroup_barrier`
to fan back into the threadgroup. **HARD REQUIREMENT:** all `G` threadgroups must be
**co-resident** or this deadlocks (a threadgroup waiting on one never scheduled).
So `G` must be ≤ the GPU's max concurrent threadgroups.

Pick `G` conservatively for the M4 Pro (~16–20 GPU cores). Phase 3 determines the
safe `G` empirically (start `G=1`, raise until just before the largest occupancy;
if any deadlock/timeout, lower). Use `dispatchThreads`/grid = `G * TGN`. Provide an
env `MLX_BUN_MEGAKERNEL_G` to sweep. Document the chosen `G`.

> **De-risking:** Phase 2 builds `G=1` (single threadgroup, `threadgroup_barrier`
> only — NO software barrier, hidden in threadgroup memory) to get CORRECTNESS
> first. Phase 3 generalizes to `G>1` with the software barrier for SPEED. Keep the
> per-stage math identical between them.

### 4.3 Weight access — the repack (Phase 1)

A `metal_kernel` can't take ~500 tensors. Repack at load time into a SMALL fixed set
of device buffers + an offset/spec table:
- `WBYTES`: one `uint8` buffer = every quantized weight's packed bytes concatenated
  in a fixed order (L0.q, L0.k, … L23.lm_head). Plus `SCALES` (bf16 concat),
  `BIASES` (bf16 concat). Plus `NORMS` (bf16 concat of all RMSNorm weights).
- `META`: a `uint32`/`int32` table the kernel indexes by `(layer, matrix)` giving:
  byte-offset into WBYTES, scales offset, biases offset, N, K. **bits/group_size are
  baked as template literals per (layer,matrix) in the GENERATED kernel**, not in
  META (they drive the dequant template instantiation).
- Because bits varies per matrix, the kernel is **generated** (like
  `scripts/gen-model.ts`): emit a `forwardLayer_L<i>` inline body per layer with that
  layer's 7 matrices' bits baked, OR a single body that `switch`es on a baked
  per-layer-constant array. Prefer generation: produces
  `src/model/generated/minicpm5-megakernel.ts` with all bits as literals.

KV cache buffers: `KBUF`,`VBUF` device `[24, max_seq, 2, 128]` bf16 (L1). `pos` is a
scalar input. Logits out: `[V]` f32.

---

## 5. Phased plan (execute in order; gate each)

### Phase 1 — Weight repack (foundation)
**File:** `src/model/megakernel-pack.ts`.
**Do:** `packMiniCpm5(model) → { wbytes, scales, biases, norms, meta, layout }`.
Walk `model.layers[i]` (`.attn.{qProj,kProj,vProj,oProj}`, `.mlp.{gate,up,down}`,
`.inputNorm`,`.postAttnNorm`) + `model.finalNorm`,`model.lmHead`,`model.embed`. For
each quantized linear concat `.w` bytes → WBYTES, `.scales`→SCALES, `.biases`→BIASES
(record offsets, N, K, bits, group in `layout`). Concat norm weights → NORMS. Use
`MlxArray.rawBytes()` (eval first) to get bytes; build with `Bun`'s buffers; upload
as `MlxArray.fromBytesCopy`.
**Gate:** unit test — for 3 sample (layer,matrix), slice WBYTES/SCALES/BIASES at the
recorded offset, rebuild a `QuantizedLinear`, run `ops.quantizedMatmul` on a fixed
input, assert **byte-identical** to the original `.forward`. (`scripts/experiments/
megapack-check.ts`.) This catches layout bugs before any kernel.

### Phase 2 — Single-threadgroup correct megakernel (G=1)
**Files:** `src/model/megakernel-kernel.ts` (the `MetalKernel` + dispatch),
`scripts/gen-minicpm5-megakernel.ts` (emits the per-layer-bits-baked SOURCE into
`src/model/generated/minicpm5-megakernel.ts`).
**Design:** ONE threadgroup (`G=1`, `TGN=256` threads). `hidden[H]` in threadgroup
memory (6 KB). Loop layers; each stage uses `threadgroup_barrier`. GEMVs: the 256
threads cover the N outputs in chunks (each thread does `ceil(N/256)` dot-products
over K, dequantizing weight via `STEEL_QMM_HEADER`'s `dequantize`). RMSNorm: parallel
sum-of-squares reduction in threadgroup. Attention: loop heads; per head, online
softmax over `pos+1` cached keys (threads split the key positions, threadgroup
reduce). Inline the `fusedMlp` math for stage 8 (gate/up into threadgroup, silu·up,
down). KV read/write from `KBUF`/`VBUF`. Final: finalNorm + lmHead GEMV → logits[V]
(threads split V).
**Transcribe** `src/model/minicpm5.ts` op-for-op; match dtypes: accumulate in f32,
round to bf16 at each op boundary to track the reference (`(T)` casts, as `fusedMlp`
does). RoPE: match `ops.rope` exactly (verify with a single-layer probe).
**Gate (THE correctness gate):** `scripts/experiments/megakernel-teacherforced.ts`
(copy `swiglu-teacherforced.ts`): drive 100 decode steps via the megakernel,
teacher-forced on `goldens/minicpm5-parity.json`, KV cache in `KBUF`/`VBUF`. Require
**≥98/100 argmax agreement, deterministic across 3 runs, no NaN.** If an early step
mismatches, bisect by stage: add a debug output for `hidden` after layer L (env
`MLX_BUN_MEGA_DUMP_LAYER=L`) and compare to the reference model's per-layer hidden
(capture via the wrapper trick in `scripts/experiments/swiglu-layerN.ts`).

### Phase 3 — Persistent multi-threadgroup (G>1) for SPEED
**Do:** generalize Phase 2 to `G` threadgroups. Move `hidden`,`xn`,`hn`,`q/k/v/attn/
gate/up` to DEVICE scratch (shared). Implement the §4.2 software barrier (`arrive`/
`sense` atomics, leader-flips-phase, spin). Split each stage's outputs across
threadgroups by `tid.x` block (GEMV: threadgroup `g` does N-rows `[g*N/G,
(g+1)*N/G)`). Determine safe `G`: sweep `MLX_BUN_MEGAKERNEL_G` from 1 up; the largest
that (a) never deadlocks/timeouts and (b) maximizes tok/s. Add a 1-second host-side
watchdog around the dispatch during the sweep to catch deadlock (kill + report).
**Gate:** same teacher-forced ≥98/100 + deterministic, AND paired tok/s ≥ baseline.
If `G>1` corrupts (barrier race), the barrier impl is wrong — verify the leader
reset ordering and that EVERY thread (not just leaders) waits on `sense` before
reading shared state, with a `threadgroup_barrier` + `mem_flags::mem_device` after.

### Phase 3 — RESULTS (2026-06-24)

Multi-threadgroup persistent kernel built + correct. Findings, in order discovered:

- **Occupancy sweep:** TGN must be a **power of 2** (the RMSNorm tree reduction
  `for(s=TGN/2;s>0;s>>=1)` silently drops lanes otherwise — TGN=192 gave KL 0.54).
  Smaller TGN packs more co-resident threadgroups (TGN=128 scales past where TGN=256
  collapses). Peak total threads ≈ 12–16k; G beyond co-residency **deadlocks** the
  software barrier (G=144 @ TGN=128 hung). Sweep needs a host watchdog.
- **Barrier cost** (measured, `megakernel-barrier-time.ts`): ~3.8 µs/barrier @ G=48,
  ~145 barriers/token after fusion → ~0.5 ms = ~10% of decode. Not the dominant cost.
- **bits-literal specialization REJECTED for the *naive* GEMV.** Templating on BITS
  and/or K bloated code/registers → lowered max co-resident G → regressed peak
  (164→102–156; full-K-unroll collapsed to 16). The kernel was occupancy/bandwidth-
  bound, not branch-bound. **Lesson: feed the bottleneck (DRAM-latency-hiding =
  occupancy×ILP), not instruction count.**
- **THE win — port mlx's `qmv_fast` decode GEMV verbatim** (`quantized.h`
  qmv_fast_impl/load_vector/qdot → `qmv4`/`load_vec_tg`/`qdot_t`). Three things ours
  lacked: (1) `load_vector` pre-scales x so `qdot` is mask-only (no per-nibble
  shifts); (2) affine folds once per group as `scale*accum + sum*bias`; (3) **4 rows
  per simdgroup reusing a register-resident x_thread** → 4× arithmetic per x-load +
  4 independent accumulators hiding FMA/load latency. Our weight layout already
  matches mlx's, all N,K divide the fast-path blocks → no safe-tail path. This is the
  M=1 decode primitive that was never ported (steel-qmm-header is the M>1 GEMM/BlockMMA
  path). **Jumped 0.70× → ~0.93–0.95× baseline; KL improved to 9.5e-4; removed the
  G≥24 down-tiling constraint (any G now correct).**
- **Barrier fusion:** RMSNorm computed in-place per-threadgroup (`rms_norm_local`,
  every TG normalizes the full hidden — tiny, removes the rms→GEMV grid barrier +
  d_nrm device traffic) and SwiGLU `silu(gate)·up` folded into the down-proj's input
  staging. ~145 barriers/token (from ~194). Perf-neutral at G=32 (barriers already
  hidden) but removes device round-trips.
- **Generated (layer-unrolled, constants-baked) kernel built** (`genSourceMt`, env
  `MLX_BUN_MEGAKERNEL_GEN=1`): per-(layer,matrix) bits/offsets/N/K + layer index L as
  compile-time literals, no META lookups, no runtime bits dispatch. Layer loop
  unrolled (sequential → registers reused, NO occupancy hit, unlike the inner-K
  unroll). **Correct (KL identical) but perf-NEUTRAL** (202.4 vs 202.9 tok/s) —
  confirms the kernel is bandwidth/barrier-bound, not lookup-bound. Kept behind the
  flag as the architecturally-correct path.
- **Peak config:** TGN=256, G=32. Paired same-process A/B: megakernel **~202 tok/s**
  vs baseline **~216 tok/s = ~0.94×**. Correctness 97/100 teacher-forced (3 argmax
  near-ties; KL 9.7e-4), deterministic, no NaN.
- **Remaining gap (~5%) is the resident-kernel structural tax** (~6 grid barriers/
  layer for the row-split GEMV producer→consumer chain + per-stage staging), which is
  largely fundamental to multi-threadgroup decode. Candidate lever to cross baseline:
  fold rope-q into attention to drop one barrier/layer. Needs a CLEAN-machine paired
  measurement (Josh-gated) — the session machine is loaded, only the ratio is trustworthy.

### Phase 4 — L2 quantized KV (IN PROGRESS 2026-06-24, spec ready)
Swap `KBUF/VBUF` for the per-layer quantized-KV format. **Facts gathered:**
- CPM5 `kv_config.json`: per-layer `bits ∈ {4,8}`, `group_size=64`, quantized along
  **head_dim=128** (so 2 groups per head per k/v). Loaded as `config.kvQuant`.
- Layout (`QuantizedKVCache`, gemma4-base.ts:407): per (layer,pos) store quantized
  triple along the KVDIM=256 axis: `packed` uint32 `[256*bits/32]`, `scales`/`biases`
  bf16 `[256/64=4]`. Affine `deq = scale*q + bias` (== our weight dequant).
- **mlx quantize formula to replicate EXACTLY** (`affine_quantize`, quantized.h:2432;
  this is what the golden used via optiq `updateAndFetchQuantized`):
  ```
  n_bins=(1<<bits)-1; eps=1e-7
  wmin=min(group), wmax=max(group)
  scale=max((wmax-wmin)/n_bins, eps); side=|wmin|>|wmax|; scale = side? scale : -scale
  edge = side? wmin : wmax;  q0=round(edge/scale)
  scale = q0==0? scale : edge/q0;  bias = q0==0? 0 : edge
  q = min(round((w-bias)/scale), n_bins)     // dequant: scale*q+bias
  ```
**Implementation steps:**
1. ✅ **DONE — quantize formula validated** (`scripts/experiments/kv-quant-formula-check.ts`):
   the affine_quantize transcription matches `ops.quantize` to bf16 ULP (scale/bias diff
   1.8e-3 @4-bit, 6e-5 @8-bit; dequant residual = expected bf16-storage rounding). The
   riskiest piece is de-risked. Compute scale/bias in f32, store bf16 (as mlx does).
2. **Host:** `MegakernelRunner` holds per-layer quantized KBUF/VBUF (packed/scales/
   biases) sized to kvSeq; bits per-layer baked (literal in the generated kernel).
3. **Kernel write:** after rope, each head's roped k/v (128 dims) → 2 groups of 64 →
   compute wmin/wmax (threadgroup or per-head reduce) → scale/bias → pack q → store at
   current pos. Replaces the bf16 `knewOut/vnewOut` emit.
4. **Kernel read (attend_simd):** dequant EVERY position incl. current (optiq quantizes
   then reads back, so the current entry must also round-trip) from packed+scales+biases.

**Increment 1 (DONE, bf16-storage round-trip): 93/100, KL 1.49e-2, deterministic, no NaN**
(`kv_rt_group<KVBITS>` after rope, `megakernel-kv-teacherforced.ts`,
`MLX_BUN_MEGAKERNEL_KVQUANT=1`). Quantize formula correct. **Gap diagnosed:** optiq's
`quantizedSdpaUnfused` uses `quantizedMatmulQT`, which dequants K/V **to f32 on-the-fly
inside the matmul** — never storing a bf16 dequantized value. Increment 1 stores
`bf16(scale·q+bias)` in the bf16 cache → ONE extra bf16 rounding optiq lacks → KL
15× the L1 path. NOT a formula bug; a storage-precision artifact of the shortcut.
**Increment 2a — PARITY fix (store-int-q, the cleaner path):** the quantized int `q`
(0..15 / 0..255) is EXACTLY representable in bf16 (ints ≤256 are exact). So store `q`
itself in the existing bf16 kcache/vcache (lossless) + per-group scale/bias in small
side buffers `[NLAYERS,KVSEQ,nKvHeads·headDim/64=4]` bf16; `attend_simd<KVBITS>` computes
`scale·q+bias` in f32 on read = optiq's exact f32 dequant, ZERO extra rounding → should
reach the attend_simd ceiling (~97, == L1). Much smaller than bit-packing: kv_rt_group
stores `q` (not dequant) to d_k/d_v + emits scale/bias new-rows; host adds 4 scale/bias
buffers + merges; attend dequants (current-pos scale/bias from device scratch, cached
from the side-buffer inputs). NO memory win (q stored loosely as bf16), but full optiq
parity — the Phase 4 correctness goal.
**Increment 2a — DONE, store-int-q: 93/100, KL 1.38e-2, deterministic, no NaN.**
Stores int q in kcache/vcache (exact in bf16) + bf16 scale/bias; `attend_simd_q<KVBITS>`
dequants to f32 on read. **Found + fixed a real bug:** the current-pos scale/bias were
first written to a NON-ATOMIC output (`sbNew`) read cross-threadgroup by attention →
incoherent (stale) per [[metal-persistent-kernel-coherence]] → 78/100. Fix: route
current-pos scale/bias through ATOMIC scratch `d_sb` (A_LD/A_ST), copy to `sbNew` only
for the host merge; cached scale/bias read from the `sb` INPUT (coherent). → 93/100.
**Surprise / honest correction:** 2a removed increment-1's extra bf16-rounding but
landed at the SAME 93/100 — so **dequant precision was NOT the gap.** The residual
(~14× L1's KL) is a genuine divergence between our quantized KV and optiq's, cause
still OPEN: formula validated vs `ops.quantize` (bf16 ULP), all 24 layers' bits match
kv_config, coherence fixed. Candidate causes to investigate: optiq may keep recent
token(s) unquantized (a bf16 staging window) rather than quantize-on-write; or its
fused quantized-SDPA accumulates differently than our dequant-then-online-softmax.
**ROOT CAUSE FOUND (decisive, in-process vs our bit-exact reference):** the reference
`QuantizedKVCache`+`quantizedSdpaUnfused` is bit-exact with the golden (maxDiff 0,
`tests/minicpm5-kv-parity.test.ts`). Comparing the megakernel's dequantized layer-0 K
to the reference's: **max diff 0.166 (≈ one quant step).** Comparing the *pre-quant*
bf16 roped K (L1): **max diff 1 bf16 ULP** (9.0 vs 9.0625; 425/1536 elems > 1 ULP) —
the `qmv4`-vs-`ops.quantizedMatmul` GEMV rounding difference, i.e. exactly what gives
L1 its 9.7e-4. **Quantization is DISCONTINUOUS**, so that 1-ULP K difference lands on a
q-level / group-min-max boundary and flips a level → a full quant-step dequant error →
amplified 9.7e-4 → 1.38e-2. **NOT a quant bug — the megakernel's intrinsic ~1-ULP GEMV
difference amplified by quant discontinuity. 93/100 is the L2 ceiling (as 97/100 is L1's);
bit-exact L2 would need a bit-exact GEMV, defeating qmv4.** Gate L2 by KL + agreement
(L3 class), not the bit-exact golden. Scripts: `megakernel-kv-{cmpkv,cmpl1,perstep}.ts`.
**Increment 2b — MEMORY win (later):** bit-pack `q` into uint32 (flat KPACK/VPACK,
per-layer literal offsets) to actually shrink 4-bit KV. Same logits as 2a. Deferred.
**Build on the GENERATED kernel** (`genSourceMt`, `MLX_BUN_MEGAKERNEL_GEN`): the
per-layer KV `bits` is fixed on disk (`kv_config.json`), so bake it as a compile-time
literal per layer (same "pre-determined" principle as the weight bits) — the quantize/
dequant helpers are `template<int KVBITS>`, and each unrolled layer emits its literal
`KVBITS` (and `group_size=64`). No runtime kv-bits table lookup. This is why Phase 4
makes the generated path the primary one (the looped kernel would need a runtime kv
table). Phase 4 therefore promotes `genSourceMt` from flag-gated to the L2 default.
**Gate:** `goldens/minicpm5-kv-parity.json` + `…-kv-logits-step*.bin` (already exist),
teacher-forced agreement + KL. Defer until L1 solid (L1 IS solid — parity, Phase 3).

### Phase 5 — Integration + ship
**Do:** `MiniCPM5Model.decodeStep(tokenId, pos) → logits` using the megakernel when
`MLX_BUN_MEGAKERNEL=1`; allocate the packed buffers + KV scratch once at model load
(or first decode), reuse across steps. Wire into `src/generate.ts` decode loop
(n23–n44 in `docs/dag/training-inference-map.html`) — the megakernel REPLACES the
per-step `forwardHidden→logitsFromHidden` at decode (M=1) only; prefill unchanged.
Guard: bf16 KV (L1) only, no adapters, no vision. Add `--megakernel` CLI flag.
**Gate:** `bun test tests/minicpm5-*.test.ts` green (off); a new
`tests/minicpm5-megakernel.test.ts` (teacher-forced gate, env-gated like
`tests/perf-kernel-oracle.test.ts`); paired decode tok/s A/B logged. Update
`STATUS.md` + `benchmarks/RESULTS.md` (preflight-gated `benchmark.sh` for the
quotable number — `[[dirty-machine-numbers-are-garbage]]`).

---

## 5.5 Methodology for the next megakernel (learned 2026-06-24)

**Copy mlx's exact code verbatim into one file → prove bit-identical (per-op harness,
maxDiff 0 vs `ops.*`) → static-analyze that one file → THEN optimize incrementally,
re-running the bit-exact harness after each step.** Why: a hand-port of `qmv_fast` was
1-ULP-correct but NOT bit-identical to what `ops.quantizedMatmul` actually dispatches
for **4-bit M=1** (it uses a different kernel/accumulation order — `qmv4-bitexact-check.ts`
shows 8-bit bit-exact, 4-bit off by exactly 1 bf16 ULP on 12/256 rows, e.g. 1552 vs 1544
= adjacent bf16 values). Invisible at L1 (9.7e-4) but quantization's DISCONTINUITY
amplifies it into the L2 gap. A provably-identical starting copy + per-step gating would
catch any divergence the moment it's introduced, not 24 layers + a quant step downstream.
Steps: (1) copy mlx `quantized.h` GEMV kernels INCLUDING the per-(bits,M,N,K) dispatch
(`qmv_fast`/`qmv`/`qmv_quad`), `rms_norm`, `rope`, `sdpa`; (2) per-op maxDiff-0 harness
before fusing; (3) analyze the single fused file; (4) optimize with the harness as a
regression gate. This megakernel was built L3-first (KL-gated, NOT bit-exact by design),
so its 1-ULP/op drift is within contract — bit-exact is a focused REBUILD, not a patch
(and may cost qmv4's speed if mlx's real 4-bit kernel is the slower qmv_quad).

## 6. Pitfalls (learned this session — do not relearn)

- **Chained custom kernels corrupt under MLX's planner.** The ENTIRE reason for one
  kernel. Don't reintroduce intermediate custom-kernel boundaries.
- **`templateDtypes:{T:x.dtype}` is required** or `T` is undeclared (Metal compile
  error). **`.template store<…>`** needed for dependent names when `T` is a template
  param. Bake dims as `templateInts` / read `x_shape[0]`, don't pass a runtime
  `shape` input array (extra lazy nodes).
- **Match the reference's bf16 rounding op-for-op** (round to `T` at each boundary) —
  `metal::precise::exp`/`tanh` are the only residual vs the reference; that's L3 and
  fine. Do NOT compute everything in f32 then round once (drifts).
- **`atomicOutputs:true` + `initValue:0`** for any atomic-accumulated output.
- **GQA:** 16 q-heads, 2 kv-heads, `nRep=8` → q-head `h` reads kv-head `h/8`.
- **`rope_theta=5e6`, not 10000.** scale `=128^-0.5`. No MiniCPM residual scaling.
- **Software barrier deadlocks if `G` > co-resident threadgroups.** Start G=1.
- **`detachLeaf` ≠ `evalAll`:** eval alone doesn't break the graph; only a fresh
  `fromBytesCopy` leaf does. (Relevant only if you keep any boundary.)
- **`MlxArray` has `.astype`, not `ops.astype`; `ops.reshape`, not `.reshape`.**
- Oracle venv for any golden regen: `/Users/joshrossi/Code/mlx-lm/.venv/bin/python`,
  `MLX_BUN_ORACLE_VENV=…`, `HF_HUB_DISABLE_XET=1`. (Goldens already exist; only
  regen if you change the prompt.)

---

## 7. File manifest (what you create)

```
src/model/megakernel-pack.ts            # Phase 1: weight repack + layout table
scripts/gen-minicpm5-megakernel.ts      # Phase 2: emit per-layer-baked kernel SOURCE
src/model/generated/minicpm5-megakernel.ts   # (generated) the kernel SOURCE + bits
src/model/megakernel-kernel.ts          # Phase 2/3: MetalKernel + decodeMegakernel()
scripts/experiments/megapack-check.ts        # Phase 1 gate
scripts/experiments/megakernel-teacherforced.ts  # Phase 2/3 correctness gate
scripts/experiments/megakernel-perf.ts       # Phase 3/5 paired tok/s A/B
tests/minicpm5-megakernel.test.ts       # Phase 5 CI gate (env-gated)
```
Modify: `src/model/minicpm5.ts` (add `decodeStep` megakernel branch),
`src/generate.ts` (decode-loop branch), `src/cli.ts` (`--megakernel`).

## 8. Order of operations (the literal checklist)

1. [ ] Phase 1: `megakernel-pack.ts` + `megapack-check.ts` → byte-identical gate green.
2. [ ] Phase 2: generator + `G=1` kernel; `megakernel-teacherforced.ts` ≥98/100,
       deterministic ×3, no NaN. Bisect by layer if it fails.
3. [ ] Phase 3: `G>1` + software barrier; sweep `MLX_BUN_MEGAKERNEL_G`; same
       correctness gate + tok/s ≥ baseline. Record chosen `G`.
4. [ ] Phase 4 (optional): L2 quantized KV vs kv-parity golden.
5. [ ] Phase 5: wire into `decodeStep`/`generate.ts`, env+CLI gate, CI test,
       benchmark, update `STATUS.md`/`RESULTS.md`/memory
       `[[cpm5-generate-and-fuse-inference]]`.

**Done = one resident dispatch computes the MiniCPM5 decode forward, ≥98/100
teacher-forced, deterministic, ≥ baseline tok/s, default-off, CI-gated.**
