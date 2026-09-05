// SSD cold tier for the prompt/KV cache (docs/design/kv-cache.md).
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
  saveKvCache, saveKvCacheAsync, loadKvCache, readKvHeader,
  cacheHeadersTrimmable, legacyCacheCodecs, type CacheCodecProvider,
  type KvSaveMeta, type KvLoadExpect, type LoadedKvCache,
} from "./kv-store";
import type { Cache } from "./model/gemma4-base";

export interface SsdIndexEntry {
  path: string;
  ns: string;
  tokens: number[];
  bytes: number;
  mtimeMs: number;
  /** Whether every serialized cache can trim (derived from kinds+state at
   *  store/scan time). An untrimmable entry (wrapped ring, SSM) can only
   *  seed prompts it matches WITHOUT a trim — find() must not prefer it
   *  over a shorter usable one (the 2026-07-06 restart-0 defect: the
   *  [prompt+gen] file always won, always got rejected after restore). */
  trimmable: boolean;
  generationCheckpoint?: NonNullable<KvSaveMeta["generationCheckpoint"]>;
}

export interface SsdStoreOptions {
  codecs?: CacheCodecProvider;
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
  readonly #codecs: CacheCodecProvider;
  readonly #root: string; // <dir>/<configFingerprint>
  #index: SsdIndexEntry[] = [];
  #warnedWriteFailure = false;
  stats = { restores: 0, spills: 0, restoreMsLast: 0 };

  constructor(opts: SsdStoreOptions) {
    this.#opts = opts;
    this.#codecs = opts.codecs ?? legacyCacheCodecs;
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

  /** Longest token prefix whose atomic cache file is present in the index. */
  get longestDurablePrefixTokens(): number {
    return this.#index.reduce((best, entry) => Math.max(best, entry.tokens.length), 0);
  }

  /** True when the SSD index can seed every token in this prefix. A longer
   * trimmable descendant is equivalent to an exact boundary snapshot. */
  hasDurablePrefix(tokens: number[], ns = ""): boolean {
    return this.#index.some((entry) => {
      if (entry.ns !== ns || entry.tokens.length < tokens.length) return false;
      if (commonPrefixLength(entry.tokens, tokens) !== tokens.length) return false;
      return entry.tokens.length === tokens.length || entry.trimmable;
    });
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
            h.modelId !== this.#opts.modelId ||
            h.configFingerprint !== this.#opts.configFingerprint ||
            h.tokenizerHash !== this.#opts.tokenizerHash
          )
            throw new Error("metadata mismatch");
          if ((h.codecProvider ?? legacyCacheCodecs.id) !== this.#codecs.id) continue;
          const st = statSync(path);
          this.#index.push({
            path, ns: h.ns ?? "", tokens: h.tokens, bytes: st.size, mtimeMs: st.mtimeMs,
            trimmable: cacheHeadersTrimmable(h.caches, this.#codecs),
            ...(h.generationCheckpoint
              ? { generationCheckpoint: h.generationCheckpoint }
              : {}),
          });
        } catch {
          try { rmSync(path, { force: true }); } catch {}
        }
      }
    }
    return this.#index.length;
  }

  /** Best USABLE stored entry for `prompt` in `ns`: the longest common
   *  prefix (capped at prompt.length−1 — at least one token must forward).
   *  An entry LONGER than the matched prefix is returned only when it can
   *  actually seed the prompt: the divergent tail must be trimmable after
   *  restore. Untrimmable entries (ring post-wrap, SSM) that would need a
   *  trim are SKIPPED here — before this gate, the big [prompt+gen] file
   *  always outranked the usable boundary snapshot, got restored, and was
   *  thrown away by take()'s backstop (the 2026-07-06 restart-0 + wasted
   *  84 s restore-then-re-prefill path). Pure index lookup; no I/O. */
  find(prompt: number[], ns = ""): { entry: SsdIndexEntry; prefixLen: number } | null {
    let best: SsdIndexEntry | null = null;
    let bestLen = 0;
    for (const e of this.#index) {
      if (e.ns !== ns) continue;
      const p = Math.min(commonPrefixLength(e.tokens, prompt), prompt.length - 1);
      if (p === 0 || p <= bestLen) continue;
      if (e.tokens.length - p > 0 && !e.trimmable) continue;
      bestLen = p;
      best = e;
    }
    return best ? { entry: best, prefixLen: bestLen } : null;
  }

  /** Restore an entry via kv-store's STREAMED COPY (bounded host
   *  transient — live entry + one tensor; no mapping survives the call,
   *  the caches own their bytes). Bumps LRU mtime. On ANY failure the
   *  file is dropped and null returned. */
  restore(entry: SsdIndexEntry, model: { makeCache(): Cache[] }): LoadedKvCache | null {
    const t0 = performance.now();
    try {
      const expect: KvLoadExpect = {
        modelId: this.#opts.modelId,
        configFingerprint: this.#opts.configFingerprint,
        tokenizerHash: this.#opts.tokenizerHash,
        ns: entry.ns,
        verify: this.#opts.verify,
      };
      const loaded = loadKvCache(entry.path, model, expect, this.#codecs);
      const now = new Date();
      try { utimesSync(entry.path, now, now); entry.mtimeMs = now.getTime(); } catch {}
      this.stats.restores++;
      this.stats.restoreMsLast = performance.now() - t0;
      return loaded;
    } catch (err) {
      // Loud: a failed restore silently degraded to a full re-prefill for
      // a month before the 2026-07-06 bench made it observable.
      console.warn(`[ssd-cache] restore failed, dropping ${entry.path}: ${(err as Error).message}`);
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
      saveKvCache(path, tokens, caches, this.#meta(ns), this.#codecs);
      return this.#indexStored(path, tokens, caches, ns);
    } catch (err) {
      return this.#storeFailed(path, err);
    }
  }

  /** Non-blocking store (the write-behind persistence path): same file,
   *  index, and supersede semantics as store(), but the tensor flush
   *  yields the event loop between tensors so serving interleaves.
   *  Caller passes zero-copy CLONES it owns (a consistent snapshot no
   *  matter what the live entry does meanwhile) and disposes them after.
   *  `waitTurn` gates every per-tensor step (see saveKvCacheAsync) — the
   *  server passes the gateway's onIdle so the flush only progresses while
   *  the engine is idle, never mid-decode. */
  async storeAsync(tokens: number[], caches: Cache[], ns = "", waitTurn?: () => Promise<void>): Promise<boolean> {
    const dir = join(this.#root, nsHash(ns));
    const path = join(dir, `${randomUUID()}.mlxkv`);
    try {
      mkdirSync(dir, { recursive: true });
      await saveKvCacheAsync(path, tokens, caches, this.#meta(ns), waitTurn, this.#codecs);
      return this.#indexStored(path, tokens, caches, ns);
    } catch (err) {
      return this.#storeFailed(path, err);
    }
  }

  /** Longest durable in-flight generation for an identical request. The
   *  checkpoint namespace is separate from the ordinary prompt-cache tier,
   *  so incomplete assistant output can never seed an unrelated prefill. */
  findGenerationCheckpoint(
    prompt: number[], key: string, cacheNs = "",
  ): SsdIndexEntry | null {
    let best: SsdIndexEntry | null = null;
    for (const entry of this.#index) {
      const checkpoint = entry.generationCheckpoint;
      if (!checkpoint || checkpoint.key !== key || checkpoint.cacheNs !== cacheNs)
        continue;
      if (checkpoint.originalPromptTokens !== prompt.length) continue;
      if (entry.tokens.length <= prompt.length) continue;
      if (commonPrefixLength(entry.tokens, prompt) !== prompt.length) continue;
      if (!best || entry.tokens.length > best.tokens.length) best = entry;
    }
    return best;
  }

  /** Persist one in-flight generation atomically. A completed newer
   *  checkpoint supersedes older checkpoints for the same request only after
   *  its rename succeeds, so a crash during a write leaves the prior point. */
  async storeGenerationCheckpoint(
    tokens: number[], caches: Cache[], checkpoint: NonNullable<KvSaveMeta["generationCheckpoint"]>,
  ): Promise<boolean> {
    const ns = `__generation_checkpoint__:${checkpoint.key}`;
    const dir = join(this.#root, nsHash(ns));
    const path = join(dir, `${randomUUID()}.mlxkv`);
    try {
      mkdirSync(dir, { recursive: true });
      await saveKvCacheAsync(path, tokens, caches, {
        ...this.#meta(ns), generationCheckpoint: checkpoint,
      }, undefined, this.#codecs);
      const stored = this.#indexStored(path, tokens, caches, ns, checkpoint);
      if (stored) {
        for (const entry of [...this.#index]) {
          if (entry.path === path) continue;
          if (entry.generationCheckpoint?.key === checkpoint.key) this.remove(entry.path);
        }
      }
      return stored;
    } catch (err) {
      return this.#storeFailed(path, err);
    }
  }

  removeGenerationCheckpoints(key: string): void {
    for (const entry of [...this.#index])
      if (entry.generationCheckpoint?.key === key) this.remove(entry.path);
  }

  #meta(ns: string): KvSaveMeta {
    return {
      modelId: this.#opts.modelId,
      configFingerprint: this.#opts.configFingerprint,
      tokenizerHash: this.#opts.tokenizerHash,
      ns,
    };
  }

  #indexStored(
    path: string, tokens: number[], caches: Cache[], ns: string,
    generationCheckpoint?: NonNullable<KvSaveMeta["generationCheckpoint"]>,
  ): boolean {
    const st = statSync(path);
    if (st.size > this.#opts.maxBytes) {
      rmSync(path, { force: true });
      console.warn(`[ssd-cache] entry not stored: ${st.size} bytes exceeds the ${this.#opts.maxBytes}-byte cap`);
      return false;
    }
    const trimmable = caches.every((c) => c.isTrimmable());
    // Exact duplicates (same tokens) are replaced regardless of
    // trimmability — the new file serves exactly the old one's matches.
    for (const e of [...this.#index]) {
      if (e.ns !== ns || e.tokens.length !== tokens.length) continue;
      if (commonPrefixLength(e.tokens, tokens) === tokens.length) this.remove(e.path);
    }
    // Supersede shadowed ancestors of this prefix (same ns) — ONLY when
    // the new entry can serve their prefixes (all caches trimmable; the
    // same guard as PromptCache.put()). An untrimmable [prompt+gen]
    // entry deleting the boundary snapshot was the gemma restart-0
    // defect (2026-07-06): the only restorable file died the moment the
    // unrestorable one landed.
    if (trimmable) {
      for (const e of [...this.#index]) {
        if (e.ns !== ns || e.tokens.length >= tokens.length) continue;
        if (commonPrefixLength(e.tokens, tokens) === e.tokens.length) this.remove(e.path);
      }
    }
    this.#index.push({
      path, ns, tokens, bytes: st.size, mtimeMs: Date.now(), trimmable,
      ...(generationCheckpoint ? { generationCheckpoint } : {}),
    });
    this.stats.spills++;
    this.evictToCap();
    return true;
  }

  #storeFailed(path: string, err: unknown): boolean {
    try { rmSync(path, { force: true }); rmSync(`${path}.tmp`, { force: true }); } catch {}
    if (!this.#warnedWriteFailure) {
      this.#warnedWriteFailure = true;
      console.warn(`[ssd-cache] store failed (disk full or unwritable?) — cold tier disabled for this entry: ${(err as Error).message}`);
    }
    return false;
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
