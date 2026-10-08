import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { createModel } from "@mlx-bun/inference/models";
import { Weights, loadModelConfig } from "@mlx-bun/inference/artifacts";
import { Qwen35Model } from "@mlx-bun/inference/models/qwen3_5";
import { TrellisLinear } from "@mlx-bun/inference/layers";
import { gateUpCodebookEligible } from "../../src/kernels/trellis/gate-up";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { createRuntimeConfig, runtimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { deviceArchitecture, clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxArray } from "@mlx-bun/mlx/array";

const artifact = process.env.MLX_BUN_TEST_TRELLIS_MODEL;
const digest = (a: MlxArray) => createHash("sha256").update(a.rawBytesView()).digest("hex");

test.skipIf(!artifact || deviceArchitecture() !== "applegpu_g13s")(
  "gate/up codebook preserves complete Qwen logits, live state and greedy continuation",
  async () => {
    const weights = await Weights.open(artifact!);
    const model = createModel(weights, await loadModelConfig(artifact!));
    if (!(model instanceof Qwen35Model)) { weights.dispose(); throw new Error("requires a packed Qwen3.5/3.8 artifact"); }
    expect(model.layers.length).toBe(64);
    expect(model.layers.filter(layer => layer.mlp.gate instanceof TrellisLinear &&
      gateUpCodebookEligible(layer.mlp.gate.geometry, 1, Dtype.bfloat16, 13)).length).toBeGreaterThan(0);
    const run = (enabled: boolean, prompt: number[]) => withRuntimeConfig(createRuntimeConfig({
      ...runtimeConfig().values, MLX_BUN_NO_FUSED_SDPA: "1", MLX_BUN_TRELLIS_VARIANT: "13", MLX_BUN_TRELLIS_GATEUP_CODEBOOK: enabled ? "1" : "0",
    }), () => {
      const caches = model.makeCache();
      const output: { logits: string; tokens: number[]; state: unknown[] }[] = [];
      let input = prompt;
      try {
        for (let step = 0; step < 17; step++) {
          using logits = model.forward(input, caches);
          ops.evalAll([logits, ...caches.flatMap(c => c.state())]);
          using last = logits.slice([0, input.length - 1, 0], [1, input.length, logits.shape[2]!]);
          using argmax = ops.argmaxAxis(last, -1);
          const tokens = Array.from(argmax.toIntTokens());
          const state = caches.map(cache => ({ signature: cache.signature(), offset: cache.offset,
            tensors: cache.state().map(a => {
              const shape = a.shape;
              const cropped = cache.signature() !== "ssm" && shape.length === 4 && cache.offset < shape[2]!
                ? a.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
              using contiguous = ops.contiguous(cropped ?? a);
              try { return { shape: contiguous.shape, dtype: contiguous.dtype, sha256: digest(contiguous) }; }
              finally { cropped?.dispose(); }
            }) }));
          output.push({ logits: digest(logits), tokens, state });
          input = tokens;
        }
        return output;
      } finally { caches.forEach(c => c.dispose()); clearCache(); }
    });
    try {
      // Different prefix lengths exercise dense prefill and the single-row
      // prefill boundary, then 16 ordinary decode steps from each state.
      for (const length of [1, 17, 32]) {
        const prompt = Array.from({ length }, (_, i) => 100 + i * 7);
        const baseline = run(false, prompt), candidate = run(true, prompt);
        expect(candidate).toEqual(baseline);
        console.log(`[trellis-codebook] prefix=${length}: 17 full logit tensors, all live state and tokens match`);
      }
    } finally { weights.dispose(); clearCache(); }
  }, 180_000);
