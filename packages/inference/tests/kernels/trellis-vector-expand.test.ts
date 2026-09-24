import { expandWeights } from "../../examples/trellis-expand";
import { expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import {
  vectorTrellisExpandEligible,
  type TrellisGeometry,
} from "@mlx-bun/inference/kernels/trellis";

// Scalar host reference from the existing Trellis codec: circular bit windows,
// a float32 1MAD codebook, and one scale per stored row. No model files needed.
const lut = Float32Array.from({ length: 4096 }, (_, state) => {
  const x = (BigInt(state) * 34038481n + 76625530n) & 0xffffffffn;
  const y = Number((x & 255n) + ((x >> 8n) & 255n) + ((x >> 16n) & 255n) + ((x >> 24n) & 255n)) - 510;
  return y / 147.800537109375;
});

function reference(codes: Int32Array, scales: Float32Array, g: TrellisGeometry): Float32Array {
  const wpb = g.T * g.k / 32, blocks = g.cols / g.T;
  const out = new Float32Array(g.rows * g.cols);
  for (let row = 0; row < g.rows; row++) {
    for (let block = 0; block < blocks; block++) {
      const start = (row * blocks + block) * wpb;
      for (let t = 0; t < g.T; t++) {
        const bit = (g.T - 1 - t) * g.k, word = bit >>> 5, shift = bit & 31;
        const lo = codes[start + word]! >>> shift;
        const hi = shift === 0 ? 0 : codes[start + (word + 1) % wpb]! << (32 - shift);
        out[row * g.cols + block * g.T + t] = lut[(lo | hi) & 4095]! * scales[row]!;
      }
    }
  }
  return out;
}

function geometry(k: number, rows: number, cols = 512, axis: 0 | 1 = 1): TrellisGeometry {
  return { k, rows, cols, L: 12, T: 256, axis,
    inFeatures: axis === 1 ? cols : rows, outFeatures: axis === 1 ? rows : cols };
}

function packedData(g: TrellisGeometry): Int32Array {
  const wpb = g.T * g.k / 32, words = g.cols * g.k / 32;
  const host = new Int32Array(g.rows * words);
  let seed = 53;
  for (let i = 0; i < host.length; i++) host[i] = seed = Math.imul(seed, 1664525) + 1013904223;
  // The existing regression's exhaustive state coverage at the circular edge.
  for (let row = 0; row < g.rows; row++) for (let block = 0; block < g.cols / g.T; block++) {
    const state = block === 0 ? row : (row * 29 + 17) & 4095;
    for (let j = 0; j < 12; j++) {
      const pos = (255 * g.k + j) % (256 * g.k), wi = row * words + block * wpb + (pos >>> 5);
      const mask = 1 << (pos & 31);
      host[wi] = (host[wi]! & ~mask) | (((state >>> j) & 1) ? mask : 0);
    }
  }
  return host;
}

function expectExpansion(codes: MlxArray, scales: MlxArray, host: Int32Array, g: TrellisGeometry): void {
  // Host readback exposes contiguous bytes; preserve strides in the kernel input.
  using contiguousScales = ops.contiguous(scales);
  using expected32 = MlxArray.fromFloat32(reference(host, contiguousScales.toFloat32(), g), [g.rows, g.cols]);
  using expected = expected32.astype(Dtype.bfloat16);
  using actual = expandWeights(codes, scales, g);
  expect(actual.shape).toEqual([g.rows, g.cols]);
  expect(actual.dtype).toBe(Dtype.bfloat16);
  const actualBytes = actual.rawBytes(), expectedBytes = expected.rawBytes();
  const mismatch = actualBytes.findIndex((byte, i) => byte !== expectedBytes[i]);
  expect(mismatch, "first mismatched decoded byte (-1 means identical)").toBe(-1);
}

test("preserves every codebook state, circular windows, and scale dtypes", () => {
  for (const bits of [2, 3, 4]) {
    const g = geometry(bits, 4096), host = packedData(g);
    using ints = MlxArray.fromInt32(host, [g.rows, g.cols * bits / 32]);
    using codes = ints.astype(Dtype.uint32);
    for (const dtype of [Dtype.float16, Dtype.bfloat16, Dtype.float32]) {
      const values = [0, 1, -1, 0.000031, 0.0131, 1.015625, 127, -511];
      using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: g.rows }, (_, i) => values[i % values.length]!), [g.rows]);
      using scales = scale32.astype(dtype);
      expectExpansion(codes, scales, host, g);
    }
  }
}, 30_000);

test("handles strided packed inputs and scales", () => {
  const g = geometry(3, 7, 512, 0), host = packedData(g), words = g.cols * g.k / 32;
  const transposed = new Int32Array(host.length);
  for (let r = 0; r < g.rows; r++) for (let w = 0; w < words; w++) transposed[w * g.rows + r] = host[r * words + w]!;
  using ints = MlxArray.fromInt32(transposed, [words, g.rows]);
  using storage = ints.astype(Dtype.uint32);
  using codes = ops.transposeAxes(storage, [1, 0]);
  using scaleStorage = MlxArray.fromFloat32(Float32Array.from({ length: g.rows * 2 }, (_, i) => (i + 1) / 9), [g.rows, 2]);
  using scales = ops.asStrided(scaleStorage, [g.rows], [2], 0);
  expectExpansion(codes, scales, host, g);
});

test("handles interleaved codes with and without row tiling", () => {
  for (const rows of [7, 128]) {
    const g = { ...geometry(3, rows, 1024, 0), blockInterleave: 2 as const };
    const host = packedData(g), wpb = g.T * g.k / 32, blocks = g.cols / g.T;
    const interleaved = new Int32Array(host.length);
    for (let block = 0; block < blocks; block++) for (let r = 0; r < rows; r++) {
      const from = (r * blocks + block) * wpb;
      const to = (Math.floor(block / 2) * rows * 2 + r * 2 + block % 2) * wpb;
      interleaved.set(host.subarray(from, from + wpb), to);
    }
    using ints = MlxArray.fromInt32(interleaved, [g.cols / 512, rows, 48]);
    using codes = ints.astype(Dtype.uint32);
    using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 17 - 8) / 9), [rows]);
    using scales = scale32.astype(Dtype.float16);
    expectExpansion(codes, scales, host, g);
  }
});

test("eligibility preserves the existing dtype and packing contract", () => {
  const g = geometry(3, 17408, 5120);
  expect(vectorTrellisExpandEligible(g, Dtype.bfloat16)).toBe(true);
  for (const dtype of [Dtype.float16, Dtype.float32]) expect(vectorTrellisExpandEligible(g, dtype)).toBe(false);
  for (const changed of [{ k: 1 }, { k: 5 }, { T: 128 }, { L: 10 }, { rows: 0 }, { cols: 255 }]) {
    expect(vectorTrellisExpandEligible({ ...g, ...changed }, Dtype.bfloat16)).toBe(false);
  }
});
