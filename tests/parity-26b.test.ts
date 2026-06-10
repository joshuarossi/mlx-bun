// 26B-A4B MoE logit-parity (OPT-IN slow tier, tier-d contract):
// single-forward logits bit-exact vs the oracle (router top-k +
// gather_qmm path included), greedy prefix identical.
//
//   MLX_BUN_TEST_26B=1 bun test tests/parity-26b.test.ts
//
// Opt-in because bun test runs every file in ONE process: the default
// suite already holds the 12B (8.3 GB) + e4b (7 GB) weights, and adding
// the 26B (16.4 GB) exceeds the 24 GB machine — the GPU command buffer
// fails asynchronously and mlx's completion-handler check_error throw
// is uncatchable (terminates the process). Run this file alone.
// Regen: bun scripts/regen-parity-goldens-26b.ts (explicit, never automatic).

import { describe, expect, test } from "bun:test";
import { SNAPSHOT_26B, snapshot26bAvailable } from "./paths";

const STEPS = 12;

const optIn = process.env.MLX_BUN_TEST_26B === "1";
const haveWeights = await snapshot26bAvailable();
const haveGoldens = await Bun.file("goldens/parity-26b.json").exists();

describe.skipIf(!optIn || !haveWeights || !haveGoldens)("26B-A4B MoE greedy decode parity", async () => {
  if (!optIn || !haveWeights || !haveGoldens) return;
  const golden = (await Bun.file("goldens/parity-26b.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
    logit_steps: number;
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, KVCache, argmaxLastPosition, lastPositionLogits } =
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

  const haveKvMixGolden = await Bun.file("goldens/logits-26b-kvmix.bin").exists();
  test.skipIf(!haveKvMixGolden)(
    "mixed-precision KV (kv_config.json): single-forward parity",
    async () => {
      // True mixed bits on the 26B: kv8 on full layers 5/11, kv4 on
      // 17/23 (kv_config.json). Pre-convert like the oracle did
      // (quantize-then-prefill at offset 0), forward once, compare.
      // Tier b tolerance: kv4 layers present → ≤1.0 on softcapped
      // logits (strided-vs-contiguous quantized_matmul rounding,
      // documented in tests/kv-quant.test.ts). This also exercises the
      // L>1 prefill-over-quantized-cache path (quantizedSdpa, multi-row).
      const byLayer = new Map(config.kvQuant!.map((e) => [e.layerIdx, e]));
      const caches = model.makeCache();
      try {
        let applied = 0;
        for (let i = 0; i < caches.length; i++) {
          const c = caches[i]!;
          const e = byLayer.get(i);
          if (c instanceof KVCache && e) {
            caches[i] = c.toQuantized(e.groupSize, e.bits);
            applied++;
          }
        }
        expect(applied).toBe(
          config.text.layerTypes.filter((t) => t === "full_attention").length,
        );
        const logits = model.forward(golden.prompt_ids, caches);
        const ours = lastPositionLogits(logits);
        logits.dispose();
        const ref = new Float32Array(
          await Bun.file("goldens/logits-26b-kvmix.bin").arrayBuffer(),
        );
        let maxDiff = 0;
        for (let i = 0; i < ref.length; i++)
          maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
        expect(maxDiff).toBeLessThanOrEqual(1.0);
      } finally {
        for (const c of caches) c.dispose();
      }
    },
    300_000,
  );
});
