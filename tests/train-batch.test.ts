// FAST: batched (B>1) training — batching, padding, and mask construction.
//
// No model load. Exercises the pure batching/masking logic directly:
//   - iterateSftBatches B=2: length-sort → contiguous windows → pad-to rule,
//     correct promptLen/length boundaries, pad fill, B=1 stays unpadded.
//   - iterateDpoBatches B=2: chosen/rejected padded per kind, masks 0 at pad.
//   - buildBatchedPadMask: [B,1,L,L] bool, causal AND key-within-valid-length,
//     pad columns zeroed per row.
//   - the SFT loss mask excludes padding (verified via the mask-construction
//     boundary math, mirrored from loss.ts).
//   - a B=2 batched ValueAndGrad finite-difference check proving gradients
//     flow through a LoRA-shaped graph with a batched input.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import { ValueAndGrad } from "../src/mlx/autograd";
import { add, sub, mul, matmul, reshape, sumAxis, mulScalar } from "../src/mlx/ops";
import {
  iterateSftBatches, iterateDpoBatches, rowLength, PAD_TO,
  type SftExample, type DpoExample,
} from "../src/train/dataset";
import { buildBatchedPadMask } from "../src/train/forward";

// ---------------------------------------------------------------------------
// SFT batching
// ---------------------------------------------------------------------------

describe("iterateSftBatches B>1", () => {
  // Distinct lengths so sort order is unambiguous: 3, 5, 8, 10.
  const ex = (len: number, promptLen: number): SftExample => ({
    ids: Array.from({ length: len }, (_, i) => i + 1), // 1..len (avoid 0=pad)
    promptLen,
  });
  const examples: SftExample[] = [ex(8, 4), ex(3, 1), ex(10, 6), ex(5, 2)];

  test("sorts by length then pads contiguous windows to the pad-to rule", () => {
    const it = iterateSftBatches(examples, 2, 256, 1, false, 0);
    const batches = [...it];
    // 4 examples / B=2 = 2 batches.
    expect(batches.length).toBe(2);

    // Sorted lengths: [3,5,8,10] → windows {3,5} and {8,10}.
    // Each batch is one of those windows (order may be permuted across batches).
    const byMaxLen = new Map(
      batches.map((b) => [Math.max(...b.lengths!), b]),
    );
    const small = byMaxLen.get(5)!;
    const large = byMaxLen.get(10)!;
    expect(small).toBeDefined();
    expect(large).toBeDefined();

    // pad-to rule: L = min(1 + 32*ceil(maxLen/32), 256).
    const padded = (maxLen: number) => 1 + PAD_TO * Math.ceil(maxLen / PAD_TO);
    expect(small.ids[0]!.length).toBe(padded(5)); // 33
    expect(large.ids[0]!.length).toBe(padded(10)); // 33
    // Every row in a batch shares the padded length.
    for (const b of batches)
      for (const row of b.ids) expect(row.length).toBe(b.ids[0]!.length);
  });

  test("records true lengths and zeroes pad positions", () => {
    const batches = [...iterateSftBatches(examples, 2, 256, 1, false, 0)];
    const small = batches.find((b) => Math.max(...b.lengths!) === 5)!;
    const L = small.ids[0]!.length;

    // The window {3,5}: one row valid-len 3, one valid-len 5.
    const lens = [...small.lengths!].sort((a, b) => a - b);
    expect(lens).toEqual([3, 5]);

    for (let r = 0; r < small.ids.length; r++) {
      const trueLen = small.lengths![r]!;
      // Real positions carry the original ids (1..trueLen).
      for (let t = 0; t < trueLen; t++) expect(small.ids[r]![t]).toBe(t + 1);
      // Pad positions are the pad id (0).
      for (let t = trueLen; t < L; t++) expect(small.ids[r]![t]).toBe(0);
    }
  });

  test("preserves prompt boundaries per row", () => {
    const batches = [...iterateSftBatches(examples, 2, 256, 1, false, 0)];
    const small = batches.find((b) => Math.max(...b.lengths!) === 5)!;
    // Map valid-len → promptLen: len3→prompt1, len5→prompt2.
    const want = new Map([[3, 1], [5, 2]]);
    for (let r = 0; r < small.ids.length; r++)
      expect(small.promptLens[r]).toBe(want.get(small.lengths![r]!));
  });

  test("respects maxSeqLen: truncates rows and caps the padded length", () => {
    const batches = [...iterateSftBatches(examples, 2, 6, 1, false, 0)];
    const large = batches.find((b) => b.ids.flat().length > 0 && b.lengths!.includes(6))!;
    // maxSeqLen=6 caps L at 6; the len-8 and len-10 rows truncate to 6.
    for (const b of batches) {
      expect(b.ids[0]!.length).toBeLessThanOrEqual(6);
      for (let r = 0; r < b.ids.length; r++)
        expect(rowLength(b, r)).toBeLessThanOrEqual(b.ids[r]!.length);
    }
    void large;
  });

  test("pads with the given pad id", () => {
    const batches = [...iterateSftBatches(examples, 2, 256, 1, false, 999)];
    const small = batches.find((b) => Math.max(...b.lengths!) === 5)!;
    const L = small.ids[0]!.length;
    const shortRow = small.ids[small.lengths!.indexOf(3)]!;
    for (let t = 3; t < L; t++) expect(shortRow[t]).toBe(999);
  });

  test("B=1 stays unpadded and bit-identical in shape", () => {
    const batches = [...iterateSftBatches(examples, 1, 256, 1, false, 0)];
    expect(batches.length).toBe(4);
    for (const b of batches) {
      expect(b.ids.length).toBe(1);
      // No pad-to rounding: length equals the example length (<=256).
      expect(b.lengths![0]).toBe(b.ids[0]!.length);
    }
  });

  test("throws when the dataset is smaller than the batch size", () => {
    expect(() => [...iterateSftBatches([ex(3, 1)], 2, 256, 1, false)]).toThrow(
      /batchSize=2/,
    );
  });
});

// ---------------------------------------------------------------------------
// DPO batching (_make_batch)
// ---------------------------------------------------------------------------

describe("iterateDpoBatches B>1", () => {
  const dex = (clen: number, cprompt: number, rlen: number, rprompt: number): DpoExample => ({
    chosenIds: Array.from({ length: clen }, (_, i) => i + 1),
    rejectedIds: Array.from({ length: rlen }, (_, i) => i + 1),
    chosenMask: Array.from({ length: clen }, (_, i) => (i >= cprompt ? 1 : 0)),
    rejectedMask: Array.from({ length: rlen }, (_, i) => (i >= rprompt ? 1 : 0)),
  });
  // Two triples with different chosen and rejected lengths.
  const examples: DpoExample[] = [dex(4, 2, 6, 3), dex(7, 3, 5, 2)];

  test("pads chosen/rejected each to their own batch-max with masks 0 at pad", () => {
    const batches = [...iterateDpoBatches(examples, 2, 1, false, 0)];
    expect(batches.length).toBe(1);
    const b = batches[0]!;

    const Lc = Math.max(...examples.map((e) => e.chosenIds.length)); // 7
    const Lr = Math.max(...examples.map((e) => e.rejectedIds.length)); // 6
    for (const row of b.chosenIds) expect(row.length).toBe(Lc);
    for (const row of b.rejectedIds) expect(row.length).toBe(Lr);
    for (const m of b.chosenMask) expect(m.length).toBe(Lc);
    for (const m of b.rejectedMask) expect(m.length).toBe(Lr);

    // Per-row true lengths recorded.
    expect([...b.chosenLengths!].sort((a, c) => a - c)).toEqual([4, 7]);
    expect([...b.rejectedLengths!].sort((a, c) => a - c)).toEqual([5, 6]);

    // Pad positions: ids = pad id (0), mask = 0.
    for (let r = 0; r < b.chosenIds.length; r++) {
      const tl = b.chosenLengths![r]!;
      for (let t = tl; t < Lc; t++) {
        expect(b.chosenIds[r]![t]).toBe(0);
        expect(b.chosenMask[r]![t]).toBe(0);
      }
    }
  });

  test("B=1 stays unpadded", () => {
    const batches = [...iterateDpoBatches(examples, 1, 1, false, 0)];
    expect(batches.length).toBe(2);
    for (const b of batches) {
      expect(b.chosenIds.length).toBe(1);
      expect(b.chosenLengths![0]).toBe(b.chosenIds[0]!.length);
    }
  });
});

// ---------------------------------------------------------------------------
// Batched padding-aware attention mask
// ---------------------------------------------------------------------------

describe("buildBatchedPadMask", () => {
  test("is [B,1,L,L] bool: causal AND key-within-valid-length per row", () => {
    const B = 2, L = 4;
    const validLengths = [4, 2]; // row0 full, row1 valid keys {0,1}
    const mask = buildBatchedPadMask(B, L, validLengths, null);
    expect(mask.shape).toEqual([B, 1, L, L]);
    expect(mask.dtype).toBe(Dtype.bool);

    // Read back as f32 (true→1, false→0). Layout row-major [B,1,L,L].
    const flat = mask.toFloat32();
    mask.dispose();
    const at = (b: number, i: number, j: number) => flat[((b * 1 + 0) * L + i) * L + j]!;

    for (let b = 0; b < B; b++) {
      const vlen = validLengths[b]!;
      for (let i = 0; i < L; i++)
        for (let j = 0; j < L; j++) {
          const expected = j <= i && j < vlen ? 1 : 0;
          expect(at(b, i, j)).toBe(expected);
        }
    }
  });

  test("with no padding (all rows full) it is exactly the causal mask", () => {
    const B = 2, L = 3;
    const mask = buildBatchedPadMask(B, L, [L, L], null);
    const flat = mask.toFloat32();
    mask.dispose();
    const at = (b: number, i: number, j: number) => flat[((b * 1 + 0) * L + i) * L + j]!;
    for (let b = 0; b < B; b++)
      for (let i = 0; i < L; i++)
        for (let j = 0; j < L; j++) expect(at(b, i, j)).toBe(j <= i ? 1 : 0);
  });

  test("a sliding window further restricts attention", () => {
    const B = 1, L = 4, W = 2;
    const mask = buildBatchedPadMask(B, L, [L], W);
    const flat = mask.toFloat32();
    mask.dispose();
    const at = (i: number, j: number) => flat[i * L + j]!;
    // window: causal AND i < j + W  ⇒  j > i - W.
    for (let i = 0; i < L; i++)
      for (let j = 0; j < L; j++)
        expect(at(i, j)).toBe(j <= i && i < j + W ? 1 : 0);
  });
});

// ---------------------------------------------------------------------------
// SFT loss mask boundary (mirrors loss.ts maskedCe) — excludes padding
// ---------------------------------------------------------------------------

describe("SFT loss mask excludes padding", () => {
  // Replicates the exact mask predicate from loss.ts maskedCe so the boundary
  // logic is unit-tested without a model: supervised iff
  //   (t+1 >= promptLen) AND (t+1 < length).
  function lossMask(L: number, promptLen: number, length: number): number[] {
    const T = L - 1;
    const m: number[] = [];
    for (let t = 0; t < T; t++)
      m.push(t + 1 >= promptLen && t + 1 < length ? 1 : 0);
    return m;
  }

  test("padded tail positions are not supervised", () => {
    // L=6 padded row, promptLen=2, true length=4 (positions 4,5 are pad).
    const m = lossMask(6, 2, 4);
    // target index t predicts ids[t+1]; supervised t where 2<=t+1<4 → t in {1,2}.
    expect(m).toEqual([0, 1, 1, 0, 0]);
  });

  test("a full (unpadded) row supervises every response position", () => {
    // length == L means t+1 < L always holds for t in 0..L-2.
    const m = lossMask(5, 2, 5);
    expect(m).toEqual([0, 1, 1, 1]); // t in {1,2,3}
  });
});

// ---------------------------------------------------------------------------
// Batched autograd (B=2) — gradients flow through a LoRA-shaped graph
// ---------------------------------------------------------------------------

describe("batched ValueAndGrad (B=2)", () => {
  const B = 2, IN = 6, RANK = 2, OUT = 6;
  const N = B * OUT;

  const det = (n: number, f: (i: number) => number) =>
    new Float32Array(Array.from({ length: n }, (_, i) => f(i)));
  // Batched input x: [B, IN]; target y: [B, OUT].
  const xData = det(B * IN, (i) => Math.sin(i * 0.6) * 0.5);
  const yData = det(B * OUT, (i) => Math.cos(i * 0.35) * 0.3);
  const aData = det(IN * RANK, (i) => ((i * 7 + 3) % 11) / 11 - 0.5);
  const bData = det(RANK * OUT, (i) => ((i * 5 + 1) % 9) / 9 - 0.4);

  const xConst = MlxArray.fromFloat32(xData, [B, IN]);
  const yConst = MlxArray.fromFloat32(yData, [B, OUT]);

  // loss = mean( (x + (x@A)@B - y)^2 ) over the WHOLE [B,OUT] batch.
  function buildLoss(a: MlxArray, b: MlxArray, x: MlxArray, y: MlxArray): MlxArray {
    const xa = matmul(x, a); // [B, RANK]
    const xab = matmul(xa, b); // [B, OUT]
    const pred = add(x, xab); // [B, OUT]
    const resid = sub(pred, y);
    const sq = mul(resid, resid);
    const flat = reshape(sq, [N]);
    const s = sumAxis(flat, 0, false);
    const loss = mulScalar(s, 1 / N);
    for (const t of [xa, xab, pred, resid, sq, flat, s]) t.dispose();
    return loss;
  }

  function eagerLoss(a: Float32Array, b: Float32Array): number {
    const aArr = MlxArray.fromFloat32(a, [IN, RANK]);
    const bArr = MlxArray.fromFloat32(b, [RANK, OUT]);
    const loss = buildLoss(aArr, bArr, xConst, yConst);
    const v = loss.toFloat32()[0]!;
    for (const t of [aArr, bArr, loss]) t.dispose();
    return v;
  }

  test("LoRA-shaped grads match finite differences over a B=2 input", () => {
    const vag = new ValueAndGrad(
      (p) => buildLoss(p[0]!, p[1]!, p[2]!, p[3]!),
      [0, 1],
    );
    const aArr = MlxArray.fromFloat32(aData, [IN, RANK]);
    const bArr = MlxArray.fromFloat32(bData, [RANK, OUT]);
    const { value, grads } = vag.apply([aArr, bArr, xConst, yConst]);

    expect(grads.length).toBe(2);
    expect(value.toFloat32()[0]!).toBeCloseTo(eagerLoss(aData, bData), 4);

    const dA = grads[0]!.toFloat32();
    const dB = grads[1]!.toFloat32();
    value.dispose();
    for (const g of grads) g.dispose();
    aArr.dispose();
    bArr.dispose();
    vag.dispose();

    const EPS = 1e-3, TOL = 1e-2;
    const check = (name: "A" | "B", base: Float32Array, analytic: Float32Array, size: number) => {
      const coords = [...new Set([0, 1, 3, size - 1, Math.floor(size / 2)])].filter((i) => i < size);
      for (const idx of coords) {
        const plus = base.slice(); plus[idx]! += EPS;
        const minus = base.slice(); minus[idx]! -= EPS;
        const fd = name === "A"
          ? (eagerLoss(plus, bData) - eagerLoss(minus, bData)) / (2 * EPS)
          : (eagerLoss(aData, plus) - eagerLoss(aData, minus)) / (2 * EPS);
        const an = analytic[idx]!;
        const rel = Math.abs(an - fd) / (Math.abs(an) + 1e-4);
        expect(rel).toBeLessThan(TOL);
      }
    };
    check("A", aData, dA, IN * RANK);
    check("B", bData, dB, RANK * OUT);
  });
});
