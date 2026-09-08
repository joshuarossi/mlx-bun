import { expect, spyOn, test } from "bun:test";
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { TrellisLinear, expandTrellis, setTrellisVariant, trellisGeometry } from "../../src/model/trellis-linear";
import { splitKTrellisPrefill } from "../../src/model/trellis-splitk-prefill";
import { interleaveTrellisCodes } from "../../src/quantize/trellis";

const spec = { bits: 3, groupSize: 256, mode: "trellis" as const,
  trellis: { L: 12, code: "1mad" as const, axis: 0 as const } };

function fixture(rows: number) {
  const host = Int32Array.from({ length: rows * 96 }, (_, i) => Math.imul(i + 71, 1640531527));
  const ints = MlxArray.fromInt32(host, [rows, 96]);
  const codes = ints.astype(Dtype.uint32); ints.dispose();
  const packed = interleaveTrellisCodes(codes);
  const scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 23 + 1) / 29), [rows]);
  const scales = scale32.astype(Dtype.float16); scale32.dispose();
  return { codes, packed, scales };
}

function equalBytes(a: MlxArray, b: MlxArray) {
  const ac = ops.contiguous(a), bc = ops.contiguous(b);
  try { expect(Buffer.from(ac.rawBytesView()).equals(Buffer.from(bc.rawBytesView()))).toBe(true); }
  finally { ac.dispose(); bc.dispose(); }
}

test("interleaved codes preserve every decoder variant and projection path", () => {
  const { codes, packed, scales } = fixture(128);
  const before = new TrellisLinear(codes, scales, spec, "kernel");
  const after = new TrellisLinear(packed, scales, spec, "kernel");
  try {
    expect(after.geometry).toEqual({ ...before.geometry, blockInterleave: 2 });
    for (let variant = 0; variant <= 13; variant++) {
      setTrellisVariant(variant);
      for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
        const a = expandTrellis(codes, scales, before.geometry, dtype);
        const b = expandTrellis(packed, scales, after.geometry, dtype);
        try { equalBytes(a, b); } finally { a.dispose(); b.dispose(); }
        for (const m of [1, 4, 8, 16]) {
          const key = ops.randomKey(BigInt(variant + m));
          const x = ops.randomNormal([1, m, 128], dtype, 0, 0.7, key); key.dispose();
          const a = before.forward(x), b = after.forward(x);
          try { expect(b.shape).toEqual([1, m, 1024]); equalBytes(a, b); }
          finally { x.dispose(); a.dispose(); b.dispose(); }
        }
      }
    }
    const a = before.expandWeight(), b = after.expandWeight();
    try { equalBytes(a, b); } finally { a.dispose(); b.dispose(); }
  } finally { setTrellisVariant(null); codes.dispose(); packed.dispose(); scales.dispose(); }
}, 30_000); // Includes first-use compilation of all fourteen variants.

test("interleaved expansion accepts strided codes and an incomplete row tile", () => {
  const { codes, packed, scales } = fixture(67);
  const t = ops.transposeAxes(packed, [1, 0, 2]), contiguous = ops.contiguous(t);
  const strided = ops.transposeAxes(contiguous, [1, 0, 2]); t.dispose(); contiguous.dispose();
  try {
    setTrellisVariant(13);
    const before = new TrellisLinear(codes, scales, spec, "kernel");
    const after = new TrellisLinear(strided, scales, spec, "kernel");
    for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
      const a = before.expandWeight(dtype), b = after.expandWeight(dtype);
      try { equalBytes(a, b); } finally { a.dispose(); b.dispose(); }
      const key = ops.randomKey(97n), x = ops.randomNormal([4, 67], dtype, 0, 0.7, key); key.dispose();
      const y = before.forward(x), z = after.forward(x);
      try { equalBytes(y, z); } finally { x.dispose(); y.dispose(); z.dispose(); }
    }
  } finally { setTrellisVariant(null); strided.dispose(); codes.dispose(); packed.dispose(); scales.dispose(); }
});

test("interleaved geometry rejects unsupported metadata and mismatched scales", () => {
  const { codes, packed, scales } = fixture(128);
  try {
    for (const changed of [{ bits: 2 }, { groupSize: 128 },
      { trellis: { ...spec.trellis, axis: 1 as const } }, { trellis: { ...spec.trellis, L: 10 } }])
      expect(() => trellisGeometry(packed, { ...spec, ...changed })).toThrow("unsupported interleaved");
    const flat = ops.reshape(packed, [packed.size]), malformed = ops.reshape(packed, [4, 128, 24]);
    const wrongScales = scales.slice([0], [64]);
    try {
      expect(() => interleaveTrellisCodes(packed)).toThrow("whole two-block groups");
      const inverse = ops.transposeAxes(packed, [1, 0, 2]), restored = ops.reshape(inverse, codes.shape);
      try { equalBytes(codes, restored); } finally { inverse.dispose(); restored.dispose(); }
      expect(() => trellisGeometry(flat, spec)).toThrow("expected a 2D");
      expect(() => trellisGeometry(malformed, spec)).toThrow("unsupported interleaved");
      expect(() => new TrellisLinear(packed, wrongScales, spec, "kernel")).toThrow("one scale per stored row");
    } finally { flat.dispose(); malformed.dispose(); wrongScales.dispose(); }
  } finally { codes.dispose(); packed.dispose(); scales.dispose(); }
});

test("interleaved split-K preserves partition tails and strided inputs", () => {
  const { codes, packed, scales } = fixture(2080);
  const before = trellisGeometry(codes, spec), after = trellisGeometry(packed, spec);
  try {
    setTrellisVariant(13);
    for (const m of [5, 8]) {
      const key = ops.randomKey(BigInt(m));
      const storage = ops.randomNormal([2080, m], Dtype.bfloat16, 0, 0.7, key); key.dispose();
      const x = ops.transposeAxes(storage, [1, 0]);
      const dense = expandTrellis(codes, scales, before, Dtype.bfloat16);
      const expected = ops.matmul(x, dense), actual = splitKTrellisPrefill(x, packed, scales, after);
      try { equalBytes(expected, actual); }
      finally { storage.dispose(); x.dispose(); dense.dispose(); expected.dispose(); actual.dispose(); }
    }
  } finally { setTrellisVariant(null); codes.dispose(); packed.dispose(); scales.dispose(); }
});


test("shared scatter codebook preserves outputs and leaves ineligible calls procedural", () => {
  const { codes, packed, scales } = fixture(67);
  const procedural = new TrellisLinear(packed, scales, spec, "kernel");
  const lookup = new TrellisLinear(packed, scales, spec, "kernel", true);
  const apply = spyOn(MetalKernel.prototype, "apply");
  try {
    for (const variant of [6, 10, 13]) {
      setTrellisVariant(variant);
      for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
        for (const m of [1, 2, 3, 4, 5, 8]) {
          const key = ops.randomKey(BigInt(variant * 100 + m));
          const x = ops.randomNormal([1, m, 67], dtype, 0, 0.7, key); key.dispose();
          const expected = procedural.forward(x);
          const start = apply.mock.calls.length;
          const actual = lookup.forward(x);
          try {
            equalBytes(expected, actual);
            const usesCodebook = apply.mock.calls.slice(start).some(([, options]) =>
              options.templateInts?.CODEBOOK === 1);
            expect(usesCodebook).toBe(variant === 13 && dtype === Dtype.bfloat16 && (m === 3 || m === 4));
          } finally { x.dispose(); expected.dispose(); actual.dispose(); }
        }
      }
    }
  } finally {
    apply.mockRestore(); setTrellisVariant(null);
    codes.dispose(); packed.dispose(); scales.dispose();
  }
});
