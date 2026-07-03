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
 *  the OpenAI/oMLX/vLLM API surfaces. resolveGrammarRequest() normalizes them. */
export interface GrammarRequest {
  /** OpenAI response_format. {type:"json_object"} | {type:"json_schema",
   *  json_schema:{name,schema,strict?}} | {type:"text"} (text = no-op). */
  responseFormat?: unknown;
  /** vLLM/oMLX: raw EBNF/LARK grammar string. */
  guidedGrammar?: string;
  /** vLLM/oMLX: regex — compiled to a grammar via xgrammar's RegexToEBNF. */
  guidedRegex?: string;
  /** vLLM/oMLX: restrict output to one of these strings (enum). */
  guidedChoice?: string[];
  /** vLLM/oMLX: a JSON schema object directly (alias for response_format's
   *  json_schema.schema). */
  structuredOutputs?: unknown;
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

let cachedTokenizerInfo: { path: string; info: XTokenizerInfo } | null = null;

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

/** Get (cached) xgrammar TokenizerInfo for a tokenizer.json path. */
async function getTokenizerInfo(tokenizerJsonPath: string): Promise<XTokenizerInfo> {
  if (cachedTokenizerInfo?.path === tokenizerJsonPath) return cachedTokenizerInfo.info;
  const { vocab, vocabType, prependSpace } = loadVocab(tokenizerJsonPath);
  const info = await wasmQueue(() =>
    xgrammar.TokenizerInfo.createTokenizerInfo(vocab, vocabType, prependSpace, vocab.length),
  );
  cachedTokenizerInfo = { path: tokenizerJsonPath, info };
  return info;
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
      const valid = (this.readyMask[word]! >>> bit) & 1;
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
  const info = await getTokenizerInfo(tokenizerJsonPath);
  const compiler = await wasmQueue(() => xgrammar.GrammarCompiler.createGrammarCompiler(info));
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
        const opts = resolved.choices
          .map((c) => `"${c.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`)
          .join(" | ");
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
    compiler.dispose();
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
  const controller = new GrammarController(matcher, compiled, compiler, true, vocabSize);
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
  // Precedence mirrors oMLX's _effective_guided_grammar / _compile_grammar:
  // explicit grammar > response_format json_schema > json_object > regex >
  // choice > structured_outputs. text / unset → null (no constraint).
  if (req.guidedGrammar) {
    return {
      kind: "grammar",
      ebnf: req.guidedGrammar,
      degradeDescription: "guided_grammar",
    };
  }

  const rf = req.responseFormat;
  if (rf && typeof rf === "object") {
    const type = (rf as { type?: string }).type;
    if (type === "json_schema") {
      const js = (rf as { json_schema?: { schema?: unknown; strict?: boolean } }).json_schema;
      const schema = js?.schema ?? req.structuredOutputs;
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

  if (req.structuredOutputs && typeof req.structuredOutputs === "object") {
    // structured_outputs as a bare schema object (oMLX alias)
    return {
      kind: "json_schema",
      schema: req.structuredOutputs,
      degradeDescription: "structured_outputs",
    };
  }

  if (req.guidedRegex) {
    return { kind: "regex", regex: req.guidedRegex, degradeDescription: "guided_regex" };
  }

  if (req.guidedChoice && req.guidedChoice.length > 0) {
    return {
      kind: "choice",
      choices: req.guidedChoice,
      degradeDescription: "guided_choice",
    };
  }

  return null;
}

/** Kill switch: MLX_BUN_GRAMMAR=0 disables grammar compilation entirely
 *  (requests degrade to prompt injection). Matches the project's envelope-gated
 *  kill-switch discipline (MLX_BUN_PERF_KERNEL, MLX_BUN_COMPILED_DECODE, …). */
export function grammarEnabled(): boolean {
  return process.env.MLX_BUN_GRAMMAR !== "0";
}
