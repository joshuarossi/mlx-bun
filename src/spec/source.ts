// DraftSource — the seam between the serve-time speculative verify loop
// (src/spec/serve-loop.ts) and whatever produces draft tokens. Designed in
// docs/reference/cli.md §7 so every drafter shares ONE
// verify/accept executor:
//   - TwoModelSource (src/spec/two-model.ts) — mlx-lm parity (L1 oracle:
//     mlx_lm.server --draft-model), a full second model. Ignores `target`.
//   - AssistantSource (src/spec/assistant-source.ts) — the optiq KV-borrowing
//     Gemma drafter (src/spec/drafter.ts; L2 oracle: optiq spec_generate).
//     Reads the target's donor K/V + anchor hidden each step.
//   - DflashSource (src/spec/dflash-source.ts) — DSpark (L3, KL/quality-gated).
//     Taps the target's multi-layer hiddens (prefill + verify) into a growing
//     H_ctx (docs/design/speculative-decoding.md).
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
import type { Dtype } from "../mlx/ffi";
import type { Cache } from "../model/gemma4";
import type { CheckpointAttachment } from "../backends/mlx/checkpoint-state";
import type { MlxDraftRows } from "../backends/mlx/speculative-round";
import type { PreparedStateChange } from "../contracts/resources";

/** Numerical ports are backend-specific; returned arrays are caller-owned. */
export interface DraftProjection {
  readonly embed: {
    encode(ids: MlxArray): MlxArray;
    readonly scales: { readonly dtype: Dtype };
  };
  logitsFromHidden(hidden: MlxArray): MlxArray;
}

/** Read-only target state and embedding, independent of draft scheduling. */
export interface AssistantRowsTarget {
  readonly hiddenSize: number;
  embed(ids: MlxArray): MlxArray;
  readDonors(): import("./drafter").AssistantDonors & {
    readonly positions: readonly number[];
    dispose(): void;
  };
}

export interface QwenMtpTarget {
  readonly hiddenSize: number;
  readonly layerCount: number;
  embed(ids: MlxArray): MlxArray;
  logitsFromHidden(hidden: MlxArray): MlxArray;
}

/** Graph-declared extensions over the target's live state. Sources request
 * only the ports they consume; they never inspect a concrete model or cache.
 * Absence refuses an unsupported pairing before draft-side allocation. */
export interface TargetView {
  /** Opaque identity for providers borrowing weights from one exact target. */
  readonly identity: object;
  readonly assistantRows?: AssistantRowsTarget;
  readonly gemmaTaps?: { readonly layerCount: number; readonly projection: DraftProjection };
  readonly qwenMtp?: QwenMtpTarget;
}

/** A per-request draft-token producer. Created per generation (owns its own
 *  draft-side state), disposed by the serve loop's finally. */
export interface DraftSource {
  /** Method-owned companion state, independent of retention and storage.
   * Capture returns owned immutable views. Restore borrows its attachment;
   * the source retains the views it needs before returning. */
  readonly checkpoint?: {
    readonly namespace: string;
    capture(processedTokens: number): import("../backends/mlx/checkpoint-state").CheckpointAttachment;
    restore(processedTokens: number, attachment: import("../backends/mlx/checkpoint-state").CheckpointAttachment): void;
  };
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
   *  iff tapLayers is set). A composed prefill may supply its exact processed
   *  token count, so a history source need not infer the target's boundary. */
  prefill(promptIds: number[], ctxML?: MlxArray, processedTokens?: number): void | Promise<void>;

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
   *  drop the rejected tips. Native GLM MTP receives the target's verified
   *  hidden window [1,d+1,H] in `verifiedHidden` and the kAccept accepted token
   *  ids in `acceptedTokens`; it uses them to rebuild accepted MTP KV rows
   *  from target state rather than recursively drafted hidden state. */
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

export interface DraftRowSampling {
  /** Borrow [B,V] log-probabilities; return owned [B] IDs on device. */
  sample(logprobs: MlxArray, steps: readonly number[]): MlxArray;
}

/** Request-owned constraints can propose known continuations without changing
 * their committed state. The target verifier still decides every output. */
export interface DraftRowConstraints {
  propose(row: number, maxTokens: number): Promise<number[]>;
}

export interface DraftRowCheckpoint {
  readonly processedTokens: number;
  readonly attachment: CheckpointAttachment;
}

/** Method-owned state membership, independent of scheduling and cache tiers.
 * Open/append borrow checkpoints; capture returns owned immutable state.
 * Membership changes and capture occur only between committed rounds.
 * The caller retains the provider's residency lease for the group's lifetime. */
export interface DraftRowGroup extends MlxDraftRows {
  readonly namespace: string;
  readonly tapLayers: readonly number[];
  readonly rowCount: number;
  append(checkpoints: readonly DraftRowCheckpoint[]): void;
  prepareAppend(checkpoints: readonly DraftRowCheckpoint[]): PreparedStateChange;
  filterRows(keep: readonly number[]): void;
  capture(row: number): DraftRowCheckpoint;
  dispose(): void;
}

/** Draft preparation consumes each target chunk at the same batch geometry.
 * Inputs are borrowed and contain only new tokens/context, with equal chunk
 * lengths across rows. A null checkpoint appends a cold request. The provider
 * owns alignment and retained hidden state; scheduling and persistence do not.
 * Membership and capture occur between prefill calls. Capture returns owned
 * state after at least one target token has been consumed for that row. */
export interface DraftPrefillGroup {
  readonly namespace: string;
  readonly prefillMode: NonNullable<DraftSource["prefillMode"]>;
  readonly tapLayers: readonly number[];
  readonly rowCount: number;
  append(checkpoints: readonly (DraftRowCheckpoint | null)[]): void;
  prepareAppend(checkpoints: readonly (DraftRowCheckpoint | null)[]): PreparedStateChange;
  prefill(tokens: MlxArray, context?: MlxArray): void | Promise<void>;
  /** Resolve borrowed backing before its external restore lease is released. */
  materialize(): void;
  filterRows(keep: readonly number[]): void;
  capture(row: number): DraftRowCheckpoint;
  dispose(): void;
}

export interface GroupedDraftProvider {
  /** Resolve persistence identity without allocating a draft row. */
  checkpointNamespace?(): string;
  /** Draft state remains valid when target forwards run under a mounted
   * adapter context. Unqualified learned draft graphs leave this absent. */
  readonly supportsTargetAdapters?: boolean;
  openPrefill(options: { target: TargetView;
    checkpoints: readonly (DraftRowCheckpoint | null)[] }): DraftPrefillGroup;
  open(options: { target: TargetView; sampling: DraftRowSampling; constraints?: DraftRowConstraints;
    checkpoints: readonly DraftRowCheckpoint[] }): DraftRowGroup;
}

/** Server-lifetime owner of the draft machinery (the loaded draft model);
 * open() mints a per-request DraftSource; grouped opens shared row state. */
export interface DraftProvider {
  /** Human-readable id (registry id / path tail) for logs + cache namespacing. */
  readonly id: string;
  readonly weightsBytes: number;
  readonly grouped?: GroupedDraftProvider;
  open(opts: {
    /** The request's sampler over logprobs [1,V] → token array [1] (the SAME
     *  sampler as the target — mlx-lm parity; greedy drafting under a
     *  temperature>0 request is NOT parity). */
    sampler: (logprobs: MlxArray, step: number) => MlxArray;
    /** Bound target capabilities, with explicit donor-view ownership. */
    target: TargetView;
  }): DraftSource;
  dispose(): void;
}
