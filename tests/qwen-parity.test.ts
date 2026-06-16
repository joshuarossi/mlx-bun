// Qwen3.5-architecture logit-parity (OPT-IN slow tier — loads the model).
// Bars, exactly as Josh specified:
//   1. bf16 KV  (KV-quant OFF) → bit-exact vs stock mlx-lm
//   2. mixed KV (KV-quant ON)  → bit-exact vs mlx-optiq (per-layer kv_config)
//
//   MLX_BUN_TEST_QWEN35=1    bun test tests/qwen-parity.test.ts   # 27B, both bars
//   MLX_BUN_TEST_QWEN35_4B=1 bun test tests/qwen-parity.test.ts   # 4B, bf16 bar only
//
// Opt-in + run alone: models are large; the default suite already holds other
// weights and the GPU command buffer fails asynchronously (uncatchable) past
// budget. Regen goldens FIRST on this machine:
//   bun scripts/regen-qwen-parity-goldens.ts [27b|4b]
//
// The 4B (8-bit, tied head, no kv_config) is the cheap end-to-end check of the
// whole qwen3_5 graph; the 27B adds the mixed-KV bar.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig, type KvQuantSpec } from "../src/config";
import { Qwen35Model } from "../src/model/qwen3_5";
import {
  argmaxLastPosition,
  KVCache,
  lastPositionLogits,
  type Cache,
} from "../src/model/gemma4-base";
import { Weights } from "../src/weights";
import { goldenAt, goldenPath } from "./goldens";
import {
  SNAPSHOT_QWEN35,
  SNAPSHOT_QWEN35_4B,
  snapshotQwen35Available,
  snapshotQwen35_4bAvailable,
} from "./paths";

const STEPS = 12;

/** Mirror optiq serve / generate.ts maybeQuantizeKv: per-layer bits from
 *  kv_config, never quantize an empty cache, skip non-KVCache (SSM) layers. */
function maybeQuantizeKv(cache: Cache[], kvConfig: KvQuantSpec[]): void {
  const byLayer = new Map(kvConfig.map((e) => [e.layerIdx, e]));
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (!(c instanceof KVCache) || c.offset === 0) continue;
    const e = byLayer.get(i);
    if (e) cache[i] = c.toQuantized(e.groupSize, e.bits);
  }
}

interface Golden {
  prompt_ids: number[];
  greedy_ids: number[];
  logit_steps: number;
}

function runParity(opts: {
  label: string;
  snapshot: string;
  optIn: boolean;
  haveWeights: boolean;
  goldenName: string;
  binPrefix: string;
  mixed: boolean;
}): void {
  const haveGoldens = existsSync(goldenPath(opts.goldenName));
  const skip = !opts.optIn || !opts.haveWeights || !haveGoldens;

  describe.skipIf(skip)(opts.label, async () => {
    if (skip) return;
    const golden = (await goldenAt(opts.goldenName).json()) as Golden;
    const config = await loadModelConfig(opts.snapshot);
    if (opts.mixed && !config.kvQuant?.length) throw new Error("kv_config did not load");
    const model = new Qwen35Model(await Weights.open(opts.snapshot), config);

    test(`first ${STEPS} greedy tokens identical; all logits bit-exact`, async () => {
      const cache = model.makeCache();
      let tokens = golden.prompt_ids;
      try {
        for (let step = 0; step < STEPS; step++) {
          const logits = model.forward(tokens, cache);
          const ours = lastPositionLogits(logits);
          const ref = new Float32Array(
            await goldenAt(`${opts.binPrefix}-logits-step${step}.bin`).arrayBuffer(),
          );
          let maxDiff = 0;
          for (let i = 0; i < ref.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
          expect(maxDiff).toBe(0);
          if (opts.mixed) maybeQuantizeKv(cache, config.kvQuant!);
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

const optIn27b = process.env.MLX_BUN_TEST_QWEN35 === "1";
const have27b = await snapshotQwen35Available();
runParity({ label: "Qwen3.6-27B bf16-KV parity (vs mlx-lm)", snapshot: SNAPSHOT_QWEN35,
  optIn: optIn27b, haveWeights: have27b, goldenName: "qwen35-parity.json", binPrefix: "qwen35", mixed: false });
runParity({ label: "Qwen3.6-27B mixed-KV parity (vs mlx-optiq)", snapshot: SNAPSHOT_QWEN35,
  optIn: optIn27b, haveWeights: have27b, goldenName: "qwen35-kv-parity.json", binPrefix: "qwen35-kv", mixed: true });

const optIn4b = process.env.MLX_BUN_TEST_QWEN35_4B === "1";
const have4b = await snapshotQwen35_4bAvailable();
runParity({ label: "Qwen3.5-4B-OptiQ bf16-KV parity (vs mlx-lm)", snapshot: SNAPSHOT_QWEN35_4B,
  optIn: optIn4b, haveWeights: have4b, goldenName: "qwen35-4b-parity.json", binPrefix: "qwen35-4b", mixed: false });
runParity({ label: "Qwen3.5-4B-OptiQ mixed-KV parity (vs mlx-optiq)", snapshot: SNAPSHOT_QWEN35_4B,
  optIn: optIn4b, haveWeights: have4b, goldenName: "qwen35-4b-kv-parity.json", binPrefix: "qwen35-4b-kv", mixed: true });
