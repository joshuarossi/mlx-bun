import { afterAll, describe, expect, setDefaultTimeout, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { TRELLIS_L, TRELLIS_T, Trellis, lut1mad, unpackDecodeHost } from "../src/trellis";
import { TrellisEncoder } from "../src/trellis-encoder";

// Viterbi encoder, tail-biting and BlockLDLQ on synthetic Gaussian weights.
// The codes are checked against properties the trellis defines (successor
// relation, cyclic window, distortion) and the LDLQ arm against the unweighted
// arm it must reduce to when there is no feedback.

function gaussian(count: number, seed: number): Float32Array {
  const out = new Float32Array(count);
  let s = seed >>> 0;
  const u = () => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return (s + 1) / 4294967297; };
  for (let i = 0; i < count; i += 2) {
    const r = Math.sqrt(-2 * Math.log(u())), t = 2 * Math.PI * u();
    out[i] = r * Math.cos(t);
    if (i + 1 < count) out[i + 1] = r * Math.sin(t);
  }
  return out;
}
const matrix = (rows: number, cols: number, seed: number, std = 0.05) =>
  MlxArray.fromFloat32(gaussian(rows * cols, seed).map(v => v * std), [rows, cols]);
// Native Viterbi encodes; several seconds each locally and slower on CI runners than the 5 s default.
setDefaultTimeout(60_000);
const encoder = new TrellisEncoder();
afterAll(() => encoder.dispose());

function hostCodes(codes: MlxArray): Uint32Array {
  const raw = codes.rawBytes();
  return new Uint32Array(raw.buffer, raw.byteOffset, raw.byteLength / 4).slice();
}
function hostScales(scales: MlxArray): Float32Array {
  using f32 = scales.astype(Dtype.float32);
  return f32.toFloat32();
}
const decode = (codes: MlxArray, scales: MlxArray, rows: number, cols: number, k: number) =>
  unpackDecodeHost(hostCodes(codes), hostScales(scales), rows, cols, k, TRELLIS_T, lut1mad(TRELLIS_L));

describe("Viterbi encode", () => {
  for (const k of [2, 3, 4]) {
    test(`k=${k}: states follow the bitshift successor relation, cyclically (tail-biting)`, () => {
      const codec = new Trellis({ L: TRELLIS_L, K: k, T: TRELLIS_T, code: "1mad", tailBiting: true });
      try {
        using x = MlxArray.fromFloat32(gaussian(8 * TRELLIS_T, 5), [8, TRELLIS_T]);
        using idx = codec.encodeStates(x);
        using i32 = idx.astype(Dtype.uint32);
        const raw = i32.rawBytes();
        const states = new Int32Array(raw.buffer, raw.byteOffset, raw.byteLength / 4);
        const low = (1 << (TRELLIS_L - k)) - 1;
        for (let b = 0; b < 8; b++) for (let t = 0; t < TRELLIS_T; t++) {
          const p = states[b * TRELLIS_T + t]!, n = states[b * TRELLIS_T + (t + 1) % TRELLIS_T]!;
          // n = ((p << k) | branch) mod 2^L  <=>  n >> k == p & (2^(L-k) - 1); t = T-1 wraps to the block's first state.
          if ((n >> k) !== (p & low)) throw new Error(`block ${b}: state ${t} -> ${(t + 1) % TRELLIS_T} breaks the trellis (${p} -> ${n})`);
        }
      } finally { codec.dispose(); }
    });
  }

  test("packed codes and scales decode to the codec's own reconstruction, and distortion falls as k grows", () => {
    const rows = 32, cols = 512;
    let previous = Infinity;
    for (const k of [2, 3, 4]) {
      using w = matrix(rows, cols, 11 + k);
      const packed = encoder.encode(w, 1, k);
      const { rec, codes: refCodes, scales: refScales } = encoder.codec(k).fakeQuantRowsPacked(w, 16384);
      try {
        expect(packed.codes.shape).toEqual([rows, (cols * k) / 32]);
        expect(packed.codes.dtype).toBe(Dtype.uint32);
        expect(packed.scales.shape).toEqual([rows]);
        expect(packed.scales.dtype).toBe(Dtype.float16);
        const decoded = decode(packed.codes, packed.scales, rows, cols, k);
        expect(decoded).toEqual(rec.toFloat32());
        expect(hostCodes(packed.codes)).toEqual(hostCodes(refCodes));
        const source = w.toFloat32();
        let err = 0, power = 0;
        for (let i = 0; i < source.length; i++) { err += (source[i]! - decoded[i]!) ** 2; power += source[i]! ** 2; }
        const mse = err / power; // relative to signal power: the (12,k,1) tail-biting codes sit near 2^-2k
        expect(mse).toBeLessThan(k === 2 ? 0.13 : k === 3 ? 0.04 : 0.012);
        expect(mse).toBeLessThan(previous);
        previous = mse;
      } finally { packed.codes.dispose(); packed.scales.dispose(); rec.dispose(); refCodes.dispose(); refScales.dispose(); }
    }
  });

  test("axis 0 codes the transposed tensor: rows are the input columns", () => {
    const shape: [number, number] = [256, 512], k = 3;
    using w = matrix(shape[0], shape[1], 21);
    using wt = ops.contiguous(ops.transposeAxes(w, [1, 0]));
    const coded = encoder.encode(w, 0, k), direct = encoder.encode(wt, 1, k);
    try {
      expect(coded.codes.shape).toEqual([512, (256 * k) / 32]);
      expect(hostCodes(coded.codes)).toEqual(hostCodes(direct.codes));
      expect(hostScales(coded.scales)).toEqual(hostScales(direct.scales));
    } finally { for (const a of [coded.codes, coded.scales, direct.codes, direct.scales]) a.dispose(); }
  });
});

describe("BlockLDLQ", () => {
  // folded [m, n]: axis 1 codes along n (rows = m), axis 0 along m (rows = n); L is [n, n].
  const cases: { axis: 0 | 1; shape: [number, number] }[] = [{ axis: 1, shape: [64, 512] }, { axis: 0, shape: [256, 512] }];
  for (const { axis, shape } of cases) {
    const [m, n] = shape;
    const zeros = () => ops.zeros([n, n], Dtype.float32);
    const strictBlockLower = (scale: number) => {
      const data = new Float32Array(n * n), noise = gaussian(n * n, 99);
      for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) if (Math.floor(i / TRELLIS_T) > Math.floor(j / TRELLIS_T)) data[i * n + j] = noise[i * n + j]! * scale;
      return MlxArray.fromFloat32(data, [n, n]);
    };

    test(`axis ${axis}: with no feedback the weighted arm reduces to the unweighted encoding`, () => {
      using w = matrix(m, n, 31), L = zeros();
      const weighted = encoder.encodeLdlq(w, axis, L, 3), plain = encoder.encode(w, axis, 3);
      try {
        expect(weighted.tripped).toBe(false);
        expect(weighted.codes.shape).toEqual(plain.codes.shape);
        expect(hostScales(weighted.scales)).toEqual(hostScales(plain.scales));
        expect(hostCodes(weighted.codes)).toEqual(hostCodes(plain.codes));
      } finally { for (const a of [weighted.codes, weighted.scales, plain.codes, plain.scales]) a.dispose(); }
    });

    test(`axis ${axis}: error feedback changes the codes, keeps the geometry, and stays near the unweighted distortion`, () => {
      using w = matrix(m, n, 32), L = strictBlockLower(0.02);
      const weighted = encoder.encodeLdlq(w, axis, L, 3), plain = encoder.encode(w, axis, 3);
      try {
        expect(weighted.tripped).toBe(false);
        expect(weighted.codes.shape).toEqual(plain.codes.shape);
        expect(hostCodes(weighted.codes)).not.toEqual(hostCodes(plain.codes));
        expect(hostScales(weighted.scales)).toEqual(hostScales(plain.scales));
        const rows = weighted.codes.shape[0]!, cols = axis === 1 ? n : m;
        const source = axis === 1 ? w.toFloat32() : (() => { using t = ops.contiguous(ops.transposeAxes(w, [1, 0])); return t.toFloat32(); })();
        const error = (packed: { codes: MlxArray; scales: MlxArray }) => {
          const d = decode(packed.codes, packed.scales, rows, cols, 3);
          let e = 0; for (let i = 0; i < d.length; i++) e += (d[i]! - source[i]!) ** 2; return e;
        };
        expect(error(weighted)).toBeLessThan(2 * error(plain));
      } finally { for (const a of [weighted.codes, weighted.scales, plain.codes, plain.scales]) a.dispose(); }
    });

    test(`axis ${axis}: feedback beyond the guard ceiling falls back to the unweighted encoding and says so`, () => {
      using w = matrix(m, n, 33), L = strictBlockLower(1e4);
      const weighted = encoder.encodeLdlq(w, axis, L, 3), plain = encoder.encode(w, axis, 3);
      try {
        expect(weighted.tripped).toBe(true);
        expect(hostCodes(weighted.codes)).toEqual(hostCodes(plain.codes));
      } finally { for (const a of [weighted.codes, weighted.scales, plain.codes, plain.scales]) a.dispose(); }
    });
  }

  test("a factor of the wrong size is refused", () => {
    using w = matrix(64, 512, 34), L = ops.zeros([256, 256], Dtype.float32);
    expect(() => encoder.encodeLdlq(w, 1, L, 3)).toThrow("L dim 256 != LDLQ dim 512");
  });
});
