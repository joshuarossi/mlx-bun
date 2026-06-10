// Logit-parity smoke (slow tier): first decode steps must be bit-exact
// with the oracle and greedy tokens identical. The full 100-step harness
// is scripts/parity-check.ts (CI-able via exit code).

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const STEPS = 12;

const haveWeights = await snapshotAvailable();
const haveGoldens = await Bun.file("goldens/parity.json").exists();

describe.skipIf(!haveWeights || !haveGoldens)("greedy decode parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await Bun.file("goldens/parity.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
    logit_steps: number;
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, argmaxLastPosition, lastPositionLogits } =
    await import("../src/model/gemma4");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
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
            await Bun.file(`goldens/logits-step${step}.bin`).arrayBuffer(),
          );
          let maxDiff = 0;
          for (let i = 0; i < ref.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
          expect(maxDiff).toBe(0); // bit-exact today; loosen only with cause
        }
        const next = argmaxLastPosition(logits);
        logits.dispose();
        expect(next).toBe(golden.greedy_ids[step]!);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
  }, 120_000);
});
