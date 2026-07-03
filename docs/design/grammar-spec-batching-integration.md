# Grammar × spec decode × batching — integration plan + feature-matrix benchmark

Status: **Phases A, B, C, E EXECUTED 2026-07-03** (same day as the plan);
Phase D open (extend-join, vectorized sampling, KV-budget admission).
Execution log at the bottom of this doc. Successor plan tying together
three workstreams so they compose deliberately instead of colliding:

- **Structured output** — SHIPPED on main (serial + batched lanes;
  docs/design/structured-output.md). Open debt: B2 model-gated batch
  tests + bench, F4 compiler cache, F5 regex, F6 escaping, F7 structural
  tags, U1/U2 engine upgrades.
- **Batching perf path** — P5 done; P0–P4 open
  (docs/design/batching-perf-path.md).
- **Speculative decoding** — research proven (assistant drafter bit-exact
  vs optiq, 12B γ=1 ≈ 1.09× win, docs/design/spec-decode-larger-targets.md;
  DSpark architecture verified, docs/investigations/dspark-handoff.md) but
  **not served**: no `--draft-model`. Build plan already written:
  docs/design/mlx-lm-tool-parity-plan.md §7 (the `DraftSource` interface,
  two-model L1 source, serve loop, admission, prompt-cache composition).

This doc does NOT restate those plans — it sequences them, defines the
composition rules where they meet, and specifies the benchmark that
measures every combination. The per-feature designs stay canonical in
their own docs.

## The composition matrix (v1 target state)

`GenerationGateway.willBatch` is the single routing point; every rule
below is one predicate there. "Serial" routing is a v1 rule, not a
limitation to hide — upstream mlx-lm routes spec serial too
(`is_batchable = draft_model is None`, server.py:371).

| Request shape | Lane | Mechanism | Status |
| --- | --- | --- | --- |
| plain | batch (or serial) | shipped engine | DONE |
| grammar only | batch (or serial) | B1 per-row matchers / serial mask loop | DONE (B2 gates open) |
| spec only | **serial** | `hasDraft` routes serial (upstream parity) | Phase B |
| grammar + spec | **serial** | constrained verify walk (novel — §Phase C) | Phase C |
| batch + spec | serial per request | `hasDraft` wins over batch | Phase B (routing) |
| batch + grammar + spec | serial per request | `hasDraft` wins | falls out of B+C |

Non-goals (explicitly out of scope, revisit only on measured demand):
per-row spec inside the batch scheduler (variable accept-lengths break
uniform-B; a research project, not a feature gap), DSpark as a served
source before its 27B retrain/data-scale lands, grammar on the
`/v1/responses` shim beyond what chat inheritance already gives.

## Phases

Ordering rationale: A is small and closes the trust gap on what already
shipped. B is the flagship parity feature and lays the `DraftSource`
seam C needs. C is the novel composition. D runs parallel to B/C
(scheduler files vs serial-loop files — near-zero overlap). E needs all
of them and produces the numbers.

### Phase A — structured-output debt (B2 + F4)  [S, 2–3 days]

1. **B2 model-gated scheduler tests** (spec'd in structured-output.md):
   mixed batch mask isolation; **all-grammar B=4 with four different
   schemas** (THE bug-class gate — row↔matcher misalignment after
   eviction/join); early termination + churn + joiner; max_tokens
   mid-JSON truncation under batch; prefill-terminated row never merges.
2. **F4 compiler cache**: one `GrammarCompiler` per `TokenizerInfo`
   (both vocab-structural; `ownsCompiler=false` path already exists).
   Measure compile time cold vs cached on a real JSON schema — this is
   the agentic-replay win and a benchmark row in Phase E.
3. Opportunistic: F6 choice escaping (tiny), F3 explicit padded-vocab
   comment. F5/F7 stay parked for the structural-tag pass (see Later).

Exit: gated suites green on cpm5 + e4b; compile-cache A/B number
recorded.

### Phase B — `serve --draft-model` (two-model, serial lane)  [M, ~1 wk]

Execute mlx-lm-tool-parity-plan.md §7 as written (it is already the
hand-to-an-implementer plan). Integration deltas this plan adds:

- **`RequestShape.hasDraft`** beside `hasGrammar`; `willBatch` returns
  false for it. Lane-debug line includes it. (The B0-grammar routing
  pattern, reused verbatim.)
- **The serve verify loop lands grammar-aware from day one**: the loop
  emits bursts of ≤ n+1 tokens; the stop-sequence/detokenizer audit in
  §7 ("risky parts") must treat the grammar mask hook as a first-class
  participant even while it's unused in this phase — i.e. the per-round
  walk is structured as `for pos in verifyWindow: sample(logits[pos],
  maskHook?)` so Phase C is a hook implementation, not a loop rewrite.
- **Kill switch** `MLX_BUN_SPEC=0` (degrade: ignore the flag, log once),
  house style.

Oracle: L1 spec-vs-spec token equality with `mlx_lm.server
--draft-model` from the oracle venv (§7.8). Acceptance telemetry
(`drafted/accepted/targetCalls`) in stats — Phase E consumes it.

Exit: greedy token-for-token vs mlx-lm spec on a fixed pair; rotating
wrap falls back non-spec (no 500); `--batch 4` + `--draft-model` routes
spec requests serial and batches the rest; admission accounts for draft
weights + KV.

### Phase C — grammar × spec: the constrained verify walk  [M, ~1 wk]

Novel territory — **no oracle serves grammar+spec** (mlx-lm has no
grammar; oMLX has no spec). L3-class gating per the parity-tier
contract: equivalence + validity gates, not bit-parity to an ancestor.

Design (v1 = verify-side masking, drafter free-running):

1. **Drafter is unconstrained.** Drafts are proposals; correctness never
   depends on them (a grammar-invalid draft is simply rejected at
   verify). No matcher state touches the draft path.
2. **The verify walk applies the mask sequentially.** One batched target
   forward over `[pending, ...drafts]` (n+1 positions) as in Phase B;
   then the host-side accept walk goes position by position:
   `mask_i = matcher.bitmask` → apply to `logits[i]` → sample → if
   sampled == draft_i: `matcher.accept(draft_i)`, continue; else emit
   the masked correction token, `matcher.accept(correction)`, stop.
   The matcher only ever advances on **emitted** tokens — no rollback
   needed in v1. Sequential bitmask fills cost 0.004–0.19 ms each
   (measured, structured-output.md); at γ≤3 that's ≤0.8 ms/round against
   a 12B target step of ~40 ms — noise.
3. **Grammar termination mid-burst** truncates the accepted prefix at
   the terminating token (same all-`-inf` guarantee as serial/batched:
   nothing is sampled past termination), finish_reason "stop".
4. **The measured fork** ([[flag-and-try-both-on-forks]]): on
   grammar-tight spans (e.g. `guided_choice`, closing braces) a
   free-running drafter's acceptance may crater — every draft off-grammar
   is a wasted round. If Phase E shows that, the alternative is built
   behind `MLX_BUN_SPEC_GRAMMAR_DRAFT=1`: mask the drafter's logits too
   (matcher advances per draft, `rollBack(n − kAccept)` on rejection —
   the WASM API exposes rollBack; this is its use case). Build the flag
   only if the default's acceptance number demands it; don't pre-build.

Gates (no external oracle):
- **Equivalence**: greedy grammar+spec long-prefix-equal to greedy
  grammar-only serial on fixed prompts (exact-match acceptance means
  spec must reproduce the non-spec masked-greedy stream, modulo the
  documented batched-verify-head knife-edges — same caveat class as L1
  spec-vs-spec).
- **Validity**: every grammar+spec output parses / conforms to its
  schema (100%, no exceptions), matcher never rejects an emitted token.
- **Composition regression fence**: grammar-only and spec-only suites
  byte-unchanged.

### Phase D — batching P0 (+ admission slice of P3)  [M, ~1 wk, parallel with B/C]

From batching-perf-path.md, the subset that the benchmark needs and that
doesn't collide with B/C's serial-loop work:

1. **P0**: `scripts/bench-serving-load.ts` (N concurrent vs live server,
   aggregate tok/s + TTFT p50/p95 at the SSE first-token event) —
   Phase E builds on this harness; `extend` join (kill the O(B·S)
   re-merge); vectorized homogeneous-sampler fast path.
   - `extend` + grammar rows: the B1 read-before-build step must hold
     across an extend-join — add one B2-style churn test with a joiner
     landing while a grammar row is live.
2. **P3 admission slice only**: `projectKvBytes` + `--kv-budget`
   queueing (the OOM backstop the combined benchmark needs before it
   pushes B=4 × long prompts on 24 GB). Prompt-cache-under-batching,
   adapters, and the default flip stay in batching-perf-path P3.

P1 (quantized KV at B>1) and P2 (perf kernel at B>1) are NOT in this
plan's critical path — they're the next wave after the matrix benchmark
exists, and the benchmark is exactly what will size their payoff.

### Phase E — the feature-matrix benchmark  [S–M, 3–4 days]

One harness answering "what does each feature — and each legal
combination — cost or buy, per model?" Extends P0's
`bench-serving-load.ts`; preflight-gated like benchmark.sh (dirty-machine
numbers are garbage; quotable rows need the clean-machine protocol).

**Cells** (skip-if-unavailable, like the model-gated suites):

- Lanes/features: `serial`, `batch4`, `serial+grammar`, `batch4+grammar`,
  `serial+spec`, `serial+grammar+spec` — the six legal shapes from the
  matrix. (batch+spec cells route serial by design; the harness records
  them as routing checks, not perf rows.)
- Models: cpm5 + e4b (fast movers, both lanes), 12B (+ its assistant
  drafter — the measured spec win), Qwen3.5 (batch + thinking-model
  grammar canary; grammar cells expected to expose F7 until structural
  tags land — record, don't hide).
- Workloads: short-chat (128 tok), JSON-extraction (a real schema,
  grammar cells), long-form (512 tok). 4 concurrent for batch cells,
  1 for serial cells; N=3 median.

**Metrics per cell**: aggregate + per-stream decode tok/s · TTFT
p50/p95 (SSE first token, wall-clock) · spec acceptance
(drafted/accepted/targetCalls) · grammar overhead vs the same cell
without grammar (%) · schema-conformance rate (**must be 100% in every
grammar cell — a conformance failure fails the run, it's a correctness
gate wearing a benchmark costume**) · peak RSS.

**Denominator discipline** (spec-decode-larger-targets.md): every
feature cell is compared to the SAME model+lane baseline cell from the
SAME run. No cross-model or cross-run speedup claims.

**Output**: eval-DB rows tagged `feature-matrix[<host>]` + a dated
markdown artifact (gitignored, like benchmark.sh's); promoted rows land
in benchmarks/RESULTS.md under a new "composition" table. Josh-gated
clean-machine run for anything quotable.

Exit: the matrix runs end-to-end on this machine; a first
(loaded-machine, unquotable) sweep sanity-checks every cell; the
clean-machine run is queued in STATUS Josh-gated.

## Later / parked (pointers, so they aren't lost)

- **F7 + F5 structural-tag pass** (thinking-model grammar + real regex)
  — try the installed WASM package's `fromStructuralTag`/`RegexFormat`
  first; U1 rebuild only if its Dec-2025 core predates the semantics
  (structured-output.md addendum). Qwen3.5's grammar cells in Phase E
  are the forcing function.
- **U2 native XGrammar-2 via TVM-FFI** — trigger conditions unchanged
  (B≫8, spec+grammar draft-tree masking via `traverse_draft_tree`, or
  compile time visible despite F4). Phase C's v1 walk deliberately
  avoids needing it.
- **Batching P1/P2** (quant-KV + perf kernel at B>1) — next wave, sized
  by the matrix.
- **P4 device-side step chaining** — orthogonal serial-decode work; the
  matrix's serial baselines will show its headroom.
- **Assistant/DSpark sources behind `--draft-model`** —
  mlx-lm-tool-parity-plan §7.9; DSpark stays research until 27B
  retrain + data scale (dspark-handoff.md).
- **Spec inside the batch lane** — research question, not scheduled.

## Execution log (2026-07-03)

- **Phase A** ✅ — B2 gates in `tests/batch-grammar.test.ts` (all five
  scenarios + a sixth found later, below); F4 compiler cache went through a
  bring-up fix (single-flight rebuild — concurrent compiles after a
  tokenizer switch double-disposed the previous compiler); F6, F3 landed.
- **Phase B** ✅ — `serve --draft-model`/`--num-draft-tokens`;
  `src/spec/{source,two-model,serve-loop}.ts`. **L1 gate: 48/48
  token-for-token vs mlx-lm spec** (Llama 3B+1B greedy, 65% acceptance,
  `scripts/oracle-spec-two-model.py`). Deviations as designed (ring-wrap
  degrades pre-pollution via an offset+n+1 gate — upstream's post-hoc check
  would already have polluted the ring; prompt cache bypassed v1).
- **Phase C** ✅ — the constrained verify walk in `samplePos`; gates green
  (100% validity; 12/12 token-identical to grammar-only serial; choice
  terminates mid-spec). Drafter-masking flag NOT built (acceptance 6/15 on
  a tight schema — usable; revisit only if Phase E's clean run says so).
- **Phase E** ✅ (harness) — `scripts/bench-feature-matrix.ts` (the planned
  bench-serving-load extension became its own script: that file already
  exists as a client-only stack-vs-stack tool and stays one). Six cells
  green end-to-end on Llama 3B+1B; `usage.speculation` telemetry on all
  four API usage blocks. Clean-machine run for RESULTS.md is Josh-gated.
- **The conformance gate paid for the whole phase in one smoke run** —
  three real bugs: (1) snake_case wire fields never reached the grammar
  resolver (structured output was DEAD over HTTP since it landed);
  (2) `#flushPipeline` didn't advance matchers → stale masks on mid-decode
  joins (regression test added); (3) **UniversalDenseModel batched RoPE
  uses the scalar cache.offset** → uneven-row batches decode joiners at
  wrong positions — latent for ALL Tier-0 archs since v0.0.9. **Fixed
  same day**: `UniversalRope.applyDynamic` (+ `ops.ropeScaledDynamic`)
  routes the wrapper's per-row `ropeOffsetArr`; gated **token-exact vs
  mlx-lm B=2 on Llama-3.2-3B** — static uneven rows AND the dynamic
  join/leave protocol (tests/batched-decode-parity.test.ts "Llama 3B
  Tier-0"). Plain full-attention universal archs now batch; maskArray
  (gemma2-family, pad-blind causal mask in forwardLayers) and
  sliding-window universal archs remain serial (unvalidated cells).
  Lesson, per [[per-model-quant-specialization]]: the gateway's
  capability gate admitted a model family no batched-parity suite ever
  validated.

## Risks

- **Grammar+spec has no oracle** — mitigated by the three-gate stack
  (equivalence to grammar-only greedy, 100% validity, regression fence)
  and by keeping the drafter out of the grammar state in v1.
- **Multi-token bursts through stop-sequence/detokenizer state** — the
  known §7 risky part, now load-bearing for two phases; land the burst
  audit with Phase B tests, not after.
- **Memory at 12B+drafter / B=4 on 24 GB** — Phase D's admission slice
  is the backstop; benchmark cells must go through it, not around it.
- **Scope creep via the matrix** — the benchmark measures what exists;
  it must not become a reason to build P1/P2/drafter-masking
  speculatively. Each parked item has its trigger written above.
