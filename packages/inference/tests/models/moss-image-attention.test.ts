import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import { Dtype, MLX_VERSION, activeMemory, clearCache, deviceArchitecture, peakMemory, resetPeakMemory, synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MossAttention, MossJointAttention, MossRefinerAttention } from "../../src/models/moss-image/blocks";
import { MossDenseLinear, MossRmsNorm, type MossLinear } from "../../src/models/moss-image/layers";
import { MossRope } from "../../src/models/moss-image/rope";

// Independent Python MLX 0.32.2 on applegpu_g16s (M4 Pro), the pinned MFLUX
// engine's attention binding. Native reductions are device-dependent. These
// recorded bits qualify that device, as the repository's synthetic digests do;
// they are not a cross-device numerical contract. The independent host-double
// checks below run on every device with their original numerical bounds.
// Regenerate with the same integer LCG below, float32 -> bf16 inputs, then
// mx.fast.scaled_dot_product_attention(q, k, v, scale=D**-0.5).
// Digests cover every output widened exactly to little-endian float32. Odd
// head widths use native fallback arithmetic with intermediate bf16 stores;
// host-double softmax is not their bitwise reference.
const NATIVE_DIGESTS: Record<string, string> = {
  "1,1,1,1": "c34fde18c1b8ec18aa9dd952cdbbcce00cf0505358e6cfcce5a6fe795e1d019b",
  "1,2,3,7": "a0a20d26646dd7dcd72bc8563f1c41ebe3c6b7d7066a6c6ee8699bfc4bc1d476",
  "2,3,7,33": "5cfb60c84e85176479a94bf7bef8e97f24f97b347568953e1ef2c30eac5ceaec",
  "1,2,31,128": "387cb7f82b030c4516ac394bc3025d610aca5608d0aaa0c57d47d943a8120fef",
  "1,2,32,128": "5ea2c59bf6d40219d56f01b53499a2aff609261609509a1bd856cdb45b5ddb17",
  "1,2,33,128": "dff98dce9ce69c3bc0aa8d7af48caa437e0881fb9ada26c2a2c3a20f334c13f6",
  "1,1,127,128": "8c5e8143b82c04570356fefbdec6974e8e929a33719ea0750e247f9fedb11900",
  "1,1,128,128": "89b3eab23df7261c2956080ee4626a3513e59469f1dc33d6b034b974e0d29492",
  "1,1,129,128": "fa3cda882697b28009c7eef8033674184955d07626075b4ec0d57965b58452cc",
  "1,1,279,128": "a81466f79a7e942cc04587b710887f0a629d98a03152219745712a4b88a45833",
  "1,1,513,128": "0773f6158e276b9c5c7e295ec941ad76edab4c71cd4f1273f2ed559b82c8bd27",
  "1,2,65,136": "bf24d4e285670144a0a944c5bfd849a0a9c4d19e99777113e3a1aba8cff50966",
  "1,1,67,257": "50530670b37a20a0f910fb448577e74e55c7ffc3828df4af484a13c719e7f790",
  "peaked": "6b83b51efbe466121ce859333c079fdd699befd881c7a2bc37f8f3ee4237c40a",
  "final-max": "caf1bb2a25135dcdaa3d4b6c95ef99643e93a4ac424704ebcbecd039cfaedc44"
};
const recordedDevice = MLX_VERSION === "0.32.2" && deviceArchitecture() === "applegpu_g16s";

function exactNative(actual: MlxArray, name: string): void {
  expect(actual.dtype).toBe(Dtype.bfloat16);
  const values = host(actual);
  expect(values.every(Number.isFinite)).toBe(true);
  expect(createHash("sha256").update(new Uint8Array(values.buffer, values.byteOffset, values.byteLength)).digest("hex"))
    .toBe(NATIVE_DIGESTS[name]!);
}

/** Nearest bf16 value, with ties to even. */
function bf16(value: number): number {
  const bits = new Uint32Array(new Float32Array([value]).buffer)[0]!;
  return new Float32Array(new Uint32Array([(bits + 0x7fff + ((bits >>> 16) & 1)) & 0xffff0000]).buffer)[0]!;
}

// Independent host-double softmax(Q K^T / sqrt(D)) V, with only the final
// result stored in bf16. Reading the inputs is the only native work here.
function reference(q: MlxArray, k: MlxArray, v: MlxArray): { shape: number[]; values: Float32Array } {
  const shape = q.shape, [batch, heads, length, dim] = shape as [number, number, number, number];
  const qs = host(q), ks = host(k), vs = host(v), values = new Float32Array(qs.length);
  const scores = new Float64Array(length), scale = 1 / Math.sqrt(dim);
  for (let b = 0; b < batch; b++) for (let h = 0; h < heads; h++) {
    const base = (b * heads + h) * length * dim;
    for (let row = 0; row < length; row++) {
      let peak = -Infinity;
      for (let key = 0; key < length; key++) {
        let dot = 0;
        for (let d = 0; d < dim; d++) dot += qs[base + row * dim + d]! * ks[base + key * dim + d]!;
        scores[key] = dot * scale;
        peak = Math.max(peak, scores[key]!);
      }
      let denominator = 0;
      for (let key = 0; key < length; key++) { scores[key] = Math.exp(scores[key]! - peak); denominator += scores[key]!; }
      for (let d = 0; d < dim; d++) {
        let weighted = 0;
        for (let key = 0; key < length; key++) weighted += scores[key]! * vs[base + key * dim + d]!;
        values[base + row * dim + d] = bf16(weighted / denominator);
      }
    }
  }
  return { shape, values };
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

function close(actual: MlxArray, expected: { shape: number[]; values: Float32Array }): void {
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.dtype).toBe(Dtype.bfloat16);
  const a = host(actual), b = expected.values;
  expect(a.length).toBe(b.length);
  let error = 0, norm = 0;
  for (let i = 0; i < a.length; i++) {
    expect(Number.isFinite(a[i])).toBe(true);
    error += (a[i]! - b[i]!) ** 2;
    norm += b[i]! ** 2;
  }
  // Native float32 reductions can cross a bf16 midpoint; cancellation in the
  // weighted sum can amplify this. Keep the existing whole-output and per-query
  // relative bounds. The separate analytical case requires exact bf16 words.
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
  test.skipIf(!recordedDevice)(`MOSS attention matches Python MLX 0.32.2 on applegpu_g16s at [${batch},${heads},${length},${dim}]`, () => {
    const shape = [batch, heads, length, dim];
    using q = input(shape, 11, 2), k = input(shape, 23, 2), v = input(shape, 37);
    using actual = new MossAttention(dim).forward(q, k, v);
    expect(actual.shape).toEqual(shape);
    exactNative(actual, shape.join(","));
  });
  if (dim === 128) test(`MOSS attention agrees with host-double softmax at [${batch},${heads},${length},${dim}]`, () => {
    const shape = [batch, heads, length, dim];
    using q = input(shape, 11, 2), k = input(shape, 23, 2), v = input(shape, 37);
    using actual = new MossAttention(dim).forward(q, k, v);
    close(actual, reference(q, k, v));
  });
}

test.skipIf(!recordedDevice)("MOSS attention matches Python MLX 0.32.2 on applegpu_g16s on peaked scores", () => {
  const shape = [1, 1, 19, 8];
  using q = input(shape, 73, 4), k = input(shape, 91, 4), v = input(shape, 121, 3);
  using actual = new MossAttention(8).forward(q, k, v);
  exactNative(actual, "peaked");
});

test("MOSS attention's analytical two-key case stores sigmoid(-1), rejecting the old numerator rounding", () => {
  const shape = [1, 1, 2, 1];
  using q32 = MlxArray.fromFloat32(new Float32Array([1, 1]), shape);
  using k32 = MlxArray.fromFloat32(new Float32Array([0, 1]), shape);
  using v32 = MlxArray.fromFloat32(new Float32Array([1, 0]), shape);
  using q = q32.astype(Dtype.bfloat16), k = k32.astype(Dtype.bfloat16), v = v32.astype(Dtype.bfloat16);
  // exp(0) / (exp(0) + exp(1)) = sigmoid(-1), whose nearest bf16 is
  // 0.26953125. The removed bf16-numerator rule produced 0.267578125.
  const correct = new Float32Array([0.26953125, 0.26953125]);
  expect(bf16(1 / (1 + Math.exp(1)))).toBe(correct[0]!);
  using actual = new MossAttention(1).forward(q, k, v);
  const expected = reference(q, k, v);
  expect(host(actual)).toEqual(correct);
  expect(expected.values).toEqual(correct);
});

test.skipIf(!recordedDevice)("MOSS attention matches Python MLX 0.32.2 on applegpu_g16s with the maximum at the last key", () => {
  const length = 65, dim = 32, shape = [1, 1, length, dim];
  using q = input(shape, 5, 3), v = input(shape, 7);
  const values = new Float32Array(length * dim);
  for (let i = 0; i < values.length; i++) values[i] = (Math.floor(i / dim) - length / 2) * 10;
  using k32 = MlxArray.fromFloat32(values, shape);
  using k = k32.astype(Dtype.bfloat16);
  using actual = new MossAttention(dim).forward(q, k, v);
  exactNative(actual, "final-max");
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
  const expected = reference(q, k, v);
  using actual = new MossAttention(dim).forward(q, k, v);
  close(actual, expected);
});

test("MOSS attention retains lazy input storage after every input handle is disposed", () => {
  const layer = new MossAttention(128);
  const build = (length: number) => {
    using qs = input([1, length, 2, 128], 17), ks = input([1, length, 2, 128], 19), vs = input([1, length, 2, 128], 29);
    using q = ops.transposeAxes(qs, [0, 2, 1, 3]), k = ops.transposeAxes(ks, [0, 2, 1, 3]), v = ops.transposeAxes(vs, [0, 2, 1, 3]);
    const expected = reference(q, k, v); // host values keep no native input storage alive
    return { actual: layer.forward(q, k, v), expected };
  };
  // The same binding handles changing N without retaining tensors between calls.
  for (const length of [5, 37, 1, 17]) {
    const result = build(length);
    using actual = result.actual;
    close(actual, result.expected);
  }
});

test("MOSS attention rejects incompatible shapes and dtypes without consuming inputs", () => {
  expect(() => new MossAttention(0)).toThrow("head width");
  expect(() => new MossAttention(1.5)).toThrow("head width");
  const layer = new MossAttention(128);
  using q = input([1, 1, 3, 128], 11);
  for (const shape of [[1, 1, 4, 128], [1, 2, 3, 128], [1, 1, 3, 64], [3, 128]]) {
    using bad = input(shape, 13);
    expect(() => layer.forward(q, bad, q)).toThrow("equal [B,H,N,D]");
    if (shape.length !== 4 || shape[3] !== 128)
      expect(() => layer.forward(bad, bad, bad)).toThrow("equal [B,H,N,D]");
  }
  using empty = q.slice([0, 0, 0, 0], [1, 1, 0, 128]);
  expect(() => layer.forward(empty, empty, empty)).toThrow("equal [B,H,N,D]");
  using wide = q.astype(Dtype.float32);
  expect(() => layer.forward(wide, q, q)).toThrow("bf16 inputs");
  expect(() => layer.forward(q, wide, q)).toThrow("bf16 inputs");
  expect(() => layer.forward(q, q, wide)).toThrow("bf16 inputs");
  expect(host(q).length).toBe(3 * 128);
});

test("joint and refiner attention compose the same MOSS attention layer", () => {
  const dim = 256, heads = 2, length = 5;
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
    const attended = reference(qk, qk, v), values = new Float32Array(length * dim), headDim = dim / heads;
    for (let n = 0; n < length; n++) for (let h = 0; h < heads; h++) for (let d = 0; d < headDim; d++)
      values[n * dim + h * headDim + d] = attended.values[(h * length + n) * headDim + d]!;
    const expected = { shape: [1, length, dim], values };
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
