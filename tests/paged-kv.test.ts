// FAST: paged KV cache storage layout (no model load).
//
// The v1 correctness claim is storage-layout equivalence: PagedKVCache's
// updateAndFetch returns the SAME bytes a plain KVCache returns for the
// same write sequence (docs/design/kv-cache.md — mlx-lm has no
// paged cache, so mlx-bun's own KVCache is the oracle). These tests feed
// both caches identical synthetic K/V across prefill-chunk + decode-step
// shapes, spanning block boundaries, and assert bit-equality every step.
// Pool bookkeeping (free-list reuse, trim, typed exhaustion) is covered
// model-free here too; the end-to-end greedy-trajectory gate lives in
// tests/paged-kv-parity.test.ts (weights-gated).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { KVCache } from "../src/model/gemma4-base";
import { PagedKVCache, PagedPoolExhausted, poolBlocksFor } from "../src/model/paged-kv";

const H = 2, D = 4;

/** Deterministic f32 K/V pair for one step: [1, H, L, D]. */
function stepKV(L: number, seed: number): [MlxArray, MlxArray] {
  const n = H * L * D;
  const kd = new Float32Array(n);
  const vd = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    kd[i] = Math.sin(seed * 131 + i) * 3;
    vd[i] = Math.cos(seed * 173 + i) * 5;
  }
  const mk = (data: Float32Array) => {
    const flat = MlxArray.fromFloat32(data, [1, H, L, D]);
    return flat;
  };
  return [mk(kd), mk(vd)];
}

function makePaged(capacity: number, blockSize: number): PagedKVCache {
  return new PagedKVCache(capacity, blockSize); // pool allocates lazily on first write
}

/** Materialized readback: fetched K/V are strided slice VIEWS, and raw
 *  toFloat32 readback needs contiguous (the generate.ts sampleStep rule). */
function read(a: MlxArray): Float32Array {
  const c = ops.contiguous(a);
  const out = c.toFloat32();
  c.dispose();
  return out;
}

/** Run the same write sequence through both caches; assert the fetched
 *  K/V are bit-equal after every single update. */
function assertParity(lens: number[], blockSize: number, trimAfter?: { step: number; n: number }) {
  const total = lens.reduce((a, b) => a + b, 0);
  const plain = new KVCache();
  const paged = makePaged(total, blockSize);
  lens.forEach((L, i) => {
    const [k1, v1] = stepKV(L, i);
    const [k2, v2] = stepKV(L, i);
    const [pk, pv] = plain.updateAndFetch(k1, v1);
    const [gk, gv] = paged.updateAndFetch(k2, v2);
    expect(gk.shape).toEqual(pk.shape);
    expect(gv.shape).toEqual(pv.shape);
    expect(read(gk)).toEqual(read(pk));
    expect(read(gv)).toEqual(read(pv));
    for (const a of [k1, v1, k2, v2, pk, pv, gk, gv]) a.dispose();
    if (trimAfter && trimAfter.step === i) {
      plain.trim(trimAfter.n);
      paged.trim(trimAfter.n);
      expect(paged.offset).toBe(plain.offset);
    }
  });
  expect(paged.offset).toBe(plain.offset);
  plain.dispose();
  paged.dispose();
}

describe("PagedKVCache vs KVCache (storage-layout parity)", () => {
  test("decode steps (L=1) within one block", () => {
    assertParity([1, 1, 1, 1, 1], 8);
  });

  test("decode steps crossing a block boundary", () => {
    assertParity(Array(10).fill(1), 4); // 10 tokens over 4-token blocks
  });

  test("prefill chunk spanning multiple blocks, then decode", () => {
    assertParity([11, 1, 1, 1], 4); // 11-token chunk = 3 blocks straddled
  });

  test("chunk landing mid-block then chunk crossing out of it", () => {
    assertParity([3, 6, 1], 4);
  });

  test("trim then regrow re-crosses the boundary bit-exact", () => {
    // 6 tokens over 4-blocks, trim 3 (frees the tail block), regrow 4.
    assertParity([1, 1, 1, 1, 1, 1, 1, 1, 1, 1], 4, { step: 5, n: 3 });
  });
});

describe("BlockPool bookkeeping", () => {
  test("trim frees tail blocks; free-list reuse keeps capacity exact", () => {
    const paged = makePaged(8, 4); // 2 blocks
    const [k, v] = stepKV(6, 0);
    const [a, b] = paged.updateAndFetch(k, v); // occupies both blocks
    for (const x of [k, v, a, b]) x.dispose();
    expect(paged.pool!.freeBlocks).toBe(0);
    paged.trim(3); // offset 3 → tail block freed
    expect(paged.offset).toBe(3);
    expect(paged.pool!.freeBlocks).toBe(1);
    const [k2, v2] = stepKV(5, 1);
    const [c, d] = paged.updateAndFetch(k2, v2); // regrows into the freed block
    expect(c.shape).toEqual([1, H, 8, D]);
    for (const x of [k2, v2, c, d]) x.dispose();
    expect(paged.pool!.freeBlocks).toBe(0);
    paged.dispose();
  });

  test("pool exhaustion is the typed error, not silent corruption", () => {
    const paged = makePaged(4, 4); // exactly 1 block
    const [k, v] = stepKV(4, 0);
    const [a, b] = paged.updateAndFetch(k, v);
    for (const x of [k, v, a, b]) x.dispose();
    const [k2, v2] = stepKV(1, 1);
    expect(() => paged.updateAndFetch(k2, v2)).toThrow(PagedPoolExhausted);
    k2.dispose();
    v2.dispose();
    paged.dispose();
  });

  test("trim to zero returns every block", () => {
    const paged = makePaged(8, 4);
    const [k, v] = stepKV(7, 0);
    const [a, b] = paged.updateAndFetch(k, v);
    for (const x of [k, v, a, b]) x.dispose();
    paged.trim(7);
    expect(paged.offset).toBe(0);
    expect(paged.pool!.freeBlocks).toBe(2);
    paged.dispose();
  });

  test("makeMask matches KVCache policy", () => {
    const paged = makePaged(8, 4);
    expect(paged.makeMask(1, null)).toEqual({ mode: "", arr: null });
    expect(paged.makeMask(4, null)).toEqual({ mode: "causal", arr: null });
    expect(paged.makeMask(2, 4)).toEqual({ mode: "causal", arr: null }); // N ≤ window at offset 0
    const windowed = paged.makeMask(4, 2); // N > window → materialized matrix
    expect(windowed.mode).toBe("array");
    windowed.arr!.dispose();
    paged.dispose();
  });
});

describe("poolBlocksFor", () => {
  test("rounds capacity up to whole blocks, min 1", () => {
    expect(poolBlocksFor(1, 256)).toBe(1);
    expect(poolBlocksFor(256, 256)).toBe(1);
    expect(poolBlocksFor(257, 256)).toBe(2);
    expect(poolBlocksFor(0, 256)).toBe(1);
  });
});
