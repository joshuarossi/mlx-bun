// DraftSource — the seam between the serve-time speculative verify loop
// (src/spec/serve-loop.ts) and whatever produces draft tokens. Designed in
// docs/design/mlx-lm-tool-parity-plan.md §7 so three drafters share ONE
// verify/accept executor:
//   - TwoModelSource (src/spec/two-model.ts) — mlx-lm parity (L1 oracle:
//     mlx_lm.server --draft-model), a full second model.
//   - AssistantSource (later) — the optiq KV-borrowing Gemma drafter
//     (src/spec/drafter.ts; L2 oracle: optiq spec_generate).
//   - DflashSource (later) — DSpark (L3, KL/quality-gated).
// The draft-vs-MTP-head difference is just what fills the draft; the serve
// loop, admission accounting, and stats never change.

/** A per-request draft-token producer. Created per generation (owns its own
 *  draft-side caches), disposed by the serve loop's finally. */
export interface DraftSource {
  /** Process the prompt (two-model: prefill the draft model's cache;
   *  assistant/dflash sources are no-ops — they read the target's state). */
  prefill(promptIds: number[]): void;
  /** Propose up to n tokens. `feed` is the token(s) the draft model has not
   *  yet consumed: [pending] after a rejection/first round, or
   *  [lastDraft, bonus] after an all-accept round (mlx-lm's re-feed rule,
   *  generate.py:645-648). `stepBase` is the emitted-token index, threaded
   *  to the sampler for per-step RNG streams. */
  draft(feed: number[], n: number, stepBase: number): number[];
  /** Verify outcome for the last draft(n) round: kAccept of n accepted.
   *  Two-model: trim the draft cache by max(n - kAccept - 1, 0) — mlx-lm's
   *  rewind rule (generate.py:589-591). */
  commit(n: number, kAccept: number): void;
  /** Resident draft weights, for admission accounting. */
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
    sampler: (logprobs: import("../mlx/array").MlxArray, step: number) => import("../mlx/array").MlxArray;
  }): DraftSource;
  dispose(): void;
}
