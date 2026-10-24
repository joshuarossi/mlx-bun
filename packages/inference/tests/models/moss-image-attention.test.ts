import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, clearCache, peakMemory, resetPeakMemory, synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MossAttention, MossJointAttention, MossRefinerAttention } from "../../src/models/moss-image/blocks";
import { MossDenseLinear, MossRmsNorm, type MossLinear } from "../../src/models/moss-image/layers";
import { MossRope } from "../../src/models/moss-image/rope";

// A full score matrix is intentional in this small test reference only. Its
// operation order is the external bf16-numerator experiment's, independently
// of the kernel's two passes and reductions.
function reference(q: MlxArray, k: MlxArray, v: MlxArray, roundNumerator = true, roundDenominator = false): MlxArray {
  using q32 = q.astype(Dtype.float32), k32 = k.astype(Dtype.float32), v32 = v.astype(Dtype.float32);
  using kt = ops.transposeAxes(k32, [0, 1, 3, 2]);
  using dots = ops.matmul(q32, kt);
  using scores = ops.mulScalar(dots, Math.fround(Math.pow(q.shape[3]!, -0.5)));
  using peak = ops.maxAxis(scores, -1, true);
  using shifted = ops.sub(scores, peak);
  using numerators = ops.exp(shifted);
  using rounded = numerators.astype(roundNumerator ? Dtype.bfloat16 : Dtype.float32);
  using stored = rounded.astype(Dtype.float32);
  using denominator = ops.sumAxis(roundDenominator ? stored : numerators, -1, true);
  using weighted = ops.matmul(stored, v32);
  using divided = ops.div(weighted, denominator);
  return divided.astype(Dtype.bfloat16);
}

function input(shape: number[], seed: number, scale = 1): MlxArray {
  const size = shape.reduce((a, b) => a * b, 1);
  const data = Float32Array.from({ length: size }, () => {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return scale * (seed / 2 ** 31 - 1);
  });
  using wide = MlxArray.fromFloat32(data, shape);
  return wide.astype(Dtype.bfloat16);
}

function host(x: MlxArray): Float32Array {
  using wide = x.astype(Dtype.float32);
  using contiguous = ops.contiguous(wide);
  return contiguous.toFloat32();
}

function close(actual: MlxArray, expected: MlxArray): void {
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.dtype).toBe(Dtype.bfloat16);
  const a = host(actual), b = host(expected);
  let error = 0, norm = 0;
  for (let i = 0; i < a.length; i++) {
    expect(Number.isFinite(a[i])).toBe(true);
    error += (a[i]! - b[i]!) ** 2;
    norm += b[i]! ** 2;
  }
  // A float32 QK reduction can move an exponential across a bf16 midpoint.
  // After multiplication by V, cancellation can amplify that into several
  // output ulps. Check relative error, including each query, rather than
  // assuming the only rounding difference is the final bf16 store.
  const dim = actual.shape.at(-1)!;
  for (let row = 0; row < a.length; row += dim) {
    let rowError = 0, rowNorm = 0;
    for (let d = 0; d < dim; d++) {
      rowError += (a[row + d]! - b[row + d]!) ** 2;
      rowNorm += b[row + d]! ** 2;
    }
    expect(Math.sqrt(rowError / Math.max(rowNorm, 1e-30))).toBeLessThanOrEqual(2e-3);
  }
  expect(Math.sqrt(error / Math.max(norm, 1e-30))).toBeLessThanOrEqual(1e-3);
}

for (const [batch, heads, length, dim] of [
  [1, 1, 1, 1], [1, 2, 3, 7], [2, 3, 7, 33],
  [1, 2, 31, 128], [1, 2, 32, 128], [1, 2, 33, 128],
  [1, 1, 127, 128], [1, 1, 128, 128], [1, 1, 129, 128],
  [1, 1, 279, 128], [1, 1, 513, 128],
  [1, 2, 65, 136], [1, 1, 67, 257],
] as const) {
  test(`MOSS attention agrees with the float32/bf16-numerator reference at [${batch},${heads},${length},${dim}]`, () => {
    const shape = [batch, heads, length, dim];
    using q = input(shape, 11, 2), k = input(shape, 23, 2), v = input(shape, 37);
    using actual = new MossAttention(dim).forward(q, k, v);
    using expected = reference(q, k, v);
    close(actual, expected);
  });
}

test("MOSS attention stays within one bf16 spacing at float32 rounding midpoints", () => {
  const shape = [1, 1, 19, 8];
  using q = input(shape, 73, 4), k = input(shape, 91, 4), v = input(shape, 121, 3);
  using expected = reference(q, k, v);
  using noStore = reference(q, k, v, false);
  using roundedDenominator = reference(q, k, v, true, true);
  const b = host(expected);
  expect(host(noStore).some((value, i) => value !== b[i])).toBe(true);
  expect(host(roundedDenominator).some((value, i) => value !== b[i])).toBe(true);
  using actual = new MossAttention(8).forward(q, k, v);
  const a = host(actual);
  // Different float32 reductions can shift the denominator by one ulp and
  // place the quotient on opposite sides of a bf16 midpoint. The resulting
  // adjacent bf16 values are allowed here; the analytical case below rejects
  // either incorrect numerator/denominator rounding rule independently.
  const actualBits = new Uint32Array(a.buffer, a.byteOffset, a.length);
  const expectedBits = new Uint32Array(b.buffer, b.byteOffset, b.length);
  const ordered = (bits: number) => bits & 0x8000 ? 0x8000 - (bits & 0x7fff) : 0x8000 + bits;
  for (let i = 0; i < a.length; i++) {
    expect(Number.isFinite(a[i])).toBe(true);
    expect(Math.abs(ordered(actualBits[i]! >>> 16) - ordered(expectedBits[i]! >>> 16))).toBeLessThanOrEqual(1);
  }
});

test("MOSS attention's analytical two-key case rejects both incorrect rounding rules", () => {
  const shape = [1, 1, 2, 1];
  using q32 = MlxArray.fromFloat32(new Float32Array([1, 1]), shape);
  using k32 = MlxArray.fromFloat32(new Float32Array([0, 1]), shape);
  using v32 = MlxArray.fromFloat32(new Float32Array([1, 0]), shape);
  using q = q32.astype(Dtype.bfloat16), k = k32.astype(Dtype.bfloat16), v = v32.astype(Dtype.bfloat16);
  // exp(-1) rounds to 0.3671875 in bf16. Dividing that stored numerator by
  // 1 + exp(-1) gives 0.26843557, below the bf16 midpoint 0.2685546875.
  // Omitting the store gives 0.26894142; summing stored numerators gives
  // 0.26857143. Both lie above the midpoint, well beyond float32 roundoff.
  const correct = new Float32Array([0.267578125, 0.267578125]);
  const wrong = new Float32Array([0.26953125, 0.26953125]);
  using actual = new MossAttention(1).forward(q, k, v);
  using expected = reference(q, k, v);
  using noStore = reference(q, k, v, false);
  using roundedDenominator = reference(q, k, v, true, true);
  expect(host(actual)).toEqual(correct);
  expect(host(expected)).toEqual(correct);
  expect(host(noStore)).toEqual(wrong);
  expect(host(roundedDenominator)).toEqual(wrong);
});

test("MOSS attention uses the final maximum even when it occurs at the last key", () => {
  const length = 65, dim = 32, shape = [1, 1, length, dim];
  using q = input(shape, 5, 3), v = input(shape, 7);
  const values = new Float32Array(length * dim);
  for (let i = 0; i < values.length; i++) values[i] = (Math.floor(i / dim) - length / 2) * 10;
  using k32 = MlxArray.fromFloat32(values, shape);
  using k = k32.astype(Dtype.bfloat16);
  using expected = reference(q, k, v);
  using actual = new MossAttention(dim).forward(q, k, v);
  close(actual, expected);
});

test("MOSS attention reads transposed, sliced and broadcast strides", () => {
  const batch = 2, heads = 3, length = 35, dim = 128;
  using qs = input([batch, length, heads, dim], 21, 2);
  using q = ops.transposeAxes(qs, [0, 2, 1, 3]);
  using ks = input([batch, heads, length + 3, dim + 5], 31, 2);
  using k = ks.slice([0, 0, 1, 2], [batch, heads, length + 1, dim + 2]);
  using vs = input([1, 1, dim, length], 41);
  using vt = ops.transposeAxes(vs, [0, 1, 3, 2]);
  using v = ops.broadcastTo(vt, [batch, heads, length, dim]);
  using expected = reference(q, k, v);
  using actual = new MossAttention(dim).forward(q, k, v);
  close(actual, expected);
});

test("MOSS attention retains lazy input storage after every input handle is disposed", () => {
  const layer = new MossAttention(128);
  const build = (length: number) => {
    using qs = input([1, length, 2, 128], 17), ks = input([1, length, 2, 128], 19), vs = input([1, length, 2, 128], 29);
    using q = ops.transposeAxes(qs, [0, 2, 1, 3]), k = ops.transposeAxes(ks, [0, 2, 1, 3]), v = ops.transposeAxes(vs, [0, 2, 1, 3]);
    using expected = reference(q, k, v);
    const values = host(expected); // no reference graph may keep the inputs alive for the kernel
    return { actual: layer.forward(q, k, v), values };
  };
  // The same binding handles changing N without retaining tensors between calls.
  for (const length of [5, 37, 1, 17]) {
    const result = build(length);
    using actual = result.actual;
    using wide = MlxArray.fromFloat32(result.values, [1, 2, length, 128]);
    using expected = wide.astype(Dtype.bfloat16);
    close(actual, expected);
  }
});

test("MOSS attention rejects incompatible shapes and dtypes without consuming inputs", () => {
  expect(() => new MossAttention(0)).toThrow("head dimension");
  expect(() => new MossAttention(1.5)).toThrow("head dimension");
  const layer = new MossAttention(128);
  using q = input([1, 1, 3, 128], 11);
  for (const shape of [[1, 1, 4, 128], [1, 2, 3, 128], [1, 1, 3, 64], [3, 128]]) {
    using bad = input(shape, 13);
    expect(() => layer.forward(q, bad, q)).toThrow("need equal nonempty");
    if (shape.length !== 4 || shape[3] !== 128)
      expect(() => layer.forward(bad, bad, bad)).toThrow("need equal nonempty");
  }
  using empty = q.slice([0, 0, 0, 0], [1, 1, 0, 128]);
  expect(() => layer.forward(empty, empty, empty)).toThrow("need equal nonempty");
  using wide = q.astype(Dtype.float32);
  expect(() => layer.forward(wide, q, q)).toThrow("must be bfloat16");
  expect(() => layer.forward(q, wide, q)).toThrow("must be bfloat16");
  expect(() => layer.forward(q, q, wide)).toThrow("must be bfloat16");
  expect(host(q).length).toBe(3 * 128);
});

test("joint and refiner attention compose the same MOSS attention layer", () => {
  const dim = 16, heads = 2, length = 5;
  const identity = Float32Array.from({ length: dim * dim }, (_, i) => +(Math.floor(i / dim) === i % dim));
  using w32 = MlxArray.fromFloat32(identity, [dim, dim]);
  using w = w32.astype(Dtype.bfloat16);
  using fusedWeight = ops.concatAxis([w, w, w], 0);
  using gain32 = MlxArray.fromFloat32(new Float32Array(dim / heads).fill(1), [dim / heads]);
  using gain = gain32.astype(Dtype.bfloat16);
  const norm = new MossRmsNorm(gain, 1e-6), rope = new MossRope(dim / heads, 10000);
  const attention = new MossAttention(dim / heads);
  // A structural adapter, with no concrete private fields, is a valid binding.
  let calls = 0;
  const supplied = { forward(q: MlxArray, k: MlxArray, v: MlxArray) { calls++; return attention.forward(q, k, v); } };
  const projection: MossLinear = { forward: x => ops.reshape(x, x.shape), dispose() {} };
  const joint = new MossJointAttention(new MossDenseLinear(w), new MossDenseLinear(w), new MossDenseLinear(w), projection, norm, norm, rope, heads, supplied);
  const refiner = new MossRefinerAttention(new MossDenseLinear(fusedWeight), new MossDenseLinear(w), norm, norm, rope, heads, supplied);
  try {
    using x = input([1, length, dim], 97);
    const tables = rope.layout(1, 2, 3).joint;
    using h = ops.reshape(x, [1, length, heads, dim / heads]);
    using normalized = norm.forward(h);
    using rotated = rope.apply(normalized, tables);
    using qk = ops.transposeAxes(rotated, [0, 2, 1, 3]), v = ops.transposeAxes(h, [0, 2, 1, 3]);
    using attended = reference(qk, qk, v);
    using transposed = ops.transposeAxes(attended, [0, 2, 1, 3]);
    using expected = ops.reshape(transposed, [1, length, dim]);
    using a = joint.forward(x, tables), b = refiner.forward(x, tables);
    close(a, expected); close(b, expected);
    expect(calls).toBe(2);
  } finally { joint.dispose(); refiner.dispose(); rope.dispose(); }
});

test("joint attention releases an earlier projection if a later projection fails", () => {
  using gain = input([8], 9), x = input([1, 3, 16], 11);
  const norm = new MossRmsNorm(gain, 1e-6), rope = new MossRope(8, 10000);
  let projected: MlxArray | undefined;
  const first: MossLinear = { forward: y => projected = ops.reshape(y, y.shape), dispose() {} };
  const fails: MossLinear = { forward() { throw new Error("projection failed"); }, dispose() {} };
  const attention = new MossJointAttention(first, fails, fails, fails, norm, norm, rope, 2, new MossAttention(8));
  try {
    expect(() => attention.forward(x, rope.layout(1, 1, 2).joint)).toThrow("projection failed");
    expect(projected).toBeDefined();
    expect(() => projected!.eval()).toThrow();
    expect(host(x).length).toBe(48);
  } finally { attention.dispose(); rope.dispose(); }
});

test("MOSS attention memory grows with the output, without an N by N workspace", () => {
  const layer = new MossAttention(128);
  for (const length of [257, 1025, 2049]) {
    const shape = [1, 1, length, 128];
    using q = input(shape, 11), k = input(shape, 13), v = input(shape, 17);
    q.eval(); k.eval(); v.eval();
    synchronize(gpuStream); clearCache();
    const baseline = activeMemory();
    resetPeakMemory();
    using out = layer.forward(q, k, v);
    out.eval(); synchronize(gpuStream);
    const outputBytes = length * 128 * 2;
    expect(peakMemory() - baseline).toBeLessThanOrEqual(outputBytes + 65536);
  }
}, 30000);
