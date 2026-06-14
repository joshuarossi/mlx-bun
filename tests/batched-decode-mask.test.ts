// FAST: batched-decode attention mask (no model load).
//
// Mirrors tests/train-batch.test.ts's buildBatchedPadMask checks for the
// decode-side primitive (src/model/batched-mask.ts): left-padded key validity
// AND causal(+window) at a nonzero offset. Pure array logic — runs in the fast
// suite. The serving batched-decode path (phase S1) builds on this mask.

import { describe, expect, test } from "bun:test";
import { Dtype } from "../src/mlx/ffi";
import { buildBatchedDecodeMask, BatchedDecodeMaskCache } from "../src/model/batched-mask";
import { KVCache } from "../src/model/gemma4-base";

describe("buildBatchedDecodeMask", () => {
  test("N=1 step: [B,1,1,S] bool, causal-trivial AND key past left padding", () => {
    const B = 2, S = 5, N = 1;
    const leftPad = [0, 2]; // row0 unpadded; row1's first 2 columns are padding
    const mask = buildBatchedDecodeMask(B, N, S, leftPad, null);
    expect(mask.shape).toEqual([B, 1, N, S]);
    expect(mask.dtype).toBe(Dtype.bool);

    const flat = mask.toFloat32(); // true→1, false→0, row-major [B,1,N,S]
    mask.dispose();
    const at = (b: number, i: number, j: number) => flat[((b * 1 + 0) * N + i) * S + j]!;

    for (let b = 0; b < B; b++)
      for (let j = 0; j < S; j++) {
        // The single query sits at abs pos S-1, so causality allows every key
        // (j <= S-1); only the row's left padding is masked out.
        expect(at(b, 0, j)).toBe(j >= leftPad[b]! ? 1 : 0);
      }
  });

  test("N>1 chunk: causal among the new queries at a nonzero offset", () => {
    const B = 1, S = 4, N = 2; // two new queries at abs pos 2,3 over 4 keys
    const mask = buildBatchedDecodeMask(B, N, S, [0], null);
    const flat = mask.toFloat32();
    mask.dispose();
    const at = (i: number, j: number) => flat[i * S + j]!;
    for (let i = 0; i < N; i++) {
      const qpos = S - N + i; // 2, then 3
      for (let j = 0; j < S; j++) expect(at(i, j)).toBe(j <= qpos ? 1 : 0);
    }
  });

  test("left padding combines with the sliding window", () => {
    const B = 1, S = 5, N = 1, W = 2;
    const leftPad = [1];
    const mask = buildBatchedDecodeMask(B, N, S, leftPad, W);
    const flat = mask.toFloat32();
    mask.dispose();
    const at = (j: number) => flat[j]!;
    const qpos = S - 1; // 4
    for (let j = 0; j < S; j++) {
      // causal (j<=qpos) AND window (qpos < j+W ⇒ j > qpos-W) AND j>=leftPad
      expect(at(j)).toBe(j <= qpos && qpos < j + W && j >= leftPad[0]! ? 1 : 0);
    }
  });
});

describe("BatchedDecodeMaskCache (wrapper, no model)", () => {
  test("ropeOffsetArr = inner.offset − leftPad per row; tracks offset", () => {
    const inner = new KVCache();
    inner.offset = 4; // pre-write offset
    const cache = new BatchedDecodeMaskCache(inner, 2, [0, 2], null);
    expect(cache.offset).toBe(4);

    const pos = cache.ropeOffsetArr.toFloat32();
    expect([...pos]).toEqual([4, 2]); // [4-0, 4-2]
    // Same offset → memoized to the SAME handle (graph holds it until eval).
    expect(cache.ropeOffsetArr).toBe(cache.ropeOffsetArr);

    inner.offset = 5; // next step advanced the buffer
    expect([...cache.ropeOffsetArr.toFloat32()]).toEqual([5, 3]);
    cache.dispose();
  });

  test("makeMask returns the [B,1,N,S] decode mask at the post-write width", () => {
    const inner = new KVCache();
    inner.offset = 4;
    const cache = new BatchedDecodeMaskCache(inner, 2, [0, 2], null);
    const { mode, arr } = cache.makeMask(1, null); // N=1 → S = 4+1 = 5
    expect(mode).toBe("array");
    expect(arr!.shape).toEqual([2, 1, 1, 5]);
    const flat = arr!.toFloat32();
    const at = (b: number, j: number) => flat[b * 5 + j]!;
    for (let j = 0; j < 5; j++) {
      expect(at(0, j)).toBe(1); // row0 unpadded: all keys valid
      expect(at(1, j)).toBe(j >= 2 ? 1 : 0); // row1: first 2 cols are padding
    }
    arr!.dispose();
    cache.dispose();
  });
});
