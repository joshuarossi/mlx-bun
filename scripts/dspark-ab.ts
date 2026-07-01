// DSpark A/B + losslessness gate.
//
// THE GATE THAT MATTERS (run first): with greedy verify, the emitted stream is
// drafter-INDEPENDENT — accept = "draft equals the target's argmax" — so
// dsparkGenerate must reproduce vanilla greedy e4b (model.generate) token for
// token, even with an UNTRAINED module. If it doesn't, the accept/reject or KV
// rollback is wrong; fix that before looking at speed. (Tie-free prompts only:
// batched verify can differ from token-at-a-time greedy at bf16 knife-edges —
// the harness reports the first divergence so you can tell a real bug from a
// tie.)
//
// Then A/B: τ (mean accepted length / round) and decode tok/s for DSpark vs the
// existing GemmaAssistantDrafter baseline (optiq assistant), at the serving
// temperature. v1 is greedy (temp 0); temperature moves τ a lot — measure at
// the real serving temp, don't over-report at temp 0.
//
//   bun scripts/dspark-ab.ts --drafter ~/.cache/mlx-bun/dspark/e4b-v1 \
//       [--baseline <assistant-drafter-model-dir>] [--prompts prompts.txt] \
//       [--max-tokens 128] [--gate-only]

import { Gemma4Model } from "../src/model/gemma4";
import { DSparkDrafter } from "../src/spec/dspark/module";
import { dsparkGenerate } from "../src/spec/dspark/generate";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");

function arg(name: string, def?: string): string {
  const i = process.argv.indexOf(`--${name}`);
  if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!;
  if (def !== undefined) return def;
  throw new Error(`missing --${name}`);
}
const has = (name: string) => process.argv.includes(`--${name}`);

const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DRAFTER = arg("drafter");
const BASELINE = has("baseline") ? arg("baseline") : null;
const MAX_TOKENS = parseInt(arg("max-tokens", "128"), 10);
const GATE_ONLY = has("gate-only");
// Serving sampling config for the τ A/B. The greedy gate below always runs at
// temp 0 (exact, deterministic); the A/B measures τ at this temperature — the
// point of speculative SAMPLING. Temperature moves τ a lot; measure at the real
// serving temp, don't over-report at temp 0.
const TEMP = parseFloat(arg("temp", "0.7"));
const TOP_P = parseFloat(arg("top-p", "0"));
const TOP_K = parseInt(arg("top-k", "0"), 10);
const SEED = parseInt(arg("seed", "0"), 10);
const sampleCfg = TEMP > 0 ? { temperature: TEMP, topP: TOP_P, topK: TOP_K, seed: SEED } : undefined;

const DEFAULT_PROMPTS = [
  "Summarize the key idea of speculative decoding in two sentences.",
  "Write a Python function that returns the nth Fibonacci number.",
  "List three reasons local LLM inference is appealing.",
];

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const eos = config.eosTokenIds;

const drafter = DSparkDrafter.load(DRAFTER);

let prompts = DEFAULT_PROMPTS;
if (has("prompts")) {
  const text = await Bun.file(arg("prompts")).text();
  prompts = text.split("\n").map((l) => l.trim()).filter((l) => l.length > 0);
}

function encode(p: string): number[] {
  let ids = tok.encode(p, true);
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  return ids;
}

function firstDivergence(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return a.length === b.length ? -1 : n;
}

console.log(`[dspark-ab] model=${MODEL} drafter=${DRAFTER} γ=${drafter.cfg.gamma} maxTokens=${MAX_TOKENS}`);

// ---- losslessness gate ----
let gatePass = 0;
for (let i = 0; i < prompts.length; i++) {
  const ids = encode(prompts[i]!);
  const ref = model.generate(ids, MAX_TOKENS, eos);
  const ds = dsparkGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS });
  const div = firstDivergence(ref, ds.tokens);
  const ok = div === -1;
  if (ok) gatePass++;
  console.log(
    `  [${i}] gate ${ok ? "PASS" : `DIVERGE@${div}`}  ref=${ref.length}tok dspark=${ds.tokens.length}tok` +
    (ok ? "" : `\n      ref[${div}]=${ref[div]} dspark[${div}]=${ds.tokens[div]} (tie or bug?)`),
  );
}
console.log(`[dspark-ab] losslessness gate: ${gatePass}/${prompts.length} exact`);
if (gatePass < prompts.length)
  console.log(`  ⚠ divergences may be bf16 ties (benign) or an accept/rollback bug — inspect before trusting τ.`);

if (GATE_ONLY) process.exit(gatePass === prompts.length ? 0 : 1);

// ---- A/B τ + tok/s (at the serving temperature) ----
console.log(`[dspark-ab] A/B at temp=${TEMP}${TOP_P > 0 ? ` top-p=${TOP_P}` : ""}${TOP_K > 0 ? ` top-k=${TOP_K}` : ""}`);
let dsTau = 0, dsTps = 0, dsAcc = 0;
for (let i = 0; i < prompts.length; i++) {
  const ids = encode(prompts[i]!);
  const r = dsparkGenerate(model, drafter, ids, { maxTokens: MAX_TOKENS, sample: sampleCfg ? { ...sampleCfg, seed: SEED + i } : undefined });
  dsTau += r.stats.meanAcceptLen; dsTps += r.stats.decodeTps; dsAcc += r.stats.acceptanceRate;
}
const n = prompts.length;
console.log(`[dspark-ab] DSpark:   τ=${(dsTau / n).toFixed(3)}  accept=${(dsAcc / n).toFixed(3)}  decode=${(dsTps / n).toFixed(1)} tok/s`);

if (BASELINE) {
  const { GemmaAssistantDrafter } = await import("../src/spec/drafter");
  const { specGenerate } = await import("../src/spec/generate");
  const base = await GemmaAssistantDrafter.load(BASELINE);
  let bTau = 0, bTps = 0, bAcc = 0;
  for (const p of prompts) {
    const ids = encode(p);
    const r = specGenerate(model, base, ids, { gamma: drafter.cfg.gamma, maxTokens: MAX_TOKENS });
    // specGenerate reports acceptanceRate + decodeTps; derive τ from accepted/targetCalls.
    const rounds = r.stats.targetCalls - 1; // minus prefill
    const tau = rounds > 0 ? (r.stats.accepted + rounds) / rounds : 0;
    bTau += tau; bTps += r.stats.decodeTps; bAcc += r.stats.acceptanceRate;
  }
  console.log(`[dspark-ab] Baseline: τ=${(bTau / n).toFixed(3)}  accept=${(bAcc / n).toFixed(3)}  decode=${(bTps / n).toFixed(1)} tok/s`);
}
