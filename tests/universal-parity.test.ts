// Universal (Tier-0 generic) logit-parity gate — OPT-IN slow tier (loads
// models). L1 bar: bit-exact vs stock mlx-lm on this machine's GPU, per
// docs/design/generic-model-support.md §3.5.
//
//   MLX_BUN_TEST_UNIVERSAL=1 bun test tests/universal-parity.test.ts
//
// Manifest-driven (tests/universal-manifest.ts); every entry skips unless
// BOTH the snapshot and its goldens exist on this machine. Regen goldens
// FIRST (same machine — logit goldens are GPU-specific):
//   bun scripts/regen-universal-goldens.ts all
//
// Asserts, per entry:
//   - createModel dispatches to UniversalDenseModel (or the dedicated class
//     where a targeted port shadows the descriptor — generic never shadows)
//   - the load-time weight audit passed (construction throws otherwise)
//   - first 12 greedy tokens identical to the oracle
//   - every step's last-position logits bit-exact (maxDiff === 0)

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { createModel } from "../src/model/factory";
import { UniversalDenseModel } from "../src/model/universal/dense";
import { genericArgsFor } from "../src/model/universal/archs";
import { argmaxLastPosition, lastPositionLogits } from "../src/model/gemma4-base";
import { Weights } from "../src/weights";
import { goldenAt, goldenPath } from "./goldens";
import { UNIVERSAL_MANIFEST } from "./universal-manifest";

const STEPS = 12;
const optIn = process.env.MLX_BUN_TEST_UNIVERSAL === "1";

interface Golden {
  prompt_ids: number[];
  greedy_ids: number[];
  logit_steps: number;
}

for (const entry of UNIVERSAL_MANIFEST) {
  const haveWeights = existsSync(`${entry.snapshot}/config.json`);
  const haveGoldens = existsSync(goldenPath(`${entry.prefix}-parity.json`));
  const skip = !optIn || !haveWeights || !haveGoldens;

  describe.skipIf(skip)(`universal L1 parity: ${entry.repoId} (${entry.modelType})`, async () => {
    if (skip) return;
    const golden = (await goldenAt(`${entry.prefix}-parity.json`).json()) as Golden;
    const config = await loadModelConfig(entry.snapshot);
    const model = createModel(await Weights.open(entry.snapshot), config);

    test("dispatches to the expected class; descriptor resolves", () => {
      expect(genericArgsFor(config)).not.toBeNull();
      if (entry.expectClass === "universal")
        expect(model).toBeInstanceOf(UniversalDenseModel);
      else expect(model).not.toBeInstanceOf(UniversalDenseModel);
    });

    test(`first ${STEPS} greedy tokens identical; all logits bit-exact`, async () => {
      const cache = model.makeCache();
      let tokens = golden.prompt_ids;
      try {
        for (let step = 0; step < STEPS; step++) {
          const logits = model.forward(tokens, cache);
          const ours = lastPositionLogits(logits);
          const ref = new Float32Array(
            await goldenAt(`${entry.prefix}-logits-step${step}.bin`).arrayBuffer(),
          );
          expect(ours.length).toBe(ref.length);
          let maxDiff = 0;
          for (let i = 0; i < ref.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
          expect(maxDiff).toBe(0);
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
}
