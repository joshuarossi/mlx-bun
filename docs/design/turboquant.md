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
- `src/server.ts` — startup refusals: `--batch N` + turbo (serial-only);
  head_dim not in `TURBOQUANT_HEAD_DIMS` (fail-fast at `createServer`, not on
  first append — 2026-07-07 review); `--draft-model` + any quantized KV warns
  and those requests decode serially WITHOUT speculation (spec-eligibility
  gate excludes `turboQuant`; the spec loop builds fresh bf16 caches and would
  otherwise silently drop the scheme). `turboQuant` and `kvQuant` are
  mutually exclusive (turbo wins with a warning).
- `src/serve/generation-gateway.ts` — explicit solo-only refusal in
  placement (belt + braces on top of the instanceof exclusion).
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

## KV-leg limits and non-goals (recorded so they don't creep)

- Full-attention layers only; rotating/sliding-window layers stay bf16 (warn
  once, never throw). Head dims outside {64,128,256,512} refused at server
  start.
- Solo-only: no batched TurboQuant (novel Cache class); paged-KV combos are
  refused explicitly.
- No fused quantized-SDPA Metal kernel (remaining fetch cost is
  unpack+gather); no QJL residual stage; no entropy coding (the paper
  declined it too).
- Speculative lane is bf16-KV-only: turbo + `--draft-model` keeps the KV
  scheme and decodes serially without speculation.
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
fixing both = paper GPTQ. Worth an upstream report. Fork:
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

Mirrors the PLAN.md phase: no custom Lloyd-Max weight format / new qmm
kernels; no activation quantization; no runtime weight rotation of any kind
(weights fold offline; online rotation remains the KV codec's job); no
GGUF/AWQ export; group_size > 128.

---

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
