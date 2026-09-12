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

import { flagOn } from "../runtime-config";
import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { CheckpointAttachment } from "../backends/mlx/checkpoint-state";
import type { DraftProvider, DraftSource, DraftRowCheckpoint, DraftRowGroup, DraftPrefillGroup, GroupedDraftProvider, DraftRowConstraints } from "./source";
import { applyStateChanges } from "../engine/resources";

/** The matching policy is independent of the executor's feed convention. */
function proposeNgram(h: readonly number[], max: number, min: number, n: number): number[] {
  const L = h.length;
  for (let k = Math.min(max, L - 1); k >= min; k--) {
    const tailAt = L - k;
    search: for (let i = 0; i + k < L; i++) {
      for (let j = 0; j < k; j++) if (h[i + j] !== h[tailAt + j]) continue search;
      return h.slice(i + k, i + k + n);
    }
  }
  return [];
}

const namespace = (max: number, min: number) => `ngram-history-v1:${max}:${min}`;
const captureHistory = (history: readonly number[], max: number, min: number): CheckpointAttachment => ({
  schema: "ngram-history-v1", metadata: { max, min }, tensors: [ops.fromInt32([...history], [history.length])],
});
function restoreHistory(state: DraftRowCheckpoint, max: number, min: number): number[] {
  const { attachment, processedTokens } = state;
  if (attachment.schema !== "ngram-history-v1" || attachment.metadata.max !== max || attachment.metadata.min !== min ||
      attachment.tensors.length !== 1 || attachment.tensors[0]!.shape.length !== 1 || attachment.tensors[0]!.shape[0] !== processedTokens)
    throw new Error("ngram checkpoint does not match its token coverage or lookup policy");
  return attachment.tensors[0]!.toIntTokens();
}

/** Each row owns only its committed token history. Verification and sampling
 * remain in the shared method; target storage and scheduling are not needed. */
class NgramRows implements DraftRowGroup, DraftPrefillGroup {
  readonly prefillMode = "tail-split" as const;
  readonly tapLayers: readonly number[] = [];
  readonly namespace: string;
  #histories: number[][] = [];
  #drafts: number[][] = [];
  constructor(readonly max: number, readonly min: number, checkpoints: readonly (DraftRowCheckpoint | null)[],
    readonly constraints?: DraftRowConstraints) {
    this.namespace = namespace(max, min);
    this.append(checkpoints);
  }
  get rowCount() { return this.#histories.length; }
  prepareAppend(checkpoints: readonly (DraftRowCheckpoint | null)[]) {
    let next = [...this.#histories, ...checkpoints.map(state => state ? restoreHistory(state, this.max, this.min) : [])];
    return { commit: () => { const old = this.#histories; this.#histories = next; next = old; }, dispose: () => { next = []; } };
  }
  append(checkpoints: readonly (DraftRowCheckpoint | null)[]) { applyStateChanges([() => this.prepareAppend(checkpoints)]); }
  filterRows(keep: readonly number[]) { this.#histories = keep.map(row => this.#histories[row]!); this.#drafts = []; }
  prefill(tokens: MlxArray): void {
    using packed = ops.contiguous(tokens);
    const ids = packed.toIntTokens(), length = tokens.shape[1]!;
    for (let row = 0; row < this.rowCount; row++) this.#histories[row]!.push(...ids.slice(row * length, (row + 1) * length));
  }
  materialize(): void {}
  draft(pending: readonly number[], depth: number): number[][] | Promise<number[][]> {
    if (this.constraints) {
      for (const [row, history] of this.#histories.entries()) history.push(pending[row]!);
      return Promise.all(this.#histories.map((_, row) => this.constraints!.propose(row, depth)))
        .then(proposals => this.#drafts = proposals);
    }
    this.#drafts = this.#histories.map((history, row) => {
      history.push(pending[row]!);
      return proposeNgram(history, this.max, this.min, depth);
    });
    return this.#drafts;
  }
  commit(accepted: readonly number[]) {
    for (let row = 0; row < this.rowCount; row++) this.#histories[row]!.push(...this.#drafts[row]!.slice(0, accepted[row]!));
    this.#drafts = [];
  }
  capture(row: number): DraftRowCheckpoint {
    const history = this.#histories[row]!;
    return { processedTokens: history.length, attachment: captureHistory(history, this.max, this.min) };
  }
  dispose() { this.#histories = []; this.#drafts = []; }
}

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
  readonly grouped: GroupedDraftProvider = {
    checkpointNamespace: () => namespace(this.max, this.min),
    supportsTargetAdapters: true,
    open: options => new NgramRows(this.max, this.min, options.checkpoints),
    openPrefill: options => new NgramRows(this.max, this.min, options.checkpoints),
  };

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
  readonly #tailSplit = flagOn("MLX_BUN_PREFILL_TAIL_SPLIT", true);
  readonly checkpoint: NonNullable<DraftSource["checkpoint"]>;

  constructor(
    private readonly max: number,
    private readonly min: number,
  ) {
    this.checkpoint = {
      namespace: namespace(max, min),
      capture: () => captureHistory(this.#hist, this.max, this.min),
      restore: (processedTokens, attachment) => {
        this.#hist = restoreHistory({ processedTokens, attachment }, this.max, this.min);
      },
    };
  }

  /** Test hook — the reconstructed prompt+emitted stream (see header). */
  get history(): readonly number[] {
    return this.#hist;
  }

  prefill(promptIds: number[], _context?: Parameters<DraftSource["prefill"]>[1], processedTokens?: number): void {
    // Mirror the serve loop's prefill shape (two-model.ts does the same): under
    // the oracle tail split the last prompt token is never prefilled — it IS
    // the first feed. Legacy shape (kill switch / 1-token prompt): full prompt,
    // and the sampled token0 arrives as the first feed.
    const upTo = processedTokens ?? (this.#tailSplit && promptIds.length > 1 ? promptIds.length - 1 : promptIds.length);
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
    return proposeNgram(this.#hist, this.max, this.min, n);
  }

  dispose(): void {}
}

/** Constraint candidates share committed-history ownership with prompt lookup.
 * They have no serial draft implementation and never perform ngram lookup. */
export function constraintDraftProvider(): { id: string; grouped: GroupedDraftProvider } {
  return {
    id: "grammar",
    grouped: {
      checkpointNamespace: () => namespace(3, 1),
      supportsTargetAdapters: true,
      openPrefill: options => new NgramRows(3, 1, options.checkpoints),
      open: options => new NgramRows(3, 1, options.checkpoints,
        options.constraints ?? { propose: async () => [] }),
    },
  };
}
