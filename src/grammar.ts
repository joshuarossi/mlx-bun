// Grammar-constrained decoding via @mlc-ai/web-xgrammar (WASM).
//
// Serves the structured-output API surface: response_format (json_object /
// json_schema), guided_grammar (EBNF/LARK), guided_regex, guided_choice,
// and the structured_outputs alias — full parity with oMLX/vLLM. From our
// side it's all one shape: compile something → GrammarMatcher → per-step
// bitmask → mask invalid logits to -inf before the sampler. The only
// difference between the modes is which xgrammar compile method we call.
//
// Fidelity tier: L2-class (oMLX is the oracle — same model+prompt+schema+seed
// must produce the same token stream). mlx-lm has no grammar support, so this
// is purely an oMLX-parity feature, not an L1 contract. The bitmask does not
// change the numerics of VALID tokens (it only sets invalid ones to -inf), so
// it touches neither L1 nor L2 decode numerics.
//
// Integration: a GrammarController is a stateful logits masker. Because
// xgrammar's getNextTokenBitmask() is async (WASM) and acceptToken() needs
// the token id as a JS number, the controller does NOT ride the sync
// LogitsProcessor array (which operates on device-side token arrays with no
// readback). Instead generate() drives it explicitly: after each token is
// sampled, call accept(tokenId) (sync matcher advance + fires async mask
// precompute that overlaps the next GPU forward), then await ready() before
// the next sampleStep; applyMask() applies the ready bitmask synchronously.
// See the grammar branch in generate()'s decode loop.

import xgrammar, {
  type TokenizerInfo as XTokenizerInfo,
  type GrammarCompiler as XGrammarCompiler,
  type CompiledGrammar as XCompiledGrammar,
  type GrammarMatcher as XGrammarMatcher,
  type Grammar as XGrammar,
} from "@mlc-ai/web-xgrammar";
import { readFileSync } from "node:fs";
import { MlxArray } from "./mlx/array";
import * as ops from "./mlx/ops";
import type { LoadedTokenizer } from "./tokenizer";

/** The request shape — the union of every structured-output field name across
 *  the OpenAI/oMLX/vLLM API surfaces. BOTH spellings are accepted: the wire
 *  protocol is snake_case (the server passes the raw request body — this was
 *  a live bug until 2026-07-03: only camelCase was read, so response_format
 *  over HTTP silently no-op'd; caught by the feature-matrix benchmark's
 *  conformance gate); library callers use camelCase. */
export interface GrammarRequest {
  /** OpenAI response_format. {type:"json_object"} | {type:"json_schema",
   *  json_schema:{name,schema,strict?}} | {type:"text"} (text = no-op). */
  responseFormat?: unknown;
  response_format?: unknown;
  /** vLLM/oMLX: raw EBNF/LARK grammar string. */
  guidedGrammar?: string;
  guided_grammar?: string;
  /** vLLM/oMLX: regex. Compiled via `root ::= <regex>` EBNF embedding, so
   *  only the regex∩EBNF subset works (the F5 gap — real regex→EBNF or
   *  structural-tag RegexFormat is the tracked fix, structured-output.md). */
  guidedRegex?: string;
  guided_regex?: string;
  /** vLLM/oMLX: restrict output to one of these strings (enum). */
  guidedChoice?: string[];
  guided_choice?: string[];
  /** vLLM/oMLX: a JSON schema object directly (alias for response_format's
   *  json_schema.schema). */
  structuredOutputs?: unknown;
  structured_outputs?: unknown;
}

/** A compiled grammar ready to mask logits. Null when the request asks for no
 *  constraint (text, or none of the fields set). `warning` is set when the
 *  requested grammar could not be compiled and the caller should degrade to
 *  prompt injection (mirrors oMLX's _compile_grammar_for_request returning None
 *  + a Warning header). */
export interface CompiledGrammarResult {
  controller: GrammarController;
  /** Schema/grammar for the degrade-path system-prompt injection (oMLX parity). */
  degradeHint: string | null;
}

/** xgrammar TokenizerInfo is expensive to build (it decodes every vocab id).
 *  Cache one per tokenizer.json path — it's vocab-structural, not per-request. */
/** Module-level serializer for ALL xgrammar WASM calls. The WASM instance is
 *  single-threaded; CONCURRENT async calls corrupt emscripten's binding
 *  layer (BindingError: Expected null or instance of VectorInt, got an
 *  instance of VectorInt — reproduced in tests/grammar.test.ts B1 test, which
 *  fires 4 overlapping compiles + fills). Under `--batch N` the scheduler
 *  fires N accept()s (each kicks an async fill) then awaits ready() on all;
 *  and the server compiles grammar for concurrent requests. Without
 *  serialization the overlapping WASM calls crash. This queue keeps the
 *  async-overlap API (fills still overlap GPU compute — the queue only
 *  serializes the CPU-side WASM calls, each 0.004–0.19 ms) while ensuring
 *  only ONE xgrammar call is in flight at a time. Both the compile path
 *  (compileGrammarRequest) and the fill path (prime/accept) ride it. */
let wasmChain: Promise<unknown> = Promise.resolve();
function wasmQueue<T>(fn: () => Promise<T>): Promise<T> {
  const run = wasmChain.then(fn, fn); // run regardless of prior success/failure
  wasmChain = run.then(
    () => undefined,
    () => undefined,
  );
  return run;
}

/** F4: ONE TokenizerInfo + ONE compiler per tokenizer.json path, cached for
 *  the process lifetime. xgrammar's GrammarCompiler carries an internal
 *  compilation cache (cacheEnabled defaults true), so agentic clients
 *  replaying the same JSON schema hit a cached grammar instead of paying a
 *  full schema→grammar compile per request. Both are vocab-structural.
 *  Controllers get ownsCompiler=false and never dispose it.
 *  The entry holds a PROMISE, installed synchronously before any await —
 *  concurrent compiles after a path change share ONE build (single-flight)
 *  instead of racing to rebuild and double-dispose the previous pair. */
let cachedTokenizerInfo: {
  path: string;
  pair: Promise<{ info: XTokenizerInfo; compiler: XGrammarCompiler }>;
} | null = null;

/** Extract the ordered vocab array + detect xgrammar vocab type from
 *  tokenizer.json (the same data src/tokenizer.ts already loads).
 *  - decoder.type == "ByteLevel"            → byte_level  (Llama3, Qwen)
 *  - decoder is Sequence w/ ByteFallback    → byte_fallback (Gemma/SP)
 *  - otherwise                              → raw
 *  prependSpace is true for byte_level (ByteLevel pretokenizers add a leading
 *  space). Validated in scripts/experiments/xgrammar-spike.ts across Gemma
 *  (byte_fallback, 256k), Llama-3 / Qwen2.5 (byte_level, 128k/151k). */
function loadVocab(tokenizerJsonPath: string): {
  vocab: string[];
  vocabType: string;
  prependSpace: boolean;
} {
  const t = JSON.parse(readFileSync(tokenizerJsonPath, "utf8"));
  const v = t.model?.vocab;
  if (!v || typeof v !== "object")
    throw new Error("tokenizer.json has no model.vocab");
  const entries = Object.entries(v as Record<string, number>);
  const size = entries.length;
  const vocab = new Array<string>(size);
  for (const [tok, id] of entries) vocab[id] = tok;

  let vocabType = "raw";
  const dec = t.decoder;
  if (dec?.type === "ByteLevel") vocabType = "byte_level";
  else if (dec?.type === "Sequence" && Array.isArray(dec.decoders)) {
    if (dec.decoders.some((d: { type?: string }) => d?.type === "ByteFallback"))
      vocabType = "byte_fallback";
  } else if (dec?.type === "ByteFallback") {
    vocabType = "byte_fallback";
  }
  return { vocab, vocabType, prependSpace: vocabType === "byte_level" };
}

/** Get (cached) xgrammar TokenizerInfo + its process-lifetime compiler for a
 *  tokenizer.json path. On a path change (model switch) the previous pair is
 *  disposed exactly once, by the single flight that replaced it. */
function getTokenizerInfo(
  tokenizerJsonPath: string,
): Promise<{ info: XTokenizerInfo; compiler: XGrammarCompiler }> {
  if (cachedTokenizerInfo?.path === tokenizerJsonPath) return cachedTokenizerInfo.pair;
  const prev = cachedTokenizerInfo;
  const pair = (async () => {
    const { vocab, vocabType, prependSpace } = loadVocab(tokenizerJsonPath);
    const info = await wasmQueue(() =>
      xgrammar.TokenizerInfo.createTokenizerInfo(vocab, vocabType, prependSpace, vocab.length),
    );
    const compiler = await wasmQueue(() => xgrammar.GrammarCompiler.createGrammarCompiler(info));
    if (prev)
      prev.pair.then(
        (p) => {
          p.compiler.dispose();
          p.info.dispose();
        },
        () => undefined,
      );
    return { info, compiler };
  })();
  // Install synchronously — concurrent callers join this flight. A failed
  // flight uncaches itself (callers still see the rejection) so a transient
  // error doesn't poison the path forever.
  cachedTokenizerInfo = { path: tokenizerJsonPath, pair };
  pair.catch(() => {
    if (cachedTokenizerInfo?.pair === pair) cachedTokenizerInfo = null;
  });
  return pair;
}

/** Vocab size the matcher masks against (config.vocab_size, may exceed the
 *  tokenizer vocab due to padding). Falls back to the tokenizer length. */
function effectiveVocabSize(tokenizer: LoadedTokenizer, configVocabSize?: number): number {
  // The matcher is built against TokenizerInfo's vocab; mask logits at the
  // model's logit width (config vocab_size, >= tokenizer vocab when padded).
  return configVocabSize ?? tokenizer.vocabSize ?? 0;
}

/** Stateful grammar masker. Driven explicitly by generate()'s decode loop
 *  (see module doc): accept(tokenId) advances the matcher + fires async mask
 *  precompute; ready() awaits it; applyMask(logits) sets invalid ids to -inf. */
export class GrammarController {
  private readonly matcher: XGrammarMatcher;
  private readonly compiled: XCompiledGrammar;
  private readonly compiler: XGrammarCompiler;
  private readonly ownsCompiler: boolean;
  private readonly vocabSize: number;
  /** Bitmask width in int32s = ceil(V / 32). */
  private readonly maskWidth: number;
  private readyMask: Int32Array;
  private pending: Promise<void> | null;
  private terminated = false;

  constructor(
    matcher: XGrammarMatcher,
    compiled: XCompiledGrammar,
    compiler: XGrammarCompiler,
    ownsCompiler: boolean,
    vocabSize: number,
  ) {
    this.matcher = matcher;
    this.compiled = compiled;
    this.compiler = compiler;
    this.ownsCompiler = ownsCompiler;
    this.vocabSize = vocabSize;
    this.maskWidth = Math.ceil(vocabSize / 32);
    this.readyMask = new Int32Array(this.maskWidth).fill(-1);
    this.pending = null;
  }

  /** Precompute the step-0 mask. Must be awaited before the first applyMask(). */
  async prime(): Promise<void> {
    this.readyMask = await wasmQueue(() => this.matcher.getNextTokenBitmask());
  }

  /** Apply the ready bitmask to logits [1, V]. Invalid token ids → -inf.
   *  Sync — the mask is already materialized. Returns a NEW array (caller
   *  disposes the input). Mirrors oMLX's apply_token_bitmask_mlx. */
  applyMask(logits: MlxArray): MlxArray {
    // Build a -inf/0 additive float mask on device from the int32 bitmask.
    // Each int32 bit b (little-endian within the word) gates token
    // word*32 + b. Set = valid (xgrammar convention). Adding -inf → -inf,
    // adding 0 → noop.
    const V = logits.shape[logits.shape.length - 1]!;
    const maskArr = new Float32Array(V);
    for (let id = 0; id < V; id++) {
      const word = id >>> 5;
      const bit = id & 31;
      // F3: V is the model's logit width (config.vocab_size, may exceed the
      // tokenizer vocab via padding); the matcher's mask has the TOKENIZER's
      // width. Padded ids beyond the mask are never valid — mask them
      // explicitly rather than relying on undefined>>>bit coercing to 0.
      const w = word < this.readyMask.length ? this.readyMask[word]! : 0;
      const valid = (w >>> bit) & 1;
      maskArr[id] = valid ? 0 : -Infinity;
    }
    const mask = MlxArray.fromFloat32(maskArr, [1, V]).astype(logits.dtype);
    const out = ops.add(logits, mask);
    mask.dispose();
    return out;
  }

  /** Advance the matcher by the just-sampled token and fire async mask
   *  precompute for the NEXT step (overlaps the GPU forward). Call AFTER the
   *  token is read back to JS. No-op once terminated. */
  accept(tokenId: number): void {
    if (this.terminated) return;
    const ok = this.matcher.acceptToken(tokenId);
    if (!ok) {
      // The sampler only ever picks valid tokens (we masked the rest), so an
      // accept failure means the vocab/mask drifted from the model's actual
      // tokenization — not a logic bug in the walk. Log + keep going; the
      // output may be malformed but generation continues rather than dying.
      console.warn(`grammar: matcher rejected token ${tokenId}`);
    }
    if (this.matcher.isTerminated()) {
      this.terminated = true;
      return;
    }
    this.pending = wasmQueue(() => this.matcher.getNextTokenBitmask()).then((m) => {
      this.readyMask = m;
    });
  }

  /** Await the mask precompute fired by accept(). Should be called before the
   *  next applyMask(); usually resolves immediately (overlapped the forward). */
  async ready(): Promise<void> {
    if (this.pending) {
      await this.pending;
      this.pending = null;
    }
  }

  get isTerminated(): boolean {
    return this.terminated;
  }

  dispose(): void {
    this.matcher.dispose();
    this.compiled.dispose();
    if (this.ownsCompiler) this.compiler.dispose();
  }
}

/** Normalize the request fields + compile. Returns null when no constraint is
 *  requested (text / none set). `degradeHint` is set when a grammar was
 *  requested but could not be compiled — callers inject a "respond in valid
 *  JSON" system prompt + emit a Warning header (oMLX parity, never 500). */
export async function compileGrammarRequest(
  req: GrammarRequest,
  tokenizer: LoadedTokenizer,
  configVocabSize?: number,
): Promise<{ controller: GrammarController; degradeHint: string | null } | null> {
  const tokenizerJsonPath = tokenizer.tokenizerJsonPath;
  if (!tokenizerJsonPath)
    throw new Error("grammar: tokenizer.tokenizerJsonPath is required (set by loadTokenizer)");

  const resolved = resolveGrammarRequest(req);
  if (!resolved) return null;

  // Each xgrammar WASM call rides wasmQueue individually (NOT a body-level
  // wrap — prime() calls wasmQueue internally, so a body-level wrap would
  // deadlock reentrantly). Individual calls serialize without nesting.
  const { info, compiler } = await getTokenizerInfo(tokenizerJsonPath);
  let compiled: XCompiledGrammar | null = null;
  let degradeHint: string | null = null;

  try {
    switch (resolved.kind) {
      case "json_object":
        compiled = await wasmQueue(() => compiler.compileBuiltinJSONGrammar());
        break;
      case "json_schema": {
        const s = resolved.schema;
        compiled = await wasmQueue(() =>
          compiler.compileJSONSchema(
            typeof s === "string" ? s : JSON.stringify(s),
            resolved.anyWhitespace ?? true,
            resolved.indent,
            resolved.separators,
            resolved.strict ?? true,
          ),
        );
        break;
      }
      case "grammar": {
        const g = await wasmQueue(() => xgrammar.Grammar.fromEBNF(resolved.ebnf, resolved.rootRule));
        compiled = await wasmQueue(() => compiler.compileGrammar(g));
        g.dispose();
        break;
      }
      case "regex": {
        const ebnf = `root ::= ${resolved.regex}`;
        const g = await wasmQueue(() => xgrammar.Grammar.fromEBNF(ebnf));
        compiled = await wasmQueue(() => compiler.compileGrammar(g));
        g.dispose();
        break;
      }
      case "choice": {
        // F6: escape everything an EBNF string literal can't hold bare.
        // \n\r\t have named escapes; any other control char has no EBNF
        // spelling — throw into the degrade path (prompt injection +
        // Warning header), never a 500.
        const esc = (c: string) => {
          const body = c
            .replace(/\\/g, "\\\\")
            .replace(/"/g, '\\"')
            .replace(/\n/g, "\\n")
            .replace(/\r/g, "\\r")
            .replace(/\t/g, "\\t");
          // eslint-disable-next-line no-control-regex
          if (/[\x00-\x1f]/.test(body))
            throw new Error("guided_choice: unsupported control character in choice");
          return `"${body}"`;
        };
        const opts = resolved.choices.map(esc).join(" | ");
        const g = await wasmQueue(() => xgrammar.Grammar.fromEBNF(`root ::= ${opts}`));
        compiled = await wasmQueue(() => compiler.compileGrammar(g));
        g.dispose();
        break;
      }
    }
  } catch (e) {
    degradeHint = resolved.degradeDescription ?? String(e);
    compiled = null;
  }

  if (!compiled) {
    if (!degradeHint) degradeHint = resolved.degradeDescription ?? "grammar compile failed";
    // The compiler is the cached per-TokenizerInfo instance (F4) — a failed
    // compile must NOT dispose it; the WASM abort is catchable and the
    // compiler state survives (verified in tests/grammar.test.ts).
    return null;
  }

  // terminateWithoutStopToken=true: the matcher terminates as soon as the
  //  grammar is SATISFIED (e.g. the closing `}` of a complete JSON), not only
  //  when the model emits a stop token. This is what oMLX does — generation
  //  halts once the structured output is complete, so the sampler never faces
  //  an all-rejected (all--inf) mask after the grammar closes (which would
  //  make greedy argmax return a garbage token id like 0 that the matcher
  //  then rejects, looping until max_tokens).
  const matcher = await wasmQueue(() =>
    xgrammar.GrammarMatcher.createGrammarMatcher(compiled!, undefined, true),
  );
  const vocabSize = effectiveVocabSize(tokenizer, configVocabSize) || info.getVocabSize();
  const controller = new GrammarController(matcher, compiled, compiler, false, vocabSize);
  await controller.prime();
  return { controller, degradeHint };
}

/** Internal: normalize the union of request fields into one compile target. */
function resolveGrammarRequest(req: GrammarRequest):
  | (
    | { kind: "json_object"; degradeDescription: string }
    | {
      kind: "json_schema";
      schema: unknown;
      strict?: boolean;
      anyWhitespace?: boolean;
      indent?: number;
      separators?: [string, string];
      degradeDescription: string;
    }
    | { kind: "grammar"; ebnf: string; rootRule?: string; degradeDescription: string }
    | { kind: "regex"; regex: string; degradeDescription: string }
    | { kind: "choice"; choices: string[]; degradeDescription: string }
  )
  | null {
  // Normalize the two spellings first (wire = snake_case, library = camel).
  const guidedGrammar = req.guidedGrammar ?? req.guided_grammar;
  const guidedRegex = req.guidedRegex ?? req.guided_regex;
  const guidedChoice = req.guidedChoice ?? req.guided_choice;
  const structuredOutputs = req.structuredOutputs ?? req.structured_outputs;
  const responseFormat = req.responseFormat ?? req.response_format;

  // Precedence mirrors oMLX's _effective_guided_grammar / _compile_grammar:
  // explicit grammar > response_format json_schema > json_object > regex >
  // choice > structured_outputs. text / unset → null (no constraint).
  if (guidedGrammar) {
    return {
      kind: "grammar",
      ebnf: guidedGrammar,
      degradeDescription: "guided_grammar",
    };
  }

  const rf = responseFormat;
  if (rf && typeof rf === "object") {
    const type = (rf as { type?: string }).type;
    if (type === "json_schema") {
      const js = (rf as { json_schema?: { schema?: unknown; strict?: boolean } }).json_schema;
      const schema = js?.schema ?? structuredOutputs;
      if (schema) {
        return {
          kind: "json_schema",
          schema,
          strict: js?.strict,
          degradeDescription: "response_format json_schema",
        };
      }
    } else if (type === "json_object") {
      return { kind: "json_object", degradeDescription: "response_format json_object" };
    }
    // type === "text" → no constraint (OpenAI: text = free-form)
  }

  if (structuredOutputs && typeof structuredOutputs === "object") {
    // structured_outputs as a bare schema object (oMLX alias)
    return {
      kind: "json_schema",
      schema: structuredOutputs,
      degradeDescription: "structured_outputs",
    };
  }

  if (guidedRegex) {
    return { kind: "regex", regex: guidedRegex, degradeDescription: "guided_regex" };
  }

  if (guidedChoice && guidedChoice.length > 0) {
    return {
      kind: "choice",
      choices: guidedChoice,
      degradeDescription: "guided_choice",
    };
  }

  return null;
}

/** Kill switch: MLX_BUN_GRAMMAR=0 disables grammar compilation entirely
 *  (requests degrade to prompt injection). Matches the project's envelope-gated
 *  kill-switch discipline (MLX_BUN_COMPILED_DECODE, MLX_BUN_GRAMMAR_BATCH, …). */
export function grammarEnabled(): boolean {
  return process.env.MLX_BUN_GRAMMAR !== "0";
}
