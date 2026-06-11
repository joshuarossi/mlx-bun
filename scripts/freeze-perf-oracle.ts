// Phase E step 1 (optimization_plan.md): FREEZE the compat-mode ground
// truth before any kernel work. Once a fused kernel ships under the
// perf-mode flag, bit-exact-vs-compat no longer applies; this snapshot
// is the quality oracle perf mode is gated against (bounded logit drift
// on the top of the distribution + trajectory agreement).
//
//   bun scripts/freeze-perf-oracle.ts
//
// Captures, per available model, under the SHIPPED kv_config serve
// scenario with the engine in compat mode (uncompiled, bit-exact path):
// greedy trajectories @~600 and @~2k synthetic prompts, plus the top-128
// (index, value) logits for the first 4 decode steps @2k. Keyed by
// config fingerprint. Deterministic by construction (fixed token ids,
// greedy, no sampler state).

import { SNAPSHOT, SNAPSHOT_26B } from "../tests/paths";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { Gemma4Model, argmaxLastPosition, lastPositionLogits } from "../src/model/gemma4";
import { configFingerprint } from "../src/model/fingerprint";
import { clearCache } from "../src/mlx/ffi";

process.env.MLX_BUN_COMPILED_DECODE = "0";

const E4B = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/fcdb12d740cd813634064567fc7cb51159b34253`;
const MODELS: [string, string][] = [
  ["12b", SNAPSHOT],
  ["e4b", E4B],
  ["26b", SNAPSHOT_26B],
];

const TOP_K = 128;
const LOGIT_STEPS = 4;
const TRAJ_TOKENS = 64;

// Natural-language prompts (per-model tokenizer): garbage-token prompts
// make greedy continuations maximally entropy-sensitive — any numeric
// perturbation flips near-tied argmaxes — which gates NOISE, not
// quality. Real text has low-entropy continuations; agreement on it is
// the meaningful signal. (First freeze used synthetic ids; re-frozen
// 2026-06-11 with text BEFORE any perf-mode kernel shipped — the compat
// engine is unchanged, so this is the same oracle with better prompts.)
import { loadTokenizer } from "../src/tokenizer";

async function textPrompt(dir: string, len: number): Promise<number[]> {
  const tok = await loadTokenizer(dir);
  let msg =
    "The history of computing begins with mechanical calculators and " +
    "proceeds through relays, vacuum tubes, transistors, and integrated " +
    "circuits. Each generation multiplied both speed and reliability. ";
  while (tok.encode(msg).length < len) msg += msg.slice(0, 400);
  return [2, ...tok.encode(msg).slice(0, len - 1)];
}

function topK(logits: Float32Array, k: number): { idx: number[]; val: number[] } {
  const idx = [...logits.keys()].sort((a, b) => logits[b]! - logits[a]!).slice(0, k);
  return { idx, val: idx.map((i) => logits[i]!) };
}

for (const [name, dir] of MODELS) {
  if (!(await Bun.file(`${dir}/config.json`).exists())) {
    console.log(`${name}: snapshot missing, skipped`);
    continue;
  }
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  const model = new Gemma4Model(weights, config);

  const run = async (promptLen: number, wantLogits: boolean) => {
    const cache = model.makeCache();
    try {
      for (let i = 0; i < cache.length; i++) {
        const e = config.kvQuant?.find((q) => q.layerIdx === i);
        if (e)
          cache[i] = (cache[i] as unknown as { toQuantized(g: number, b: number): (typeof cache)[number] }).toQuantized(e.groupSize, e.bits);
      }
      const prompt = await textPrompt(dir, promptLen);
      const trajectory: number[] = [];
      const logitSteps: { idx: number[]; val: number[] }[] = [];
      let tokens: number[] = prompt;
      for (let s = 0; s < TRAJ_TOKENS; s++) {
        const logits = model.forward(tokens, cache);
        if (wantLogits && s > 0 && s <= LOGIT_STEPS)
          logitSteps.push(topK(lastPositionLogits(logits), TOP_K));
        const next = argmaxLastPosition(logits);
        logits.dispose();
        trajectory.push(next);
        tokens = [next];
      }
      return { promptLen, trajectory, logitSteps };
    } finally {
      for (const c of cache) c.dispose();
    }
  };

  const out = {
    frozen: "2026-06-11",
    fingerprint: configFingerprint(config),
    kvConfig: config.kvQuant ?? null,
    topK: TOP_K,
    short: await run(600, false),
    long: await run(2048, true),
  };
  await Bun.write(`goldens/perf-oracle/${name}.json`, JSON.stringify(out));
  console.log(`${name}: frozen (fingerprint ${out.fingerprint})`);
  weights.dispose();
  clearCache();
}
