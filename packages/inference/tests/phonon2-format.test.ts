import { expect, test } from "bun:test";
import {
  fermionRecords,
  halfFloat,
  unpackDense,
  unpackFiveValue,
} from "../src/artifacts/phonon2-format";
import { tdtWindowEnd, tdtWords } from "../src/transcription/tdt/segments";
import { isTranscriptionModelType, supportTier } from "../src/models/support";
test("Phonon-2 is a transcription family", () => {
  expect(isTranscriptionModelType("parakeet_tdt_five_value")).toBe(true);
  expect(supportTier("parakeet_tdt_five_value")).toBe("targeted");
});
test("five-value record decodes all signs and magnitudes into exact affine planes", () => {
  const signs = Array.from({ length: 16 }, (_, i) => i % 3),
    raw: number[] = [];
  for (let i = 0; i < 16; i += 5)
    raw.push(signs.slice(i, i + 5).reduce((n, c, j) => n + c * 3 ** j, 0));
  const nz = signs.filter((c) => c !== 1).length;
  raw.push(...new Array(Math.ceil(nz / 8)).fill(0b01010101));
  raw.push(0, 0x38, 0, 0x3c); // lo=.5, hi=1
  const data = new Uint8Array(raw),
    planes = unpackFiveValue({
      n: "test",
      k: "five_value",
      shape: [1, 16],
      b: raw.length,
      data,
    });
  let bit = 0;
  for (let i = 0; i < 16; i++) {
    const a = ((planes.base[0]! >>> (i * 2)) & 3) - 1,
      b = ((planes.residual[0]! >>> (i * 2)) & 3) - 1;
    const high = signs[i] !== 1 ? bit++ % 2 === 0 : false;
    expect(a * planes.lo[0]! + b * planes.delta[0]!).toBe(
      (signs[i]! - 1) * (high ? 1 : 0.5),
    );
  }
});
test("signed int6 packing and malformed containers", () => {
  const raw = new Uint8Array([0, 0xf8, 0xff, 0, 0x3c]); // codes [0,32,63,63], row scale 1
  expect([
    ...unpackDense({ n: "int6", k: "int6", shape: [1, 4], b: 5, data: raw }),
  ]).toEqual([-32, 0, 31, 31]);
  expect(halfFloat(0x3c00)).toBe(1);
  expect(halfFloat(1)).toBe(2 ** -24);
  expect(() => fermionRecords(new Uint8Array(7))).toThrow("truncated");
  expect(() => fermionRecords(new Uint8Array(8).fill(255))).toThrow("header");
});
test("TDT word timing groups subwords and punctuation without fabricated confidence", () => {
  expect(
    tdtWords(
      [
        { id: 1, piece: "▁trans", start: 0.08, duration: 0.08 },
        { id: 2, piece: "cript", start: 0.16, duration: 0.08 },
        { id: 3, piece: ".", start: 0.24, duration: 0.08 },
        { id: 4, piece: "▁Next", start: 0.4, duration: 0.16 },
      ],
      0.5,
    ),
  ).toEqual([
    { word: "transcript.", start: 0.08, end: 0.32 },
    { word: "Next", start: 0.4, end: 0.5 },
  ]);
  const samples = new Float32Array(16000 * 70).fill(0.1);
  samples.fill(0, 29 * 16000, 31 * 16000);
  expect(tdtWindowEnd(samples)).toBe(30 * 16000);
  expect(tdtWindowEnd(samples.subarray(0, 100))).toBe(100);
});

test("lookup unpacking preserves row tails and mask bits across packed word boundaries", () => {
  for (const cols of [16, 32, 128, 1024]) {
    const rows = 243,
      stride = Math.ceil(cols / 5),
      signs = new Uint8Array(rows * stride);
    const codes = new Uint8Array(rows * cols),
      high: number[] = [];
    const expected = new Float32Array(rows * cols);
    for (let r = 0; r < rows; r++)
      for (let c = 0; c < cols; c++) {
        const byte = (r + Math.floor(c / 5)) % 243,
          code = Math.floor(byte / 3 ** (c % 5)) % 3;
        codes[r * cols + c] = code;
        signs[r * stride + Math.floor(c / 5)]! += code * 3 ** (c % 5);
        const h = (r * 11 + c * 7) % 13 < 6;
        if (code !== 1) high.push(Number(h));
        expected[r * cols + c] = (code - 1) * (h ? 1 : 0.5);
      }
    const maskBytes = Math.ceil(high.length / 8),
      data = new Uint8Array(signs.length + maskBytes + 4 * rows);
    data.set(signs);
    high.forEach((h, i) => (data[signs.length + (i >>> 3)]! |= h << i % 8));
    const view = new DataView(data.buffer);
    for (let r = 0; r < rows; r++) {
      view.setUint16(signs.length + maskBytes + r * 2, 0x3800, true);
      view.setUint16(signs.length + maskBytes + rows * 2 + r * 2, 0x3c00, true);
    }
    const p = unpackFiveValue({
      n: "lookup",
      k: "five_value",
      shape: [rows, cols],
      b: data.length,
      data,
    });
    const actual = Float32Array.from(codes, (_, i) => {
      const a = ((p.base[i >>> 4]! >>> (2 * (i % 16))) & 3) - 1;
      const b = ((p.residual[i >>> 4]! >>> (2 * (i % 16))) & 3) - 1;
      return (
        a * p.lo[Math.floor(i / cols)]! + b * p.delta[Math.floor(i / cols)]!
      );
    });
    expect(actual).toEqual(expected);
  }
});
