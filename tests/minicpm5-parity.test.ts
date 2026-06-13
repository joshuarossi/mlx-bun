// MiniCPM5 parity: goldens are generated before the port and
// compared here while the implementation comes up.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { goldenAt, goldenPath } from "./goldens";
import { SNAPSHOT_MINICPM5 } from "./paths";

const STEPS = 100;

function requireFile(path: string): void {
  if (!existsSync(path)) throw new Error(`required MiniCPM5 parity file missing: ${path}`);
}

describe("MiniCPM5 greedy decode parity", async () => {
  requireFile(`${SNAPSHOT_MINICPM5}/config.json`);
  requireFile(`${SNAPSHOT_MINICPM5}/model.safetensors.index.json`);
  requireFile(goldenPath("minicpm5-parity.json"));
  for (let i = 0; i < STEPS; i++) requireFile(goldenPath(`minicpm5-logits-step${i}.bin`));

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { MiniCPM5Model } = await import("../src/model/minicpm5");
  const { argmaxLastPosition, lastPositionLogits } = await import("../src/model/gemma4-base");

  test(`first ${STEPS} greedy tokens identical; all logits match oracle`, async () => {
    const golden = (await goldenAt("minicpm5-parity.json").json()) as {
      prompt_ids: number[];
      greedy_ids: number[];
      logit_steps: number;
    };
    let t = performance.now();
    const config = await loadModelConfig(SNAPSHOT_MINICPM5);
    const weights = await Weights.open(SNAPSHOT_MINICPM5);
    const openMs = performance.now() - t;
    t = performance.now();
    const model = new MiniCPM5Model(weights, config);
    const constructMs = performance.now() - t;
    expect(model.weightsBytes).toBeGreaterThan(900_000_000);

    const cache = model.makeCache();
    let tokens = golden.prompt_ids;
    let firstEvalMs = 0;
    const decodeStart = performance.now();
    try {
      for (let step = 0; step < STEPS; step++) {
        const stepStart = performance.now();
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
        if (step === 0) firstEvalMs = performance.now() - stepStart;
        expect(next).toBe(golden.greedy_ids[step]!);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    const decodeMs = performance.now() - decodeStart;
    console.log(
      `MiniCPM5 parity timings: open=${openMs.toFixed(1)}ms ` +
      `construct=${constructMs.toFixed(1)}ms firstEval=${firstEvalMs.toFixed(1)}ms ` +
      `decode${STEPS}=${decodeMs.toFixed(1)}ms`,
    );
  }, 120_000);
});
