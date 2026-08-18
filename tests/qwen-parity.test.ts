// Qwen3.5-architecture logit-parity (OPT-IN slow tier — loads the model).
// Bars, exactly as Josh specified:
//   1. bf16 KV  (KV-quant OFF) → bit-exact vs stock mlx-lm
//   2. mixed KV (KV-quant ON)  → bit-exact vs mlx-optiq (per-layer kv_config)
//
//   MLX_BUN_TEST_QWEN38=1    bun test tests/qwen-parity.test.ts   # 3.8-27B, bf16 bar
//   MLX_BUN_TEST_QWEN35=1    bun test tests/qwen-parity.test.ts   # 3.6-27B, both bars
//   MLX_BUN_TEST_QWEN35_4B=1 bun test tests/qwen-parity.test.ts   # 4B, bf16 bar only
//
// Opt-in + run alone: models are large; the default suite already holds other
// weights and the GPU command buffer fails asynchronously (uncatchable) past
// budget. Regen goldens FIRST on this machine:
//   bun scripts/regen-qwen-parity-goldens.ts [38|27b|4b]
//
// The 4B (8-bit, tied head, no kv_config) is the cheap end-to-end check of the
// whole qwen3_5 graph; the 3.6-27B adds the mixed-KV bar. Qwen3.8-27B has no
// mixed bar (its repo ships no kv_config and no mixed-KV oracle exists for
// it — mixed-KV serving is Lab-tier there, see PLAN.md Phase 14 retarget).

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
  SNAPSHOT_QWEN38,
  snapshotQwen35Available,
  snapshotQwen35_4bAvailable,
  snapshotQwen38Available,
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
  /** Prompt length when the golden includes the full prefill grid
   *  (<binPrefix>-prefill-logits.bin, [T, vocab] f32 — every position). */
  prefill_positions?: number;
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

    const steps = golden.logit_steps ?? STEPS;
    test(`first ${steps} greedy tokens identical; all logits bit-exact`, async () => {
      // Full prefill grid golden (newer regens): logits at EVERY prompt
      // position must be bit-exact, not just the last one.
      const prefillGolden = golden.prefill_positions
        ? goldenAt(`${opts.binPrefix}-prefill-logits.bin`)
        : null;
      if (prefillGolden && !(await prefillGolden.exists()))
        throw new Error(
          `${opts.binPrefix}: manifest requires ${golden.prefill_positions} ` +
            `prefill positions but ${opts.binPrefix}-prefill-logits.bin is missing`,
        );
      const cache = model.makeCache();
      let tokens = golden.prompt_ids;
      try {
        for (let step = 0; step < steps; step++) {
          const logits = model.forward(tokens, cache);
          if (step === 0 && prefillGolden) {
            const grid = new Float32Array(await prefillGolden.arrayBuffer());
            const oursGrid = logits.toFloat32();
            expect(oursGrid.length).toBe(grid.length);
            let gridDiff = 0;
            for (let i = 0; i < grid.length; i++)
              gridDiff = Math.max(gridDiff, Math.abs(oursGrid[i]! - grid[i]!));
            expect(gridDiff).toBe(0);
          }
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
      // Generous ceiling: this is an opt-in, run-alone gate, and the 27B-class
      // targets swap hard on 24 GB machines (~30 s/step observed under
      // pressure). Wall-clock here is meaningless; only the bit-exact
      // comparisons matter (paired parity survives memory pressure).
    }, 1_800_000);
  });
}

const optIn38 = process.env.MLX_BUN_TEST_QWEN38 === "1";
const have38 = await snapshotQwen38Available();
runParity({ label: "Qwen3.8-27B bf16-KV parity (vs mlx-lm)", snapshot: SNAPSHOT_QWEN38,
  optIn: optIn38, haveWeights: have38, goldenName: "qwen38-parity.json", binPrefix: "qwen38", mixed: false });

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
