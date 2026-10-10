import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { Weights, loadModelConfig } from "@mlx-bun/inference/artifacts";
import { Qwen35Model } from "@mlx-bun/inference/models/qwen3_5";
import { TrellisLinear } from "@mlx-bun/inference/layers";
import { TRELLIS_MATVEC_MAX_M, fusedGateUpSwiglu, fusedGateUpSwigluMixed, trellisScatter, type ScatterRepresentation } from "@mlx-bun/inference/kernels/trellis";
import { gateUpCodebookEligible } from "../../src/kernels/trellis/gate-up";
import { scatterBitsEligible, scatterFloatCodebookEligible } from "../../src/kernels/trellis/scatter";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { createRuntimeConfig, runtimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { deviceArchitecture, clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxArray } from "@mlx-bun/mlx/array";

const artifact = process.env.MLX_BUN_TEST_TRELLIS_MODEL;
const digest = (a: MlxArray) => createHash("sha256").update(a.rawBytesView()).digest("hex");

type Mode = "inline" | "codebook" | "combined" | "generic" | "scatter-codebook";
interface Representation { codebook: boolean; mixedBits: boolean; scatter: ScatterRepresentation }
const representation = (mode: Mode): Representation => {
  const bits = mode === "combined" || mode === "generic" || mode === "scatter-codebook";
  return { codebook: mode !== "inline", mixedBits: bits, scatter: { bits,
    genericBits: mode === "generic" || mode === "scatter-codebook", floatCodebook: mode === "scatter-codebook" } };
};

/** The MLP step of the packed graph that serves this artifact on `applegpu_g13s`
 *  (same-width gate/up fuse, different widths take the mixed kernel's split
 *  tail, down runs the packed matvec) with each single-row representation
 *  explicit; wider inputs run the loaded MLP. */
function representedMlp(mlp: { gate: unknown; up: unknown; down: unknown; forward(x: MlxArray, rowContiguous?: boolean, independentRows?: boolean): MlxArray },
  r: Representation) {
  const gate = mlp.gate as TrellisLinear, up = mlp.up as TrellisLinear, down = mlp.down as TrellisLinear;
  return {
    forward(x: MlxArray, inputRowContiguous = false, independentRows = false): MlxArray {
      const lead = x.shape.slice(0, -1), M = lead.reduce((a, b) => a * b, 1);
      if (M > TRELLIS_MATVEC_MAX_M) return mlp.forward(x, inputRowContiguous, independentRows);
      using mid = gate.geometry.k === up.geometry.k ? fusedGateUpSwiglu(x, gate, up, 13, r.codebook)
        : fusedGateUpSwigluMixed(x, gate, up, 13, "split", r.mixedBits);
      using rows = ops.reshape(mid, [M, down.geometry.inFeatures]);
      using y = trellisScatter(rows, down.codes, down.scales, down.geometry, 13, down.useSharedScatterCodebook, r.scatter);
      return ops.reshape(y, [...lead, down.geometry.outFeatures]);
    },
  };
}

test.skipIf(!artifact || deviceArchitecture() !== "applegpu_g13s")(
  "Trellis codebook and bit representation preserve complete Qwen logits, live state and greedy continuation",
  async () => {
    const weights = await Weights.open(artifact!);
    // The generic graph reads each layer's MLP per forward, so the representations below reach it.
    const model = new Qwen35Model(weights, await loadModelConfig(artifact!));
    expect(model.layers.length).toBe(64);
    expect(model.layers.filter(layer => layer.mlp.gate instanceof TrellisLinear &&
      gateUpCodebookEligible(layer.mlp.gate.geometry, 1, Dtype.bfloat16, 13, deviceArchitecture())).length).toBeGreaterThan(0);
    const eligibleDown = model.layers.flatMap(layer => layer.mlp.down instanceof TrellisLinear &&
      scatterBitsEligible(layer.mlp.down.geometry, 1, Dtype.bfloat16, 13) ? [layer.mlp.down.geometry.k] : []);
    expect(eligibleDown.filter(k => k === 3).length).toBe(40);
    expect(eligibleDown.filter(k => k === 2 || k === 4).length).toBe(24);
    expect(model.layers.filter(layer => layer.mlp.down instanceof TrellisLinear &&
      scatterFloatCodebookEligible(layer.mlp.down.geometry, 1, Dtype.bfloat16, 13, deviceArchitecture())).length).toBe(64);
    const loaded = model.layers.map(layer => layer.mlp);
    const install = (mode: Mode) => model.layers.forEach((layer, i) => {
      (layer as unknown as { mlp: unknown }).mlp = representedMlp(loaded[i]!, representation(mode));
    });
    const run = (mode: Mode, prompt: number[]) => withRuntimeConfig(createRuntimeConfig({
      ...runtimeConfig().values, MLX_BUN_NO_FUSED_SDPA: "1",
    }), () => {
      install(mode);
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
    } finally {
      model.layers.forEach((layer, i) => { (layer as unknown as { mlp: unknown }).mlp = loaded[i]; });
      weights.dispose(); clearCache();
    }
  }, 180_000);
