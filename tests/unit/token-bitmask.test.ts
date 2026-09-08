import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { Dtype, activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { applyTokenBitmask } from "../../src/mlx/token-bitmask";

function reference(x: MlxArray, bits: Int32Array): MlxArray {
  const vocab = x.shape.at(-1)!;
  const values = Float32Array.from({ length: vocab }, (_, i) =>
    ((bits[i >>> 5] ?? 0) >>> (i & 31)) & 1 ? 0 : -Infinity);
  const raw = MlxArray.fromFloat32(values, [vocab]);
  const mask = raw.astype(x.dtype); raw.dispose();
  try { return ops.add(x, mask); } finally { mask.dispose(); }
}

function bytes(x: MlxArray): Uint8Array {
  const contiguous = ops.contiguous(x);
  try { return contiguous.rawBytes(); } finally { contiguous.dispose(); }
}

test("token bitmask matches additive masking across dtypes, strides and padded vocabularies", () => {
  for (const dtype of [Dtype.float32, Dtype.float16, Dtype.bfloat16]) {
    for (const vocab of [1, 31, 32, 33, 129, 32000, 248320]) {
      for (const strided of [false, true]) {
        const raw = MlxArray.fromFloat32(Float32Array.from({ length: 3 * vocab }, (_, i) =>
          [0, -0, 1, -1, Infinity, -Infinity, NaN, 0.03125][i % 8]!),
        strided ? [vocab, 3] : [3, vocab]);
        const typed = raw.astype(dtype); raw.dispose();
        const x = strided ? ops.transposeAxes(typed, [1, 0]) : ops.reshape(typed, [3, vocab]);
        typed.dispose();
        const mask = Int32Array.from({ length: Math.ceil(vocab / 32) }, (_, i) => i % 2 ? 0x55555555 : 0xaaaaaaaa);
        if (vocab > 32) mask[mask.length - 1] = 0;
        const expected = reference(x, mask), actual = applyTokenBitmask(x, mask);
        try {
          expect(actual.shape).toEqual(x.shape);
          expect(bytes(actual)).toEqual(bytes(expected));
        } finally { expected.dispose(); actual.dispose(); x.dispose(); }
      }
    }
  }
});

test("lazy token masking owns a snapshot of host bits and rejects missing words", () => {
  const logits = MlxArray.fromFloat32(Float32Array.from({ length: 2 * 3 * 65 }, (_, i) => i % 65), [2, 3, 65]);
  const bits = new Int32Array([1, 1]);
  const first = applyTokenBitmask(logits, bits);
  bits.fill(-1);
  const second = applyTokenBitmask(logits, bits);
  const empty = applyTokenBitmask(logits, new Int32Array());
  const oversized = applyTokenBitmask(logits, new Int32Array(8).fill(-1));
  const expectedFirst = reference(logits, new Int32Array([1, 1]));
  const expectedSecond = reference(logits, new Int32Array([-1, -1]));
  try {
    expect(bytes(first)).toEqual(bytes(expectedFirst));
    expect(bytes(second)).toEqual(bytes(expectedSecond));
    expect(empty.toFloat32().every((value) => value === -Infinity)).toBe(true);
    expect(bytes(oversized)).toEqual(bytes(logits));
  } finally {
    for (const x of [logits, first, second, empty, oversized, expectedFirst, expectedSecond]) x.dispose();
  }
});

test("repeated token masking releases per-step inputs and results", () => {
  const logits = MlxArray.fromFloat32(new Float32Array(4096), [1, 4096]);
  const bits = new Int32Array(128).fill(-1);
  const warm = applyTokenBitmask(logits, bits); warm.eval(); warm.dispose();
  synchronize(gpuStream);
  clearCache();
  const before = activeMemory();
  try {
    for (let i = 0; i < 100; i++) {
      bits[i % bits.length] = i;
      const out = applyTokenBitmask(logits, bits); out.eval(); out.dispose();
    }
    synchronize(gpuStream);
    clearCache();
    expect(activeMemory()).toBe(before);
  } finally { logits.dispose(); }
});
