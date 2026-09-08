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
mlx-bun-mixed · optiq-mixed) it measures decode tok/s (five fixed samples,
all retained; unstable runs flagged), TTFT cold (~1k, nonce-busted) and warm/cached (each stack's own
prompt cache), prefill tok/s, long-context prefill/TTFT/decode (ONE measured
prefill; decode sampled on 64 tok + 2 cached repeats), aggregate tok/s at 4
concurrent streams, peak RSS (sampled; undercounts GPU), and load→ready time.
The same cells compare decoded text from greedy probes of up to 64 tokens
between stacks of the same scheme, including the serial control vs mlx-lm.
Prompt-count inequality rejects a comparison as template/tokenizer drift;
matching counts and text are a smoke check, not proof of identical token IDs
or logits. Missing usage cannot produce a passing verdict. The engine's
pinned logit oracle remains the correctness gate.

```sh
bun scripts/bench-serve.ts all                       # cpm5 + e4b + 12B + Qwen3.8-27B, all arms
bun scripts/bench-serve.ts all --no-serial           # skip the --batch 1 control arm
bun scripts/bench-serve.ts all --models cpm5,qwen27b # subset
bun scripts/bench-serve.ts all --skip-context        # drop the long-context leg
bun scripts/bench-serve.ts all --context 8192        # shorter context leg
```

For an exact local quant use `--model-path <dir>` and optionally `--label`.
It replaces the registry selection and cannot be combined with `--models`.
`--dry-run` prints artifact metadata and server commands, with no preflight,
model load, database write or server process. Packed trellis skips stock
mlx-lm/optiq arms; explicitly requesting those arms fails before starting a
server. A fake-quant/8-bit carrier is a separate artifact and cannot establish
same-artifact packed performance or decode parity.

```sh
bun scripts/bench-serve.ts all --model-path /path/to/quant --label qwen38-quant --dry-run
bun scripts/bench-serve.ts all --model-path /path/to/affine --arms mlx-bun-serial,mlx-lm --context 4096 --out reports/affine-h2h.md
bun scripts/bench-serve.ts all --model-path /path/to/packed --arms mlx-bun-serial --context 4096 --out reports/packed-baseline.md
bun scripts/bench/model-inventory.ts /path/to/affine /path/to/packed > reports/model-inventory.json
```

`--workload-seed <block-id>` generates identical nonce-prefixed prompts for
every engine and artifact in that block, with distinct nonces for retries.
Thinking is pinned on for all chat measurements. Long-context filler uses a
fixed character estimate so token-count drift cannot silently change the
input on one engine. Record actual token counts and compare raw request hashes.
Use phase/attempt/index to distinguish a cold request from its identical warm
repeat; request hashes alone do not identify cache state.
For paired trials, alternate `--arms mlx-bun-serial,mlx-lm` and the reversed
order across blocks; give every block its own seed and `--out` path.

Configured serial experiments accept `--draft-model`, `--draft-kind`,
`--num-draft-tokens`, `--kv-quant` and `--prompt-cache`. These options require
`--arms mlx-bun-serial`; record default and oracle controls in separate runs.
The dry-run, raw JSON and Markdown report retain the settings and relevant
runtime overrides. No script under `reports/` is required to launch them.
For the current packed Qwen artifact on the M4 Pro, run this after closing
other workloads. It exercises the opt-in KV4/MTP/paired-prefix configuration
through the current checkout and writes a new dated report under `reports/`.

```sh
MLX_BUN_TRELLIS_VARIANT=13 MLX_BUN_QWEN_SPEC_KV4=1 MLX_BUN_MTP_PROMPT_CACHE=1 MLX_BUN_RD_PREFILL_CHUNK=256 \
bun scripts/bench-serve.ts all \
  --model-path "$HOME/models/Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd" \
  --arms mlx-bun-serial \
  --draft-model "$HOME/models/Qwen3.8-27B-MTP-folded-rtn4-g64-rd" \
  --draft-kind mtp --num-draft-tokens 2 --kv-quant 4 --prompt-cache 4 \
  --context 4096 --tokens 192 --workload-seed pr47-block-0
```

Append `--dry-run` to inspect the command first. This serving suite is separate
from the Luke Kanban task and does not establish its task-time speedup. The
portable multi-machine HTML report in the performance plan remains open;
this entry point currently writes Markdown and JSON.

`--diagnostic` explicitly permits a loaded-machine serving run. It records
the preflight snapshot and writes `*-serve-diagnostic` DB rows, which cannot
serve as canonical results. Server children use the invoking Bun executable,
so an isolated runtime comparison actually changes the server runtime too.

The Markdown report has a `<report>.md.json` companion containing all chat
requests, results, failures and retries, plus config/source-diff hashes and
server commands. Schema 4 also hashes a sorted manifest of tracked and
untracked source files at startup and save time, so new local kernels cannot
escape source identity. External native libraries and weights need their own
manifests. Failed attempts include the child's stderr tail and process
status; a successful retry keeps the recovered failure visible. It is saved
after each completed or failed cell. The report
separately records total request wall time and actual-output throughput.
The decode columns use the first-to-last visible SSE interval: bursty chunks
can distort that interval, so it is not a GPU timing. Token throughput requires
valid server usage; chunk counting is no longer a fallback. Raw results also
record response-header, first-byte and first-SSE-event latency, then every
content/reasoning/tool-output event arrival. Event gaps measure stream
delivery, not individual token latency. Tool-only streams have an output TTFT.
Malformed/error SSE and responses without a finish reason or `[DONE]` fail
the measurement. Match output counts, finish reasons and text before
interpreting a speed difference. The exported `measureCompletionRequest`
helper applies the same timing and stream-validation contract to raw
`/v1/completions` requests, without chat-template preparation.

The inventory reads shard headers and config only, reconstructs matrix
shapes including trellis axis-0 storage, and counts actual tensors rather
than duplicate config aliases. Its matrix effective-bpw figure includes
scales/biases but excludes norms, convolutions and sidecars; it is explicitly
not whole-model bpw or peak memory. Config/index/layout hashes do not hash
weight payloads. Use existing shard hashes or hash weights outside timed runs
when certifying artifact identity. The complete Qwen campaign is in
[the performance program](../design/decode-speed-program.md#7-qwen38-27b-research-program).

For native engine isolation, `scripts/bench/native.ts` runs dense Qwen3.5/3.8
with bf16 attention KV, f32 recurrent state and greedy decoding. Supply a
frozen JSON array of prompt token IDs and the exact local artifact to both
stacks. Each request starts with a fresh cache; warmups and every measured
sample are retained. Reports include actual output IDs, EOS policy, TTFT,
wall time through cache cleanup/GPU synchronization, memory and source pins.
They record the effective wiring policy and active/cached memory around each
request. The oracle worker enters mlx-lm's normal scoped wired limit; compare
that policy with Bun's model-sized scope before interpreting a ratio.
`--clear-before-request` is a separate allocator-cache experiment on both
stacks, with cleanup included in wall time. Keep it fixed within a pair;
it does not clear model weights or substitute for a fresh inference cache.
Stock mlx-lm rejects packed trellis. This worker uses the pinned oracle
environment and never starts a server or downloads a model.

```sh
bun scripts/bench/native.ts --model-path /path/to/affine --prompt-ids reports/prompt-ids.json --stack mlx-bun --json reports/native-bun.json --dry-run
bun scripts/bench/native.ts --model-path /path/to/affine --prompt-ids reports/prompt-ids.json --stack mlx-lm --json reports/native-oracle.json
```

Alternate stack order across predeclared process pairs. Check token IDs,
output counts and finish reasons before comparing request wall times.
`--diagnostic` permits a failed quiet-machine preflight and records that
failure. Native results remain diagnostic, including on a quiet machine;
they do not establish HTTP throughput, task quality or full logit parity.
The repaired legacy `bench-h2h.ts direct` command delegates to this worker,
requires `--models` and bf16 KV, and writes only `*-native-diagnostic` DB
rows with raw report paths. Its rates use actual emitted tokens and all
fixed samples. Use the worker directly to avoid registry ambiguity.

`all` runs the clean-machine preflight first (refuses headline numbers from
a loaded or swapped box) and holds `caffeinate` for the pass. Quotable
numbers and ratios need a quiet machine; loaded runs are diagnostic only.
Results land in the eval DB (`~/.cache/mlx-bun/evals.sqlite`) plus dated
Markdown and JSON reports under `reports/` by default. Developer lever A/Bs are NOT benchmarks — run
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

### Standard serve matrix — M4 Pro 24 GB (2026-09-08, incomplete acceptance)

Josh ran `bun scripts/bench-serve.ts all` at clean commit `86738ac` on
`Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, Bun 1.4.0, with the matching
MLX 0.32.2 reference. Quiet preflight passed. There were no runtime overrides;
the workload used `bench-serve-v2`, thinking enabled, five 192-token decode
requests and a requested context target of 16,384. The actual context probes
contained 9,062 MiniCPM tokens and 9,589 Gemma tokens. This is one ordered
suite, not an alternating before/after optimization comparison.

| Model | Default mlx-bun decode tok/s | mlx-lm decode tok/s | Default mlx-bun request time | mlx-lm request time | Request-time reduction |
|---|---:|---:|---:|---:|---:|
| MiniCPM5-1B | 278.65 | 223.55 | 0.710 s | 0.936 s | 24.2% — output mismatch |
| Gemma4-e4b | 57.86 | 53.63 | 3.402 s | 3.810 s | 10.7% |
| Gemma4-12B | 26.14 | 25.40 | 7.576 s | 7.969 s | 4.9% |
| Qwen3.8-27B 4/8-bit winner | 14.75 | 14.19 | 13.814 s | 14.523 s | 4.9% — output mismatch |

The table uses medians of the same five requests, all with exactly 192 output
tokens. Request hashes, input/output counts and cached-token counts match
between these arms. Both Gemma models also match all five timed output texts
and both short parity probes. MiniCPM and Qwen differ on all five timed
outputs despite matching counts; Qwen's separate 64-token probes match, while
MiniCPM's chat probe diverges. Their timing rows remain observations pending
the exact-token/logit investigation. The Gemma12B reference command invokes
OptiQ's model registration before its mlx-lm serving path.

For Gemma e4b, cold/cached TTFT is 559/72 ms versus 707/212 ms in the
reference, and the approximately 1K prefill estimate is 1,199 versus 947
tok/s. For Gemma 12B those values are 2,531/157 ms versus 2,677/333 ms and
265 versus 250 tok/s. The serial controls finish the same short requests in
3.360 s and 7.514 s, respectively. Cached TTFT is one warm sample per cell.

Acceptance is incomplete. Qwen hits Metal out-of-memory errors in both the
approximately 1K and context phases, in default and serial serving. Its
reference recovers an initial 1K timeout, then fails the context phase and
skips concurrency. MiniCPM and Gemma12B each report missing SSD snapshots on
the first restart-flush attempt in default and mixed serving; retries succeed.
Mixed-KV rows are not compared for L1 identity against bf16 KV. The complete
report retains eleven phase-failure records, including recovered failures.

The Qwen artifact is the registry's 4/8-bit winner, not the required 12.14 GiB
packed Trellis target. No MTP draft was configured. These numbers neither
replace the Trellis/KV4/MTP measurements nor establish a Kanban task-time gain.
Raw evidence: `reports/benchmarks-serve-2026-09-08-Joshs-MBP-2025.md` and its
`.md.json` companion; source hashes are unchanged across the run.

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

### Original and optimized serving diagnostics, M4 Pro, 2026-09-07

Machine: `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, Bun 1.4.0.
`bench-serve.ts all` used workload seed `kanban-final-0`, thinking enabled,
192 requested output tokens and five decode samples. These are earlier
diagnostic runs, with existing swap, rather than final-PR quiet acceptance.
All columns below use the serial serving lane and the required packed target
weights. Baseline uses `673b43f`, Trellis variant 6 and the older native library;
optimized arms use variant 13, the lossless interleaved artifact and the local
MLX 0.32.2 candidate. Each run's source stayed fixed.

All three serving arms use **bf16 KV**, with `--kv-quant off`. The MTP arm
adds two drafts and paired RAM prefixes. This differs from the completed
long Kanban task's KV4 configuration. These runs predate the later ownership
and bounded-range fixes, so they do not measure the exact final task revision.

| Serial serving metric | Original | Optimized, ordinary decode | Optimized, MTP + RAM cache |
|---|---:|---:|---:|
| Median decode, tok/s | 10.140 | 11.712 | 19.426 |
| Cold-request TTFT, ms | 5,923.576 | 6,164.498 | 5,801.504 |
| Cached TTFT, ms | 190.841 | 436.308 | 91.916 |
| 1K prefill, tok/s | 127.963 | 122.962 | 130.522 |
| Peak process RSS, reported MB | 11,958.984 | 13,859.828 | 12,061.219 |

Ordinary decode improves **15.5%**. The MTP configuration improves decode
**91.6%** relative to the original, with cached TTFT **51.8% lower**.
Its cold TTFT changes by -2.1%, prefill by +2.0%, and sampled RSS by +0.9%.
Ordinary decode's gain does not extend to every metric: its cached TTFT and
RSS regress in this diagnostic. The percentages describe these specific
serving configurations; they are not a measured Kanban task-time reduction.

The baseline context phase crashed and recovered on retry; no context-phase
speedup is claimed here. MTP prefix state is RAM-only: the restart probe
restored zero tokens and does not establish SSD persistence. Stock mlx-lm
cannot read this packed Trellis artifact, so it supplies no same-artifact
serving baseline for these rows.

Raw evidence: `reports/qwen38-rd/kanban-final/suite-driver.json`,
`baseline-suite.md.json`, `optimized-ordinary-suite.md.json`, and
`optimized-mtp-cache-suite.md.json`. The driver records all commands,
environments, source hashes and exits. The completed task and its separate
acceptance are recorded below.

### Fresh Pi kanban diagnostic, M4 Pro, 2026-09-07

Machine: `Joshs-MBP-2025.local`, M4 Pro, 24 GB; Bun 1.4.0, Pi 0.85.1,
MLX 0.32.2. These are task diagnostics with existing swap. The first attempt
also had a brief background browser-test CPU burst. Neither is a quiet-machine
speed claim.
The model is the required 12.14 GiB packed Qwen3.8-27B Trellis artifact with
lossless interleaving. The selected Luke profile is
`qwen3.8-27b-q3_k_xl-coding-128k`, pinned at repository commit
`3288d1918fa6140c10f3b2de2d37f9d717a5ab75`. It uses the unchanged prompt,
xhigh thinking, temperature 0.6, seed 42 and 131072 context. The MLX mapping
uses target affine KV4 group64, two MTP drafts, paired RAM prompt prefixes
and 256-token prefill chunks.

| Attempt | Time until Pi stopped | Output tokens | Overall tok/s | First-turn tok/s, including prefill | First reasoning TTFT | Peak server + Pi RSS | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| History fixed; original tool-value parser | 65m 30.245s | 53,631 | 13.646 | 15.965 | 22.869s | 12.042 GiB | Failed: only HTML and two JS modules; final edit call remained assistant text |
| History and tool-value parsing fixed | 106m 6.531s | 82,015 confirmed | 12.882 | 16.154 | 22.892s | 13.795 GiB | Failed inference: Metal out of memory at the 85,238-token request; Pi did not finish |

All four request prompt counts matched independent renders. Later requests
reused 2,549, 53,174 and 54,859 prompt tokens, with MTP active. Pi had no
automatic retries or compactions. Its clean process exit did not mean the
app was complete: the mandatory README was absent and most app files were
never written. The untouched output fails acceptance. No successful task
completion time or matched task-time speedup is established by this row.

The saved final edit parameter is valid JSON. The engine decoded XML
entities before JSON parsing and its repair pass misidentified the nested
array as the outer call. The corrected parser preserves the complete argument
array through the actual tokenizer and streaming path.

The fresh attempt with both fixes completed ten requests. Every completed
prompt count matched the independent render and every response used MTP.
The aggregate accepted/drafted ratio was 80.038%. The first tool transition
took 524.244 seconds to first output while processing newly generated history.
Later requests reused progressively longer prompt prefixes. The cache still
captures prompt boundaries rather than the newly generated history.

The eleventh request reached a Metal allocation failure after its first
reasoning fragment. Its terminal usage was unavailable, so the output total
counts only completed responses. The wall-clock interval includes that failed
request, prefill, tools and agent overhead. Ten completed response intervals,
excluding TTFT, average 15.270 output tokens/s. This is distinct from both
overall task throughput and the short-context serving-suite decode rate.
There were no retries, compactions or tool errors. Engine source hashes stayed
fixed. All inference processes exited during bounded cleanup.

The untouched app has HTML, CSS, twelve JavaScript modules and package.json,
but no README. Syntax checks pass. A separate browser smoke test after server
shutdown shows the default columns and keyboard card creation work, but opening
the editor throws `ReferenceError: renderLabels is not defined`. Remaining UI
checks were not run after that blocking failure. No app edits or repair prompts
were supplied. These are findings about an incomplete artifact, not a completed
model submission. No successful completion time or matched task-time gain exists.

Process RSS does not measure all Metal allocations. The out-of-memory failure
does not establish the model's architectural context limit; the tested KV4,
MTP and retained-prefix combination needs a separate memory diagnosis.

Protocol and design: [decode-speed-program §7.7](../design/decode-speed-program.md#77-gates-scheduling-and-completion).
Raw evidence: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-history-fixed/`
and `luke-q3-128k-xhigh-tool-values-fixed/`, including `quality-static.json`,
`quality-browser.json` and screenshots. Portable report:
`reports/qwen38-rd/kanban-final/comparison.html`.

### Kanban capacity diagnosis, M4 Pro, 2026-09-08

Native Bun screen on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, using the
same 12.14 GiB target, MTP head, MLX 0.32.2 candidate and KV4/prefix settings
as the failed Pi attempt above. The saved failing history renders to 85,238
tokens. Fixed text tokens extend it to 110,000 for this capacity screen.
No Pi task runs in this screen. Sampling follows the selected profile, but
EOS stopping is disabled to require a short continuation. This is neither
a fresh task result nor a quiet-machine performance claim.

The unchanged control finished target prefill and emitted one token, then
failed with Metal out of memory in the first MTP draft round. Its wall time
was 1,482.497 seconds. Peak active Metal allocation reached 19,451,721,310
bytes against a recommended working set of 19,069,665,280 bytes. Immediately
before draft prefill, active allocation was 14,593,938,440 bytes; at the
first emitted token it was 17,494,527,842 bytes. The retained prefix reported
2,633,836,544 logical bytes. These counters measure different things from
process RSS and do not establish a model context limit. Source hashes stayed
fixed; the worker exited with failure and bounded cleanup completed.

Raw control: `reports/qwen38-rd/kanban-capacity-110k-control.json` and its
allocation event log. A focused small ownership regression retains 8,405,016
bytes before the fix, despite requiring only small KV state and one hidden
row. The isolated candidate now evaluates draft KV at each existing prefill
chunk and materializes the retained final hidden row. The ownership,
prefix-position and provider-disposal tests pass. Full-model exactness and
large-context acceptance are checked separately. A sampling-failure
regression retains 524,288 bytes before scoped disposal; it now passes the
under-4-KiB cleanup guard without running GC after the failure.

The final-source small native comparison uses the same first 8,192 history
tokens and generates 32 tokens twice. Before and after the ownership changes,
both responses and all MTP acceptance decisions match exactly. Each process
first prefills from zero, then restores 8,191 cached tokens. Peak active
allocation is 13,330,783,014 bytes before and 13,105,695,458 after. Both source
manifests stay fixed. This is one correctness/allocation comparison, not a
request-time speed claim. Typechecks pass. Evidence: `kanban-capacity-8k-final-comparison.json`
and its two referenced control/candidate reports in `reports/qwen38-rd/`.

The final native capacity screen passes at 110,000 prompt tokens. It completes
three identical 256-token continuations, with 109,999 tokens restored on each
cached request. Between the latter two, an intentional output-sink error after
eight emitted tokens exercises request cleanup. Retained active allocation is
14,911,641,794 bytes after every completed or intentionally failed request.
The next request recovers in the same process and reproduces the continuation.
Peak active allocation is 17,981,018,362 bytes, 1,470,702,948 bytes below the
failing control, despite the longer continuation. The first request takes
1,525.095 seconds including full prefill; the two complete cached requests take
33.148 and 33.175 seconds. Instrumented synthetic-context timings are not
Kanban completion estimates. Final provider/weight disposal leaves 101,892,102
active bytes; the equal per-request counters establish no incremental retention
from the injected failure, not zero global runtime allocation. The worker exits
successfully, its source hashes stay fixed and its deadline is not reached.

The main source has the same ownership fixes. Its focused memory/provider tests
and a real-target MTP/non-MTP short greedy identity gate pass, as do all
typechecks.
Native evidence: `reports/qwen38-rd/kanban-capacity-110k-owned-final.json`.

The saved-history HTTP gate also passes on the isolated candidate. It first
replays the exact failed request, then appends that response and synthetic
tool/user history to test growth. Tool calls are recorded but never executed
by this diagnostic. Each response allows up to 512 output tokens and stops
naturally. Both repeated responses preserve all text, tool arguments, output
counts and MTP acceptance decisions.

| Prompt tokens | Cached tokens | Output tokens | Complete request, s | TTFT, s |
|---:|---:|---:|---:|---:|
| 85,238 | 0 | 42 | 988.103 | 984.951 |
| 85,238 | 85,237 | 42 | 3.283 | 0.225 |
| 110,014 | 85,237 | 92 | 401.843 | 393.126 |
| 110,014 | 110,013 | 92 | 8.931 | 0.255 |

Source hashes stay fixed and server cleanup exits successfully. This validates
serving capacity and cache reuse, not a completed Kanban task. Raw evidence:
`reports/qwen38-rd/kanban-memory-http-owned.json` and the saved request/response
files beside it. These checks exercise short continuations. The fresh Pi
retry below still fails during sustained generation.

During the saved-history HTTP prefill, simultaneous read-only `/health` and
`/stats` requests both returned 200, taking 4,776.475 and 4,776.682 ms. This
single busy-server observation does not establish an idle baseline or latency
distribution. It identifies responsiveness during native prefill for a separate
serving check. Evidence: `reports/qwen38-rd/kanban-memory-http-responsiveness.json`.

### Fresh Pi Kanban after MTP ownership fixes, M4 Pro, 2026-09-08

The fresh retry on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, failed with
Metal out of memory after **106m 5.416s**. It used the same 12.14 GiB target,
published Luke Q3 128K xhigh profile and unchanged prompt as the preceding
attempt. The source and every saved request's profile pass the post-run audit.
The first request body is byte-identical to the preceding attempt; its entire
response and MTP acceptance trace also match. Later history includes actual
tool results, including changed directory timestamps.

Eight requests completed, reporting **73,831 output tokens**. The ninth
request started with **77,077 prompt tokens**, emitted its first output after
26.415 seconds and failed after 780.891 seconds, during sustained decode.
Its terminal usage is missing. Retokenizing delivered reasoning estimates
another 5,659 tokens, but excludes buffered tool arguments, so the full
generation count is unknown. The completed-response rate after first output
is 15.658 tok/s; this excludes prefill, tool time and the failed response.
Peak combined server/Pi RSS is **13.836 GiB**. Completed requests report
79.911% MTP acceptance. There were no retries, compactions or tool execution
errors. Pi exited with code zero but reported a terminal error; the task
therefore failed. No successful completion time or task-time speedup is
established.

The untouched app supplies its README and passes syntax, basic card creation,
board/theme persistence, column creation/rename and between-column card drag
checks. The card editor throws `ReferenceError: renderLabels is not defined`;
the archive panel throws `TypeError: K.render.renderArchive is not a function`.
Required functional acceptance fails. Reorder interaction probes remain
unconfirmed because their input simulation needs validation. Independent UI
checks ran only after inference exited. No app code was edited and no repair
prompts were supplied.

The short native and HTTP capacity checks above did not reproduce this long
decode failure. It motivated the sustained allocation check below. Raw result,
source/profile audit and untouched
app checks: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-mtp-memory-fixed/`
contains `result.json`, `measurement-audit.json`, `quality.json` and its
referenced evidence.

### Sustained Kanban decode allocation diagnosis, M4 Pro, 2026-09-08

A fresh native process loaded the failed task's saved **77,077-token** request
and generated **12,288 tokens** with the same model, MTP, KV and sampling
settings. EOS stopping was disabled for this bounded diagnostic; no tools
were executed. The unchanged control completed in 2,408.753 seconds including
923.348 seconds to first output. Decode was 8.272 tok/s. Peak active MLX
allocation was **18,204,808,450 bytes**; **1,593,360,390 bytes** remained active
after provider/weights disposal and allocator-cache clearing. Source hashes
stayed fixed. This is a saved-history diagnostic, not a fresh task result or
a quiet-machine speed claim.

The large-range cache retained every distinct causal-mask range above 65,536
elements. Early comparable rounds each added **311,296 bytes**, matching the
page-rounded int32 range allocation. A focused regression with 256 changing
context lengths retained **79,790,080 bytes** in the old implementation and
**7,258,112 bytes** after bounding cached array data to 8 MiB. Three oversized
ranges retained **37,748,736 bytes** before and **zero additional bytes** after.
The regression fails before the change and passes after it, including exact
range values, vocabulary reuse and lazy-view ownership after eviction. Eight
focused main-source tests, the candidate regression and both workspace
typechecks pass.

Reconstructing the target prefill lengths and verification windows from the
control's acceptance trace predicts 4,685 distinct large mask ranges occupying
1,592,344,576 page-rounded bytes. That accounts for more than 99.9% of the
observed allocation left after model disposal. This is allocation attribution
from the recorded execution and source, not a measurement of every cache entry.

The bounded-cache full-model repeat passes: all **12,288 output tokens** and
all **4,638 MTP acceptance decisions** are identical. Source and harness hashes
stay fixed, with `src/mlx/ops.ts` the only engine difference between arms.
Both runs exit normally without cleanup errors.

| Native diagnostic metric | Unbounded cache | Bounded cache |
|---|---:|---:|
| Complete request time | 2,408.753 s | 2,461.051 s |
| Time to first output | 923.348 s | 939.902 s |
| Decode rate | 8.272 tok/s | 8.078 tok/s |
| Peak active MLX allocation | 18,204,808,450 B | 16,622,195,970 B |
| Active MLX allocation after model disposal | 1,593,360,390 B | 8,224,774 B |
| Observed peak process RSS | 14,324,711,424 B | 12,745,523,200 B |
| OS lifetime peak process footprint | 18,969,882,768 B | 18,826,963,720 B |

Peak active allocation falls by **1,582,612,480 bytes**. The single diagnostic
pair takes **2.171% longer**, so it establishes a memory/ownership correction,
not a throughput gain. RSS, active allocation and physical footprint remain
distinct measurements. The process monitor started during control prefill
and before candidate prefill; native allocation instrumentation is identical.
The fresh Pi task with this correction completed; its separate task result
and functional acceptance are recorded below.

Raw evidence: `reports/qwen38-rd/kanban-sustained-77k-owned-control.json`, its
allocation/process-memory traces, `kanban-arange-allocation-evidence.json`,
`kanban-arange-regression.json`, `kanban-arange-micro-memory.json` and
`kanban-arange-reconstruction.json`. Full-model comparison:
`kanban-sustained-arange-comparison.json`, with both raw runs and their traces.

### Completed fresh Pi Kanban with bounded range cache, M4 Pro, 2026-09-08

The untouched app passes the required functional checks after a fresh Pi run
on `Joshs-MBP-2025.local`, Apple M4 Pro, 24 GB, using the required 12.14 GiB
Trellis target. The published Luke Q3 coding 128K profile, unchanged prompt,
xhigh thinking, sampling and seed 42 remain fixed. The candidate uses MLX
0.32.2, target KV4, MTP depth 2 and paired RAM prefixes. Processes, application
caches, Pi session and task workspace started fresh; OS file cache was not purged.

| Completed task metric | Result |
|---|---:|
| Prompt submitted to Pi settled | **3h 33m 7.685s** |
| Including server startup | 3h 33m 8.581s |
| First request time to first output | 23.145 s |
| Reported output tokens, including reasoning and compaction | **130,494** |
| Completed inference requests | 62 |
| Output / whole task elapsed time | 10.205 tok/s |
| Completed-response rate after first output | 13.904 tok/s |
| Sum of request time before first output | 56.665 min |
| MTP draft-token acceptance | 79.706% |
| Peak sampled combined server/Pi RSS | 11.916 GiB |

All 443 source, profile, request, usage and timing audit checks pass. Every
response has terminal usage; the output total is exact. Pi and the server
exit normally, with no inference error or automatic retry. Pi encounters
seven tool execution errors during its own debugging and completes the task
without external repair prompts.

One context compaction is included in the total. Its summary request uses
90,214 input tokens, reports 1,404 output tokens, and takes **19m 42.705s**,
including 17m 37.551s before first output. The following coding request has
28,126 input tokens and takes another 4m 22.552s before first output.
Both prompts have zero cached tokens because the summary changes the exact
serialized prefix. The first ordinary tool turn separately takes 8m 53.415s
before first output after the initial 50,533-token response; its cached prefix
contains only 2,549 tokens. These are measured targets for reducing repeated
prefill, not claimed savings. The frozen outcome helper recorded zero
compactions because it recognized only `auto_compaction_start`; derived
reports count the observed `compaction_start` while preserving the raw result.

The server's last observed OS lifetime peak physical footprint is
**18,913,094,336 bytes**. The external monitor began during the task and
sampled through five seconds before exit; lifetime counters include earlier
process history but may miss the final interval. Physical footprint and the
runner's sampled combined RSS are different measurements. Separate process
lifetime peaks are not added as though they were concurrent.

After inference exited, independent browser checks passed card creation,
required-title editing, description/labels/assignee fields, combined filters,
archive/restore, column creation/rename/safe deletion/restore, native card
and column reordering, the Done indicator, and persisted theme/board/order.
The app supplies run instructions and modular vanilla code. No generated
source was edited. Earlier automated reorder probes remain recorded; native
mouse motion with dragover before release confirms both reorder operations.

This establishes a completed task on the frozen candidate. There is no
matched successful original baseline, so it establishes no task-time speedup
percentage. The complete first response and every MTP acceptance decision
match the preceding failed attempt; its time changes from 3,152.595 to
3,147.633 seconds, effectively flat in one pair. The bounded range cache's
measured benefit remains retained-memory correction and successful completion.

Raw evidence: `reports/qwen38-rd/kanban-final/luke-q3-128k-xhigh-arange-bounded/`
contains `result.json`, `measurement-audit.json`, `quality.json`, referenced
browser evidence, `memory-summary.json`, the untouched app and saved sources.
The derived HTML report is `reports/qwen38-rd/kanban-final/comparison.html`.

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
