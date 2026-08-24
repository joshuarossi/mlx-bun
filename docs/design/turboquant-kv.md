# TurboQuant KV — design (Phase 13)

Status: v1 wired end-to-end (2026-07-06): codec + `TurboQuantKVCache` +
`--kv-quant turbo[:k<bits>v<bits>]` (cli.ts, serve/generate/bench) +
`maybeQuantizeKv` conversion + `GenerationGateway` solo-only refusal +
`kv-store.ts` persistence + `scripts/turboquant/eval-turboquant-curve.ts` (KL/ppl curve
script; not yet RUN against a real model — that's the next stage's gate).
Owner seam: L2 cache format, L1-unmodified attention (dequantize-on-fetch),
eval-gated. Opt-in only — naked default stays L1.

## What it is

Rotation-based KV-cache quantization: signed int8 affine keys + FWHT-rotated
3-bit Lloyd-Max values, per-32-group fp16 scales. More usable context at the
same memory (2.56× KV compression at the k8/v3 default, head_dim 128), NOT a
weight quantizer. Composes with (is orthogonal to) the per-layer mixed-KV
allocation axis — TurboQuant is the QUANTIZER axis (frontier plan §7.2).

## Oracle chain (decided 2026-07-06 from the research fan-out)

Two unrelated implementations share the name; do not conflate:

- **The paper** (arXiv:2504.19874, Google): dense QR random rotation, no
  groups, no K/V asymmetry, optional QJL residual stage. It anchors the WHY
  (rotate→Gaussian marginal→Lloyd-Max optimal; 4^-b distortion law) but not
  the layout.
- **vllm-metal** (`vllm-project/vllm-metal`, `vllm_metal/attention/caches/
  turboquant.py` + `kernels_v2/turboquant.metal`): the engineering variant.
  optiq's `runtime/mtp/turboquant.py` config layer is lifted verbatim from it
  (byte-identical `CENTROIDS_3BIT`, matching op signatures in optiq
  `cache_state.py`). **This is our oracle** — "the oracle is whoever ships
  it." Its Python reference functions are pure MLX; we vendor them and
  generate bit-exact goldens with the oracle venv.
- mlx-vlm's 6.3k-line module is a THIRD design (whole-vector norms, MSE/Prod
  codecs, keys rotated too) — noted, not our target. Its numeric test oracles
  (MSE≈{0.36, 0.117, 0.03} at bits {1,2,3} on unit vectors) are still useful
  sanity anchors for the rotation+Lloyd-Max math.
- vllm-metal's rendered docs page contradicts its own source (claims keys are
  rotated; the code never rotates keys). Trust the source.

## Algorithm (vllm-metal reference semantics, exact)

Per token, per kv-head, groups of 32 along head_dim (head_dim ∈ {64,128,256,
512}, must divide by 32):

**Keys — NO rotation, asymmetric affine, per-32-group:**
- signed (q8_0/int8, bits=8): `max_val=127; scale=(max−min)/(2·max_val);
  zero=round((max+min)/(2·scale)); idx=clip(round(x/scale − zero), −127, 127)`
  stored as int8, one byte per element (no packing at 8 bits).
- unsigned (q5_0/q4_0/int2…): `max_val=2^bits−1; scale=(max−min)/max_val;
  zero=round(min/scale); idx=clip(round(x/scale − zero), 0, max_val)`, packed.
- Dequant (both): `x̂=(idx+zero)·scale`. scale/zero fp16, one pair per group.
- Reference routes intermediates through fp16 (and deliberately drops the
  +1e-8 scale epsilon because it underflows in fp16) — match the Python
  reference's ACTUAL behavior, verified by goldens, not its comments.

**Values — FWHT + Lloyd-Max, per-32-group RMS scale:**
- `y = FWHT(x · signs)` where `signs ∈ {±1}^d` from `mx.random.randint(0,2,
  (d,), key=mx.random.key(42))`, and FWHT normalizes by 1/√d.
- `scale = sqrt(mean(y²))` per 32-group (RMS, not min/max); `y_n = y/(scale+1e-8)`.
- `idx = searchsorted(BOUNDARIES, y_n)` — nearest centroid. 3-bit table:
  centroids ±{0.24509, 0.75601, 1.34391, 2.15195}, boundaries ±{0.50055,
  1.04996, 1.74793}, 0. Other bit-widths (2/4/5/8): iterative Lloyd-Max on a
  unit normal — we generate those tables ONCE from the vendored reference and
  hardcode them (parity by construction; no runtime iteration).
- Pack: flat little-endian bitstream, element i at bits [i·b, i·b+b), values
  may straddle two bytes (3-bit: 8 values → 3 bytes).
- Dequant: `x̂ = InvFWHT(centroids[idx] · scale · signs⁻¹)` (inverse = apply
  FWHT then multiply signs; Hadamard is an involution up to normalization).

**Per-token-per-head bytes (k8v3, d=128):** 128 (K int8) + 8+8 (K scale/zero)
+ 48 (V packed) + 8 (V scale) = 200 vs 512 bf16 → 2.56×. The centroid table is
a shared constant, not per-token. This reproduces optiq's `compression_ratio`.

**Sign vectors are hardcoded constants per head_dim** (64/128/256/512),
generated from the reference's key(42) — exactly what vllm-metal does in its
.metal source. Deterministic across machines and spill/restore.

## v1 architecture in mlx-bun

Dequantize-on-fetch: `TurboQuantKVCache implements Cache` (does NOT subclass
KVCache — that keeps it auto-excluded from batching), `updateAndFetch(k,v)`
quantizes the new tokens into packed storage and returns the dequantized bf16
active window, so the standard `ops.sdpa` path runs unmodified — the same
pattern optiq's `runtime/kv/rotating.py` uses for its v1. No generated-file
changes: a novel cache class fails every `#matches()` guard and falls back to
the monolith by design. Quantization groups run along head_dim only —
token-axis slicing stays byte-safe (standing invariant).

Files (from the codebase-map seams):
- `src/mlx/turboquant-ops.ts` — NEW: fwht (bind `mlx_hadamard_transform`,
  confirmed exported by libmlxc), encode/decode keys + values, pack/unpack.
- `src/mlx/turboquant-tables.ts` — NEW, GENERATED by regen script: sign
  vectors per head_dim + Lloyd-Max centroid/boundary tables per bit-width.
- `src/model/gemma4-base.ts` — NEW `TurboQuantKVCache` (full-attention only in
  v1; rotating/sliding-window layers stay bf16 — documented limitation).
- `src/generate.ts` `maybeQuantizeKv()` — the single conversion chokepoint
  (serve serial lane + generate + eval all flow through it); keep the
  `offset===0` skip and `quantizedKvStart` semantics.
- `src/cli.ts` — `--kv-quant turbo[:k<bits>v<bits>]` (default k8v3).
- `src/serve/generation-gateway.ts` — explicit solo-only refusal (belt +
  braces on top of the automatic instanceof exclusion).
- `src/kv-store.ts` — new `CacheKind "turboquant"`, branches in
  snapshotCache/loadKvCache/cloneKvCaches; header carries kBits/vBits.
- `src/model/fingerprint.ts` — NOT touched, by design symmetry: uniform
  `--kv-quant 4|8` is a CLI-only runtime lever that never feeds
  `configFingerprint()` either (only the per-layer `kv_config.json` scheme
  does); TurboQuant is the same class of lever, so it gets the same
  non-treatment. The SSD-cache compat key (`server.ts`'s `schemeKey`) DOES
  fold in the TurboQuant scheme directly (`turbo-k<bits>v<bits>`), same as it
  already does for uniform bits — that's the actual anti-collision mechanism
  for this class of scheme, not the fingerprint.
- Docs same-commit: server-config.md, cli.md, features-matrix.md.
- Tests: `tests/turboquant-ops.test.ts` (golden bit-exactness vs vendored
  reference + model-free math props), `tests/turboquant-cache.test.ts` (cache
  invariants, growth/trim, persistence roundtrip — synthetic arrays, no
  model/golden dependency), `scripts/regen-turboquant-goldens.ts`.
- `scripts/turboquant/eval-turboquant-curve.ts` — the Gate 3 quality-vs-bpw curve script:
  bf16 baseline + {k8v8,k8v4,k8v3,k8v2,k4v3,k4v2} sequentially, reusing
  `src/eval/kl.ts`'s `evaluateKlKvArm` (teacher-forced serving-decode KL,
  real `TurboQuantKVCache.fromKVCache` conversion) and
  `src/eval/perplexity.ts`'s `evalPpl` (bf16-forward anchor column).
  Typechecks + `--help`/arg-parsing verified; not yet RUN against a real
  model — that run (and reading the resulting curve against the paper's law)
  is the next stage's job.
- Vendored reference: `lab/repro/vllm-metal-turboquant/` (their Python file +
  provenance note), driven only by the regen script via the oracle venv.

## Gates — ALL PASSED 2026-07-06 (M1 Max 32 GB)

Gate 3 measured curve (MiniCPM5-1B, `scripts/turboquant/eval-turboquant-curve.ts`,
teacher-forced serving-decode KL vs bf16, 8 prompts × 128 tokens, 32 decode
steps; affine baselines via the same `evaluateKlKvArm` harness):

| scheme | effective KV bits | mean KL vs bf16 |
|---|---|---|
| bf16 | 16.00 | 0 (control) |
| uniform kv8 (affine g64) | 8.50 | 0.00246 |
| turbo k8v8 | 8.75 | 0.00214 |
| turbo k8v4 | 6.75 | 0.00936 |
| **turbo k8v3 (default)** | **6.25** | **0.0325** |
| turbo k8v2 | 5.75 | 0.175 |
| uniform kv4 (affine g64) | 4.50 | 0.0516 |
| turbo k4v3 | 4.25 | 0.0622 |
| turbo k4v2 | 3.75 | 0.205 |

Shape reproduces the paper's law: value bits dominate, ~4^-b decay, cliff at
v2. Headline: turbo adds operating points between affine kv8/kv4 — the k8v3
default (2.56× KV compression) beats uniform kv4's KL with room to spare.
Live smokes: cpm5 + e4b generation coherent under turbo:k8v3 (e4b emits the
one-time rotating-layers-stay-bf16 warning). The paper's own LongBench
numbers were NOT rerun (different benchmark harness) — the reproduction is
shape-level plus the codec-level D_mse≈0.03 anchor, which our 3-bit
roundtrip test hits.

1. **Quantizer parity (bit-exact, the hard gate):** our encode indices,
   scales, zeros, packed bytes, and dequant outputs match the vendored
   vllm-metal Python reference on golden vectors (head_dim 64/128; configs
   k8v3/k4v3/k4v2/k8v4/k2v5/k5v8 — spanning every kBits/vBits value the CLI
   accepts, per the 2026-07-06 integration review). This is an oracle-backed
   scheme at the codec level.
2. **Math sanity (model-free):** FWHT involution/orthogonality; roundtrip MSE
   at 3-bit on unit-normal data ≈ paper's D_mse≈0.03 band.
3. **Quality-vs-bpw curve (Phase 13 exit criterion):** teacher-forced KL
   (src/eval/kl.ts) + perplexity vs bf16 KV on MiniCPM5-1B (head_dim 128,
   pure full-attention) across {k8v8, k8v4, k8v3, k8v2, k4v3, k4v2}; curve
   shape must match the paper's law (≈quality-neutral ≥3.5 effective bits,
   marginal degradation at 2.5, cliff below). e4b spot check second. Model
   runs SEQUENTIAL (32 GB box rule).
4. Whole-repo `tsc --noEmit` = 0; fast suite green; no batching regression
   (turbo requests route serial with a clear reason).

## Deferred inverse FWHT (LANDED 2026-07-06, post-v1, Josh-directed)

Attention is linear in V, so `InvFWHT(Σᵢ wᵢ·v̂ᵢ) = Σᵢ wᵢ·InvFWHT(v̂ᵢ)`:
`updateAndFetchDeferredV` returns the V window still in the rotated domain
and the attention site un-rotates the OUTPUT once per query row
(`tq.unrotateValues`) — O(q·d log d) per step instead of O(T·d log d).
Opt-in per attention site via `SharedKv.vRotated` (monolith gemma4.ts —
KV-shared consumer layers inherit the flag through sharedIn — and
minicpm5.ts); every other consumer keeps calling `updateAndFetch` (eager)
and stays correct. Not bit-identical to eager (bf16 rounding in the rotated
domain before the transform); measured k8v3 KL 0.0338 vs eager 0.0325 —
same quality. Paired fetch-path A/B on a LOADED M1 Max: never slower,
~10-20% off fetch cost at 4k ctx, noise-level at 8k (dequant gather
dominates both paths) — no speed claim until a quiet-machine benchmark.sh
run; the win is removing the O(T) transform, which matters more once the
gather itself is fused.

## Future: rotation-based WEIGHT quantization (noted 2026-07-06, Josh)

The same rotate-then-quantize mechanism applies to weights, and we already
ship a quantization tool (`convert`/`fuse` verbs) to hang it on — as a
further optimization of quantization itself, the quantizer leg of the §7.1
mixed-precision program (allocation × quantizer, same orthogonality as KV):

- Rotation smears outlier channels so a low-bit codebook covers the signal
  mass — the QuaRot/SpinQuant family (both cited by the TurboQuant paper).
- Weights beat KV on one axis: the rotation FOLDS into adjacent weight
  matrices offline (R into one layer, Rᵀ into the next) → zero runtime
  cost, no online transform at all.
- Weights lose on the other: they're static, so calibration-aware methods
  (GPTQ/AWQ/imatrix, optiq sensitivity maps) are admissible and set a
  higher baseline than any calibration-free scheme — the win to chase is
  rotation COMPOSED WITH calibration/allocation, not instead of it.
- A Lloyd-Max weight FORMAT needs custom quantized-matmul kernels — the
  26B gather-qmv shelving (dispatch fixed-cost ate the prize) is the
  cautionary precedent. Rotation-folding into mlx's EXISTING affine format
  needs no new kernels and is the cheap first experiment.
- Activations (W4A4/QuaRot act-quant): more involved (online rotation,
  fused kernels) and mispriced for this hardware — no int4 tensor cores,
  decode is weight-bandwidth-bound. See w4a16-compute-precision-spike.md.
  Not queued.

Gate when picked up: perplexity + frozen 6-task eval at equal bpw vs the
plain affine convert output (the §7.1 gate, eval DB rows).

## Non-goals for v1 (recorded so they don't creep)

- Fused quantized-SDPA Metal kernel (the remaining fetch cost is the
  unpack+gather; deferred InvFWHT — see above — already landed).
- Rotating/sliding-window TurboQuant cache; batched TurboQuant; QJL residual
  stage (Q_prod); entropy coding (paper explicitly declined it too).
- TurboQuant on the speculative lane: `--kv-quant turbo` + `--draft-model`
  keeps the KV scheme — those requests decode serially WITHOUT speculation
  (the spec loop is bf16-KV-only; excluded in the server's spec-eligibility
  gate with a startup warning, 2026-07-07 review fix — turbo was previously
  routed into the spec lane and silently dropped).
- Head dims beyond {64,128,256,512}: REFUSED AT SERVER START (2026-07-07
  review fix — validation was lazy on the first cache append, so an
  unsupported model 500'd every request mid-prefill; createServer now
  checks the config's full-attention head dim against
  TURBOQUANT_HEAD_DIMS, and the cache-level check stays as the backstop).
- Speed claims of any kind — v1 dequant-on-fetch is expected slower per-step
  at long context; this ships as a memory/context feature like uniform KV.
