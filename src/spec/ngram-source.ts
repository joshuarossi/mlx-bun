// NgramSource — MODEL-FREE prompt-lookup speculative drafting behind the
// DraftSource seam (src/spec/source.ts). No weights, no caches, no tokenizer:
// drafts are copied from the request's own token stream. When the trailing
// k-gram of (prompt + emitted-so-far) has occurred earlier in that stream,
// the tokens that followed the earlier occurrence are proposed as the draft;
// the shared verify/accept executor (src/spec/serve-loop.ts) makes the result
// LOSSLESS by construction (drafts are only proposals — the target's own
// samples decide every emitted token, at any temperature; only the acceptance
// rate moves). Best case: agentic/RAG/code-edit traffic that re-emits spans
// already present in context.
//
// Prior art (ported, not invented): "Prompt Lookup Decoding" (Apoorv Saxena,
// github.com/apoorvumang/prompt-lookup-decoding) and vLLM's `ngram` proposer
// (vllm/v1 spec_decode ngram_proposer) — both match the LONGEST k-gram first
// (k = max..min) and take the FIRST occurrence scanning left-to-right; we
// follow that exactly. Defaults mirror Saxena (max_ngram_size=3,
// num_pred_tokens=10 → our --num-draft-tokens default for this kind).
//
// Token-history reconstruction (the one subtle part): the seam hands sources
// the prompt at prefill() and only the FEED tail each round — never the full
// emitted stream — so this source rebuilds it from the feed/commit discipline
// (same information two-model keeps in its draft KV):
//   - prefill: history = prompt to len-1 under the oracle tail-split shape
//     (the last prompt token arrives as the first round's feed = [pending]);
//     full prompt under the legacy shape (token0 arrives as its feed).
//   - draft(feed): history += feed. feed is [correction] after a rejected
//     round, or [lastDraft, bonus] after an all-accept round (mlx-lm's
//     re-feed rule, generate.py:645-648) — so the all-accept round's LAST
//     draft is deliberately NOT pushed at commit (it arrives here instead).
//   - commit(d, kAccept): history += drafts[0 .. min(kAccept, d-1)) — the
//     accepted drafts except that re-fed last one. Rejected tips never enter
//     history; the correction token arrives via the next feed.
// Invariant at matching time (just after the feed push): history ==
// prompt + every emitted token, ending at the pending/anchor token.
//
// A round with no match returns [] — the serve loop's d=0 semantics degrade
// it to one plain target step (bit-equivalent to non-spec decode), so ngram
// speculation is structurally never worse than plain decode by more than the
// JS scan (~µs against 30k-token histories).

import { flagOn } from "../flags";
import type { DraftProvider, DraftSource } from "./source";

export interface NgramOptions {
  /** Longest suffix k-gram tried first (Saxena max_ngram_size). */
  max?: number;
  /** Shortest k-gram tried before giving up (vLLM prompt_lookup_min). */
  min?: number;
}

export class NgramProvider implements DraftProvider {
  readonly id = "ngram";
  readonly weightsBytes = 0;
  readonly max: number;
  readonly min: number;

  constructor(opts: NgramOptions = {}) {
    this.max = Math.max(1, opts.max ?? 3);
    this.min = Math.max(1, Math.min(opts.min ?? 1, this.max));
  }

  open(_opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    // Sampler and target both ignored: proposals come from lookup, not a
    // model, so drafting is sampler-independent (like the assistant source —
    // correctness holds at any temperature, only acceptance moves).
    return new NgramSource(this.max, this.min);
  }

  dispose(): void {}
}

class NgramSource implements DraftSource {
  readonly weightsBytes = 0;
  #hist: number[] = [];
  #lastDrafts: number[] = [];

  constructor(
    private readonly max: number,
    private readonly min: number,
  ) {}

  /** Test hook — the reconstructed prompt+emitted stream (see header). */
  get history(): readonly number[] {
    return this.#hist;
  }

  prefill(promptIds: number[]): void {
    // Mirror the serve loop's prefill shape (two-model.ts does the same): under
    // the oracle tail split the last prompt token is never prefilled — it IS
    // the first feed. Legacy shape (kill switch / 1-token prompt): full prompt,
    // and the sampled token0 arrives as the first feed.
    const tailSplit = flagOn("MLX_BUN_PREFILL_TAIL_SPLIT", true);
    const upTo = tailSplit && promptIds.length > 1 ? promptIds.length - 1 : promptIds.length;
    this.#hist = promptIds.slice(0, upTo);
  }

  draft(feed: number[], n: number, _stepBase: number): number[] {
    this.#hist.push(...feed);
    this.#lastDrafts = this.#propose(n);
    return this.#lastDrafts;
  }

  commit(d: number, kAccept: number): void {
    // Accepted drafts join history, EXCEPT an all-accept round's last draft —
    // the serve loop re-feeds it ([lastDraft, bonus]) and the next draft()'s
    // feed push would double it (see header). d=0 rounds push nothing.
    const upTo = Math.max(0, Math.min(kAccept, d - 1));
    for (let i = 0; i < upTo; i++) this.#hist.push(this.#lastDrafts[i]!);
  }

  /** Longest-k-first, first-occurrence prompt lookup (Saxena/vLLM order):
   *  find the trailing k-gram earlier in history, propose what followed it. */
  #propose(n: number): number[] {
    const h = this.#hist;
    const L = h.length;
    const kTop = Math.min(this.max, L - 1);
    for (let k = kTop; k >= this.min; k--) {
      const tailAt = L - k;
      // First occurrence, left to right; i + k < L both excludes the trailing
      // self-match and guarantees at least one continuation token.
      search: for (let i = 0; i + k < L; i++) {
        for (let j = 0; j < k; j++) {
          if (h[i + j] !== h[tailAt + j]) continue search;
        }
        return h.slice(i + k, i + k + n);
      }
    }
    return [];
  }

  dispose(): void {}
}
