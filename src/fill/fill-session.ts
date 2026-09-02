// Token fast-forwarding (K3) — the per-request proposal table.
//
// DOCTRINE. This is PURE CONTEXT EXTENSION, not speculation. A transformer is
// a next-token function over a token sequence; it has no memory of who wrote
// which token, so an APPENDED token is indistinguishable from a sampled one.
// When the engine already knows the next m tokens (a chat template's tool-call
// scaffold is a deterministic function of the request's `tools`), it appends
// them itself with ONE chunked forward and resumes sampling after them. No
// draft, no verify, no rollback, and no comparison against what the model
// "would have" produced — nothing here routes through src/spec/.
//
// The echo tier (K3c) adds a weaker claim over the SAME mechanism: a span
// copied from earlier in the session, held under policy "verify" — the engine
// keeps the prefix the model agrees with (read from the free logits of the
// very same forward) and rewinds the rest. See ./proposal.ts for the two
// policies and ./echo-index.ts for the branch-point rule.
//
// This module is bookkeeping only: it owns the running history, runs the
// sources in priority order, clamps what they return, and counts. It never
// touches MLX, the tokenizer, or the template. Row COMPILATION is
// ./schema-rows.ts.
import { flagOn, runtimeNumber, runtimeValue } from "../runtime-config";
import { EchoSource, type EchoConfig } from "./echo-index";
import type {
  Proposal, ProposalOrigin, ProposalPolicy, ProposalSource, TokenView,
} from "./proposal";

export type { Proposal, ProposalPolicy, ProposalSource, TokenView };

/** Which producer a strict row came from (telemetry + the mismatch policy). */
export type FillKind = "scaffold" | "name" | "key" | "close" | "turn-end";

export interface FillRow {
  /** Token ids that must be the TAIL of the generated history for this row to
   *  fire (matched as an exact suffix ending at the token just pushed). */
  trigger: number[];
  /** Ids appended immediately after the trigger. Sliced out of a full
   *  template rendering — never `encode(fragment)` in isolation. */
  emit: number[];
  kind: FillKind;
}

/** Echo-tier (K3c) configuration; null disables the source entirely. */
export interface FillEchoConfig {
  k: number;
  maxSpan: number;
  maxCandidates: number;
  indexMax: number;
}

export interface FillPlan {
  rows: FillRow[];
  /** Echo tier: null = strict rows only (MLX_BUN_FILL=strict). */
  echo: FillEchoConfig | null;
  /** Token ids that legitimately END an injected span — the closing quote /
   *  markup that follows an argument value, derived from the template by the
   *  strict-row compiler. A span is cut so it ends AT the first delimiter it
   *  contains, never past one. */
  delimiters?: ReadonlySet<number>;
  /** EOS ids. An injected span is cut BEFORE the first one: end-of-generation
   *  is the model's decision, never ours. (The grammar jump burst yields its
   *  ids with NO eos check — that bug is deliberately not inherited.) */
  eos: number[];
}

export interface FillStats {
  /** Fills that put at least one token into the stream. */
  events: number;
  /** Total injected tokens (billed as generated). */
  injected: number;
  /** …from strict schema/template rows (always policy "assert"). */
  strict: number;
  /** …from the echo index. */
  echo: number;
  /** Length of each injected span, in event order. */
  spanLens: number[];
  /** In-flight sampled tokens dropped unexamined at an ASSERT fill — a
   *  discarded pipeline dispatch, NOT a rejected draft. */
  wastedSamples: number;
  /** Tool-call parses that failed after strict rows had fired. */
  parseFallback: number;
  /** Spans shortened by a clamp (EOS / delimiter / max span / budget). */
  indexTruncated: number;
  /** Tokens the model actually sampled (the real decode steps). */
  decodeSteps: number;
  /** Verify-policy proposals that reached the forward. */
  verifyEvents: number;
  /** Tokens accepted under verify (the model's own argmax agreed). */
  verifyAccepted: number;
  /** Tokens proposed under verify and dropped (incl. rejected-at-position-0,
   *  which costs nothing — that check happens before the forward). */
  verifyRejected: number;
  /** Verify proposals dropped because this model's caches cannot rewind. */
  verifyUnsupported: number;
  /** Wall time in cache checkpoint / rollback / commit (verify only). */
  checkpointMs: number;
  /** Echo spans that stopped because the session history forked. */
  branchStops: number;
}

const emptyStats = (): FillStats => ({
  events: 0, injected: 0, strict: 0, echo: 0, spanLens: [],
  wastedSamples: 0, parseFallback: 0, indexTruncated: 0, decodeSteps: 0,
  verifyEvents: 0, verifyAccepted: 0, verifyRejected: 0, verifyUnsupported: 0,
  checkpointMs: 0, branchStops: 0,
});

export type FillMode = "off" | "strict" | "echo";

/** MLX_BUN_FILL=off|strict|echo (default off). `echo` is additive: the strict
 *  rows still apply (and stay policy "assert"); the echo index joins as a
 *  second, weaker source. Lab tier — default off, A/B before any default. */
export function resolveFillMode(): FillMode {
  const raw = runtimeValue("MLX_BUN_FILL");
  if (raw === undefined || raw === "" || raw === "off" || raw === "0") return "off";
  if (raw === "strict" || raw === "1") return "strict";
  if (raw === "echo") return "echo";
  throw new Error(`MLX_BUN_FILL=${raw}: expected off|strict|echo`);
}

/** Hard cap on one injected span (MLX_BUN_FILL_MAX_SPAN, default 32). */
export function fillMaxSpan(): number {
  const n = Math.floor(runtimeNumber("MLX_BUN_FILL_MAX_SPAN", 32));
  return n >= 2 ? n : 2;
}

/** Echo-tier knobs. k: anchor length (MLX_BUN_FILL_K, default 8 — the corpus
 *  study's token-level threshold). candidates: nearest-occurrence bucket cap
 *  (MLX_BUN_FILL_CANDIDATES, default 24). indexMax: token cap on the growing
 *  index (MLX_BUN_FILL_INDEX_MAX, default 131072). */
export function fillEchoConfig(): FillEchoConfig {
  return {
    k: Math.max(2, Math.floor(runtimeNumber("MLX_BUN_FILL_K", 8))),
    maxSpan: fillMaxSpan(),
    maxCandidates: Math.max(1, Math.floor(runtimeNumber("MLX_BUN_FILL_CANDIDATES", 24))),
    indexMax: Math.max(1024, Math.floor(runtimeNumber("MLX_BUN_FILL_INDEX_MAX", 131072))),
  };
}

/** MLX_BUN_FILL_TRACE=1 — cache-alignment assertions + per-event logging on
 *  the engine's fill path. Off by default (the invariant it checks is the
 *  easiest bug in the feature, and the check costs a JS compare). */
export function fillTraceEnabled(): boolean {
  return flagOn("MLX_BUN_FILL_TRACE", false) || fillTracePath() !== null;
}

/** MLX_BUN_FILL_TRACE=<file.jsonl> — additionally append one record per
 *  proposal: the proposed ids/text next to what the model's OWN logits said
 *  at every span position (position 0 = the in-flight sample, j>0 = argmax
 *  after ids[j-1]), for BOTH policies. Under `assert` the readback is
 *  trace-only (one lm_head over the span) — the served path never pays it.
 *  This is the list that answers "would the model have produced this span?"
 *  without a verify pass in production. */
export function fillTracePath(): string | null {
  const raw = runtimeValue("MLX_BUN_FILL_TRACE");
  if (raw === undefined || raw === "" || raw === "0" || raw === "1" || raw === "true") return null;
  return raw;
}

export interface FillTraceRecord {
  ts: string;
  origin: string;
  policy: string;
  generated: number;
  proposedLen: number;
  accepted: number;
  /** Index of the first position where the model disagreed, or -1. */
  firstMismatch: number;
  proposed: number[];
  actual: number[];
  proposedText?: string;
  actualText?: string;
}

/** Strict schema/template rows as a ProposalSource. Always policy "assert":
 *  the spans are sliced out of the model's own chat template, so they are
 *  determined by construction, not guessed. */
export class StrictRowSource implements ProposalSource {
  readonly name = "strict";
  readonly #byLastTrigger = new Map<number, FillRow[]>();
  /** Longest trigger — the tail this source needs to match against. */
  readonly maxTrigger: number = 1;
  get windowNeeded(): number { return this.maxTrigger; }
  #enabled = true;

  constructor(rows: readonly FillRow[]) {
    for (const row of rows) {
      if (row.trigger.length === 0 || row.emit.length === 0) continue;
      this.maxTrigger = Math.max(this.maxTrigger, row.trigger.length);
      const last = row.trigger[row.trigger.length - 1]!;
      const bucket = this.#byLastTrigger.get(last);
      if (bucket) bucket.push(row);
      else this.#byLastTrigger.set(last, [row]);
    }
    // Longest trigger wins (most specific row); plan order breaks ties.
    for (const bucket of this.#byLastTrigger.values())
      bucket.sort((a, b) => b.trigger.length - a.trigger.length);
  }

  get enabled(): boolean { return this.#enabled; }
  disable(): void { this.#enabled = false; }

  propose(view: TokenView): Proposal | null {
    if (!this.#enabled) return null;
    const tail = view.tail(this.maxTrigger);
    const last = tail[tail.length - 1];
    if (last === undefined) return null;
    const bucket = this.#byLastTrigger.get(last);
    if (!bucket) return null;
    for (const row of bucket) {
      const t = row.trigger;
      if (t.length > tail.length) continue;
      const base = tail.length - t.length;
      let ok = true;
      for (let i = 0; i < t.length; i++) {
        if (tail[base + i] !== t[i]) { ok = false; break; }
      }
      if (ok) {
        return {
          ids: [...row.emit],
          policy: "assert",
          // The scaffold and the close come from the TEMPLATE; the name and
          // key spans are what the request's SCHEMA determines.
          origin: row.kind === "name" || row.kind === "key" ? "schema" : "template",
        };
      }
    }
    return null;
  }
}

/** One request's proposal sources plus the running match state.
 *
 *  CONTRACT. push() returns a proposal; the caller MUST then call commit()
 *  exactly once with the number of ids it actually emitted (all of them for an
 *  assert, the accepted prefix for a verify, 0 when it declined). Nothing
 *  enters the session's history until commit — so a partial accept needs no
 *  rollback here. */
export class FillSession {
  readonly stats: FillStats = emptyStats();
  readonly #sources: ProposalSource[];
  readonly #strict: StrictRowSource;
  readonly #eos: Set<number>;
  readonly #delimiters: ReadonlySet<number>;
  readonly #maxSpan: number;
  readonly #window: number;
  /** Bounded tail of the token history — all a source can see directly (the
   *  echo index keeps its own full copy via observe()). */
  #tail: number[] = [];
  #length = 0;
  #budget = Number.POSITIVE_INFINITY;

  /** Optional token→text decoder for the proposal trace (set by the serve
   *  layer, which owns the tokenizer). */
  readonly decode: ((ids: readonly number[]) => string) | null;

  constructor(
    readonly plan: FillPlan,
    promptIds: readonly number[],
    options: { maxSpan?: number; sources?: ProposalSource[]; decode?: (ids: readonly number[]) => string } = {},
  ) {
    this.decode = options.decode ?? null;
    this.#eos = new Set(plan.eos);
    this.#delimiters = plan.delimiters ?? new Set<number>();
    this.#maxSpan = Math.max(2, Math.floor(options.maxSpan ?? fillMaxSpan()));
    this.#strict = new StrictRowSource(plan.rows);
    const echo = plan.echo
      ? new EchoSource(
        { ...plan.echo, maxSpan: this.#maxSpan, delimiters: this.#delimiters } as EchoConfig,
        promptIds,
      )
      : null;
    // Priority: determined before guessed, then anything the caller injected
    // (the seam the spec lane's DraftSources would adapt onto — see
    // proposal.ts MIGRATION NOTE).
    this.#sources = [
      this.#strict,
      ...(echo ? [echo] : []),
      ...(options.sources ?? []),
    ];
    // Every source declares the tail it needs; the session retains the max.
    this.#window = Math.max(
      1, ...this.#sources.map((s) => s.windowNeeded ?? 1),
    );
    // A row may be triggered by the prompt's own tail (a re-rendered turn that
    // ends mid-scaffold), so the history starts seeded.
    this.#tail = promptIds.slice(Math.max(0, promptIds.length - this.#window));
    this.#length = promptIds.length;
  }

  /** Are strict rows still armed? (Cleared by noteParseFailure.) */
  get strictEnabled(): boolean { return this.#strict.enabled; }

  /** Feed one SAMPLED token, then ask the sources what follows. `budget` is
   *  the caller's remaining allowance (max_tokens − generated). */
  push(tokenId: number, budget: number = Number.POSITIVE_INFINITY): Proposal | null {
    this.stats.decodeSteps++;
    this.#append([tokenId]);
    this.#budget = budget;
    for (const source of this.#sources) {
      const proposal = source.propose(this);
      if (!proposal) continue;
      if (proposal.branchStop) this.stats.branchStops++;
      const clamped = this.#clamp(proposal.ids, budget, proposal.origin === "echo");
      if (!clamped) continue;
      // An assert claim that a clamp cut short for any reason OTHER than
      // ending at a delimiter is no longer the claim the source made. Strict
      // rows are exempt: they are determined by construction, and a budget
      // clamp shortens the span without weakening it.
      const weakened = proposal.origin === "echo" &&
        clamped.ids.length !== proposal.ids.length &&
        !this.#delimiters.has(clamped.ids[clamped.ids.length - 1]!);
      return {
        ...proposal,
        ids: clamped.ids,
        policy: weakened ? "verify" : proposal.policy,
      };
    }
    return null;
  }

  /** Record what the engine actually emitted from `proposal` (all of it for an
   *  assert; the accepted prefix for a verify; 0 when the engine declined).
   *  MUST be called exactly once per proposal returned by push(). */
  commit(proposal: Proposal, accepted: number): void {
    const n = Math.max(0, Math.min(accepted, proposal.ids.length));
    const rejected = proposal.ids.length - n;
    if (proposal.policy === "verify") {
      this.stats.verifyAccepted += n;
      this.stats.verifyRejected += rejected;
    }
    if (n === 0) return;
    const ids = proposal.ids.slice(0, n);
    this.#append(ids);
    this.stats.events++;
    this.stats.injected += n;
    if (proposal.origin === "echo") this.stats.echo += n;
    else this.stats.strict += n;
    this.stats.spanLens.push(n);
  }

  /** A verify proposal reached the forward (the checkpoint was taken). */
  noteVerifyEvent(checkpointMs: number): void {
    this.stats.verifyEvents++;
    this.stats.checkpointMs += checkpointMs;
  }

  /** A verify proposal was dropped: this model's caches cannot rewind. */
  noteVerifyUnsupported(): void {
    this.stats.verifyUnsupported++;
  }

  /** The engine dropped an in-flight sampled token to take an ASSERT fill. */
  noteWastedSample(): void {
    this.stats.wastedSamples++;
  }

  /** The tool-call parser rejected this request's markup. Strict rows are
   *  disarmed for the rest of the request — the template's own rendering
   *  disagreed with what the model actually emits, so every further row is
   *  suspect. (Echo rows are unaffected: they never claimed to be schema.)
   *
   *  REALITY NOTE: the served parse (ToolAwareStream.toolCalls →
   *  parseGeneratedToolCalls) runs at sink FLUSH, i.e. after the generation
   *  has ended, so within one request this is telemetry and the disarm has no
   *  remaining tokens to act on. The seam is here so a future incremental
   *  parse (or a plan cached across requests) disarms for real. */
  noteParseFailure(): void {
    if (this.stats.strict === 0) return; // no strict row armed this request
    this.stats.parseFallback++;
    this.#strict.disable();
  }

  // --- TokenView ---------------------------------------------------------
  get length(): number { return this.#length; }
  get budget(): number { return this.#budget; }
  tail(n: number): readonly number[] {
    return n >= this.#tail.length ? this.#tail : this.#tail.slice(this.#tail.length - n);
  }

  #append(ids: readonly number[]): void {
    this.#length += ids.length;
    for (const source of this.#sources) source.observe?.(ids);
    this.#tail.push(...ids);
    if (this.#tail.length > this.#window)
      this.#tail.splice(0, this.#tail.length - this.#window);
  }

  /** Clamp order: EOS → delimiter → max span / caller budget → reject <2.
   *  A one-token span saves no forward (the engine already had that token's
   *  successor in flight), so it is never worth the discarded dispatch.
   *
   *  `applyDelimiters` is ECHO-ONLY. A delimiter marks where an argument VALUE
   *  ends, which is exactly where a copied span must stop — but a template
   *  scaffold legitimately contains the same tokens as structure (`{"name": "`
   *  is three quotes deep), and it is determined by construction. Clamping
   *  strict rows on delimiters would cut every scaffold at its first quote. */
  #clamp(
    emit: readonly number[], budget: number, applyDelimiters: boolean,
  ): { ids: number[]; truncated: boolean } | null {
    let ids = emit as number[];
    let truncated = false;
    for (let i = 0; i < ids.length; i++) {
      if (this.#eos.has(ids[i]!)) { ids = ids.slice(0, i); truncated = true; break; }
    }
    if (applyDelimiters && this.#delimiters.size) {
      for (let i = 0; i < ids.length; i++) {
        // A span may END at a delimiter — injecting the closing quote is the
        // point — but never continue past one.
        if (this.#delimiters.has(ids[i]!)) {
          if (i + 1 < ids.length) { ids = ids.slice(0, i + 1); truncated = true; }
          break;
        }
      }
    }
    const cap = Math.min(
      this.#maxSpan,
      Number.isFinite(budget) ? Math.max(0, Math.floor(budget)) : this.#maxSpan,
    );
    if (ids.length > cap) { ids = ids.slice(0, cap); truncated = true; }
    if (ids.length < 2) return null;
    if (truncated) this.stats.indexTruncated++;
    return { ids: ids === emit ? [...ids] : ids, truncated };
  }
}

export type { ProposalOrigin };
