import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { createModel } from "@mlx-bun/inference/models";
import { Weights, loadModelConfig } from "@mlx-bun/inference/artifacts";
import { Qwen35Model } from "@mlx-bun/inference/models/qwen3_5";
import { TrellisLinear } from "@mlx-bun/inference/layers";
import { gateUpCodebookEligible } from "../../src/kernels/trellis/gate-up";
import { scatterBitsEligible, scatterFloatCodebookEligible } from "../../src/kernels/trellis/scatter";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { createRuntimeConfig, runtimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { deviceArchitecture, clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxArray } from "@mlx-bun/mlx/array";

const artifact = process.env.MLX_BUN_TEST_TRELLIS_MODEL;
const digest = (a: MlxArray) => createHash("sha256").update(a.rawBytesView()).digest("hex");

test.skipIf(!artifact || deviceArchitecture() !== "applegpu_g13s")(
  "Trellis codebook and bit representation preserve complete Qwen logits, live state and greedy continuation",
  async () => {
    const weights = await Weights.open(artifact!);
    const model = createModel(weights, await loadModelConfig(artifact!));
    if (!(model instanceof Qwen35Model)) { weights.dispose(); throw new Error("requires a packed Qwen3.5/3.8 artifact"); }
    expect(model.layers.length).toBe(64);
    expect(model.layers.filter(layer => layer.mlp.gate instanceof TrellisLinear &&
      gateUpCodebookEligible(layer.mlp.gate.geometry, 1, Dtype.bfloat16, 13)).length).toBeGreaterThan(0);
    const eligibleDown = model.layers.flatMap(layer => layer.mlp.down instanceof TrellisLinear &&
      scatterBitsEligible(layer.mlp.down.geometry, 1, Dtype.bfloat16, 13) ? [layer.mlp.down.geometry.k] : []);
    expect(eligibleDown.filter(k => k === 3).length).toBe(40);
    expect(eligibleDown.filter(k => k === 2 || k === 4).length).toBe(24);
    expect(model.layers.filter(layer => layer.mlp.down instanceof TrellisLinear &&
      scatterFloatCodebookEligible(layer.mlp.down.geometry, 1, Dtype.bfloat16, 13)).length).toBe(64);
    const run = (mode: "inline" | "codebook" | "combined" | "generic" | "scatter-codebook", prompt: number[]) => withRuntimeConfig(createRuntimeConfig({
      ...runtimeConfig().values, MLX_BUN_NO_FUSED_SDPA: "1", MLX_BUN_TRELLIS_VARIANT: "13",
      MLX_BUN_TRELLIS_GATEUP_CODEBOOK: mode === "inline" ? "0" : "1",
      MLX_BUN_TRELLIS_MIXED_BITS: ["combined", "generic", "scatter-codebook"].includes(mode) ? "1" : "0",
      MLX_BUN_TRELLIS_SCATTER_BITS: ["combined", "generic", "scatter-codebook"].includes(mode) ? "1" : "0",
      MLX_BUN_TRELLIS_GENERIC_SCATTER_BITS: mode === "generic" || mode === "scatter-codebook" ? "1" : "0",
      MLX_BUN_TRELLIS_SCATTER_FLOAT_CODEBOOK: mode === "scatter-codebook" ? "1" : "0",
    }), () => {
      const caches = model.makeCache();
      const output: { logits: string; tokens: number[]; state: unknown[] }[] = [];
      let input = prompt;
      try {
        for (let step = 0; step < 17; step++) {
          using logits = model.forward(input, caches);
          ops.evalAll([logits, ...caches.flatMap(c => c.state())]);
          expect([Dtype.bfloat16, Dtype.float32]).toContain(logits.dtype);
          const bytes = logits.rawBytesView(), view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
          const width = logits.dtype === Dtype.bfloat16 ? 2 : 4;
          for (let i = 0; i < bytes.length; i += width) {
            const exponent = width === 2 ? (view.getUint16(i, true) >>> 7) & 255 : (view.getUint32(i, true) >>> 23) & 255;
            if (exponent === 255) throw new Error(`non-finite logit: mode=${mode}, step=${step}, byte=${i}`);
          }
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
        const baseline = run("inline", prompt), codebook = run("codebook", prompt), combined = run("combined", prompt);
        const generic = run("generic", prompt);
        const scatterCodebook = run("scatter-codebook", prompt);
        expect(codebook).toEqual(baseline);
        expect(combined).toEqual(baseline);
        expect(generic).toEqual(baseline);
        expect(scatterCodebook).toEqual(baseline);
        console.log(`[trellis-codebook+bits] prefix=${length}: 17 full logit tensors, all live state and tokens match across five modes`);
      }
    } finally { weights.dispose(); clearCache(); }
  }, 180_000);
