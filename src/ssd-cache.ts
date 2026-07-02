// SSD cold tier for the prompt/KV cache (docs/design/ssd-kv-cold-tier.md).
//
// Files ARE the database: no sidecar index. Layout
//   <dir>/<configFingerprint>/<nsHash>/<uuid>.mlxkv
// so two models (or two kv-quant schemes of one model) share a directory
// without ever colliding, and an incompatible fingerprint dir is simply
// ignored (never deleted — it may belong to the user's other model).
// Startup recovery = a header-only scan of OUR fingerprint dir: header hash
// verified (cheap), corrupt or metadata-mismatched files unlinked, `.tmp`
// write orphans reaped. LRU state = file mtime (bumped on hit); the byte
// cap is enforced at write time by oldest-mtime eviction. A cache is always
// droppable: every failure path degrades to "no hit" or "not stored" — the
// tier must never take serving down (oMLX paged_ssd_cache lesson, Apache-2.0
// idea port; ours spills whole prefix entries, not content-hashed blocks —
// see the design doc's D1 for why).

import {
  existsSync, mkdirSync, readdirSync, rmSync, statSync, utimesSync,
} from "node:fs";
import { join } from "node:path";
import { randomUUID } from "node:crypto";
import { commonPrefixLength } from "./prompt-cache";
import {
  saveKvCache, loadKvCache, readKvHeader,
  type KvSaveMeta, type KvLoadExpect, type LoadedKvCache,
} from "./kv-store";
import type { Cache } from "./model/gemma4-base";

export interface SsdIndexEntry {
  path: string;
  ns: string;
  tokens: number[];
  bytes: number;
  mtimeMs: number;
}

export interface SsdStoreOptions {
  dir: string;
  maxBytes: number;
  /** Server identity — written into every file, enforced on scan/load. */
  configFingerprint: string;
  tokenizerHash: string;
  modelId: string;
  /** Verify every tensor hash on load (--ssd-cache-verify). */
  verify?: boolean;
}

const nsHash = (ns: string): string =>
  ns === "" ? "base" : Bun.hash(ns).toString(16);

export class SsdCacheStore {
  readonly #opts: SsdStoreOptions;
  readonly #root: string; // <dir>/<configFingerprint>
  #index: SsdIndexEntry[] = [];
  #warnedWriteFailure = false;
  stats = { restores: 0, spills: 0, restoreMsLast: 0 };

  constructor(opts: SsdStoreOptions) {
    this.#opts = opts;
    this.#root = join(opts.dir, opts.configFingerprint);
  }

  get entries(): number {
    return this.#index.length;
  }

  get totalBytes(): number {
    return this.#index.reduce((a, e) => a + e.bytes, 0);
  }

  get maxBytes(): number {
    return this.#opts.maxBytes;
  }

  /** Startup recovery: rebuild the in-memory index from disk. Corrupt
   *  headers and metadata mismatches are unlinked; `.tmp` orphans reaped.
   *  Only OUR fingerprint dir is touched. Returns entries indexed. */
  scan(): number {
    this.#index = [];
    if (!existsSync(this.#root)) return 0;
    for (const nsDir of readdirSync(this.#root)) {
      const nsPath = join(this.#root, nsDir);
      let files: string[];
      try { files = readdirSync(nsPath); } catch { continue; }
      for (const f of files) {
        const path = join(nsPath, f);
        if (f.endsWith(".tmp")) {
          // A crash mid-write: the rename never happened. Ours by
          // construction (uuid names), safe to reap.
          try { rmSync(path, { force: true }); } catch {}
          continue;
        }
        if (!f.endsWith(".mlxkv")) continue;
        try {
          const h = readKvHeader(path); // verifies the header hash
          if (
            h.configFingerprint !== this.#opts.configFingerprint ||
            h.tokenizerHash !== this.#opts.tokenizerHash
          )
            throw new Error("metadata mismatch");
          const st = statSync(path);
          this.#index.push({
            path, ns: h.ns ?? "", tokens: h.tokens, bytes: st.size, mtimeMs: st.mtimeMs,
          });
        } catch {
          try { rmSync(path, { force: true }); } catch {}
        }
      }
    }
    return this.#index.length;
  }

  /** Best stored entry for `prompt` in `ns`: the longest common prefix
   *  (capped at prompt.length−1 — at least one token must forward). An
   *  entry LONGER than the matched prefix is still returned (the divergent-
   *  tail pattern: same long context, different question) — the caller
   *  trims after restore when every cache kind is trimmable, and falls
   *  back to a fresh prefill when not (ring post-wrap, SSM). Pure index
   *  lookup; no I/O. */
  find(prompt: number[], ns = ""): { entry: SsdIndexEntry; prefixLen: number } | null {
    let best: SsdIndexEntry | null = null;
    let bestLen = 0;
    for (const e of this.#index) {
      if (e.ns !== ns) continue;
      const p = Math.min(commonPrefixLength(e.tokens, prompt), prompt.length - 1);
      if (p === 0 || p <= bestLen) continue;
      bestLen = p;
      best = e;
    }
    return best ? { entry: best, prefixLen: bestLen } : null;
  }

  /** Restore an entry zero-copy (COW mmap; pages fault in lazily). Bumps
   *  LRU mtime. On ANY failure the file is dropped and null returned. */
  restore(entry: SsdIndexEntry, model: { makeCache(): Cache[] }): LoadedKvCache | null {
    const t0 = performance.now();
    try {
      const expect: KvLoadExpect = {
        configFingerprint: this.#opts.configFingerprint,
        tokenizerHash: this.#opts.tokenizerHash,
        ns: entry.ns,
        verify: this.#opts.verify,
      };
      const loaded = loadKvCache(entry.path, model, expect);
      const now = new Date();
      try { utimesSync(entry.path, now, now); entry.mtimeMs = now.getTime(); } catch {}
      this.stats.restores++;
      this.stats.restoreMsLast = performance.now() - t0;
      return loaded;
    } catch {
      this.remove(entry.path);
      return null;
    }
  }

  /** Persist an entry. Synchronous (the tier calls it on the idle serial
   *  lane between requests); atomic via kv-store's tmp+fsync+rename. An
   *  entry bigger than the cap is refused; disk/write failure is a warn-once
   *  soft-fail — serving never stalls on the cold tier. Existing entries in
   *  the same ns whose tokens are a PREFIX of the new entry are superseded
   *  (the agent-conversation pattern: one growing entry, not N generations
   *  of it). Returns true if stored. */
  store(tokens: number[], caches: Cache[], ns = ""): boolean {
    const dir = join(this.#root, nsHash(ns));
    const path = join(dir, `${randomUUID()}.mlxkv`);
    try {
      mkdirSync(dir, { recursive: true });
      const meta: KvSaveMeta = {
        modelId: this.#opts.modelId,
        configFingerprint: this.#opts.configFingerprint,
        tokenizerHash: this.#opts.tokenizerHash,
        ns,
      };
      saveKvCache(path, tokens, caches, meta);
      const st = statSync(path);
      if (st.size > this.#opts.maxBytes) {
        rmSync(path, { force: true });
        return false;
      }
      // Supersede shadowed ancestors of this prefix (same ns).
      for (const e of [...this.#index]) {
        if (e.ns !== ns || e.tokens.length >= tokens.length) continue;
        if (commonPrefixLength(e.tokens, tokens) === e.tokens.length) this.remove(e.path);
      }
      this.#index.push({ path, ns, tokens, bytes: st.size, mtimeMs: Date.now() });
      this.stats.spills++;
      this.evictToCap();
      return true;
    } catch (err) {
      try { rmSync(path, { force: true }); rmSync(`${path}.tmp`, { force: true }); } catch {}
      if (!this.#warnedWriteFailure) {
        this.#warnedWriteFailure = true;
        console.warn(`[ssd-cache] store failed (disk full or unwritable?) — cold tier disabled for this entry: ${(err as Error).message}`);
      }
      return false;
    }
  }

  /** Enforce the byte cap: unlink oldest-mtime entries until under it. */
  evictToCap(): void {
    while (this.totalBytes > this.#opts.maxBytes && this.#index.length > 0) {
      let oldest = 0;
      for (let i = 1; i < this.#index.length; i++)
        if (this.#index[i]!.mtimeMs < this.#index[oldest]!.mtimeMs) oldest = i;
      this.remove(this.#index[oldest]!.path);
    }
  }

  remove(path: string): void {
    try { rmSync(path, { force: true }); } catch {}
    this.#index = this.#index.filter((e) => e.path !== path);
  }
}
