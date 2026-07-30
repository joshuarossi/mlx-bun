// DraftSource — the seam between the serve-time speculative verify loop
// (src/spec/serve-loop.ts) and whatever produces draft tokens. Designed in
// docs/design/mlx-lm-tool-parity-plan.md §7 so every drafter shares ONE
// verify/accept executor:
//   - TwoModelSource (src/spec/two-model.ts) — mlx-lm parity (L1 oracle:
//     mlx_lm.server --draft-model), a full second model. Ignores `target`.
//   - AssistantSource (src/spec/assistant-source.ts) — the optiq KV-borrowing
//     Gemma drafter (src/spec/drafter.ts; L2 oracle: optiq spec_generate).
//     Reads the target's donor K/V + anchor hidden each step.
//   - DflashSource (src/spec/dflash-source.ts) — DSpark (L3, KL/quality-gated).
//     Taps the target's multi-layer hiddens (prefill + verify) into a growing
//     H_ctx (docs/design/dspark-speculative-decoding.md).
//   - NgramSource (src/spec/ngram-source.ts) — model-free prompt lookup.
//   - Glm52NativeMtpSource (src/spec/glm52-mtp-source.ts) — the target
//     artifact's native Colibri MTP row.
//
// The sources differ ONLY in what fills the draft; the serve loop, admission
// accounting, and stats never change. The KV-borrowing sources need target
// state the two-model source doesn't — carried by the `target` view at open()
// and the optional prefill/draft/commit arguments below (all no-ops for
// two-model). See [[dspark-seam-kv-borrowing]].

import type { MlxArray } from "../mlx/array";
import type { RuntimeModel } from "../model/factory";
import type { Cache } from "../model/gemma4";

/** Read-only handle to the target's live decode state, handed to every source
 *  at open(). Two-model ignores it; KV-borrowing sources read the target's
 *  model (embed / lm-head / the draft module) and its LIVE cache array (donor
 *  K/V views + offset — the SAME caches the serve loop drives). */
export interface TargetView {
  readonly model: RuntimeModel;
  readonly caches: Cache[];
}

/** A per-request draft-token producer. Created per generation (owns its own
 *  draft-side state), disposed by the serve loop's finally. */
export interface DraftSource {
  /** Target prefill shape required by this source's oracle. Most mlx-lm
   *  sources leave the final prompt token pending; native Colibri MTP starts
   *  from a full-prompt target forward. */
  readonly prefillMode?: "tail-split" | "full";
  /** Request one fixed target kernel family across the speculative verify
   * batch. Native GLM MTP uses the direct-Colibri SPEC_PIN contract. */
  readonly pinTargetKernelFamily?: boolean;

  /** Multi-layer target tap the source needs captured on the target's prefill
   *  AND every verify forward (DSpark's H_ctx; e4b {20,31,41,42}). When set,
   *  the serve loop sets model.hiddenTap around those forwards and passes the
   *  captured context [1,L,m*H] into prefill()/commit(). Undefined for sources
   *  that don't tap (two-model, assistant). */
  readonly tapLayers?: number[];

  /** Process the prompt (two-model: prefill the draft model's cache;
   *  assistant/dflash: read the target's state — mostly a no-op, but DSpark
   *  seeds H_ctx from `ctxML`, the tapped prefill context [1,Lp,m*H], present
   *  iff tapLayers is set). */
  prefill(promptIds: number[], ctxML?: MlxArray): void | Promise<void>;

  /** Propose 0..n tokens (RETURN LENGTH IS AUTHORITATIVE — a source may
   *  return fewer than n, e.g. DSpark's confidence-scheduled draft-length
   *  pruning; ZERO means "skip drafting this round" — DeepSpec ℓ=0 semantics,
   *  the serve loop degenerates to one plain target step, still tapped +
   *  committed for context-growing sources). The serve loop verifies over
   *  exactly the returned length. `feed` is the token(s) the draft has not
   *  yet consumed: [pending]
   *  after a rejection/first round, or [lastDraft, bonus] after an all-accept
   *  round (mlx-lm's re-feed rule, generate.py:645-648). `stepBase` is the
   *  emitted-token index, threaded to the sampler for per-step RNG streams.
   *  `anchorHidden` is the target's final hidden [1,1,H] at the pending/anchor
   *  position — the assistant source borrows it for its first draft step;
   *  two-model and dflash ignore it. */
  draft(
    feed: number[],
    n: number,
    stepBase: number,
    anchorHidden?: MlxArray,
  ): number[] | Promise<number[]>;

  /** Verify outcome for the last round: kAccept of d accepted, where d is the
   *  length draft() actually RETURNED (≤ n). Two-model: trim the draft cache
   *  by max(d - kAccept - 1, 0) — mlx-lm's rewind rule (generate.py:589-591).
   *  DSpark: grow H_ctx by the accepted window from `vCtxML`, the verified
   *  window's tapped context [1,d+1,m*H] (present iff tapLayers is set), and
   *  drop the rejected tips. */
  commit(
    d: number,
    kAccept: number,
    vCtxML?: MlxArray,
    verifiedHidden?: MlxArray,
    acceptedTokens?: readonly number[],
  ): void | Promise<void>;

  /** Resident per-request draft weights, for admission accounting (0 when the
   *  provider owns the weights). */
  readonly weightsBytes: number;
  dispose(): void;
}

/** Server-lifetime owner of the draft machinery (the loaded draft model);
 *  open() mints a per-request DraftSource. */
export interface DraftProvider {
  /** Human-readable id (registry id / path tail) for logs + cache namespacing. */
  readonly id: string;
  readonly weightsBytes: number;
  open(opts: {
    /** The request's sampler over logprobs [1,V] → token array [1] (the SAME
     *  sampler as the target — mlx-lm parity; greedy drafting under a
     *  temperature>0 request is NOT parity). */
    sampler: (logprobs: MlxArray, step: number) => MlxArray;
    /** The target model + its live caches (donor views / offset). */
    target: TargetView;
  }): DraftSource;
  dispose(): void;
}
