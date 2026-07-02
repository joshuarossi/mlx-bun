# Decode perf "look again" — adversarial re-exam of the M=1 floor claim (2026-07-01)

**Machine:** Apple M1 Max, 32 GB (MacBookPro18,2), `sysctl` verified. All eval-DB
rows are also M1 Max — same box. **All numbers below are directional (session,
loaded-machine caveat); quotable numbers remain benchmark.sh-gated.** GPU idle
verified before every probe (one contaminated bandwidth run was discarded and
re-run; another agent's `bun test` was live during it).

**Mandate:** re-attack the PLAN-archive megakernel post-mortem conclusion —
"mlx per-op decode = 4.62 ms vs ~4.5 ms pure weight-read floor (~0.12 ms
overhead, near optimal)" — the way the ORPO backward was attacked.

## Verdict up front

**The floor claim was wrong.** The ~4.5 ms "pure weight-read floor" for CPM5 was
never derived from measured bandwidth and overstates the true floor by ~70%:

- CPM5 reads **0.694 GB** of weights/token (safetensors-header accounting:
  0.448 GiB layers + 0.198 GiB untied lm_head; the 0.198 GiB embed table is
  row-gathered, not streamed). The old "~1 GB" figure counted the embed table.
- Measured achieved bandwidth on this M1 Max: **~337 GB/s raw streaming read**
  (4 GiB bf16 sum), **~250–295 GB/s in mlx's own `quantized_matmul` GEMV** at
  decode shapes (large matrices). 4.5 ms for 0.694 GB implies 154 GB/s — no
  measurement supports that.
- True CPM5 floor: **~2.6 ms/tok** at GEMV-achieved BW (~2.1 ms at raw-read BW).
  Production-shaped decode measures **4.06 ms/tok**. That is **~64% of the
  measured roofline**, not 97%.

The megakernel was still right to shelve (it was slower for its own reasons),
but "mlx is already at the floor" is false for every model except the 12B.
There is ~1.4 ms/tok recoverable on CPM5 (+35–55%), ~5–7 ms on e4b (+30–50%),
~8 ms on the 26B (+40–60%), and ~3 ms (~9%) on the 12B.

Two inconsistencies in the record corroborate that the old floor was never
measured: `megakernel-perf.ts`'s own comment says "floor ~394 tok/s" (2.54 ms —
0.694 GB at the M4 Pro's 273 GB/s spec sheet), while the post-mortem says
~4.5 ms; and the production eval-DB h2h rows (255–266 tok/s = 3.76–3.92 ms)
were ALREADY faster than the claimed 4.5 ms "floor" when the post-mortem was
written.

## 1. Measured bandwidth (this machine, idle, `decode-roofline-bw.ts`)

| probe | result |
|---|---|
| raw streaming read, bf16 sum 1/2/4 GiB | 299 / 320 / **337 GB/s** |
| qmv 4-bit GEMV 540 MiB (12B tied head) | 2.12 ms → **268 GB/s** |
| qmv 4-bit GEMV 360 MiB (e4b tied head) | 1.31 ms → **289 GB/s** |
| qmv 4-bit GEMV 108 MiB (CPM5 head) | 0.45 ms → **249 GB/s** |
| qmv 8-bit GEMV 60 MiB | **295 GB/s** |
| qmv 4-bit GEMV 32 MiB (12B MLP) | **256 GB/s** |
| qmv 4-bit GEMV 3.8 MiB (CPM5 MLP) | 0.022 ms → **183 GB/s** |
| qmv 4-bit GEMV 1.3 MiB (small qkv) | 0.013 ms → **100 GB/s** |
| bf16 GEMV 113 MiB | **296 GB/s** |
| dependent tiny-op chain (in one eval) | **~10–15 µs/op** incl. host encode |

GEMVs were chained back-to-back inside one eval over distinct matrix copies
(cycling ≥ SLC) — the in-step cost, not eval round-trip latency. Methodology
trap worth recording: mlx is lazy — disposing unevaluated outputs silently
skips their compute; the first draft of this probe "measured" 4.4 TB/s.

So: mlx's `qmv_fast` reaches **74–88% of raw machine bandwidth on large
matrices** and degrades hard below ~10 MiB (fixed per-kernel cost). Small-model
decode is a mix of both regimes.

## 2. Weights + KV bytes per decode token (safetensors headers, exact)

| model | streamed weights/tok | how |
|---|---|---|
| CPM5-1B | **0.694 GB** | 0.448 layers + 0.198 lm_head (untied; embed row-gathered) |
| e4b | **3.536 GB** | 2.547 layers + 0.664 tied head + 0.082 altup; 2.789 GiB per-layer embeds are ROW-gathered; vision/audio 0.891 GiB untouched |
| 12B | **8.860 GB** | 7.255 layers + 0.996 tied head |
| 26B-A4B | **3.444 GB** | 1.597 dense + 0.730 tied head + 8/128 × 14.091 GiB experts (top_k 8 of 128, all 30 layers) |

KV read/token (bf16): CPM5 24.6 KB/pos (24L·2kv·128d); e4b 7 full + 35
sliding@512 (2kv·256d) → 45 MB @600, 154 MB @8k; 12B 8 full + 40 sliding@1024
(8kv·256d) → 236 MB @600, 872 MB @8k; 26B 5 full + 25 sliding@1024 → 147 MB @600.

## 3. Roofline table (floor at 270 GB/s GEMV-achieved; ceiling at 337 GB/s raw)

Measured with `decode-roofline-step.ts` (mirrors generateInner's pipelined
loop; greedy; bf16 KV; clearCache cadence; two passes each; uncompiled arm
unless noted).

| model @ctx | bytes/tok | floor ms (270) | ceiling tok/s (337) | measured ms (tok/s) | GPU ms | host graph ms | read ms | % of floor-roofline |
|---|---|---|---|---|---|---|---|---|
| CPM5 @132 | 0.70 GB | 2.58 | 483 | 4.06 (246) | 3.0 | 1.0 | 0.02 | **64%** |
| CPM5 @4k | 0.80 GB | 2.94 | 424 | 5.03 (199) | 4.0 | 1.0 | 0.02 | **58%** |
| e4b @600 | 3.58 GB | 13.3 | 94 | 18.9 (53.0) | 15.1 | 3.6 | 0.03 | **70%** |
| e4b @600 compiled | 3.58 GB | 13.3 | 94 | 18.1 (55.2) | 16.8 | 1.2 | 0.03 | 73% |
| e4b @8k | 3.69 GB | 13.7 | 91 | 21.3 (46.9) | 17.4 | 3.5 | 0.03 | **64%** |
| e4b @8k compiled | 3.69 GB | 13.7 | 91 | 21.5 (46.5) | 20.2 | 1.3 | 0.03 | 64% |
| 12B @600 | 9.10 GB | 33.7 | 37 | 36.8 (27.2) | 33.0 | 3.4 | 0.03 | **92%** |
| 12B @8k | 9.73 GB | 36.0 | 35 | 37.5–40.9 (26.6–24.4) | 33.2–36.1 | 3.4 | 0.03 | **~93%** |
| 12B @8k compiled | 9.73 GB | 36.0 | 35 | 39.4–41.6 | 37.0–39.7 | 1.9 | 0.03 | (thermal drift muddies the arm A/B) |
| 26B @600 | 3.59 GB | 13.3 | 92 | 21.5–22.3 (46.5–44.8) | 17.3 | 3.7 | 0.02 | **60–62%** |

(12B pass-to-pass drift @8k was ~8% — machine warming across the long runs;
within-run medians are the trustworthy split.)

**The inversion:** the bigger the model, the closer to the roofline. The 12B's
GPU time IS the bandwidth floor (its GEMVs are all in the 250–295 GB/s regime
and its dispatch count amortizes); the small/sparse models leave 30–40% on the
table. The old conclusion was accidentally ~true for the 12B only — it was
derived on CPM5, where it is most wrong.

## 4. Gap decomposition

Per-step wall time = GPU step + host graph build + readback, **serial** (PLAN's
structural finding re-confirmed: async_eval hides only the ~0.03 ms token read,
never the graph build — measured directly in every row above).

**(a) Weight+KV read floor** — §3 table. Dominant everywhere; the only true
"physics".

**(b) GPU overhead above floor** (dispatch gaps + small-GEMV inefficiency +
elementwise/norm/rope kernels):
- CPM5: 0.4 ms @132 rising to 1.0 @4k (KV-append/attention kernels are in the
  100–183 GB/s small-buffer regime).
- e4b: **1.8 @600 → 3.7 ms @8k** — the worst dense offender. 42 layers of
  per-layer-input machinery (gate/proj GEMVs ~1–2 MiB each = the 100 GB/s
  regime, ×42), altup ops, KV-share plumbing → dispatch count several hundred
  per token at ~5–15 µs each.
- 12B: ~0 (at floor).
- 26B: **~4.0 ms** — gather-qmm expert GEMVs: each expert slice is ~3.3 MiB
  (2816×704×3 mats, 4-bit) read at the ~180 GB/s small-buffer rate, ×8 experts
  ×30 layers, plus router argpartition/take chains.
- Corroboration: the dependent tiny-op chain costs ~10–15 µs/op; a ~200–400
  dispatch decode step predicts 2–5 ms of pure serialization if nothing
  overlaps, consistent with the observed overheads.

**(c) Host JS loop** — the single biggest NON-physics term across models:
graph build 1.0 ms (CPM5) / 3.4–3.7 ms (e4b, 12B, 26B) per token, serial with
the GPU. Sampler readback is already free (0.02–0.03 ms, pipelined).
clearCache cadence already mlx-lm-faithful.

**(d) Compiled decode reality check** (suspect d):
- e4b (whole-graph form): graph 3.5→1.2 ms but GPU +1.7 ms (the concat-fetch
  materializes each growing cache's window every step) → net **+3.6% @600,
  ~0 @8k**. The trade is real and grows with context.
- 12B (segmented form): **@600 it compiles NOTHING** — sliding rings only
  enter ring phase at offset ≥ window (1024), and the 8 full-attention layers
  are concat-phase (never compiled) forever. So at short context the default
  MLX_BUN_COMPILED_DECODE=1 delivers zero and the full 3.4 ms host tax stands.
  @8k it halves the host term (3.6→1.9 ms); net effect within thermal noise
  today, historically +0–1%.
- CPM5 / Qwen / 26B-MoE: **no compiled decode exists at all** (gemma4-dense
  gate in generate.ts:512-516). CPM5 pays 25% of its step in host graph build.

## 5. Suspect-by-suspect verdicts (2026-07-01 kernel review)

**(a) Backlog #4 — fused decode kernel's 6 ensureRowContiguous copies/layer/step: CONFIRMED structurally.**
`fused-decode-kernel.ts:227,234` build both kernels with
`ensureRowContiguous: true`; the dispatch site passes step-padded fetch VIEWS,
non-contiguous whenever offset < capacity → mlx copies all six
packed/scales/biases arrays per quantized full-attention layer per step.
Order-of-magnitude at 12B @8k (8-bit KV): ~38 MB/layer × 8 full layers ≈
300 MB/step ≈ 1–2 ms ≈ 3–5% — matches the review's 1–3% @8k and grows linearly
with context. Note this only helps the kv=config arm, which today is SLOWER
than bf16 KV (eval DB: 12B @16k 24.7 vs 27.3; CPM5 209 vs 255) — this fix
narrows the quantized-KV speed tax, it does not move the bf16 headline.

**(b) qmv_fast port → live kernel: NOTHING TO FLOW.** Live weight GEMVs go
through `ops.quantizedMatmul` (gemma4-base.ts:121,198) = mlx's own `qmv_fast`
— the thing the megakernel port was catching up TO (0.70→0.94x, never above
1.0). The live perf kernel (fused SDPA) already uses the same quantized.h qdot
pattern (fused-decode-kernel.ts:47-55 comment, predates the megakernel per
PLAN.md:1109-1130). Review's claim verified correct; no action.

**(c) "Megakernel could win at M=K": AGREE WITH THE REVIEW — recorded
misleadingly.** The post-mortem's own numbers show the megakernel losing at
M=1 even with zero barriers (4.95 vs 4.62) on the atomic-coherence tax and a
0.94x GEMV. At M=K, mlx ALSO amortizes: the live spec-decode verify is already
one batched forward sharing the weight read, and mlx's steel GEMM kernels are
strongest exactly at small-M GEMM. Nothing measured supports the megakernel
overtaking at M=K. The banked learning should read: "M=K amortizes the
per-forward fixed cost for ANY engine; the megakernel's specific coordination
primitives were measured net-negative." The real M=K lever is the small-L
flash-decoding SDPA kernel (review opportunity) + spec decode.

**(d) Compiled decode: see §4(d).** On by default where applicable, but it
delivers far less than its billing: nothing at 12B short-context (window
phase-gating), a wash on e4b @8k (concat tax), absent on CPM5/MoE. The 3.4 ms
host term it was built to kill is still ~85–100% alive at short context.

**(e) e4b prefill gap: NOT REPRODUCIBLE ON THIS MACHINE — the RESULTS.md row
is suspect, profile on the other laptop before building anything.**
- RESULTS.md says e4b prefill 304 (ours) vs 373 (mlx-lm). This machine's eval
  DB has NO such rows (e4b prefill rows: ours 505–725 tok/s @600–16k; the only
  oracle e4b rows are @24–31 ctx where "prefill tok/s" is meaningless).
- Measured today, same prompt, this machine: ours 689 tok/s @3266 (probe,
  in-process), mlx-lm 715–763 tok/s @3266 (two runs, cross-process). Gap ≈
  −4 to −10% directional, thermally muddy — nowhere near −20%.
- Flag arms @2048: FUSED_GELU=0 changes prefill ~nothing (2.31→2.36 s) but
  costs −7% DECODE (18.4→19.9 ms — the fused GeGLU is a decode win); fused
  SDPA off: no prefill change.
- Conclusion: the 304/373 row most likely came from the M4 Pro or a stale
  build. Re-benchmark there before spending on backlog #10. (Also noted: the
  oracle venv's mlx-lm cannot even load the 12B — `gemma4_unified not
  supported` — so the 12B baseline rows came through some other path.)
- Bonus decode observation while pairing: mlx-lm e4b decode measured 61.3
  tok/s over 8 tokens but 34.0 tok/s over 64 tokens in back-to-back runs —
  cross-process decode comparisons at this granularity are thermal noise;
  trust the recorded paired result (−5% @short) and the in-process split.

## 6. Ranked fix plan (estimated wins are directional, this machine)

1. **Kill/hide the serial host graph-build tax** — the largest cross-model,
   non-physics term (CPM5 25%, e4b 17%, 26B 17%, 12B 9% of step):
   1a. **CPM5 (and Qwen): extend CompiledDecode beyond gemma4.** CPM5 is
       dense, no per-layer inputs, no MoE — the EASY shape (whole-graph, no
       concat-tax caveat beyond growing KV, same as 12B's ring layers after
       window). Worth ~0.8 ms/tok ≈ **+20–25% CPM5 decode**. Effort M.
   1b. **Research spike: overlap graph build with the GPU instead of
       compiling it away.** Today asyncEvalAll(step n+1) blocks until step n
       drains and the build happens outside that window. If the build of step
       n+2 can run while step n's buffer drains (build-two-ahead, or move the
       blocking wait off the loop thread), the host term hides under the GPU
       for EVERY model with zero numerics risk — this would also beat mlx-lm's
       loop, which pays the same serial cost (their pybind build is just
       cheaper). Effort S to spike, M to land. **This is the "no way we can't
       be faster" candidate.**
   1c. **e4b: SharedKv segmented compile plumbing** (already-scoped review
       item) so e4b gets graph 3.5→~1.2 without the whole-graph concat tax:
       ~**+10–12% e4b**, more at long context. Effort L.
   1d. **12B short-context: compile the concat phase too** (or accept 1b as
       the fix). The current segmented form compiles nothing below the 1024
       window and never compiles the 8 full-attention layers. ~+9% @600.
2. **26B GPU overhead (~4 ms/tok over floor):** profile gather-qmm expert
   reads (each expert slice ~3.3 MiB → the ~180 GB/s small-buffer regime);
   candidates: expert-contiguous layout so 8 experts read as fewer/larger
   spans, the open perf-kernel enablement (review #7, +1–3%), router-chain op
   fusion. Potential **+15–25% 26B decode** if expert reads reach big-GEMV
   bandwidth. Effort M (profile first).
3. **e4b GPU overhead (1.8–3.7 ms):** dispatch-count reduction on the
   per-layer-input machinery (the ~1–2 MiB gate/proj GEMVs and altup
   elementwise chains; batch the 42 per-layer gate GEMVs into one [42·width]
   GEMM where semantics allow). **+8–15% e4b.** Effort M–L.
4. **Backlog #4 (ensureRowContiguous full-capacity buffers + activeN):**
   validated; ~3–5% on the kv=config arm @8k, ~4x that @32k. Small, safe,
   makes quantized KV stop losing to bf16 on speed. Effort S.
5. **CPM5 @4k KV-path overhead (GPU 3.0→4.0 ms while KV adds only 0.35 ms of
   bytes):** the attention/append kernels at CPM5's small KV shapes run in the
   ~100–180 GB/s regime; candidates: the existing fused-decode kernel path for
   CPM5 (currently gemma-shaped sites only?) or upstream sdpa-vector tuning.
   ~+10% CPM5 @4k+. Effort M (profile first).
6. **Spec decode (M=K)** remains the only lever that beats the 12B's
   bandwidth wall (weight read shared across K tokens) — unchanged priority,
   now with the roofline to prove why nothing else can.

## Probes added (scripts/experiments/, tsc-clean)
- `decode-roofline-bw.ts` — machine bandwidth: raw read, decode-shaped qmv
  GEMV (multi-copy, one-eval chaining), bf16 GEMV, dispatch chain.
- `decode-roofline-step.ts` — factory-generic pipelined decode split
  (graph/dispatch/read) with `--compiled` arm, any model/context.

## Standing-rule notes
- Pre-existing tsc error in `src/eval/runner.ts:161` (kvBits on a Pick union)
  in Josh's working tree — not introduced here, not fixed here (outside the
  edit boundary for this task).
- RESULTS.md "Direct" table's e4b prefill row contradicts this machine's eval
  DB (no supporting rows) — per the verify-against-evaldb rule it needs a
  machine label or a re-run on the M4 Pro.
