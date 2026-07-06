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

// ---- Layer 0: tiered take / idle demotion / onPut (fake cold tier) --------

/** In-memory fake of the SSD tier: stores token lists, "restores" fresh stub
 *  caches; counts calls. `trimmable` shapes the divergent-tail rule. */
function fakeCold(trimmable = true) {
  const stored: { tokens: number[]; ns: string }[] = [];
  const retained = { count: 0 };
  const restores = { count: 0 };
  let failRestore = false;
  const disposed = { count: 0 };
  const trims: number[] = [];
  return {
    stored, retained, restores, trims, disposed,
    setFailRestore(v: boolean) { failRestore = v; },
    tier: {
      find(prompt: number[], ns: string) {
        let best: { tokens: number[] } | null = null;
        let bestLen = 0;
        for (const e of stored) {
          if (e.ns !== ns) continue;
          let p = 0;
          while (p < Math.min(e.tokens.length, prompt.length - 1) && e.tokens[p] === prompt[p]) p++;
          if (p > bestLen) { bestLen = p; best = e; }
        }
        return best ? { prefixLen: bestLen, handle: best } : null;
      },
      restore(handle: unknown) {
        if (failRestore) return null;
        restores.count++;
        const e = handle as { tokens: number[] };
        return {
          tokens: [...e.tokens],
          caches: [stubCache(10, disposed, trimmable, trims)],
          retain: () => { retained.count++; },
        };
      },
      store(tokens: number[], _caches: Cache[], ns: string) {
        stored.push({ tokens: [...tokens], ns });
      },
    },
  };
}

describe("PromptCache — Layer 0 tiering", () => {
  test("cold tier wins with a strictly longer prefix; RAM entry stays untouched", () => {
    const cold = fakeCold();
    const pc = new PromptCache(1e9, null, cold.tier);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4], [], "");

    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]); // the cold entry
    expect(cold.restores.count).toBe(1);
    expect(pc.size).toBe(1); // RAM entry not consumed, not trimmed
    expect(hit?.retain).toBeDefined();
  });

  test("tie (equal prefix) goes to RAM — the restore is not free", () => {
    const cold = fakeCold();
    const pc = new PromptCache(1e9, null, cold.tier);
    const d = { count: 0 };
    pc.put([1, 2, 3], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3], [], "");

    const hit = pc.take([1, 2, 3, 9]);
    expect(cold.restores.count).toBe(0);
    expect(hit?.tokens).toEqual([1, 2, 3]);
    expect(pc.size).toBe(0); // RAM entry consumed
  });

  test("cold entry with an untrimmable divergent tail falls back to RAM", () => {
    const cold = fakeCold(false); // restored caches refuse trim
    const pc = new PromptCache(1e9, null, cold.tier);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4, 9, 9], [], ""); // diverges at [4]: needs trim

    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2]); // RAM served
    expect(cold.disposed.count).toBe(1); // restored caches dropped
    expect(cold.retained.count).toBe(1); // unmap ran after dispose
  });

  test("cold entry trims a divergent tail when trimmable", () => {
    const cold = fakeCold(true);
    const pc = new PromptCache(1e9, null, cold.tier);
    cold.tier.store([1, 2, 3, 4, 9, 9], [], "");
    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]);
    expect(cold.trims).toEqual([2]); // dropped the [9, 9] tail
  });

  test("restore failure degrades to the RAM candidate", () => {
    const cold = fakeCold();
    const pc = new PromptCache(1e9, null, cold.tier);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4], [], "");
    cold.setFailRestore(true);
    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2]);
  });

  test("demoteIdle spills idle entries to the cold tier, frees GPU, and take() restores them", () => {
    const cold = fakeCold();
    const pc = new PromptCache(1e9, null, cold.tier);
    const d = { count: 0 };
    const t0 = Date.now();
    pc.put([1, 2, 3], [stubCache(10, d)]);
    pc.put([4, 5], [stubCache(10, d)]);

    expect(pc.demoteIdle(60_000, t0 + 30_000)).toBe(0); // nothing idle yet
    const n = pc.demoteIdle(60_000, t0 + 120_000); // both idle now
    expect(n).toBe(2);
    expect(pc.size).toBe(0);
    expect(d.count).toBe(2); // GPU memory freed
    expect(cold.stored.map((e) => e.tokens)).toEqual([[1, 2, 3], [4, 5]]);
    expect(pc.demotions).toBe(2);

    // ... and the prefix is still reachable, now via the cold tier.
    const hit = pc.take([1, 2, 3, 9]);
    expect(hit?.tokens).toEqual([1, 2, 3]);
    expect(cold.restores.count).toBe(1);
  });

  test("demoteIdle without a cold tier is a no-op (never data loss)", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    pc.put([1], [stubCache(10, d)]);
    expect(pc.demoteIdle(0)).toBe(0);
    expect(pc.size).toBe(1);
    expect(d.count).toBe(0);
  });

  test("onPut fires per put with tokens+ns; its exceptions are contained", () => {
    const pc = new PromptCache(1e9);
    const d = { count: 0 };
    const puts: Array<[number[], string]> = [];
    pc.onPut = (tokens, ns) => { puts.push([tokens, ns]); throw new Error("boom"); };
    pc.put([1, 2], [stubCache(10, d)], "nsA");
    expect(puts).toEqual([[[1, 2], "nsA"]]);
    expect(pc.size).toBe(1); // the throw did not unwind the put
  });
});
