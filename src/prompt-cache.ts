// Byte-capped LRU prompt cache — the RAM tier of the Layer-0 KV store.
//
// The mlx-lm lesson (PLAN.md): a count-capped cache of multi-GB KV
// entries is an OOM footgun. Ours accounts bytes (sum of KV array bytes
// per entry) and evicts least-recently-used until under the cap.
//
// Usage pattern (single generation queue, so take/reinsert is race-free):
//   const hit = cache.take(promptIds);     // longest strict-prefix match
//   generate(model, promptIds, { cache: hit?.caches ?? fresh })
//   cache.put([...promptIds, ...generated], caches);  // extended entry
//
// TIERING (Layer 0, unified-engine plan): when a ColdTier is attached,
// take() itself runs the two-tier dance — RAM peek vs cold find, restore
// (zero-copy mmap) + trim when the cold tier holds a strictly longer
// prefix — so EVERY consumer (the serial lane, the batch scheduler, future
// prefix sharing) gets SSD restores through the same take()/put() it
// already calls. Eviction spills to the tier (the #spill hook); idle
// entries DEMOTE to it (demoteIdle — free the GPU memory, keep the prefix
// reachable); onPut lets the server schedule its debounced write-behind
// snapshot for both lanes.

import type { Cache } from "./model/gemma4";

/** The cold (SSD) tier the RAM cache tiers over. Structural — this module
 *  never imports ssd-cache (which imports us); the server binds
 *  SsdCacheStore + the model into this shape (src/server.ts). All methods
 *  must be failure-proof: any error degrades to "no hit"/"not stored". */
export interface ColdTier {
  /** Longest stored usable prefix for prompt/ns — index-only, no I/O.
   *  `handle` is the tier's opaque entry token, passed back to restore. */
  find(prompt: number[], ns: string): { prefixLen: number; handle: unknown } | null;
  /** Materialize a found entry as GPU-visible caches (zero-copy COW mmap;
   *  pages fault in lazily). `retain` must run after the caches are
   *  disposed (it unmaps the backing file). Null on any failure. */
  restore(handle: unknown): { tokens: number[]; caches: Cache[]; retain: () => void } | null;
  store(tokens: number[], caches: Cache[], ns: string): void;
}

export interface PromptCacheEntry {
  tokens: number[];
  caches: Cache[];
  /** Namespace key — adapter spec for LoRA requests ("" = base model).
   *  KV computed under one adapter must never seed another's prefill. */
  ns: string;
  /** Release hook for entries restored from the SSD cold tier: unmaps the
   *  backing COW file mapping. MUST run only after `caches` are disposed
   *  (they may alias file pages); every dispose path here honors that, and
   *  callers who take() an entry carry the thunk with it. */
  retain?: () => void;
}

function cacheBytes(caches: Cache[]): number {
  let total = 0;
  for (const c of caches) for (const a of c.state()) total += a.nbytes;
  return total;
}

/** Length of the longest common prefix of two token sequences. */
export function commonPrefixLength(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[i] === b[i]) i++;
  return i;
}

export class PromptCache {
  readonly maxBytes: number;
  #entries: { entry: PromptCacheEntry; bytes: number; lastUsed: number; lastUsedMs: number }[] = [];
  #clock = 0;
  hits = 0;
  misses = 0;
  demotions = 0;
  /** Cold-tier spill hook: called with an entry ABOUT to be evicted (still
   *  alive — the hook may serialize its caches); the cache disposes it after.
   *  Failures are the hook's problem; eviction proceeds regardless. */
  readonly #spill: ((entry: PromptCacheEntry) => void) | null;
  /** Optional cold tier: take() tiers over it, demoteIdle() spills into it. */
  readonly #cold: ColdTier | null;
  /** Fired after every successful put() — the server hangs its debounced
   *  write-behind SSD snapshot here so BOTH lanes' entries persist. */
  onPut: ((tokens: number[], ns: string) => void) | null = null;

  constructor(
    maxBytes: number,
    spill: ((entry: PromptCacheEntry) => void) | null = null,
    cold: ColdTier | null = null,
  ) {
    this.maxBytes = maxBytes;
    this.#spill = spill;
    this.#cold = cold;
  }

  #disposeEntry(entry: PromptCacheEntry, spillFirst: boolean): void {
    if (spillFirst) {
      const spill =
        this.#spill ??
        (this.#cold
          ? (e: PromptCacheEntry) => this.#cold!.store(e.tokens, e.caches, e.ns)
          : null);
      if (spill) try { spill(entry); } catch {}
    }
    for (const c of entry.caches) c.dispose();
    entry.retain?.();
  }

  get totalBytes(): number {
    return this.#entries.reduce((a, e) => a + e.bytes, 0);
  }

  get size(): number {
    return this.#entries.length;
  }

  /** Find the entry with the longest usable common prefix of `prompt`
   *  across BOTH tiers, remove/restore it, trim its caches to that prefix
   *  if needed (and possible), and hand over ownership (caller must put()
   *  it back — possibly extended — or dispose it, honoring `retain`).
   *
   *  Usable prefix = common prefix capped at prompt.length - 1 (at least
   *  one token must be forwarded to produce logits). Entries longer than
   *  the prefix need cache.trim(); ring caches lose trimability once
   *  wrapped — those entries only match in full.
   *
   *  Tier order: the cold tier wins only with a STRICTLY longer usable
   *  prefix (its restore costs a mmap + lazy fault-in; RAM is free). A
   *  cold entry with an untrimmable divergent tail (ring post-wrap, SSM)
   *  is dropped and the RAM candidate (or a fresh prefill) serves.
   *  hits/misses count RAM candidacy only (cold restores are counted by
   *  the tier itself), preserving the /stats meaning. */
  take(prompt: number[], ns = ""): PromptCacheEntry | null {
    let bestIdx = -1;
    let bestLen = 0;
    for (let i = 0; i < this.#entries.length; i++) {
      const e = this.#entries[i]!.entry;
      if (e.ns !== ns) continue;
      const p = Math.min(commonPrefixLength(e.tokens, prompt), prompt.length - 1);
      if (p <= bestLen) continue;
      const trimNeeded = e.tokens.length - p;
      if (trimNeeded > 0 && !e.caches.every((c) => c.isTrimmable())) continue;
      bestLen = p;
      bestIdx = i;
    }
    if (bestIdx === -1) this.misses++;
    else this.hits++;

    // Cold tier: strictly longer usable prefix ⇒ restore + trim; the RAM
    // candidate stays put UNTOUCHED (the old serial-lane flow trimmed it
    // before comparing — a needless entry degradation, gone now).
    if (this.#cold) {
      const hit = this.#cold.find(prompt, ns);
      if (hit && hit.prefixLen > bestLen) {
        const loaded = this.#cold.restore(hit.handle);
        if (loaded) {
          const trimNeeded = loaded.tokens.length - hit.prefixLen;
          if (trimNeeded > 0 && !loaded.caches.every((c) => c.isTrimmable())) {
            // Divergent tail on an untrimmable kind: this file can't seed
            // the prompt — fall back to the RAM candidate.
            for (const c of loaded.caches) c.dispose();
            loaded.retain();
          } else {
            if (trimNeeded > 0) for (const c of loaded.caches) c.trim(trimNeeded);
            return {
              tokens: loaded.tokens.slice(0, hit.prefixLen),
              caches: loaded.caches,
              ns,
              retain: loaded.retain,
            };
          }
        }
      }
    }

    if (bestIdx === -1) return null;
    const { entry } = this.#entries.splice(bestIdx, 1)[0]!;
    const trimNeeded = entry.tokens.length - bestLen;
    if (trimNeeded > 0) {
      for (const c of entry.caches) c.trim(trimNeeded);
      entry.tokens = entry.tokens.slice(0, bestLen);
    }
    return entry;
  }

  /** Longest usable prefix length available for `prompt` WITHOUT taking
   *  (the SSD tier compares this against its own best before restoring). */
  peekPrefixLen(prompt: number[], ns = ""): number {
    let best = 0;
    for (const { entry: e } of this.#entries) {
      if (e.ns !== ns) continue;
      const p = Math.min(commonPrefixLength(e.tokens, prompt), prompt.length - 1);
      if (p <= best) continue;
      const trimNeeded = e.tokens.length - p; // same usability rule as take()
      if (trimNeeded > 0 && !e.caches.every((c) => c.isTrimmable())) continue;
      best = p;
    }
    return best;
  }

  /** Read-only exact-token lookup (the write-behind snapshot path: the
   *  entry stays owned by the cache; the caller only reads array state,
   *  under the gateway lock so no generation is mutating it). */
  findExact(tokens: number[], ns = ""): PromptCacheEntry | null {
    for (const { entry: e } of this.#entries) {
      if (e.ns !== ns || e.tokens.length !== tokens.length) continue;
      if (commonPrefixLength(e.tokens, tokens) === tokens.length) return e;
    }
    return null;
  }

  /** Insert (or reinsert) an entry; evicts LRU entries over the byte cap
   *  (spilling each to the cold tier first, when one is attached). If the
   *  entry itself exceeds the cap it is spilled + disposed, not stored. */
  put(tokens: number[], caches: Cache[], ns = "", retain?: () => void): void {
    const bytes = cacheBytes(caches);
    const entry: PromptCacheEntry = { tokens, caches, ns, retain };
    if (bytes > this.maxBytes) {
      this.#disposeEntry(entry, true);
      return;
    }
    this.#entries.push({ entry, bytes, lastUsed: ++this.#clock, lastUsedMs: Date.now() });
    while (this.totalBytes > this.maxBytes && this.#entries.length > 1) {
      let lruIdx = 0;
      for (let i = 1; i < this.#entries.length; i++)
        if (this.#entries[i]!.lastUsed < this.#entries[lruIdx]!.lastUsed) lruIdx = i;
      const [evicted] = this.#entries.splice(lruIdx, 1);
      this.#disposeEntry(evicted!.entry, true);
    }
    try { this.onPut?.(tokens, ns); } catch {}
  }

  /** Layer-0 idle demotion: spill every entry unused for `idleMs` to the
   *  cold tier and FREE its GPU memory. The prefix stays reachable — the
   *  next take() restores it via zero-copy mmap (~0.25 s for a 13.7k-token
   *  entry, vs a 12 s re-prefill) — but between bursts the RAM tier drains
   *  toward empty, returning unified memory to the system. Caller must
   *  hold the generation lock (entries' arrays are disposed here). No-op
   *  without a cold tier — demotion without a place to demote TO would
   *  just be data loss. Returns entries demoted. */
  demoteIdle(idleMs: number, now = Date.now()): number {
    if (!this.#cold) return 0;
    let n = 0;
    for (const rec of [...this.#entries]) {
      if (now - rec.lastUsedMs < idleMs) continue;
      this.#entries = this.#entries.filter((r) => r !== rec);
      this.#disposeEntry(rec.entry, true); // spill-first, then dispose
      this.demotions++;
      n++;
    }
    return n;
  }

  clear(): void {
    for (const e of this.#entries) this.#disposeEntry(e.entry, false);
    this.#entries = [];
  }
}
