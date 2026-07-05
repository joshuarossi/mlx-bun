# Structured output (grammar-constrained decoding) — design

Status: LANDED (2026-07-02). Adoption-map item #1
(`docs/design/omlx-adoption-map.md`). L2-class (oMLX is the oracle).

## What it is

OpenAI/oMLX/vLLM-compatible `response_format` + `guided_*` fields on
`/v1/chat/completions` and `/v1/completions`, enforced at the sampler via
**grammar-constrained decoding**: a per-step token bitmask masks invalid
logits to `-inf` before sampling, guaranteeing the generated text is valid
JSON (or matches a JSON schema, regex, EBNF grammar, or enum choice).

| Field | Compiles to | Example |
| --- | --- | --- |
| `response_format: {type:"json_object"}` | xgrammar builtin JSON grammar | any valid JSON |
| `response_format: {type:"json_schema", json_schema:{name,schema,strict}}` | `compileJSONSchema(schema)` | `{"name":"…","age":N}` |
| `guided_grammar` (EBNF/LARK) | `Grammar.fromEBNF` | `root ::= "\"" [a-z]+ "\""` |
| `guided_regex` | EBNF-wrapped regex | `[A-Z]{3}\d+` |
| `guided_choice` (enum) | `root ::= ("a"\|"b"\|"c")` | `["yes","no","maybe"]` |
| `structured_outputs` | bare schema (alias for json_schema.schema) | — |

From our side it's **one shape**: compile something → `GrammarMatcher` →
per-step bitmask → mask logits. The only difference between modes is which
xgrammar compile method we call. Precedence mirrors oMLX's
`_effective_guided_grammar`: `guided_grammar > json_schema > json_object >
structured_outputs > guided_regex > guided_choice`.

## Engine choice: `@mlc-ai/web-xgrammar` (WASM)

The **official MLC-ai xgrammar WASM/JS build** (Apache-2.0, same authors as
xgrammar). Same engine oMLX uses, just WASM-packaged. Chosen over a C/ABI
FFI shim because:

- **No native build.** No `libxgrammar.a` linking, no `extern "C"` shim, no
  `build-binary.sh` changes, no signing/notarization concerns. It's an npm
  dep that ships WASM, same as any JS dep.
- **Behavioral parity by construction.** Same engine → same bitmask
  semantics, same schema→grammar compilation, same structural-tag handling.
- **Fast enough.** Measured per-step `getNextTokenBitmask` on a real JSON
  walk (nanosecond timing, state-changing): 0.004–0.19 ms across Gemma 256k
  byte_fallback / Llama-3 128k byte_level / Qwen2.5 151k byte_level. <1% of
  a GPU decode step. The bitmask is CPU work either way (WASM vs C++ native
  would only differ in WASM overhead, which is negligible on M-series), so
  the C/ABI fallback was not needed. Evidence: `scripts/experiments/xgrammar-spike.ts`.

## Vocab extraction + type detection

`TokenizerInfo` is fed from data we already have. `loadVocab(tokenizer.json)`:
- `encoded_vocab` = the per-id decoded strings (the `model.vocab` object,
  inverted to an ordered array).
- `vocabType`: `decoder.type=="ByteLevel"` → `byte_level` (Llama-3, Qwen);
  `decoder` is a `Sequence` containing `ByteFallback` → `byte_fallback`
  (Gemma/SentencePiece); else `raw`.
- `prependSpace = (vocabType == "byte_level")` (ByteLevel pretokenizers add
  a leading space).

`TokenizerInfo` is **cached per `tokenizer.json` path** (it decodes every
vocab id once — expensive, but vocab-structural, not per-request).
`LoadedTokenizer.tokenizerJsonPath` threads the path from `loadTokenizer`.

## Integration: the pipelining tension

`GrammarMatcher.acceptToken()` needs the token id as a **JS number**,
which requires the sync GPU readback (`ops.itemUint32`). The decode loop's
pipelining defers that readback to overlap the forward; existing
logits-processors (repetition penalty etc.) operate on device-side token
arrays with no readback, so they ride the sync `LogitsProcessor` array
cleanly. Grammar can't.

Resolution: grammar requests take a slightly different loop shape in
`generate()` (`src/generate.ts`):

1. Eager-read `cur` (the just-sampled token) at the **top** of the loop.
2. `grammar.accept(tokenId)` — sync matcher advance + fires async
   `getNextTokenBitmask()` (overlaps the GPU forward dispatched just below).
3. `await grammar.ready()` — the mask for the next step is materialized.
4. `sampleStep` applies `grammar.applyMask(logits)` after the standard
   processors, before the sampler.

Non-grammar requests keep the fast pipelined loop untouched. The cost is
~0.1 ms/step of GPU idle during the eager readback (grammar is opt-in;
outputs are usually short). The mask fill (CPU WASM) overlaps the forward.

`terminateWithoutStopToken=true` on the matcher: it terminates when the
**grammar is satisfied** (e.g. the closing `}` of a complete JSON), not
only on an EOS stop token. Without this, the sampler faced an all-`-inf`
mask after the JSON closed (greedy argmax → garbage token 0, matcher
rejected, looped to max_tokens). The loop skips building the next step
once `isTerminated`.

## Degrade path (oMLX parity)

If grammar compile fails (malformed schema/EBNF), the request **degrades**,
never 500:

- `/v1/chat/completions`: inject a system message — *"You must respond with
  valid JSON matching the '<name>' schema. JSON Schema: ```json…```"*
  (ported from oMLX `api.tool_calling.build_json_system_prompt`) — and emit
  a `Warning` header.
- `/v1/completions`: no chat template to inject into, so emit the `Warning`
  header only (documented gap vs oMLX's text-completions behavior).

xgrammar's EBNF parser calls `abort()` on a parse error, but the WASM trap
surfaces as a catchable `RuntimeError: Aborted()` — the process survives,
WASM state is intact, and a later good grammar still compiles (verified in
`tests/grammar.test.ts`). The `[FATAL]/Aborted()` stderr line is xgrammar's
`LOG(FATAL)` noise, harmless.

## Kill switch

`MLX_BUN_GRAMMAR=0` disables grammar compilation entirely (requests degrade
to prompt injection). Matches the project's envelope-gated kill-switch
discipline (`MLX_BUN_COMPILED_DECODE`, `MLX_BUN_NO_FUSED_SDPA`, …).

## Tests

- `tests/grammar.test.ts` (8 tests, model-free — needs only a tokenizer.json):
  step0 mask admits the expected tight set across all five request kinds;
  accept/ready advances state; choice + EBNF + json_object + json_schema all
  mask correctly; degrade returns null on malformed grammar (abort caught);
  text/unset → null; applyMask keeps valid / -infs invalid.
- `scripts/experiments/xgrammar-spike.ts`: phase-0 perf + correctness across
  three vocab types.
- `scripts/experiments/xgrammar-parity.ts`: L2 parity vs oMLX through the
  real chat template — byte-identical content, both valid JSON.

## Known gaps / follow-ups

- **Whitespace formatting differs from oMLX.** With `anyWhitespace=true`
  (the default both use) the grammar allows any whitespace; the model freely
  picks indented (ours) vs compact (oMLX). Content is byte-identical; both
  are valid JSON. A subtle version-skew (WASM 0.1.27 vs native 0.2.0) /
  logit detail at whitespace steps. Not a correctness issue.
  - **Whitespace STALL mode** (observed 2026-07-03, B2 bring-up): unlimited
    whitespace means a whitespace-degenerate model can greedily emit
    whitespace until max_tokens (CPM5-1B base + raw prompt + a boolean
    value → tab loop after the colon, 96/96 tokens, no value emitted). Same
    exposure as oMLX (same default); chat-tuned models rarely hit it. If it
    bites in practice the knob is `anyWhitespace=false` (compact
    separators) or a whitespace-run cap — default-off, oMLX parity stays
    the default.
- **B2 batch gates: LANDED 2026-07-03** (`tests/batch-grammar.test.ts`,
  `MLX_BUN_TEST_BATCH_DECODE=1`, CPM): all-grammar B=4 four-schemas
  cross-bleed gate, mixed-batch sibling byte-match (pinned schedule),
  early-termination + churn + joiner, mid-JSON max_tokens truncation,
  prefill-terminated row never merges. Bring-up also hardened the F4 cache
  (single-flight rebuild on tokenizer switch — concurrent compiles were
  double-disposing the previous compiler). Still open from B2: the bench
  (all-grammar vs all-free at `--batch 4`) — now part of the Phase E
  feature-matrix benchmark (grammar-spec-batching-integration.md).
- **Batched lane.** LANDED (B1, 2026-07-02). The WASM build has no
  `BatchGrammarMatcher`; the batched lane (`--batch N`) uses N individual
  per-row matchers driven by the scheduler's `#stepGrammar` (read-before-build:
  read pending [B] tokens, accept per row, build forward, await ready, sample,
  emit). Terminated rows finish + evict before their slot is sampled again
  (the all-`-inf` guarantee, per row). `MLX_BUN_GRAMMAR_BATCH=0` forces serial
  fallback. A module-level `wasmQueue` serializes ALL xgrammar WASM calls — the
  single-threaded WASM instance corrupts under concurrent fills/compiles
  (BindingError, caught by the B2 test).
- **Structural tags for thinking models.** `compileStructuralTag` (permissive
  during `<think>`, constraining only the output) is supported by xgrammar
  but NOT YET WIRED. oMLX wraps the grammar in a structural tag when
  `reasoning_parser` is set; the equivalent here needs the thinking-tag
  format from `ctx.template`.
- **`/v1/responses` logprobs-style gap.** `response_format` is accepted on
  chat + completions; the Responses API shim routes through chat so it
  inherits support, but untested there.

---

# Serial review + batched-lane plan (2026-07-02)

A full read of the serial implementation (`src/grammar.ts`, the grammar
branch in `src/generate.ts`, the server wiring, the spike/parity scripts,
and the batch engine `src/serve/{generation-gateway,batch-scheduler}.ts`)
before wiring grammar into `--batch N`. Findings first, then the plan.

## What's solid (verified, keep as-is)

- **Terminal-state handling.** After the grammar's final character (e.g.
  the closing `}`) NO token is valid — the next mask is all-`-inf` and
  greedy argmax would return garbage. The serial loop handles this
  correctly at both ends: `terminateWithoutStopToken=true` makes the
  matcher terminate the moment the grammar is satisfied, and the decode
  loop skips building step n+1 when `isTerminated` (generate.ts). The
  batched lane must replicate this **per row**: a terminated row must
  never be sampled again (plan B1).
- **Perf is a measured non-issue.** Per-step `getNextTokenBitmask` on a
  real JSON walk: 0.004–0.19 ms across 128k–256k vocabs (nanosecond
  timing, `xgrammar-spike.ts`), ~constant regardless of state tightness;
  the CPU-side `applyMask` host loop is inside the <1%-of-decode-step
  envelope. At B=4 the aggregate worst case is ~0.8 ms of CPU fill work
  that overlaps GPU compute — no device-side masking needed for v1.
- **The pipelining resolution.** Eager-read the sampled token, `accept()`
  (fires the async fill), `await ready()` overlapping the next forward —
  the right shape; the batch lane reuses it (B1).
- **Degrade path** (never 500, prompt injection + Warning header, WASM
  abort is catchable) and **disposal discipline** (generate()'s finally
  owns the controller on every exit path).
- **Accept-failure policy**: a matcher reject after masking can only mean
  vocab/mask drift — warn + continue, don't kill the generation.

## Findings

**F1 — BUG (serial): stale/garbage final token at the max_tokens
boundary.** In generate.ts, `grammarTok` is only refreshed when
`generated + 1 < maxTokens`, but the token emitted is
`options.grammar ? grammarTok : ops.itemUint32(cur)` unconditionally. When
a grammar generation reaches the max_tokens cap, the LAST iteration skips
the refresh: the emitted token duplicates the previous step's token (or is
`-1` when max_tokens=1). Truncated-JSON responses end on a corrupted
token; `forwarded`/cacheTokens record the wrong id. Fix: always eager-read
`cur` when grammar is on; gate only `accept()`/`ready()` (which exist to
prepare the NEXT step) on "a next step will be built".

**F2 — CRITICAL (batch): grammar is silently dropped under `--batch N`.**
`RequestShape` has no grammar field, `GenerationGateway.willBatch()` never
checks it, and the batch branch of `gateway.run()` ignores
`options.grammar` entirely. An otherwise-batchable request with
`response_format` is admitted to the batch and generates UNCONSTRAINED —
HTTP 200, no Warning header, schema silently not enforced — and the
compiled `GrammarController` (WASM matcher + compiled grammar + compiler)
is never disposed (generate() never runs), leaking WASM state per request.
The design doc's "serial-lane-only under `--batch`" was intent, not code.
Plan B0 fixes routing immediately; B1 makes batching real.

**F3 — robustness: mask width vs padded config vocab.** `applyMask`
iterates the logits width V = `config.vocab_size` (padded, can exceed the
tokenizer vocab) while `readyMask` has the MATCHER's width. For padded ids
`this.readyMask[word]!` is `undefined`, and `(undefined >>> bit) & 1`
evaluates to 0 → `-inf`. That is the correct behavior (padding ids are
never valid) but it works by accident under a lying non-null assertion.
Make it explicit (treat out-of-range words as 0) + a comment.

**F4 — efficiency: fresh `GrammarCompiler` per request.**
`compileGrammarRequest` builds a new compiler every request, discarding
xgrammar's internal compilation cache (`createGrammarCompiler(info,
cacheEnabled?)` — the WASM API exposes it). Agentic clients replay the
same schema hundreds of times; each pays full schema→grammar compile.
Cache ONE compiler per TokenizerInfo (both are vocab-structural); the
`ownsCompiler=false` path in GrammarController already exists for this.

**F5 — gap: `guided_regex` supports only the regex∩EBNF intersection.**
The WASM build has NO `Grammar.fromRegex` (verified in
`lib/xgrammar.d.ts`: fromEBNF / fromJSONSchema / builtinJSONGrammar /
fromStructuralTag only). Our `root ::= ${regex}` hack accepts regexes that
happen to parse as xgrammar EBNF (char classes, `{m,n}`); real-world
regexes (`\d`, `.`, anchors, groups) hit the degrade path. Follow-up: port
a regex→EBNF translation (native xgrammar has `_regex_to_ebnf`) or
document the subset. Not a batching blocker.

**F6 — minor: `guided_choice` escaping** covers `\` and `"` only; a choice
containing a newline/control char breaks the EBNF string literal. Escape
`\n\r\t` or 400 on control chars.

**F7 — known, hotter under batch: thinking models.** The mask constrains
from token 0, so it forbids the `<think>` preamble. Qwen3.5 — a headline
`--batch` model, thinking default-on — makes this visible. The fix is
structural tags (`fromStructuralTag` IS in the WASM API): permissive
during the think span, constrained output after. Separate work item; not
part of the batching plan.

## The plan

### B0 — correctness stopgaps (land first, small)

1. **F1 fix** in generate.ts: under grammar, read `grammarTok =
   ops.itemUint32(cur)` unconditionally at the top of the loop; keep
   `accept()`/`ready()` gated on `generated + 1 < maxTokens`. Regression
   test: grammar + max_tokens smaller than the JSON → truncated output's
   final token is the actually-sampled token (and max_tokens=1 emits a
   real token, not -1).
2. **F2 routing fix**: add `hasGrammar` to `RequestShape` (true when a
   controller compiled — degrade-path requests have NO controller and stay
   batchable, the injection already happened at the prompt level);
   `willBatch()` returns false for it. This makes the design doc's claim
   true and stops the silent non-enforcement + controller leak TODAY,
   independent of B1's schedule.
3. Lane-debug: `MLX_BUN_LANE_DEBUG=1` line includes `hasGrammar`.

Exit: `--batch 4` server + `response_format` request → enforced output
(valid schema-conformant JSON), routed serial, controller disposed.

### B1 — per-row grammar in the batch scheduler

No `BatchGrammarMatcher` in the WASM build → N independent per-row
matchers, driven by the scheduler. The design maps the serial loop's three
grammar duties (mask-before-sample, accept-after-read,
terminate-without-stop) onto the batch engine's existing structures:

- **`BatchRequest.grammar?: GrammarController`** (new field). The gateway
  passes `options.grammar` through on the batch lane and **owns disposal**
  in a finally around `submit()` (covers resolve, reject, eviction, and
  the whole-batch-drop error path — the scheduler uses but never owns).
- **Mask application** goes inside the gateway's existing per-row `sample`
  closure: after the logits processors, before `toLogprobs` — same "grammar
  has the final say" ordering as serial `sampleStep`. `applyMask` is sync
  and reused as-is; the documented precondition is that the scheduler has
  awaited `ready()` before invoking `sample` for that row.
- **Prefill (admission)**: token 0 is already sampled through the row's
  closure, and the controller is primed at compile time, so the step-0
  mask applies with zero scheduler changes. After the existing
  `#readToken`: `accept(tok0)`; if the matcher terminated (a 1-token
  grammar), emit + finish("stop") WITHOUT merging into the batch;
  otherwise the fill is in flight and `ready()` is awaited before that
  row's next sample.
- **`#step()` with ≥1 live grammar row** takes the read-before-build shape
  (the serial resolution, transplanted):
  1. Read the pending `[B]` token array NOW (one sync readback, before
     building the next step's graph).
  2. For each grammar row: `accept(tok_b)` — fires that row's async fill.
     Rows whose matcher terminated are marked done: they keep their `[B]`
     slot through the forward (one harmless KV write, exactly like today's
     length-doomed placeholder rows) but are NOT sampled.
  3. Build the batched forward graph (host-side; the fills overlap it).
  4. `await ready()` on every live grammar row.
  5. Sample per live row (closure applies the mask), asyncEval.
  6. Emit using the values read in (1) — no second readback — via the
     existing `#emitRows`; grammar-terminated rows emit their final token
     and finish with `finish_reason: "stop"`, then the existing filter
     evicts them. **This is the all-`-inf` guarantee, per row: a
     terminated row is finished/evicted before its slot is ever sampled
     again.**
  Batches with NO grammar rows keep the current pipelined path
  byte-identical (zero cost when the feature is unused).
- **The trade, stated:** while any grammar row is live the batch runs
  effectively NO_PIPELINE (the readback no longer overlaps the next step's
  GPU compute) — same math, scheduling only; bounded by the readback
  (~0.1 ms) + fills (0.004–0.19 ms/row, overlapped with graph build).
  Serial grammar pays the identical trade today. Rejected alternative:
  speculative pipelining via the matcher's `rollBack(1)` (sample with a
  stale mask, roll back on mismatch) — complexity without evidence; the
  WASM API exposes rollBack if a measured need ever appears.
- **EOS / stop sequences / accept-failure**: unchanged semantics. Grammar
  termination is an additional per-row stop source; accept-failure warns
  and continues (serial parity).
- **Levers**: `MLX_BUN_GRAMMAR=0` still kills the feature (degrade
  everywhere). New `MLX_BUN_GRAMMAR_BATCH=0` forces grammar rows back to
  the serial lane (B0 behavior) — the A/B + kill switch for the new code,
  house style.
- Seeded requests already route serial (`userSeed`), so grammar+seed
  reproducibility is untouched.

### B2 — gates (tests + numbers)

- **Scheduler tests** (model-gated, alongside tests/batch-scheduler.test.ts):
  - Mixed batch: 1 grammar row + free-running siblings — grammar row emits
    valid schema JSON; siblings byte-match a no-grammar-sibling run (mask
    isolation).
  - All-grammar B=4 with FOUR DIFFERENT schemas — each row conforms to ITS
    schema. This is THE bug-class gate: row↔matcher misalignment after
    eviction/join would cross-bleed masks.
  - Early termination + churn: a grammar row terminates mid-batch,
    siblings continue, a joiner admits afterward; controller disposed.
  - max_tokens truncation mid-JSON under batch (F1's regression, batch
    flavor).
  - Prefill-terminated row (grammar satisfied at token 0) never merges.
- **Model-free unit** (tests/grammar.test.ts): N matchers advanced
  interleaved with overlapping async fills — the one novel runtime
  assumption (concurrent per-row fills on the single WASM instance don't
  cross-contaminate) gets cheap insurance.
- **Lane parity**: same greedy request through serial vs batch lane → both
  valid + schema-conformant. Byte-equality is NOT the gate (batched
  forward is mlx-lm-B=N-parity, not B=1-parity; the scheduler's existing
  gate is teacher-forced/KL) — the grammar gate is validity + matcher
  never rejects + correct finish_reasons.
- **Bench**: `--batch 4` all-grammar vs all-free, aggregate tok/s + TTFT
  (cpm5 + e4b). Every perf claim gets a number on this machine; expected
  cost <2% from the pipeline trade.

## Addendum (2026-07-02): XGrammar-2 / TVM-FFI / the WASM version gap

Investigated per Josh: [XGrammar-2](https://blog.mlc.ai/2026/05/04/xgrammar-2-fast-customizable-structured-generation)
(native 0.2.x, May 2026) vs our `@mlc-ai/web-xgrammar` 0.1.27 WASM.

**What XGrammar-2 adds (native):** Structural Tag v2 (composable JSON DSL:
sequence/tag/any_text/triggered_tags/**regex**/json_schema — uniformly
expresses harmony format, tool calling, reasoning channels), cross-grammar
caching + repetition-state compression (up to 80× compile speedup),
**`BatchGrammarMatcher`** (`batch_fill_next_token_bitmask` /
`batch_accept_token` / `batch_rollback` — a C++ **thread pool** over N
matchers, one call per step), `traverse_draft_tree` for speculative
decoding, and [TVM-FFI](https://github.com/apache/tvm-ffi)-based bindings
(Python/C++/Rust/JS) with **MLX support** (`pip install "xgrammar[metal]"`).

**The npm package IS behind, but less than the version number implies.**
[npm 0.1.27](https://www.npmjs.com/package/@mlc-ai/web-xgrammar) was
published 2025-12-25 (native 0.2.0 landed 2026-05-01 — that's the
whitespace-parity version skew). BUT the `web/` tree on current main still
says 0.1.27 while its `xgrammar_binding.cc` compiles against the CURRENT
`cpp/` core — a source rebuild today produces an XGrammar-2-core WASM.
The npm version number is just stale packaging.

**BatchGrammarMatcher is NOT in the WASM binding — and wouldn't help at
our B anyway.** Verified in `web/src/xgrammar_binding.cc` on main: no
batch class is bound. Its win is the C++ thread pool, and the emscripten
build isn't compiled with pthreads — a WASM batch call would be a serial
C++ loop, saving only per-call JS↔WASM overhead on fills already measured
at 0.004–0.19 ms. At B≤4 (≤0.8 ms/step aggregate, overlapped) there is no
prize. **B1's N-per-row-matchers design stands regardless of engine
version.**

**Two upgrade paths, decoupled from B1:**

- **U1 — rebuild web-xgrammar from current main** (emsdk + `web/build.sh`,
  vendor the artifact). Gets the XGrammar-2 core as WASM: cross-grammar
  cache + repetition compression (compile-time wins — F4's pain),
  Structural Tag v2 incl. `RegexFormat` (a real F5 fix: compile
  `guided_regex` via `fromStructuralTag({format:{type:"regex",pattern}})`
  instead of the `root ::= regex` EBNF hack) and the triggered-tags
  machinery F7 needs for thinking models. Also re-tests the
  whitespace-parity gap (it was 0.1.27-vs-0.2.0 skew). Same API surface,
  no native-build/signing implications. NOTE: the INSTALLED 0.1.27
  typedefs already declare `RegexFormat`/`fromStructuralTag` — try F5/F7
  against the current package first; upgrade only if the Dec-2025 core
  predates the semantics we need.
- **U2 — native XGrammar-2 over the TVM-FFI stable C ABI via bun:ffi.**
  The original "no native build" rationale is weakened by TVM-FFI (a
  stable C ABI is exactly what we bind mlx-c through today), and it would
  buy: real threaded batch fill, MLX-side mask application, and
  `traverse_draft_tree` — which composes with the DSpark speculative-
  decoding path (grammar-masking a draft tree is otherwise awkward).
  Costs: a dylib in distribution (build-binary.sh, signing/notarization),
  a new FFI surface. Trigger conditions, not calendar: B grows past ~8,
  spec decode + grammar needs to compose, or agentic multi-tool schemas
  make compile time visible despite the F4 cache. Until one fires, WASM
  stays the engine.

### B3 — follow-ups (explicitly out of scope for the batch landing)

F4 compiler cache (biggest real-world win — agentic schema replay), F5
regex via structural tag `RegexFormat` (see addendum — try the installed
package first, else U1), F6 choice escaping, F3 explicit padded-vocab
handling, F7 structural tags for thinking models (batch-relevant:
Qwen3.5; the Structural Tag v2 machinery in the addendum is the tool),
U1/U2 engine upgrades (addendum), and device-side bitmask expansion
(upload the packed `ceil(V/32)` int32 mask ≈ 8 KB instead of host-building
a V-float mask ≈ 1 MB/step/row, expand with `right_shift`+`bitwise_and`
on device) — ONLY if the B2 bench shows the O(B·V) host loop, which the
measured serial numbers say it won't at B≤4.
