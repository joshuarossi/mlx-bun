// Weights-loaded oracle parity: values read through the zero-copy load
// path must match the Python reference (goldens/values.json).
// Slow tier: skipped automatically if the snapshot isn't on disk.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const goldenFile = Bun.file("goldens/values.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("oracle value parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    input_layernorm_l0_first16: number[];
    input_layernorm_l0_sum: number;
    embed_dequant_rows4_first16: number[];
    embed_dequant_rows4_sum: number;
    embed_dequant_shape: number[];
  };

  const { Weights } = await import("../src/weights");
  const { MlxArray } = await import("../src/mlx/array");

  const weights = await Weights.open(SNAPSHOT);

  test("bf16 layernorm weight reads identically", () => {
    const ln = weights.tensor("language_model.model.layers.0.input_layernorm.weight");
    const values = ln.toFloat32();
    for (let i = 0; i < 16; i++)
      expect(values[i]).toBe(golden.input_layernorm_l0_first16[i]!);
    const sum = values.reduce((a, b) => a + b, 0);
    // fp32 accumulation order differs from mlx's reduction; allow tiny slack
    expect(Math.abs(sum - golden.input_layernorm_l0_sum)).toBeLessThan(1e-2);
  });

  test("dequantized embedding rows match oracle (optInt packing works)", () => {
    const sliceRows = (name: string, rows: number) => {
      const t = weights.tensor(name);
      return t.slice([0, 0], [rows, t.shape[1]!]);
    };
    const w = sliceRows("language_model.model.embed_tokens.weight", 4);
    const scales = sliceRows("language_model.model.embed_tokens.scales", 4);
    const biases = sliceRows("language_model.model.embed_tokens.biases", 4);

    const deq = MlxArray.dequantize(w, scales, biases, 64, 8);
    expect(deq.shape).toEqual(golden.embed_dequant_shape);
    const values = deq.toFloat32();
    for (let i = 0; i < 16; i++)
      expect(values[i]).toBe(golden.embed_dequant_rows4_first16[i]!);
    const sum = values.reduce((a, b) => a + b, 0);
    expect(Math.abs(sum - golden.embed_dequant_rows4_sum)).toBeLessThan(1e-2);
    for (const a of [w, scales, biases, deq]) a.dispose();
  });
});
