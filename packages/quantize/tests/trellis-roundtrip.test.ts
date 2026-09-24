import { describe, expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { expandTrellis, vectorTrellisExpand, type TrellisGeometry } from "@mlx-bun/inference/kernels/trellis";
import { TRELLIS_L, TRELLIS_T, interleaveTrellisCodes, lut1mad, packStates, unpackDecodeHost, wordsPerBlock } from "../src/trellis";

// The quantizer packs states; the inference kernels expand them. This proves the
// two agree on the packed format, with the quantizer's host decoder as referee.

function geometry(k: number, rows: number, cols: number): TrellisGeometry {
  return { k, L: TRELLIS_L, T: TRELLIS_T, axis: 1, rows, cols, inFeatures: cols, outFeatures: rows };
}

/** Pack pseudo-random k-bit symbols for every row and block. */
function packedWords(g: TrellisGeometry): Uint32Array {
  const blocksPerRow = g.cols / g.T, symbols = new Int32Array(g.rows * g.cols);
  let seed = 17;
  for (let i = 0; i < symbols.length; i++) {
    seed = Math.imul(seed, 1664525) + 1013904223;
    symbols[i] = (seed >>> 8) & ((1 << g.k) - 1);
  }
  const words = new Uint32Array(g.rows * blocksPerRow * wordsPerBlock(g.T, g.k));
  packStates(symbols, g.rows * blocksPerRow, g.T, g.k, words);
  return words;
}

/** Power-of-two scales keep host and kernel products exact in float32. */
function scalesFor(rows: number): Float32Array {
  return Float32Array.from({ length: rows }, (_, i) => [0.5, 1, 2, 0.25][i % 4]!);
}

function codesArray(words: Uint32Array, shape: number[]): MlxArray {
  return MlxArray.fromBytesCopy(new Uint8Array(words.buffer, words.byteOffset, words.byteLength), shape, Dtype.uint32);
}

describe("quantizer packing round-trips through the inference kernels", () => {
  for (const k of [2, 3, 4]) {
    test(`k=${k}: row-major words expand to the host decoder's values`, () => {
      const g = geometry(k, 32, 512), words = packedWords(g), scales = scalesFor(g.rows);
      const expected = unpackDecodeHost(words, scales, g.rows, g.cols, g.k, g.T, lut1mad(g.L));
      using codes = codesArray(words, [g.rows, words.length / g.rows]);
      using scaleArr = MlxArray.fromFloat32(scales, [g.rows]);
      using actual = expandTrellis(codes, scaleArr, g, Dtype.float32, 6);
      expect(actual.shape).toEqual([g.rows, g.cols]);
      const values = actual.toFloat32();
      const mismatch = values.findIndex((v, i) => v !== expected[i]);
      expect(mismatch, "first mismatched value (-1 means identical)").toBe(-1);
    });
  }

  test("k=3: the quantizer's interleaved layout matches the kernels' interleaved reader", () => {
    const g = geometry(3, 16, 1024), words = packedWords(g), scales = scalesFor(g.rows);
    const expected = unpackDecodeHost(words, scales, g.rows, g.cols, g.k, g.T, lut1mad(g.L));
    using rowMajor = codesArray(words, [g.rows, words.length / g.rows]);
    using interleaved = interleaveTrellisCodes(rowMajor);
    expect(interleaved.shape).toEqual([g.cols / 512, g.rows, 48]);
    using scaleArr = MlxArray.fromFloat32(scales, [g.rows]);
    const ig: TrellisGeometry = { ...g, blockInterleave: 2 };
    using actual = expandTrellis(interleaved, scaleArr, ig, Dtype.float32, 6);
    const values = actual.toFloat32();
    const mismatch = values.findIndex((v, i) => v !== expected[i]);
    expect(mismatch, "first mismatched value (-1 means identical)").toBe(-1);
  });

  test("k=3: the vector expansion kernel agrees with the general kernel in bfloat16", () => {
    const g = geometry(3, 64, 512), words = packedWords(g), scales = scalesFor(g.rows);
    using codes = codesArray(words, [g.rows, words.length / g.rows]);
    using scaleArr = MlxArray.fromFloat32(scales, [g.rows]);
    using general = expandTrellis(codes, scaleArr, g, Dtype.bfloat16, 6);
    using vector = vectorTrellisExpand(codes, scaleArr, g);
    const a = general.rawBytes(), b = vector.rawBytes();
    expect(a.length).toBe(b.length);
    expect(a.findIndex((byte, i) => byte !== b[i])).toBe(-1);
  });
});
