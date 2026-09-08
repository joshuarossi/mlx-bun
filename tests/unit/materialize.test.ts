import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { C, Dtype, activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import { materializeCopy } from "../../src/mlx/materialize";
import { CompiledFunction } from "../../src/mlx/compile";
import { ValueAndGrad } from "../../src/mlx/autograd";
import * as ops from "../../src/mlx/ops";

const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
const bytes = (a: MlxArray) => a.dtype === Dtype.int32
  ? new Uint8Array(new Int32Array(a.toIntTokens()).buffer) : a.rawBytes();

test("a materialized state tail owns compact storage after its large source is disposed", () => {
  clearCache();
  const before = activeMemory();
  const base = ops.zeros([1, 515, 10240], Dtype.bfloat16);
  const view = base.slice([0, 512, 0], [1, 515, 10240]);
  const expected = sha(view.rawBytes());
  const copy = materializeCopy(view);
  copy.eval();
  expect(C.mlx_array_data_bfloat16(copy.handle)).not.toBe(C.mlx_array_data_bfloat16(view.handle));
  base.dispose(); view.dispose(); synchronize(gpuStream); clearCache();
  try {
    expect(sha(copy.rawBytes())).toBe(expected);
    // MLX pools align allocations; assert a bound far below the 10 MiB source.
    expect(activeMemory() - before).toBeLessThan(copy.nbytes + 2 ** 20);
  } finally { copy.dispose(); clearCache(); }
});

test("materialization preserves raw values, noncontiguous order and empty arrays", () => {
  for (const dtype of [Dtype.float32, Dtype.float16, Dtype.bfloat16, Dtype.int32, Dtype.uint32]) {
    const raw = MlxArray.fromFloat32(new Float32Array([0, -0, 1, -2, 3, 4]), [2, 3]);
    const input = raw.astype(dtype); raw.dispose();
    const transposed = ops.transposeAxes(input, [1, 0]);
    const reference = ops.contiguous(transposed);
    const expected = sha(bytes(reference));
    const output = materializeCopy(transposed);
    input.dispose(); transposed.dispose(); reference.dispose();
    try {
      expect(output.shape).toEqual([3, 2]);
      expect(output.dtype).toBe(dtype);
      expect(sha(bytes(output))).toBe(expected);
    } finally { output.dispose(); }
  }
  const bits = new Uint32Array([0x80000000, 0x7fc00123, 0x7f800000, 0xff800000]);
  const input = MlxArray.fromBytesCopy(new Uint8Array(bits.buffer), [4], Dtype.float32);
  const copy = materializeCopy(input);
  try { expect(copy.rawBytes()).toEqual(input.rawBytes()); }
  finally { input.dispose(); copy.dispose(); }
  const empty = ops.zeros([0, 3], Dtype.float32), emptyCopy = materializeCopy(empty);
  try { emptyCopy.eval(); expect(emptyCopy.shape).toEqual([0, 3]); expect(emptyCopy.nbytes).toBe(0); }
  finally { empty.dispose(); emptyCopy.dispose(); clearCache(); }
});

test("materialization supports gradients, scalar values and shape-specialized compiled replay", () => {
  const input = MlxArray.fromFloat32(new Float32Array([2, -3, 4]), [3]);
  const compiled = new CompiledFunction(([x]) => [materializeCopy(x!)], false);
  const vag = new ValueAndGrad(([x]) => {
    const copy = materializeCopy(x!);
    try { return ops.sumAxis(copy, 0, false); }
    finally { copy.dispose(); }
  }, [0]);
  try {
    const [out] = compiled.apply([input]);
    try {
      expect(out!.rawBytes()).toEqual(input.rawBytes());
      expect(C.mlx_array_data_float32(out!.handle)).not.toBe(C.mlx_array_data_float32(input.handle));
    } finally { out!.dispose(); }
    const { value, grads } = vag.apply([input]);
    try {
      expect(value.toFloat32()[0]).toBe(3);
      expect([...grads[0]!.toFloat32()]).toEqual([1, 1, 1]);
      const scalarCopy = materializeCopy(value);
      try { expect(scalarCopy.shape).toEqual([]); expect(scalarCopy.toFloat32()[0]).toBe(3); }
      finally { scalarCopy.dispose(); }
    } finally { value.dispose(); for (const grad of grads) grad.dispose(); }
  } finally { input.dispose(); compiled.dispose(); vag.dispose(); clearCache(); }
});
