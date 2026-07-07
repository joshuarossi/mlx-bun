// TurboQuant codec parity (Phase 13). Two independent gates:
//  (a) golden bit-exactness vs the vendored vllm-metal Python reference
//      (goldens/turboquant.json — pure deterministic MLX math, no model
//      weights, machine-independent; self-skips if the golden is absent).
//  (b) model-free math properties that need no golden at all: FWHT
//      involution/orthogonality, 3-bit MSE band, pack/unpack roundtrip.

import { describe, expect, test } from "bun:test";
import { Dtype } from "../src/mlx/ffi";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import * as tq from "../src/mlx/turboquant-ops";

const goldenFile = Bun.file("goldens/turboquant.json");
const haveGoldens = await goldenFile.exists();

// JSON has no Infinity/NaN literal; gen_goldens.py encodes non-finite floats
// as the sentinel strings "Infinity"/"-Infinity"/"NaN" (see PROVENANCE.md /
// gen_goldens.py's _json_safe_float doc). Reverse that here.
function num(v: number | string): number {
  if (v === "Infinity") return Infinity;
  if (v === "-Infinity") return -Infinity;
  if (v === "NaN") return NaN;
  return v as number;
}

function flatten(v: unknown, out: number[] = []): number[] {
  if (Array.isArray(v)) {
    for (const x of v) flatten(x, out);
  } else {
    out.push(num(v as number | string));
  }
  return out;
}

// Bit-exact equality, EXCEPT +0/-0 (both compare equal to plain 0). The
// zero_point/index computations subtract two near-equal quantities right at
// a zero crossing (e.g. an outlier-row block whose true zero_point is
// mathematically 0): IEEE754 catastrophic-cancellation noise there is free
// to land on either signed zero depending on op-scheduling/reduction order,
// even re-running the SAME vendored reference twice (verified: regenerating
// gen_goldens.py reproduces -0.0 at a position the committed golden has as
// plain 0). Neither sign is "more correct" — collapse both to 0 before
// comparing so the assertion tracks real numeric parity, not zero-sign noise.
function collapseSignedZero(arr: number[]): number[] {
  return arr.map((x) => (x === 0 ? 0 : x));
}

function expectArrayCloseModuloSignedZero(actual: number[], expected: number[]): void {
  expect(collapseSignedZero(actual)).toEqual(collapseSignedZero(expected));
}

function shapeOf(v: unknown): number[] {
  const shape: number[] = [];
  let cur = v;
  while (Array.isArray(cur)) {
    shape.push(cur.length);
    cur = cur[0];
  }
  return shape;
}

function arrayFromNested(v: unknown, dtype: Dtype): MlxArray {
  const shape = shapeOf(v);
  const flat = flatten(v);
  const f32 = MlxArray.fromFloat32(new Float32Array(flat), shape);
  if (dtype === Dtype.float32) return f32;
  const cast = f32.astype(dtype);
  f32.dispose();
  return cast;
}

interface GoldenVector {
  head_dim: number;
  config: string;
  k_quant_type: string;
  k_bits: number;
  v_bits: number;
  input_k: unknown;
  input_v: unknown;
  k_indices: unknown;
  k_scale: unknown;
  k_zero: unknown;
  k_packed: unknown;
  v_indices: unknown;
  v_packed: unknown;
  v_scale: unknown;
  k_dequant: unknown;
  v_dequant: unknown;
}

interface GoldenFile {
  signs: Record<string, number[]>;
  lloyd_max: Record<string, { centroids: number[]; boundaries: number[] }>;
  vectors: GoldenVector[];
}

describe.skipIf(!haveGoldens)("turboquant codec — golden bit-exactness", async () => {
  if (!haveGoldens) return;
  const golden = (await goldenFile.json()) as GoldenFile;

  for (const vec of golden.vectors) {
    test(`${vec.config} head_dim=${vec.head_dim}`, () => {
      const signed = vec.k_quant_type === "q8_0" || vec.k_quant_type === "int8";
      const inputK = arrayFromNested(vec.input_k, Dtype.float32);
      const inputV = arrayFromNested(vec.input_v, Dtype.float32);

      // --- keys ---
      const kEnc = tq.encodeKeys(inputK, vec.k_bits, signed);
      const kIndicesExpected = flatten(vec.k_indices);
      const kIndicesActual = [...kEnc.indices.toFloat32()];
      expectArrayCloseModuloSignedZero(kIndicesActual, kIndicesExpected);

      // scale/zero round-trip through fp16 exactly as the reference does —
      // compare via the fp16 bit pattern (toFloat32 of an fp16 array is the
      // exact upcast, so equality here is bit-exact fp16 equality,
      // including the intentional +Infinity zero_point overflow case), up
      // to the +0/-0 collapse documented above.
      const kScaleExpected = flatten(vec.k_scale);
      const kScaleActual = [...kEnc.scales.toFloat32()];
      expectArrayCloseModuloSignedZero(kScaleActual, kScaleExpected);

      const kZeroExpected = flatten(vec.k_zero);
      const kZeroActual = [...kEnc.zeros.toFloat32()];
      expectArrayCloseModuloSignedZero(kZeroActual, kZeroExpected);

      const kPacked = vec.k_bits < 8
        ? tq.packBits(kEnc.indices.astype(Dtype.uint8), vec.k_bits)
        : kEnc.indices;
      const kPackedExpected = flatten(vec.k_packed);
      const kPackedActual = [...kPacked.toFloat32()];
      expectArrayCloseModuloSignedZero(kPackedActual, kPackedExpected);

      const kDequant = tq.decodeKeys(kEnc.indices, kEnc.scales, kEnc.zeros);
      const kDequantExpected = flatten(vec.k_dequant);
      const kDequantActual = [...kDequant.astype(Dtype.float32).toFloat32()];
      // bf16 output: ~3 decimal digits of precision. The +Infinity/NaN
      // adversarial case must match exactly (non-finite, not "close").
      for (let i = 0; i < kDequantExpected.length; i++) {
        const exp = kDequantExpected[i]!;
        const act = kDequantActual[i]!;
        if (!Number.isFinite(exp)) {
          if (Number.isNaN(exp)) expect(Number.isNaN(act)).toBe(true);
          else expect(act).toBe(exp);
        } else {
          const scaleMag = Math.max(Math.abs(exp), 1);
          expect(Math.abs(act - exp)).toBeLessThanOrEqual(0.05 * scaleMag);
        }
      }

      // Independent check on decodeKeys' FORMULA itself: feed the golden's
      // OWN indices/scale/zero (not kEnc's, already bit-exact-asserted
      // above) through decodeKeys and require tight agreement with the
      // golden's dequant. This catches a wrong operand order/exponent in
      // the arithmetic even if indices/scale/zero all happen to be right —
      // the 5%-tolerance check above alone cannot, since it composes with
      // TS's own (already-verified) indices rather than the golden's.
      const kIdxFromGolden = arrayFromNested(vec.k_indices, signed ? Dtype.int8 : Dtype.uint8);
      const kScaleFromGolden = arrayFromNested(vec.k_scale, Dtype.float16);
      const kZeroFromGolden = arrayFromNested(vec.k_zero, Dtype.float16);
      const kDequantFromGolden = tq.decodeKeys(kIdxFromGolden, kScaleFromGolden, kZeroFromGolden);
      const kDequantFromGoldenActual = [...kDequantFromGolden.astype(Dtype.float32).toFloat32()];
      for (let i = 0; i < kDequantExpected.length; i++) {
        const exp = kDequantExpected[i]!;
        const act = kDequantFromGoldenActual[i]!;
        if (!Number.isFinite(exp)) {
          if (Number.isNaN(exp)) expect(Number.isNaN(act)).toBe(true);
          else expect(act).toBe(exp);
        } else {
          // tight: bf16 ulp only, no slack for a formula error to hide in.
          const scaleMag = Math.max(Math.abs(exp), 1);
          expect(Math.abs(act - exp)).toBeLessThanOrEqual(0.01 * scaleMag);
        }
      }
      kIdxFromGolden.dispose();
      kScaleFromGolden.dispose();
      kZeroFromGolden.dispose();
      kDequantFromGolden.dispose();

      // --- values ---
      const vEnc = tq.encodeValues(inputV, vec.v_bits);
      const vIndicesExpected = flatten(vec.v_indices);
      const vIndicesActual = [...vEnc.indices.toFloat32()];
      expectArrayCloseModuloSignedZero(vIndicesActual, vIndicesExpected);

      const vScaleExpected = flatten(vec.v_scale);
      const vScaleActual = [...vEnc.scales.toFloat32()];
      expectArrayCloseModuloSignedZero(vScaleActual, vScaleExpected);

      const vPacked = vec.v_bits < 8
        ? tq.packBits(vEnc.indices, vec.v_bits)
        : vEnc.indices;
      const vPackedExpected = flatten(vec.v_packed);
      const vPackedActual = [...vPacked.toFloat32()];
      expectArrayCloseModuloSignedZero(vPackedActual, vPackedExpected);

      const vDequant = tq.decodeValues(vEnc.indices, vEnc.scales, vec.v_bits);
      const vDequantExpected = flatten(vec.v_dequant);
      const vDequantActual = [...vDequant.astype(Dtype.float32).toFloat32()];
      for (let i = 0; i < vDequantExpected.length; i++) {
        const exp = vDequantExpected[i]!;
        const act = vDequantActual[i]!;
        const scaleMag = Math.max(Math.abs(exp), 1);
        expect(Math.abs(act - exp)).toBeLessThanOrEqual(0.05 * scaleMag);
      }

      // --- unpack roundtrip against the golden's own packed bytes ---
      if (vec.k_bits < 8) {
        const kUnpacked = tq.unpackBits(kPacked, vec.k_bits, vec.head_dim);
        expectArrayCloseModuloSignedZero([...kUnpacked.toFloat32()], kIndicesExpected);
        kUnpacked.dispose();
      }
      const vUnpacked = vec.v_bits < 8
        ? tq.unpackBits(vPacked, vec.v_bits, vec.head_dim)
        : vPacked;
      expectArrayCloseModuloSignedZero([...vUnpacked.toFloat32()], vIndicesExpected);
      if (vUnpacked !== vPacked) vUnpacked.dispose();

      inputK.dispose();
      inputV.dispose();
      kEnc.indices.dispose();
      kEnc.scales.dispose();
      kEnc.zeros.dispose();
      if (kPacked !== kEnc.indices) kPacked.dispose();
      kDequant.dispose();
      vEnc.indices.dispose();
      vEnc.scales.dispose();
      if (vPacked !== vEnc.indices) vPacked.dispose();
      vDequant.dispose();
    });
  }

  test("sign vectors match generated tables", async () => {
    const { SIGN_VECTORS } = await import("../src/mlx/turboquant-tables");
    for (const dim of [64, 128, 256, 512] as const) {
      expect(SIGN_VECTORS[dim]).toEqual(golden.signs[String(dim)]!);
    }
  });

  test("Lloyd-Max tables match generated tables", async () => {
    const { LLOYD_MAX } = await import("../src/mlx/turboquant-tables");
    for (const bits of [2, 3, 4, 5, 8] as const) {
      expect(LLOYD_MAX[bits].centroids).toEqual(golden.lloyd_max[String(bits)]!.centroids);
      expect(LLOYD_MAX[bits].boundaries).toEqual(golden.lloyd_max[String(bits)]!.boundaries);
    }
  });
});

describe("turboquant codec — dtype routing", () => {
  test("encodeKeys on bf16 input matches encodeKeys on the bf16-rounded values re-upcast to fp32 (production callers feed bf16 K straight off the model — see gemma4-base.ts TurboQuantKVCache#encode)", () => {
    // Small-magnitude values (post-RMSNorm-scale keys are typically ~0.02
    // in magnitude) are exactly the regime where bf16's ~7-8 bit mantissa
    // vs fp32's 23 shifts rounding-boundary decisions in the affine-quant
    // arithmetic (min/max/scale/zero-point/round) if that arithmetic runs
    // at the input's native precision instead of upcasting first. The
    // oracle here is fp32 arithmetic on the SAME (bf16-rounded) logical
    // values as encodeKeys(xbf, ...) sees — not the original unrounded
    // fp32 array, which legitimately differs (bf16 already lost mantissa
    // bits before encodeKeys ever runs).
    const x32 = ops.randomNormal([2, 3, 64], Dtype.float32, 0, 0.02, null);
    const xbf = x32.astype(Dtype.bfloat16);
    const xRoundTripped = xbf.astype(Dtype.float32); // exact bf16-rounded values, in fp32

    const encFromF32 = tq.encodeKeys(xRoundTripped, 8, true);
    const encFromBf16 = tq.encodeKeys(xbf, 8, true);

    const idxF32 = [...encFromF32.indices.toFloat32()];
    const idxBf16 = [...encFromBf16.indices.toFloat32()];
    expect(idxBf16).toEqual(idxF32);

    x32.dispose(); xbf.dispose(); xRoundTripped.dispose();
    encFromF32.indices.dispose(); encFromF32.scales.dispose(); encFromF32.zeros.dispose();
    encFromBf16.indices.dispose(); encFromBf16.scales.dispose(); encFromBf16.zeros.dispose();
  });

  test("encodeKeys on bf16 input diverges from a bf16-precision (no-upcast) reference, proving the fp32 upcast is doing real work", () => {
    // Direct counterfactual (prove-by-removal): compute the SAME affine-quant
    // formula as encodeKeys, but entirely at bf16 precision (mirroring what
    // encodeKeys did before the fp32 upcast fix), and confirm it disagrees
    // with the fixed encodeKeys on a realistic small-magnitude block. If
    // this ever starts passing (arrays equal), the fp32 upcast has silently
    // regressed to a no-op.
    const raw = new Float32Array(64);
    for (let i = 0; i < 64; i++) raw[i] = 0.02 * Math.sin(i * 1.7 + 0.3) + 0.001 * i;
    const x32 = MlxArray.fromFloat32(raw, [1, 1, 2, 32]);
    const xbf = x32.astype(Dtype.bfloat16);

    const enc = tq.encodeKeys(xbf, 8, true);
    const idxFromCodec = [...enc.indices.toFloat32()];

    // Bf16-precision reference: every op below stays in bf16 (no astype to
    // fp32 anywhere), same op sequence as encodeKeys' signed branch.
    const xg = ops.reshape(xbf, [1, 1, 2, 1, 32]);
    const xMin = ops.minAxis(xg, -1, true);
    const xMax = ops.maxAxis(xg, -1, true);
    const eps = ops.scalarLike(1e-8, xMax);
    const range = ops.sub(xMax, xMin);
    const twoMaxVal = ops.scalarLike(254.0, range);
    const scale = ops.div(range, twoMaxVal);
    const scaleEps = ops.add(scale, eps);
    const two = ops.scalarLike(2.0, scaleEps);
    const denom = ops.mul(two, scaleEps);
    const sumMinMax = ops.add(xMax, xMin);
    const zpRaw = ops.div(sumMinMax, denom);
    const zeroPoint = ops.round(zpRaw);
    const scaleEps2 = ops.add(scale, eps);
    const xOverScale = ops.div(xg, scaleEps2);
    const shifted = ops.sub(xOverScale, zeroPoint);
    const rounded = ops.round(shifted);
    const loBound = ops.scalarLike(-127, rounded);
    const hiBound = ops.scalarLike(127, rounded);
    const clipped = ops.clip(rounded, loBound, hiBound);
    const idxBf16Ref = [...clipped.astype(Dtype.float32).toFloat32()];

    expect(idxFromCodec).not.toEqual(idxBf16Ref);

    for (const a of [xg, xMin, xMax, eps, range, twoMaxVal, scale, scaleEps, two, denom,
      sumMinMax, zpRaw, zeroPoint, scaleEps2, xOverScale, shifted, rounded, loBound, hiBound, clipped]) {
      a.dispose();
    }
    x32.dispose(); xbf.dispose();
    enc.indices.dispose(); enc.scales.dispose(); enc.zeros.dispose();
  });
});

describe("turboquant codec — deferred inverse FWHT", () => {
  test("decodeValuesRotated + unrotateValues matches eager decodeValues", () => {
    const key = ops.randomKey(31n);
    const v = ops.randomNormal([1, 2, 6, 128], Dtype.float32, 0, 1, key);
    key.dispose();
    const enc = tq.encodeValues(v, 3);

    const eager = tq.decodeValues(enc.indices, enc.scales, 3);
    const rotated = tq.decodeValuesRotated(enc.indices, enc.scales, 3);
    const deferred = tq.unrotateValues(rotated);

    const e = [...eager.astype(Dtype.float32).toFloat32()];
    const d = [...deferred.astype(Dtype.float32).toFloat32()];
    // Not bit-equal by design: the deferred path rounds to bf16 in the
    // rotated domain before the inverse transform. Bound the drift by one
    // bf16 ulp of the transform magnitude.
    for (let i = 0; i < e.length; i++) {
      expect(Math.abs(d[i]! - e[i]!)).toBeLessThan(0.05);
    }
    for (const a of [v, enc.indices, enc.scales, eager, rotated, deferred]) a.dispose();
  });

  test("linearity: unrotate(Σ w·v_rot) equals Σ w·unrotate(v_rot)", () => {
    // The property the deferred attention path rests on: InvFWHT commutes
    // with the softmax-weighted sum over tokens.
    const key = ops.randomKey(32n);
    const vRot = ops.randomNormal([1, 1, 4, 64], Dtype.float32, 0, 1, key);
    key.dispose();
    const w = [0.4, 0.3, 0.2, 0.1];
    const wArr = MlxArray.fromFloat32(new Float32Array(w), [1, 1, 4, 1]);

    const weighted = ops.mul(vRot, wArr);
    const summed = ops.sumAxis(weighted, 2, true); // Σ w·v_rot  [1,1,1,64]
    const lhs = tq.unrotateValues(summed);

    const unrot = tq.unrotateValues(vRot);
    const weighted2 = ops.mul(unrot, wArr);
    const rhs = ops.sumAxis(weighted2, 2, true);

    const l = [...lhs.astype(Dtype.float32).toFloat32()];
    const r = [...rhs.astype(Dtype.float32).toFloat32()];
    for (let i = 0; i < l.length; i++) {
      expect(Math.abs(l[i]! - r[i]!)).toBeLessThan(1e-4);
    }
    for (const a of [vRot, wArr, weighted, summed, lhs, unrot, weighted2, rhs]) a.dispose();
  });
});

describe("turboquant codec — model-free math properties", () => {
  test("FWHT involution: encode then decode recovers the input", () => {
    const x = ops.randomNormal([2, 3, 128], Dtype.float32, 0, 1, null);
    const encoded = tq.fwht(x, true);
    const decoded = tq.fwht(encoded, false);
    const xArr = [...x.toFloat32()];
    const dArr = [...decoded.toFloat32()];
    for (let i = 0; i < xArr.length; i++) {
      expect(Math.abs(dArr[i]! - xArr[i]!)).toBeLessThan(1e-4);
    }
    x.dispose();
    encoded.dispose();
    decoded.dispose();
  });

  test("FWHT rotation preserves L2 norm (orthogonal transform)", () => {
    const x = ops.randomNormal([4, 64], Dtype.float32, 0, 1, null);
    const rotated = tq.fwht(x, true);
    const sq = ops.square(x);
    const normX = Math.sqrt(ops.sumAxis(sq, -1, false).toFloat32().reduce((a, b) => a + b, 0));
    const sqR = ops.square(rotated);
    const normR = Math.sqrt(ops.sumAxis(sqR, -1, false).toFloat32().reduce((a, b) => a + b, 0));
    // both norms summed over the WHOLE (flattened) tensor via the loop above
    // double-sums per-row norms — compare relative to sqrt for magnitude
    // sanity: an orthogonal transform preserves norm ROW-WISE.
    const xRows = ops.sumAxis(sq, -1, false);
    const rRows = ops.sumAxis(sqR, -1, false);
    const xRowVals = [...xRows.toFloat32()];
    const rRowVals = [...rRows.toFloat32()];
    for (let i = 0; i < xRowVals.length; i++) {
      expect(Math.sqrt(rRowVals[i]!)).toBeCloseTo(Math.sqrt(xRowVals[i]!), 3);
    }
    expect(normX).toBeGreaterThan(0);
    expect(normR).toBeGreaterThan(0);
    x.dispose(); rotated.dispose(); sq.dispose(); sqR.dispose(); xRows.dispose(); rRows.dispose();
  });

  test("3-bit value roundtrip MSE on unit-normal data lands in the paper band (~0.03, ±50%)", () => {
    const x = ops.randomNormal([64, 128], Dtype.float32, 0, 1, null);
    const enc = tq.encodeValues(x, 3);
    const dec = tq.decodeValues(enc.indices, enc.scales, 3);
    const xArr = [...x.toFloat32()];
    const dArr = [...dec.astype(Dtype.float32).toFloat32()];
    let sumSq = 0;
    let sumOrigSq = 0;
    for (let i = 0; i < xArr.length; i++) {
      const diff = dArr[i]! - xArr[i]!;
      sumSq += diff * diff;
      sumOrigSq += xArr[i]! * xArr[i]!;
    }
    const mse = sumSq / xArr.length;
    // MSE is measured relative to unit-normal data (E[x^2] ≈ 1), so the raw
    // MSE is directly comparable to the paper's ~0.03 band at 3 bits.
    expect(sumOrigSq / xArr.length).toBeGreaterThan(0.5); // sanity: really unit-normal-ish
    expect(mse).toBeGreaterThan(0.03 * 0.5);
    expect(mse).toBeLessThan(0.03 * 1.5);
    x.dispose(); enc.indices.dispose(); enc.scales.dispose(); dec.dispose();
  });

  test.each([2, 3, 4, 5] as const)("pack/unpack roundtrip identity at %d bits (byte-straddling patterns)", (bits) => {
    const dim = 32; // one BLOCK_SIZE group; also exercises the general reshape math
    const maxVal = (1 << bits) - 1;
    // deterministic byte-straddling pattern: every representable value, cycling.
    const data = new Float32Array(dim);
    for (let i = 0; i < dim; i++) data[i] = i % (maxVal + 1);
    const vals = MlxArray.fromFloat32(data, [1, dim]).astype(Dtype.uint8);
    const packed = tq.packBits(vals, bits);
    const expectedPackedLen = (dim * bits) / 8;
    expect(packed.shape[packed.shape.length - 1]).toBe(expectedPackedLen);
    const unpacked = tq.unpackBits(packed, bits, dim);
    expect([...unpacked.toFloat32()]).toEqual([...vals.toFloat32()]);
    vals.dispose(); packed.dispose(); unpacked.dispose();
  });

  test("pack/unpack roundtrip on random data at every supported bit width", () => {
    for (const bits of [2, 3, 4, 5] as const) {
      const maxVal = (1 << bits) - 1;
      const dim = 64;
      const rows = 3;
      const data = new Float32Array(dim * rows);
      for (let i = 0; i < data.length; i++) data[i] = Math.floor(Math.random() * (maxVal + 1));
      const vals = MlxArray.fromFloat32(data, [rows, dim]).astype(Dtype.uint8);
      const packed = tq.packBits(vals, bits);
      const unpacked = tq.unpackBits(packed, bits, dim);
      expect([...unpacked.toFloat32()]).toEqual([...vals.toFloat32()]);
      vals.dispose(); packed.dispose(); unpacked.dispose();
    }
  });
});
