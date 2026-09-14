import { configureRuntime } from "../../src/runtime-config";
import { expect, test } from "bun:test";
import { Dtype } from "../../src/mlx/ffi";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { TurboQuantKVCache } from "../../src/model/gemma4-base";
import { BatchedTurboQuantKVCache } from "../../src/model/batched-turboquant-kv";
import { disposeResources } from "../../src/engine/resources";

function inputs(B: number, N: number, seed: number): [MlxArray, MlxArray] {
  using key = ops.randomKey(BigInt(seed));
  using k = ops.randomNormal([B, 2, N, 64], Dtype.float32, 0, 1, key);
  using next = ops.randomKey(BigInt(seed + 1));
  using v = ops.randomNormal([B, 2, N, 64], Dtype.float32, 0, 1, next);
  return [k.astype(Dtype.bfloat16), v.astype(Dtype.bfloat16)];
}
function equalState(actual: TurboQuantKVCache, expected: TurboQuantKVCache) {
  expect(actual.offset).toBe(expected.offset);
  expect(actual.headDim).toBe(expected.headDim);
  const a = actual.state(), b = expected.state();
  try {
    expect(a).toHaveLength(5); expect(b).toHaveLength(5);
    for (let field = 0; field < 5; field++) {
      using aa = ops.contiguous(a[field]!); using bb = ops.contiguous(b[field]!);
      expect(aa.shape).toEqual(bb.shape); expect(aa.dtype).toBe(bb.dtype);
      expect(Buffer.from(aa.rawBytesView()).equals(Buffer.from(bb.rawBytesView()))).toBe(true);
    }
  } finally { disposeResources([...a, ...b]); }
}

for (const fused of [false, true]) for (const [kb, vb] of [[8, 3], [4, 2], [5, 5]] as const)
  test(`TurboQuant ${kb}/${vb}, fused=${fused}: unequal rows retain encoded state across rollback and re-admission`, () => {
    const restore = configureRuntime({ MLX_BUN_TURBOQUANT_FUSED_DECODE: fused ? "1" : "0" });
    const group = new BatchedTurboQuantKVCache(kb, vb);
    const references = [new TurboQuantKVCache(kb, vb), new TurboQuantKVCache(kb, vb)];
    try {
      for (const [row, length] of [3, 7].entries()) {
        const input = inputs(1, length, 10 + row * 2);
        try { disposeResources(references[row]!.updateAndFetch(...input)); }
        finally { disposeResources(input); }
      }
      group.mergeRows(references);
      expect(group.rowOffsets).toEqual([3, 7]); expect(group.leftPad).toEqual([4, 0]);
      expect(group.state()).toHaveLength(5);
      const verify = () => {
        for (let row = 0; row < references.length; row++) {
          const extracted = group.extractRow(row);
          try { equalState(extracted, references[row]!); }
          finally { extracted.dispose(); }
        }
      };
      verify();
      const append = (N: number, seed: number, keep = [N, N]) => {
        const input = inputs(2, N, seed);
        try {
          group.specRoundBegin();
          disposeResources(group.updateAndFetch(...input));
          group.specRoundRollback(keep);
          for (let row = 0; row < 2; row++) {
            using k = input[0].slice([row, 0, 0, 0], [row + 1, 2, keep[row]!, 64]);
            using v = input[1].slice([row, 0, 0, 0], [row + 1, 2, keep[row]!, 64]);
            disposeResources(references[row]!.updateAndFetch(k, v));
          }
          verify();
        } finally { disposeResources(input); }
      };
      append(3, 20, [1, 3]);
      expect(group.rowOffsets).toEqual([4, 10]);
      const mask = group.makeMask(2, null);
      try { expect(mask.mode).toBe("array"); expect(mask.arr!.shape).toEqual([2, 1, 2, 12]); }
      finally { mask.arr?.dispose(); }
      append(2, 30);
      group.filterRows([1]);
      const retained = group.extractRow(0);
      try { equalState(retained, references[1]!); }
      finally { retained.dispose(); }
      group.mergeRows([references[0]!, group]);
      verify();
      append(2, 40);
      group.filterRows([]);
      expect(group.state()).toHaveLength(0);
      expect(group.bytesPerToken()).toBe(0);
      group.mergeRows(references);
      verify();
    } finally {
      group.dispose(); disposeResources(references);
      restore();
    }
  });
