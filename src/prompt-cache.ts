// Byte-capped LRU prompt cache — the RAM tier of the Layer-0 KV store.
//
// The mlx-lm lesson (PLAN.md): a count-capped cache of multi-GB KV
// entries is an OOM footgun. Ours accounts bytes (sum of KV array bytes
// per entry) and evicts least-recently-used until under the cap.
//
// Usage pattern (single generation queue, so take/put is race-free):
//   const hit = cache.take(promptIds);   // longest-prefix match → CLONES
//   generate(model, promptIds, { cache: hit?.caches ?? fresh })
//   cache.put([...promptIds, ...generated], caches, ns, hit?.retain);
// take() is NON-CONSUMING (prefix sharing): it serves zero-copy clones and
// leaves the donor entry in place — N agents sharing a system prompt all
// clone from one donor, one prefill; put() supersedes same-ns
// prefix-ancestors (when the new entry is trimmable) so a conversation
// stays one entry, not one per turn.
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

import { TurboQuantKVCache, type Cache } from "./model/gemma4";
import { cloneKvCaches } from "./kv-store";

/** Reference-counted release: wraps an entry's `retain` (e.g. an mmap
 *  unmap) so DONOR + CLONES can each hold a share — the underlying hook
 *  runs once, after the LAST holder releases. Prefix sharing hands out
 *  zero-copy VIEWS of a donor's buffers; if the donor's unmap ran while a
 *  clone still referenced the mapped pages, the clone would read freed
 *  memory. */
function makeSharedRetain(retain: (() => void) | undefined): { acquire(): () => void } {
  let count = 0;
  let released = false;
  return {
    acquire() {
      count++;
      let mine = false;
      return () => {
        if (mine) return; // idempotent per share
        mine = true;
        count--;
        if (count === 0 && !released) {
          released = true;
          retain?.();
        }
      };
    },
  };
}

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

/** Spill sink for eviction/demotion (write-behind, 2026-07-06).
 *
 *  `spillOwned` (preferred, NON-BLOCKING): the cache hands the sink an
 *  entry it OWNS — zero-copy CLONES of the caches (made via the same
 *  injectable cloner take() uses, BEFORE the donor is disposed; entries
 *  are immutable so the clones stay consistent forever) plus a copy of
 *  the tokens. The sink must dispose entry.caches when done, on BOTH
 *  fulfill and reject paths (the server chains storeAsync -> dispose on
 *  ssdWriteChain). A sink that throws SYNCHRONOUSLY has not taken
 *  ownership — the cache disposes the clones and the spill degrades to
 *  a no-op; eviction/demotion never unwinds.
 *
 *  `spillSync` (fallback): called with the LIVE entry about to be
 *  disposed; must finish reading before returning. This is the old
 *  contract — a full synchronous serialize+write under the generation
 *  lock — kept for tests and simple embedders. */
export interface SpillSink {
  spillOwned?: (entry: PromptCacheEntry) => void;
  spillSync?: (entry: PromptCacheEntry) => void;
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

export function cacheBytes(caches: Cache[]): number {
  let total = 0;
  for (const c of caches) {
    const state = c.state();
    for (const a of state) total += a.nbytes;
    // Most Cache kinds' state() returns their own live-owned arrays (safe
    // to just read), but TurboQuantKVCache allocates fresh trimmed slice
    // views per call (kv-store.ts snapshotCache/cloneKvCaches contract) —
    // those must be disposed here or they leak (see generate.ts
    // evalCacheState for the same hazard on the prefill path).
    if (c instanceof TurboQuantKVCache) for (const a of state) a.dispose();
  }
  return total;
}

/** Length of the longest common prefix of two token sequences. */
export function commonPrefixLength(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[i] === b[i]) i++;
  return i;
}

interface EntryRecord {
  entry: PromptCacheEntry;
  bytes: number;
  lastUsed: number;
  lastUsedMs: number;
  /** Ref-counted retain: the donor holds one share (entry.retain); every
   *  clone handed out by take() holds another. */
  share: { acquire(): () => void };
}

export class PromptCache {
  readonly maxBytes: number;
  #entries: EntryRecord[] = [];
  #clock = 0;
  hits = 0;
  misses = 0;
  demotions = 0;
  /** Cold-tier spill sinks (see SpillSink): spillOwned gets clones and
   *  runs the write off-lock; spillSync gets the live entry inline.
   *  Failures are the sink's problem; eviction proceeds regardless. */
  readonly #spillOwned: ((entry: PromptCacheEntry) => void) | null;
  readonly #spillSync: ((entry: PromptCacheEntry) => void) | null;
  /** Optional cold tier: take() tiers over it, demoteIdle() spills into it. */
  readonly #cold: ColdTier | null;
  /** Fired after every successful put() — the server hangs its debounced
   *  write-behind SSD snapshot here so BOTH lanes' entries persist. */
  onPut: ((tokens: number[], ns: string) => void) | null = null;

  /** Zero-copy view cloner — injectable so model-free tests can stub it. */
  readonly #clone: (caches: Cache[]) => Cache[];

  constructor(
    maxBytes: number,
    // Bare function = legacy sync spill (tests, simple embedders).
    spill: SpillSink | ((entry: PromptCacheEntry) => void) | null = null,
    cold: ColdTier | null = null,
    clone: (caches: Cache[]) => Cache[] = cloneKvCaches,
  ) {
    this.maxBytes = maxBytes;
    this.#spillOwned = typeof spill === "function" ? null : spill?.spillOwned ?? null;
    this.#spillSync = typeof spill === "function" ? spill : spill?.spillSync ?? null;
    this.#cold = cold;
    this.#clone = clone;
  }

  #disposeEntry(entry: PromptCacheEntry, spillFirst: boolean): void {
    if (spillFirst) {
      if (this.#spillOwned) {
        // NON-BLOCKING spill: clone BEFORE disposing (clones are zero-copy
        // views of the live arrays) and hand ownership to the sink, which
        // flushes off the generation lock. The underlying GPU buffers stay
        // alive until the sink disposes the clones — for demoteIdle that
        // means the memory is freed one bounded write-chain hop later, not
        // instantly; acceptable because the chain is serial and each write
        // disposes its clones on settle (fulfill AND reject).
        // Retain contract: entry.retain still runs below, possibly while
        // the clones are in flight — safe because cold-restored entries
        // OWN their bytes (streamed copy-restore, 2026-07-07): there is
        // no backing mmap for retain to unmap, so nothing the clones
        // could alias goes away.
        let clones: Cache[] | null = null;
        try {
          clones = this.#clone(entry.caches);
          this.#spillOwned({ tokens: [...entry.tokens], caches: clones, ns: entry.ns });
        } catch {
          // Failure degrades to no-spill; eviction/demotion never unwinds.
          if (clones) for (const c of clones) try { c.dispose(); } catch {}
        }
      } else {
        const spill =
          this.#spillSync ??
          (this.#cold
            ? (e: PromptCacheEntry) => this.#cold!.store(e.tokens, e.caches, e.ns)
            : null);
        if (spill) try { spill(entry); } catch {}
      }
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
   *  across BOTH tiers and serve it NON-CONSUMINGLY (prefix sharing,
   *  2026-07-05): the caller receives zero-copy CLONES trimmed to the
   *  matched prefix (plus a ref-counted retain share); the donor entry
   *  stays in the cache, ready for the next agent/session with the same
   *  prefix. The caller owns the returned caches — dispose them or put()
   *  an extended entry (which supersedes prefix-ancestors), honoring
   *  `retain` either way.
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
            // the prompt — fall back to the RAM candidate. Loud: this used
            // to be the silent 84 s "restore-then-re-prefill" path (the
            // whole cold tier degrading with zero observables, 2026-07-06).
            console.warn(
              `[prompt-cache] cold entry unusable: ${loaded.tokens.length} tokens, ` +
              `needs trim ${trimNeeded} but untrimmable (wrapped ring/SSM) — re-prefilling`,
            );
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
    // PREFIX SHARING (non-consuming serve): the caller gets zero-copy
    // CLONES of the donor's caches, trimmed to the matched prefix; the
    // donor stays in the cache untouched, ready to serve the next agent /
    // session with the same prefix. Safe because mlx cache updates are
    // FUNCTIONAL (updateAndFetch reassigns fresh arrays; buffer donation
    // only fires at refcount 1, and the donor always holds a ref), so a
    // clone extending itself can never mutate the donor's bytes. The old
    // consume-and-trim semantics CANNIBALIZED donors: agent B borrowing
    // agent A's 2k system prompt destroyed A's 10k entry to do it.
    const rec = this.#entries[bestIdx]!;
    rec.lastUsed = ++this.#clock;
    rec.lastUsedMs = Date.now();
    const clones = this.#clone(rec.entry.caches);
    const trimNeeded = rec.entry.tokens.length - bestLen;
    if (trimNeeded > 0) for (const c of clones) c.trim(trimNeeded);
    return {
      tokens: rec.entry.tokens.slice(0, bestLen),
      caches: clones,
      ns,
      retain: rec.share.acquire(),
    };
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
    // The donor's retain becomes ref-counted so take()'s clones can hold
    // shares; the entry's own retain is the donor's share.
    const share = makeSharedRetain(retain);
    entry.retain = share.acquire();
    const rec: EntryRecord = { entry, bytes, lastUsed: ++this.#clock, lastUsedMs: Date.now(), share };
    this.#entries.push(rec);
    // Exact duplicates (equal tokens) are redundant REGARDLESS of
    // trimmability — the new entry serves exactly the matches the old one
    // did (mlx-lm's trie replaces in place). Without this, every gemma ctx
    // repeat left another full-size wrapped-ring entry behind (measured
    // ~0.4 GB retained per repeat on the 12B bench).
    for (const old of [...this.#entries]) {
      if (old === rec || old.entry.ns !== ns) continue;
      if (old.entry.tokens.length !== tokens.length) continue;
      if (commonPrefixLength(old.entry.tokens, tokens) !== tokens.length) continue;
      this.#entries = this.#entries.filter((r) => r !== old);
      this.#disposeEntry(old.entry, false);
    }
    // SUPERSEDE strict prefix-ancestors (the SSD store's rule, brought to
    // RAM — prefix sharing would otherwise grow an entry per turn): same-ns
    // entries whose tokens are a prefix of the new entry are redundant
    // and disposed WITHOUT spill (the new entry serves their prefixes and
    // its own write-behind persists them) — but ONLY when the new entry's
    // caches are all trimmable. An untrimmable new entry (wrapped ring)
    // can only serve exact-length matches, so shorter ancestors — e.g.
    // the prompt-boundary snapshot that makes drifted multi-turn agents
    // hit — must survive.
    if (caches.every((c) => c.isTrimmable())) {
      for (const old of [...this.#entries]) {
        if (old === rec || old.entry.ns !== ns) continue;
        if (old.entry.tokens.length >= tokens.length) continue;
        if (commonPrefixLength(old.entry.tokens, tokens) !== old.entry.tokens.length) continue;
        this.#entries = this.#entries.filter((r) => r !== old);
        this.#disposeEntry(old.entry, false);
      }
    }
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
   *  hold the generation lock (entries' arrays are disposed here) — with
   *  a spillOwned sink the lock covers only the zero-copy clone; the
   *  write runs off-lock and the buffers free when it settles. No-op
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
