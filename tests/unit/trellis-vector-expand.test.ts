import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { expandTrellis, trellisGeometry, setTrellisVariant } from "../../src/model/trellis-linear";
import { vectorTrellisExpandEligible } from "../../src/model/trellis-vector-expand";

test("vector expansion preserves every codebook state, circular windows and scale dtypes", () => {
  try {
    for (const bits of [2, 3, 4]) {
      const rows = 4096, cols = 512, wpb = 256 * bits / 32, words = wpb * 2;
      const host = new Int32Array(rows * words);
      let seed = 53;
      for (let i = 0; i < host.length; i++) host[i] = seed = Math.imul(seed, 1664525) + 1013904223;
      // Put every possible state at t=0, which wraps through the first word.
      // Other positions retain arbitrary packed data, including block edges.
      for (let r = 0; r < rows; r++) for (let block = 0; block < 2; block++) {
        const state = block === 0 ? r : (r * 29 + 17) & 4095;
        for (let j = 0; j < 12; j++) {
          const pos = (255 * bits + j) % (256 * bits), wi = r * words + block * wpb + (pos >>> 5);
          const mask = 1 << (pos & 31);
          host[wi] = (host[wi]! & ~mask) | (((state >>> j) & 1) ? mask : 0);
        }
      }
      const ints = MlxArray.fromInt32(host, [rows, words]);
      const codes = ints.astype(Dtype.uint32); ints.dispose();
      const g = trellisGeometry(codes, { bits, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis: 1 } });
      try {
        for (const dtype of [Dtype.float16, Dtype.bfloat16, Dtype.float32]) {
          const values = [0, 1, -1, 0.000031, 0.0131, 1.015625, 127, -511];
          const scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => values[i % values.length]!), [rows]);
          const scales = scale32.astype(dtype); scale32.dispose();
          setTrellisVariant(12); const expected = expandTrellis(codes, scales, g, Dtype.bfloat16);
          setTrellisVariant(13); const actual = expandTrellis(codes, scales, g, Dtype.bfloat16);
          try { expect(actual.rawBytes()).toEqual(expected.rawBytes()); }
          finally { actual.dispose(); expected.dispose(); scales.dispose(); }
        }
      } finally { codes.dispose(); }
    }
  } finally { setTrellisVariant(null); }
});

test("vector expansion handles strided packed inputs and retains unsupported dtype fallback", () => {
  try {
    const ints = MlxArray.fromInt32(Int32Array.from({ length: 48 * 7 }, (_, i) => Math.imul(i + 17, 1640531527)), [48, 7]);
    const storage = ints.astype(Dtype.uint32); ints.dispose();
    const codes = ops.transposeAxes(storage, [1, 0]);
    const scales = MlxArray.fromFloat32(Float32Array.from({ length: 7 }, (_, i) => (i + 1) / 9), [7]);
    const g = trellisGeometry(codes, { bits: 3, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis: 0 } });
    try {
      for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
        setTrellisVariant(12); const expected = expandTrellis(codes, scales, g, dtype);
        setTrellisVariant(13); const actual = expandTrellis(codes, scales, g, dtype);
        try { expect(actual.rawBytes()).toEqual(expected.rawBytes()); }
        finally { actual.dispose(); expected.dispose(); }
      }
    } finally { scales.dispose(); codes.dispose(); storage.dispose(); }
  } finally { setTrellisVariant(null); }
});

test("vector expansion dispatch enforces the measured dtype and packing contract", () => {
  const g = { k: 3, L: 12, T: 256, axis: 1 as const, rows: 17408, cols: 5120, inFeatures: 5120, outFeatures: 17408 };
  expect(vectorTrellisExpandEligible(g, Dtype.bfloat16)).toBe(true);
  for (const dtype of [Dtype.float16, Dtype.float32]) expect(vectorTrellisExpandEligible(g, dtype)).toBe(false);
  for (const changed of [{ k: 1 }, { k: 5 }, { T: 128 }, { L: 10 }, { rows: 0 }, { cols: 255 }])
    expect(vectorTrellisExpandEligible({ ...g, ...changed }, Dtype.bfloat16)).toBe(false);
});
