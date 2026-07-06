// PromptCache unit tests (fast tier — stub caches, no weights).
//
// Since prefix sharing (2026-07-05), take() is NON-CONSUMING: it serves
// zero-copy clones and leaves the donor entry in the cache (killing the
// cannibalization where one agent's prefix match destroyed another's
// entry), and put() supersedes same-ns prefix-ancestors when the new
// entry is trimmable. Tests inject a stub cloner (the real one,
// kv-store.cloneKvCaches, switches on real cache classes).

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

/** Stub cloner: fresh stubs mirroring nbytes/trimmability, recording trims
 *  and disposals into the given sinks (so donor vs clone are observable). */
function stubClone(cloneTrims: number[], cloneDisposed: { count: number }) {
  return (caches: Cache[]): Cache[] =>
    caches.map((c) =>
      stubCache(c.state()[0]!.nbytes, cloneDisposed, c.isTrimmable(), cloneTrims));
}

const mk = (maxBytes = 1e9) => {
  const cloneTrims: number[] = [];
  const cloneDisposed = { count: 0 };
  const pc = new PromptCache(maxBytes, null, null, stubClone(cloneTrims, cloneDisposed));
  return { pc, cloneTrims, cloneDisposed };
};

describe("PromptCache", () => {
  test("longest usable prefix wins; donor stays in the cache (non-consuming)", () => {
    const { pc, cloneTrims } = mk();
    const d = { count: 0 };
    const trims: number[] = [];
    pc.put([1, 2], [stubCache(10, d, true, trims)]);
    pc.put([1, 2, 3, 4], [stubCache(10, d, true, trims)]); // supersedes [1,2] (prefix ancestor)
    pc.put([9, 9, 9], [stubCache(10, d, true, trims)]);
    expect(pc.size).toBe(2);
    expect(d.count).toBe(1); // the superseded ancestor was disposed

    const hit = pc.take([1, 2, 3, 4, 5, 6]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]);
    expect(trims).toEqual([]); // donor untouched
    expect(cloneTrims).toEqual([]); // full prefix — clone needs no trim either
    expect(pc.size).toBe(2); // nothing consumed by the take

    expect(pc.take([7, 8])).toBeNull(); // no overlap → miss
    expect(pc.hits).toBe(1);
    expect(pc.misses).toBe(1);
  });

  test("diverging entry: the CLONE is trimmed to the common prefix; donor untouched", () => {
    const { pc, cloneTrims } = mk();
    const d = { count: 0 };
    const trims: number[] = [];
    pc.put([1, 2, 3, 4, 5], [stubCache(10, d, true, trims)]);

    const hit = pc.take([1, 2, 3, 9, 9, 9]); // shares [1,2,3] then diverges
    expect(hit?.tokens).toEqual([1, 2, 3]);
    expect(cloneTrims).toEqual([2]); // clone dropped [4, 5]
    expect(trims).toEqual([]); // donor keeps its full 5 tokens
    // ... and can still serve ITS OWN conversation at full length:
    const own = pc.take([1, 2, 3, 4, 5, 6]);
    expect(own?.tokens).toEqual([1, 2, 3, 4, 5]);
  });

  test("exact-match prompt trims one token (on the clone) to leave logits work", () => {
    const { pc, cloneTrims } = mk();
    const d = { count: 0 };
    pc.put([1, 2, 3], [stubCache(10, d)]);
    const hit = pc.take([1, 2, 3]);
    expect(hit?.tokens).toEqual([1, 2]);
    expect(cloneTrims).toEqual([1]);
  });

  test("untrimmable entry only matches in full", () => {
    const { pc } = mk();
    const d = { count: 0 };
    pc.put([1, 2, 3, 4, 5], [stubCache(10, d, false)]);

    expect(pc.take([1, 2, 3, 9])).toBeNull(); // would need a trim → skipped
    const hit = pc.take([1, 2, 3, 4, 5, 6]); // full prefix → fine
    expect(hit?.tokens).toEqual([1, 2, 3, 4, 5]);
  });

  test("byte cap evicts LRU, never the fresh insert", () => {
    const { pc } = mk(100);
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

  test("take bumps donor recency IN PLACE; extended put supersedes the ancestor", () => {
    const { pc } = mk(100);
    const d1 = { count: 0 }, d2 = { count: 0 }, d3 = { count: 0 };
    pc.put([1], [stubCache(40, d1)]);
    pc.put([2], [stubCache(40, d2)]);
    const e = pc.take([1, 99]); // hit on [1] → donor becomes MRU
    pc.put([1, 99], e!.caches); // extended entry SUPERSEDES donor [1]
    expect(d1.count).toBe(1); // ancestor disposed by supersede
    pc.put([3], [stubCache(40, d3)]); // over cap → evicts [2], the true LRU
    expect(d2.count).toBe(1);
  });

  test("supersede only fires for trimmable new entries (boundary snapshots survive)", () => {
    const { pc } = mk();
    const dB = { count: 0 }, dE = { count: 0 };
    pc.put([1, 2, 3], [stubCache(10, dB, true)]); // boundary snapshot (prompt-only)
    pc.put([1, 2, 3, 4, 5], [stubCache(10, dE, false)]); // UNTRIMMABLE extended entry
    expect(pc.size).toBe(2); // ancestor survives — it's the only drift-proof server
    expect(dB.count).toBe(0);

    pc.put([1, 2, 3, 4, 5, 6], [stubCache(10, dE, true)]); // trimmable extension
    expect(dB.count).toBe(1); // now redundant → superseded
  });

  test("supersede never crosses namespaces", () => {
    const { pc } = mk();
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)], "nsA");
    pc.put([1, 2, 3], [stubCache(10, d)], "nsB");
    expect(pc.size).toBe(2);
    expect(d.count).toBe(0);
  });

  test("entry larger than the cap is disposed, not stored", () => {
    const { pc } = mk(100);
    const d = { count: 0 };
    pc.put([1], [stubCache(500, d)]);
    expect(d.count).toBe(1);
    expect(pc.size).toBe(0);
  });

  test("clear disposes everything", () => {
    const { pc } = mk();
    const d = { count: 0 };
    pc.put([1], [stubCache(10, d)]);
    pc.put([2], [stubCache(10, d)]);
    pc.clear();
    expect(d.count).toBe(2);
    expect(pc.size).toBe(0);
  });
});

describe("PromptCache — prefix sharing", () => {
  test("one donor serves many agents: repeated takes all clone, donor persists", () => {
    const { pc, cloneTrims, cloneDisposed } = mk();
    const d = { count: 0 };
    pc.put([1, 2, 3, 4], [stubCache(10, d)]); // the shared system prefix (via any conversation)

    const a = pc.take([1, 2, 3, 4, 100]);
    const b = pc.take([1, 2, 3, 4, 200]);
    const c = pc.take([1, 2, 3, 4, 300]);
    for (const hit of [a, b, c]) expect(hit?.tokens).toEqual([1, 2, 3, 4]);
    expect(pc.size).toBe(1);
    expect(d.count).toBe(0); // donor alive throughout
    expect(cloneTrims).toEqual([]); // full-prefix serves
    // each agent owns its clone independently
    for (const hit of [a, b, c]) for (const cc of hit!.caches) cc.dispose();
    expect(cloneDisposed.count).toBe(3);
    expect(d.count).toBe(0);
  });

  test("ref-counted retain: unmap runs only after donor AND all clones release", () => {
    const { pc } = mk();
    const d = { count: 0 };
    let unmapped = 0;
    pc.put([1, 2, 3], [stubCache(10, d)], "", () => { unmapped++; });

    const clone1 = pc.take([1, 2, 3, 9]);
    const clone2 = pc.take([1, 2, 3, 8]);
    pc.clear(); // donor disposed + its share released
    expect(unmapped).toBe(0); // clones still hold shares
    clone1!.retain!();
    expect(unmapped).toBe(0);
    clone2!.retain!();
    expect(unmapped).toBe(1); // last holder out → unmap, exactly once
    clone2!.retain!(); // double-release is idempotent
    expect(unmapped).toBe(1);
  });

  test("retain flows through put(extended, clone.retain) without early unmap", () => {
    const { pc } = mk();
    const d = { count: 0 };
    let unmapped = 0;
    pc.put([1, 2], [stubCache(10, d)], "", () => { unmapped++; });

    const hit = pc.take([1, 2, 9]); // clone holds a share of the donor's unmap
    // conversation finishes; extended entry carries the clone's release —
    // and supersedes the donor (trimmable), releasing the donor's share.
    pc.put([1, 2, 9, 10], hit!.caches, "", hit!.retain);
    expect(unmapped).toBe(0); // extended entry still holds the last share
    pc.clear();
    expect(unmapped).toBe(1);
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

const mkTiered = (cold: ReturnType<typeof fakeCold>, maxBytes = 1e9) => {
  const cloneTrims: number[] = [];
  const cloneDisposed = { count: 0 };
  const pc = new PromptCache(maxBytes, null, cold.tier, stubClone(cloneTrims, cloneDisposed));
  return { pc, cloneTrims, cloneDisposed };
};

describe("PromptCache — Layer 0 tiering", () => {
  test("cold tier wins with a strictly longer prefix; RAM donor untouched", () => {
    const cold = fakeCold();
    const { pc } = mkTiered(cold);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4], [], "");

    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]); // the cold entry
    expect(cold.restores.count).toBe(1);
    expect(pc.size).toBe(1);
    expect(hit?.retain).toBeDefined();
  });

  test("tie (equal prefix) goes to RAM — the restore is not free", () => {
    const cold = fakeCold();
    const { pc } = mkTiered(cold);
    const d = { count: 0 };
    pc.put([1, 2, 3], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3], [], "");

    const hit = pc.take([1, 2, 3, 9]);
    expect(cold.restores.count).toBe(0);
    expect(hit?.tokens).toEqual([1, 2, 3]);
    expect(pc.size).toBe(1); // non-consuming serve
  });

  test("cold entry with an untrimmable divergent tail falls back to RAM", () => {
    const cold = fakeCold(false); // restored caches refuse trim
    const { pc } = mkTiered(cold);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4, 9, 9], [], ""); // diverges at [4]: needs trim

    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2]); // RAM served (a clone)
    expect(cold.disposed.count).toBe(1); // restored caches dropped
    expect(cold.retained.count).toBe(1); // unmap ran after dispose
  });

  test("cold entry trims a divergent tail when trimmable", () => {
    const cold = fakeCold(true);
    const { pc } = mkTiered(cold);
    cold.tier.store([1, 2, 3, 4, 9, 9], [], "");
    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2, 3, 4]);
    expect(cold.trims).toEqual([2]); // dropped the [9, 9] tail
  });

  test("restore failure degrades to the RAM candidate", () => {
    const cold = fakeCold();
    const { pc } = mkTiered(cold);
    const d = { count: 0 };
    pc.put([1, 2], [stubCache(10, d)]);
    cold.tier.store([1, 2, 3, 4], [], "");
    cold.setFailRestore(true);
    const hit = pc.take([1, 2, 3, 4, 5]);
    expect(hit?.tokens).toEqual([1, 2]);
  });

  test("demoteIdle spills idle entries to the cold tier, frees GPU, and take() restores them", () => {
    const cold = fakeCold();
    const { pc } = mkTiered(cold);
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

  test("demoteIdle skips donors with recent takes (recency bumps in place)", () => {
    const cold = fakeCold();
    const { pc } = mkTiered(cold);
    const d = { count: 0 };
    const t0 = Date.now();
    pc.put([1, 2, 3], [stubCache(10, d)]);
    pc.take([1, 2, 3, 9]); // bumps lastUsedMs to ~now
    expect(pc.demoteIdle(60_000, t0 + 30_000)).toBe(0);
  });

  test("demoteIdle without a cold tier is a no-op (never data loss)", () => {
    const { pc } = mk();
    const d = { count: 0 };
    pc.put([1], [stubCache(10, d)]);
    expect(pc.demoteIdle(0)).toBe(0);
    expect(pc.size).toBe(1);
    expect(d.count).toBe(0);
  });

  // The oracle invariant (2026-07-06 gemma cache fixes): a trim-free
  // STRICT-PREFIX entry is the only reuse path an untrimmable (wrapped
  // ring) model has — an exact repeat must hit it with zero trims.
  test("untrimmable strict-prefix entry serves an exact repeat without trims", () => {
    const { pc, cloneTrims } = mk();
    const d = { count: 0 };
    const prompt = Array.from({ length: 600 }, (_, i) => i);
    // the boundary snapshot: prompt[:-1], untrimmable (rings already wrapped)
    pc.put(prompt.slice(0, 599), [stubCache(10, d, false)]);
    const hit = pc.take(prompt); // exact repeat of the full prompt
    expect(hit?.tokens).toHaveLength(599); // prompt.length-1 — no trim needed
    expect(cloneTrims).toEqual([]);
    expect(pc.size).toBe(1);
  });

  test("exact-duplicate put replaces the old entry even when untrimmable", () => {
    const { pc } = mk();
    const d1 = { count: 0 };
    const d2 = { count: 0 };
    pc.put([1, 2, 3], [stubCache(10, d1, false)]);
    pc.put([1, 2, 3], [stubCache(10, d2, false)]); // same tokens, wrapped rings
    expect(pc.size).toBe(1); // no duplicate accumulation (12B ctx-repeat leak)
    expect(d1.count).toBe(1);
    expect(d2.count).toBe(0);
  });

  test("untrimmable longer put leaves the boundary snapshot in place", () => {
    const { pc } = mk();
    const d = { count: 0 };
    pc.put([1, 2, 3, 4], [stubCache(10, d, true)]); // boundary (prompt-only)
    pc.put([1, 2, 3, 4, 5, 6], [stubCache(10, d, false)]); // [prompt+gen], wrapped
    expect(pc.size).toBe(2); // ancestor survives — it is the only reusable form
    expect(d.count).toBe(0);
  });

  test("onPut fires per put with tokens+ns; its exceptions are contained", () => {
    const { pc } = mk();
    const d = { count: 0 };
    const puts: Array<[number[], string]> = [];
    pc.onPut = (tokens, ns) => { puts.push([tokens, ns]); throw new Error("boom"); };
    pc.put([1, 2], [stubCache(10, d)], "nsA");
    expect(puts).toEqual([[[1, 2], "nsA"]]);
    expect(pc.size).toBe(1); // the throw did not unwind the put
  });
});
