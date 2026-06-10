// PromptCache unit tests (fast tier — stub caches, no weights).

import { describe, expect, test } from "bun:test";
import { PromptCache } from "../src/prompt-cache";
import type { Cache } from "../src/model/gemma4";

function stubCache(
  nbytes: number, disposed: { count: number }, trimmable = true,
  trims: number[] = [],
): Cache {
  return {
    offset: 0,
    updateAndFetch: () => { throw new Error("unused"); },
    makeMask: () => ({ mode: "", arr: null }),
    state: () => [{ nbytes } as never],
    isTrimmable: () => trimmable,
    trim: (n) => { trims.push(n); },
    dispose: () => { disposed.count++; },
  };
}

describe("PromptCache", () => {
  test("longest usable prefix wins; full-prefix hit needs no trim", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    const trims: number[] = [];
    pc.put([1, 2], [stubCache(10, d, true, trims)]);
    pc.put([1, 2, 3, 4], [stubCache(10, d, true, trims)]);
    pc.put([9, 9, 9], [stubCache(10, d, true, trims)]);

    const hit = pc.take([1, 2, 3, 4, 5, 6]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]);
    expect(trims).toEqual([]); // full prefix — nothing trimmed
    expect(pc.size).toBe(2);

    // no overlap at all → miss
    expect(pc.take([7, 8])).toBeNull();
    expect(pc.hits).toBe(1);
    expect(pc.misses).toBe(1);
  });

  test("diverging entry is trimmed to the common prefix", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    const trims: number[] = [];
    pc.put([1, 2, 3, 4, 5], [stubCache(10, d, true, trims)]);

    // prompt shares [1,2,3] then diverges
    const hit = pc.take([1, 2, 3, 9, 9, 9]);
    expect(hit?.tokens).toEqual([1, 2, 3]);
    expect(trims).toEqual([2]); // dropped [4, 5]
  });

  test("exact-match prompt trims one token to leave logits work", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    const trims: number[] = [];
    pc.put([1, 2, 3], [stubCache(10, d, true, trims)]);
    const hit = pc.take([1, 2, 3]);
    expect(hit?.tokens).toEqual([1, 2]);
    expect(trims).toEqual([1]);
  });

  test("untrimmable entry only matches in full", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    pc.put([1, 2, 3, 4, 5], [stubCache(10, d, false)]);

    // would need a trim → skipped
    expect(pc.take([1, 2, 3, 9])).toBeNull();
    // full prefix → fine without trim
    const hit = pc.take([1, 2, 3, 4, 5, 6]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4, 5]);
  });

  test("byte cap evicts LRU, never the fresh insert", () => {
    const pc = new PromptCache(100);
    const d1 = { count: 0 }, d2 = { count: 0 }, d3 = { count: 0 };
    pc.put([1], [stubCache(40, d1)]);
    pc.put([2], [stubCache(40, d2)]);
    expect(pc.totalBytes).toBe(80);

    pc.put([3], [stubCache(40, d3)]); // 120 > 100 → evict oldest ([1])
    expect(d1.count).toBe(1);
    expect(d2.count).toBe(0);
    expect(d3.count).toBe(0);
    expect(pc.totalBytes).toBe(80);
  });

  test("take refreshes recency via reinsert", () => {
    const pc = new PromptCache(100);
    const d1 = { count: 0 }, d2 = { count: 0 }, d3 = { count: 0 };
    pc.put([1], [stubCache(40, d1)]);
    pc.put([2], [stubCache(40, d2)]);
    const e = pc.take([1, 99]); // hit on [1]
    pc.put([1, 99], e!.caches); // reinsert extended → now newest
    pc.put([3], [stubCache(40, d3)]); // evicts [2], the true LRU
    expect(d2.count).toBe(1);
    expect(d1.count).toBe(0);
  });

  test("entry larger than the cap is disposed, not stored", () => {
    const pc = new PromptCache(100);
    const d = { count: 0 };
    pc.put([1], [stubCache(500, d)]);
    expect(d.count).toBe(1);
    expect(pc.size).toBe(0);
  });

  test("clear disposes everything", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    pc.put([1], [stubCache(10, d)]);
    pc.put([2], [stubCache(10, d)]);
    pc.clear();
    expect(d.count).toBe(2);
    expect(pc.size).toBe(0);
  });
});
