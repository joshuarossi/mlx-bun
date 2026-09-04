// SsdCacheStore unit tests — no model weights needed (hand-built KVCaches).
// Covers the ssd-kv-cold-tier P2 exit criteria: restart recovery, corrupt
// deletion, fingerprint quarantine, cap eviction by mtime, supersede,
// find() prefix semantics.

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, readdirSync, openSync, writeSync, closeSync, utimesSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const { SsdCacheStore } = await import("../../src/ssd-cache");
const { KVCache } = await import("../../src/model/gemma4-base");
const { Dtype } = await import("../../src/mlx/ffi");
const ops = await import("../../src/mlx/ops");

const { RotatingKVCache } = await import("../../src/model/gemma4-base");

/** A WRAPPED ring (offset past the window): untrimmable by the mlx-lm rule. */
const mkWrappedCaches = (window = 4, offset = 8) => {
  const mk = () => {
    const c = new RotatingKVCache(window);
    c.restoreState(
      ops.zeros([1, 2, window, 8], Dtype.bfloat16),
      ops.zeros([1, 2, window, 8], Dtype.bfloat16),
      offset, 0,
    );
    return c;
  };
  return [mk(), mk()];
};

const mkCaches = (offset = 4) => {
  const mk = () => {
    const c = new KVCache();
    c.restoreState(
      ops.zeros([1, 2, offset, 8], Dtype.bfloat16),
      ops.zeros([1, 2, offset, 8], Dtype.bfloat16),
      offset,
    );
    return c;
  };
  return [mk(), mk()];
};
const model = { makeCache: () => mkCaches(0) };
const OPTS = (dir: string, maxBytes = 64 * 1024 * 1024) => ({
  dir, maxBytes, configFingerprint: "fp-test", tokenizerHash: "tk-test", modelId: "stub",
});

describe("SsdCacheStore", () => {
  test("store → scan (restart) → find → restore round-trip", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s1 = new SsdCacheStore(OPTS(dir));
    const caches = mkCaches();
    expect(s1.store([1, 2, 3, 4], caches)).toBe(true);
    expect(s1.hasDurablePrefix([1, 2, 3, 4])).toBe(true);
    expect(s1.hasDurablePrefix([1, 2, 3, 4, 5])).toBe(false);
    for (const c of caches) c.dispose();

    // "restart": a fresh store over the same dir must recover the entry
    const s2 = new SsdCacheStore(OPTS(dir));
    expect(s2.scan()).toBe(1);
    const hit = s2.find([1, 2, 3, 4, 9, 9], "");
    expect(hit?.entry.tokens).toEqual([1, 2, 3, 4]);
    expect(hit?.prefixLen).toBe(4);
    const loaded = s2.restore(hit!.entry, model);
    expect(loaded).not.toBeNull();
    expect(loaded!.tokens).toEqual([1, 2, 3, 4]);
    expect(loaded!.caches).toHaveLength(2);
    for (const c of loaded!.caches) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  });

  test("in-flight generation checkpoint survives scan and is isolated from prompt lookup", async () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-resume-"));
    try {
      const prompt = [1, 2, 3];
      const tokens = [...prompt, 7, 8];
      const caches = mkCaches(tokens.length);
      expect(await new SsdCacheStore(OPTS(dir)).storeGenerationCheckpoint(
        tokens,
        caches,
        {
          key: "request-a",
          cacheNs: "",
          originalPromptTokens: prompt.length,
          generatedTokens: 2,
          pendingToken: 9,
          seed: 42,
          seedWasExplicit: false,
        },
      )).toBe(true);
      for (const cache of caches) cache.dispose();

      const restarted = new SsdCacheStore(OPTS(dir));
      expect(restarted.scan()).toBe(1);
      expect(restarted.find([...tokens, 10], "")).toBeNull();
      const hit = restarted.findGenerationCheckpoint(prompt, "request-a");
      expect(hit?.generationCheckpoint).toMatchObject({
        generatedTokens: 2,
        pendingToken: 9,
        seed: 42,
        seedWasExplicit: false,
      });
      const loaded = restarted.restore(hit!, model);
      expect(loaded?.tokens).toEqual(tokens);
      for (const cache of loaded!.caches) cache.dispose();
      restarted.removeGenerationCheckpoints("request-a");
      expect(restarted.entries).toBe(0);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });

  test("find: longest usable prefix, ns isolation, no partial-entry hits", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    // note the order: storing [1,2] AFTER [1,2,3,4] — the other way round
    // the supersede rule would (correctly) replace the shorter ancestor
    for (const [toks, ns] of [
      [[1, 2, 3, 4], ""], [[1, 2], ""], [[1, 2, 3, 4], "lora-a"],
    ] as const) {
      const c = mkCaches(toks.length);
      s.store([...toks], c, ns);
      for (const x of c) x.dispose();
    }
    expect(s.find([1, 2, 3, 4, 5], "")?.entry.tokens).toEqual([1, 2, 3, 4]); // longest wins
    expect(s.find([1, 2, 3, 4, 5], "")?.prefixLen).toBe(4);
    // diverging tail: the longer entry still wins (prefixLen 2 < entry.len 4
    // → the caller trims after restore); both entries match p=2, ties keep first
    const div = s.find([1, 2, 9], "");
    expect(div?.prefixLen).toBe(2);
    expect(s.find([1, 2, 3, 4], "lora-b")).toBeNull(); // ns isolation
    // prompt == entry exactly: prefix caps at prompt.length−1 (one token
    // must forward) → partial hit with prefixLen 1
    expect(s.find([1, 2], "")?.prefixLen).toBe(1);
    rmSync(dir, { recursive: true, force: true });
  });

  test("corrupt file is unlinked on scan; foreign fingerprint dir untouched", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s1 = new SsdCacheStore(OPTS(dir));
    const c1 = mkCaches();
    s1.store([1, 2, 3, 4], c1);
    for (const c of c1) c.dispose();
    // corrupt the stored file's header region
    const nsDir = join(dir, "fp-test", "base");
    const file = readdirSync(nsDir).find((f) => f.endsWith(".mlxkv"))!;
    const fd = openSync(join(nsDir, file), "r+");
    writeSync(fd, new Uint8Array([0x00]), 0, 1, 25);
    closeSync(fd);
    // plant a foreign-fingerprint file (another model's cache — never touch)
    const foreignDir = join(dir, "fp-OTHER", "base");
    const s3 = new SsdCacheStore({ ...OPTS(dir), configFingerprint: "fp-OTHER" });
    const c2 = mkCaches();
    s3.store([7, 7], c2);
    for (const c of c2) c.dispose();

    const s2 = new SsdCacheStore(OPTS(dir));
    expect(s2.scan()).toBe(0); // corrupt entry reaped
    expect(readdirSync(nsDir).filter((f) => f.endsWith(".mlxkv"))).toEqual([]);
    expect(readdirSync(foreignDir).length).toBe(1); // foreign dir untouched
    rmSync(dir, { recursive: true, force: true });
  });

  test("byte cap evicts oldest mtime; supersede replaces prefix ancestors", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    // grow one conversation: [1..4] then [1..4,5,6] — the ancestor is superseded
    const a = mkCaches(4);
    s.store([1, 2, 3, 4], a);
    for (const c of a) c.dispose();
    const b = mkCaches(6);
    s.store([1, 2, 3, 4, 5, 6], b);
    for (const c of b) c.dispose();
    expect(s.entries).toBe(1);
    expect(s.find([1, 2, 3, 4, 5, 6, 7], "")?.entry.tokens).toEqual([1, 2, 3, 4, 5, 6]);

    // unrelated entry + tiny cap → oldest mtime goes first
    const c3 = mkCaches(4);
    s.store([9, 8, 7, 6], c3);
    for (const c of c3) c.dispose();
    expect(s.entries).toBe(2);
    // age the first entry, then squeeze the cap via a store on a small store
    const first = s.find([1, 2, 3, 4, 5, 6, 7], "")!.entry;
    utimesSync(first.path, new Date(Date.now() - 1e7), new Date(Date.now() - 1e7));
    first.mtimeMs = Date.now() - 1e7;
    const tiny = new SsdCacheStore({ ...OPTS(dir), maxBytes: s.totalBytes - 1 });
    tiny.scan();
    tiny.evictToCap();
    expect(tiny.entries).toBe(1);
    expect(existsSync(first.path)).toBe(false); // oldest evicted
    rmSync(dir, { recursive: true, force: true });
  });

  test("oversized entry refused; scan reaps .tmp orphans", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore({ ...OPTS(dir), maxBytes: 64 }); // absurdly small
    const c = mkCaches();
    expect(s.store([1, 2, 3, 4], c)).toBe(false);
    for (const x of c) x.dispose();
    expect(s.entries).toBe(0);

    // orphan .tmp (crash mid-write simulation) is reaped by scan
    const nsDir = join(dir, "fp-test", "base");
    const { mkdirSync, writeFileSync } = require("node:fs");
    mkdirSync(nsDir, { recursive: true });
    writeFileSync(join(nsDir, "orphan.mlxkv.tmp"), "junk");
    s.scan();
    expect(readdirSync(nsDir)).toEqual([]);
    rmSync(dir, { recursive: true, force: true });
  });

  // 2026-07-06 restart-survival fixes: the untrimmable [prompt+gen] entry
  // must neither delete nor outrank the boundary snapshot — the only file
  // a wrapped-ring model can actually restore from.
  test("untrimmable longer store leaves the boundary snapshot; find prefers the usable file", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    const boundary = mkCaches(4); // trimmable prompt-only snapshot [1,2,3,4]
    expect(s.store([1, 2, 3, 4], boundary)).toBe(true);
    for (const c of boundary) c.dispose();
    const wrapped = mkWrappedCaches(); // [prompt+gen], rings wrapped
    expect(s.store([1, 2, 3, 4, 5, 6], wrapped)).toBe(true);
    for (const c of wrapped) c.dispose();
    expect(s.entries).toBe(2); // ancestor SURVIVED the untrimmable supersede

    // Exact prompt replay [1,2,3,4,5]: the wrapped file matches 4 tokens but
    // needs a 2-token trim it cannot do — find must return the boundary file.
    const hit = s.find([1, 2, 3, 4, 5], "");
    expect(hit?.entry.tokens).toEqual([1, 2, 3, 4]);
    expect(hit?.prefixLen).toBe(4);

    // ...and the usability flag survives a restart scan (header-derived).
    const s2 = new SsdCacheStore(OPTS(dir));
    expect(s2.scan()).toBe(2);
    const hit2 = s2.find([1, 2, 3, 4, 5], "");
    expect(hit2?.entry.tokens).toEqual([1, 2, 3, 4]);
    rmSync(dir, { recursive: true, force: true });
  });

  // headerTrimmable() is a closed switch over the on-disk kind string; when
  // "turboquant" was missing it fell through to false, so a restart scan()
  // misclassified every TurboQuant entry as untrimmable and find() skipped
  // partial-prefix hits — silently forfeiting restart survival for exactly
  // that scheme (2026-07-06 integration review).
  test("turboquant entry stays trimmable across a restart scan", async () => {
    const { TurboQuantKVCache } = await import("../../src/model/gemma4-base");
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s1 = new SsdCacheStore(OPTS(dir));
    const mkTq = () => {
      const c = new TurboQuantKVCache(8, 3);
      const key = ops.randomKey(7n);
      const k = ops.randomNormal([1, 2, 4, 64], Dtype.bfloat16, 0, 1, key);
      const v = ops.randomNormal([1, 2, 4, 64], Dtype.bfloat16, 0, 1, key);
      const [fk, fv] = c.updateAndFetch(k, v);
      for (const a of [key, k, v, fk, fv]) a.dispose();
      return c;
    };
    const caches = [mkTq()];
    expect(s1.store([1, 2, 3, 4], caches)).toBe(true);
    for (const c of caches) c.dispose();

    // live index: diverging tail needs a 1-token trim → only served if trimmable
    expect(s1.find([1, 2, 3, 9], "")?.prefixLen).toBe(3);

    // restart: the header-derived flag must agree with the live isTrimmable()
    const s2 = new SsdCacheStore(OPTS(dir));
    expect(s2.scan()).toBe(1);
    const hit = s2.find([1, 2, 3, 9], "");
    expect(hit?.prefixLen).toBe(3);
    const tqModel = { makeCache: () => [new TurboQuantKVCache(8, 3)] };
    const loaded = s2.restore(hit!.entry, tqModel);
    expect(loaded).not.toBeNull();
    for (const c of loaded!.caches) c.dispose();
    rmSync(dir, { recursive: true, force: true });
  });

  test("GLM compressed entry stays trimmable across a restart scan", async () => {
    const { MLACache } = await import("../../src/model/glm52-cache");
    const dir = mkdtempSync(join(tmpdir(), "ssd-glm-"));
    const make = () => new MLACache({
      kvLoraRank: 2,
      ropeHeadDim: 1,
      dsa: { headDim: 2 },
      maxTokens: 16,
    });
    const cache = make();
    cache.restoreCompressedState(
      ops.zeros([1, 4, 2], Dtype.float32),
      ops.zeros([1, 4, 1], Dtype.float32),
      ops.zeros([1, 4, 2], Dtype.float32),
      4,
    );
    const s1 = new SsdCacheStore(OPTS(dir));
    expect(s1.store([1, 2, 3, 4], [cache])).toBe(true);
    cache.dispose();
    expect(s1.find([1, 2, 3, 9], "")?.prefixLen).toBe(3);

    const s2 = new SsdCacheStore(OPTS(dir));
    expect(s2.scan()).toBe(1);
    const hit = s2.find([1, 2, 3, 9], "");
    expect(hit?.prefixLen).toBe(3);
    const loaded = s2.restore(hit!.entry, { makeCache: () => [make()] });
    expect(loaded?.caches[0]).toBeInstanceOf(MLACache);
    for (const restored of loaded?.caches ?? []) restored.dispose();
    rmSync(dir, { recursive: true, force: true });
  });

  test("exact-duplicate store replaces the file regardless of trimmability", () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    const a = mkWrappedCaches();
    expect(s.store([7, 8, 9], a)).toBe(true);
    for (const c of a) c.dispose();
    const b = mkWrappedCaches();
    expect(s.store([7, 8, 9], b)).toBe(true);
    for (const c of b) c.dispose();
    expect(s.entries).toBe(1);
    rmSync(dir, { recursive: true, force: true });
  });

  // The 2026-07-07 decode@ctx fix: storeAsync's flush must gate EVERY
  // per-tensor step (including the first) on the caller's waitTurn — a
  // flush step is a blocking GPU sync + writeSync, and ungated steps
  // interleaved with active decodes (the bench's contaminated ctx repeats).
  test("storeAsync awaits waitTurn before every tensor step and still stores", async () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    const caches = mkCaches(); // 2 caches × [k, v] = 4 tensor steps
    let gateCalls = 0;
    let gateOpen = false;
    const waitTurn = async (): Promise<void> => {
      gateCalls++;
      // the first call happens BEFORE any bytes hit disk (the .tmp is only
      // opened inside the first step) — hold the gate one macrotask and
      // verify nothing was written while it was shut
      if (gateCalls === 1) {
        expect(readdirSync(join(dir, "fp-test", "base")).length).toBe(0);
        await new Promise<void>((r) => setTimeout(r, 5));
        gateOpen = true;
      }
      expect(gateOpen).toBe(true);
    };
    expect(await s.storeAsync([1, 2, 3, 4], caches, "", waitTurn)).toBe(true);
    // 4 yields → 5 next() calls, each preceded by the gate
    expect(gateCalls).toBe(5);
    for (const c of caches) c.dispose();
    expect(s.entries).toBe(1);
    rmSync(dir, { recursive: true, force: true });
  });

  test("a throwing waitTurn is swallowed — the flush completes ungated", async () => {
    const dir = mkdtempSync(join(tmpdir(), "ssd-"));
    const s = new SsdCacheStore(OPTS(dir));
    const caches = mkCaches();
    const bad = (): Promise<void> => Promise.reject(new Error("gate broke"));
    expect(await s.storeAsync([1, 2, 3], caches, "", bad)).toBe(true);
    for (const c of caches) c.dispose();
    expect(s.entries).toBe(1);
    rmSync(dir, { recursive: true, force: true });
  });
});

// ---------------------------------------------------------------------------
// SpillQueue — the bounded write-behind queue (2026-07-07 review fix: the
// bare promise chain retained GPU-pinning clones without bound while the
// idle gate starved under sustained traffic). Model-free: byte sizing and
// disposal are injected, so fakes suffice.
// ---------------------------------------------------------------------------

const { SpillQueue } = await import("../../src/kv-store");

type FakeCache = { nbytes: number; disposed: number; dispose(): void };
function fakeCaches(nbytes: number): FakeCache[] {
  const c: FakeCache = { nbytes, disposed: 0, dispose() { this.disposed++; } };
  return [c];
}
const bytesOf = (caches: unknown[]) =>
  (caches as FakeCache[]).reduce((s, c) => s + c.nbytes, 0);
const disposeAll = (caches: unknown[]) => {
  for (const c of caches as FakeCache[]) c.dispose();
};

function makeQueue(cap: number, storeImpl: (item: { ns: string }) => Promise<unknown>) {
  return new SpillQueue(
    cap,
    bytesOf as never,
    storeImpl as never,
    disposeAll as never,
  );
}

describe("SpillQueue", () => {
  test("flushes serially in enqueue order and disposes every clone exactly once", async () => {
    const stored: string[] = [];
    const q = makeQueue(1_000, async (item) => { stored.push(item.ns); });
    const a = fakeCaches(10), b = fakeCaches(10), c = fakeCaches(10);
    const results = [
      q.enqueue({ tokens: [1], caches: a as never, ns: "a" }),
      q.enqueue({ tokens: [2], caches: b as never, ns: "b" }),
      q.enqueue({ tokens: [3], caches: c as never, ns: "c" }),
    ];
    await q.drain();
    expect(await Promise.all(results)).toEqual([true, true, true]);
    expect(stored).toEqual(["a", "b", "c"]);
    for (const set of [a, b, c]) expect(set[0]!.disposed).toBe(1);
    expect(q.pendingCount).toBe(0);
    expect(q.pendingBytes).toBe(0);
    expect(q.droppedCount).toBe(0);
  });

  test("over cap drops the OLDEST queued (not in-flight, not newest) and disposes it immediately", async () => {
    let releaseFirst!: () => void;
    const gate = new Promise<void>((r) => { releaseFirst = r; });
    const stored: string[] = [];
    const q = makeQueue(100, async (item) => {
      if (stored.length === 0) await gate; // block the first (in-flight) store
      stored.push(item.ns);
    });
    const a = fakeCaches(60), b = fakeCaches(60), c = fakeCaches(60);
    const aResult = q.enqueue({ tokens: [1], caches: a as never, ns: "a" });
    // let a's store() actually START (blocked on the gate) — a queued-but-
    // not-started head is legitimately droppable; a mid-store one is not.
    await new Promise((r) => setTimeout(r, 0));
    const bResult = q.enqueue({ tokens: [2], caches: b as never, ns: "b" }); // 120 > 100, but only in-flight+newest → soft cap
    expect(q.droppedCount).toBe(0);
    const cResult = q.enqueue({ tokens: [3], caches: c as never, ns: "c" }); // 180 > 100 → drop b (oldest droppable)
    expect(q.droppedCount).toBe(1);
    expect(b[0]!.disposed).toBe(1); // disposed AT DROP TIME, before any flush
    expect(a[0]!.disposed).toBe(0); // in-flight never dropped
    releaseFirst();
    await q.drain();
    expect(await Promise.all([aResult, bResult, cResult])).toEqual([true, false, true]);
    expect(stored).toEqual(["a", "c"]); // b never stored
    expect(a[0]!.disposed).toBe(1);
    expect(c[0]!.disposed).toBe(1);
    expect(b[0]!.disposed).toBe(1); // exactly once — no double-dispose on its chain turn
    expect(q.pendingCount).toBe(0);
    expect(q.pendingBytes).toBe(0);
  });

  test("a single oversized item exceeds the cap rather than never spilling (soft cap)", async () => {
    const stored: string[] = [];
    const q = makeQueue(10, async (item) => { stored.push(item.ns); });
    const big = fakeCaches(50);
    q.enqueue({ tokens: [1], caches: big as never, ns: "big" });
    await q.drain();
    expect(stored).toEqual(["big"]);
    expect(q.droppedCount).toBe(0);
    expect(big[0]!.disposed).toBe(1);
  });

  test("a store failure disposes the clones and the queue keeps flushing", async () => {
    const stored: string[] = [];
    const q = makeQueue(1_000, async (item) => {
      if (item.ns === "boom") throw new Error("disk full");
      stored.push(item.ns);
    });
    const a = fakeCaches(10), b = fakeCaches(10);
    const failed = q.enqueue({ tokens: [1], caches: a as never, ns: "boom" });
    const storedOk = q.enqueue({ tokens: [2], caches: b as never, ns: "ok" });
    await q.drain();
    expect(await failed).toBe(false);
    expect(await storedOk).toBe(true);
    expect(q.failedCount).toBe(1);
    expect(stored).toEqual(["ok"]);
    expect(a[0]!.disposed).toBe(1);
    expect(b[0]!.disposed).toBe(1);
    expect(q.pendingBytes).toBe(0);
  });
});

// ---------------------------------------------------------------------------
// SsdDurabilityCoordinator: a dirty snapshot is not acknowledged until the
// queue's atomic store settles. This is the restart boundary used by the
// benchmark and graceful shutdown.
// ---------------------------------------------------------------------------

const { SsdDurabilityCoordinator } = await import("../../src/ssd-durability");

function durabilityFixture(
  entries: Array<{ tokens: number[]; ns?: string }> = [{ tokens: [1, 2, 3] }],
  storeImpl?: (item: { tokens: number[]; ns: string }) => Promise<unknown>,
  isAlreadyDurable: (tokens: number[], ns: string) => boolean = () => false,
) {
  const source = fakeCaches(10);
  const promptCache = {
    findExact(tokens: number[], ns = "") {
      const hit = entries.find((e) =>
        (e.ns ?? "") === ns && e.tokens.length === tokens.length &&
        e.tokens.every((token, i) => token === tokens[i]));
      return hit ? { tokens: [...hit.tokens], caches: source as never, ns } : null;
    },
  };
  const gateway = {
    busy: false,
    async runExclusive<T>(fn: () => Promise<T>): Promise<T> { return fn(); },
  };
  const stored: string[] = [];
  const queue = makeQueue(1_000, async (item) => {
    stored.push(`${item.ns}:${(item as unknown as { tokens: number[] }).tokens.join(",")}`);
    return storeImpl?.(item as unknown as { tokens: number[]; ns: string });
  });
  const coordinator = new SsdDurabilityCoordinator(
    gateway,
    promptCache as never,
    queue,
    (() => fakeCaches(10) as never) as never,
    isAlreadyDurable,
    1,
    60_000,
  );
  return { coordinator, gateway, queue, stored };
}

describe("SsdDurabilityCoordinator", () => {
  test("flush overrides a busy retry and waits for the atomic store", async () => {
    let release!: () => void;
    const gate = new Promise<void>((resolve) => { release = resolve; });
    const f = durabilityFixture(undefined, async () => { await gate; return true; });
    f.gateway.busy = true;
    f.coordinator.schedule([1, 2, 3]);
    await Bun.sleep(5);
    expect(f.coordinator.stats.pendingSnapshots).toBe(1);
    expect(f.stored).toEqual([]);

    f.gateway.busy = false;
    const flush = f.coordinator.flush();
    expect(f.coordinator.flush()).toBe(flush);
    await Bun.sleep(0);
    expect(f.coordinator.stats.pendingSpills).toBe(1);
    let settled = false;
    void flush.then(() => { settled = true; });
    await Bun.sleep(0);
    expect(settled).toBe(false);

    release();
    const result = await flush;
    expect(result.durable).toBe(true);
    expect(result.flushedSnapshots).toBe(1);
    expect(result.pendingSnapshots).toBe(0);
    expect(result.pendingSpills).toBe(0);
    expect(f.stored).toEqual([":1,2,3"]);
  });

  test("equal-length prompts keep separate durability records", async () => {
    const f = durabilityFixture([{ tokens: [1, 2] }, { tokens: [3, 4] }]);
    f.coordinator.schedule([1, 2]);
    f.coordinator.schedule([3, 4]);
    expect(f.coordinator.stats.pendingSnapshots).toBe(2);
    const result = await f.coordinator.flush();
    expect(result.durable).toBe(true);
    expect(result.flushedSnapshots).toBe(2);
    expect(f.stored).toEqual([":1,2", ":3,4"]);
  });

  test("a failed store remains dirty and a later flush retries it", async () => {
    let attempts = 0;
    const f = durabilityFixture(undefined, async () => ++attempts > 1);
    f.coordinator.schedule([1, 2, 3]);
    const first = await f.coordinator.flush();
    expect(first.durable).toBe(false);
    expect(first.pendingSnapshots).toBe(1);
    expect(first.failedSpills).toBe(1);

    const second = await f.coordinator.flush();
    expect(second.durable).toBe(true);
    expect(second.pendingSnapshots).toBe(0);
    expect(attempts).toBe(2);
  });

  test("reports a boundary snapshot that vanished from RAM", async () => {
    const f = durabilityFixture([]);
    f.coordinator.schedule([9, 9]);
    const result = await f.coordinator.flush();
    expect(result.durable).toBe(false);
    expect(result.missingSnapshots).toBe(1);
    expect(result.pendingSnapshots).toBe(0);
  });

  test("accepts a vanished RAM snapshot when SSD already covers its prefix", async () => {
    const f = durabilityFixture([], undefined, () => true);
    f.coordinator.schedule([9, 9]);
    const result = await f.coordinator.flush();
    expect(result.durable).toBe(true);
    expect(result.missingSnapshots).toBe(0);
    expect(result.pendingSnapshots).toBe(0);
  });
});

// ---------------------------------------------------------------------------
// loadKvCache verify-failure leak regression (2026-07-07 review): a hash
// mismatch on an entry's SECOND tensor used to orphan the first tensor
// (already materialized + grown to step capacity) — the catch only saw
// completed caches. The pending[] drain must free mid-entry orphans, so
// repeated corrupt-file loads must not grow active memory.
// ---------------------------------------------------------------------------

describe("loadKvCache — verify-failure drains mid-entry tensors", () => {
  test("repeated hash-mismatch loads do not grow active memory", async () => {
    const { saveKvCache, loadKvCache, readKvHeader } = await import("../../src/kv-store");
    const { activeMemory } = await import("../../src/mlx/ffi");
    const { readSync } = await import("node:fs");
    const dir = mkdtempSync(join(tmpdir(), "kv-verify-"));
    try {
      const S = 4096, D = 64; // ~1 MB per tensor — a leak is unmistakable
      const mkBig = () => {
        const c = new KVCache();
        c.restoreState(
          ops.zeros([1, 2, S, D], Dtype.bfloat16),
          ops.zeros([1, 2, S, D], Dtype.bfloat16),
          S,
        );
        return c;
      };
      const caches = [mkBig(), mkBig()];
      const path = join(dir, "entry.kv");
      saveKvCache(path, [1, 2, 3], caches, {});
      for (const c of caches) c.dispose();

      // Flip one byte inside the FIRST entry's SECOND tensor: tensor 0
      // materializes (and grows) before the mismatch throws.
      const header = readKvHeader(path);
      const slot = header.caches[0]!.tensors[1]!;
      const at = header.dataStart + slot.off + 8;
      const fd = openSync(path, "r+");
      const buf = new Uint8Array(1);
      readSync(fd, buf, 0, 1, at);
      buf[0] = buf[0]! ^ 0xff;
      writeSync(fd, buf, 0, 1, at);
      closeSync(fd);

      const bigModel = { makeCache: () => [mkBig(), mkBig()] };
      expect(() => loadKvCache(path, bigModel, { verify: true })).toThrow(/hash mismatch/);

      const before = activeMemory();
      for (let i = 0; i < 10; i++) {
        expect(() => loadKvCache(path, bigModel, { verify: true })).toThrow(/hash mismatch/);
      }
      // Pre-fix this leaked the ~1.1 MB grown tensor per load (11+ MB over
      // the loop); post-fix growth is pool slack only.
      expect(activeMemory() - before).toBeLessThan(8_000_000);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });
});
