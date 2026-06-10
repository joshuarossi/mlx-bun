// Byte-capped LRU prompt cache.
//
// The mlx-lm lesson (PLAN.md): a count-capped cache of multi-GB KV
// entries is an OOM footgun. Ours accounts bytes (sum of KV array bytes
// per entry) and evicts least-recently-used until under the cap.
//
// Usage pattern (single generation queue, so take/reinsert is race-free):
//   const hit = cache.take(promptIds);     // longest strict-prefix match
//   generate(model, promptIds, { cache: hit?.caches ?? fresh })
//   cache.put([...promptIds, ...generated], caches);  // extended entry

import type { Cache } from "./model/gemma4";

export interface PromptCacheEntry {
  tokens: number[];
  caches: Cache[];
  /** Namespace key — adapter spec for LoRA requests ("" = base model).
   *  KV computed under one adapter must never seed another's prefill. */
  ns: string;
}

function cacheBytes(caches: Cache[]): number {
  let total = 0;
  for (const c of caches) for (const a of c.state()) total += a.nbytes;
  return total;
}

/** Length of the longest common prefix of two token sequences. */
function commonPrefixLength(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[i] === b[i]) i++;
  return i;
}

export class PromptCache {
  readonly maxBytes: number;
  #entries: { entry: PromptCacheEntry; bytes: number; lastUsed: number }[] = [];
  #clock = 0;
  hits = 0;
  misses = 0;

  constructor(maxBytes: number) {
    this.maxBytes = maxBytes;
  }

  get totalBytes(): number {
    return this.#entries.reduce((a, e) => a + e.bytes, 0);
  }

  get size(): number {
    return this.#entries.length;
  }

  /** Find the entry with the longest usable common prefix of `prompt`,
   *  remove it, trim its caches to that prefix if needed (and possible),
   *  and hand over ownership (caller must put() it back — possibly
   *  extended — or dispose it).
   *
   *  Usable prefix = common prefix capped at prompt.length - 1 (at least
   *  one token must be forwarded to produce logits). Entries longer than
   *  the prefix need cache.trim(); ring caches lose trimability once
   *  wrapped — those entries only match in full. */
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
    if (bestIdx === -1) {
      this.misses++;
      return null;
    }
    this.hits++;
    const { entry } = this.#entries.splice(bestIdx, 1)[0]!;
    const trimNeeded = entry.tokens.length - bestLen;
    if (trimNeeded > 0) {
      for (const c of entry.caches) c.trim(trimNeeded);
      entry.tokens = entry.tokens.slice(0, bestLen);
    }
    return entry;
  }

  /** Insert (or reinsert) an entry; evicts LRU entries over the byte cap.
   *  If the entry itself exceeds the cap it is disposed, not stored. */
  put(tokens: number[], caches: Cache[], ns = ""): void {
    const bytes = cacheBytes(caches);
    if (bytes > this.maxBytes) {
      for (const c of caches) c.dispose();
      return;
    }
    this.#entries.push({ entry: { tokens, caches, ns }, bytes, lastUsed: ++this.#clock });
    while (this.totalBytes > this.maxBytes && this.#entries.length > 1) {
      let lruIdx = 0;
      for (let i = 1; i < this.#entries.length; i++)
        if (this.#entries[i]!.lastUsed < this.#entries[lruIdx]!.lastUsed) lruIdx = i;
      const [evicted] = this.#entries.splice(lruIdx, 1);
      for (const c of evicted!.entry.caches) c.dispose();
    }
  }

  clear(): void {
    for (const e of this.#entries) for (const c of e.entry.caches) c.dispose();
    this.#entries = [];
  }
}
