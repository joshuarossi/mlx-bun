# mlx-bun benchmark results (curated)

The durable, hand-maintained benchmark record. Raw per-run files
(`benchmarks-h2h-<date>-<machine>.md/.html`) are gitignored ephemera; the
structured backing record is the user-local eval DB
(`~/.cache/mlx-bun/evals.sqlite`). Promote a run into this file
deliberately when it becomes the new reference.

The optional `mlx-bun-isolated` arm runs the same CLI/model/request cells through
`--isolate`; select it alongside `mlx-bun` to compare transport cost. Its RSS
column sums the parent and descendant processes. This is aggregate process RSS,
not deduplicated physical memory; shared runtime pages may appear in both.

## Running the benchmark

`bun scripts/bench-serve.ts all` is THE benchmark — one pass, real servers,
real paths, every number that matters. Per model × arm (mlx-bun@defaults ·
mlx-bun `--batch 1` [the control arm — `--no-serial` skips] · mlx-lm ·
mlx-bun-mixed · optiq-mixed) it measures decode tok/s (spread/stability
policy), TTFT cold (~1k, nonce-busted) and warm/cached (each stack's own
prompt cache), prefill tok/s, long-context prefill/TTFT/decode (ONE measured
prefill; decode sampled on 64 tok + 2 cached repeats), aggregate tok/s at 4
concurrent streams, peak RSS (sampled; undercounts GPU), and load→ready time.
From the SAME cells it checks BIT PARITY: a fixed greedy 64-token probe must
be byte-identical between stacks of the same scheme (mlx-bun vs mlx-lm;
mixed vs optiq; unified engine vs `--batch 1`), with prompt_tokens equality
doubling as a chat-template-parity check.

```sh
bun scripts/bench-serve.ts all                       # cpm5 + e4b + 12B + Qwen3.8-27B, all arms
bun scripts/bench-serve.ts all --no-serial           # skip the --batch 1 control arm
bun scripts/bench-serve.ts all --models cpm5,qwen27b # subset
bun scripts/bench-serve.ts all --skip-context        # drop the long-context leg
bun scripts/bench-serve.ts all --context 8192        # shorter context leg
```

`all` runs the clean-machine preflight first (refuses headline numbers from
a loaded or swapped box) and holds `caffeinate` for the pass. Quotable
ABSOLUTE numbers need a quiet machine (reboot, nothing open); parity verdicts
and ratios survive a dirty one. Results land in the eval DB
(`~/.cache/mlx-bun/evals.sqlite`) plus a dated markdown report (gitignored;
move it to `reports/`). Developer lever A/Bs are NOT benchmarks — run
`scripts/bench-levers.ts <faithful-matrix|fused-prefill|compiled-decode>` or
`scripts/bench-matrix.ts <modes|features>` directly when touching those paths.

There are **three categorically different kinds of measurement** — kept in
separate sections because they answer different questions:

1. **Parity** — are we *bit-exact* with the upstream oracle? (pass/fail)
2. **Performance** — *numbers* under like-for-like config (tok/s, memory…).
3. **Quality** — for non-bit-exact optimizations, what does the speed cost
   in output quality? (6-test mean + KL)

**Default machine for older rows:** Apple M4 Pro, 24 GB unified
(`Joshs-MBP-2025`), ~273 GB/s. Newer subsections name their machine explicitly.
**Oracle toolchain:** Bun 1.3.14; Python 3.13.5 with mlx 0.31.2,
mlx-lm 0.31.3, mlx-optiq 0.2.1. Numbers below are the 2026-06-14
cleared-machine run (commits `97457e4` / `d1e0296`), preflight-gated,
median-of-N with warmups discarded.

**Model legend** (registry hash → repo):

| hash | model |
|---|---|
| `664aabaed233` | `MiniCPM5-1B-OptiQ-4bit` (sub-GB starter) |
| `fcdb12d740cd` | `gemma-4-e4b-it-OptiQ-4bit` |
| `5b1101065d20` | `gemma-4-12B-it-OptiQ-4bit` |
| `dbfd2a779b03` | `gemma-4-26B-A4B-it-OptiQ-4bit` (MoE) |

> **Legend corrected 2026-06-15.** An earlier revision had the gemma
> hashes cycled (`5b…`→e4b, `dbfd…`→12B, `fcdb…`→26B). The mapping above is
> the authoritative one from `tests/support/paths.ts` (`SNAPSHOT`=`5b…`=12B,
> `SNAPSHOT_26B`=`dbfd…`=26B) and the e4b snapshot hash used across
> `tests/*.test.ts` (`fcdb…`=e4b), corroborated by on-disk weight size
> (e4b 7.0G · 12B 8.4G · 26B 18G). The **Performance** rows below were
> labeled by the old legend; each gemma row has been relabeled to its true
> model, re-identified by its gen-peak / steady-RSS fingerprint —
> e4b≈6.6 GB, 12B≈9.0 GB, 26B≈17.7 GB — which is stable across runs. The
> row *data* was correct; only the model labels moved.

---

## 1. Parity (porting correctness) — bit-exact vs the oracle

The correctness oracle. Each cell is **bit-for-bit** logit parity against
the upstream reference under matched config, proven by the test suite
(regenerated only by `scripts/regen-*.ts` against the oracle venv). This
is the gate the Performance/Quality numbers are only meaningful *under*.

| model | L1: mlx-lm, standard (bf16) KV | L2: mlx-optiq, mixed-precision KV | proof |
|---|---|---|---|
| MiniCPM5-1B | ✓ 100/100 logit vectors | ✓ 100/100 logit vectors | `tests/parity/minicpm5-parity.test.ts`, `tests/parity/minicpm5-kv-parity.test.ts` |
| gemma-4-e4b | ✓ | ✓ | `tests/parity/parity.test.ts`, `tests/parity/kv-quant.test.ts` |
| gemma-4-12B | ✓ | ✓ | `tests/parity/parity.test.ts`, `tests/parity/kv-quant.test.ts` |
| gemma-4-26B | ✓ | ✓ (mixed per-layer scheme) | `tests/parity/parity-26b.test.ts`, `tests/parity/rotating-kvq.test.ts` |

Fused quantized-attention prefill is separately bit-exact against
optiq's reference (`tests/parity/fused-sdpa.test.ts`).

### GLM-5.2 direct-Colibri oracle closure — M1 Max 32 GB

The direct-container port uses pinned Colibri, rather than mlx-lm, as its
implementation oracle. The public artifact is
`mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp@3cc8db9`; direct component and
G0 controls use Colibri `44e489b`, while the later official DSA replay is
pinned to `ecade075` with indexers sourced from
`zai-org/GLM-5.2-FP8@ba978f7d`.

| gate | result | durable proof |
|---|---|---|
| tiny converted Q4 trajectory | 32/32 greedy tokens exact with `IDOT=0`; all 8,192 logits max abs `1.3113e-6`, RMSE `2.7423e-7` | `fixtures/colibri-glm52/tiny-teacher-forcing.json` |
| production Q4/router cells | layer-0 SwiGLU max abs `5.2387e-9`; layers 3/77 exact ordered top-8 | `fixtures/colibri-glm52/production-probe.json` |
| real-model oracle | 140 GLM/MLA/router/MTP/KV records reproduced byte-for-byte twice; both heads predict teacher token 16 | `fixtures/colibri-glm52/real-model-oracle.json` |
| full target trajectory | all 128 cold/warm, MTP-on/off target token IDs identical; first 64 also match direct Colibri | machine-local `runs/colibri-g5/summary.json` |
| first-sparse DSA | all 21 official score rows replay to exact ordered positions and float32 thresholds at context 2,049; both engines emit `[264,264]` | `~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/` |

These are quality-preserving gates: checkpoint precision, true top-8 routing,
and the 21-full/57-shared DSA schedule remain unchanged. Consequently there is
no KL/eval tradeoff row in section 3 for this path.

**Served-surface parity (2026-07-07, prefill tail-split fix):** the two
serve-bench parity residuals (cpm5 + 12B `/v1/completions` probe ✗ on the
07-07 run) are closed — with the oracle's step-0 prefill convention
adopted (drain to len−1, step 0 from an L=1 forward of the last prompt
token; `MLX_BUN_PREFILL_TAIL_SPLIT`), live HTTP probes are
**byte-identical** to `mlx_lm.server`/optiq serve for MiniCPM5-1B,
gemma-4-e4b, AND gemma-4-12B, on completion + chat probes, in both the
unified (`--batch 8` default) and `--batch 1` lanes; script-level A/B
shows 64/64 token ids + top-2 logprob values identical per step
(`serve-parity-probe.ts (deleted; git history)`,
`step0-top2-dump.ts (deleted; git history)`).

---

## Methodology change (2026-07-05)

The primary benchmark is now **`bun scripts/bench-serve.ts all` → `scripts/bench-serve.ts`**:
real servers on real paths — the mlx-bun arms spawn the ACTUAL CLI at its
actual defaults (the old harness used a bench-local wrapper, since deleted),
and every metric arrives over HTTP as a user would see it. One server per
cell yields: decode tok/s, cold TTFT (~1k, nonce-busted), warm/cached TTFT
(each stack's own prompt cache), prefill tok/s, long-context
prefill/TTFT/decode (ONE measured prefill; decode sampled on 64 tokens),
aggregate tok/s at 4 concurrent streams, and load→ready time. Context
lengths are recorded from usage.prompt_tokens (measured, not requested).
Engine-level questions (in-process kernel parity, gen-peak memory,
kill-switch A/Bs) live behind `bun scripts/bench-serve.ts all --engine`. Numbers below this
note predate the redesign; the next quiet-machine pass supersedes them.

## 2. Performance — like-for-like numbers

Two comparison axes: **vs the oracles**, and **our optimized path vs our
own bit-exact compat path** (does an optimization beat the baseline it
diverges from). Within mlx-bun, `bf16` is the L1-compatible path and
`mixed` is the L2-compatible path; both are bit-exact, so the bf16↔mixed
delta is the first "our-vs-our" axis. Lab experiment rows (no external
oracle; KL/eval-gated) land here once one beats the L1 baseline in a
paired A/B — none recorded yet (the 2026-07-05 candidates were deleted).

### Current standard serve matrix — M1 Max 32 GB (2026-08-22)

Real-server HTTP matrix on commit `4103ae1`, with the canonical preflight
passing at the start of both runs: zero swap, ample free memory, and no large
foreign process. The Qwen extension ended with 944 MiB of inactive swap,
below the harness's 3 GiB mid-run rejection threshold. No benchmark phase
failed. Raw gitignored reports:
`benchmarks-serve-2026-08-22-Joshs-MacBook-Pro-2.md` and
`benchmarks-serve-2026-08-22-Joshs-MacBook-Pro-2-qwen27b.md`.

| model | arm | short decode tok/s | decode @ ~15.8k tok/s | aggregate ×4 tok/s | restart TTFT ms (cached tokens) |
|---|---|---:|---:|---:|---:|
| MiniCPM5-1B | mlx-bun | **267.7** | 122.0 | **420.1** | 207 (15,817) |
|  | mlx-bun serial | 266.4 | 124.6 | 245.9 | 182 (15,889) |
|  | mlx-lm | 179.7 | 96.2 | 181.4 | 10,355 (0) |
|  | mlx-bun mixed | 194.2 | **127.0** | 397.5 | **130 (15,815)** |
| gemma-4-e4b | mlx-bun | **61.5** | 43.7 | 20.7 | 18,863 (4) |
|  | mlx-bun serial | **61.5** | 43.1 | 59.7 | **661 (15,940)** |
|  | mlx-lm | 52.8 | 42.8 | 72.3 | 20,187 (0) |
|  | mlx-bun mixed | 57.3 | **49.0** | **97.4** | 20,510 (0) |
| gemma-4-12B | mlx-bun | **29.6** | 28.3 | 5.6 | 85,180 (4) |
|  | mlx-bun serial | **29.6** | **28.4** | 27.5 | **1,338 (15,866)** |
|  | mlx-lm | 27.1 | 25.8 | 32.5 | 89,504 (0) |
|  | mlx-bun mixed | 28.7 | 24.4 | **38.7** | 93,068 (6) |
| Qwen3.8-27B winner | mlx-bun | **18.5** | 16.5 | 19.3 | 173,215 (0) |
|  | mlx-bun serial | **18.5** | **16.7** | 15.8 | 172,400 (0) |
|  | mlx-lm | 16.5 | 14.9 | 18.3 | 177,066 (0) |
|  | mlx-bun mixed | 18.1 | 14.9 | **19.4** | **3,328 (15,112)** |

- All four models passed 64-token greedy completion and chat parity for
  mlx-bun bf16 versus mlx-lm, and unified scheduling versus `--batch 1`.
- Qwen's standard mlx-bun arm beat mlx-lm by 12.1% at short decode and
  10.7% at long-context decode. The mixed arm did not beat bf16 on decode;
  its useful result was restoring the full 15,112-token cache after restart.
- The e4b and 12B unified arms restored only four cached tokens after restart,
  while their serial controls restored the full cache. This is a real
  scheduler/SSD-persistence regression and explains their poor aggregate rows.
  Qwen bf16 restored no cache in either scheduler mode.
- Qwen mixed KV is a Lab characterization, not an L2 correctness claim. Its
  policy is copied from the official same-topology Qwen3.6 OptiQ artifact;
  Qwen3.8 has no model-specific mixed-KV oracle yet. Its 15,278 MB sampled peak
  RSS also failed the harness's `mixed < bf16` diagnostic, so the run proves
  that the policy loads and serves, but not that KV quantization was effective.

#### Bun 1.4.0 repeat

The full matrix repeated after upgrading from Bun 1.3.14 to 1.4.0. Starting
state was 401 MiB inactive swap, 93% free memory, load 3.7, and no large
foreign process, which passed the canonical preflight. All completion, chat,
and unified-versus-serial parity probes passed again. Core mlx-bun performance
was stable; the largest one-run movements were MiniCPM aggregate +5.0% and
Qwen long-context decode +3.0%, neither promoted as a Bun speed claim without
repeats.

| model | engine | short decode tok/s | short prefill tok/s | long decode tok/s | warm TTFT ms | aggregate ×4 tok/s |
|---|---|---:|---:|---:|---:|---:|
| MiniCPM5-1B | mlx-bun | **265.8** | **2,576** | **124.2** | **26** | **441.3** |
|  | mlx-lm | 177.0 | 1,907 | 96.5 | 86 | 185.8 |
| gemma-4-e4b | mlx-bun | **61.7** | **868** | **43.1** | **39** | 21.2 |
|  | mlx-lm | 52.4 | 676 | 42.5 | 268 | **72.4** |
| gemma-4-12B | mlx-bun | **29.7** | **191** | **28.4** | **77** | 6.0 |
|  | mlx-lm | 26.7 | 181 | 25.3 | 388 | **33.4** |
| Qwen3.8-27B winner | mlx-bun | **18.6** | 64 | **17.0** | **116** | **19.5** |
|  | mlx-lm | 16.5 | **85** | 14.8 | 284 | 18.6 |

The e4b and 12B aggregate losses remain contaminated by the SSD durability
race. Their unified arms restored 2 and 4 tokens; serial restored 15,939 and
15,794. Qwen's short-prefill loss is different: both mlx-bun schedulers lose
at the roughly 754-token shape, while sustained prefill reaches 87 tok/s at
15.1k versus mlx-lm's 88. This points to fixed graph-build or shape overhead,
not a slower sustained prefill kernel. Split timing is still required before
assigning the cause.

### Colibri G1/G3 component matrix — M1 Max 32 GB

Cleared-machine run on 2026-07-30, commit `47c4d6d`, Bun 1.3.14, pinned
Colibri `44e489b`, public artifact revision `3cc8db9`, ten warmups and fifteen
measured samples. Values are synchronized median milliseconds at identical
production shapes; every arm passed its correctness oracle. These are
component timings, not end-to-end generation claims.

| production-shape cell | direct Colibri Metal | selected mlx-bun path | decision |
|---|---:|---:|---|
| Q4 dense decode M=1 | 0.302 | 1.372 stock MLX | stock MLX (only mlx-bun dense candidate) |
| Q4 dense prefill M=32 | 1.286 | **1.030 stock MLX** | stock MLX |
| routed SwiGLU decode, top-8 M=1 | **1.401** | 4.282 custom Metal | custom Metal; 16.0% faster than stock MLX's 5.099 ms |
| routed SwiGLU ragged M=11/23 experts | **10.851** | 18.100 stock MLX | stock MLX |
| routed SwiGLU prefill M=32/64 experts | **32.906** | 45.558 stock MLX | stock MLX |
| absorbed MLA decode, position 128 | **1.014** | 11.506 stock MLX | stock MLX; largest remaining component gap |

For the selected custom decode path, max absolute delta versus stock is
`2.33e-9`, relative RMSE `5.56e-7`, and cosine
`0.9999999999998354`. A separate three-warmup/eleven-sample run also selected
custom Metal by 5.4%. Swap was unchanged at 339.25 MiB. Matched idle-power
arms (baseline, 1, 2, and 4 native workers, repeated in reverse order) show no
monotonic CPU/GPU/package-power increase, proving the condition-variable
workers are passive; two workers remain the default. Raw gitignored reports:
`runs/colibri-g1/*matrix*-2026-07-30.json` and
`runs/colibri-g1/passive-worker-power*-2026-07-30.json`.

### Colibri G4 serial native MTP — M1 Max 32 GB

Production-artifact separate-process A/B on 2026-07-30, Bun 1.3.14, pinned
Colibri `44e489b`, public artifact revision `3cc8db9`, greedy gamma=3, 32-token
prompt and 64 generated tokens. Both arms reproduced the same direct-Colibri
64/64 target-token trajectory. Generation wall time is the comparison metric;
the probe's prefill/decode sub-buckets place the first sample on different
sides of that boundary and are therefore not compared.

| arm | generation wall | wall throughput | target/verify forwards | draft acceptance |
|---|---:|---:|---:|---:|
| MTP off | 834.172 s | 0.0767 tok/s | 63 continuation | — |
| MTP on | **675.654 s** | **0.0947 tok/s (1.235x)** | **31 verify (32 saved)** | 32/92 |

MTP-on emitted 2.065 tokens per verify forward and reduced end-to-end
generation time by 19.0%. Its direct-oracle acceptance prefix was exact for
the tie-free first four rounds `[1,1,1,0]` (eight emitted tokens; minimum
first-draft margin 3.5675). Later acceptance is intentionally non-gating
across engines because direct Colibri's float64 RMSNorm reduction and MLX's
float32 graph produce different recurrent MTP hidden states while preserving
all target tokens. The machine was not swap-cleared, so the
14,679,224,320-byte completed MTP-on physical footprint is not a G5 memory
claim. Stable record:
`fixtures/colibri-glm52/g4-native-mtp-e2e.json`.

### Colibri G5–G7 full-model productization — M1 Max 32 GB

Final curated result for the streamed runtime. Bun 1.3.14, 32 GiB unified
memory, 25 GiB process ceiling, batch 1, 4,096-token supported context, 128
generated tokens, greedy decoding, true top-8, and quality-preserving defaults.
The G5 before/after run is 2026-08-15; G6 learning telemetry is a three-repeat
paired run on 2026-08-16; the DSA and API gates are 2026-08-17.

#### Resource contract

The current artifact-aware preflight, including the locally installed stock
DSA indexer overlay, reports:

| resource | bytes | GiB |
|---|---:|---:|
| full artifact on disk (streamed, not resident) | 383,739,826,712 | 357.39 |
| resident non-expert weights + DSA indexers | 11,074,469,760 | 10.31 |
| main Q4 expert slab (139 slots) | 2,632,646,656 | 2.45 |
| MTP Q8 expert slab (25 slots) | 945,356,800 | 0.88 |
| target + MTP compressed KV | 789,577,728 | 0.74 |
| reconstructed KV + verify + allocator/Bun/safety reserves | 5,910,612,992 | 5.50 |
| **planned process** | **21,352,663,936** | **19.89 / 25.00** |
| **process/macOS headroom** | **5,490,881,664** | **5.11** |

The original G5 measurement preceded the 197,202,400-byte stock indexer
overlay and planned 21,111,440,128 bytes. The overlay raises the current
preflight by 241,223,808 bytes but does not alter the short-context trajectory
or the observed G5 footprints below.

> **Measurement outcome:** the requested before/after observation closed the
> 32 GB fit question, but did **not** satisfy the harness's stricter
> zero-compression/zero-swap contract. Peak physical footprint stayed at or
> below 14,807,789,616 bytes (13.791 GiB), while maximum system/task compressor
> growth was 4,402,905,088 / 1,939,537,920 bytes; MTP-off observed 7,143,424
> bytes of swapout and MTP-on observed zero. The source result is correctly
> labeled `observed`, not `pass`.

#### Cold/warm MTP and memory

| arm / turn | decode tok/s | end-to-end tok/s | final physical footprint |
|---|---:|---:|---:|
| MTP off · cold | 0.1330 | 0.1274 | 13,490,515,008 B |
| MTP off · warm | 0.1190 | 0.1139 | 13,510,634,560 B (+19.2 MiB) |
| MTP on · cold | 0.1557 | 0.1456 | 14,673,342,512 B |
| MTP on · warm | **0.1577** | **0.1487** | 14,697,574,448 B (+23.1 MiB) |

MTP-on accepted 72/166 drafts over 56 verify forwards on each turn. Warm
end-to-end throughput was 1.306x MTP-off. It is also only 55% of the rounded
same-machine direct-Colibri MTP-on control (0.27 tok/s), and 0.1487 tok/s is
7.43% of the aspirational 2 tok/s target—a **13.45x** remaining gap. The
aspiration is not a release gate or a `fit` prediction.

#### Expert delivery and policy decisions

The replicated G6 control's median warm turn read exactly
1,974,949,363,712 logical bytes from the expert artifact, or
15.429291904 decimal GB per generated token. Its hit rate was 1.6597%; median
main-tier disk-service p95 was 90.98 ms, foreground-wait p95 92.66 ms, and
expert-layer-forward p95 167.84 ms. This is the measured reason the runtime is
disk/serialization-bound rather than compute-bound.

| MTP-on policy (three paired repeats) | warm hit rate | disk GB/token | warm e2e tok/s | decision |
|---|---:|---:|---:|---|
| control | 1.66% | 15.429 | **0.149** | default |
| startup auto-pin | 9.62% | 14.191 | 0.143 | off: 4.06% slower, +3.337 GiB footprint |
| auto-pin + live LFRU | 9.62% | 14.191 | 0.148 | off: zero swaps; no benefit beyond run-order noise |

PILOT measurement found 69.90% next-layer top-8 precision/recall, but advisory
`PILOT_K=4` left demand bytes unchanged and reduced warm throughput to 0.9746x.
Two-step correction improved recall to 73.01% while reducing warm throughput
10.13%. All learning/prediction/hint policies therefore remain off by default.

#### DSA and served API

The paired DSA matrix measured 24 eligible fresh-process cells (2K/8K × DSA
off/on × MTP off/on × three repeats), all with exact cold/warm/repeat/MTP
tokens. Positive decode delta means DSA was faster; negative wall delta means
less total time.

| context | MTP | paired median decode delta | paired median wall delta | decision |
|---:|---|---:|---:|---|
| 2,048 | off | -2.80% | +4.14% | no speed claim |
| 2,048 | on | -32.90% | +20.95% | regression |
| 8,192 | off | +12.38% | -1.89% | below 5% total-wall win gate |
| 8,192 | on | -34.33% | +8.19% | regression |
| 32,768 | off/on | not run | not run | ineligible: 27.320/28.540 GiB exceeds 25 GiB |

The checkpoint's 21-full/57-shared schedule remains a semantic requirement,
but no DSA product-speed claim is made. Stage-2 manifest SHA-256:
`90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.

Finally, the fresh real-artifact G7 smoke returned HTTP 200 with correct
envelopes for chat completions, text completions, Anthropic Messages, and
OpenAI Responses; SSE used `text/event-stream`, emitted four events, ended in
`[DONE]`, and reported the truthful `serial+spec` lane. Health, discovery,
exact-plan stats, and post-run idle rows also passed. This is protocol/API
evidence, not a throughput benchmark.

Primary raw records: machine-local `runs/colibri-g5/{summary,mtp-on,mtp-off}.json`,
`runs/colibri-g6-learning-shakeout-2026-08-15/summary.json`, and
`~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`.

### Served (warm) — the path agents actually use

decode tok/s · TTFT ms · server-ready s · steady RSS GB

| model | mlx-bun (mixed) | mlx-bun (bf16) | mlx-lm (bf16) | optiq (mixed)† |
|---|---|---|---|---|
| MiniCPM5-1B | **252.9** · 34 · 0.17 · 1.22 | — | — | 223.6 · 64 · 0.84 · 1.82 |
| gemma-4-e4b | 55.7 · 44 · 0.36 · 7.14 | **57.3** · 48 · 0.36 | 53.5 · 218 · 0.98 · 7.55 | 53.4 · 221 · 0.78 · 7.53 |
| gemma-4-12B | **25.9** · 85 · 0.38 · 9.46 | — | — | 25.5 · 326 · 1.24 · 9.86 |
| gemma-4-26B | 54.2 · **45** · 0.47 · 18.25 | **55.0** · 44 · 0.47 | 52.3 · 228 · 0.77 · 4.87 | — |

† **The served `optiq (mixed)` cells are effectively bf16** — optiq's
KV-quant patch is inert on mlx-lm 0.31.3's batched server path:
`install_mixed_kv` hooks `mlx_lm.generate.maybe_quantize_kv_cache` and
`mlx_lm.server.stream_generate`, but the server routes every *seedless*
text chat request through `BatchGenerator`, which calls neither hook, and
the h2h harness's server requests carry no `seed`. See
`lab/repro/optiq-mixed-kv-inert/` for the mechanism + repro. The data
fingerprint agrees: e4b optiq-mixed served 53.4 tok/s · 7.53 GB RSS ≡
mlx-lm bf16's 53.5 · 7.55. Same caveat applies to any serve-mode
optiq-mixed cell in raw `benchmarks-serve-*` artifacts dated ≤ 2026-07-06.
The **Direct** and **Long context** optiq (mixed) rows below DID measure
real quantized-KV execution (the legs passed `kv_bits=8` straight into
`mlx_lm.generate.stream_generate` — old `bench.ts --baseline-kv config` —
so the 64k collapse and the lower peaks are genuine quantized-KV
behavior), but a second installer defect means the scheme was **uniform
8-bit, not the per-layer map**: `install_mixed_kv`'s hook patch lands on
the `generate` *function* that shadows `mlx_lm.generate` in mlx-lm's
package namespace, never on the module, so mlx-lm's stock uniform
`maybe_quantize_kv_cache` is what ran (empirically proven in the repro
dir). Read "optiq (mixed)" in those two tables as "optiq (uniform kv8)".
mlx-bun (mixed) columns are unaffected — our engine implements the
per-layer scheme natively — and the L2 parity goldens stay valid: every
`regen-*` oracle script applies the scheme explicitly (direct per-layer
`to_quantized`, or calling optiq's patched hook by name), never through
the dead serve-path indirection.

Across every served model: mlx-bun has the fastest decode and the fastest
TTFT/startup (2–5×), at ~0% server tax vs its own direct engine.

### Served h2h post-consolidation (2026-08-22, e4b, single pass — directional)

Real servers via `bench-serve.ts` on merged main `4103ae1`; loaded machine
(ambient loadavg ~3), so treat as directional until a quiet-box pass. Full
findings + root-cause sweep: PLAN.md "Prefill vs mlx-lm (2026-08-22)".

| arm | prefill@1k tok/s | ttft cold/warm ms | decode tok/s | parity |
|---|---:|---|---:|---|
| mlx-bun | **1143** | 578 / **39** | **53.9** | ✓✓ byte-identical |
| mlx-lm | 866 | 772 / 230 | 50.3 | (oracle) |

Served prefill stays a decisive mlx-bun win (+32% @1k, warm TTFT 5.9×)
after the serving-architecture merge. Engine-direct prefill is
parity-within-noise elsewhere (cpm5/12B/26B; e4b@256 fresh-process −12%
is the one reproducible engine-level residual). Chunk-size tuning below
the 2048 convention is NOT L1-safe: logits are convention-pinned in BOTH
stacks (mlx reduction-order sensitivity; python drifts more than we do).
Open lead from this pass: e4b agg×4 read 26.6 vs mlx-lm 107.3 — RESOLVED
same day as a `443f333` regression (bf16 BatchedRotatingCache lost its
signature-based route in the join merge → whole-batch drop on joiners;
PLAN.md "agg×4 regression"). Post-fix: 122-126 tok/s aggregate, matching
pre-merge.

### Direct (engine only)

decode tok/s · prefill tok/s · gen-peak GB

| model | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| MiniCPM5-1B | 268.6 · 1817 · 1.01 | 241.9 · 1651 · 1.01 | **271.0** · 800 · 1.03 | 249.5 · 706 · 1.03 |
| gemma-4-e4b | **57.1** · 304 · 6.61 | 55.7 · 283 · 6.61 | 56.5 · 373 · 6.65 | 56.1 · 368 · 6.65 |
| gemma-4-12B | **26.0** · 168 · 8.99 | 25.8 · 166 · 8.99 | 25.9 · 141 · 9.10 | 25.7 · 137 · 9.00 |
| gemma-4-26B | 55.0 · 206 · 17.71 | 53.9 · 208 · 17.71 | **55.6** · 187 · 17.78 | 55.0 · 190 · 17.72 |

Direct decode is at parity-to-slightly-behind mlx-lm (the residual host
overhead per step); prefill leads on the larger models. See PLAN.md
"Decode gap RESOLVED" for the root-cause/fix history.

### Logprob metadata readback (2026-07-29)

Paired internal before/after measurement on the M1 Max 32 GB,
Qwen2.5-0.5B-Instruct-4bit, Bun 1.3.14: 256 generated tokens, two warmups,
five randomized measured rounds. This isolates mlx-bun's API metadata
readback; it is **not** a Bun-versus-Python FFI comparison.

| arm | before total / decode | after total / decode | overhead vs off, before → after |
|---|---:|---:|---:|
| off | 802.75 ms / 328.92 tok/s | 803.94 ms / 328.81 tok/s | control |
| `logprobs` | 1,185.89 ms / 220.52 tok/s | 802.77 ms / 329.18 tok/s | +47.7% → −0.1% |
| `top_logprobs=5` | 1,354.21 ms / 192.69 tok/s | 856.24 ms / 307.63 tok/s | +68.7% → +6.5% |

The fix reads uint32 IDs directly and expands the few bf16/f16 values on the
host instead of queueing `astype(float32)` behind the already-dispatched next
decode step. The off control stayed flat; all 40 parity checks and all 1,280
selected/top-k comparisons were exact. Clean commits: before `00e597e`, after
`b1cb7cb`. Raw artifacts are recorded in the Phase 22 ledger in
`docs/archive/investigations/pre-colibri-stabilization.md`.

### Long context (gemma-4-12B) — where the gap opens

decode tok/s · gen-peak GB

| context | mlx-bun (bf16) | mlx-bun (mixed) | mlx-lm (bf16) | optiq (mixed) |
|---|---|---|---|---|
| 16k | 23.9 · 11.82 | 23.5 · 10.61 | 23.9 · 11.72 | 21.6 · 11.19 |
| 64k | **20.9** · 15.77 | 18.7 · 10.46 | 20.9 · 15.91 | 12.3 · 14.89 |

At 64k mlx-bun holds parity with mlx-lm on bf16 while optiq collapses to
12.3 tok/s; mlx-bun's mixed-KV trades ~2 tok/s for ~5 GB lower peak.

### Attempted but failed (2026-06-14)

- `gemma-4-12B/optiq/kv=config`: `quantized_matmul` weight/scales
  shape mismatch (upstream optiq bug; tracked). _(Relabeled from the
  old-legend name "e4b" = hash `5b…` = 12B; no gen-peak was recorded for
  this failed run, so the model id here is inferred from the legend, not
  fingerprinted.)_

---

## 3. Quality — for non-bit-exact (Lab) optimizations only

When a custom path trades bit-exactness for speed, quantify the cost so a
perf win is only claimed with its quality delta — e.g. *"+23% tok/s while
holding ±5% on the 6-test mean."*

- **6-test mean** — mean score across `src/eval/tasks/`: bfcl, gsm8k,
  hashhop, humaneval, ifeval, mmlu — optimized path vs the compatible
  upstream.
- **KL divergence** — optimized vs compatible token distribution.

This section is the home for a Lab experiment's quality measurements
when it's promoted (the bar: paired-A/B win vs L1 on a stable pass +
KL PASS — see docs/design/unified-engine-frontier-plan.md §6-7).

### TurboQuant KV quality-vs-bpw (2026-07-06, M1 Max 32 GB, MiniCPM5-1B)

> Note: measured on an M1 Max 32 GB, not this file's M4 Pro reference
> box — valid as a paired quality/KL measurement (machine-independent),
> not as a perf number.

Opt-in memory/context scheme (`--kv-quant turbo[:k<bits>v<bits>]`), not a
speed lever. Teacher-forced serving-decode KL vs bf16 KV (8×128 tokens, 32
decode steps, `eval-turboquant-curve.ts (deleted; git history)`); affine rows same harness:

| scheme | effective KV bits | KV compression | mean KL vs bf16 |
|---|---|---|---|
| uniform kv8 (g64) | 8.50 | 1.88× | 0.00246 |
| turbo k8v8 | 8.75 | 1.83× | 0.00214 |
| turbo k8v4 | 6.75 | 2.37× | 0.00936 |
| **turbo k8v3 (default)** | **6.25** | **2.56×** | **0.0325** |
| uniform kv4 (g64) | 4.50 | 3.56× | 0.0516 |
| turbo k4v3 | 4.25 | 3.76× | 0.0622 |
| turbo k4v2 | 3.75 | 4.27× | 0.205 |

Read: turbo k8v3 beats uniform kv4's KL at 2.56× compression; k4v3 is
on-curve with affine at matched bits; 2-bit values are the cliff (matches
the TurboQuant paper's law). Codec is bit-exact vs the vendored vllm-metal
reference (goldens/turboquant.json); details in
docs/design/turboquant.md.

## 4. Composition — feature-default decisions (measured, per pair)

The doctrine (docs/design/speculative-decoding.md Phase 4e): a feature is ON by
default for a (model, config) pair only when it WINS a clean-machine
paired A/B on that pair; losing configs stay documented default-off
levers. This section records the decisions and the numbers behind them.

### Speculative decoding — "should spec be on?" (decision pending Phase 0/1 runs)

Decision rule: spec defaults ON for a (target, drafter) pair iff
serve-path decode ≥ 1.3× serial at the recommended γ, clean-machine
paired (`scripts/bench-serve.ts all` preflight, `bench-feature-matrix.ts --cells
serial,spec`), with acceptance within 3 pts of the bf16-drafter baseline
(`scripts/dspark.ts ab`). Prediction to test: ON for
12B + quantized DeepSpec drafter, OFF for e4b + anything.

| target | drafter | γ | acceptance | τ | spec tok/s | serial tok/s | verdict |
|---|---|---|---|---|---|---|---|
| 12B-OptiQ-4bit | DeepSpec bf16 (6.9 GB) | 7 | 26–33% | ≈2.8 | 14.6 agg | 49.8 agg | **OFF** — drafter tax −3.4× (2026-07-07 first live run, loaded box, conc-4; directional) |
| 12B-OptiQ-4bit | DeepSpec affine-q4-g64 (1.8 GB, built 2026-07-07) | best-of-0b | _1d run_ | _1d run_ | _0b/6 run_ | _0b/6 run_ | _pending_ |
| e4b-OptiQ-4bit | (expected-negative control) | — | — | — | — | — | _pending_ |

Runbook (Josh's shell; directional passes fine loaded, the FINAL pair
clean-machine per the house rule):
1. **1d acceptance A/B** (no server): `bun scripts/dspark.ts ab
   --target gemma-4-12B-it-OptiQ-4bit --drafter-a <bf16-snap>
   --drafter-b <q4-snap> --json ab-q4.json` — gate: drop ≤ 3 pts AND
   wall-clock strictly improves.
2. **0b γ sweep** (server): serve 12B `--draft-model <q4-snap>
   --num-draft-tokens {2,3,5,7}` × `bun scripts/bench-matrix.ts features
   --concurrency 1 --cells serial,spec` — pick best-γ by per-request tok/s.
3. **Phase 6 decision pair** (clean machine: reboot + `sudo purge`):
   best-γ config, `--cells serial,spec` at conc 1 AND agg×4 — fill the
   table, flip the features-matrix default cell if ≥ 1.3×.

### TurboQuant KV — decided OFF (2026-07-06, re-affirmed post-leak-fix)

Opt-in memory/context lever, not a speed feature (v1 dequant-on-fetch is
slower per step at long context; no speed claim made). The KL-vs-bpw
curve above is the quality evidence. NOTE: any turbo perf/RSS impression
formed before 2026-07-07 is invalid — the pre-fix build leaked
window-scale buffers per decode step (PLAN Phase 13 post-merge fix).
