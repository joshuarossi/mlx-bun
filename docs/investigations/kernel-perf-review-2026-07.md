# Kernel/perf deep review — 2026-07-01 (condensed, tracked record)

A 25-agent adversarially-verified review of every Metal/fused kernel and
training memory path (7 areas; every suspected bug survived an independent
refutation pass before making this list). Raw structured output (all seven
area reviews + full mechanisms): `reports/kernel-perf-review-2026-07-01.json`
(gitignored, local). This file is the durable record.

## Area verdicts (one line each)

- **flash-CCE head** (steel fwd + H-tiled bwd): done unusually well — verbatim
  vendored MLX steel machinery, exact-by-default backward with autograd + FD
  parity — marred by decision drift: the PLAN-decided 1.35× filter win was
  never landed and the in-code comments argued three contradictory positions
  (comments fixed 2026-07-01; the FLIP itself is still backlog #1).
- **Training flash-attention kernel**: faithful port with exemplary post-bug
  discipline, correctly opt-in — but it copies a naive oracle (~30× slower)
  and its tests covered none of the production configs (extended 2026-07-01:
  D=256, sliding-window, non-tile T; ≥2K e4b revalidation still Josh-gated).
- **Inference fused paths**: disciplined and honest (everything measured,
  gated, losses documented) — one real latent bug (fixed) + the open 26B
  perf-kernel checkbox.
- **Quantized-KV attention**: line-faithful ports, tol=0 oracle gates, no
  materialized dequant on the serving path — optiq's streaming per-layer
  conversion was only half-ported (fixed 2026-07-01) and FUSED_DECODE×
  compiled-decode composes unsafely (OPEN — see below).
- **Training memory machinery (segmented backward)**: the strongest subsystem
  reviewed — the mlx_vjp-per-segment design is the correct primitive, disposal
  exception-safe in all five classes.
- **Metal infra + megakernel learnings**: apply() is careful post-incident
  design; the megakernel was shelved on decisive numbers, but the banked
  "could win at M=K" learning is recorded misleadingly (decode look-again
  agrees: re-word it — mlx amortizes at M=K too).
- **Cross-cutting flags**: unusually disciplined for a 65-flag surface — but
  the --l2 tier promise was violated by its own default (FIXED 2026-07-01:
  perf kernel demoted to --l3) and the v1 batch scheduler lacked the serial
  loop's optimizations (batching-v2 wave, in flight).

## Confirmed bugs — status ledger

FIXED in commit 381382c (2026-07-01): same-ms batch seed collision ·
streaming per-layer KV-quant conversion · segmented compiled-decode mid-step
double-write · --l2 tier violation (perf kernel → l3; evidence: the frozen
"optiq" goldens were mlx-bun's own compat engine, gate was ≥56/64 argmax) ·
generate --l2/--l3 silent L1 degrade · unguarded TRAIN_ATTN=flash on Gemma ·
evalSftLoss error swallowing · tokens_per_sec metric · inverted comments
(gemma4.ts:298, flash-cce filter trio) · silent steel fallback (now warns;
H%128 throw narrowed) · flash-attn test blindness.

STILL OPEN: **FUSED_DECODE=1 inside whole-graph compiled decode** bakes the
tile loop at trace-time N — q-cat adapters grow N per step under shapeless
replay, so the newest KV rows are silently never attended (gemma4-base.ts
quantizedSdpaTiled; deferred for file-ownership at fix time — guard the combo
or make the tile loop trace-safe).

## The ranked optimization backlog (task #12)

1. **[S] Land the coeff filter at eps~1e-5** (+ measure blockMax skip on real
   data) — 1.35× ORPO head backward, ALREADY MEASURED
   (flash-cce-filter-realdata.ts, PLAN.md "filter-on-real-data"); gates:
   E4B=1 rerun + teacher-forced grad fidelity + eps=0 byte-identical.
2. **[M] planSegments full-attention isolation** — e4b@8K ~17.5→10 GB;
   unblocks 8K training on the 24 GB M4 Pro.
3. **[S] Auto-dispatch the training head by M** — exact fused QM head for
   short-M (~1.9×: 481 ms vs 934 ms at e4b M=512), flash only when memory
   demands; both heads already share the fusedRespLogpMean interface.
4. **[S] Fused decode full-capacity KV buffers + activeN** — kills 6
   ensureRowContiguous copies/layer/step; 1-3% @8k, ~4× that at 32k.
5. **[M] Collapse per-token host syncs in the spec/DSpark loop** — ~2γ+1
   round-trips → ~2 per verify cycle; directly attacks DSpark's fixed draft
   overhead.
6. **[M] Pipeline the batched decode loop + clearCache cadence** — folded into
   the batching-v2 wave (docs/design/batching-v2-plan.md).
7. **[S] Enable the 26B perf kernel** (open PLAN Phase E box; oracle frozen).
8. **[S] Bound the SFT segmented head** — replace full-[M,V] responseOnlyCe in
   the segmented head vjp; ~2-4 GB peak on long-response e4b SFT.
9. **[S] Segmented-step overhead pass** — detachLeaf single-copy, one evalAll
   barrier/segment, memoize the CPM5 prefix block-sparse mask.
10. **[M] e4b prefill gap** — profile-first; NOTE: the decode look-again could
    NOT reproduce RESULTS.md's 304-vs-373 row on the M1 Max (no eval-DB
    backing) — re-bench on the M4 Pro before building anything.

## Superseding context: the decode roofline look-again

The review's framing assumed the megakernel post-mortem's "M=1 decode is at
the floor". The follow-up investigation (docs/investigations/
decode-roofline-lookagain.md) OVERTURNED that: only the 12B is at the wall
(~92-93% of measured roofline); CPM5 58-64%, e4b 64-70%, 26B 60-62%, with the
host JS graph build as the #1 recoverable term. Its ranked fixes (CPM5
compiled-decode port; build-ahead graph overlap spike; 26B gather-qmm
bandwidth; e4b dispatch batching) COMPOSE with the backlog above and should be
sequenced first where they overlap.
