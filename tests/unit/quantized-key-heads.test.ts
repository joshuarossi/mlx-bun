import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import * as ops from "../../src/mlx/ops";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import { createCausalMask, FINFO_MIN, quantizedSdpaUnfused } from "../../src/model/gemma4-base";
import type { MlxArray } from "../../src/mlx/array";

test("three-query affine attention preserves the separate-head reference with strided KV", () => {
  const digest = (array: MlxArray) => createHash("sha256").update(array.rawBytes()).digest("hex");
  const dispose = (triple: ops.QuantizedTensor) => {
    triple.packed.dispose(); triple.scales.dispose(); triple.biases.dispose();
  };
  const map = (triple: ops.QuantizedTensor, fn: (array: MlxArray) => MlxArray): ops.QuantizedTensor =>
    ({ packed: fn(triple.packed), scales: fn(triple.scales), biases: fn(triple.biases) });
  for (const batch of [1, 2]) for (const length of [8192, 8195])
    for (const dtype of [Dtype.bfloat16, Dtype.float32]) {
      ops.randomSeed(42n);
      using queryRows = ops.randomNormal([batch, 3, 24, 256], dtype, 0, 1, null);
      using queries = ops.transposeAxes(queryRows, [0, 2, 1, 3]);
      using keys = ops.randomNormal([batch, 4, length + 17, 256], dtype, 0, 1, null);
      using values = ops.randomNormal([batch, 4, length + 17, 256], dtype, 0, 1, null);
      const fullK = ops.quantize(keys, 64, 4), fullV = ops.quantize(values, 64, 4);
      const cut = (a: MlxArray) => a.slice([0, 0, 0, 0], [batch, 4, length, a.shape[3]!]);
      const k = map(fullK, cut), v = map(fullV, cut);
      const expandedK = map(k, a => ops.expandDims(a, -3));
      const expandedV = map(v, a => ops.expandDims(a, -3));
      try {
        // Pinned mlx-lm composition: every query head is a separate broadcast
        // batch in both matmuls. No production dispatch helper supplies this oracle.
        using scaled = ops.mulScalar(queries, 1 / 16);
        using grouped = ops.reshape(scaled, [batch, 4, 6, 3, 256]);
        using scores = ops.quantizedMatmulQT(grouped, expandedK, true, 64, 4);
        using mask = createCausalMask(3, length - 3, null);
        using floor = ops.scalarLike(FINFO_MIN[scores.dtype]!, scores);
        using masked = ops.where(mask, scores, floor);
        using probabilities = ops.softmaxAxis(masked, -1, true);
        using reference = ops.quantizedMatmulQT(probabilities, expandedV, false, 64, 4);
        using expected = ops.reshape(reference, [batch, 24, 3, 256]);
        using actual = quantizedSdpaUnfused(queries, k, v, 1 / 16, { mode: "causal", arr: null }, 64, 4);
        expect(actual.shape).toEqual(expected.shape);
        expect(digest(actual)).toBe(digest(expected));
      } finally {
        for (const triple of [expandedK, expandedV, k, v, fullK, fullV]) dispose(triple);
        clearCache();
      }
    }
}, 15_000);
