---
status: active
axis: ON
canonical-for: turboquant
plan-anchor: "Phase: TurboQuant weights — rotation-folded quantization, Qwen3.8-27B target `[ ]` (opened 2026-08-17)"
last-verified: 2026-08-23
---

# TurboQuant — rotation-based quantization (KV leg landed, weights leg open)

One canonical doc for both legs of the rotate-then-quantize program.
Sources folded in: `docs/design/turboquant.md` (KV, landed 2026-07-06)
and `docs/design/turboquant.md` (weights, open). Status/changelog
prose lives in PLAN.md under the plan-anchor above (weights) and the closed
Phase 13 entry (KV); this doc keeps mechanism, invariants, decisions with
rationale, measured curves, and open items.

## Naming: TurboQuant is a KV method by origin

TurboQuant (arXiv:2504.19874, Google) is a KV-cache quantizer: rotate the
value vectors so their marginals are near-Gaussian, then Lloyd-Max quantize.
That is the leg we ship under `--kv-quant turbo`. The **weights leg is this
repo's extension** of the same mechanism to weight matrices — mechanically
it is the QuaRot/SpinQuant family (rotation folded offline into adjacent
weights, then quantized with mlx's stock formats), not anything the
TurboQuant paper describes. The shared name records the shared idea
(rotate → Gaussian marginal → better codebook coverage) and that both are
the QUANTIZER axis of the mixed-precision program: they compose with, and
never replace, per-layer allocation (OptiQ-style) and calibration.

| leg | what is rotated | when | oracle | state |
|---|---|---|---|---|
| KV | value vectors (keys affine, unrotated) | online, per appended token | vllm-metal `turboquant.py` | landed 2026-07-06 |
| weights | residual-stream basis of every linear | offline, folded into weights | QuaRot + SpinQuant fold code; mlx-lm GPTQ | open (PLAN "TurboQuant weights") |

---

# Part A — KV leg (`--kv-quant turbo`)

## What it is

Rotation-based KV-cache quantization: signed int8 affine keys + FWHT-rotated
3-bit Lloyd-Max values, per-32-group fp16 scales. More usable context at the
same memory (2.56× KV compression at the k8/v3 default, head_dim 128). Owner
seam: L2 cache format, L1-unmodified attention (dequantize-on-fetch), opt-in
only — the naked default stays L1 (bf16 KV).

## Oracle chain (decided 2026-07-06)

Two unrelated implementations share the name; do not conflate:

- **The paper** (arXiv:2504.19874): dense QR random rotation, no groups, no
  K/V asymmetry, optional QJL residual stage. Anchors the WHY (rotate →
  Gaussian marginal → Lloyd-Max optimal; 4^-b distortion law), not the layout.
- **vllm-metal** (`vllm-project/vllm-metal`,
  `vllm_metal/attention/caches/turboquant.py` + `kernels_v2/turboquant.metal`):
  the engineering variant. optiq's `runtime/mtp/turboquant.py` config layer is
  lifted verbatim from it (byte-identical `CENTROIDS_3BIT`, matching op
  signatures in optiq `cache_state.py`). **This is our oracle** — "the oracle
  is whoever ships it." Its Python reference is pure MLX; we vendor it at
  `lab/repro/vllm-metal-turboquant/turboquant_reference.py` (fetch provenance
  in `PROVENANCE.md` beside it) and generate bit-exact goldens through the
  oracle venv. Quirks are preserved on purpose: the port matches what the file
  computes, not what its comments say.
- mlx-vlm's module is a THIRD design (whole-vector norms, MSE/Prod codecs,
  keys rotated too) — not our target; its unit-vector MSE anchors
  (≈{0.36, 0.117, 0.03} at bits {1,2,3}) remain useful sanity checks.
- vllm-metal's rendered docs claim keys are rotated; the code never rotates
  keys. Trust the source.

## Algorithm (vllm-metal reference semantics, exact)

Per token, per kv-head, groups of 32 along head_dim (head_dim ∈
{64,128,256,512} — `TURBOQUANT_HEAD_DIMS` in `src/mlx/turboquant-tables.ts`).

**Keys — NO rotation, asymmetric affine, per-32-group:**
- signed (int8, bits=8): `max_val=127; scale=(max−min)/(2·max_val);
  zero=round((max+min)/(2·scale)); idx=clip(round(x/scale − zero), −127, 127)`,
  one byte per element (no packing at 8 bits).
- unsigned (bits ∈ {2,4,5}): `max_val=2^bits−1; scale=(max−min)/max_val;
  zero=round(min/scale); idx=clip(round(x/scale − zero), 0, max_val)`, packed.
- Dequant (both): `x̂=(idx+zero)·scale`; scale/zero fp16, one pair per group.
- The reference routes intermediates through fp16 and deliberately drops the
  `+1e-8` scale epsilon (it underflows in fp16). Our port upcasts the affine
  arithmetic to fp32 (production feeds bf16 K; bf16 arithmetic shifted
  rounding-boundary indices vs the reference) and casts only scale/zero to
  fp16 at the end — reproducing the reference's real defect that a
  constant-valued block overflows zero_point to ±Inf. The golden test asserts
  it (`src/mlx/turboquant-ops.ts` header).

**Values — FWHT + Lloyd-Max, per-32-group RMS scale:**
- `y = FWHT(x · signs)`, `signs ∈ {±1}^d` from
  `mx.random.randint(0,2,(d,), key=mx.random.key(42))`; FWHT normalizes by 1/√d.
- `scale = sqrt(mean(y²))` per 32-group (RMS, not min/max); `y_n = y/(scale+1e-8)`.
- `idx = searchsorted(BOUNDARIES, y_n)`. 3-bit table: centroids
  ±{0.24509, 0.75601, 1.34391, 2.15195}, boundaries ±{0.50055, 1.04996,
  1.74793}, 0. Other widths (2/4/5/8): the reference's iterative Lloyd-Max on
  a unit normal (key(0), 500 iterations), generated ONCE and hardcoded —
  parity by construction, no runtime iteration.
- Pack: flat little-endian bitstream, element i at bits [i·b, i·b+b); values
  may straddle bytes (3-bit: 8 values → 3 bytes).
- Dequant: `x̂ = InvFWHT(centroids[idx] · scale · signs⁻¹)`.

**Bytes per token per head (k8v3, d=128):** 128 (K int8) + 8+8 (K
scale/zero) + 48 (V packed) + 8 (V scale) = 200 vs 512 bf16 → 2.56×. This
reproduces optiq's `compression_ratio`. Sign vectors are hardcoded constants
per head_dim (what vllm-metal does in its .metal source) — deterministic
across machines and spill/restore.

## Architecture in mlx-bun (verified 2026-08-23)

Dequantize-on-fetch: `TurboQuantKVCache implements Cache`
(`src/model/gemma4-base.ts`; does NOT subclass KVCache, which keeps it
auto-excluded from batching). `updateAndFetch(k,v)` quantizes only the newly
appended tokens into packed storage and returns the dequantized bf16 active
window, so stock `ops.sdpa` runs unmodified — the pattern optiq's
`runtime/kv/rotating.py` uses. A novel cache class fails every generated-file
`#matches()` guard and falls back to the monolith by design. Quantization
groups run along head_dim only — token-axis slicing stays byte-safe
(standing invariant).

Code map:
- `src/mlx/turboquant-ops.ts` — fwht (binds `mlx_hadamard_transform`),
  encode/decode keys + values, pack/unpack, `unrotateValues`.
- `src/mlx/turboquant-tables.ts` — GENERATED by `bun scripts/regen.ts
  turboquant` (job file `scripts/regen/turboquant.ts`, which shells out to
  `lab/repro/vllm-metal-turboquant/gen_goldens.py` under the oracle venv):
  sign vectors per head_dim + Lloyd-Max tables per bit-width; also writes
  `goldens/turboquant.json` (machine-independent, flat goldens set).
- `src/config.ts` — `TurboQuantScheme {kBits, vBits}`,
  `parseTurboQuantScheme` (`turbo` = k8v3; `TURBOQUANT_VALID_KBITS`
  {2,4,5,8}, `TURBOQUANT_VALID_VBITS` {2,3,4,5,8}).
- `src/cli.ts` — `--kv-quant turbo[:k<bits>v<bits>]` on serve/generate/bench.
- `src/kv-scheme.ts` — `KvScheme` kind `"turbo"`; `cacheKey` =
  `turbo-k<k>v<v>` (the SSD-cache / prompt-cache anti-collision key);
  `bytesAt` bills bf16 (conservative — no projector for the packed layout
  yet); `fitOptions` is empty for turbo for the same reason.
- `src/generate.ts` `maybeQuantizeKv()` → `maybeTurboQuantizeKv()` — the
  single conversion chokepoint (serve serial lane + generate + eval all flow
  through it); `TurboQuantKVCache.fromKVCache`; `RotatingKVCache` layers stay
  bf16 with a one-time warning; keeps the `quantizedKvStart` semantics.
- `src/backends/mlx/kv-codec.ts` and `src/model/turboquant-codec.ts` separate
  encoding and existing fused kernel selection from storage membership.
- `KvTensorRows` owns arbitrary encoded planes; `BatchedTurboQuantKVCache`
  binds the five TQ planes to shared positions and a rotated-value attention
  port. Gemma owns pre-write row positions across cache appends and releases
  shared positions with the shared attention state.
- `src/backends/mlx/cache-layout.ts` supplies ordinary and target-transaction
  layouts. The gateway binds start-zero TQ and grouped Qwen MTP capabilities;
  the scheduler only chooses work. Server head-dimension validation remains.
  `turboQuant` and `kvQuant` are mutually exclusive.
- `src/kv-store.ts` — `CacheKind "turboquant"`; header carries kBits/vBits
  + head_dim; snapshot/restore/clone branches.
- `src/model/fingerprint.ts` — NOT touched, by symmetry: uniform
  `--kv-quant 4|8` is a CLI-only runtime lever that never feeds
  `configFingerprint()` either; the anti-collision mechanism for this class
  of lever is the scheme key above, not the fingerprint.
- Tests: `tests/turboquant-ops.test.ts` (golden bit-exactness vs the
  vendored reference + model-free math props), `tests/turboquant-cache.test.ts`
  (cache invariants, growth/trim, persistence roundtrip; synthetic arrays).
- Curve script: `scripts/turboquant/eval-turboquant-curve.ts` — bf16
  baseline + {k8v8,k8v4,k8v3,k8v2,k4v3,k4v2} sequentially, reusing
  `src/eval/kl.ts`'s `evaluateKlKvArm` (teacher-forced serving-decode KL,
  real `fromKVCache` conversion) and `src/eval/perplexity.ts`'s `evalPpl`.
- Reference docs: server-config.md, cli.md, docs/reference/server-config.md carry the
  flag surface.

## Deferred inverse FWHT (landed 2026-07-06, post-v1)

Attention is linear in V, so `InvFWHT(Σᵢ wᵢ·v̂ᵢ) = Σᵢ wᵢ·InvFWHT(v̂ᵢ)`:
`updateAndFetchDeferredV` returns the V window still in the rotated domain
and the attention site un-rotates the OUTPUT once per query row
(`tq.unrotateValues`) — O(q·d log d) per step instead of O(T·d log d).
Opt-in per attention site via `SharedKv.vRotated` (monolith `gemma4.ts` —
KV-shared consumer layers inherit the flag through `sharedIn` — and
`minicpm5.ts`); every other consumer keeps calling `updateAndFetch` (eager)
and stays correct. Not bit-identical to eager (bf16 rounding in the rotated
domain before the transform); measured k8v3 KL 0.0338 vs eager 0.0325 —
same quality. Paired fetch-path A/B on a LOADED M1 Max: never slower,
~10-20% off fetch cost at 4k ctx, noise-level at 8k (dequant gather
dominates both) — no speed claim until a quiet-machine
`scripts/bench-serve.ts all` run; the win is removing the O(T) transform,
which matters more once the gather itself is fused. (The class-level doc
comment on `TurboQuantKVCache` still calls deferred-InvFWHT a non-goal; the
method exists two screens below it — the comment is stale, the code is
authoritative.)

## Packed-value decode fusion investigation

The Mac-quant video follow-up in decode-speed-program §7.11 exposed an
unpack/gather/scale chain that also exists in our shipped KV decoder. A
research-only Metal prototype reads the byte-packed values and fp16 group
scales directly from the active cache window, gathers the existing f32
Lloyd-Max centroids and multiplies in f32. The eager path keeps the native
inverse Hadamard, sign multiplication and bf16 cast. The deferred path casts
the same f32 values to bf16. Keys and the quantized representation stay the
same. The four-dimensional launch reads cache strides without copying its
capacity slice; context length, capacity and head count remain runtime inputs.
There is no specialization for each new token position.

On the M4 Pro 24 GB, the initial 140 cases preserve 280 flat/grid comparisons
across value bits 2/3/4/5/8, head dimensions 64/128/256/512, multiple batch/head
counts, strided cache windows and both rotation paths. Three six-process
repeats preserve another 1,440 candidate comparisons and every cross-process
fixture/output hash. These add fp16 scales and the production 32-value group
to the initial bf16/f32 and 64-value-group operation coverage. Every process
returns to its primed native sign/centroid-cache allocation. The all-dimension
screen retains 5,104 bytes; each D256 repeat retains 2,288 bytes. The generated
kernel keys stay constant across the three tested context lengths.

The last repeat uses synthetic [1,8,N,256] caches with fp16 scales and groups
of 32. For eager V3 decode, paired median operation time falls 46.72% at N128,
77.43% at N2048 and 81.37% at N8192. V5 falls 54.66%, 82.12% and 84.93%. Every
V3/V5 pair improves. At N8192, peak temporary allocation falls about 250 MiB
for V3 and 282 MiB for V5. The repeat checks outputs before timing and after
the last rep of each arm; the earlier screen read the output on the CPU
between every rep, which changed the timing regime. Raw screens are retained.
These are operation diagnostics on a loaded machine, not RSS or full-model
speed claims. This Qwen artifact has four KV heads, so the next gate runs the
actual model. The experimental full-model branch keeps V8 on its native path
while the larger low-bit gain is assessed.

Evidence in reports/qwen38-rd: tq-value-grid.json,
tq-value-repeat{,-review}.json, tq-value-f16-repeat{,-review}.json and
tq-value-production-repeat{,-review}.json. Full-model logits, live cache and
recurrent state, seeded generation, actual HTTP timing, fallback/lifetime and
quiet acceptance are required before production integration or a default.

The first Qwen k8v3 full-model pair now preserves all 20 forward/state and
continuation comparisons plus four greedy/seeded-sampled generations at
128/2048 input tokens. Both arms make 4,880 cache-value calls. The candidate
uses one D256/V3/group32/fp16-scale specialization across every context length;
final active allocation is identical at 1,016,898 bytes. Timing is mixed:
single-token forwards improve, while three of four complete generations lose.
During the candidate process, one-minute load rises from 2.80 to 7.57 and
system swap grows about 323 MiB, so this pair cannot isolate the cause of the
slowdown. It is retained in full, and no production/default decision follows.
Evidence: tq-value-full{,-review}.json. Actual Bun HTTP comparisons follow.

An additional 270 finite-scale-boundary cases preserve 540 comparisons,
including zero, signed zero, fp16 subnormals and large scales at every head
dimension, with the actual four-KV-head shape included. All allocations return
to the primed 5,104-byte global cache. Evidence: tq-value-edge.json. The first
actual HTTP pair preserves all five responses, call maps and final allocation.
Measured complete time falls 0.77% for the 58-token code prompt and 1.38% for
the 1,806-token inventory prompt. The latter improves decode throughput 7.57%
but worsens TTFT 3.80%; it is a screening pair, not acceptance. Six alternating
fresh-server pairs now preserve all 30 paired responses, call maps, source
hashes and process exits. Each server ends with the same 11,936,577,410 active
bytes, which includes the retained model. Paired median complete time falls
0.82% on the short prompt, all six pairs, and 2.87% on the long prompt, four of
six pairs. Long-prompt decode throughput rises 7.33%, five of six pairs; TTFT
worsens 0.75% in the paired median and is split three wins/three losses. Per-
request sampled RSS differences are small and inconsistent, so this is not a
physical-memory claim. Retain both losing long-prompt pairs. Evidence:
tq-value-http-repeat{,-review}.json. Test decode-only eligibility to separate
prefill scheduling from decode, then broader context/quant/cache and quiet
acceptance. No production/default change yet.

A separate decode-only V arm also preserves 20 forward/state cases and four
generations. Exact call maps show 4,480 fused M1 reads and 400 native
multi-token reads; active allocation remains 1,016,898 bytes. Evidence:
tq-value-decode-full{,-review}.json. A first timing pair improves complete
generation, but it is not the policy decision.

The next prototype decodes packed K and V in one launch, retaining K's f32
addition before multiplication and V's f32 centroid multiplication. It passes
720 initial pair comparisons. An expanded screen checks all 20 served K/V bit
combinations with distinct key/value scales, including finite boundary values,
and preserves all 2,400 comparisons. Equal scale values in the initial
synthetic fixtures could not detect a swapped scale input; the expanded
fixtures close that gap. Actual-model scales were already independent.

Six fresh-process operation repeats preserve another 432 comparisons. With
actual four-head D256 caches, fp16 scales and group32, joint k8v3 decoding is
9.60%, 22.80% and 43.19% faster than V-only fusion at N128/2048/8192 in the
paired median, all six pairs at each context. These include the native inverse
rotation. Peak temporary allocation falls another 0.53/8.5/34 MiB. The full
Qwen pair preserves 20 forward/state comparisons and four generations, all
4,880 cache calls, one generated specialization and identical final active
allocation. Source and raw evidence: tq-kv-screen.json,
tq-kv-independent.json, tq-kv-repeat{,-review}.json and
tq-kv-full{,-review}.json.

The actual Bun HTTP follow-up completes all six arm orders across 18 fresh
servers. Its 90 requests preserve all 60 candidate/control response comparisons,
call and eligibility maps, process exits and source hashes. Every server retains
the same 11,936,577,410 active bytes. Each candidate uses one shader specialization
across both prompt lengths. These runs use the same R6 weights, k8v3 cache,
serial execution, greedy seed42 and no prompt reuse or speculative draft.

| Candidate versus original | 58-token prompt: complete time | 1,806-token prompt: complete time | Long-prompt decode throughput | Long-prompt TTFT |
|---|---|---|---|---|
| V fusion only on M1 appends | −0.81%, 6/6 wins | −3.42%, 5/6 wins | +7.53%, 5/6 wins | −0.14%, 5/6 wins |
| Joint K/V at all append shapes | −0.76%, 5/6 wins | −4.57%, 6/6 wins | +10.35%, 6/6 wins | −0.17%, 5/6 wins |

Values are medians of paired changes, not ratios of unpaired medians. Joint
decoding also improves long-prompt complete time over decode-only V by 1.20%,
all six pairs; its short-prompt median is 0.08% slower. The first joint short
request loses 3.70%, and the first decode-only long request loses 2.30%; both
remain in the report. TTFT is effectively flat. Observed RSS deltas remain
small and do not establish physical-memory savings. Evidence:
tq-kv-policy-http{,-review}.json. Extend the exact gates to 8,192 context tokens,
RTN4 and deferred-rotation consumers, then check integrated lifetime/fallback
behavior. These are M4 Pro diagnostics with existing system swap; quiet
acceptance and a production/default decision remain open.

The 8,192-token R6 gate also passes: six full forward/state/continuation cases
at M1/4/128 and two 64-token greedy/sampled generations are exact. Both arms
make 2,960 cache calls and finish at 1,016,898 active bytes; the candidate still
uses one shader key. In this single pair, complete generation time falls 9.11%
and 7.43%, and native peak allocation falls 126.97 MiB. The measured M1 forward
falls from 200.84 to 118.87 ms. These are screening timings, not repeated HTTP
acceptance or physical-memory savings. Evidence: tq-kv-long-full{,-review}.json.

A further prototype folds inverse Hadamard, normalization, signs and bf16 cast
into the joint decoder. It copies the exact radix-16 butterfly and indexing from
MLX 0.31.2's MIT-licensed Metal Hadamard implementation. All 480 shape/bit/dtype/
finite-boundary cases preserve both candidate comparisons. Six fresh processes
then preserve all 36 performance cells, but the literal one-row threadgroup
layout loses to joint decode plus native rotation: k8v3 paired median operation
time rises 12.76%/20.11%/24.67% at N128/2048/8192. Lower temporary allocation
alone does not justify this version. The follow-up tests independent rows in
one threadgroup, preserving each row's arithmetic and participation in barriers
at partial tails. Evidence: tq-kv-rotation-screen.json and
tq-kv-rotation-repeat{,-review}.json. No full-model run is justified for the
losing layout.

Grouping independent rows into one threadgroup preserves the same 960 boundary
comparisons, including partially occupied tail groups. Six fresh-process repeats
preserve all 36 timing cells. At N8192, this version improves over joint decode
plus native rotation by 22.28% for k8v3 and 23.20% for k4v3, all six pairs, while
halving the operation's peak temporary allocation from 64 to 32 MiB. It remains
slower at N128 and N2048; for k8v3 the paired medians are +4.08% and +20.43%.
Only a long-context candidate is justified for full-model/request testing.
Evidence: tq-kv-rotation-rows-screen.json and
tq-kv-rotation-rows-repeat{,-review}.json. The baseline layout does not advance.

Joint decoding also passes the RTN4 full-model counterpart: 18 forward/state/
continuation cases at context128/2048/8192 and four generations are exact, with
5,536 matching cache calls, one specialization and 1,000,514 final active bytes
per arm. Its first paired generation timings improve, but repeated RTN4 HTTP
acceptance remains. A nonfinite follow-up preserves 960 additional comparisons
across every served bit pair, all head dimensions and scale dtypes, including
NaNs, infinities and arbitrary f32 zero-point fractions. This covers the
reference codec's documented zero-scale/infinite-fp16-zero behavior.

The MiniCPM5-1B counterpart exercises deferred V rotation: all 20 forward/state
cases, four generations and 7,320 cache calls match. Both arms finish at 524,860
active bytes; the candidate uses one D128 specialization. These are correctness
and first-pair timing gates, not repeated cross-model serving claims. Evidence:
tq-kv-rtn4-full{,-review}.json, tq-kv-nonfinite.json and
tq-kv-minicpm-full{,-review}.json. Gemma D512 and integrated operation/fallback/
lifetime checks follow.

Gemma-4-e4b's D512 deferred consumer also passes: 20 forward/state cases, four
generations and 1,220 matching cache reads, one specialization and 1,057,864
final active bytes per arm. Evidence: tq-kv-gemma-e4b-full{,-review}.json.

The joint decoder is now integrated as an experimental opt-in. The environment
setting and supported inputs are documented in server-config.md. A shared
`src/mlx/turboquant-kv-decode.ts` owns only the packed Metal operation; the existing
codec owns inverse rotation and the cache captures operation selection once.
Request/execution interfaces, quantization and persistence remain unchanged.
The original codec remains the fallback and correctness reference. Five new
operation tests pass 1,102 assertions across served bit combinations, head
dimensions, independent group sizes, nonfinite values, strided storage, fallback
and shapeless-trace behavior, borrowing and exact post-disposal allocation.
All three typechecks pass. With fusion enabled, the existing 26 codec/cache
tests also pass, including growth, trim and mixed-cache persistence. Their
snapshot helpers now release temporary casts and owned state views instead of
letting test-only allocations obscure the lifecycle checks. The integrated
model/HTTP evidence follows; prototype timings above are not automatically
attributed to the production dispatch.

The integrated R6 gate now preserves all 20 forward/state/continuation cases,
four generations, 4,880 cache reads and 1,016,898 final active bytes per arm.
Passive observation confirms that every enabled read reaches the production
kernel, with one specialization. The full model-free tier passes 1,873 tests
with 10 skips; typechecks and pure hygiene also pass. Evidence:
tq-kv-integrated-full{,-review}.json and tq-kv-integrated-code-checks.json.
The integrated RTN4 counterpart also preserves all 20 forward/state cases,
four generations, 4,880 reads and 1,000,514 final active bytes. Its first-pair
timings are mixed: three complete-generation cells regress 0.44–1.88%, while
the 2,048-token sampled cell improves 4.33%. Exactness alone does not establish
a speed gain. Evidence: tq-kv-integrated-rtn4-full{,-review}.json.

Six integrated R6 HTTP pairs preserve all 30 response comparisons, call maps,
one candidate specialization and equal post-exit active allocation. Paired
medians for the 58-token prompt are −0.74% complete time and +0.75% decode,
both six wins. At 1,806 prompt tokens they are −3.61% complete time, four wins,
and +10.33% decode, five wins. Long-prompt TTFT is +1.81%, three wins. Both
complete-time losses, +0.55% and +10.95%, remain in the result. This repeat is
noisier than the prototype, with no established TTFT improvement.

The same run stops after its first RTN4 pair on a 10,944-byte difference in
post-exit active allocation, with less retained in the candidate. All five
responses and the cache call maps match. The original run remains marked
incomplete; the later allocation investigation and revised assessment appear
below. Every child exits
cleanly and all 547 recorded source hashes remain unchanged. Evidence:
tq-kv-integrated-http{,-review}.json. A separate instrumented allocation/GC
diagnostic follows; its timings cannot be compared with ordinary serving.

The HTTP extension keeps the existing RSS collector and adds the calibrated
native process reader. R6's whole-server sampled physical-footprint maximum
falls in every pair, with a median difference of 2.04 GiB; this includes
startup, warmups and both prompt shapes. Measured-request RSS is nearly flat.
These observations do not identify per-request physical peaks or prove
savings across models. Longer-context, pressure, repeated deferred-model
serving and quiet acceptance remain before any default decision.

A fresh six-pair RTN4 repeat completes all 60 requests with all 30 response
comparisons and cache call maps exact. Both prompt shapes improve complete
time and decode throughput in every pair. At 58 prompt tokens the paired
medians are −3.07% complete time and +3.35% decode; at 1,806 they are −5.95%
and +15.47%. TTFT medians are about −0.63% in both cells. These use k8v3 KV,
serial execution and 128 generated tokens, without a speculative draft.

The repeat still fails its exact process-exit allocation gate. The candidate
retains 15,135,029,250 bytes in all six servers; four controls match, while
the last two retain 18,624 and 6,976 fewer bytes. Together with the earlier
smaller candidate observation, this varies in both arms. An array-tracked
diagnostic preserves 1,851 live wrappers and identical allocation before and
after explicit GC, but does not reproduce the variation. It establishes no
GC fix or kernel leak. The lighter observation below resolves the acceptance
metric, while preserving these failed reports. Evidence:
tq-kv-integrated-rtn4-http{,-review}.json and tq-kv-memory{,-review}.json.

The lighter array observer reproduces a 2,560-byte capacity difference while
both servers retain exactly 1,851 wrappers with matching dtype/shape counts
and logical bytes, before and after GC. This exposes a flaw in the exact-byte
gate: MLX's Metal allocator counts `MTLBuffer.length`, and its cache can reuse
a larger buffer for a smaller request. A controlled native reproduction gives
identical 4,096-byte arrays with either 4,096 or 6,144 active bytes. Clearing
unused buffers preserves that difference; disposing the live array releases
it completely. See the pinned allocator.cpp and buffer_cache.h plus
allocator-capacity-repro.json. The server's individual backing capacities were
not enumerated, so reuse explains the metric's limitation without attributing
every byte. Ownership acceptance uses the matching live-array inventory and
the exact native/cache disposal gates; active capacity remains a reported
measurement. Original failed reports remain unchanged. The revised assessment
is tq-kv-integrated-rtn4-http-acceptance.json.

The integrated 8K R6 gate also passes all six forward/state/continuation cases
and both 64-token greedy/sampled generations, with 2,960 matching cache reads,
one specialization and equal final allocation. In the first three-arm block,
joint decoding improves complete generation by 8.63%/7.59% versus the original.
Adding row-grouped inverse rotation only at N≥8192 preserves all results and
improves a further 1.25%/0.90% over integrated joint decoding. Its 2,256 rotation
calls exactly match eligibility, with 704 ordinary joint calls. The operation's
lower temporary allocation does not reduce the whole generation's peak further.
These are screening timings; the repeated long-context HTTP result follows. Evidence:
tq-kv-rotation-long{,-review}.json.

The six-block long-context HTTP repeat completes all 18 fresh servers and 54
requests in all six arm orders. At 8,846 prompt tokens and 128 generated tokens,
joint decoding versus the original codec improves paired-median decode by
83.87% and complete time by 12.77%. Adding row-grouped inverse rotation improves
a further 5.39% decode and 1.05% complete time over the integrated joint decoder.
Every paired complete-time and decode comparison improves. The incremental
TTFT median is −0.24%, with four of six wins; sampled request RSS is slightly
higher, so this establishes no RSS saving. All response text, usage, finish
reasons, call/eligibility maps and retained capacity match; all children exit
cleanly and all 547 recorded source hashes remain fixed. These are R6/k8v3,
serial, greedy seed42 diagnostics on the M4 Pro, without a draft. They do not
apply to bf16-cache rows. Evidence: tq-kv-rotation-long-http{,-review}.json.

That result justifies integrating the inverse operation into the same opt-in.
The numeric module `src/mlx/turboquant-kv-inverse.ts` owns a single D256 shader,
with 16 rows per threadgroup, unrolled radix16 butterflies and exact 1/16
normalization. The codec selects it only for the measured eager k8v3, B1/H4,
fp16/group32 regime at N≥8192; other calls retain joint decoding or the original
codec. Packed arrays and codec-table strides are explicit. N changes the grid,
never the shader specialization, and padded rows participate in every barrier.
The updated operation suite passes nine tests and 1,226 assertions, including
threshold/partial-row, nonfinite, strided-table, fallback and ownership checks.
Actual integrated model and serving acceptance against the saved prior joint
codec remain separate from the prototype's timing evidence. The R6 native
integration gate passes twelve forward/state/continuation cases and four
64-token greedy/sampled generations at contexts 2048/8192. Logits, tokens,
logprobs, complete cache states, prefix snapshots and usage are identical.
The candidate's 2,256 inverse calls match eligibility exactly, with 3,088 joint
calls; both arms release to the same retained allocation. Source hashes remain
fixed and both children exit cleanly. A brief concurrent CPU build prevents
accepting this gate's timing. Evidence:
tq-kv-inverse-integrated-r6-full{,-review}.json.

The MLX 0.32.2 controls now pass the same integrated model gate on both R6 and
RTN4. Every full logit/state/continuation case and greedy/sampled generation is
exact, with matching call maps, equal final active allocation and clean exits.
The version-specific records are mlx-upgrade-0.32.2/{r6,rtn4}-kv-inverse-full.json.
The integrated serving repeat now completes six usable timing pairs per quant
on the M4 Pro 24 GB, with the same 8,846-token prompt, k8v3, greedy seed42 and
128 generated tokens. Inverse rotation improves the paired-median HTTP decode
rate by 4.69% on R6 and 5.98% on RTN4; every decode pair improves. Complete
request time improves 0.79% on R6, with all six pairs improving. RTN4's complete
time is inconclusive: its median improves 0.38%, but only three pairs improve
and prefill variation exceeds the incremental saving. Neither result establishes
a general RSS reduction. All 78 responses across the original and replacement
runs match text, usage and finish reason. Call/eligibility maps match, all 26
servers exit cleanly and source/library hashes stay fixed. One original R6
timing pair was excluded after an MLX unit test overlapped its warmup; the
predeclared replacement supplies that pair. These are loaded-machine
diagnostics, not canonical acceptance. Evidence:
mlx-upgrade-0.32.2/inverse-kv-http{,-replacement,-review,-isolation}.json.
Combined pressure and quiet acceptance remain.

The consolidated 0.32.2 runtime also passes six paired actual HTTP blocks per
MiniCPM5-1B and Gemma4-e4b with the joint decoder off/on. Their deferred value
paths use D128 and D512 respectively. All 120 responses, including warmups,
match in text, usage and finish reason; every call map matches and all 24
servers exit cleanly. Source and native-library hashes remain fixed. Both
models improve complete request time in every measured pair. MiniCPM improves
substantially at both tested prompt lengths; Gemma's benefit is larger on the
longer prompt. Sampled RSS establishes no reduction. The server-exit observer
still sees resident model arrays, so its active capacity is not a disposal-to-
zero test. Native operation and full-model ownership gates remain separate.
These are M4 Pro 24 GB diagnostics with k8v3, greedy seed 42 and 128 generated
tokens. TurboQuant KV requires serial placement in the existing execution
planner. Evidence: mlx-upgrade-0.32.2/deferred-kv-http{,-review}.json. This closes
the deferred-model serving comparison; broader pressure and quiet gates remain.

Direct packed-key attention is closed as an additional speed candidate. A
research port of MLX 0.31.2's two-pass vector attention replaces each K load
with the existing signed-k8 zero/scale arithmetic and bf16 rounding. It keeps
the native block selection, score reduction, online softmax, bf16 partial
output and final reduction order. The dense source port and packed-key variant
both match all 72 operation cases at D256, one query, GQA 6 and N1024 through
16384, including group32/64, fp16/bf16/f32 metadata and strided arrays. Every
owned allocation is released. Scope is M4 Pro, no mask or sinks, with eager
V already decoded; this does not cover arbitrary SDPA inputs.

Six fresh-process repeats then measure the complete eager k8v3 decode plus
attention using actual encoder output. All 72 cells preserve their inputs
and both candidate outputs, with 3,888 timed operations and matching source
hashes. Fixture allocations return to the same warmed codec-table baseline
after every cell. Direct key loads with the earlier fused V decoder improve
over the original operations, but lose against the integrated joint K/V
decoder plus native attention. Paired median regressions are about 14% at
N1024/1025, 19% at N2048, 6% at N8192/8193 and 8% at N16384, for contiguous
and strided caches. All six pairs lose except two noisy N2048 contiguous
cells. Peak temporary allocation falls by the removed bf16 K window, about
16 MiB at N8192 and 32 MiB at N16384, without a measured whole-model memory
benefit. The initial key-only improvement therefore does not justify a new
model/cache dispatch or production kernel. Evidence: tq-key-sdpa-screen.json
and tq-key-sdpa-complete-repeat{,-review}.json. The pinned source is MLX's
MIT-licensed sdpa_vector.h and scaled_dot_product_attention.cpp under
upstream/mlx-0.31.2; the closed research helpers are removed.

## Gates — all passed 2026-07-06 (M1 Max 32 GB)

1. **Quantizer parity (bit-exact, the hard gate):** encode indices, scales,
   zeros, packed bytes, and dequant outputs match the vendored reference on
   golden vectors (head_dim 64/128; configs k8v3/k4v3/k4v2/k8v4/k2v5/k5v8 —
   every kBits/vBits value the CLI accepts).
2. **Math sanity (model-free):** FWHT involution/orthogonality; 3-bit
   roundtrip MSE on unit-normal data in the paper's D_mse≈0.03 band.
3. **Quality-vs-bpw curve (Phase 13 exit criterion)** — MiniCPM5-1B,
   teacher-forced serving-decode KL vs bf16, 8 prompts × 128 tokens, 32
   decode steps; affine baselines via the same harness:

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

   Shape reproduces the paper's law: value bits dominate, ~4^-b decay, cliff
   at v2. Turbo adds operating points between affine kv8/kv4; the k8v3
   default (2.56× KV compression) beats uniform kv4's KL with room to spare.
   Live smokes: cpm5 + e4b coherent under turbo:k8v3 (e4b emits the
   rotating-layers-stay-bf16 warning). The paper's LongBench numbers were NOT
   rerun — the reproduction is shape-level plus the codec-level D_mse anchor.
4. Whole-repo `tsc --noEmit` = 0; fast suite green; turbo requests route
   serial with a clear reason.

The Phase 18 composition is integrated in the unreleased working tree;
`~/.cache/mlx-bun/turboquant-composition-validation` remains a frozen comparison.
It extracts the existing
encode/decode operations behind a KV codec interface and applies that codec to
one owner of five tensor fields with shared row positions. Merge, retirement,
rollback and extraction operate on encoded bytes. A rotated-value attention
port lets Gemma and MiniCPM consumers retain the existing deferred inverse
rotation with either storage layout.

On M1 Max and M4 Pro, the focused codec/kernel/row checks pass 29 tests and
2,828 assertions. A native Qwen target test passes 2,824 assertions on each
machine, comparing retained state and subsequent full logits at the same B=2
shape across unequal accepted prefixes. Existing fused kernel selection is
preserved. The subsequent MLX cache-layout binding now serves ordinary and
Qwen MTP groups through those same encoded rows. Scheduling retains its
method lifecycle; sampling and fused codec selection are unchanged. The
method key and paired-prefix namespace include the TurboQuant scheme.
Temporary extracted-state views use the existing lease interface.

Fused K8/V3 serving passes on both Macs: MTP2 and MTP4 each prove true B4,
seeded logprobs, mixed grammar, joins and retirement; ordinary tests prove
B1/B2/B3 and immutable RAM donor reuse. Paired RAM and SSD restart tests
preserve target/draft/hidden state and continuations. Full suites pass
2,078 tests on M1 and 2,082 on M4, with typechecks clear. MTP3 also passes
the M1 native/HTTP gate. On M1, all 21 saved-boundary requests match across
8 GiB synchronous, 1 GiB synchronous and 1 GiB asynchronous RAM-cache arms,
including full usage and acceptance. Each arm durably flushes all seven
snapshots with no missing, pending, dropped or failed writes. The constrained
arms cause six eviction spills; the async observer confirms 3,264 submissions.
These sequential shared-server pressure checks cause substantial swapping;
B4 correctness is a separate native gate, and no speed or memory-reduction
claim follows. M4 pressure and strict paired performance acceptance remain open.
The shared integration is now adopted in the unreleased working tree; the
released v0.3.0 binary retains its earlier placement limits.
Evidence: `reports/qwen38-closeout/composition-baseline/turboquant-composition-manifest.json`.
Integration evidence: `reports/qwen38-closeout/composition-baseline/turboquant-serving/`.
Broader family checks pass MiniCPM seeded/logprob serving but reproduce a
Gemma e4b/12B failure: attention borrows the row-offset array across a cache
append that releases it. The adopted ownership fix passes seeded/logprob and
prefix checks on both Gemma families, MiniCPM/Qwen prefix controls, and the
complete suites on both Macs. M4 acceptance also passes fused and unfused
Gemma seeded sampling, affine KV4 controls and Qwen MTP3 B4 serving.
MiniCPM prefix checks allow the existing policy to supersede trimmable donors
while proving byte identity and continuation through retirement.

## KV-leg limits and non-goals (recorded so they don't creep)

- Full-attention layers only; rotating/sliding-window layers stay bf16 (warn
  once, never throw). Head dims outside {64,128,256,512} refused at server
  start.
- Shared ordinary execution supports row-local delayed TurboQuant; Qwen MTP
  requires start zero. Delayed affine conversion and paged-KV combinations
  remain unsupported.
- No fused quantized-SDPA Metal kernel (remaining fetch cost is
  unpack+gather); no QJL residual stage; no entropy coding (the paper
  declined it too).
- Strict legacy serial speculation and draft providers without grouped TQ
  support retain their existing exclusions. A shared server with one active
  row is the TQ/MTP B1 path.
- No speed claims: v1 dequant-on-fetch is expected slower per step at long
  context; this ships as a memory/context feature like uniform KV. Admission
  still bills turbo as bf16 (server-config.md says so).

---

# Part B — Weights leg (rotation-folded quantization)

## What it is

Fold an orthogonal rotation R offline into producer/consumer weight pairs so
every weight matrix is quantized in a rotated basis where outlier channels
are smeared into near-Gaussian marginals — then quantize with mlx's EXISTING
formats (affine / mxfp4 / nvfp4). Zero runtime cost, zero new kernels,
output loadable by stock mlx-lm. The QuaRot/SpinQuant family; composes with
(does not replace) per-layer allocation (OptiQ-style) and calibration.

Target: the best-possible Qwen3.8-27B (+ MTP companion) on our hardware,
beating OptiQ-4bit / plain 4bit at equal effective bpw (gate: ppl + frozen
6-task eval, eval DB rows, per-bpw-band comparisons).

Why weights differ from KV (the 2026-07-06 framing that opened the leg):
- Weights win on one axis: the rotation FOLDS into adjacent matrices offline
  (R into one layer, Rᵀ into the next) — no online transform at all.
- Weights lose on the other: they are static, so calibration-aware methods
  (GPTQ/AWQ/imatrix, optiq sensitivity maps) are admissible and set a higher
  baseline than any calibration-free scheme — the win to chase is rotation
  COMPOSED WITH calibration/allocation, not instead of it.
- A Lloyd-Max weight FORMAT needs custom quantized-matmul kernels — the 26B
  gather-qmv shelving (dispatch fixed-cost ate the prize) is the precedent.
  Folding into mlx's existing affine format needs none.
- Activation quant (W4A4) is mispriced on this hardware (no int4 tensor
  cores, decode is weight-bandwidth-bound; docs/design/orpo-training.md).

## Oracle chain

Folding mechanics come from the reference repos (read 2026-08-17, full-file
agent reads):

- **QuaRot** (arXiv:2404.00456, github spcl/QuaRot):
  `fake_quant/rotation_utils.py` (fuse_ln_linear, fuse_layer_norms,
  rotate_model), `fake_quant/hadamard_utils.py` (get_hadK, matmul_hadU,
  random_hadamard_matrix), `fake_quant/model_utils.py`.
- **SpinQuant** (arXiv:2405.16406, github facebookresearch/SpinQuant):
  `utils/fuse_norm_utils.py` (a copy of QuaRot's γ-fold),
  `eval_utils/rotation_utils.py` (R1/R2 folds), `optimize_rotation.py`
  (Cayley-SGD learned R — deferred to W5-learned).
- **GPTQ**: `mlx_lm/quant/gptq.py` in the pinned venv (forked minimally in
  `scripts/turboquant/tq-gptq.py`; see the two upstream defects below).
- **Sensitivity**: `mlx_lm.quant.dynamic_quant` (gradient KL) + OptiQ's
  published `optiq/sensitivity.json` for this exact 27B (`sensitivities[b]`
  = measured KL GAIN at b bits — the first read had the sign flipped).

Weight layout: torch and MLX `nn.Linear` are both `[out, in]`, `y = x @ W.T`
— their fold table transfers verbatim.

## The recipe (weight-only, fully offline)

Order matters: γ-fold FIRST (R1 commutes only with gain-free RMSNorm), then
R1, then R2, then quantize.

**0. Untie embeddings** if `tie_word_embeddings` (clone into a separate
lm_head, set the flag false). Required: step 1 transforms lm_head but not
embed_tokens (SpinQuant `ptq.py` does exactly this).

**1. γ-fold (norm fusion)** — for each RMSNorm feeding linears,
`W' = W · diag(γ)` on the INPUT dim, then set that norm's γ to ones (keep the
module + its eps — do NOT copy QuaRot's replacement RMSN, which hardcodes
eps=1e-5; our subjects use 1e-6):
- input_layernorm → q/k/v_proj
- post_attention_layernorm → gate/up_proj
- final norm → lm_head

**2. R1 residual fold** — one hidden-size orthogonal R1:

| matrix | transform | reason |
|---|---|---|
| embed_tokens | `W @ R1` | writes residual (rows are embeddings) |
| q/k/v_proj | `W @ R1` | reads residual (input dim) |
| o_proj (+bias) | `R1ᵀ @ W` | writes residual (output dim) |
| gate/up_proj | `W @ R1` | reads residual |
| down_proj (+bias) | `R1ᵀ @ W` | writes residual |
| lm_head | `W @ R1` | reads residual |

Q/K outputs untouched → RoPE unaffected. Input-side folds never touch biases
(bias lives on the output).

**3. R2 per-head v/o fold — SpinQuant's version, NOT QuaRot's.** Per layer,
one head_dim-sized orthogonal R2 applied block-diagonally: v_proj output
blocks get R2ᵀ, o_proj input blocks get R2; softmax weights are R2-invariant
so it cancels exactly, incl. under GQA (same R2 for all heads; repeat_kv
replicates whole heads). QuaRot's variant folds a FULL Hadamard into o_proj
and needs an ONLINE cross-head Hadamard (`online_partial_had`) to cancel —
folding its v-side alone breaks the network. Skip QuaRot's pairing entirely.

**4. Quantize** the folded weights with the stock convert path (affine g64 /
mxfp4 / nvfp4 arms; only affine has been measured — see W3).

### Deviations from the references (decided, with reasons)

These are the strings persisted per artifact in `optiq_metadata.json`
`weight_transforms[].deviations` (`src/quantize/rotate.ts`).

- **No embedding mean-centering.** Their `fuse_layer_norms` mean-centers
  embedding rows (SliceGPT LayerNorm→RMSNorm trick). For RMSNorm models this
  is NOT an exact invariance — they do it anyway; we don't, because W0's exit
  criterion is logit parity of the folded bf16 model.
- **Delete the hidden R4 half-fold.** BOTH repos' `rotate_mlp_output`
  unconditionally applies a full Hadamard to down_proj's input dim right
  after the R1ᵀ fold — the offline HALF of R4, which requires the runtime
  `online_full_had` on down_proj's activation (QuaRot rotation_utils.py:173 /
  SpinQuant eval_utils/rotation_utils.py 98-100). Weight-only must skip both
  halves. The `R1ᵀ @ W_down` part stays.
- **No R3.** Post-RoPE Q/K rotation exists only for KV-cache quant (their
  code registers it only when k_bits < 16). Our KV story is Part A — online
  rotation remains KV-only.
- **γ kept in the module as ones (eps preserved).**
- **Fold precision: fp32, not fp64.** References fold in fp64 (fp16-era
  caution). Our weights are bf16 (8-bit mantissa); fp32 accumulation at
  n≲6k leaves ample headroom. Escape hatch if a parity gate fails: fold
  goldens in the oracle venv (mlx CPU float64).

### R generation

- Random-Hadamard R1 = `diag(±1 signs) · H_n / √n` (QuIP#-style). Signs are
  a seed-pinned splitmix32 stream (`signVector(seed, n, lane)`; R1 = lane 0,
  layer i's R2 = lane i+1) so the same (seed, n, lane) yields the same signs
  on every machine. R is never needed at runtime; provenance (transform id,
  family, seed, deviations) is written to `optiq_metadata.json`.
- Supported n: the Llama adapter asserts power-of-two hidden and head dims;
  the Qwen adapter accepts `n = m·2^k, m ∈ {1,12,20,28}` — what mlx's
  `hadamard_transform` takes natively (verified live at 5120 = 20·256). The
  references' Kronecker table for other K values is NOT implemented; callers
  get a clear throw. (QR-of-Gaussian "random" mode from the references is
  likewise not implemented.)
- R2 default: plain signed Hadamard of head_dim (must be pow-2).
- Learned R (SpinQuant Cayley-SGD R1 + per-layer R2) stays deferred until a
  random-R recipe wins on task evals; it folds identically afterward.

## Implementation seam (verified 2026-08-23)

`src/quantize/weight-transform.ts` separates pure tensor-name planning from
lazy tensor application:
- `WeightTransform { id, plan(names, config), createContext(weights, plan) }`;
  `plan()` is name/config analysis only (no arrays, no device work);
  `WeightTransformContext.apply(outputName, source)` returns a lazy owned
  array and never disposes `source`.
- `WeightTransformPlan.sourceByOutput` makes untie/clone explicit (a
  synthesized `lm_head.weight` maps to `model.embed_tokens.weight`).
- Adapters: `llamaWeightTransform` (`rotation.llama`), `qwen35WeightTransform`
  (`rotation.qwen3_5`), `qwenMtpWeightTransform` (`rotation.qwen3_5_mtp`), and
  `automaticRotationWeightTransform` (`rotation.auto`) which selects by
  schema: MTP if `fc.weight` + `pre_fc_norm_hidden.weight` are present, else
  by `model_type` ∈ {qwen3_5, llama}, else throws.
- Fold math lives in `src/quantize/rotate.ts` (`foldLlamaWeights`,
  `planQwen35Fold`, `planQwenMtpFold`, `QwenFoldContext`; f32 chains → bf16;
  every returned array is a lazy graph over the source mmap so the writer
  materializes one tensor at a time).
- `src/quantize/quantizer.ts` `quantizeModelDir` applies the plan in its
  existing module walk; refuses a transform when the source is already
  quantized ("requires full-precision source weights"); writes
  `weight_transforms` into both the uniform and the mixed-precision
  `optiq_metadata.json`. Mixed-precision calibration receives a
  `ProbeSource`; the default builds an 8-bit probe through the lower-level
  writer instead of recursively re-entering the top-level quantizer.
- CLI: `mlx-bun convert --rotate-weights [--rotation-seed N]` (default seed
  42; cli.md documents it). An MTP companion must be folded with the same
  seed as its trunk.
- Tests: `tests/weight-transform-plan.test.ts`,
  `tests/weight-transform-numerics.test.ts`.

Src-vs-doc note: the production Llama adapter currently REQUIRES tied
embeddings (`planLlamaWeightTransform` throws if `lm_head.weight` exists) —
the "untie if tied" recipe step is exercised only in that direction; an
untied Llama source is not yet accepted. The Qwen adapter handles both.

## W1 — Qwen3.8 (qwen3_5) corridor map (2026-08-18, from `src/model/qwen3_5.ts` + `src/spec/qwen-mtp-source.ts` + `src/vision/qwen3vl-tower.ts` + tensor dumps)

**R2 is architecturally OFF for this family:** full attention computes
`o_proj(attention_output · σ(gate))` — q_proj emits 2×head_dim per head and
the gate multiplies the attention output ELEMENTWISE in head space. An
elementwise gate does not commute with a per-head rotation, so only γ+R1
apply. hidden 5120 = 20·256 — mlx's hadamard_transform takes it natively.

Trunk corridors (prefix `language_model.`):
- readers (@R1 input dim, γ folded in): self_attn.q/k/v_proj,
  linear_attn.in_proj_{qkv,z,b,a}, mlp.gate/up_proj, lm_head (γ = model.norm)
- writers (R1ᵀ output dim): self_attn.o_proj, linear_attn.out_proj,
  mlp.down_proj
- vision: `vision_tower.merger.linear_fc2` weight+bias is the ONLY
  vision→residual seam (deepstack is empty for qwen3_5 and not ported) —
  output-dim fold; everything else in the tower passes through bf16
- untouched internal bases: q_norm/k_norm (head-space), linear_attn.{norm,
  A_log, conv1d, dt_bias} (post-projection), rotary
- 27B trunk is untied; the 0.8B proof subject is tied (untie step exercised)

MTP companion (separate artifact, same seed/R1 — shared residual basis):
- `fc [H,2H]`: input block 0 = embedding stream (γ = pre_fc_norm_embedding),
  block 1 = hidden stream (γ = pre_fc_norm_hidden) — per-block γ+@R1 — plus
  an output-dim R1ᵀ fold; both pre-fc norms → ones
- `layers.0`: standard full-attention corridor treatment
- **final `norm` γ is DROPPED (→ ones):** it feeds the SHARED trunk lm_head,
  which already carries the trunk's final γ. Draft logits see γ_trunk instead
  of γ_mtp — draft-quality-only (the verified target path is exact); revisit
  lever = ship a private folded head inside the companion. Persisted as the
  `mtp-final-gamma-dropped` deviation.

Small-scale proof (0.8B, dequantized from OptiQ-4bit since no bf16 is
published; fold-parity on dequant-vs-folded-dequant tests the fold exactly):
teacher-forced logits through STOCK mlx-lm (also the W2 cross-stack check) —
worst per-position KL 0.00353, argmax flips 2/42 positions BOTH at reference
margin 0.0 (exact ties). Scripts: `scripts/turboquant/dequant-model.ts`,
`scripts/turboquant/fold-qwen35.ts`, `scripts/turboquant/tq-fold-parity.py`.

Quantization packaging (corrected 2026-08-18: OptiQ does NOT fully strip
vision — its main weights omit it but `optiq/optiq_vision.safetensors`
carries it, and `optiq/mtp.safetensors` bundles MTP; their artifact also
publishes `optiq/sensitivity.json`. No kv_config.json is published.) Our
packaging: language modules quantize uniformly (embed + lm_head included),
`vision_tower.*` is predicate-excluded and stays bf16 both IN-MAIN (mlx-vlm
compatible — OptiQ's sidecar-only vision is not) and as the `optiq/` sidecar
(`scripts/turboquant/tq-make-vision-sidecar.ts`), so one self-contained
artifact serves text+vision across stacks; the folded MTP companion ships at
`<model>/mtp/` (engine: `--draft-kind mtp` with no `--draft-model` resolves
it).

## Subject models

- **W0/W3: mlx-community/Llama-3.2-1B-Instruct-bf16** (~2.5 GB; the
  reference repos' literal target family; TIED embeddings → exercises step
  0; hidden 2048 / head_dim 64, both pow-2). MiniCPM5-1B is the alternate
  subject (no published mlx bf16; geometry fold-friendly: untied, head_dim
  128, hidden 1536 = had12 ⊗ H128, eps 1e-6).
- **W4: mlx-community/Qwen3.8-27B-bf16** (11 shards, 54.7 GB) +
  `Qwen3.8-27B-MTP-bf16` companion (~850 MB). The companion shares the
  trunk's residual basis → must fold consistently (W1 decision). 27B bf16
  never fully loads on either laptop: folding bit-identity is proven at W0
  scale plus per-tensor checks; the 27B only ever RUNS folded-and-quantized.
  Streaming fold/quantize (`ShardedWriter` + `Weights.releaseShard`; fold
  peak 17.9 GB after the naive whole-list path OOM'd a 51 GB model).

## W0 fold proof (2026-08-17, Llama-3.2-1B, M1 Max 32 GB, busy box — correctness only)

Folded model loads + generates through the UNMODIFIED engine
(UniversalDenseModel path); teacher-forced two-model KL (16×256 tok) mean
0.00131 / median 0.00119 / p95 0.00287 — below the KV curve's
quality-neutral kv8 yardstick (0.00246); greedy 64-token trajectories 3/6
token-identical, 3 diverge only at near-ties (margins 0.0/0.125/0.125);
folded weights fully re-expressed (mean|Δ|≈mean|w|), per-tensor max|w| down
3–5× (q_proj 0.676→0.162, down_proj 0.578→0.110, gate 0.965→0.367), down_proj
excess kurtosis 1.19→0.22. Runner: `scripts/turboquant/w0-fold-llama.ts`
(`--skip-r1/--skip-r2` bisection arms + `turboquant_fold.json` sidecar).

## W3/W4 measured curve (2026-08-18, RTN affine g64, ppl via stock mlx-lm on the local UF-derived corpus, seq 512; M1 Max 32 GB)

**Headline: rotation-only + RTN does NOT beat plain RTN at the 4-bit
operating point; it wins decisively at 3-bit — the paper's law, reproduced.**
Per-module function-space Frobenius error is a wash at 4-bit (~0.091 all
arms, `scripts/turboquant/tq-quant-error.py` — γs are tame, 0.7–2.7, no
module class is the culprit); the 4-bit regression is the anisotropy story
(isotropic rotated error vs activation-aligned plain error), which is what
GPTQ-style calibration fixes — the composition named as the real win.

0.8B lab (dequant-OptiQ source; PAIRED arms; bf16 anchor 6.41, 48×512):

| arm | bpw | ppl |
|---|---|---|
| plain 4-bit | 4.50 | 7.01 |
| TQ(R1+γ) 4-bit | 4.50 | 7.39  ← regression, reproduces 27B |
| plain 3-bit | 3.50 | 19.19 ← RTN collapse |
| **TQ 3-bit** | 3.50 | **14.54** ← rotation −24% ppl |
| plain mixed (3-bit MLP, 4-bit attn/embed) | 4.15 | 9.69 |
| **TQ mixed (same profile)** | 4.24 | **9.22** ← paired rotation win |

27B (32×512, same corpus): plain 4-bit 4.659 ±0.093 (4.50 bpw, 15.0 GB) ·
TQ 4-bit 4.923 ±0.102 (+5.7%, consistent with the lab) · **TQ-mixed (4-bit
attn/embed + 3-bit MLP) 4.932 ±0.098 at 3.86 bpw / 13.9 GB** — matches
rotated-uniform-4-bit quality at −0.64 bpw; the artifact of record for the
14z M4-Pro fit lever.

AWQ-style equalization spike (norm-carried per-channel scales, α=0.5,
function-preservation verified at KL 0.0037/0 flips): TQ+eq 7.363 (≈no
change), plain+eq 7.809 (HURT — per-channel scales inside a g64 group widen
group ranges; real AWQ grid-searches a far gentler α and the real 4-bit fix
is GPTQ-style compensated rounding). Scripts kept:
`scripts/turboquant/tq-collect-actstats.py` + `tq-equalize.ts`.

**End-to-end validation of the TQ-mixed 27B artifact (2026-08-18, M1 Max,
busy box — correctness only):** server chat with correct arithmetic
reasoning (thinking → `reasoning` field); vision through the folded merger +
sidecar correctly identifies the gradient fixture's colors over HTTP; MTP
via the 14g harness with the same-seed folded companion: 71% acceptance,
2.40 tok/target-forward, arms token-identical (losslessness), ON/OFF 0.726×
(consistent with the stock 0.821× correct-but-slower verdict; MTP stays
opt-in).

Consequence for the release recipe: do NOT ship rotated uniform-4-bit (loses
to the trivial baseline); rotation's band is the ≤4-bpw mixed recipe where
it is decisively ahead. The 4.5-bpw flagship win waits for the calibration
composition (W5).

## W5a corrected-GPTQ matrix (2026-08-18; 0.8B lab, 4.5 bpw arms, 48×512 ppl, anchor = dequant-OptiQ 6.41 — verified lossless: original OptiQ scores 6.4077)

mlx-lm's shipped GPTQ (`mlx_lm/quant/gptq.py`) has TWO real defects that
partially cancel: the in-loop update window is `k:k+j` (over-propagates past
the block edge; must be `k:j` — the k term itself writes the quantized value
since e·Hinv[k,k] = w−q) and `err[..., k:k+1]` indexes a group-local buffer
with the GLOBAL k (mlx out-of-range slice assignment silently no-ops →
cross-group propagation lost after block 0). Fixing only err
DOUBLE-compensates [j, k+j) and REGRESSES below RTN (measured: 7.22/7.50);
fixing both = paper GPTQ. [mlx-lm #1878](https://github.com/ml-explore/mlx-lm/issues/1878) contains the CPU-only reproduction, observed results against mlx-lm 0.31.3 and upstream `e5962529`, and proposed two-line correction. Fork:
`scripts/turboquant/tq-gptq.py` (also restricts GPTQ+fallback to language
modules — vision H is a zero scalar and stays bf16).

| arm | ppl |
|---|---|
| **plain + GPTQ (fixed)** | **6.741** |
| TQ(R1) + GPTQ (fixed) | 6.847 |
| plain RTN | 7.010 |
| TQ RTN | 7.390 |

**Verdict: calibration is the main course; rotation SUBTRACTS at the 4-bit
band even under GPTQ on this family** (gap −1.6%; GPTQ closes half the
RTN→anchor gap). Rotation remains the sub-4-bpw lever (−24% at 3-bit). 27B
needs a chunked Hessian/GPTQ driver (stock flow = whole bf16 model + all
Hessians resident; down_proj H = 1.2 GB f32 each) —
`scripts/turboquant/tq-gptq-27b.py` (per-layer checkpoints, resumable, peak
≈ one bf16 layer + one Hessian + activations ≈ 6 GB).

## W5c 27B production results (2026-08-18)

**v2 run (uniform GPTQ-4): BROKEN artifact (ppl 306k).** Root cause,
evidence-backed: the compensation loop DIVERGED on layers with
rank-deficient calibration Hessians (layer-0 down_proj group scales grew
0.003 → 27 monotonically across columns, max 2.8e7; cosine ~0 vs source;
neighbors healthy). Early layers see low-rank activations (layer-0 input =
raw embeddings; rank ≤ distinct calibration tokens), so 5120 dims outran
the standard 1% damping — the 0.8B (1024 dims) never hit it.

**v3 fixes (all landed in the 27B driver):** divergence guard in
`gptq_one_guarded` (GPTQ scales vs 4× the RTN scale ceiling per matrix;
damping escalation 1e-2→10; RTN fallback = never worse than RTN); 4×
calibration (128×512); sensitivity-driven per-module bits from OptiQ's
published sensitivity.json; greedy benefit-per-param to `--target-bpw`.
v3 27B: 169 modules @8-bit, 4.80 bpw, 17.0 GB, ZERO guard triggers (the
calibration bump fixed conditioning outright), 64 layers in 166 min.

**27B ppl ladder (73×512, UF corpus, stock mlx-lm):** plain RTN-4 4.570
±0.060 · OptiQ 5.14 bpw 4.574 ±0.061 · GPTQ+sens 4.80 bpw 4.618 ±0.061.
**At 27B every sane ≥4.5-bpw recipe SATURATES this instrument** — OptiQ's
+0.6 bpw buys nothing measurable, and GPTQ shows a small consistent deficit
(likely calibration-domain mismatch: calibration_v5 vs chat-flavored eval
text). This contradicts the 0.8B lab ordering (GPTQ clearly won there) —
quantization robustness grows with scale. Decision moved to task
benchmarks: MMLU-100 + GSM8K-50 across the arms (`scripts/turboquant/
tq-evals.py`, paired items through stock mlx-lm).

## FINAL BOARD + DECISION (2026-08-18 night 2)

Task evals (lean mlx-lm runner, paired items; in-engine sweep swap-thrashed
the box — 73 GB swap at 0.7 GB resident — killed, gap recorded below):

| arm | bpw | GB | ppl(73×512) | MMLU-100 | GSM8K-50 |
|---|---|---|---|---|---|
| **GPTQ+sens v3 (SHIPPED as mjriii/Qwen3.8-27B)** | 4.80 | 16.3 | 4.618 | 87 | **96** |
| plain RTN 4-bit | 4.50 | 15.0 | **4.570** | 88 | 94 |
| OptiQ published | 5.14 | 18.1 | 4.574 | **89** | 92 |
| TQ-mixed (staged, small-footprint variant) | 3.86 | 13.0 | 4.93 | 82 | 96 |

All ≥4.5-bpw arms statistically tied on every instrument — 27B quality
SATURATES at 4-bit; recipes differentiate below 4 bpw and on completeness.
THE artifact = v3 (never trails; protective recipe; one-repo
vision+video+MTP; additive to the ecosystem where plain-4bit already exists
publicly). Serve gauntlet on THE artifact through OUR engine: text ✓
(23×19), image ✓ ("Green and pink"), video ✓ (gradient motion described;
AVFoundation chain), MTP harness 76% accept / 2.53 tok-per-forward with an
output-divergence flag vs plain greedy (consistent with verify-width
reduction-order near-ties, 12B step-0 class — margin analysis queued; NOT
claimed lossless on the card).

## Territory-mapping campaign (2026-08-18/19, Josh-directed: "map all the levers before concluding TQ-off")

**sens3 arm (Josh's recipe: rotated 3-bit base + sensitivity-driven 8-bit,
4.26 bpw / 15.25 GB incl. vision):** ppl 4.630 ±0.058 — TIED with the
4.80-bpw flagship (4.618) at −0.54 bpw, and a full recovery over unprotected
TQ-mixed (4.93). GSM8K 46/50 = 92% (plateau band). **MMLU 83/100 — the
3-bit-base dip persists** (TQ-mixed scored 82): two independent 3-bit-base
arms at 82–83 vs the 87–89 plateau → the knowledge-recall damage is SMEARED
across the MLP long tail; KL-derived sensitivity shields fluency, not
recall.

Perplexity proxy calibration (from our own table): deltas <~0.1 ppl are
task-invisible; ppl's remaining role is catastrophe detection + screening
(see the g128 lesson below, which retired the "~0.3 ppl = visible damage"
rule). mlx kernel bound: group_size ∈ {32, 64, 128} — 256+ needs custom
kernels (non-goal).

**Group-size lab (0.8B ppl) + 27B g128 arm:** rotation does NOT buy
coarse-group tolerance at 4-bit (tax +4.7% rotated vs +4.2% plain); at 3-bit
the dividend is real but partial (+29% vs +47%; rotated 3.25 bpw ≈ plain 3.5
bpw). 27B plain-4bit-g128 (4.25 bpw): ppl 4.714 (+3%), MMLU 88 (plateau!),
**GSM8K 62% — COLLAPSE via generation-behavior damage** (correct-but-rambling
truncations + instant-EOS empty outputs; single-forward instruments blind to
it). Lessons: (1) ppl deltas DO NOT bound task damage (+0.14 ppl ↔ −32 GSM8K
pts) — every finalist needs generative tasks; (2) g128 disqualified for
generative work.

**Run B — the full suite (rotation + GPTQ + sensitivity, 4.80 bpw, 17.0 GB,
zero guard triggers):** ppl **4.5965** (best quantized arm, tied w/
plain-4bit) · MMLU 84 · raw-completion GSM8K **24% — and the collapse is a
FORMAT CLIFF, not a reasoning failure**: when it answers it is flawless, but
3/4 raw few-shot prompts get INSTANT EOS; under the native chat template it
always answers (3/5 correct at a tight token cap). g128's 62% was the same
failure at lower frequency. **Methodology consequence: the raw-completion
GSM8K column conflates math ability with EOS-cliff robustness** — different
quant-noise realizations displace a razor-thin answer-vs-stop margin at
token 0. The map carries TWO generative columns: templated GSM8K
(serving-path reasoning) and raw-completion GSM8K (format-robustness probe).
Neither ppl nor MMLU sees any of this.

## THE FRONTIER (campaign complete, 2026-08-19; chart artifact `reports/frontier-map-2026-08-19.html` is machine-local — `reports/` is gitignored)

| arm | bpw | GB | ppl | MMLU | tGSM | rawGSM | tok/s* | Pareto |
|---|---|---|---|---|---|---|---|---|
| **rot+sens48 RTN (Josh's recipe)** | 4.79 | 17.0 | 4.680 | **90** | 94 | 84 | **11.80** | **YES** |
| GPTQ+sens (staged flagship) | 4.80 | 17.0 | 4.618 | 87 | 94 | **96** | 11.42 | — |
| rot+GPTQ+sens (full suite) | 4.80 | 17.0 | **4.597** | 84 | 94 | 24 | 11.77 | — |
| OptiQ published | 5.14 | 18.1 | 4.574 | 89 | 94 | 92 | 8.92 | — (dominated) |
| **TQ-mixed** | 3.86 | 13.0 | 4.932 | 82 | 82 | 96 | 10.94 | **YES** |
| bf16 ceiling (streamed eval, `tq-bf16-ceiling.py`) | 16 | 54.4 | 4.552 | 87 | n/a | n/a | n/a | ref |

*M1 Max 32 GB, busy box, spreads 8–34% — directional until a quiet
`scripts/bench-serve.ts all` run (probes: `scripts/turboquant/tq-tps.ts`).

Findings of record: (1) the ≥4.5-bpw band sits AT the bf16 ceiling (ppl
within ~1%, MMLU within noise — a quant scoring 90 vs ceiling 87 proves ±3
noise); (2) BOTH Pareto points are ROTATED — rotation at 4-bit is
competitive exactly when paired with sensitivity allocation (the earlier
uniform-rotation loss concentrated in the sensitive modules, as Josh
hypothesized), and mandatory below 4 bpw; (3) OptiQ is dominated on all
three axes (its extra 0.34 bpw buys nothing and costs ~25% decode); (4)
GPTQ's measurable 27B contribution is ppl-only — it buys no task quality at
this scale and (with rotation) costs raw-format robustness; (5) 3-bit
kernels pay an unpack tax that eats their bandwidth win on M1 (see the M4
row for the reversal); (6) cross-engine parity CERTIFIED (byte-identical
greedy, ours vs stock mlx-lm, on the staged flagship). Certification
benchmark for the chosen artifact: GPQA Diamond at reasoning_effort=xhigh
(`scripts/turboquant/tq-gpqa.py`, local mlx-lm or `--server-url` through a
running `mlx-bun serve`; greedy runs bit-identical across the two paths).

## M4 Pro 24 GB speed rows (2026-08-20, mlx-bun, `scripts/turboquant/tq-speed-row.ts`)

Winner artifact (rot+sens48), second reference machine (M4 Pro, 24 GB,
~273 GB/s), `sysctl iogpu.wired_limit_mb=21504`, DeltaNet leak fix applied:

| prompt | prefill tok/s | TTFT | decode tok/s | notes |
|---|---|---|---|---|
| 1,024 | 127 | 8.1 s | 14.66 (1.1%) | chunk 2048 |
| 8,192 | 124 | 66 s | 14.13 (1.3%) | chunk 2048 |
| 32,768 | 114 | 288 s | 12.77 | chunk 1024 (peak 19.3 GB) |

- **Compute-bound decode confirmed cross-machine:** 14.7 tok/s here vs 11.8
  on the M1 Max (400 GB/s) — the machine with 68% of the bandwidth is 25%
  FASTER. Decode is dequant-ALU-bound, not weight-streaming-bound (M1
  telemetry: GPU 100% @ ~266 GB/s of 400). Headroom to the ~24 tok/s
  bandwidth roofline is a future perf program.
- **Decode-at-depth is nearly flat** (−13% at 32× context): only 16 of 64
  layers grow KV; DeltaNet state is constant.
- **Prefill transient scales with chunk × offset** (~2.8 GB at 24k with
  2048-chunks; measured via `MLX_BUN_PREFILL_MEM_LOG` and
  `scripts/turboquant/tq-mem-probe.ts`): on 24 GB the 32k row needs
  1024-token chunks (−8% prefill). Engine follow-up: serve should scale
  prefillChunkSize from fit.ts headroom automatically.
- Prefill absolute rate (~125 tok/s) is the weak axis — suspected DeltaNet
  per-token recurrence during prefill; compare against mlx-lm same-box
  before treating as our bug (oracle-gap rule).

Compact sibling (TQ-mixed) on the M4, same protocol, chunk 1024 all rows:

| prompt | prefill tok/s | TTFT | decode tok/s (spread) |
|---|---|---|---|
| 1,024 | 117 | 8.8 s | **17.14** (0.7%) |
| 8,192 | 124 | 66 s | 16.05 (2.4%) |
| 32,768 | 85 | 6.4 min | 13.80 (2.9%) |

**The 3-bit speed verdict is GPU-generation-dependent:** on M1 Max the
3-bit-heavy artifact decoded SLOWER than the 4/8 winner (10.94 vs 11.80 —
unpack ALU dominates); on M4 Pro it decodes FASTER (17.14 vs 14.66 — newer
ALU absorbs the unpack, fewer bytes win). Card guidance: M1-class → winner
fastest; M4-class → compact is smaller AND faster. Compact 32k prefill
(85 tok/s) is its weak axis. Peak not instrumented this run; estimated
~16 GB at 32k (likely fits the DEFAULT 24 GB wired limit — untested).

## Known engine gaps found in passing (not TQ defects)

- `mlx-bun perplexity` cannot score qwen3_5: it routes through
  `trainForward`, whose cache stub lacks the DeltaNet `SSMCache.advance`
  (`qwen3_5.ts:226` throws on plain and TQ arms identically). 27B ppl runs
  through stock mlx-lm (`scripts/turboquant/tq-ppl.py`) — which doubles as
  the cross-stack load check for the release artifact.
- bf16 (unquantized) qwen3_5 trunks don't load in our engine:
  `QuantizedEmbedding.load`/`QuantizedLinear.load` hard-require `.scales`.
  The small-scale fold proof ran through stock mlx-lm instead. Backlog: not
  needed to serve the published quant.
- `scripts/eval.ts` capability tasks at 27B swap-thrashed a 32 GB box — root
  cause fixed (chunked `forwardHidden` prefill + allocator clear cadence);
  verify at 27B post-GPQA.
- Qwen MTP via the HTTP serve lane 500'd (`[slice] Invalid number of
  indices…`) — pre-existing serving-path bug, reproduced with stock
  artifacts; FIXED 2026-08-20 (draft gate + `[1,V]` sampler contract). The
  paired MTP harness is `scripts/turboquant/tq-mtp-ab.ts` (its header still
  cites its old name, `qwen38-mtp-ab.ts`).
- DeltaNet prefill leak (~1 MB/token, `contiguous()` returning a no-op view
  that pinned whole chunk buffers) FOUND+FIXED 2026-08-20 via this program's
  dogfood gate; 27B now fits 24 GB (peak 19.2 GB at 16k probe).

## Weights-leg non-goals

The original W recipe's scope below does not limit the 2026-09 Qwen performance
program. Custom formats, kernels, alternative algorithms and online-transform
candidates are now in scope under the gates in
[decode-speed-program.md](decode-speed-program.md#7-qwen38-27b-research-program).

Mirrors the PLAN.md phase: no custom Lloyd-Max weight format / new qmm
kernels; no activation quantization; no runtime weight rotation of any kind
(weights fold offline; online rotation remains the KV codec's job); no
GGUF/AWQ export; group_size > 128.

---

## Q campaign — sub-4-bpw frontier: KL instrument, trellis, LDLQ, mixed-k (2026-08-31 → 09-02, M1 Max 32 GB)

Josh's frame: the best Qwen3.8-27B for THIS 32 GB box — smallest, smartest,
fastest — using the rotation ("that was the entire point") plus the levers
the 900+ published quants do not combine: trellis coding (QTIP/TCQ), LDLQ,
and borrowed sensitivity measurements (EXL3/Unsloth/OptiQ). Program tag Q.

**Q0 instrument — mean KL vs a bf16 teacher, on 32 GB.** `scripts/turboquant/
tq-dump-teacher-logits.py` streams the bf16 27B through stock mlx-lm once and
writes, per teacher-forced position, the top-2048 logits + full-vocab
logsumexp (fp16 lossless for bf16; captures 99.79% of full-vocab KL);
`tq-kl-vs-teacher.py` (Python) and `bun scripts/eval.ts kl --reference-logits`
(serving path) score any candidate; self-KL is exactly 0 and the two stacks
read the dump byte-identically. Corpus `runs/kl-corpus/uf-4096x32` (32×4096
UF-derived chat, sha `6594cfbf…`); dump `runs/kl-teacher/qwen38-27b-bf16`
(1.61 GB). Calibration warning of record: this protocol runs ~25× hotter than
the published self-generated-trace charts (RTN-4 = 0.1396 here vs ~0.005
there) — only within-dump comparisons are valid, never cross-paper numbers.

**KL ladder (mean KL(bf16‖cand), same dump, lower is better):**

| arm | bpw | GiB | KL | MMLU | tGSM | rawGSM |
|---|---|---|---|---|---|---|
| bf16 | 16 | 54 | 0 | | | |
| RTN-4 g64 (all 4-bit) | 4.5 | 15.0 | 0.1396 | | | |
| **Q3: rotation + LDLQ + mixed-k 3.00** (fake-quant; carrier8 dense 0.1568) | **3.55** | **~11.9 proj.** | **0.1553** | **88** | 48 | 44 |
| flagship GPTQ+sens (mjriii/Qwen3.8-27B) | 4.80 | 17.0 | 0.1646 | 87 | 94 | 96 |
| **compact allocation, NO rotation** (`tqalloc-norot`) | 3.858 | 13.13 | **0.2524** | 85 | 98 | **0/50** |
| q1-latemlp, no rotation | ~3.9 | | 0.2837 | | | |
| **trellis k3 uniform + rotation** (q2a, fake-quant) | ~3.4 | | 0.4240 | | | |
| trellis k3 uniform, no rotation (q2b) | ~3.4 | | 0.5648 | | | |
| compact allocation + rotation (mjriii/Qwen3.8-27B-TQ) | 3.86 | 13.9 | 0.6054 | 82 | 82 | 96 |
| q1-latemlp + rotation | ~3.9 | | 0.6519 | | | |

Findings of record: (1) **rotation is a 2×2 crossover, not a lever with a
sign** — it HELPS the trellis (0.565 → 0.424) and HURTS affine g64
(0.252 → 0.605): the trellis codes a Gaussian source and needs the Hadamard;
affine's per-64 scale+bias already absorbs the outliers the rotation spreads.
(2) **KL is the screen, not the verdict**: the lowest-KL sub-4-bpw arm scores
0/50 on raw GSM (an EOS cliff a single-forward instrument cannot see) while the
rotated compact arm at 2.4× the KL scores 96 — every finalist still needs the
task columns. (3) No trellis cell beats the affine compact arm yet; the two
open levers are LDLQ (Hessian error feedback) and mixed k — the published
EXL3 numbers (their protocol: SC 3 bpw 0.0257 vs UD-Q3_K_XL 0.0209; 4 bpw
0.0062) say both are worth ~20–70%. (4) Weight-MSE is NOT a screen: it
predicted the unrotated trellis at 0.18–0.21; the measured KL was 0.5648.
(5) **The full recipe wins (2026-09-02):** rotation + LDLQ + EXL3-derived
mixed k at the 3.00 MLP budget scores KL 0.1553 at 3.55 coded bpw — below
the shipped 4.80-bpw flagship (0.1646), 38% below the previous sub-4 best
(compact-norot 0.2524), 11% above all-4-bit RTN (0.1396) — with MMLU 88/100
(flagship 87, compact 85), tGSM 48/50 (flagship 48), rawGSM 44/50 (flagship
48, compact-norot 0): no EOS cliff. Each lever alone lost (q2a 0.4240); the
levers compound. At n=100/50 a one-point gap is noise: the claim of record
is "matches the 4.8-bpw flagship at 3.55 bpw", not "beats it". Gate Q3 PASSED.

**Q2 trellis codec** (`scripts/turboquant/tq-trellis.ts`): QTIP bitshift
trellis L=12, k∈{1..4}, V=1, T=256, tail-biting Viterbi, 1MAD/RPTC/random
codebooks; `--validate` reproduces QTIP Table 2 exactly; 1.2 Mw/s on M1 Max
after replacing `argmax` (MLX ArgReduce is 85× slower than `max`) with
compare + uint8 max. Driver `tq-quantize-trellis.ts`: streaming fold +
quantize, trellis on the 192 MLP tensors along the rotated axis, affine
elsewhere per the compact allocation, fake-quant output (decoded bf16 flagged
`false`, so stock mlx-lm loads it). Real packed kernels (Q2b) only if a recipe
wins: Metal has no `lop3`, so decode costs 4–5 ALU ops/weight; M1 decode is
already ALU-bound (3-bit affine at 54% of roofline) → predicted 7–9 tok/s on
M1 (a regression), wash-to-win on M4 Pro; ~257 dispatches/token; fallback is
load-time expansion to affine.

**Q2c LDLQ** (`tq-ldlq-hessians.py` + `--ldlq <hdir>`): per-layer MLP input
Hessians in the folded basis (gate/up captured pre-γ so H' = R1ᵀ E[nnᵀ] R1;
down basis-free), block-LDL on CPU, BlockLDLQ error feedback at block T (=
the trellis block, so only the objective changes vs q2a), 4× unweighted-peak
guard, 20 GiB leak abort. Calibration = 512×128 rows of the SAME chat domain
(disjoint from the scored rows; a domain mismatch was measured to hurt GPTQ).
Hessians: 64 layers in 35 min, 0/128 factorization fallbacks. The uniform-k3
LDLQ arm (Q2c) was paused at 72/192 and superseded: Q3 went straight to the
full recipe, so LDLQ's isolated contribution is not separately measured
(q2a → Q3 is LDLQ + mixed-k together, 0.4240 → 0.1553). Bug found on resume
(2026-09-02): the k-map refactor's block loop shadowed the codec k
(`trellisFor(blockIdx)`); the Trellis ctor now rejects K outside [1,L), the
L=0 selftest is byte-identical again, and the real-L probe on layer 21 runs
at 5.6 GiB peak with the unweighted MSE +32/+46% (gate/down), as expected for
a Hessian-weighted objective.

**Q3 mixed k** (`--k-map reports/qwen38-allocation/trellis-kmap.json
--k-budget 3.00`): per-tensor k∈{2,3,4} greedily allocated from turboderp's
EXL3 per-tensor KLD-vs-k table for this exact model (gate/up tied like EXL3's
own recipe; 94.3% agreement with their 3.00 bpw recipe). Budgets 2.75 / 3.00
/ 3.25 avg-MLP-bpw = k2/k3/k4 68/104/20, 26/140/26, 2/140/50 (≈10.8 / 11.3 /
11.8 GiB projected). Run 2026-09-01/02 at 3.00: 259 min (257 in the encoder,
1.11 Mw/s), 192 trellis tensors, 3.5468 coded bpw over 27.3 G params, 38 GiB
fake-quant on disk; artifact `mjriii/Qwen3.8-27B-q3-trellis-ldlq-k300-fakequant`
on the external volume, KL row `rows/q3-ldlq-k300.json`. Result: see finding
(5). 3.25 not run — 3.00 already clears the gate; a 2.75 arm is the next
size lever, not 3.25.

**Q2b packed format + kernels** (`src/quantize/trellis.ts`,
`src/model/trellis-linear.ts`, driver `scripts/turboquant/
tq-quantize-trellis-packed.ts`; the fake-quant codec/driver that produced the
Q3 record are frozen, these are new files). On disk a trellis tensor is
`.weight` uint32 `[rows, cols·k/32]` + `.scales` fp16 `[rows]`, config entry
`{mode:"trellis", bits:k, group_size:T, trellis:{L, code:"1mad", axis}}`
(axis 1 = coded along the input dim, stored `[out, in·k/32]`; axis 0 = along
the output dim, stored as Wᵀ `[in, out·k/32]`). One block = T·k bits; symbol
b_t sits at bit offset (T−1−t)·k — REVERSED time — so the L-bit window at that
offset (wrapping, tail-biting) IS state_t, and any weight decodes in O(1):
two word loads, shift, mask, LUT. No sequential dependency, hence a plain
matvec. Three Metal kernels share that primitive: `reduce` (axis 1, one SIMD
group per output row, lanes stride consecutive coded positions → coalesced,
`simd_sum`), `scatter` (axis 0, 32 lanes = 32 consecutive outputs of one
block, loop over inputs, split-K ×16 partials summed by one mlx op), and
`expand` (whole tensor → bf16 for M>4, then a stock matmul; ≤178 MB
per expanded tensor). Packed prefill evaluates each projection before
building the next. Qwen also evaluates each layer's cache outputs: the
copied conv tail otherwise retains the whole chunk's conv input until
end-of-chunk cache evaluation. Decode remains lazy and uses packed kernels.
These evaluation boundaries bound temporary buffer lifetimes; disposing a
JS tensor handle alone does not release a lazy consumer's references.
The reconstructed weight is bf16(f32(lut[state])·f32(scale)) in
every path — bit-identical to the fake-quant artifact's stored bf16 (unit test
`tests/unit/trellis-linear.test.ts`: host unpack + expand kernel exact for
k∈{2,3,4}; matvecs within 2e-3 of a bf16 matmul). Engine wiring is additive:
`QuantSpec.trellis`, `loadLinear`/`Qwen3MLP` pick `TrellisLinear` per module;
trellis MLP tensors are not LoRA targets yet. `MLX_BUN_TRELLIS=expand` is the
load-time fallback (8-bit affine carrier). Encoding a packed artifact reruns
the Viterbi (the fake-quant stores values, not states; a state path cannot be
recovered from values because the 4096 states map onto 1021 distinct values).

**Q2b measured (2026-09-02, M1 Max 32 GB).** Packed Q3 artifact
(`Qwen3.8-27B-q3-trellis-ldlq-k300-packed`): **12.14 GiB** on disk (fake-quant
38 GiB, flagship 17 GiB), LDLQ applied 192/192, 0 guard trips; decoded
weights bit-identical to the fake-quant artifact through the expand kernel
(0 mismatches in 89 M per tensor, k=2 and k=3, both axes). Loads and generates
through the qwen3_5 graph; KL through OUR serving path 0.15501 (mlx-lm on the
fake-quant: 0.15532). Decode kernels, pipelined 8-deep (the in-graph cost; an
eval-per-call bench adds ~0.3 ms of sync and misleads), gate/up [17408×5120]
and down [5120×17408], k=3, M=1:

| kernel | no decode (floor) | inline 1MAD, f32 weight | stock affine 3-bit g64 |
|---|---|---|---|
| gate/up matvec (reduce) | 0.24 ms | 0.41 ms | 0.16 ms |
| gate+up+swiglu fused | 0.37 ms | 0.73 ms | 2×0.16 |
| down matvec (scatter) | 0.54 ms | 0.77 ms | 0.16 ms |

Whole model: **9.3 tok/s** vs the 4.80-bpw affine flagship at **18.9** on the
same box (kernels v3, `c0a1e00`); the first kernels read 4.4. What the
decomposition says: (1) the 1MAD decode is ~12 int ops/weight and costs
0.17 ms per 89 M weights; a precise divide cost 1 ms (replaced by y×(1/d),
which is 1-ulp-off f32 for 398 of 1021 code values — a 2-FMA residual step
restores exactness at +0.05 ms, `trellis_val_rcp`); (2) rounding the decoded
weight to bf16 (to match the artifact's stored bf16) cost as much as the
decode, so the served weight is now f32 code×scale — MORE accurate than the
fake-quant, no longer bit-identical to it — measured on the served DECODE
path (`eval.ts kl --decode --self MLX_BUN_TRELLIS_VARIANT 1→6`, 16 prompts ×
32 teacher-forced steps): KL(bit-exact ‖ f32-weight) mean 0.00089, p95
0.0025, i.e. 0.6% of the model's own 0.155 to the teacher (the prefill/expand
path always rounds to bf16 and is unaffected); (3) the threadgroup LUT (16 KB) halves
occupancy and the device LUT gathers 32 lines per load — both slower than
computing the code; (4) the axis-0 (down) matvec is the hard one: the code
sequence runs along the OUTPUT dim, so a reduction over inputs is a column
gather; lanes-over-outputs looping rows costs a full line per 16-byte
segment, and lane-per-word (whole-line reads, shuffle for spilled windows)
did not beat it — its no-decode floor is 3× affine. M1 decode at these sizes
is latency/occupancy bound (affine reaches 200 GB/s of 400), so every ALU op
per weight lands on the wall clock. Verdict: the packed format works and is
the honest 12 GiB artifact; on M1 Max it decodes at ~half the flagship's
speed. Levers left: code down_proj along its INPUT dim (a recipe change —
the rotated axis is the output dim — needs a re-encode and a KL check),
half-precision LUT (8 KB, occupancy back, +double rounding), or accept
M4-class ALU. `MLX_BUN_TRELLIS=expand` (8-bit carrier, 23 GiB) is the
full-speed fallback where it fits.

**The down_proj axis, settled (2026-09-02 night).** Re-encoded the same recipe
with `--down-axis in` (down_proj coded along its INPUT dim — the un-rotated
intermediate — so all three MLP projections decode with the plain reduce
kernel; `--reuse` copied the 128 unchanged gate/up tensors, so only 64 Viterbi
runs, 98 min):

| arm | bpw | GiB | KL (engine) | top-1 | decode tok/s |
|---|---|---|---|---|---|
| down coded along the ROTATED output dim | 3.5468 | 12.14 | 0.15501 | 86.38% | 9.3 |
| **down coded along the INPUT dim** | 3.5463 | 12.14 | **0.15543** | **86.59%** | **11.3** |

KL is a wash (+0.0004, 0.3% of the arm's own distance to the teacher) and
top-1 is marginally BETTER — so on the screen the input axis looked like a
free +22% decode. **The task columns overturned it** (8-bit carriers, same
frozen items, `tq-evals.py`):

| arm | MMLU-100 | tGSM-50 | rawGSM-50 |
|---|---|---|---|
| down along the rotated output dim | 88 | 48 | **44** |
| down along the input dim | 88 | 47 | **29** |

The rawGSM regression is STRICTLY NESTED — 15 items the output-axis arm
answers correctly that the input-axis arm fails, **0 the other way** (McNemar
p ≈ 3e-5) — and the failure mode is an EMPTY continuation: on those items the
model emits EOS immediately after `A:` (verified by dumping the raw
generations). That is the same EOS-cliff class as the unrotated affine arm
(`tqalloc-norot`, rawGSM 0/50 at KL 0.2524), and it is invisible to MMLU
(logprob over four letters), to templated GSM (chat template, 47 vs 48), and
to KL (a single-forward instrument that never asks the model to STOP).

**Finding of record (third instance of "KL is the screen, not the verdict"):
one-sided incoherence processing must reach the CODED axis.** R1 gaussianizes
down_proj's output dim; coding along the un-rotated input dim leaves that
sequence non-Gaussian for a codebook that assumes unit-variance Gaussian
inputs, and what breaks is not average next-token quality but the model's
raw-format stopping behavior. **Carry-forward stays the output-axis arm**
(`…-k300-packed`, 9.3 tok/s); `--down-axis in` is kept as the measured
counter-example, not a default, and the scatter kernel stays load-bearing.
The re-encode also surfaced a driver bug: the LDLQ Hessian must be chosen by
MODULE, not by trellis axis (`2b29b18`).

**Eval carrier** (`scripts/turboquant/tq-repack-fakequant.ts`): a 38 GiB
fake-quant cannot load dense on 32 GB, and `tq-evals.py` (MMLU logprob
scoring, GSM greedy generation) needs the whole model resident. The tool
re-packs exactly the bf16 MLP tensors flagged `false` as 8-bit g64 affine
(≈ −45 dB, negligible next to the ≈ −13 dB trellis error) and passes every
other tensor through byte-identical: 23 GiB, loads in 24 s, dense KL 0.1568
vs 0.1553 streamed (+1%, identity confirmed). All task columns for trellis
arms are measured on the carrier. NOT a shipping format — the real footprint
needs Q2b (packed trellis + Metal decode kernel).

## Packed kernel experiments (2026-09-05, M4 Pro 24 GB)

Experimental `MLX_BUN_TRELLIS_VARIANT=7` reuses each decoded gate/up weight
across M=2..4 input vectors. The new kernels live in
`src/model/trellis-shared-m.ts`; the original kernels remain the default
(variant 6). Variant 7 keeps the same two-accumulator order, reductions and
bf16 activation boundaries. M=1, scatter/down and M>4 expansion retain the
variant-6 decoder and kernels. No weight format or crossover changed.

The kernel diagnostic now loads an individual layer's real packed tensors
with `--model-path`, selecting a gate bit-width via `--k` (and optionally
`--layer`). It records the actual per-role geometry, tensor SHA-256 hashes,
source identity, every timing sample and memory. `--variants 6,7` compares
the implementations; `--reference-variant 6` checks outputs separately from
timing. `--m`, `--seed`, `--reps` and `--pipe` control the micro-workload;
`--skip-affine` excludes synthetic affine controls, which are not a quality
comparison. `--json reports/<name>.json` preserves results. Its complete-MLP
cell retains gate/up → SwiGLU → down dependencies and production barriers.
`--kernel-module` permits isolated candidate modules with the same exports.

The first screen covers the packed artifact's k2/k3/k4 matrices at
M=1/2/3/4/5/8. Shared-M reduce and fused gate/up prototypes match the observed
outputs at M=1..4. Six sequential AB/BA blocks with different activation seeds
retain the gain in the complete MLP. Raw evidence is under
`reports/qwen38-rd/paired-shared-m/`; integrated variant-7 checks are under
`reports/qwen38-rd/variant7/`. Unit tests also compare exact output bytes for
bf16/f32, both axes, fused activation, the complete MLP and the M=4/5 boundary.
The complete packed 27B also passes candidate/current equality for all logits,
live KV/recurrent state and a subsequent token at M=1..5. Six AB/BA full-model
forward blocks at M=2/4 preserve state/logit identity on distinct token inputs;
results are in `reports/qwen38-rd/shared-m-full-model.json`. These timings
project every position from a short shared prefix. They do not measure HTTP
generation or strict fill's last-position-only head. The machine fails the
quiet/swap gate, so user-workload A/B and quiet M4 Pro evidence remain required
before a default. `tests/parity/trellis-shared-m.test.ts` retains the native
gate behind `MLX_BUN_TEST_TRELLIS_MODEL`; `MLX_BUN_TRELLIS_AB_REPORT` optionally
records the diagnostic forward timings.

Experimental variant 8 combines variant 7 with balanced 3-bit scatter in
`src/model/trellis-balanced-scatter.ts`. The incumbent assigns one packed word
per lane and leaves eight SIMD lanes idle for a 3-bit block. The candidate
assigns eight outputs to each of all 32 lanes, loads adjacent packed words
and aligns them once before constant-shift decoding. It preserves each
output's row/FMA order, all split boundaries, partial reduction and final
cast. This path requires k=3, T=256 and L<=12; other geometries retain the
incumbent scatter. M>4 still expands. The default remains variant 6.

Balanced lanes alone improve the diagnostic screen; aligning words improves
it further. Row-loop unrolling does not materially improve the aligned
candidate, so it is not retained. The unroll screen has no repeatable-win
verdict for k2/k4. Raw screens: `reports/qwen38-rd/balanced3-screen/`,
`scatter-unroll-screen/` and `aligned3-screen/`. Six blocks comparing
variants 6/7/8 at k3 and M=1/2/4 retain the down/complete-MLP gain with exact
observed outputs (`variant8-paired/`). Native packed-model logits, live state
and subsequent-token checks also pass M=1..5. Six full-model A/B blocks at
M=1/2/4 retain the gain (`variant8-full-model.json`). Select this gate with
`MLX_BUN_TRELLIS_AB_VARIANT=8`; these remain short-prefix diagnostics.

`MLX_BUN_TRELLIS_AB_LAST=1` selects a native append screen at
M=1/2/3/4/5/8/9/16 with only the last vocabulary projection, closer to strict
fill's work. The variant-7 screen preserves state/logit identity and confirms
the M=4/5 cost discontinuity (`shared-m-append-lengths.json`). Splitting a long
span crosses the packed-f32/expanded-bf16 paths and is a separate numerical
experiment; the timing curve does not authorize that change.

A device lookup table of variant-6 f32 code values also matched the observed
outputs but slowed the M=1 kernels for every tested bit width. That candidate
is a measured loss on this chip/regime (`reports/qwen38-rd/lut6-*.json`). The
M=4/5 gate-projection cost discontinuity remains; changing the crossover also
changes the accumulation/precision path and needs separate numerical gates.

The smaller-table follow-up also loses on the M4 Pro. A constant-address-space
table stores all 4,096 integer code values in signed 16-bit entries, preserving
the reciprocal, scaling and reduction arithmetic. It matches the k3 M=1
checks but slows both projections and complete MLP execution. Device and
threadgroup tables store the same integers exactly in fp16, avoiding the
double rounding of fp16 normalized code values. Both lose at M=1/4; the
threadgroup version is the less costly choice. Those two experiments change
gate/up decoding while retaining the aligned k3 scatter's computed decoder.
None proceeds to full-model integration. Evidence: `trellis-constant-short-k3-m1.json`,
`trellis-device-half-k3-m1.json`, `trellis-device-half-k3-m4.json`,
`trellis-threadgroup-half-k3-m1.json` and `trellis-threadgroup-half-k3-m4.json`
under `reports/qwen38-rd/`, with source manifests and every timing sample.

A later scatter-specific table experiment starts from the interleaved
variant-13 artifact. Each threadgroup computes the exact 4,096 integer code
values into an 8 KiB signed-short table; packed float multiplication and the
original dense-expansion LUT remain unchanged. An initial 45-process screen
across bf16/f16/f32 and M1/2/4/5/8 preserves all output hashes. Changing all
decode sites still loses because gate/up slows. The apparent M1 scatter gain
does not survive the narrower repeated control.

Restricting the table to the balanced scatter kernels completes 72 processes
with exact separate-process output hashes, including complete MLP outputs
and M5/8 fallback. Six alternating bf16 pairs on the M4 Pro 24 GB change
complete-MLP time by +1.28% at M1, -0.62% at M2 and -4.12% at M4. All M1
pairs lose and all M2/M4 pairs improve. A 20-process M3 follow-up also preserves
every output hash; its six bf16 pairs improve the down projection by a median
8.02% and the complete MLP by 2.52%. The smaller fp16/fp32 screens preserve
identity but do not establish retention. Each native/candidate pair reaches
the same final active-allocation baseline. These are diagnostic operation
timings, with fixed sources and all samples retained. The next full-model
prototype targets only M3/4 for the tested k3/L12/T256 interleaved down shape.
Ordinary M1 stays procedural. Full-model state, generation and actual serving
acceptance remain before integration. Evidence: `trellis-threadgroup-codebook.json`,
`trellis-threadgroup-scatter{,-review}.json` and
`trellis-threadgroup-scatter-m3{,-review}.json` in the campaign directory.

The narrow full-model screen then preserves all 24 forward comparisons,
including every vocabulary row at M1..8, live attention/recurrent state and
the next token's logits/state. It also preserves four greedy/seeded-sampled
generation streams and their log-probabilities, counts and final cache bytes.
The prefix snapshot stays unchanged. Both fresh processes exit cleanly with
fixed sources, equal scatter-call counts and the same 1,015,814-byte final
active counter after model/cache disposal. The first pair's measured M3/4
forwards improve by 1.6–2.8%; ordinary 64-token generation changes by less
than 0.1%. This is an initial screen. Six balanced process pairs and actual
MTP serving comparisons remain before retaining the prototype. Evidence:
`trellis-scatter-full{,-review}.json`.

Six balanced fresh-process pairs preserve all 144 forward/logit/state and
24 generation comparisons, with fixed sources, identical call counts and
the same final active allocation. Taking the two measured forward samples
within each process before pairing, median M3/M4 forward changes are
-1.44/-2.00%, improving every pair. Ordinary 64-token greedy/sampled complete
times change by +0.045/-0.125%. The unchanged M128 prefill control is 2.59%
slower in this sequence and loses all six pairs. A focused M128-only control
tests whether that regression requires preceding M3/4 work. The initial actual MTP HTTP pair preserves all seven responses,
7,100 eligible scatter calls per arm and equal final active counters, but
its complete-time changes are mixed. Evidence:
`trellis-scatter-full-repeat{,-review}.json` and
`trellis-scatter-http{,-review}.json`.

Six subsequent balanced MTP HTTP pairs preserve all 42 paired responses,
call maps and final active allocations. Median complete-request changes are
-1.53% for code, -1.29% for explanation and -1.04% for JSON. Code and explanation
improve in every pair; JSON improves in four of six. TTFT changes by less than
0.71% and median paired sampled peak RSS increases by 2.16 MiB. These are
M4 Pro 24 GB diagnostic results, with static swap still failing preflight.
They support a small serving benefit in this scope, not ordinary M1 decode.
The separate four-pair M128-only control executes no eligible M3/4 scatter
calls. All 20 forward/state comparisons remain exact and final active memory
is 16,390 bytes in every process. Its median paired time increases by 0.52%,
with individual process-median differences from 0.06% to 1.01%. This does not
reproduce the earlier 2.59% magnitude, but does not identify its cause either.
Keep both results and inspect scheduling before integration. Evidence:
`trellis-scatter-http-repeat{,-review}.json` and
`trellis-scatter-prefill{,-review}.json`.

A four-pair sequence control adds 80 exact forward/state/continuation cases,
with the same 16,390-byte final active counter in all eight processes. M3/M4
forwards improve by median 1.45/1.73%, in every pair. The same-input M128
measurement immediately before and after those calls changes by -0.92/-1.77%
between arms; the after-versus-before difference does not show the suspected
slowdown. The unchanged M512 control instead changes by +1.11%, losing three
of four pairs. These controls do not reproduce the original M128 result or
establish a prefill benefit. Keep prefill variation in the uncertainty of this
small candidate and require integrated, combined and quiet acceptance.
Evidence: `trellis-scatter-sequence{,-review}.json`.

The normal-scheduling recorder preserves the three HTTP responses and all
scatter calls in a separate JSON pair. The measured request has 76,928
dispatches, 3,153 command buffers with dispatches, 50,001 barriers and 3,870
concurrent dispatches in both arms. Temporary-reference counts and bytes also
match. Buffers without dispatches and fence waits differ slightly. Candidate
command-span union falls by about 51 ms, while gaps between those spans grow
by about 72 ms; instrumented complete time increases by 0.32%. Command spans
include internal waits and do not measure active GPU utilization. This pair
shows how scheduling gaps can cancel a small operation gain; it does not
override the six normal-library serving pairs or prove the cause of the
prefill difference. Evidence: `trellis-scatter-http-trace{,-review}.json`.

The first ordinary four-request serving pair also preserves all 12 paired
responses, submitted-row counts, scatter-call maps and final active allocation.
The measured 256-token cohort completes in 11.342 versus 11.778 seconds,
3.70% faster, with 4,050 eligible M4 scatter calls across its three cohorts.
This is one M4 Pro 24 GB diagnostic pair, not a repeat verdict. Explicit API
seeds require the serial lane, so this fixture uses temperature-zero argmax
without an explicit seed. The initial seeded attempt is retained as a rejected
batch fixture. Evidence: `trellis-scatter-cohort-v2{,-review}.json`.

The codebook is now part of experimental variant 13. Qwen's MLP loader enables
it for the 5120/17408 down projection. `TrellisLinear` further requires bf16,
k3/L12/T256, two-block interleaving and M3/4. The generic shared scatter kernel
receives that decision as a compile-time integer. The table is initialized
before the threadgroup's bounds return, and no new MLX allocation or graph
boundary is introduced. Request and execution interfaces do not select it.
The 23 focused tests and all three typechecks pass. The new test compares
actual output bytes and dispatch eligibility across three dtypes, variants
6/10/13, M1/2/3/4/5/8 and an incomplete row tile. Evidence:
`trellis-scatter-integration-source-change.json`,
`trellis-scatter-integration-focused-tests-final.txt` and
`trellis-scatter-integration-typecheck.txt`.

The integrated full-model gate preserves all 24 forward/logit/state and four
generation comparisons, the immutable prefix, call maps and final allocation.
M3/M4 each exercise 150 table calls in the candidate. Timing also improves in
unchanged control shapes during an unrelated CPU workload burst; those broad
changes cannot be attributed to this kernel. Six integrated MTP HTTP pairs
then preserve all 42 responses and the same final active counter. Median
complete-time changes are -1.07/-1.27/-1.19% for code/explanation/JSON, with
5/6, 5/6 and 4/6 pairs improving. TTFT changes remain below 0.46%. Retain every
losing pair and the diagnostic classification. Repeated ordinary four-request
serving, combined/pressure and quiet M4 Pro acceptance remain. Evidence:
`trellis-scatter-integrated-full{,-review}.json` and
`trellis-scatter-integrated-http{,-review}.json`.

Six integrated ordinary four-request serving pairs preserve all 72 paired
responses, counts and finish reasons. Every cohort admits four batched rows,
uses the eligible M4 kernel and returns to the same final active counter.
Median measured cohort time changes by -1.49%, improving four of six pairs.
Four measured pairs have identical per-cohort call maps; their median is also
-1.49%, with three improving. The other two retain arrival-dependent M1/M2
work differences. Report all pairs and the work-matched subset separately;
do not silently discard scheduling differences or losing samples. The first
integrated attempt preserved all responses but failed its stricter total-call
map gate, motivating snapshots collected outside timed cohorts. This remains
diagnostic evidence, with combined/pressure and quiet acceptance open. Evidence:
`trellis-scatter-integrated-cohort.json` and
`trellis-scatter-integrated-cohort-v2{,-review}.json`.

Sharing activation loads across multiple gate/up output rows per SIMD group
also loses in the k3 M=1 screen. Every tested layout preserves the incumbent
output bytes. One row per group reproduces the incumbent timing; two, four
and eight rows increase complete-MLP time. Reducing the threadgroup to one
or two SIMD groups does not rescue the two/four-row candidates. The original
row mapping remains. Evidence: `trellis-shared-rows-k3-r*-m1.json` and
`trellis-shared-rows-k3-r*-s*-m1.json` in the campaign report directory.

An integer arithmetic rewrite replaces the final byte-pair sum and subtraction
with `as_type<int>(p * 65537u - (510u << 16)) >> 16`. If
`p = a + (b << 16)`, with both byte-pair sums at most 510, this returns
`a + b - 510` exactly. Host exhaustive-state/edge/random checks and all real
k2/k3/k4 M=1/4 operation checks pass. The timing screen gives no useful
additional gain, so the readable existing expression remains. Evidence:
`trellis-y-mad-manifest.json` and `trellis-y-mad-k*-m*.json`.

The activation audit identifies a separate numerical distinction in the
existing Lab path. Its fused kernel uses a float32 precise-exp sigmoid,
whereas compiled MLX uses a dtype-specific abs/exp expression. Real k3 inputs
at M=1/4 differ for bf16 and f32. Applying the old activation independently
to the two projection outputs reproduces the fused result exactly, isolating
the difference to the activation. Earlier small-input tolerance tests did
not establish bit identity here. Existing variant-to-variant identity results
still compare the same packed activation. Changing it requires a separately
declared numerical/quality experiment; no default is changed by this audit.
Evidence: `trellis-activation-audit.json`.

Variant 9 tests evaluation barriers separately. It keeps the variant-8
kernels but lets the three expanded projections remain lazy until the
existing layer-end hidden/state evaluation. The native last-head sweep
preserves logits and live state at all observed lengths. M>4 improves while
peak allocation grows; small M is unchanged. Evidence is in
`reports/qwen38-rd/variant9-full-model.json`, with per-arm memory peaks.
Larger prefill and the frozen long-agent pressure replay remain required.
The default's per-projection barriers remain in place.

The variant-13 follow-up fixes the interleaved artifact and all kernels,
then changes only the returned expanded projection's evaluation. It compares
blocking evaluation, deferral to the existing layer boundary and asynchronous
submission followed by that same layer boundary. All 35 warm/measured cases
at M1/8/16/128/512 preserve logits, live state and continuation. Six balanced
blocks exercise 64 expansion boundaries at M16 and 192 at M128/512; M1/8
have none and are controls. Deferred evaluation reduces median paired time
by 2.46%, 5.15% and 2.03% at M16/128/512; asynchronous evaluation reduces it
by 2.39%, 6.56% and 2.89%. Every affected pair improves. M128/512 peak MLX
allocation grows by about 362/380 MB for deferral and 368/403 MB for async.
These M4 Pro 24 GB diagnostics do not remove the memory gate.
Evidence: `reports/qwen38-rd/trellis-v13-boundary-full-model{,-review}.json`.

The serial HTTP follow-up completes six balanced three-arm blocks with 18
clean server exits, fixed sources and 126 requests. All 84 paired response
texts, usage counts and finish reasons match. At 128/512 prompt tokens,
deferral reduces median paired TTFT by 2.88%/0.53%; asynchronous submission
reduces it by 4.10%/1.41%, with all six pairs improving in each cell. Async
complete-response time falls by 0.90%/0.67%. Six-token TTFT and all decode
cells stay approximately flat. Per-server peak RSS is approximately flat;
the separately measured MLX transient-allocation increase still applies.
Evidence: `trellis-v13-boundary-http-serial{,-review}.json`.

The saved-agent pressure gate rejects unrestricted deferral on this M4.
The synchronous control completes all seven requests, including 14,465 prompt
tokens, 12,953 cached tokens and a 512-token response, followed by a durable
SSD flush and clean exit. Deferral preserves the first five responses but
fails on the sixth request at 12,954 prompt tokens. Native tracing reports
Metal command-buffer insufficient memory and the child exits with SIGTRAP.
Sources remain fixed. The asynchronous and mapped arms had not started;
their outcome cannot be inferred from this failure. Keep per-projection
barriers while testing bounded alternatives. Evidence:
`qwen-long-boundary-serial{,-review}.json` and its deferred server trace.

A fresh synchronous/asynchronous pair reaches the same result. The control
again completes all seven requests with a durable final flush and clean exit.
Async preserves the first five responses, then fails the sixth request with
the same Metal insufficient-memory error. Source fingerprints remain fixed.
Thus both unrestricted alternatives fail this pressure gate despite their
short-prompt timing gains. A further candidate must retain blocking evaluation
when available headroom is insufficient. Evidence:
`qwen-long-async-serial{,-review}.json` and its async server trace.

The next policy submits asynchronously only while MLX active allocation is
below 75% of the device's recommended working set, retaining blocking
evaluation above that ceiling. It still evaluates at the existing layer
boundary. All 35 native warm/measured cases preserve logits, live cache bytes
and continuation. The short native sweep stays below the ceiling and exercises
asynchronous submission at every expanded projection. Median paired time
falls 2.00%/5.40%/3.07% at M16/128/512, with six wins per cell; M1/8 controls
are approximately flat. The short sweep does not exercise the pressure fallback.
Evidence: `trellis-v13-bounded-full-model{,-review}.json`.

The bounded policy also passes a fresh serial saved-agent pair. All seven
responses and usage counts match, both servers exit cleanly, and the final
SSD flush reports durable state with no pending, missing or failed writes.
The candidate submits 1,152 expanded projections asynchronously and evaluates
2,112 synchronously, exercising both branches. Its maximum observed active
allocation is 17.216 GB; the 14.302 GB threshold controls scheduling, not total
allocation. Peak sampled RSS is 13.370/13.743 GB for control/candidate.
This single pair establishes the pressure gate, not a timing or RSS win.
The default scheduler pressure gate remains.
Evidence: `qwen-long-bounded-serial{,-review}.json`.

Six fresh serial HTTP pairs then complete 84 requests with fixed sources,
clean exits and all 42 paired responses identical. The bounded policy reduces
median paired TTFT by 4.42%/1.78% at 128/512 prompt tokens, with six wins in
each cell. Complete-response time falls 0.95%/0.80%; decode speed and the
six-token control are approximately flat. Median per-server sampled peak
RSS is 12.364/12.362 GB for synchronous/bounded evaluation. Each candidate
server exercises 768 asynchronous boundaries in this short sweep. These M4
diagnostics retain the separate native transient-allocation increase and
do not replace the default scheduler or quiet-machine gates. Evidence:
`trellis-v13-bounded-http-serial{,-review}.json`.

The actual continuous-scheduler follow-up completes six pairs and 84 requests.
All 42 paired response texts, usage counts and finish reasons match; each
request reports `"batched"` and increments scheduler submissions. Sources
remain fixed and all 12 servers exit cleanly. Median paired TTFT falls
4.46% at 128 tokens with six wins and 1.30% at 512 with five wins.
Complete-response time falls 0.96%/0.60%. Decode and six-token controls remain
approximately flat; median sampled peak RSS is 12.381/12.352 GB. MLX is seeded
to 42 at startup with greedy sampling; request-level seed is omitted because
it selects serial placement. Evidence:
`trellis-v13-bounded-http-default{,-review}.json`.

The continuous saved-agent gate also passes all seven paired responses with
fixed sources. Every request reports the batched lane and a scheduler
submission. Both servers finish durable SSD flushes with no pending, missing
or failed writes and exit cleanly. The candidate again uses 1,152 async and
2,112 blocking expansion boundaries; maximum observed active allocation is
17.265 GB. Sampled peak RSS is 12.842/12.992 GB for control/candidate.
This one pair closes the prototype's continuous pressure gate, not a timing
or memory-saving claim. Evidence: `qwen-long-bounded-default{,-review}.json`.

The integrated opt-in `MLX_BUN_TRELLIS_ASYNC_EXPAND` now applies that policy
to variant 13. It reads the execution's existing runtime snapshot and caches
only the fixed device threshold per linear layer. It preserves layer barriers
and blocks expanded projections above the threshold. Default remains off;
other variants retain their current behavior. Typechecks, hygiene and all
1,822 model-free tests pass. Integrated native, both short HTTP repeats and both
long-agent pressure gates pass on the M4 Pro. Evidence:
`trellis-async-integrated-{typecheck,hygiene,model-free}.txt`.

The integrated native sweep preserves all 35 logit/live-cache/continuation
cases with fixed sources. An observer records the implementation's own async
and blocking calls without substituting a scheduling decision. Median paired
forward time falls 2.09%/6.19%/2.80% at M16/128/512, with all six pairs
improving. M1/M8 exercise no expansion boundaries; their paired timings are
+1.16%/-0.21%, so the M1 control variation remains visible. M128/512 peak
MLX allocation again grows about 368/403 MB. Integrated serving and pressure
gates remain. Evidence: `trellis-async-production-full-model{,-review}.json`.

The integrated serial HTTP repeat also passes all 42 paired responses across
12 clean server exits with fixed sources. Median paired TTFT falls 4.00% at
128 prompt tokens in all six pairs and 1.43% at 512 in five pairs. Request
wall time falls 0.88%/0.63%; decode and the six-token control remain flat.
Median sampled peak RSS is 12.331/12.355 GB for control/candidate. Each
candidate server exercises 768 async boundaries, with no blocking fallback
in these short prompts. These are M4 Pro diagnostics; pressure and quiet
acceptance remain. Evidence:
`trellis-async-production-http-serial{,-review}.json`.

The integrated continuous repeat passes another 42 paired responses and
12 clean exits with fixed sources. Every request reports the batched lane
and exactly one scheduler submission. Median paired TTFT falls 3.96%/1.40%
at 128/512 prompt tokens, with six/five improving pairs. Wall time falls
0.87%/0.63% in five/four pairs. Decode and the six-token control remain flat.
Median sampled peak RSS is 12.353/12.349 GB. Short prompts exercise the async
branch only; integrated long-agent pressure gates are next. Evidence:
`trellis-async-production-http-default{,-review}.json`.

The integrated serial saved-agent gate preserves all seven paired responses
and usage records with fixed sources and clean exits. Both SSD flushes finish
durably with no pending, missing or failed snapshots and a longest durable
prefix of 14,976 tokens. The candidate uses 1,151 async and 2,113 blocking
boundaries; its maximum observed active allocation is 17.227 GB. Sampled peak
RSS is 13.550/13.544 GB for control/candidate. The longest request prefills
14,465 tokens, reuses 12,953 and generates 512. This is a single pressure
gate under system swap, without a performance or memory-saving claim.
Continuous pressure acceptance remains. Evidence:
`trellis-async-production-long-serial{,-review}.json`.

The integrated continuous saved-agent pair also passes all seven responses,
usage records, source hashes and clean exits. Every request uses the batched
lane with one scheduler submission. Both final flushes are durable, with
14 snapshots, a 14,976-token longest prefix and no pending, missing or failed
writes. The candidate uses 1,152 async and 2,112 blocking boundaries; maximum
observed active allocation is 17.253 GB. Sampled peak RSS is 12.994/12.873 GB
for control/candidate. This completes the integrated M4 pressure gates; the
one-pair RSS difference is not a memory-saving claim. Broader callers, combined
optimizations and quiet M4 Pro acceptance remain. Evidence:
`trellis-async-production-long-default{,-review}.json`.

Variant 10 shares scatter weight decoding and scales across M=2..4 in
`src/model/trellis-shared-scatter.ts`. It uses aligned k3 decoding where
eligible and the incumbent packed-word mapping for other bit widths. Every
output retains its row/FMA order, split boundaries, sum and cast. M=1 uses
the existing variant-8 path; M>4 keeps the projection barriers. Variant 10
does not combine the variant-9 memory experiment.

Real k2/k3/k4 screens improve down and complete-MLP time with exact observed
outputs. Unit checks cover both axes, bf16/f32 inputs, M=1..5 and the complete
MLP. The packed 27B passes exact logits, live state and continuation checks
at M=1..5. Six native A/B blocks against variant 8 improve M=2..4 while M=1
is unchanged. Raw evidence is in `shared-scatter-screen/`,
`shared-scatter-all-screen/` and `variant10-full-model.json` under
`reports/qwen38-rd/`. The native gate accepts
`MLX_BUN_TRELLIS_AB_BASELINE=8 MLX_BUN_TRELLIS_AB_VARIANT=10`.

Variant 11 combines variant 10 with tiled axis-1 prefill at M=5..32.
`src/model/trellis-tiled-prefill.ts` reconstructs bf16 weights in threadgroup
storage and consumes them through SIMD-group matrix operations. Its shared
operation accepts other compatible matrix shapes; automatic experimental
dispatch is limited to the measured 5120-to-17408 geometry, bf16, T=256,
L=12 and k=2/3/4. Down projections keep stock expansion and matmul.
Dense expansion and layer-end evaluation boundaries remain in place.

The initial computed-code prototype failed the full model despite matching
the sampled synthetic matrices. Expansion consumes the precise host LUT,
whereas variant-6 packed matvec uses an unrefined reciprocal. Refining that
reciprocal before scaling reproduces expansion's bf16 weights. The corrected
prototype passes logits, live cache state and continuation at M=1/4/5/8/16/32;
six paired native blocks improve M=5..32 without a larger observed peak.
Evidence: `trellis-tiled-initial-review.json`,
`trellis-tiled-refined-gate-model.json` and its review under
`reports/qwen38-rd/`. The integrated kernel repeats the full-model gate in
`variant11-full-model.json`. Six process A/B blocks per serving method also
improve first-token and complete-request latency on one six-token raw prompt,
with identical output at eight and 64 generated tokens. Serial and continuous
B=1 paths agree; this does not test concurrent users. Evidence:
`trellis-v11-http.json` and its review. Broader native/HTTP workloads, pressure
replay and quiet M4 Pro acceptance remain required. Variant 6 remains the default.

Variant 12 also reconstructs axis-0 weights inside split-K matrix tiles at
M=5..8. The shared `trellis-splitk-prefill.ts` operation follows MLX 0.31.2's
partition geometry, float partials and ordered final sum, then rounds to bf16.
The measured dispatch profile covers 17408-to-5120 matrices at k2/k3/k4.
It avoids the dense down-projection weight allocation. Dense expansion and
layer evaluation boundaries remain. Larger M, wider tiles, padding and a device
lookup table did not give a consistent advantage in the initial sweep.

Other-shape unit checks include transposed inputs and a longer final K
partition. Both the prototype and integrated packed 27B preserve logits,
live state and continuation. Six paired integrated blocks improve M=5/8;
M=1..4/9/16/32 retain their existing path and timing. Evidence:
`trellis-splitk-screen-review.json`, `trellis-splitk-tuning-review.json`,
`trellis-splitk-full-model-review.json` and `variant12-full-model.json` under
`reports/qwen38-rd/`. Combined native and HTTP results are recorded in
decode-speed-program §7; quiet-machine acceptance remains open.

The calibrated operation trace led to a second tile pass. At M=5..8, both
direct kernels now use eight output rows and place all four SIMD groups
across columns. This removes unused row work while preserving each output's
matrix products, accumulation order, weight rounding and split reduction.
Contiguous packed reads with transposed threadgroup writes were slower in
the controlled screen; neither that layout nor padding is retained.

Direct tiles also avoid per-projection evaluation. They keep activations and
bounded partials without constructing a dense weight matrix, so the existing
model layer boundary bounds their graph. Expansion paths retain their original
projection evaluations. A four-arm full-model experiment separates tile
geometry from synchronization: all logits, live cache bytes and continuation
match across six blocks at M=1/4/5/8/16/32/128. The combination improves the
eligible shapes with a small temporary-memory increase. A subsequent six-pair
check at M=5/8 adds the smaller split-K tile with exact outputs and unchanged
peak allocation. These changes remain within the experimental variants;
variant 6 is unchanged. Evidence: `trellis-tile-layout-screen-review.json`,
`trellis-tile-full-model-review.json`,
`trellis-splitk-bm8-other-bits-review.json` and
`trellis-splitk-bm8-full-model-review.json` under `reports/qwen38-rd/`.
The first layout screen also changed evaluation boundaries and is excluded
from isolated-kernel speed attribution. The integrated operation passes
targeted units and ten old/new full-model append lengths. Six subsequent
HTTP process pairs improve actual eight-request throughput and B=1 TTFT,
with identical responses and verified scheduler activity. Evidence:
`trellis-tile-integrated-forward-review.json` and `trellis-tile-http-review.json`.
Six old/new native process pairs also preserve every emitted ID and finish
reason, with lower first-token latency and a small complete-request gain;
single-row decode is unchanged. All workers complete with fixed source hashes.
Evidence: `trellis-tile-native-review.json`. These remain loaded-machine
diagnostics, with quiet M4 Pro acceptance pending.

A corrected larger-prefill sweep checks ten tile geometries, packed-load
orders and threadgroup padding choices on actual k3 gate/down matrices at
M=128 and 512. Every one of the 40 cases reproduces the expansion-plus-matmul
output bytes, but none beats that existing path in six AB/BA timing pairs.
Both arms include output evaluation and GPU synchronization; the candidate
gets no pipeline-only timing advantage. Larger tiles and coalesced packed
loads therefore remain rejected for these measured shapes. Keep MLX's native
matrix multiplication and investigate the separate expansion operation.
Evidence: `trellis-large-prefill-screen.json` and
`trellis-large-prefill-screen-review.json` in the campaign report directory.

A source audit also rejects an assumed fp16 throughput shortcut. In pinned
[MLX 0.31.2 Steel GEMM](https://github.com/ml-explore/mlx/blob/v0.31.2/mlx/backend/metal/kernels/steel/gemm/kernels/steel_gemm_fused.metal),
both half and bf16 instantiations explicitly select float accumulation.
`BlockMMA` loads both input tiles into float matrix fragments before the
matrix multiply. Changing storage dtype alone therefore does not select a
half-fragment multiply in this path. This is a dispatch/arithmetic finding,
not a measured bf16-versus-fp16 performance comparison; other native paths
need their own inspection before making the same claim.

Variant 13 builds on variant 12 with `trellis-vector-expand.ts`: four adjacent
weights share two packed-word reads and the scale. An unrolled loop extracts
their circular windows and refines the computed code value to reproduce the
host f32 LUT before bf16 rounding. MLX's matrix multiplication and each dense
projection's evaluation boundary remain unchanged. The operation is independent
of the model; dispatch requires bf16 output, k2/k3/k4, T=256 and L=12. Other
packing/dtypes retain their existing expansion.

The actual-weight screen passes all 96 configurations across three bit widths
and both projection axes. Four values per thread with 128 threads gives a
consistent isolated improvement. Explicit wider output stores add little in
a subsequent exact 24-case screen and are not retained. The initial full-model
prototype preserves logits, all live cache bytes and continuation in seven
blocks at M=1/8/16/128/512, including six measured AB/BA pairs. Eligible prefills
improve; M=1 and M=8 retain the variant-12 path. The integrated kernel repeats
those checks and passes the repository parity harness, whose variant-13 arm
also exercises larger prefills. All HTTP responses match in two existing-suite
pairs, but their timing is mostly flat; see decode-speed-program §7. Closed
research helpers are removed after recording their results. These are M4 Pro
diagnostics, with the
default still variant 6. Evidence: `trellis-vector-expand-screen-review.json`,
`trellis-vector-store-screen-review.json` and
`trellis-vector-expand-full-model-review.json` in the campaign directory.

The R6 layout screen rearranges groups of coded blocks across input rows,
preserving the codes, payload size, arithmetic and split-K reduction order.
All six actual k3 down-projection layouts invert to the original code bytes
and produce identical output bytes. Two groupings improve the isolated
operation; the original-order control is flat. Both full-model groupings
preserve every eligible matrix's code bytes, logits, live cache state and
continuation, with a small single-token forward improvement. Group two is
simpler and group ten offers no additional model gain. The prototype
retains both layouts to alternate A/B arms, so its additional residency and
packing cost are recorded separately. Six subsequent production-generation
pairs with a fixed seed and 64 outputs preserve every emitted ID, final live
cache byte and continuation logit. The small gain survives the complete
generation loop. Six fresh-server pairs in each of serial and default
scheduling then preserve all 60 paired responses. Both prompt lengths retain
the small decode and complete-request improvement; the default scheduler's
longer-prompt TTFT is approximately flat. All servers exit cleanly, and
telemetry proves the configured execution path. Both arms retain the extra
code copy, so their flat RSS comparison is not a memory improvement. A stored
format usable by every prefill, scatter and expansion reader remains open.
No artifact or production dispatch is changed. Evidence:
`trellis-block-interleave-screen-review.json` and
`trellis-block-interleave-full-model-{g2,g10}-review.json`, plus
`trellis-block-interleave-native-generation-g2-interface-review.json` in the
campaign directory, plus `trellis-block-interleave-http-{serial,default}-review.json`.
The first generation driver used the wrong iterator
interface and failed before timing; its failed report remains separate.

The replacement-layout reader prototype now preserves all 27 actual-matrix
projection cases across bf16/f16/f32 and three dense expansions. It covers
single-token and shared M2..4 scatter, M5..8 split-K and larger dense prefills,
through M512. The operation timings show small-batch gains with marginal
prefill regressions. The first full-model reader check preserves 63 cases,
but its wrapper changes input disposal and output evaluation order. A repeat
with the incumbent order preserves all 35 cases and retains the single-token
gain; M8/16 are approximately flat, while M128/512 are slightly slower.
Changing expansion threadgroup traversal preserves all five operation cases;
moderate row tiles improve that reader slightly, while fully prioritizing
contiguous code reads loses. The revised traversal preserves all 35 full-model
cases, retains the small single-token gain and has approximately flat prefills
in that repeat. The next gate uses a separate stored artifact through serving,
with every reader consuming one resident code copy. Evidence:
`trellis-interleaved-readers-screen-review.json`,
`trellis-interleaved-readers-full-model-count-review.json`,
`trellis-interleaved-readers-order-full-model-review.json`,
`trellis-interleaved-vector-schedule-screen-review.json` and
`trellis-interleaved-readers-schedule-full-model-review.json`. Those prototype
measurements keep both code copies resident; the stored-artifact gate below
removes that extra allocation.

The integrated reader accepts an optional U32 code shape
`[coded_columns / 512, stored_rows, 48]` for k3, T256, L12, 1MAD, axis0.
Each 48-word row holds two original coded blocks; block groups precede rows.
Scales retain their original one-value-per-stored-row representation. The
existing 2D format retains its addressing. Shape validation rejects other
3D geometries, and every scatter/expansion reader selects its address formula
at compile time. Variant 13 also uses the measured moderate row traversal
when rows divide its tile size; other shapes retain the original traversal.
No request, scheduler or state interface changes. Focused tests preserve all
14 variants, bf16/f16/f32 outputs, strided inputs and expansion, with explicit
split-K partition-tail and malformed-format checks. Broader artifact and
serving acceptance remain open; this is not a default artifact change. All three
typechecks, hygiene and the complete model-free tier pass. A separately
written artifact verifies all converted code inverses and every unchanged
tensor payload. Native and HTTP comparisons load one artifact per process,
without runtime repacking or duplicate codes. Closed layout prototype helpers
are removed; their raw reports remain. The first native artifact driver fails
before spawning a child because of an unsupported stdout option; its corrected
file-descriptor version has a separate report. Evidence:
`trellis-interleave-integrated-tests.txt`,
`trellis-interleave-integrated-tail-tests.txt`,
`trellis-interleave-model-free.txt` and `trellis-interleave-artifact-review.json`.
The converter's header padding does not determine the kernel buffer's
alignment. `Weights` uses native MLX safetensors loading, whose pinned
`Load::eval_cpu` allocates its output buffer and reads the payload into it.
The paired kernels therefore consume MLX-owned buffers in both artifacts;
they do not access the file mapping at the tensor's raw header offset.
The packed quantizer's optional `--interleave-codes` switch produces this
layout for eligible tensors, including row-major tensors read through
`--reuse`. Other tensors retain their layout. The shared codec helper only
reorders words; the quantizer records the number of interleaved modules.
Six fresh-process native artifact pairs now preserve all warm/measured
forward logits, live states, continuations and generation IDs. Single-token
and M4 forwards improve in every pair; M8 is slightly slower, M16 improves,
and longer prefills are mixed. Complete 64-token generation improves in every
pair with equal peak MLX allocation. One slower M512 sample remains included.
This removes the prototype's duplicate-code residency from the comparison;
HTTP RSS and timing have their own gate below. Evidence:
`trellis-interleave-artifact-native-fd-review.json` and
`trellis-interleave-encoder-tests.txt`. Native research helpers are removed
after recording the finding; the artifact converter is superseded by the
quantizer's layout option and the retained codec helper.

Six fresh-server serial HTTP artifact pairs preserve all 42 paired responses,
including warmups, usage, finish reasons and stream completion. Each process
loads only its selected artifact, uses production readers at variant 13, and
exits cleanly. Source hashes remain fixed. Decode improves in every measured
pair at each actual prompt length of 6, 128 and 512 tokens; TTFT changes are
small or mixed. RSS is approximately flat, with no retained duplicate code
buffer. These M4 Pro diagnostics use cache-disabled requests and do not
establish cached, pressure or quiet-machine acceptance. Six further pairs
under the default continuous scheduler preserve another 42 paired responses
with clean exits and fixed sources. Telemetry confirms the configured batch
capacity of eight, one submitted row per request and no remaining active or
pending rows. These are single-prompt measurements. Decode improves in every
pair at all three lengths; TTFT changes remain small or mixed, and RSS is
approximately flat. Evidence:
`trellis-interleave-artifact-http-{serial,default}-review.json`.
The completed HTTP research helper is removed; raw responses, telemetry,
source hashes and server logs remain in the reports.

A separate M<=8 crossover prototype improves complete-MLP time at M=5/8
but changes output bytes for every tested bit width. It replaces expanded
bf16 matrix arithmetic with packed f32 code-times-scale arithmetic, so this
is a Lab precision change, not an exact optimization. The prototype is not
retained in production dispatch. `reports/qwen38-rd/m8-screen/` records the
timings and numerical differences. Quality and long-state checks must precede
any use of the larger crossover or equivalent small-chunk span splitting.

# Open items (weights leg — mirrors the PLAN.md phase boxes; PLAN.md owns status)

- **W5 calibration composition** — PLAN sub-boxes W5a (0.8B matrix), W5b
  (allocation axis, pick the best ≤4.5 bpw recipe), W5c (chunked 27B
  production run + gates) remain unchecked in PLAN.md although the results
  above were measured; closing them is a PLAN.md edit, not new work.
  Deferred lever inside W5: learned R (SpinQuant Cayley-SGD) — only if a
  random-R recipe wins first.
- **W6 release — SINGLE REPO:** one artifact = quantized trunk + bf16 vision
  (in-main + optiq sidecar) + folded MTP companion at `mtp/`. Engine landed
  (`--draft-kind mtp` bundled resolution). Publish the winner via
  `mlx-bun upload`; awaiting Josh's go. Card notes owed: M1-vs-M4 3-bit
  speed guidance; MTP not claimed lossless; adapters trained on the artifact
  are rotation-basis-married to it.
- **W6.5 dogfood gate (publish blocker, ahead of W6 upload):** open
  sub-items — `mlx-bun perplexity` on qwen3_5 (SSMCache.advance stub);
  dogfood close-out (re-score a ~30-question GPQA subset through mlx-bun and
  match the mlx-lm scores); 24 GB near-ceiling UX (detect weightsBytes ≈
  default iogpu wired limit and PRINT the sysctl advice up front instead of
  dying mid-request — clamp/advise, never refuse).
- **W7 Pareto frontier (Josh's frame: "we shouldn't operate in a vacuum"):**
  (intelligence × tok/s × memory) for local models on consumer Macs at the
  24 GB and 32 GB budgets, defended against NON-OURS points: ours
  {GPTQ-4bit, TQ-mixed} × mlx-bun; published {OptiQ-4bit, mlx-community
  RTN-4bit} × {mlx-bun, mlx-lm}; cross-ecosystem anchor {GGUF Q4_K_M ×
  llama.cpp/Ollama}. Still owed: quiet-box tps per arm (labeled
  host/chip/RAM), peak footprint + max-context-that-fits per budget, the
  GGUF anchor. The KV axis composes: `--kv-quant turbo` (k8v3) is the
  context-headroom lever at fixed weight bpw. `scripts/turboquant/
  farm-setup.sh` provisions a rented Apple-silicon worker for these runs.
- **Q campaign (sub-4 bpw):** Q3 passed its gate (finding 5); Q2b packed
  format landed and measured (12.1 GiB, KL 0.1550 through the engine, 9.3
  tok/s vs 18.9 on M1 Max — "Q2b measured"); the down_proj axis is settled the
  OTHER way (input-dim coding buys +22% decode but reintroduces the raw-GSM
  EOS cliff, 29/50 vs 44/50 strictly nested — the coded axis must be the
  rotated one). Owed: a 2.75-budget arm
  for the size axis; task columns on q2a/q2b for the ladder's completeness;
  root-cause the rawGSM EOS cliff on the unrotated affine arm. Source bf16,
  all Q artifacts, Hessians live on the external `/Volumes/MLX-Models` volume.
- **Engine follow-up from the M4 rows:** serve should scale
  prefillChunkSize from fit.ts headroom automatically; prefill-rate
  oracle comparison vs mlx-lm same-box.
- **KV-leg projector:** `KvScheme.bytesAt` bills turbo as bf16; a packed-
  layout projector would let admission advertise the real window.
- **Queued post-campaign (GPU owned by certification until then):** DSpark×27B
  Track A (confidence-scheduled verification on the stock MTP head) and
  Track B (multi-token drafter on the TQ trunk; gate: beat MTP's 0.68
  generalizing acceptance or drop); ORPO LoRA on the TQ 27B (QLoRA shape:
  frozen 17 GB base + bf16 adapters; first step a one-layer-backward memory
  probe). Designs live in docs/design/speculative-decoding.md §"27B program".

## Invariants (both legs)

- Rotation never enters the runtime graph for weights; for KV it enters only
  inside the cache class (dequantize-on-fetch or deferred un-rotation at the
  attention site). L1 attention math stays unmodified.
- Quantization groups run along head_dim (KV) — token-axis surgery stays
  byte-safe.
- Oracle-backed at the codec level (KV: vllm-metal goldens; weights: fold
  parity vs stock mlx-lm on the folded bf16 model). Quality of a recipe is
  a measured curve with host/chip/RAM labels, never inferred from ppl alone
  — every finalist needs generative tasks (templated + raw GSM8K).
- Same seed for a trunk and its MTP companion; provenance persisted in
  `optiq_metadata.json`.
- Comparisons are per-bpw-band and paired (same corpus, same items, same
  scorer); no perf claims off a loaded box.

## History

- 2026-06-12 — TurboQuant KV promoted from research path to Phase 13.
- 2026-07-06 — KV v1 landed end-to-end (codec, `TurboQuantKVCache`,
  `--kv-quant turbo`, kv-store persistence, goldens vs vllm-metal); Gate 3
  curve passed on MiniCPM5-1B; deferred inverse FWHT landed same day; the
  weights leg noted as "Future".
- 2026-07-07 — review fixes: spec-lane exclusion (turbo was silently routed
  into speculation), head-dim refusal at server start.
- 2026-08-17 — weights phase opened; W0 Llama fold proof (`rotate.ts`).
- 2026-08-18 — W1 corridor map, W2 streaming fold/quantize at 27B, W3/W4
  curves + TQ-mixed artifact, W5a corrected-GPTQ matrix, W5c v3 27B run,
  FINAL BOARD (v3 staged as mjriii/Qwen3.8-27B).
- 2026-08-19 — territory campaign + THE FRONTIER; W6.5 dogfood gate opened.
- 2026-08-20 — `WeightTransform` seam promoted into production convert
  (`--rotate-weights`, `optiq_metadata.json` provenance); MTP serve lane
  fixed; DeltaNet prefill leak fixed; M4 Pro 24 GB speed rows.
- 2026-08-23 — research scripts moved to `scripts/turboquant/`; this
  consolidated doc.
- 2026-08-31 — Q0 KL-vs-bf16-teacher instrument (both stacks); transformers-5.8
  checkpoint loader.
- 2026-09-01 — Q2 trellis codec + driver, rotation 2×2, Q2c LDLQ, Q3 k-map;
  KL ladder above.
- 2026-09-02 — Q3 full recipe (rot + LDLQ + k-map 3.00) PASSED: KL 0.1553 at
  3.55 bpw, MMLU 88 / tGSM 48 / rawGSM 44; eval-carrier repack tool; LDLQ
  loop-shadow bug fixed.

## Delayed row conversion and reusable precision boundaries

`DelayedTurboQuantKVCache` implements the existing batchable cache and
rotated-value attention ports. It keeps serial row caches during a mixed
plain/TQ phase and invokes the existing maintenance operation before each
row's next append. `KvTensorRows` supplies positions and masks without
dummy tensor planes. Once every row converts, `BatchedTurboQuantKVCache`
owns the encoded rows. The scheduler invokes a generic preparation hook;
it does not implement threshold, codec or inverse-rotation logic.

The rotated-value port can capture an output transform for its fetched
state. Plain value rows pass through unchanged, and TQ rows receive the
existing inverse rotation. Gemma carries that transform through its donor
KV consumers. Model projections and attention remain at B=N. Start-zero
layouts and kernel selection retain their existing paths.

A cache's `minimumReusableOffset` records an irreversible precision
boundary. Delayed maintenance sets it to the actual conversion offset,
which can exceed the configured threshold when a prefill chunk crosses it.
Clone, row extraction and SSD metadata retain the bound. RAM/SSD selection
and ancestor supersession check it independently of physical trimmability.
Earlier plain donors remain reusable after a converted descendant appears.
Old TQ SSD headers lacking the bound conservatively use their stored offset.

Focused tests cover exact mixed-row bytes and output transforms through
reordering, retirement and re-admission, plus RAM/SSD ancestor retention,
restart, continuation and old-header compatibility. Native seeded/logprob
and prefix gates accept positive thresholds via their test environment
switches. Shared Qwen MTP also uses the delayed layout. Its transaction
begins conversion from committed history before verification. A verify block
may cross the configured threshold; resolution converts at the retained
offset after rollback and before checkpoint publication, so rejected tokens
never set the precision boundary.
The draft provider retains its existing paired checkpoint format.

Mixed rollback and final packed promotion preserve each row's physical left
padding. Re-aligning it based on another row's accepted count changes SDPA
reduction positions even when all live cache bytes match. Same-batch native
controls check every target layer and subsequent hidden rows after unequal
acceptance. Affine delayed speculation and the legacy serial TQ speculative
path remain excluded. This implementation changes no defaults.

### Wider split-K verification screen

The current packed down-projection operation covers five through eight input
vectors. An isolated candidate extended that operation through 32 vectors,
using 8-, 16- or 32-row tiles while retaining the native split partition and
accumulation order. Scheduler and speculation policy were unchanged.

Actual 2-, 3- and 4-bit artifact projections pass exact expanded-weight
controls at every new width and three input seeds on both Macs. Full Qwen
logits, recurrent/KV state and continuation match the unchanged eligibility
control at B1/B2/B4/B8 on both Macs. Call-count assertions prove the wider
kernels ran. Updated unit coverage includes wider partition tails and
noncontiguous inputs; both complete suites and typechecks pass.

The alternating M4 prompt-lookup comparison preserves all requests but loses
concurrent throughput. This wider eligibility is not adopted. Future work
needs serving dispatch/cost attribution before additional tile tuning.
Measurements: benchmarks.md. Evidence and source manifest:
`reports/qwen38-closeout/composition-baseline/trellis-batch-width/`.
