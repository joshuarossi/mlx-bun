import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { Cancellation, GenerationOutput, TokenLogprobs } from "../../contracts/generation";
import type { DisposableResource } from "../../contracts/resources";
import { cleanupFailure, disposeResources } from "../../engine/resources";
import type { SpeculativeTransaction } from "../../inference/rollback";
import { DraftAcceptance } from "../../inference/draft-acceptance";
import { deliverDraftOutputs, type DraftOutputResult } from "../../inference/draft-output";
import { readStepExtras, type NumberStepSampler } from "../../sampler";

/** Draft state owns proposal generation and its committed hidden/KV state.
 * It borrows verification context and knows nothing about target storage. */
export interface MlxDraftRows<Context = MlxArray> {
  /** Each row returns 0..depth proposals. The method verifies the returned
   * lengths; an empty row still consumes its pending token. */
  draft(pending: readonly number[], depth: number, steps: readonly number[]): number[][] | Promise<number[][]>;
  commit(accepted: readonly number[], context: Context): void | Promise<void>;
}

/** A bound graph transfers both tensors on success and releases partial
 * allocations on failure. State retention is a separate injected interface. */
export interface MlxRowVerification<Context extends DisposableResource = MlxArray> {
  readonly transaction: SpeculativeTransaction<readonly number[]>;
  forward(ids: MlxArray): Promise<{ logits: MlxArray; context: Context }>;
}

export interface MlxSpeculativeRow {
  readonly pending: number;
  readonly step: number;
  readonly remaining: number;
  readonly eosTokenIds: readonly number[];
  readonly sampling: NumberStepSampler;
  readonly grammarDone?: () => boolean;
}

export interface MlxSpeculativeRowResult {
  readonly drafts: readonly number[];
  readonly acceptance: DraftAcceptance;
  /** One entry per content token; stopping EOS is excluded. */
  readonly logprobs: readonly (TokenLogprobs | undefined)[];
}

export interface MlxSpeculativeOutputRow extends MlxSpeculativeRow {
  readonly output: Pick<GenerationOutput, "commit">;
  readonly cancellation?: Cancellation;
}

/** Execute one method step through output delivery and aligned state commit.
 * The caller retires terminal rows and publishes eligible completed state
 * before changing membership. Consumer failures are returned per request;
 * a graph/state failure throws and requires discarding the whole group. */
export async function advanceSpeculativeOutputs<Context extends DisposableResource = MlxArray>(
  rows: readonly MlxSpeculativeOutputRow[], depth: number,
  draft: MlxDraftRows<NoInfer<Context>>, target: MlxRowVerification<Context>,
): Promise<{ rounds: readonly MlxSpeculativeRowResult[]; outputs: readonly DraftOutputResult[] }> {
  const round = await prepareSpeculativeRows(rows, depth, draft, target);
  let outputs: DraftOutputResult[];
  try {
    outputs = await deliverDraftOutputs(round.results.map((result, row) => ({
      acceptance: result.acceptance, logprobs: result.logprobs,
      output: rows[row]!.output, cancellation: rows[row]!.cancellation,
    })));
    await round.commit(outputs.map(output => output.accepted));
  } catch (error) { return cleanupFailure(error, () => round.dispose()); }
  round.dispose();
  return { rounds: round.results, outputs };
}

/** Retention stays unresolved while the method delivers output. A terminal
 * row may keep fewer accepted inputs for an output-aligned checkpoint;
 * continuing rows retain their complete accepted prefix. Commit exactly once,
 * then dispose; disposing an uncommitted round requires discarding its state. */
export interface MlxPreparedSpeculativeRound extends DisposableResource {
  readonly results: readonly MlxSpeculativeRowResult[];
  commit(keepAccepted?: readonly number[]): Promise<void>;
}

/** One committed method step at B=1 or B>1. The caller supplies live rows with
 * a positive token budget and a common nonnegative draft depth. Admission,
 * cancellation boundaries, output delivery and cache publication stay outside
 * this step. On failure the caller discards the participating method state. */
export async function advanceSpeculativeRows<Context extends DisposableResource = MlxArray>(
  rows: readonly MlxSpeculativeRow[], depth: number,
  draft: MlxDraftRows<NoInfer<Context>>, target: MlxRowVerification<Context>,
): Promise<readonly MlxSpeculativeRowResult[]> {
  const round = await prepareSpeculativeRows(rows, depth, draft, target);
  try { await round.commit(); }
  catch (error) { return cleanupFailure(error, () => round.dispose()); }
  round.dispose();
  return round.results;
}

/** Draft, verify and sample without deciding which output-aligned state to
 * retain. Graph-specific context is opaque to this operation. */
export async function prepareSpeculativeRows<Context extends DisposableResource = MlxArray>(
  rows: readonly MlxSpeculativeRow[], depth: number,
  draft: MlxDraftRows<NoInfer<Context>>, target: MlxRowVerification<Context>,
): Promise<MlxPreparedSpeculativeRound> {
  const proposals = await draft.draft(rows.map(row => row.pending), depth, rows.map(row => row.step));
  const B = rows.length;
  const verifyDepth = proposals.reduce((max, tokens) => Math.max(max, tokens.length), 0);
  using ids = ops.fromInt32(proposals.flatMap((tokens, row) => {
    const window = [rows[row]!.pending, ...tokens];
    // Causal right padding only fills the rectangular graph. Sampling stops
    // at this row's own bonus position; commit discards every padded input.
    while (window.length <= verifyDepth) window.push(rows[row]!.pending);
    return window;
  }), [B, verifyDepth + 1]);
  target.transaction.begin(verifyDepth);
  const verification = await target.forward(ids);
  const dispose = () => disposeResources([verification.context, verification.logits]);
  try {
    const results = await sampleSpeculativeRows(rows, proposals, verification.logits);
    return {
      results,
      async commit(accepted = results.map(result => result.acceptance.accepted)) {
        target.transaction.resolve(accepted);
        await draft.commit(accepted, verification.context);
      },
      dispose,
    };
  } catch (error) { return cleanupFailure(error, dispose); }
}

/** Sample a borrowed verify window. Each request owns its processor history,
 * grammar and RNG stream; completing one walk never samples its unused suffix.
 * The existing request adapter and grouped method use this same operation. */
export async function sampleSpeculativeRows(
  rows: readonly MlxSpeculativeRow[], proposals: readonly (readonly number[])[], logits: MlxArray,
): Promise<MlxSpeculativeRowResult[]> {
  const V = logits.shape[2]!, width = logits.shape[1]!;
  const independent = rows[0]?.sampling.independent;
  let tokens: number[] | undefined;
  if (independent && rows.every(row => row.sampling.independent === independent)) {
    using flat = ops.reshape(logits, [rows.length * width, V]);
    using sampled = independent.sample(flat);
    tokens = sampled.toIntTokens();
  }
  const results: MlxSpeculativeRowResult[] = [];
  for (let row = 0; row < rows.length; row++) {
    const request = rows[row]!;
    const acceptance = new DraftAcceptance(proposals[row]!, request.remaining, request.eosTokenIds);
    const logprobs: (TokenLogprobs | undefined)[] = [];
    while (!acceptance.done) {
      const position = acceptance.position;
      let token: number, metadata: TokenLogprobs | undefined;
      if (tokens) token = tokens[row * width + position]!;
      else {
        using slice = logits.slice([row, position, 0], [row + 1, position + 1, V]);
        using scores = ops.reshape(slice, [1, V]);
        const sampled = await request.sampling.sample(scores, request.step + acceptance.emitted.length);
        token = sampled.token;
        metadata = readStepExtras(sampled.extras);
      }
      acceptance.accept(token, request.grammarDone?.() ?? false);
      if (!acceptance.sawEos) logprobs.push(metadata);
    }
    results.push({ drafts: proposals[row]!, acceptance, logprobs });
  }
  return results;
}
