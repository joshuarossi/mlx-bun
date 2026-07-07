// TurboQuant KV-cache codec — pure mlx-op composition, ported op-for-op
// from the vendored vllm-metal reference
// (lab/repro/vllm-metal-turboquant/turboquant_reference.py). See
// docs/design/turboquant-kv.md for the algorithm writeup and
// goldens/turboquant.json (via tests/turboquant-ops.test.ts) for the
// bit-exactness oracle. Quantization groups run along the LAST axis
// (head_dim) only — never the token axis, per the standing invariant.
//
// Dtype routing: encodeKeys upcasts its input to fp32 before any
// min/max/scale/zero-point/round arithmetic (mirroring the value path,
// where the FWHT sign-multiply already forces an fp32 promotion — see
// fwht()). This matters because production callers (gemma4-base.ts
// TurboQuantKVCache) feed bf16 K tensors straight from the model, not the
// fp32 the vendored reference/goldens exercise; running the affine-quant
// arithmetic at bf16 precision measurably shifts rounding-boundary indices
// vs the fp32 reference. Only scale/zero are cast to fp16 at the end —
// this is deliberate and reproduces a real reference defect: a
// constant-valued block drives scale to exactly 0, and the resulting
// zero_point (finite in fp32, ~5e7) OVERFLOWS fp16 to +Infinity. We do not
// paper over this; the golden test asserts it.

import { Dtype, type MlxHandle } from "./ffi";
import { MlxArray, gpuStream } from "./array";
import * as ops from "./ops";
import {
  SIGN_VECTORS, LLOYD_MAX, TURBOQUANT_HEAD_DIMS, TURBOQUANT_VALUE_BITS,
  type TurboQuantHeadDim, type TurboQuantValueBits,
} from "./turboquant-tables";

type S = MlxHandle;

const BLOCK_SIZE = 32;
export { BLOCK_SIZE as TURBOQUANT_BLOCK_SIZE };

/** Port of packed_dim(): byte count for `dim` elements at `bits` width
 *  (bits===8 is one byte/element, unpacked). Throws on a non-byte-aligned
 *  product, matching the reference's own guard. */
export function packedDim(dim: number, bits: number): number {
  if ((dim * bits) % 8 !== 0) {
    throw new Error(`turboquant packedDim: dim=${dim} * bits=${bits} is not byte-aligned`);
  }
  return (dim * bits) / 8;
}

function isSupportedHeadDim(d: number): d is TurboQuantHeadDim {
  return (TURBOQUANT_HEAD_DIMS as readonly number[]).includes(d);
}

// --- sign vectors (host-side constants, generated from key(42)) ---------

const signArrayCache = new Map<TurboQuantHeadDim, MlxArray>();

/** [dim] float32 array of the ±1 sign table for this head_dim. Cached —
 *  it's a shared constant like the Lloyd-Max centroid tables, never
 *  per-token. */
function signArray(dim: TurboQuantHeadDim): MlxArray {
  let a = signArrayCache.get(dim);
  if (!a) {
    a = MlxArray.fromFloat32(new Float32Array(SIGN_VECTORS[dim]), [dim]);
    signArrayCache.set(dim, a);
  }
  return a;
}

// --- Lloyd-Max centroid/boundary constants -------------------------------

const centroidArrayCache = new Map<number, MlxArray>();
const boundaryArrayCache = new Map<number, MlxArray>();

function isSupportedValueBits(bits: number): bits is TurboQuantValueBits {
  return (TURBOQUANT_VALUE_BITS as readonly number[]).includes(bits);
}

function lloydMaxTableFor(bits: number) {
  if (!isSupportedValueBits(bits)) {
    throw new Error(`turboquant: no Lloyd-Max table for bits=${bits}`);
  }
  return LLOYD_MAX[bits];
}

function centroidsFor(bits: number): MlxArray {
  let a = centroidArrayCache.get(bits);
  if (!a) {
    const table = lloydMaxTableFor(bits);
    a = MlxArray.fromFloat32(new Float32Array(table.centroids), [table.centroids.length]);
    centroidArrayCache.set(bits, a);
  }
  return a;
}

function boundariesFor(bits: number): MlxArray {
  let a = boundaryArrayCache.get(bits);
  if (!a) {
    const table = lloydMaxTableFor(bits);
    a = MlxArray.fromFloat32(new Float32Array(table.boundaries), [table.boundaries.length]);
    boundaryArrayCache.set(bits, a);
  }
  return a;
}

// --- FWHT (fwht() in the reference: sign-multiply then/or Hadamard) -----

/** Rotation step used by both encode and decode. `encode=true`: x*signs
 *  then hadamard_transform (forward). `encode=false`: hadamard_transform
 *  then x*signs (inverse — Hadamard is self-inverse up to the 1/sqrt(d)
 *  normalization mlx's hadamard_transform already applies by default, so
 *  applying it twice with signs on the outside undoes the rotation
 *  exactly, matching the reference's `fwht(x, encode=False)`). */
export function fwht(x: MlxArray, encode: boolean, s: S = gpuStream): MlxArray {
  const dim = x.shape[x.shape.length - 1]!;
  if (!isSupportedHeadDim(dim)) {
    throw new Error(
      `turboquant fwht: head_dim ${dim} not in supported set ${TURBOQUANT_HEAD_DIMS.join(",")}`,
    );
  }
  const signs = signArray(dim);
  if (encode) {
    const signed = ops.mul(x, signs, s);
    const rotated = ops.hadamardTransform(signed, null, s);
    signed.dispose();
    return rotated;
  }
  const rotated = ops.hadamardTransform(x, null, s);
  const signed = ops.mul(rotated, signs, s);
  rotated.dispose();
  return signed;
}

// --- searchsorted: index = count(boundaries < x) -------------------------
// Reference: (x[..., None] > boundaries).sum(axis=-1) — broadcast compare
// then reduce over the boundary axis (the LAST axis after broadcasting,
// since boundaries is 1-D and lands in the new trailing dim).

function searchsorted(boundaries: MlxArray, x: MlxArray, s: S = gpuStream): MlxArray {
  const xExpanded = ops.expandDims(x, -1, s);
  const cmp = ops.greater(xExpanded, boundaries, s);
  xExpanded.dispose();
  const idx = ops.sumAxis(cmp, -1, false, s);
  cmp.dispose();
  return idx;
}

// --- key encode/decode: asymmetric per-32-group affine -------------------

export interface TurboQuantKeyEncoded {
  /** int8 (signed=true, 8 bits) or uint8 (unsigned) indices, one element
   *  per input element — NOT bit-packed here; call packBits separately
   *  (mirrors the reference's turbo_quant_encode_key / turbo_quant_encode
   *  split: quantize() returns unpacked indices, turbo_quant_encode packs
   *  sub-8-bit ones). */
  indices: MlxArray;
  /** fp16, shape [..., headDim/32] */
  scales: MlxArray;
  /** fp16, shape [..., headDim/32] */
  zeros: MlxArray;
}

/** Port of quantize() in the reference. `bits` in {2,4,5,8}; `signed` is
 *  only meaningful (and only ever true) for bits===8 (q8_0/int8) — every
 *  sub-8-bit key type in QUANT_PARAMS is unsigned. Groups run along the
 *  LAST axis (head_dim), BLOCK_SIZE=32 elements per group. */
export function encodeKeys(
  x: MlxArray, bits: number, signed: boolean, s: S = gpuStream,
): TurboQuantKeyEncoded {
  const shape = x.shape;
  const dim = shape[shape.length - 1]!;
  if (dim % BLOCK_SIZE !== 0) {
    throw new Error(`turboquant encodeKeys: head_dim ${dim} not divisible by ${BLOCK_SIZE}`);
  }
  // Upcast to fp32 for the affine-quant arithmetic below regardless of the
  // caller's dtype — production callers hand this bf16 K straight off the
  // model, and doing min/max/scale/zero-point/round at bf16 precision
  // measurably shifts which rounding boundary an element lands on (see the
  // dtype-routing note above). fp32 input is a no-op cast.
  const x32 = x.astype(Dtype.float32, s);
  const nGroups = dim / BLOCK_SIZE;
  const groupShape = [...shape.slice(0, -1), nGroups, BLOCK_SIZE];
  const xg = ops.reshape(x32, groupShape, s);
  x32.dispose();

  const xMin = ops.minAxis(xg, -1, true, s);
  const xMax = ops.maxAxis(xg, -1, true, s);

  const eps = ops.scalarLike(1e-8, xMax);

  let scale: MlxArray;
  let zeroPoint: MlxArray;
  let indices: MlxArray;
  const maxVal = signed ? (1 << (bits - 1)) - 1 : (1 << bits) - 1;

  if (signed) {
    // scale = (max-min) / (2*max_val)
    const range = ops.sub(xMax, xMin, s);
    const twoMaxVal = ops.scalarLike(2.0 * maxVal, range);
    scale = ops.div(range, twoMaxVal, s);
    range.dispose();
    twoMaxVal.dispose();

    const scaleEps = ops.add(scale, eps, s);
    const two = ops.scalarLike(2.0, scaleEps);
    const denom = ops.mul(two, scaleEps, s);
    two.dispose();
    scaleEps.dispose();

    const sumMinMax = ops.add(xMax, xMin, s);
    const zpRaw = ops.div(sumMinMax, denom, s);
    sumMinMax.dispose();
    zeroPoint = ops.round(zpRaw, s);
    zpRaw.dispose();

    const scaleEps2 = ops.add(scale, eps, s);
    const xOverScale = ops.div(xg, scaleEps2, s);
    scaleEps2.dispose();
    const shifted = ops.sub(xOverScale, zeroPoint, s);
    xOverScale.dispose();
    const rounded = ops.round(shifted, s);
    shifted.dispose();
    const loBound = ops.scalarLike(-maxVal, rounded);
    const hiBound = ops.scalarLike(maxVal, rounded);
    const clipped = ops.clip(rounded, loBound, hiBound, s);
    rounded.dispose();
    loBound.dispose();
    hiBound.dispose();
    denom.dispose();
    indices = ops.reshape(clipped, shape, s);
    clipped.dispose();
  } else {
    // scale = (max-min) / max_val
    const range = ops.sub(xMax, xMin, s);
    const maxValArr = ops.scalarLike(maxVal, range);
    scale = ops.div(range, maxValArr, s);
    range.dispose();
    maxValArr.dispose();

    const scaleEps = ops.add(scale, eps, s);
    const zpRaw = ops.div(xMin, scaleEps, s);
    scaleEps.dispose();
    zeroPoint = ops.round(zpRaw, s);
    zpRaw.dispose();

    const scaleEps2 = ops.add(scale, eps, s);
    const xOverScale = ops.div(xg, scaleEps2, s);
    scaleEps2.dispose();
    const shifted = ops.sub(xOverScale, zeroPoint, s);
    xOverScale.dispose();
    const rounded = ops.round(shifted, s);
    shifted.dispose();
    const loBound = ops.scalarLike(0, rounded);
    const hiBound = ops.scalarLike(maxVal, rounded);
    const clipped = ops.clip(rounded, loBound, hiBound, s);
    rounded.dispose();
    loBound.dispose();
    hiBound.dispose();
    indices = ops.reshape(clipped, shape, s);
    clipped.dispose();
  }

  eps.dispose();
  xMin.dispose();
  xMax.dispose();
  xg.dispose();

  const outDtype = signed ? Dtype.int8 : Dtype.uint8;
  const indicesTyped = indices.astype(outDtype, s);
  indices.dispose();

  const scaleSq = ops.reshape(scale, [...shape.slice(0, -1), nGroups], s);
  scale.dispose();
  const zeroSq = ops.reshape(zeroPoint, [...shape.slice(0, -1), nGroups], s);
  zeroPoint.dispose();
  const scaleF16 = scaleSq.astype(Dtype.float16, s);
  scaleSq.dispose();
  const zeroF16 = zeroSq.astype(Dtype.float16, s);
  zeroSq.dispose();

  return { indices: indicesTyped, scales: scaleF16, zeros: zeroF16 };
}

/** Port of dequantize(): x = (indices + zero_point) * scale, output cast
 *  to bf16 (the cache's working dtype). `indices` must be UNPACKED
 *  (one element per array element) and scales/zeros are [..., dim/32]. */
export function decodeKeys(
  indices: MlxArray, scales: MlxArray, zeros: MlxArray, s: S = gpuStream,
): MlxArray {
  const shape = indices.shape;
  const dim = shape[shape.length - 1]!;
  const nGroups = scales.shape[scales.shape.length - 1]!;
  const groupShape = [...shape.slice(0, -1), nGroups, dim / nGroups];

  const idxF32 = indices.astype(Dtype.float32, s);
  const idxG = ops.reshape(idxF32, groupShape, s);
  idxF32.dispose();

  const zerosExp = ops.expandDims(zeros, -1, s);
  const scalesExp = ops.expandDims(scales, -1, s);

  const sum = ops.add(idxG, zerosExp, s);
  idxG.dispose();
  zerosExp.dispose();
  const scaled = ops.mul(sum, scalesExp, s);
  sum.dispose();
  scalesExp.dispose();

  const out = ops.reshape(scaled, shape, s);
  scaled.dispose();
  const outBf16 = out.astype(Dtype.bfloat16, s);
  out.dispose();
  return outBf16;
}

// --- value encode/decode: FWHT + Lloyd-Max per-32-group RMS scale --------

export interface TurboQuantValueEncoded {
  /** uint8 indices in [0, 2^bits - 1], one per input element (unpacked). */
  indices: MlxArray;
  /** fp16, shape [..., headDim/32] */
  scales: MlxArray;
}

/** Port of turbo_quant_encode_value(): rotate (fwht) then Lloyd-Max
 *  quantize (lm_quant) per 32-group RMS scale. */
export function encodeValues(x: MlxArray, bits: number, s: S = gpuStream): TurboQuantValueEncoded {
  const rotated = fwht(x, true, s);
  const shape = rotated.shape;
  const dim = shape[shape.length - 1]!;
  if (dim % BLOCK_SIZE !== 0) {
    throw new Error(`turboquant encodeValues: head_dim ${dim} not divisible by ${BLOCK_SIZE}`);
  }
  const nGroups = dim / BLOCK_SIZE;
  const groupShape = [...shape.slice(0, -1), nGroups, BLOCK_SIZE];
  const xg = ops.reshape(rotated, groupShape, s);
  rotated.dispose();

  const sq = ops.square(xg, s);
  const meanSq = ops.meanAxis(sq, -1, true, s);
  sq.dispose();
  const scale = ops.sqrt(meanSq, s);
  meanSq.dispose();

  const eps = ops.scalarLike(1e-8, scale);
  const scaleEps = ops.add(scale, eps, s);
  eps.dispose();
  const xNorm = ops.div(xg, scaleEps, s);
  scaleEps.dispose();
  xg.dispose();

  const boundaries = boundariesFor(bits);
  const idxG = searchsorted(boundaries, xNorm, s);
  xNorm.dispose();

  const idxShaped = ops.reshape(idxG, shape, s);
  idxG.dispose();
  const idxU8 = idxShaped.astype(Dtype.uint8, s);
  idxShaped.dispose();

  const scaleSq = ops.reshape(scale, [...shape.slice(0, -1), nGroups], s);
  scale.dispose();
  const scaleF16 = scaleSq.astype(Dtype.float16, s);
  scaleSq.dispose();

  return { indices: idxU8, scales: scaleF16 };
}

/** Port of turbo_quant_decode_value(): centroid lookup + block rescale,
 *  then inverse FWHT. Output cast to bf16. */
/** Dequantize to the ROTATED (FWHT) domain in f32: centroids[idx] * scale,
 *  no inverse rotation. Shared tail of decodeValues / decodeValuesRotated. */
function dequantScaled(
  indices: MlxArray, scales: MlxArray, bits: number, s: S,
): MlxArray {
  const shape = indices.shape;
  const dim = shape[shape.length - 1]!;
  const nGroups = scales.shape[scales.shape.length - 1]!;
  const groupShape = [...shape.slice(0, -1), nGroups, dim / nGroups];

  const idxI32 = indices.astype(Dtype.int32, s);
  const idxG = ops.reshape(idxI32, groupShape, s);
  idxI32.dispose();

  const centroids = centroidsFor(bits);
  // mx.take_axis over the LAST axis: centroids[idx] element-wise lookup.
  const xNorm = ops.takeAxis(centroids, idxG, -1, s);
  idxG.dispose();

  const scalesExp = ops.expandDims(scales, -1, s);
  const scaled = ops.mul(xNorm, scalesExp, s);
  xNorm.dispose();
  scalesExp.dispose();

  const flat = ops.reshape(scaled, shape, s);
  scaled.dispose();
  return flat;
}

export function decodeValues(
  indices: MlxArray, scales: MlxArray, bits: number, s: S = gpuStream,
): MlxArray {
  const flat = dequantScaled(indices, scales, bits, s);
  const rotatedBack = fwht(flat, false, s);
  flat.dispose();

  const outBf16 = rotatedBack.astype(Dtype.bfloat16, s);
  rotatedBack.dispose();
  return outBf16;
}

/** Dequantized values still in the ROTATED domain (bf16) — the deferred-
 *  inverse-FWHT read path. Attention over V is linear in V, so
 *  InvFWHT(Σᵢ wᵢ·v̂ᵢ) = Σᵢ wᵢ·InvFWHT(v̂ᵢ): sdpa may run on these directly
 *  and the caller un-rotates the attention OUTPUT once per query row
 *  (unrotateValues) instead of un-rotating every cached token per step —
 *  vllm-metal's deferred-V trick, O(q·d log d) instead of O(T·d log d).
 *  Not bit-identical to the eager path (reduction order differs); both are
 *  valid decodes of the same cache bytes. */
export function decodeValuesRotated(
  indices: MlxArray, scales: MlxArray, bits: number, s: S = gpuStream,
): MlxArray {
  const flat = dequantScaled(indices, scales, bits, s);
  const outBf16 = flat.astype(Dtype.bfloat16, s);
  flat.dispose();
  return outBf16;
}

/** Undo the value rotation on an attention output computed against
 *  decodeValuesRotated values. f32 through the transform (matching the
 *  eager decode path's precision), returned in the input's dtype. */
export function unrotateValues(x: MlxArray, s: S = gpuStream): MlxArray {
  const dt = x.dtype;
  const f32 = x.astype(Dtype.float32, s);
  const rotatedBack = fwht(f32, false, s);
  f32.dispose();
  const out = rotatedBack.astype(dt, s);
  rotatedBack.dispose();
  return out;
}

// --- bit packing ----------------------------------------------------------
// Flat little-endian bitstream: element i occupies bits [i*b, i*b+b) —
// ports of _pack_2bit/_pack_3bit/_pack_4bit/_pack_5bit and their unpack
// twins. Values are always uint8 (or promoted to uint32 internally for
// widths needing >8-bit intermediate combination, matching the reference's
// own dtype choices exactly since bitwise ops on the wrong width silently
// truncate differently).

function u8(value: number, like: MlxArray): MlxArray {
  return ops.scalarLike(value, like);
}

function groupsOf(a: MlxArray, groupSize: number): { xg: MlxArray; shape: number[]; nGroups: number } {
  const shape = a.shape;
  const dim = shape[shape.length - 1]!;
  const nGroups = dim / groupSize;
  const xg = ops.reshape(a, [...shape.slice(0, -1), nGroups, groupSize]);
  return { xg, shape, nGroups };
}

/** vals: [..., dim] uint8, each using only 2 bits. Returns [..., dim/4] uint8. */
function pack2bit(vals: MlxArray): MlxArray {
  const { xg } = groupsOf(vals, 4);
  const lanes = ops.split(xg, [1, 2, 3], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg.dispose();
  const mask = u8(0x3, lanes[0]!);
  const v0 = ops.bitwiseAnd(lanes[0]!, mask);
  const v1raw = ops.bitwiseAnd(lanes[1]!, mask);
  const shift2 = u8(2, lanes[0]!);
  const v1 = ops.leftShift(v1raw, shift2);
  v1raw.dispose();
  const v2raw = ops.bitwiseAnd(lanes[2]!, mask);
  const shift4 = u8(4, lanes[0]!);
  const v2 = ops.leftShift(v2raw, shift4);
  v2raw.dispose();
  const v3raw = ops.bitwiseAnd(lanes[3]!, mask);
  const shift6 = u8(6, lanes[0]!);
  const v3 = ops.leftShift(v3raw, shift6);
  v3raw.dispose();
  mask.dispose(); shift2.dispose(); shift4.dispose(); shift6.dispose();
  lanes.forEach((l) => l.dispose());

  const o1 = ops.bitwiseOr(v0, v1); v0.dispose(); v1.dispose();
  const o2 = ops.bitwiseOr(o1, v2); o1.dispose(); v2.dispose();
  const packed = ops.bitwiseOr(o2, v3); o2.dispose(); v3.dispose();
  return packed;
}

function unpack2bit(packed: MlxArray, origDim: number): MlxArray {
  const shape = packed.shape;
  const g = ops.reshape(packed, [...shape.slice(0, -1), packed.shape[packed.shape.length - 1]!, 1]);
  const mask = u8(0x3, g);
  const v0 = ops.bitwiseAnd(g, mask);
  const s2 = u8(2, g);
  const g2 = ops.rightShift(g, s2); const v1 = ops.bitwiseAnd(g2, mask); g2.dispose();
  const s4 = u8(4, g);
  const g4 = ops.rightShift(g, s4); const v2 = ops.bitwiseAnd(g4, mask); g4.dispose();
  const s6 = u8(6, g);
  const g6 = ops.rightShift(g, s6); const v3 = ops.bitwiseAnd(g6, mask); g6.dispose();
  mask.dispose(); s2.dispose(); s4.dispose(); s6.dispose(); g.dispose();
  const cat = ops.concatAxis([v0, v1, v2, v3], -1);
  v0.dispose(); v1.dispose(); v2.dispose(); v3.dispose();
  const out = ops.reshape(cat, [...shape.slice(0, -1), origDim]);
  cat.dispose();
  return out;
}

/** vals: [..., dim] uint8 (each using 3 bits). Returns [..., dim*3/8] uint8.
 *  Matches _pack_3bit exactly: 8 values -> 3 bytes, via uint32 intermediates
 *  to avoid overflow while combining >8 bits per lane. */
function pack3bit(vals: MlxArray): MlxArray {
  const { xg } = groupsOf(vals, 8);
  const xg32 = xg.astype(Dtype.uint32);
  xg.dispose();
  const lanes = ops.split(xg32, [1, 2, 3, 4, 5, 6, 7], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg32.dispose();
  const v = lanes;
  const mask7 = u8(0x7, v[0]!);

  const m = (i: number) => ops.bitwiseAnd(v[i]!, mask7);
  const shl = (a: MlxArray, n: number) => {
    const sh = u8(n, a);
    const r = ops.leftShift(a, sh);
    sh.dispose();
    return r;
  };
  const shr = (a: MlxArray, n: number) => {
    const sh = u8(n, a);
    const r = ops.rightShift(a, sh);
    sh.dispose();
    return r;
  };

  // b0 = v0 | (v1<<3) | (v2<<6)
  const m0 = m(0);
  const m1 = m(1); const m1s = shl(m1, 3); m1.dispose();
  const m2 = m(2); const m2s = shl(m2, 6); m2.dispose();
  let b0 = ops.bitwiseOr(m0, m1s); m0.dispose(); m1s.dispose();
  b0 = ops.bitwiseOr(b0, m2s); m2s.dispose();

  // b1 = (v2>>2) | (v3<<1) | (v4<<4) | (v5<<7)
  const m2b = m(2); const m2bs = shr(m2b, 2); m2b.dispose();
  const m3 = m(3); const m3s = shl(m3, 1); m3.dispose();
  const m4 = m(4); const m4s = shl(m4, 4); m4.dispose();
  const m5 = m(5); const m5s = shl(m5, 7); m5.dispose();
  let b1 = ops.bitwiseOr(m2bs, m3s); m2bs.dispose(); m3s.dispose();
  b1 = ops.bitwiseOr(b1, m4s); m4s.dispose();
  b1 = ops.bitwiseOr(b1, m5s); m5s.dispose();

  // b2 = (v5>>1) | (v6<<2) | (v7<<5)
  const m5b = m(5); const m5bs = shr(m5b, 1); m5b.dispose();
  const m6 = m(6); const m6s = shl(m6, 2); m6.dispose();
  const m7 = m(7); const m7s = shl(m7, 5); m7.dispose();
  let b2 = ops.bitwiseOr(m5bs, m6s); m5bs.dispose(); m6s.dispose();
  b2 = ops.bitwiseOr(b2, m7s); m7s.dispose();

  mask7.dispose();
  v.forEach((l) => l.dispose());

  const mask255 = u8(0xff, b0);
  const b0m = ops.bitwiseAnd(b0, mask255); b0.dispose();
  const b1m = ops.bitwiseAnd(b1, mask255); b1.dispose();
  const b2m = ops.bitwiseAnd(b2, mask255); b2.dispose();
  mask255.dispose();

  const b0e = ops.expandDims(b0m, -1); b0m.dispose();
  const b1e = ops.expandDims(b1m, -1); b1m.dispose();
  const b2e = ops.expandDims(b2m, -1); b2m.dispose();
  const packed32 = ops.concatAxis([b0e, b1e, b2e], -1);
  b0e.dispose(); b1e.dispose(); b2e.dispose();
  const shape = vals.shape;
  const dim = shape[shape.length - 1]!;
  const packedFlat = ops.reshape(packed32, [...shape.slice(0, -1), (dim / 8) * 3]);
  packed32.dispose();
  const packed = packedFlat.astype(Dtype.uint8);
  packedFlat.dispose();
  return packed;
}

/** Inverse of pack3bit. packed: [..., dim*3/8] uint8 -> [..., dim] uint8. */
function unpack3bit(packed: MlxArray, origDim: number): MlxArray {
  const shape = packed.shape;
  const { xg } = groupsOf(packed, 3);
  const xg32 = xg.astype(Dtype.uint32);
  xg.dispose();
  const bytes = ops.split(xg32, [1, 2], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg32.dispose();
  const [b0, b1, b2] = bytes;

  const s8 = u8(8, b0!);
  const s16 = u8(16, b0!);
  const b1s = ops.leftShift(b1!, s8);
  const b2s = ops.leftShift(b2!, s16);
  s8.dispose(); s16.dispose();
  let combined = ops.bitwiseOr(b0!, b1s); b1s.dispose();
  combined = ops.bitwiseOr(combined, b2s); b2s.dispose();
  b0!.dispose(); b1!.dispose(); b2!.dispose();

  const mask7 = u8(0x7, combined);
  const vals: MlxArray[] = [];
  for (let i = 0; i < 8; i++) {
    const sh = u8(i * 3, combined);
    const shifted = ops.rightShift(combined, sh);
    sh.dispose();
    const v = ops.bitwiseAnd(shifted, mask7);
    shifted.dispose();
    vals.push(ops.expandDims(v, -1));
    v.dispose();
  }
  mask7.dispose();
  combined.dispose();
  const cat = ops.concatAxis(vals, -1);
  vals.forEach((v) => v.dispose());
  const outFlat = ops.reshape(cat, [...shape.slice(0, -1), origDim]);
  cat.dispose();
  const out = outFlat.astype(Dtype.uint8);
  outFlat.dispose();
  return out;
}

/** vals: [..., dim] uint8 (each using 4 bits). Returns [..., dim/2] uint8. */
function pack4bit(vals: MlxArray): MlxArray {
  const { xg } = groupsOf(vals, 2);
  const lanes = ops.split(xg, [1], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg.dispose();
  const [v0, v1] = lanes;
  const mask = u8(0xf, v0!);
  const m0 = ops.bitwiseAnd(v0!, mask);
  const m1raw = ops.bitwiseAnd(v1!, mask);
  const shift4 = u8(4, v0!);
  const m1 = ops.leftShift(m1raw, shift4);
  m1raw.dispose(); shift4.dispose(); mask.dispose();
  v0!.dispose(); v1!.dispose();
  const packed = ops.bitwiseOr(m0, m1);
  m0.dispose(); m1.dispose();
  return packed;
}

function unpack4bit(packed: MlxArray, origDim: number): MlxArray {
  const shape = packed.shape;
  const g = ops.reshape(packed, [...shape.slice(0, -1), packed.shape[packed.shape.length - 1]!, 1]);
  const mask = u8(0xf, g);
  const lo = ops.bitwiseAnd(g, mask);
  const s4 = u8(4, g);
  const g4 = ops.rightShift(g, s4);
  const hi = ops.bitwiseAnd(g4, mask);
  g4.dispose(); s4.dispose(); mask.dispose(); g.dispose();
  const cat = ops.concatAxis([lo, hi], -1);
  lo.dispose(); hi.dispose();
  const out = ops.reshape(cat, [...shape.slice(0, -1), origDim]);
  cat.dispose();
  return out;
}

// 5-bit pack/unpack: 8 lanes of 5 bits = 40 bits -> 5 bytes. mlx has no
// uint64 dtype exposed here (the reference combines via uint64), but since
// every output byte's contributing lane-bit-ranges independently fit
// within 8 bits once masked and shifted, the whole packing decomposes into
// a fixed table of (lane, lane_bit_lo, lane_bit_hi, out_bit_lo) triples per
// output byte — computed once below — with no wider-than-8-bit intermediate
// ever needed. This is bit-identical to the reference's 40-bit combine.
type FiveBitContrib = { lane: number; laneBitLo: number; width: number; outBitLo: number };
const FIVE_BIT_BYTE_TABLE: FiveBitContrib[][] = (() => {
  const table: FiveBitContrib[][] = [[], [], [], [], []];
  for (let byteIdx = 0; byteIdx < 5; byteIdx++) {
    const byteLo = byteIdx * 8;
    const byteHi = byteLo + 8;
    for (let lane = 0; lane < 8; lane++) {
      const laneLo = lane * 5;
      const laneHi = laneLo + 5;
      const ovLo = Math.max(laneLo, byteLo);
      const ovHi = Math.min(laneHi, byteHi);
      if (ovLo < ovHi) {
        table[byteIdx]!.push({
          lane, laneBitLo: ovLo - laneLo, width: ovHi - ovLo, outBitLo: ovLo - byteLo,
        });
      }
    }
  }
  return table;
})();

/** vals: [..., dim] uint8 (each using 5 bits). Returns [..., dim*5/8] uint8. */
function pack5bit(vals: MlxArray): MlxArray {
  const { xg } = groupsOf(vals, 8);
  const xg32 = xg.astype(Dtype.uint32);
  xg.dispose();
  const lanes = ops.split(xg32, [1, 2, 3, 4, 5, 6, 7], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg32.dispose();

  const bytes: MlxArray[] = [];
  for (const contribs of FIVE_BIT_BYTE_TABLE) {
    let byteVal: MlxArray | null = null;
    for (const c of contribs) {
      const widthMask = u8((1 << c.width) - 1, lanes[c.lane]!);
      const laneShift = u8(c.laneBitLo, lanes[c.lane]!);
      const shiftedDown = ops.rightShift(lanes[c.lane]!, laneShift);
      laneShift.dispose();
      const bits = ops.bitwiseAnd(shiftedDown, widthMask);
      shiftedDown.dispose();
      widthMask.dispose();
      const outShift = u8(c.outBitLo, bits);
      const placed = ops.leftShift(bits, outShift);
      outShift.dispose();
      bits.dispose();
      if (byteVal === null) {
        byteVal = placed;
      } else {
        const next = ops.bitwiseOr(byteVal, placed);
        byteVal.dispose();
        placed.dispose();
        byteVal = next;
      }
    }
    bytes.push(ops.expandDims(byteVal!, -1));
    byteVal!.dispose();
  }
  lanes.forEach((l) => l.dispose());

  const cat = ops.concatAxis(bytes, -1);
  bytes.forEach((b) => b.dispose());
  const shape = vals.shape;
  const dim = shape[shape.length - 1]!;
  const packedFlat = ops.reshape(cat, [...shape.slice(0, -1), (dim / 8) * 5]);
  cat.dispose();
  const packed = packedFlat.astype(Dtype.uint8);
  packedFlat.dispose();
  return packed;
}

/** Inverse of pack5bit. packed: [..., dim*5/8] uint8 -> [..., dim] uint8. */
function unpack5bit(packed: MlxArray, origDim: number): MlxArray {
  const shape = packed.shape;
  const { xg } = groupsOf(packed, 5);
  const xg32 = xg.astype(Dtype.uint32);
  xg.dispose();
  const bytes = ops.split(xg32, [1, 2, 3, 4], -1).map((l) => ops.reshape(l, l.shape.slice(0, -1)));
  xg32.dispose();

  const lanes: MlxArray[] = [];
  for (let lane = 0; lane < 8; lane++) {
    const laneLo = lane * 5;
    const laneHi = laneLo + 5;
    let laneVal: MlxArray | null = null;
    for (let byteIdx = 0; byteIdx < 5; byteIdx++) {
      const byteLo = byteIdx * 8;
      const byteHi = byteLo + 8;
      const ovLo = Math.max(laneLo, byteLo);
      const ovHi = Math.min(laneHi, byteHi);
      if (ovLo >= ovHi) continue;
      const width = ovHi - ovLo;
      const byteBitLo = ovLo - byteLo;
      const laneBitLo = ovLo - laneLo;
      const widthMask = u8((1 << width) - 1, bytes[byteIdx]!);
      const byteShift = u8(byteBitLo, bytes[byteIdx]!);
      const shiftedDown = ops.rightShift(bytes[byteIdx]!, byteShift);
      byteShift.dispose();
      const bits = ops.bitwiseAnd(shiftedDown, widthMask);
      shiftedDown.dispose();
      widthMask.dispose();
      const laneShift = u8(laneBitLo, bits);
      const placed = ops.leftShift(bits, laneShift);
      laneShift.dispose();
      bits.dispose();
      if (laneVal === null) {
        laneVal = placed;
      } else {
        const next = ops.bitwiseOr(laneVal, placed);
        laneVal.dispose();
        placed.dispose();
        laneVal = next;
      }
    }
    lanes.push(ops.expandDims(laneVal!, -1));
    laneVal!.dispose();
  }
  bytes.forEach((b) => b.dispose());

  const cat = ops.concatAxis(lanes, -1);
  lanes.forEach((l) => l.dispose());
  const outFlat = ops.reshape(cat, [...shape.slice(0, -1), origDim]);
  cat.dispose();
  const out = outFlat.astype(Dtype.uint8);
  outFlat.dispose();
  return out;
}

const _PACK_FNS: Record<number, (v: MlxArray) => MlxArray> = {
  2: pack2bit, 3: pack3bit, 4: pack4bit, 5: pack5bit,
};
const _UNPACK_FNS: Record<number, (v: MlxArray, origDim: number) => MlxArray> = {
  2: unpack2bit, 3: unpack3bit, 4: unpack4bit, 5: unpack5bit,
};

/** Bit-pack sub-8-bit unpacked values (uint8, one per element, using only
 *  the low `bits` bits) into a flat little-endian bitstream, `bits/8`
 *  bytes per `bits`-wide group of 8 elements (mirrors pack_bits). bits===8
 *  is a no-op (matches the reference). */
export function packBits(values: MlxArray, bits: number): MlxArray {
  if (bits === 8) return values;
  const fn = _PACK_FNS[bits];
  if (!fn) throw new Error(`turboquant packBits: unsupported bit width ${bits}`);
  return fn(values);
}

/** Inverse of packBits. bits===8 is a no-op. */
export function unpackBits(packed: MlxArray, bits: number, origDim: number): MlxArray {
  if (bits === 8) return packed;
  const fn = _UNPACK_FNS[bits];
  if (!fn) throw new Error(`turboquant unpackBits: unsupported bit width ${bits}`);
  return fn(packed, origDim);
}
