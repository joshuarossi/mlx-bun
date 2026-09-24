import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cancellation, GenerationOutput, TokenLogprobs } from "../../contracts/portable/generation";
import type { DisposableResource } from "../../contracts/portable/resources";
import { cleanupFailure, disposeResources } from "../../runtime/resources";
import type { SpeculativeTransaction } from "../../contracts/portable/rollback";
import { DraftAcceptance } from "./acceptance";
import { deliverDraftOutputs, type DraftOutputResult } from "./output";
import { readStepExtras, type NumberStepSampler } from "../../sampling/index";
import { runtimeFlag } from "../../runtime/config";
import type { SpecPhaseMs } from "../index";

/** Diagnostic phase timing: evaluates the verify logits before sampling so
 * draft / verify / sample / commit wall time can be attributed separately.
 * Off by default because that evaluation removes the draft-verify overlap. */
export function specPhaseTiming(): boolean {
  return runtimeFlag("MLX_BUN_SPEC_PHASE_TIMING", false);
}

/** Draft state owns proposal generation and its committed hidden/KV state.
 * It borrows verification context and knows nothing about target storage. */
export interface MlxDraftRows<Context = MlxArray> {
  /** Each row returns 0..depth proposals. The method verifies the returned
   * lengths; an empty row still consumes its pending token. */
  draft(pending: readonly number[], depth: number, steps: readonly number[]): number[][] | Promise<number[][]>;
  /** Optional: the same proposals left on the device as [B, depth] ids, resolved
   *  from one later host readback. Lets the round build its verify graph while
   *  the GPU is still drafting. Null when unavailable for this call. */
  draftDevice?(pending: readonly number[], depth: number, steps: readonly number[]):
    { tokens: MlxArray; resolve(read: readonly number[]): number[][] } | null;
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
): Promise<{ rounds: readonly MlxSpeculativeRowResult[]; outputs: readonly DraftOutputResult[]; phaseMs?: SpecPhaseMs }> {
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
  return { rounds: round.results, outputs, ...(round.phaseMs ? { phaseMs: round.phaseMs } : {}) };
}

/** Retention stays unresolved while the method delivers output. A terminal
 * row may keep fewer accepted inputs for an output-aligned checkpoint;
 * continuing rows retain their complete accepted prefix. Commit exactly once,
 * then dispose; disposing an uncommitted round requires discarding its state. */
export interface MlxPreparedSpeculativeRound extends DisposableResource {
  readonly results: readonly MlxSpeculativeRowResult[];
  commit(keepAccepted?: readonly number[]): Promise<void>;
  /** Present under `MLX_BUN_SPEC_PHASE_TIMING=1`; `commit` fills in after commit(). */
  readonly phaseMs?: SpecPhaseMs;
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
  const timing = specPhaseTiming();
  const phaseMs: SpecPhaseMs | undefined = timing ? { draft: 0, verify: 0, sample: 0, commit: 0, rounds: 1 } : undefined;
  let mark = timing ? performance.now() : 0;
  const lap = (): number => { const now = performance.now(); const elapsed = now - mark; mark = now; return elapsed; };
  // Device-first round: leave the draft tokens on the GPU, assemble the verify
  // ids there, start the GPU on the draft chain, and build the ~2.5k-node verify
  // graph while it runs. Drafts and window samples then come back in ONE read.
  // Same ops and values as the host-first order, so outputs are unchanged.
  // Diagnostics (phase timing) keep the host-first order so phases stay separable.
  const lazy = !phaseMs && depth > 0 && runtimeFlag("MLX_BUN_SPEC_DEVICE_ROUND", true) && draft.draftDevice &&
    rows.every(row => row.sampling.independent || row.sampling.positional)
    ? draft.draftDevice(rows.map(row => row.pending), depth, rows.map(row => row.step)) : null;
  if (lazy) return prepareDeviceRound(rows, depth, lazy, draft, target);
  const inventory = phaseMs && runtimeFlag("MLX_BUN_SPEC_OP_INVENTORY", false);
  const counting = globalThis as Record<string, unknown>;
  if (inventory) counting.__opCount = {};
  let proposals: number[][];
  try { proposals = await draft.draft(rows.map(row => row.pending), depth, rows.map(row => row.step)); }
  finally { if (inventory && phaseMs) { phaseMs.draftOps = counting.__opCount as Record<string, number>; counting.__opCount = undefined; } }
  if (phaseMs) phaseMs.draft = lap();
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
  // Component attribution INSIDE the served verify forward. The model's
  // profiler hooks add an evaluation barrier per op, so this distorts the
  // verify total; it is only ever on with phase timing, for diagnosis.
  const layers: Record<string, number> | undefined =
    phaseMs && runtimeFlag("MLX_BUN_SPEC_LAYER_PROFILE", false) ? {} : undefined;
  const profiled = globalThis as Record<string, unknown>;
  if (layers) profiled.__deltaProf = layers;
  if (inventory) counting.__opCount = {};
  let verification: Awaited<ReturnType<typeof target.forward>>;
  try { verification = await target.forward(ids); }
  finally {
    if (layers) profiled.__deltaProf = undefined;
    if (inventory && phaseMs) { phaseMs.verifyOps = counting.__opCount as Record<string, number>; counting.__opCount = undefined; }
  }
  if (layers && phaseMs) phaseMs.layers = layers;
  const dispose = () => disposeResources([verification.context, verification.logits]);
  try {
    if (phaseMs) {
      // Force the verify forward to completion so its time is not attributed
      // to the sampling readback. Production leaves it lazy on purpose.
      ops.evalAll([verification.logits]);
      phaseMs.verify = lap();
    }
    const results = await sampleSpeculativeRows(rows, proposals, verification.logits);
    if (phaseMs) phaseMs.sample = lap();
    return {
      results,
      async commit(accepted = results.map(result => result.acceptance.accepted)) {
        if (phaseMs) lap();
        target.transaction.resolve(accepted);
        await draft.commit(accepted, verification.context);
        if (phaseMs) phaseMs.commit = lap();
      },
      dispose,
      ...(phaseMs ? { phaseMs } : {}),
    };
  } catch (error) { return cleanupFailure(error, dispose); }
}

async function prepareDeviceRound<Context extends DisposableResource>(
  rows: readonly MlxSpeculativeRow[], depth: number,
  lazy: { tokens: MlxArray; resolve(read: readonly number[]): number[][] },
  draft: MlxDraftRows<NoInfer<Context>>, target: MlxRowVerification<Context>,
): Promise<MlxPreparedSpeculativeRound> {
  const B = rows.length;
  let verification: { logits: MlxArray; context: Context } | null = null;
  const dispose = () => { if (verification) disposeResources([verification.context, verification.logits]); };
  try {
    ops.asyncEvalAll([lazy.tokens]); // the GPU drafts while the verify graph is built
    using pendingIds = ops.fromInt32(rows.map(row => row.pending), [B, 1]);
    using pending = pendingIds.astype(lazy.tokens.dtype);
    using ids = ops.concatAxis([pending, lazy.tokens], 1);
    target.transaction.begin(depth);
    verification = await target.forward(ids);
    const sampled = sampleWindowOnDevice(rows, verification.logits);
    if (!sampled) throw new Error("device round requires stateless window sampling");
    let read: number[];
    try {
      using drafted = ops.reshape(lazy.tokens, [B * depth]);
      using draftedSameType = drafted.astype(sampled.dtype);
      using both = ops.concatAxis([draftedSameType, sampled], 0);
      read = both.toIntTokens();
    } finally { sampled.dispose(); }
    const proposals = lazy.resolve(read.slice(0, B * depth));
    const results = await walkSpeculativeRows(rows, proposals, verification.logits, read.slice(B * depth));
    const held = verification;
    return {
      results,
      async commit(accepted = results.map(result => result.acceptance.accepted)) {
        target.transaction.resolve(accepted);
        await draft.commit(accepted, held.context);
      },
      dispose,
    };
  } catch (error) { return cleanupFailure(error, dispose); }
  finally { lazy.tokens.dispose(); }
}

/** Sample a borrowed verify window. Each request owns its processor history,
 * grammar and RNG stream; completing one walk never samples its unused suffix.
 * The existing request adapter and grouped method use this same operation. */
export async function sampleSpeculativeRows(
  rows: readonly MlxSpeculativeRow[], proposals: readonly (readonly number[])[], logits: MlxArray,
): Promise<MlxSpeculativeRowResult[]> {
  let tokens: number[] | undefined;
  const sampled = sampleWindowOnDevice(rows, logits);
  if (sampled) { try { tokens = sampled.toIntTokens(); } finally { sampled.dispose(); } }
  return walkSpeculativeRows(rows, proposals, logits, tokens);
}

/** Every window position of every row as ONE owned device array [B * width]
 *  (row-major), or null when some row's sampling depends on accepted history, a
 *  grammar or probability capture (those walk position by position).
 *  Plain greedy rows share one stateless argmax; stateless sampled rows
 *  (temperature/top-p/top-k) draw every position with its own (seed, step) key,
 *  so the walk still stops at each row's first rejection with the draws
 *  sequential sampling would make, and unused suffix draws consume nothing. */
export function sampleWindowOnDevice(rows: readonly MlxSpeculativeRow[], logits: MlxArray): MlxArray | null {
  const V = logits.shape[2]!, width = logits.shape[1]!;
  const independent = rows[0]?.sampling.independent;
  if (independent && rows.every(row => row.sampling.independent === independent)) {
    using flat = ops.reshape(logits, [rows.length * width, V]);
    return independent.sample(flat);
  }
  if (rows.length === 0 || !rows.every(row => row.sampling.positional)) return null;
  const perRow: MlxArray[] = [];
  try {
    for (const [row, request] of rows.entries()) {
      using slice = logits.slice([row, 0, 0], [row + 1, width, V]);
      using scores = ops.reshape(slice, [width, V]);
      perRow.push(request.sampling.positional!.sample(
        scores, Array.from({ length: width }, (_, position) => request.step + position)));
    }
    return perRow.length === 1 ? perRow.pop()! : ops.concatAxis(perRow, 0);
  } finally { for (const sampled of perRow) sampled.dispose(); }
}

/** The host accept walk over already-read window samples (`tokens`, row-major
 *  [B * width]) or, without them, position-by-position sampling. */
export async function walkSpeculativeRows(
  rows: readonly MlxSpeculativeRow[], proposals: readonly (readonly number[])[], logits: MlxArray,
  tokens: readonly number[] | undefined,
): Promise<MlxSpeculativeRowResult[]> {
  const V = logits.shape[2]!, width = logits.shape[1]!;
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
