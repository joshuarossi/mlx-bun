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
  (comments fixed 2026-07-01; the FLIP LANDED 2026-07-02 — see backlog #1).
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

FIXED 2026-07-02: **FUSED_DECODE=1 inside whole-graph compiled decode** baked
the tile loop at trace-time N — q-cat adapters grow N per step under shapeless
replay, so the newest KV rows were silently never attended. REPRODUCED on e4b
(42 layers traced tile=true at N=17; diverges within 3 tokens then
repetition-loops). The 12B was never affected — its segmented form runs concat
layers as uncompiled js layers. Fix: generate() refuses to compile under
MLX_BUN_FUSED_DECODE=1 (explicit opt-in wins, like LoRA/MoE) + quantizedSdpa
throws if the tiled path is ever selected inside a trace (lands in the
transactional fallback, never silent). Regression in
tests/compiled-decode.test.ts, whose e4b block also now uses the dynamic
snapshot resolver — the old hard-coded hash silently skipped it on this
machine, which is how the combo went unexercised.

NEW BUG (found 2026-07-02 by the backlog-#8 gate test; FIXED in mlx-bun,
UPSTREAM in mlx): **mx.quantized_matmul(transpose=false) returns wrong values
at row count 2 or 3** — relnorm ~0.33-0.39 on our dylib, ~0.98-1.14 on stock
mlx 0.31.2 (oracle venv repro); M=1 and M>=4 exact, transpose=true exact at
every M. mlx's autograd computes dh for a transpose=true head qmm via an
internal transpose=false call at the cotangent's row count, so EVERY training
head silently produced wrong dh for 2-3-token responses, 2-3-token tail
chunks, and tiny prompt spans (f32 ground truth: dh relnorm up to 0.99 at the
affected positions, cos ~0.2). Serving/decode unaffected (transpose=true).
Fix: (a) loss.ts `logitsFromHiddenPadM` pads differentiated head spans to 4
rows (pad cotangents are exactly zero) — applied at all seven head sites;
(b) ops.quantizedMatmul pads direct transpose=false calls (the fused head's
analytic backward). Verified vs f32-dequant ground truth (chunk-4 dh
0.47→0.006) + M-sweeps. Worth filing upstream with the 10-line python repro.

## The ranked optimization backlog (task #12)

1. ~~**[S] Land the coeff filter at eps~1e-5**~~ **LANDED 2026-07-02** — BOTH
   skips default 1e-5 (coeff filter + blockMax block skip; env=0 restores exact).
   All gates run on the M1 Max with real chunk-ORPO data
   (flash-cce-filter-realdata.ts, extended: E4B=1 + blockEps sweep + Vjp
   full-logits fidelity): filter CPM5 0.343%/1.41×, e4b 0.158%/1.70×; blockMax
   skip ~lossless (≤0.004%) and real text DOES go cold (the synthetic probe was
   the artifact) — **combined 1.71× (CPM5) / 3.16× (e4b)**; teacher-forced
   fidelity cosine ≥0.99993, filter adds ≤0.07% over the eps=0 reassociation
   floor (standing test in tests/train-orpo-fused-ce.test.ts). The "eps=0
   byte-identical" gate resolved structurally: eps=0 compiles the identical
   pre-flip kernel, but run-to-run dh is never byte-stable (atomic-add
   reassociation) — byte-replay was the wrong spelling of that gate.
2. ~~**[M] planSegments full-attention isolation**~~ **REFUTED BY MEASUREMENT
   2026-07-02** — built, A/B'd @8K on real chunk rows: ZERO peak win (18.09 vs
   18.02 GB; scripts/experiments/seg-isolation-smoke.ts + MLX_BUN_SEG_MEM_LOG
   phase probes). The §5 cost-model premise is false: mlx's sdpa BACKWARD
   materializes O(L²) scores for EVERY layer (~3.5 GB/layer @8K e4b — the
   sliding window is just an additive mask; sliding pair +7.1 GB ≈ full+sliding
   +7.15). Worst segment = layer count alone, so **segment_size is the whole
   knob: seg1 measures 14.59 GB @8K (+3% step time, loss identical) — which
   DOES fit the 24 GB M4 Pro today, no code needed.** Inter-segment clearCache
   also measured no-effect (watermark is live memory). Real next levers: the
   head vjp's ~3 GB [M,V] spike (backlog #8) and an O(L)-memory attention
   backward (the flash-attention track).
3. ~~**[S] Auto-dispatch the training head by M**~~ **LANDED 2026-07-02** —
   fusedRespLogpMean routes requested-flash batches with M <
   MLX_BUN_FLASH_MIN_M (default 1024) to the exact fused head. Fresh crossover
   sweep (head-dispatch-sweep.ts, M1 Max — the review's 1.9× @M=512 was
   pre-filter-flip): fused wins e4b M=64 1.6× / M=512 1.13×, tie @1024; the
   #1-flip made flash FASTER at long M too (e4b ≥2048; 8K 10.7 vs 13.2 s) on
   top of its memory win. CPM5: fused faster at every M — flash stays a pure
   memory lever there (≥1024 honors the caller's intent). Dispatch proven by
   bit-identical-to-fused loss in tests/train-orpo-fused-ce.test.ts.
4. ~~**[S] Fused decode full-capacity KV buffers + activeN**~~ **REFUTED BY
   MEASUREMENT 2026-07-02** — the variant was built (an int32 activeN input,
   capacity-strided rows, fetch attaches full buffers), gated BYTE-IDENTICAL
   on all three recorded dispatch shapes and perf-oracle-green — and then
   measured SLOWER end-to-end: interleaved in-process A/B on the 12B uniform
   kv4 (tokens identical across arms, M1 Max) gave 24.64 vs 26.18 tok/s @8k
   (0.94) and 23.07 vs 23.83 @22k (0.97) — the "~4× at 32k" scaling is
   refuted too. Two holes in the estimate: the 12B's full-attention dispatch
   shape is KV=1 (H16 D512), where the fetch view is a CONTIGUOUS PREFIX and
   the six-copies model never applied; and kernel-only micro-A/Bs proved
   unstable (±50% run-to-run) — the numbers behind "1-3%" were never
   end-to-end. REVERTED; evidence + re-application recipe:
   scripts/experiments/fused-decode-activen-ab.ts.
5. **[M] Collapse per-token host syncs in the spec/DSpark loop** — ~2γ+1
   round-trips → ~2 per verify cycle; directly attacks DSpark's fixed draft
   overhead.
6. **[M] Pipeline the batched decode loop + clearCache cadence** — folded into
   the batching-v2 wave (docs/design/batching-v2-plan.md).
7. **[S] Enable the 26B perf kernel** (open PLAN Phase E box; oracle frozen).
8. ~~**[S] Bound the SFT segmented head**~~ **LANDED 2026-07-02** — both SFT
   segmented classes now use boundedSftCe (token-chunked Checkpoint head, the
   proven ORPO plumbing; MLX_BUN_SEG_HEAD/MLX_BUN_SEG_HEAD_CHUNK knobs).
   Head-only A/B at e4b M=6000: whole-vocab head 16.60 GB peak vs bounded
   6.60 GB (**~10 GB head-vjp transient eliminated**), loss identical, dh
   relnorm 0.00000; head time +45% (Checkpoint recompute, small share of a
   step). The @8K smoke's short responses were never head-bound (peak set by
   the per-layer sdpa backward — see #2), so its wall peak moved little; the
   win is exactly the long-response regime the review named. Gate test:
   tests/train-orpo-fused-ce.test.ts "bounded SFT head".
   **Landing this exposed a NEW upstream mlx bug (see ledger below).**
9. ~~**[S] Segmented-step overhead pass**~~ **LANDED 2026-07-02** — all three
   fixes: MlxArray.detachCopy (ONE mlx→mlx copy; the old rawBytes+
   fromBytesCopy route was two copies via the JS heap), detachLeaves (ONE
   evalAll barrier per segment's whole vjp set, applied in all six segmented
   backward loops), and a step-shared block-sparse-mask memo for the CPM5
   prefix classes (prefixSharedCaches — makeMask hands out slice views).
   Gate: loss + grads BYTE-IDENTICAL on CPM5-SFT / CPM5-ORPO-prefix / e4b-SFT
   fixed steps. Step time (short-seq fixtures, M1 Max): CPM5 ORPO-prefix
   238→158 ms (−34%), e4b SFT 2065→1272 ms (−38%); e4b @8K flat (GPU-bound,
   as predicted) with peak unchanged (14.49 GB).
10. **[M] e4b prefill gap** — profile-first; NOTE: the decode look-again could
    NOT reproduce RESULTS.md's 304-vs-373 row on the M1 Max (no eval-DB
    backing) — re-bench on the M4 Pro before building anything.

## Superseding context: the decode roofline look-again

The review's framing assumed the megakernel post-mortem's "M=1 decode is at
the floor". The follow-up investigation (docs/investigations/
decode-roofline-lookagain.md) OVERTURNED that: only the 12B is at the wall
(~92-93% of measured roofline); CPM5 58-64%, e4b 64-70%, 26B 60-62%.
**2026-07-02 second correction (lookagain §7):** the "host JS graph build =
#1 recoverable term" part of that verdict was itself wrong — the overlap
spike (decode-overlap-probe.ts, spin-injection + serial anchor) proved the
pipelined loop ALREADY hides the build; wall = GPU step time. The lookagain's
host-side fixes (1a–1d: CPM5 compiled-decode port, build-ahead spike, SharedKv
segmented-compile, 12B concat-phase compile) are refuted or de-prioritized;
its GPU-side fixes (26B gather-qmm bandwidth, e4b dispatch batching, CPM5
KV-path, backlog #4 contiguity, spec decode) are now the ENTIRE recoverable
gap and still compose with the backlog above.
