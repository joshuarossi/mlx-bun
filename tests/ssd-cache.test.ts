// SsdCacheStore unit tests — no model weights needed (hand-built KVCaches).
// Covers the ssd-kv-cold-tier P2 exit criteria: restart recovery, corrupt
// deletion, fingerprint quarantine, cap eviction by mtime, supersede,
// find() prefix semantics.

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, readdirSync, openSync, writeSync, closeSync, utimesSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const { SsdCacheStore } = await import("../src/ssd-cache");
const { KVCache } = await import("../src/model/gemma4-base");
const { Dtype } = await import("../src/mlx/ffi");
const ops = await import("../src/mlx/ops");

const { RotatingKVCache } = await import("../src/model/gemma4-base");

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
