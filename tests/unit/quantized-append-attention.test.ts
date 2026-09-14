import { expect, test } from "bun:test";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { QuantizedKVCache, quantizedSdpa } from "../../src/model/gemma4-base";
import { quantizedAppendAttention } from "../../src/model/quantized-append-attention";

test("affine committed spans retain sequential attention at each causal prefix", () => {
  const slice = (a: import("../../src/mlx/array").MlxArray, start: number, end: number) =>
    a.slice([0, 0, start, 0], [a.shape[0]!, a.shape[1]!, end, a.shape[3]!]);
  const dispose = (t: ops.QuantizedTensor) => {
    t.packed.dispose(); t.scales.dispose(); t.biases.dispose();
  };
  for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
    for (const groupSize of [32, 64, 128]) for (const bits of [4, 8]) for (const batch of [1, 2]) for (const length of [1, 4]) {
      const prefix = length === 1 ? 128 : 1021;
      ops.randomSeed(42n);
      using q = ops.randomNormal([batch, 24, length, 256], dtype, 0, 1, null);
      using k = ops.randomNormal([batch, 4, prefix + length, 256], dtype, 0, 1, null);
      using v = ops.randomNormal([batch, 4, prefix + length, 256], dtype, 0, 1, null);
      const sequential = new QuantizedKVCache(groupSize, bits), combined = new QuantizedKVCache(groupSize, bits);
      const outputs: import("../../src/mlx/array").MlxArray[] = [];
      try {
        using prefixK = slice(k, 0, prefix), prefixV = slice(v, 0, prefix);
        const prefill = sequential.updateAndFetchQuantized(prefixK, prefixV);
        for (const t of prefill) dispose(t);
        for (let position = 0; position < length; position++) {
          using qiView = slice(q, position, position + 1);
          using qi = ops.contiguous(qiView);
          using ki = slice(k, prefix + position, prefix + position + 1);
          using vi = slice(v, prefix + position, prefix + position + 1);
          const [keys, values] = sequential.updateAndFetchQuantized(ki, vi);
          try { outputs.push(quantizedSdpa(qi, keys, values, 1 / 16, { mode: "", arr: null }, groupSize, bits)); }
          finally { dispose(keys); dispose(values); }
        }
        using expected = ops.concatAxis(outputs, 2);
        const [keys, values] = combined.updateAndFetchQuantized(k, v);
        try {
          using actual = quantizedAppendAttention(q, keys, values, 1 / 16, groupSize, bits);
          expect(actual.shape).toEqual(expected.shape);
          expect(actual.rawBytes()).toEqual(expected.rawBytes());
          expect(combined.offset).toBe(sequential.offset);
        } finally { dispose(keys); dispose(values); }
      } finally {
        for (const output of outputs) output.dispose();
        sequential.dispose(); combined.dispose(); clearCache();
      }
    }
  }
}, 30_000);
