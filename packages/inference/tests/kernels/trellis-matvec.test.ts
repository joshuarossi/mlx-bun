import { expect, test } from "bun:test";
import { CompiledFunction, Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import {
  expandTrellis, fusedGateUpSwiglu, fusedGateUpSwigluMixed, trellisReduce, trellisScatter,
  type TrellisGeometry,
} from "@mlx-bun/inference/kernels/trellis";

function weights(k: number, axis: 0 | 1 = 1, interleave = false) {
  const rows = 64, cols = 512, words = cols * k / 32;
  let seed = 31 + k;
  const data = Int32Array.from({ length: rows * words }, () => seed = Math.imul(seed, 1664525) + 1013904223);
  using ints = MlxArray.fromInt32(data, interleave ? [1, rows, 48] : [rows, words]);
  const codes = ints.astype(Dtype.uint32);
  using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 17 + 1) / 200), [rows]);
  const scales = scale32.astype(Dtype.float16);
  const geometry: TrellisGeometry = { k, L: 12, T: 256, axis, rows, cols,
    inFeatures: axis === 1 ? cols : rows, outFeatures: axis === 1 ? rows : cols,
    ...(interleave ? { blockInterleave: 2 as const } : {}) };
  return { codes, scales, geometry, [Symbol.dispose]() { codes.dispose(); scales.dispose(); } };
}

function input(m: number, k: number, dtype: Dtype, batched = false) {
  using raw = MlxArray.fromFloat32(Float32Array.from({ length: m * k }, (_, i) => ((i * 73 + 19) % 257 - 128) / 31), batched ? [1, m, k] : [m, k]);
  return raw.astype(dtype);
}

function same(actual: MlxArray, expected: MlxArray): void {
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.dtype).toBe(expected.dtype);
  expect(Buffer.from(actual.rawBytes()).equals(Buffer.from(expected.rawBytes()))).toBe(true);
}

// Allow cold Metal compilation across all variants; this is a correctness gate.
test("shared matvec schedules retain baseline decoded values and accumulation", () => {
  for (const k of [2, 3, 4]) for (const axis of [0, 1] as const) {
    using w = weights(k, axis);
    const run = axis === 1 ? trellisReduce : trellisScatter;
    for (const m of [1, 2, 3, 4]) for (const dtype of [Dtype.bfloat16, Dtype.float32]) {
      using x = input(m, w.geometry.inFeatures, dtype);
      using expected = run(x, w.codes, w.scales, w.geometry, 6);
      for (const variant of [7, 8, 9, 10, 11, 12, 13]) {
        using actual = run(x, w.codes, w.scales, w.geometry, variant);
        same(actual, expected);
      }
      using rounded = run(x, w.codes, w.scales, w.geometry, 0);
      for (const variant of [1, 2, 3]) {
        using actual = run(x, w.codes, w.scales, w.geometry, variant);
        same(actual, rounded);
      }
    }
  }
}, 60_000);

test("interleaved scatter codebook retains outputs across the small row counts", () => {
  using w = weights(3, 0, true);
  for (const m of [1, 2, 3, 4]) {
    using x = input(m, w.geometry.inFeatures, Dtype.bfloat16);
    using expected = trellisScatter(x, w.codes, w.scales, w.geometry, 6);
    using actual = trellisScatter(x, w.codes, w.scales, w.geometry, 13, true);
    same(actual, expected);
  }
});

test("fused gate/up schedules and mixed kernel preserve the fused activation tail", () => {
  for (const k of [2, 3, 4]) {
    using gate = weights(k), up = weights(k);
    for (const m of [1, 2, 3, 4]) {
      using x = input(m, gate.geometry.inFeatures, Dtype.bfloat16, true);
      using expected = fusedGateUpSwiglu(x, gate, up, 6);
      using shared = fusedGateUpSwiglu(x, gate, up, 13);
      using mixed = fusedGateUpSwigluMixed(x, gate, up, 13, "fused");
      same(shared, expected);
      same(mixed, expected);
    }
  }
}, 30_000);

test("different gate/up bit widths preserve the split compiled activation tail", () => {
  const swiglu = new CompiledFunction(([gate, up]) => {
    const sigmoid = ops.sigmoid(gate!), silu = ops.mul(gate!, sigmoid);
    const out = ops.mul(silu, up!);
    sigmoid.dispose(); silu.dispose();
    return [out];
  });
  try {
    for (const [gk, uk] of [[2, 3], [3, 4], [4, 2]]) {
      using gate = weights(gk!), up = weights(uk!);
      for (const m of [1, 2, 3, 4]) {
        using x = input(m, gate.geometry.inFeatures, Dtype.bfloat16);
        using g = trellisReduce(x, gate.codes, gate.scales, gate.geometry, 13);
        using u = trellisReduce(x, up.codes, up.scales, up.geometry, 13);
        using expected = swiglu.apply([g, u])[0]!;
        using actual = fusedGateUpSwigluMixed(x, gate, up, 13, "split");
        same(actual, expected);
      }
    }
  } finally { swiglu.dispose(); }
}, 30_000);

test("baseline and vector expansion agree for supported output and scale dtypes", () => {
  for (const k of [2, 3, 4]) {
    using w = weights(k);
    for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
      using expected = expandTrellis(w.codes, w.scales, w.geometry, dtype, 0);
      for (const variant of [1, 2, 3, 6, 13]) {
        using actual = expandTrellis(w.codes, w.scales, w.geometry, dtype, variant);
        same(actual, expected);
      }
    }
  }
});
