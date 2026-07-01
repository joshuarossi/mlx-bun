// Is the greedy-gate divergence a real DSpark bug or e4b's batched-vs-incremental
// numerical knife-edge? Decisive test: the greedy accept rule makes the emitted
// stream γ-INDEPENDENT under exact arithmetic. So run dsparkGenerate at γ∈{1,3,5}
// and compare each to model.generate (incremental decode). If the tie-free
// prompts stay bit-exact at EVERY γ and only the unstable prompt diverges (at
// γ-dependent points, because each γ uses a different verify-window length), the
// divergence is e4b forward-length sensitivity — not an accept/reject/rollback
// bug. A real bug would corrupt output at a fixed point regardless of γ, or break
// the stable prompts.

import { Gemma4Model } from "../../src/model/gemma4";
import { DSparkDrafter, DEFAULT_DSPARK_CONFIG } from "../../src/spec/dspark/module";
import { dsparkGenerate } from "../../src/spec/dspark/generate";

const { Registry } = await import("../../src/registry");
const { loadModelConfig } = await import("../../src/config");
const { Weights } = await import("../../src/weights");
const { createModel } = await import("../../src/model/factory");
const { loadTokenizer } = await import("../../src/tokenizer");

const MODEL = "gemma-4-e4b-it-OptiQ-4bit";
const MAX = 48;
const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const tok = await loadTokenizer(dir);
const eos = config.eosTokenIds;
const drafter = DSparkDrafter.init(model, { ...DEFAULT_DSPARK_CONFIG, gamma: 5 }, "tiecheck", 0);

const enc = (p: string) => {
  let ids = tok.encode(p, true);
  if (ids.length >= 2 && ids[0] === ids[1] && ids[0] === tok.bosTokenId) ids = ids.slice(1);
  return ids;
};
const diverge = (a: number[], b: number[]) => {
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) if (a[i] !== b[i]) return i;
  return a.length === b.length ? -1 : n;
};

const PROMPTS = ["Summarize speculative decoding in one sentence.", "What is 17 times 23?", "Name three primary colors."];
const GAMMAS = [1, 3, 5];

for (let p = 0; p < PROMPTS.length; p++) {
  const ids = enc(PROMPTS[p]!);
  const ref = model.generate(ids, MAX, eos);
  const row = GAMMAS.map((g) => {
    const ds = dsparkGenerate(model, drafter, ids, { gamma: g, maxTokens: MAX });
    const d = diverge(ref, ds.tokens);
    return `γ${g}:${d === -1 ? "exact" : `div@${d}`}`;
  });
  console.log(`[${p}] "${PROMPTS[p]}" → ${row.join("  ")}`);
}
