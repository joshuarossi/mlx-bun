// DSpark end-to-end gate on the REAL e4b model with an UNTRAINED drafter.
// The losslessness gate is drafter-quality-independent: accept = "draft equals
// e4b's argmax", so dsparkGenerate must reproduce vanilla greedy e4b token for
// token even untrained. This exercises forwardInfer + verify + KV rollback on
// the real quantized model — the highest-bug-density path. Also runs a temp>0
// pass to confirm the sampling path runs and decodes to text.
//
//   bun scripts/dspark-e2e-gate.ts [--max-tokens 48]

import { Gemma4Model } from "../src/model/gemma4";
import { DSparkDrafter, DEFAULT_DSPARK_CONFIG } from "../src/spec/dspark/module";
import { dsparkGenerate } from "../src/spec/dspark/generate";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");
const { loadTokenizer } = await import("../src/tokenizer");

const arg = (n: string, d: string) => {
  const i = process.argv.indexOf(`--${n}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : d;
};
const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const MAX_TOKENS = parseInt(arg("max-tokens", "48"), 10);
const GAMMA = parseInt(arg("gamma", "5"), 10);

const dir = new Registry().resolve(MODEL).path;
console.log(`[e2e] loading ${MODEL} from ${dir}`);
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const eos = config.eosTokenIds;
console.log(`[e2e] H=${config.text.hiddenSize} V=${config.text.vocabSize} eos=${eos}`);

const targetId = `${MODEL}@${config.text.hiddenSize}x${config.text.vocabSize}`;
const drafter = DSparkDrafter.init(model, { ...DEFAULT_DSPARK_CONFIG, gamma: GAMMA }, targetId, 0);
console.log(`[e2e] untrained drafter: ${drafter.names.length} param tensors, γ=${GAMMA}`);

const prompts = [
  "Summarize speculative decoding in one sentence.",
  "What is 17 times 23?",
  "Name three primary colors.",
];

function encode(p: string): number[] {
  let ids = tok.encode(p, true);
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  return ids;
}
function firstDiverge(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return a.length === b.length ? -1 : n;
}

let gatePass = 0;
for (let i = 0; i < prompts.length; i++) {
  const ids = encode(prompts[i]!);
  const t0 = performance.now();
  const ref = model.generate(ids, MAX_TOKENS, eos);
  const tRef = performance.now() - t0;

  const t1 = performance.now();
  const ds = dsparkGenerate(model, drafter, ids, { gamma: GAMMA, maxTokens: MAX_TOKENS });
  const tDs = performance.now() - t1;

  const div = firstDiverge(ref, ds.tokens);
  const ok = div === -1;
  if (ok) gatePass++;
  console.log(
    `\n[${i}] "${prompts[i]}"\n  gate ${ok ? "PASS ✓" : `DIVERGE@${div} (ref=${ref[div]} ds=${ds.tokens[div]})`}` +
    `  ref=${ref.length}tok(${tRef.toFixed(0)}ms) ds=${ds.tokens.length}tok(${tDs.toFixed(0)}ms)` +
    `  τ=${ds.stats.meanAcceptLen.toFixed(2)} accept=${ds.stats.acceptanceRate.toFixed(2)}`,
  );
  if (i === 0) console.log(`  ref text: ${JSON.stringify(tok.decode(ref).slice(0, 120))}`);
}
console.log(`\n[e2e] GREEDY GATE: ${gatePass}/${prompts.length} bit-identical to vanilla e4b`);

// temp>0 sampling path — confirm it runs and decodes (correctness proven
// statistically in dspark-smoke; here we just exercise the real model path).
const ids = encode(prompts[0]!);
const samp = dsparkGenerate(model, drafter, ids, {
  gamma: GAMMA, maxTokens: MAX_TOKENS, sample: { temperature: 0.7, seed: 1 },
});
console.log(`\n[e2e] temp=0.7 sampling: ${samp.tokens.length} tokens, τ=${samp.stats.meanAcceptLen.toFixed(2)}, decodes ok=${samp.tokens.length > 0}`);
console.log(`  text: ${JSON.stringify(tok.decode(samp.tokens).slice(0, 120))}`);

console.log(`\n[e2e] ${gatePass === prompts.length ? "✓ runtime correct (untrained drafter reproduces e4b)" : "✗ GATE FAILED — accept/reject or KV rollback bug"}`);
process.exit(gatePass === prompts.length ? 0 : 1);
