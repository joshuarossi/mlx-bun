// 26B-A4B MoE logit-parity (slow tier, tier-d contract): single-forward
// logits bit-exact vs the oracle (router top-k + gather_qmm path included),
// greedy prefix identical. Skips unless weights + goldens are present.
// Regen: bun scripts/regen-parity-goldens-26b.ts (explicit, never automatic).

import { describe, expect, test } from "bun:test";
import { SNAPSHOT_26B, snapshot26bAvailable } from "./paths";

const STEPS = 12;

const haveWeights = await snapshot26bAvailable();
const haveGoldens = await Bun.file("goldens/parity-26b.json").exists();

describe.skipIf(!haveWeights || !haveGoldens)("26B-A4B MoE greedy decode parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await Bun.file("goldens/parity-26b.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
    logit_steps: number;
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, argmaxLastPosition, lastPositionLogits } =
    await import("../src/model/gemma4");

  const config = await loadModelConfig(SNAPSHOT_26B);
  const weights = await Weights.open(SNAPSHOT_26B);
  const model = new Gemma4Model(weights, config);

  test(`first ${STEPS} greedy tokens identical; early logits bit-exact`, async () => {
    const cache = model.makeCache();
    let tokens = golden.prompt_ids;
    try {
      for (let step = 0; step < STEPS; step++) {
        const logits = model.forward(tokens, cache);
        if (step < golden.logit_steps) {
          const ours = lastPositionLogits(logits);
          const ref = new Float32Array(
            await Bun.file(`goldens/logits-26b-step${step}.bin`).arrayBuffer(),
          );
          let maxDiff = 0;
          for (let i = 0; i < ref.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
          // Tier d: bit-exact incl. router tie-breaks — same mlx kernels,
          // same op composition. Loosen only with documented cause.
          expect(maxDiff).toBe(0);
        }
        const next = argmaxLastPosition(logits);
        logits.dispose();
        expect(next).toBe(golden.greedy_ids[step]!);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
  }, 300_000);
});
