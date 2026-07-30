# Pre-Colibri stabilization program

**Status:** ACTIVE — opened 2026-07-29. This program interrupts Phase 21
before G4. The landed Colibri G1–G3 foundation stays intact; no new Colibri
feature work starts until the exit gate below closes.

## 1. Why this is a program, not a bug pile

The intake contains 25 potential issues with different evidence and different
failure modes. Some are statically obvious safety or correctness defects. Two
are performance hypotheses whose magnitude has not been measured. Three are
deployment hardening ideas that add little while the server is strictly
loopback-only.

Treating all 25 as equivalent would create a large, unreviewable patch and
would encourage performance claims without numbers. This program instead:

1. gives every item a stable ID (source line numbers are only discovery
   anchors);
2. records whether the item is reported, reproduced, disproved, fixed, or
   deliberately deferred;
3. requires a failing regression or baseline measurement before changing
   code;
4. lands one coherent invariant per commit/PR, except where cancellation must
   be fixed end-to-end across several protocol adapters;
5. runs a wave gate before moving to the next risk class; and
6. resumes Colibri from its exact checkpoint only after the closeout gate.

## 2. Colibri pause and resume point

Phase 21 is paused after the G1–G3 foundation landed on `main` at
`2cd6e35`. G0 and G2 are closed. G1 and G3 still require the quiet-machine
kernel/power matrix and the stock-MLX-versus-custom-Metal path decision. G4
(serial native MTP) has not started.

After this program closes, resume in this order:

1. run the remaining G1/G3 quiet-machine kernel and passive-worker power
   measurements;
2. record the selected correct path per shape and close G1/G3;
3. start G4 serial native MTP; and
4. continue the existing G5–G8 contract unchanged.

No stabilization result changes the Colibri performance target or licenses an
unmeasured performance claim.

## 3. State and priority vocabulary

Each ledger row has one state:

- **reported** — credible intake, but no dedicated regression has failed yet;
- **reproduced** — a deterministic test, stress case, or benchmark captures
  the old behavior;
- **disproved** — the claimed failure does not occur; preserve the evidence
  that disproved it;
- **fixed** — the reproducer is green, the focused suite is green, and the
  relevant wave gate is green;
- **deferred** — the risk is outside the supported threat/deployment model and
  has a named trigger for reopening.

Priority means:

- **P0:** security boundary, native lifetime, cancellation/runaway work, or a
  global resource lease that can wedge the product;
- **P1:** user-visible silent corruption, broken advertised behavior, or
  durable output loss;
- **P2:** bounded leaks, cold-path ownership, test/typecheck coverage, and
  misleading dead code;
- **P3:** performance hypothesis; measure first, optimize only if material;
- **D:** conditional deployment hardening, not active product work.

## 4. Intake ledger

Active rows begin in **reported**; the three deployment rows begin in
**deferred**. The “proof to close” column is the minimum evidence needed to
change that state.

| ID | Pri | State | Discovery anchor | Failure or invariant | Proof to close |
|---|---:|---|---|---|---|
| PERF-01 | P3 | fixed | `src/server.ts`, `StreamDecoder.push` | `push()` decoded the full accumulated ID list on every token, giving an O(n²) code shape across streaming surfaces. | Deterministic tokenizer-only scaling benchmark at several output lengths; optimize only if the curve and wall time are material, then preserve exact emitted bytes/chunk boundaries. |
| PERF-02 | P3 | fixed | `src/generate.ts`, `readExtras` | Serial `logprobs`/`top_logprobs` readback placed `astype` work behind the already-dispatched next step and serialized decoding. Direct integer reads plus host bf16/f16 expansion remove the barrier. | Quiet-machine paired generation benchmark with logprobs off/on and a timeline or per-token latency signal; patch must recover overlap without changing logprob values. |
| CANCEL-01 | P0 | fixed | `src/anthropic.ts`, `src/responses.ts` SSE translators | Canceling the outer Anthropic or Responses stream does not cancel its upstream OpenAI stream. | A synthetic slow upstream records `cancel()` exactly once when the translated reader is canceled; normal completion and upstream error behavior remain exact. |
| CANCEL-02 | P0 | fixed | `src/server.ts`, non-streaming chat/completions | Client abort is not threaded into non-streaming gateway generation, so abandoned work can retain the serial lane. | End-to-end abort test proves generation stops, the lane/row is released, and a following request begins promptly for chat and text completions; protocol shims inherit the same signal. |
| JOB-01 | P0 | fixed | `src/jobs/runner.ts`, `spawnNow` | The GPU lease is assigned before `Bun.spawn`; a synchronous throw can leave `isGpuBusy()` true forever. | Inject a throwing spawn, assert failed job state, null lease, and successful queue drain/next job. |
| LIFE-01 | P0 | fixed | `src/expert-io.ts`, `wait`/`close` | `wait()` polls again after an await without re-checking closure while `close()` may free the native pool. | Native stress test races pending waits with close repeatedly under the existing helper; no post-close FFI call, crash, stale read, or leaked waiter. Define whether close waits, cancels, or makes wait reject. |
| ADAPTER-01 | P1 | fixed | `src/lora.ts`, adapter shape validation | The validator assumes mlx-lm tensor orientation and rejects real PEFT LoRA A/B tensors despite accepting PEFT names. | Tiny tracked PEFT-layout adapter mounts and produces the expected delta; mlx-lm-layout fixtures remain exact; invalid and wrong-base shapes get distinct, truthful errors. |
| TRAIN-01 | P1 | fixed | `src/train/lora-params.ts`, adapter config writes | Two un-awaited `Bun.write` calls can let successful training exit before mount metadata is durable. | Inject delayed writes and prove save completion waits for both JSON files; immediately reopen/mount the returned adapter directory. |
| EVAL-01 | P1 | fixed | `src/eval/ifeval.ts` and `src/eval/tasks/ifeval.ts` | Two scorer implementations have different coverage and unknown-instruction/strict-loose semantics while both present results as IFEval. | Choose one canonical scorer and metric schema; run one frozen response corpus through every public entrypoint and prove identical labeled results. If a legacy subset remains, rename it so results cannot be compared accidentally. |
| METRIC-01 | P1 | fixed | `src/train/trainer.ts`, `countResponseTokens` | Batched SFT throughput counts padded sequence length, inflating tokens/s for B>1. | Unequal-length batch fixture reports only supervised, non-padding response tokens and matches a manual count. |
| TRAIN-02 | P1 | fixed | `src/train/trainer.ts`, optimizer construction | `loraPlusRatio` is accepted for SFT/DPO but only creates per-leaf LR scales in ORPO. | Either wire the same A/B LR-scale contract into all three methods with optimizer-state tests, or reject the option outside supported methods at parse/CLI/API boundaries and document that scope. |
| STORE-01 | P1 | fixed | `src/responses.ts`, `ResponseStore.#evictExpired` | LRU touches change map insertion order but not `createdAt`; early-break expiry can leave expired entries after a fresh entry. | Fake-clock test creates, touches, advances, and proves every expired ID is gone regardless of LRU order while byte accounting stays exact. |
| GRAMMAR-01 | P1 | fixed | `src/server.ts`, guided degrade prompt | Graceful grammar degradation can inject a system message whose `content` is null, causing the fallback request itself to fail. | A request for every degrading `guided_*` form reaches generation with a valid string/content shape and carries an explicit Warning header. |
| GRAMMAR-02 | P1 | fixed | `src/generate.ts`, grammar jump gate | Jump-forward excludes `logprobs` but not `topLogprobs`, so forced tokens can emit empty logprob records. | `topLogprobs > 0` test cannot enter a jump path that lacks complete rows; emitted token/logprob counts and values stay aligned. |
| LEAK-01 | P2 | fixed | `src/diffusion/diffusion-generate.ts`, stable/confident stop | A precomputed soft-embedding tensor can be abandoned on early stop. | Forced early-stop fixture returns native/MLX live-handle counts to baseline over repeated runs. |
| LEAK-02 | P2 | fixed | `src/weights.ts`, `Weights.open` failure | Loader failure can leak the current array-map handle plus maps retained from earlier shards. | Fail loading shard N and assert every array/meta map from shards 1..N is freed exactly once. |
| LEAK-03 | P2 | fixed | `src/mlx/{autograd,checkpoint,custom-vjp}.ts` constructors | Failure out-parameter slots are initialized with live handles that may not be freed when native constructor calls fail. | Failure-injection tests for all three constructors prove slots, closures, and callbacks return to baseline with no double free. |
| HYG-01 | P2 | fixed | `src/train/job.ts`, empty Gemma block | A config read and stale comment claim load-bearing environment setup, but the branch is empty. | Remove the read/block/comment; job parsing and training setup tests stay green. |
| HYG-02 | P2 | fixed | `tsconfig.json` exclusions | Shipped web sources and tests that run in the gate are excluded from the zero-error typecheck contract. | Remove the exclusions or replace them with an explicit checked project reference; repository and web typechecks are green with no hidden files. |
| HYG-03 | P2 | fixed | `scripts/test.sh` test glob | `scripts/bench-serving-load.test.ts` is model-free but outside the gate. | Gate enumerates and runs it exactly once; a sentinel/failing-case check proves it cannot silently fall out again. |
| SEC-01 | P0 | fixed | `src/web-tools.ts`, `web_fetch` | Model-selected URLs bypass the existing public-destination policy, follow redirects automatically, and buffer the full body. This permits SSRF into loopback/private services and unbounded response buffering. | Reuse one shared fetch-policy implementation: reject private literals and DNS resolutions, revalidate every redirect, combine caller abort with timeout, and stream to a byte cap. Tests cover loopback, private DNS, public-to-private redirect, redirect limit, chunked over-cap, and normal public text. |
| SEC-02 | P1 | fixed | `src/download.ts`, `blobId` | An unvalidated blob ID reaches `join()` and symlink creation, unlike the adjacent validated digest. It requires a hostile HF-compatible endpoint. | Reject any non-lowercase-40-hex SHA-1 blob ID before path construction; traversal and malformed-ID tests fail closed. |
| DEPLOY-01 | D | deferred | `src/server.ts`, WebSocket upgrade | No WebSocket Origin enforcement. | Deferred while bind is loopback-only. Reopen before any supported non-loopback bind, tunnel, reverse proxy, or browser origin; then add an allowlist and cross-origin rejection tests. |
| DEPLOY-02 | D | deferred | `src/server.ts`, `/api/*` mutation routes | Browser-accessible state-changing routes have no CSRF/origin policy. | Same deployment trigger as DEPLOY-01; define trusted origins/auth before exposing the control plane. |
| DEPLOY-03 | D | deferred | `src/server.ts`, CORS headers | Wildcard CORS would be unsafe in a remotely reachable deployment. | Same deployment trigger as DEPLOY-01; replace wildcard policy as part of one remote-exposure threat-model change, not as isolated lines today. |

### Evidence log

- **Frozen baseline:** `2cd6e35`, Bun `1.3.14`, loopback-only supported
  deployment. The initial gate isolated an e4b chirp trajectory mismatch and
  a mixed-KV teacher-forced logit mismatch; both are resolved below rather
  than carried as hidden exceptions.
- **Wave 1:** 134 focused tests passed across web fetch/media policy,
  expert-I/O, jobs, generation gateway, protocol translators, and the live
  server. Coverage includes private DNS and redirects, chunked response caps,
  250 wait/close races, synchronous spawn failure plus queue drain, translated
  stream cancellation exactly once, request abort, and immediate serial-lane
  reuse.
- **Wave 2:** 91 focused tests passed across adapters/training, IFEval,
  ResponseStore, grammar, download, and the live server. Evidence includes a
  real PEFT-layout numeric delta, delayed config writes plus immediate remount,
  unequal padded rows, shared LoRA+ leaf scales for SFT/DPO/ORPO, frozen-corpus
  scorer equivalence, fake-clock reordered LRU expiry, every guided degrade
  form, the `topLogprobs` jump gate, and malformed SHA-1 IDs.
- **Wave 3 focused gate:** 197 tests passed. Fifty diffusion early-stop loops
  dispose 300/300 targeted wrappers with flat active memory; 200 shard-N
  loader failures free every current/prior map exactly once; all three native
  transform constructors return slots, closures, and callbacks to zero under
  repeated failure injection. The root typecheck now includes DOM/web sources
  and the formerly excluded web tests. `scripts/test.sh` enumerates
  `scripts/bench-serving-load.test.ts` exactly once and rejects gate drift.
- `bunx tsc --noEmit`, `bun scripts/check-hygiene.ts`, `bash -n
  scripts/test.sh`, and `git diff --check` are green after Wave 3. The full
  post-Wave-3 repository gate and both performance measurements remain open.
- **Post-wave audit:** public-address fetches now dial the DNS-checked IP while
  preserving the logical Host/SNI, closing the validation/connect rebinding
  window. The gateway owns grammar disposal even for already-aborted and
  queued-aborted requests. A live server test covers both chat and text
  completion cancellation and every guided degrade form; it caught and fixed
  the non-ASCII `Warning` header value that helper-only coverage missed.
  Standard PEFT `use_rslora` now mounts and saves at exactly
  `alpha / sqrt(rank)`. Custom-VJP also frees the first callback if allocation
  of the second callback throws.
- **PERF-01:** `scripts/bench-stream-decoder.ts` measured the original
  full-history decoder against the bounded exact-suffix implementation with
  five paired repetitions. MiniCPM5 medians were 142.62 → 27.40 ms at 512
  tokens (5.20×), 576.01 → 56.45 ms at 1,024 (10.20×), and 2,284.57 →
  115.16 ms at 2,048 (19.84×; before IQR 2,258.83–2,297.20 ms, after
  113.62–116.06 ms). Every per-push chunk and final byte stream matched at
  64–2,048 tokens; the e4b 1,024-token check was 88.62 → 10.25 ms. Raw,
  gitignored artifacts are under `reports/perf-01-stream-decoder-*.json`.
- **PERF-02:** `scripts/bench-logprobs-readback.ts` confirmed the reported
  barrier on a clean M1 Max 32 GB with Bun 1.3.14 and
  Qwen2.5-0.5B-Instruct-4bit (256 tokens, two warmups, five measured rounds).
  At clean base `00e597e`, off/logprobs/top-5 medians were
  802.75/1,185.89/1,354.21 ms: logprobs cost 1.477× and top-5 cost 1.687×.
  Clean fix commit `b1cb7cb` measured 803.94/802.77/856.24 ms:
  0.999× and 1.065× the off arm. The off control moved only 0.15%; selected
  logprob throughput rose 220.52→329.18 tok/s and top-5 rose
  192.69→307.63 tok/s. All 40 parity checks passed; all 1,280 selected values
  and all 1,280 emitted top-k entries were bit-exact with zero maximum delta.
  Raw gitignored artifacts:
  `scripts/reports/perf02-logprobs-readback-2026-07-30T04-40-09-139Z.json`
  (before) and
  `reports/perf02-logprobs-readback-2026-07-30T04-50-06-626Z.json` (after).
  The focused affected-path gate is 100/100 green, with typecheck, hygiene,
  and diff checks green.
- **Oracle-drift closeout:** the e4b frontend differs from the oracle mel by
  at most `4.768e-7`, inside the existing `1e-5` T0 contract. With the oracle
  mel, the tower output is byte-exact at the actual bf16/divide language-model
  splice boundary. The allowed frontend residual changes only a handful of
  bf16 values and crosses a later greedy near-tie (`contains`/`features`) with
  the same factual chirp description, so the fixture now gates exact splice
  IDs/counts and the decoded fact. The mixed-KV mismatch was stale untracked
  `.bin` data: regenerating with MLX `0.31.2`, mlx-lm `0.31.3`, OptiQ `0.2.15`,
  and model revision `5b1101065d2094c8f12aa87fee80e0afa5b292b7` makes all
  four logit steps bit-exact. Its tracked manifest now records that provenance
  and each blob's SHA-256, which the parity test verifies before comparison.
- **Repository closeout gate:** `bash scripts/test.sh` completed both shards:
  shard 1 passed 760 with 42 skips across 107 files; shard 2 passed 1,097 with
  29 skips across 108 files. Total: 1,857 pass, 71 intentional skip, zero
  failures. Typecheck, hygiene, and diff checks are green. The formal exit is
  closed and Phase 21 is unpaused at its G1/G3 quiet-machine measurements.

## 5. Execution waves

### Wave 0 — freeze the baseline and open the ledger

- Record the current commit, Bun version, test/typecheck commands, and supported
  deployment assumption (loopback only).
- Treat reproduction as a rolling gate in risk order: establish the P0 cases
  first and fix them without waiting for every later-wave reproducer.
- For each active row, add the smallest deterministic failing test or, for
  PERF-01/PERF-02, an honest baseline benchmark.
- Change a row to **reproduced** or **disproved** before editing its production
  path. A statically obvious one-line ownership bug still needs failure-path
  coverage.
- Keep fixtures model-free where possible. Any model/quiet-machine step is
  labeled USER-RUN and may not be silently replaced by a loaded-machine number.

### Wave 1 — stop unsafe and runaway work

Land independent changes in this order:

1. **SEC-01** — shared SSRF/redirect/body-cap policy;
2. **LIFE-01** — native wait/close lifetime contract;
3. **CANCEL-01 + CANCEL-02** — one end-to-end cancellation vertical slice
   across OpenAI, Anthropic, and Responses surfaces; and
4. **JOB-01** — exception-safe GPU lease ownership and queue drain.

Wave gate: focused suites plus cancellation-after-abort follow-up requests,
native wait/close churn, and full model-free tests. No P0 row may be deferred
without a new product-scope decision in `PLAN.md`.

### Wave 2 — restore advertised correctness and durable output

Use small review units:

1. **ADAPTER-01 + TRAIN-01** — adapters can be produced durably and mounted in
   both supported layouts;
2. **TRAIN-02 + METRIC-01** — training knobs and throughput accounting mean
   what the API says;
3. **EVAL-01** — one canonical, clearly labeled IFEval result;
4. **STORE-01** — TTL and LRU are separate correct invariants; and
5. **GRAMMAR-01 + GRAMMAR-02 + SEC-02** — protocol/data validation edges.

Wave gate: all focused fixtures, one save-then-immediate-mount adapter flow,
frozen-corpus scorer equivalence, and the full model-free suite.

### Wave 3 — close resource and gate debt

1. Fix **LEAK-01**, **LEAK-02**, and **LEAK-03** with failure/early-exit handle
   accounting.
2. Remove **HYG-01**.
3. Close **HYG-02** and **HYG-03** last so the enlarged type/test gate judges
   all earlier work.

Wave gate: repeated failure-path loops stay flat, `bunx tsc --noEmit` covers
the newly admitted sources, hygiene is green, and `scripts/test.sh` executes
every model-free test including the serving-load test.

### Wave 4 — measure before optimizing

Run **PERF-01** and **PERF-02** only after correctness and cancellation have
stabilized the baseline.

- Preserve raw benchmark artifacts outside curated results.
- Record tokenizer/output lengths, model/config where applicable, warmup,
  repetitions, median and spread, and machine load.
- Optimize only when the measured cost is material to an affected surface.
- Require paired before/after results plus exact output parity. If the effect
  is immaterial, mark the row **disproved** or **deferred with evidence**; do
  not land speculative complexity.
- Curate a number into `benchmarks/RESULTS.md` only when it passed the
  repository’s quiet-machine preflight.

### Wave 5 — deployment decision and closeout

- Keep **DEPLOY-01..03** deferred together while loopback-only is an enforced
  product invariant.
- Before adding a non-loopback flag, tunnel quickstart, or reverse-proxy
  support, reopen all three as one threat-model/API project. “Ten easy lines”
  are not sufficient without deciding trusted origins and authentication.
- Run the final exit gate, update this ledger’s states/evidence, update
  `STATUS.md`, and explicitly unpause Phase 21.

## 6. Per-item working loop

Every active item uses the same loop:

1. **Revalidate:** trace the current call/data path and replace stale line
   numbers with symbol-level anchors.
2. **Reproduce:** check in the minimal red regression, failure injection,
   stress case, or baseline benchmark.
3. **State the invariant:** describe ownership, cancellation, metric, or
   protocol behavior in one sentence before choosing a fix.
4. **Patch narrowly:** one invariant per branch/commit. The cancellation
   vertical slice and closely coupled adapter save/mount work are deliberate
   exceptions.
5. **Adversarial pass:** test abort during await, constructor throw, redirect,
   partial write, reordered LRU, unequal padding, and repeated teardown as
   appropriate—not just the happy path.
6. **Run gates:** focused test, affected subsystem suite, then the current wave
   gate.
7. **Document with the behavior:** any served field, warning, default, flag, or
   support claim updates README/reference docs in the same change.
8. **Close honestly:** record **fixed**, **disproved**, or **deferred**, with
   the exact test/benchmark artifact. Do not close on “code looks right.”

Recommended branch/PR naming is `fix/<ledger-id>-<slug>`. Keep at most two
independent changes in flight and avoid concurrent edits to `server.ts` or
`generate.ts`. Merge in wave order; rebase and rerun the focused reproducer
after any overlapping merge.

## 7. Gate matrix

| Area | Required focused evidence |
|---|---|
| Protocol cancellation | `tests/{server,anthropic,responses}.test.ts`; slow synthetic source; cancel/abort followed by immediate lane reuse |
| Jobs | `tests/jobs.test.ts`; injected synchronous spawn failure and queue drain |
| Native expert I/O | `tests/expert-io-native.test.ts`; repeated wait/close race and post-close-call detection |
| Web fetch/download security | `tests/{web-tools,download}.test.ts`; private DNS/redirect, body cap, traversal/malformed IDs |
| Adapters/training | `tests/{lora,train-*,ifeval}.test.ts`; delayed writes, PEFT + mlx-lm layouts, unequal padding, optimizer LR scales, frozen scorer corpus |
| Grammar/Responses store | `tests/{grammar,grammar-jump,responses,server}.test.ts`; degrade forms, top-logprob alignment, fake-clock reordered LRU |
| MLX/resource ownership | focused diffusion/weights/autograd/checkpoint/custom-VJP failure loops with handle/allocation baselines |
| Repository gate | `bun scripts/check-hygiene.ts`, `bunx tsc --noEmit`, `bash scripts/test.sh`; prove `scripts/bench-serving-load.test.ts` is included |
| Performance | deterministic raw artifact, paired A/B, exact output parity, quiet-machine preflight before any curated claim |

## 8. Exit gate

Colibri may resume only when:

- every P0 and P1 row is **fixed** or **disproved** with checked-in evidence;
- every P2 row is fixed, disproved, or explicitly parked with a bounded impact
  and owner;
- PERF-01 and PERF-02 have measured baselines and are either fixed with paired
  wins or closed without an optimization claim;
- cancellation is proven end-to-end on streaming and non-streaming protocol
  surfaces, including prompt lane reuse after abort;
- native lifetime and constructor/load failure stress tests stay flat;
- SSRF redirect/DNS/body-cap and blob-ID tests are green;
- typecheck and the complete model-free gate are green with the former
  exclusions removed and the serving-load test included;
- documentation matches any changed public behavior; and
- `STATUS.md` names the exact Phase 21 resume action: finish the G1/G3 quiet
  matrix/path choice, then begin G4.

The deferred deployment trio does not block this exit while the product
remains loopback-only. Any decision to support remote exposure invalidates
that deferral and reopens all three together.
