// The echo source (K3c, Lab tier) — a growing per-request k-gram index over
// the session's own tokens, and the branch-point rule that decides how far a
// copied span may run.
//
// PORT. The index is the TS port of `GrowingMatcher` from the corpus study
// (reports/k3-replication/analyze.py): a sequence plus a k-gram → [start
// positions] map, appended incrementally so a lookup never rescans the prefix,
// with the bucket scan capped at the NEAREST candidates. The corpus tool ran
// it offline over recorded turns to measure how much of an agent's output is
// copy-determined; this runs the same structure online, over promptIds plus
// everything emitted (injected tokens included — the model cannot tell them
// apart, so neither does the index).
//
// THE INTERESTING PART is not the lookup, it is the STOPPING RULE. A match
// tells you where this exact k-gram occurred before; it does not tell you how
// far the future agrees with the past. So the span extends only while EVERY
// nearby occurrence continues the same way. The moment two occurrences
// disagree — the session history forks — the span stops. That is where
// old-query-vs-new-query divergence lives, and delimiters fall out of it for
// free: a closing quote is where histories fork.
//
// DOCTRINE. An echo span is a GUESS, unlike the schema rows. It ships under
// policy "verify" unless it is unambiguous all the way to a delimiter-class
// token — the engine then keeps only the prefix the model itself agrees with.
// Lab tier: default off, and a paired A/B decides whether it ever becomes a
// default (PLAN K3).
import type { Proposal, ProposalSource, TokenView } from "./proposal";

export interface EchoConfig {
  /** Anchor length: the k-gram that has to match for a span to be proposed. */
  k: number;
  /** Longest span the source will propose (the session clamps again). */
  maxSpan: number;
  /** Bucket scan cap — the NEAREST occurrences win (recency is the signal;
   *  an unbounded scan is also the only quadratic risk here). */
  maxCandidates: number;
  /** Stop growing the index past this many tokens (memory cap). */
  indexMax: number;
  /** Token ids that legitimately END a copied span (a closing quote, the
   *  markup that follows an argument value). Derived from the template by the
   *  strict-row compiler; empty means "no span can be asserted". */
  delimiters: ReadonlySet<number>;
}

/** Growing k-gram index over one request's token sequence. */
export class EchoIndex {
  readonly #k: number;
  readonly #indexMax: number;
  readonly #seq: number[] = [];
  /** hash(k-gram) → start positions, oldest first. Hash collisions are
   *  harmless: every candidate's gram is compared id-for-id before use. */
  readonly #buckets = new Map<number, number[]>();
  #frozen = false;

  constructor(k: number, indexMax: number) {
    this.#k = Math.max(1, Math.floor(k));
    this.#indexMax = Math.max(this.#k, Math.floor(indexMax));
  }

  get length(): number { return this.#seq.length; }
  /** True once the memory cap stopped the index from growing. */
  get frozen(): boolean { return this.#frozen; }

  append(ids: readonly number[]): void {
    for (const id of ids) {
      if (this.#seq.length >= this.#indexMax) { this.#frozen = true; return; }
      this.#seq.push(id);
      const start = this.#seq.length - this.#k;
      if (start < 0) continue;
      const h = this.#hash(start);
      const bucket = this.#buckets.get(h);
      if (bucket) bucket.push(start);
      else this.#buckets.set(h, [start]);
    }
  }

  /** Start positions whose k-gram equals `gram` AND which have at least one
   *  token after it, nearest (most recent) first. */
  candidates(gram: readonly number[], cap: number): number[] {
    if (gram.length !== this.#k) return [];
    let h = 0x811c9dc5;
    for (const id of gram) h = this.#mix(h, id);
    const bucket = this.#buckets.get(h >>> 0);
    if (!bucket) return [];
    const out: number[] = [];
    for (let i = bucket.length - 1; i >= 0 && out.length < cap; i--) {
      const pos = bucket[i]!;
      if (pos + this.#k >= this.#seq.length) continue; // no continuation yet
      let ok = true;
      for (let j = 0; j < this.#k; j++) {
        if (this.#seq[pos + j] !== gram[j]) { ok = false; break; } // collision
      }
      if (ok) out.push(pos);
    }
    return out;
  }

  /** Extend forward from the given anchors while EVERY anchor agrees.
   *  Returns the agreed continuation, whether it stopped at a fork, and how
   *  many occurrences corroborated the WHOLE span (survivors at the last
   *  accepted token) — one occurrence is a copy, several are a pattern. */
  extend(
    anchors: readonly number[], maxSpan: number, delimiters: ReadonlySet<number>,
  ): { ids: number[]; branchStop: boolean; agreed: number } {
    const ids: number[] = [];
    let agreed = 0;
    let live = anchors.map((p) => p + this.#k);
    while (ids.length < maxSpan) {
      let next: number | undefined;
      let forked = false;
      const stillLive: number[] = [];
      for (const p of live) {
        const v = this.#seq[p];
        // An occurrence that ran out of history simply drops out: a prefix
        // that ends is not evidence of disagreement.
        if (v === undefined) continue;
        if (next === undefined) next = v;
        else if (v !== next) { forked = true; break; }
        stillLive.push(p + 1);
      }
      // A fork means the session's own history disagrees about what comes
      // next. That is exactly the position the model must decide for itself.
      if (forked) return { ids, branchStop: true, agreed };
      if (next === undefined) break; // every occurrence exhausted
      ids.push(next);
      agreed = stillLive.length;
      live = stillLive;
      // A delimiter is a legitimate END: injecting the closing quote is the
      // point, continuing past it is not.
      if (delimiters.has(next)) break;
    }
    return { ids, branchStop: false, agreed };
  }

  #hash(start: number): number {
    let h = 0x811c9dc5;
    for (let j = 0; j < this.#k; j++) h = this.#mix(h, this.#seq[start + j]!);
    return h >>> 0;
  }

  #mix(h: number, id: number): number {
    let x = h ^ id;
    x = Math.imul(x, 0x01000193);
    return x >>> 0;
  }
}

/** ProposalSource over the echo index. */
export class EchoSource implements ProposalSource {
  readonly name = "echo";
  readonly windowNeeded: number;
  readonly index: EchoIndex;

  constructor(private readonly config: EchoConfig, promptIds: readonly number[]) {
    this.windowNeeded = config.k;
    this.index = new EchoIndex(config.k, config.indexMax);
    this.index.append(promptIds);
  }

  observe(ids: readonly number[]): void {
    this.index.append(ids);
  }

  propose(view: TokenView): Proposal | null {
    const { k, maxSpan, maxCandidates, delimiters } = this.config;
    const gram = view.tail(k);
    if (gram.length < k) return null;
    const anchors = this.index.candidates(gram, maxCandidates);
    if (anchors.length === 0) return null;
    const { ids, branchStop, agreed } = this.index.extend(anchors, maxSpan, delimiters);
    if (ids.length < 2) return null;
    // POLICY. Assert only with CORROBORATION: several occurrences of this
    // context all continued the same way, nothing forked, and the span stops
    // at a delimiter-class token. A single occurrence is just a copy — and a
    // copy will happily replay whatever followed it in the transcript,
    // including another role's turn, so it has to be the model's call.
    // Everything else rides policy "verify", where a wrong guess costs a
    // rewound forward, never a wrong token.
    const endsAtDelimiter = delimiters.has(ids[ids.length - 1]!);
    const corroborated = agreed >= 2;
    return {
      ids,
      policy: !branchStop && endsAtDelimiter && corroborated ? "assert" : "verify",
      origin: "echo",
      branchStop,
    };
  }
}
