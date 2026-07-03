// Phase-0 spike: can @mlc-ai/web-xgrammar (WASM) build a correct token-bitmask
// from a REAL served-model vocab, and how fast is the per-step mask?
//
// This is the gating experiment for the structured-output feature
// (docs/design/omlx-adoption-map.md #1). It answers:
//   1. Vocab extraction + vocab-type detection from tokenizer.json → xgrammar
//      TokenizerInfo (the one new unknown vs the /tmp smoke test).
//   2. Correctness: json_object + json_schema masks round-trip through
//      acceptToken and produce the expected valid-token sets.
//   3. Performance: median/p95 getNextTokenBitmask latency at real vocab size
//      (256k Gemma, 151k Qwen, 128k Llama). This is the WASM-vs-C/ABI number
//      we'll quote; the precompute-ahead overlap in the real integration hides
//      most of it, but we need the raw per-call cost on record.
//
// Run: bun scripts/experiments/xgrammar-spike.ts [model-name ...]
// Defaults to the three vocab-type representatives above.

import xgrammar from "@mlc-ai/web-xgrammar";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

const HF_CACHE =
  process.env.HF_HUB_CACHE ??
  (process.env.HF_HOME
    ? join(process.env.HF_HOME, "hub")
    : `${process.env.HOME}/.cache/huggingface/hub`);

const MODELS = process.argv.slice(2).length
  ? process.argv.slice(2)
  : ["gemma-2-2b-it-4bit", "Llama-3.2-1B-Instruct-4bit", "Qwen2.5-0.5B-Instruct-4bit"];

/** Find the snapshot tokenizer.json for an mlx-community model dir. */
function tokenizerPath(model: string): string {
  const dir = `${HF_CACHE}/models--mlx-community--${model}`;
  const snapDir = join(dir, "snapshots");
  for (const snap of readdirSync(snapDir)) {
    const f = join(snapDir, snap, "tokenizer.json");
    if (exists(f)) return f;
  }
  throw new Error(`no tokenizer.json under ${snapDir}`);
}
function exists(p: string): boolean {
  try {
    return statSync(p).isFile();
  } catch {
    return false;
  }
}

/** Extract the ordered vocab array + detect xgrammar vocab type from
 *  tokenizer.json (the same data src/tokenizer.ts already loads).
 *  - decoder.type == "ByteLevel"            → byte_level  (Llama3, Qwen)
 *  - decoder is Sequence w/ ByteFallback    → byte_fallback (Gemma/SP)
 *  - otherwise                              → raw */
function loadVocab(tokenizerJsonPath: string): {
  vocab: string[];
  vocabType: string;
  prependSpace: boolean;
} {
  const t = JSON.parse(readFileSync(tokenizerJsonPath, "utf8"));
  const v = t.model?.vocab;
  if (!Array.isArray(v) && !v || typeof v !== "object")
    throw new Error("tokenizer.json has no model.vocab");
  // vocab is {token: id}; build ordered-by-id array.
  const entries = Object.entries(v as Record<string, number>);
  const size = entries.length;
  const vocab = new Array<string>(size);
  for (const [tok, id] of entries) vocab[id] = tok;

  let vocabType = "raw";
  const dec = t.decoder;
  if (dec?.type === "ByteLevel") vocabType = "byte_level";
  else if (dec?.type === "Sequence" && Array.isArray(dec.decoders)) {
    if (dec.decoders.some((d: any) => d?.type === "ByteFallback"))
      vocabType = "byte_fallback";
  } else if (dec?.type === "ByteFallback") {
    vocabType = "byte_fallback";
  }

  // prependSpace: ByteLevel pretokenizers add a leading space.
  const prependSpace = vocabType === "byte_level";
  return { vocab, vocabType, prependSpace };
}

const SCHEMA = JSON.stringify({
  type: "object",
  properties: {
    name: { type: "string" },
    age: { type: "number" },
    hobbies: { type: "array", items: { type: "string" } },
  },
  required: ["name", "age", "hobbies"],
});

function fmtMs(ns: number): string {
  return (ns / 1e6).toFixed(3) + " ms";
}

function pct(arr: number[], p: number): number {
  if (arr.length === 0) return NaN;
  const s = [...arr].sort((a, b) => a - b);
  const i = Math.min(s.length - 1, Math.floor((p / 100) * (s.length - 1)));
  return s[i]!;
}

async function benchModel(model: string) {
  console.log(`\n=== ${model} ===`);
  const path = tokenizerPath(model);
  const { vocab, vocabType, prependSpace } = loadVocab(path);
  console.log(
    `vocab: ${vocab.length} tokens  type: ${vocabType}  prependSpace: ${prependSpace}`,
  );

  const t0 = performance.now();
  const ti = await xgrammar.TokenizerInfo.createTokenizerInfo(
    vocab,
    vocabType,
    prependSpace,
    vocab.length,
  );
  console.log(`TokenizerInfo built in ${fmtMs((performance.now() - t0) * 1e6)}`);
  const compiler = await xgrammar.GrammarCompiler.createGrammarCompiler(ti);

  // --- json_object ---
  const tJO = performance.now();
  const cgJo = await compiler.compileBuiltinJSONGrammar();
  const mJo = await xgrammar.GrammarMatcher.createGrammarMatcher(cgJo);
  console.log(
    `json_object compile+matcher: ${fmtMs((performance.now() - tJO) * 1e6)}`,
  );

  // --- json_schema ---
  const tJS = performance.now();
  const cgJs = await compiler.compileJSONSchema(SCHEMA);
  const mJs = await xgrammar.GrammarMatcher.createGrammarMatcher(cgJs);
  console.log(
    `json_schema compile+matcher: ${fmtMs((performance.now() - tJS) * 1e6)}`,
  );

  // --- correctness: first mask should admit tokens that can start an object ---
  const mask0 = await mJs.getNextTokenBitmask();
  const V = ti.getVocabSize();
  const rejected0 = await xgrammar.Testings.debugGetMaskedTokensFromBitmask(
    new Int32Array(mask0),
    V,
    0,
  );
  const validCount = V - rejected0.length;
  console.log(
    `schema step0: ${validCount}/${V} tokens valid (${rejected0.length} masked)`,
  );
  if (validCount === 0 || validCount === V)
    throw new Error("step0 mask looks degenerate");

  // Find the '{' token id in vocab to accept it.
  const braceIdx = vocab.indexOf("{");
  if (braceIdx < 0) throw new Error("vocab has no '{' token");
  const accepted = mJs.acceptToken(braceIdx);
  if (!accepted) throw new Error("matcher rejected '{' — mask/vocab mismatch");
  const mask1 = await mJs.getNextTokenBitmask();
  if (mask1.length !== mask0.length) throw new Error("mask length changed");
  console.log(`accepted '{' → step1 mask ok (len ${mask1.length})`);

  // --- perf: the real per-step cost the integration pays = accept + fill,
  //  with the matcher state CHANGING each step (a bare getNextTokenBitmask
  //  loop returns a cached bitset — measured 0.0 ms, a cache hit, useless).
  //  Walk by repeatedly accepting the smallest valid token id (advances state)
  //  and timing the fill that follows.
  const walkTimes: number[] = [];
  const mW = await xgrammar.GrammarMatcher.createGrammarMatcher(cgJs);
  const N = 200;
  for (let i = 0; i < N; i++) {
    const m = await mW.getNextTokenBitmask();
    const rej = await xgrammar.Testings.debugGetMaskedTokensFromBitmask(
      new Int32Array(m),
      V,
      0,
    );
    // smallest unmasked id advances the matcher down SOME valid path
    let tok = -1;
    for (let id = 0; id < V; id++) {
      if (!rej.includes(id)) { tok = id; break; }
    }
    if (tok < 0 || !mW.acceptToken(tok) || mW.isTerminated()) break;
    // time the fill AFTER the state changed — the hot-path cost
    const s = performance.now();
    await mW.getNextTokenBitmask();
    walkTimes.push(performance.now() - s);
  }
  if (walkTimes.length === 0) throw new Error("walk produced no samples");
  console.log(
    `accept+fill x${walkTimes.length} (state-changing): ` +
    `median ${fmtMs(pct(walkTimes, 50))}  p95 ${fmtMs(pct(walkTimes, 95))}  ` +
    `min ${fmtMs(Math.min(...walkTimes))}`,
  );

  ti.dispose();
  compiler.dispose();
  mJo.dispose();
  mJs.dispose();
  mW.dispose();
}

(async () => {
  console.log("@mlc-ai/web-xgrammar spike — phase 0");
  for (const m of MODELS) {
    try {
      await benchModel(m);
    } catch (e) {
      console.error(`!! ${m} FAILED:`, e);
    }
  }
  console.log("\nDONE");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
