// One interface for every source that can propose the next tokens.
//
// A proposal is a claim about the sequence, plus how strongly it is held:
//
//   assert — the tokens are DETERMINED (a chat template's tool-call scaffold
//            is a function of the request's `tools`). The engine appends them
//            and moves on: no readback, no rewind, no checkpoint. This is
//            context extension, not speculation.
//   verify — the tokens are LIKELY (a span copied from earlier in the same
//            session). The engine appends them in the same single forward,
//            then reads the argmax already sitting in that forward's logits
//            at every span position — free, no extra pass — keeps the agreed
//            prefix, rewinds the rest, and resumes decode at the first
//            disagreement.
//
// Both policies share the expensive half: ONE chunked forward that advances
// the KV (and recurrent SSM state) over the whole span. That shared primitive
// lives in generate.ts; everything here is bookkeeping.
//
// MIGRATION NOTE. The shipped speculative lane (src/spec/) has its own
// `DraftSource` seam with a verify/rollback executor of its own (ngram, MTP,
// two-model, DSpark). Those are NOT rewired onto this interface in this phase
// — the adapter (a DraftSource wrapped as a `verify`-policy ProposalSource, so
// one apply primitive serves both lanes) is future work, deliberately deferred
// so the spec lane's oracles stay untouched.

/** What a source can see of the sequence so far. */
export interface TokenView {
  /** Tokens seen: prompt + everything emitted (injected tokens included). */
  readonly length: number;
  /** The last `n` ids, oldest first. Shorter near the start of a request, and
   *  bounded by the session's retained window — a source that needs more
   *  history keeps its own copy (see observe()). */
  tail(n: number): readonly number[];
  /** Tokens the caller may still emit (max_tokens − generated). */
  readonly budget: number;
}

/** How strongly a proposal is held — see the file header. */
export type ProposalPolicy = "assert" | "verify";

/** Where a proposal came from. `ngram`/`mtp` are reserved for the spec-lane
 *  adapter that does not exist yet (see MIGRATION NOTE). */
export type ProposalOrigin = "schema" | "template" | "echo" | "ngram" | "mtp";

export interface Proposal {
  ids: number[];
  policy: ProposalPolicy;
  origin: ProposalOrigin;
  /** Echo only: the span stopped because the session history forked here
   *  (multiple distinct continuations). Telemetry + policy input. */
  branchStop?: boolean;
}

export interface ProposalSource {
  readonly name: string;
  /** How many trailing tokens this source needs to see in `TokenView.tail`.
   *  The session retains the maximum across its sources; a source that needs
   *  more history than that keeps its own copy (see observe()). */
  readonly windowNeeded?: number;
  /** Propose the tokens that follow `tail`, or null. The caller clamps
   *  (EOS / delimiter / max span / budget), so a source may return more than
   *  the budget allows. */
  propose(tail: TokenView): Proposal | null;
  /** Every token that actually entered the sequence — sampled or injected —
   *  in order. Sources that maintain an index grow it here. */
  observe?(ids: readonly number[]): void;
}
