// Qwen3-MoE logit-parity (OPT-IN slow tier — loads the ~17 GB 30B-A3B).
// Bar: bf16 KV (KV-quant OFF) → bit-exact vs stock mlx-lm's qwen3_moe.
// (The cached checkpoint is not OptiQ — no kv_config — so no mixed-KV bar.)
//
//   MLX_BUN_TEST_QWEN3_MOE=1 bun test tests/qwen3-moe-parity.test.ts
//
// Opt-in + run alone (see qwen-parity.test.ts for why). Regen goldens FIRST
// on this machine:
//   bun scripts/regen.ts qwen-parity moe

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { Qwen3MoeModel } from "../src/model/qwen3-moe";
import { argmaxLastPosition, lastPositionLogits } from "../src/model/gemma4-base";
import { Weights } from "../src/weights";
import { goldenAt, goldenPath } from "./goldens";
import { SNAPSHOT_QWEN3_MOE, snapshotQwen3MoeAvailable } from "./paths";

const STEPS = 12;

interface Golden {
  prompt_ids: number[];
  greedy_ids: number[];
  logit_steps: number;
}

const optIn = process.env.MLX_BUN_TEST_QWEN3_MOE === "1";
const haveWeights = await snapshotQwen3MoeAvailable();
const haveGoldens = existsSync(goldenPath("qwen3-moe-parity.json"));
const skip = !optIn || !haveWeights || !haveGoldens;

describe.skipIf(skip)("Qwen3-30B-A3B bf16-KV parity (vs mlx-lm)", async () => {
  if (skip) return;
  const golden = (await goldenAt("qwen3-moe-parity.json").json()) as Golden;
  const config = await loadModelConfig(SNAPSHOT_QWEN3_MOE);
  const model = new Qwen3MoeModel(await Weights.open(SNAPSHOT_QWEN3_MOE), config);

  test(`first ${STEPS} greedy tokens identical; all logits bit-exact`, async () => {
    const cache = model.makeCache();
    let tokens = golden.prompt_ids;
    try {
      for (let step = 0; step < STEPS; step++) {
        const logits = model.forward(tokens, cache);
        const ours = lastPositionLogits(logits);
        const ref = new Float32Array(
          await goldenAt(`qwen3-moe-logits-step${step}.bin`).arrayBuffer(),
        );
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
  }, 600_000);
});
