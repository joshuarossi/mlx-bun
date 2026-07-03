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
discipline (`MLX_BUN_PERF_KERNEL`, `MLX_BUN_COMPILED_DECODE`, …).

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
- **Batched lane.** The WASM build has no `BatchGrammarMatcher`; the batched
  lane (`--batch N`) uses N individual per-row matchers in the existing
  per-row processor fold in `src/serve/generation-gateway.ts`. NOT YET
  WIRED — grammar is currently serial-lane-only under `--batch`. The fold
  is built; each row would carry its own `GrammarMatcher`.
- **Structural tags for thinking models.** `compileStructuralTag` (permissive
  during `<think>`, constraining only the output) is supported by xgrammar
  but NOT YET WIRED. oMLX wraps the grammar in a structural tag when
  `reasoning_parser` is set; the equivalent here needs the thinking-tag
  format from `ctx.template`.
- **`/v1/responses` logprobs-style gap.** `response_format` is accepted on
  chat + completions; the Responses API shim routes through chat so it
  inherits support, but untested there.
