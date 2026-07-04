// FaithfulMiniCPM5 (the exact op-for-op mlx-lm copy, MLX_BUN_CPM5_FAITHFUL=1)
// must be BIT-EXACT to the same oracle golden our optimized MiniCPM5Model is held
// to, AND its faithful forward must actually run (not fall back to the monolith).

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { goldenAt, goldenPath } from "./goldens";
import { SNAPSHOT_MINICPM5 } from "./paths";

const STEPS = 100;

function requireFile(path: string): void {
  if (!existsSync(path)) throw new Error(`required MiniCPM5 parity file missing: ${path}`);
}

describe("FaithfulMiniCPM5 exact-copy decode parity", async () => {
  requireFile(`${SNAPSHOT_MINICPM5}/config.json`);
  requireFile(`${SNAPSHOT_MINICPM5}/model.safetensors.index.json`);
  requireFile(goldenPath("minicpm5-parity.json"));
  for (let i = 0; i < STEPS; i++) requireFile(goldenPath(`minicpm5-logits-step${i}.bin`));

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const faith = await import("../src/model/minicpm5-faithful");
  const { argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4-base");

  test(`first ${STEPS} greedy tokens + all logits match oracle; faithful path ran`, async () => {
    const golden = (await goldenAt("minicpm5-parity.json").json()) as {
      prompt_ids: number[];
      greedy_ids: number[];
      logit_steps: number;
    };
    const config = await loadModelConfig(SNAPSHOT_MINICPM5);
    const weights = await Weights.open(SNAPSHOT_MINICPM5);
    const model = new faith.FaithfulMiniCPM5(weights, config);
    expect(model.weightsBytes).toBeGreaterThan(900_000_000);

    const before = faith.faithfulForwardUses;
    const cache = model.makeCache();
    let tokens = golden.prompt_ids;
    try {
      for (let step = 0; step < STEPS; step++) {
        const logits = model.forward(tokens, cache);
        if (step < golden.logit_steps) {
          const ours = lastPositionLogits(logits);
          const ref = new Float32Array(
            await goldenAt(`minicpm5-logits-step${step}.bin`).arrayBuffer(),
          );
          let maxDiff = 0;
          for (let i = 0; i < ref.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
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
    expect(faith.faithfulForwardUses - before).toBe(STEPS);
  }, 120_000);
});
