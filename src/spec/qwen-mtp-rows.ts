import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { materializeCopy } from "../mlx/materialize";
import { toLogprobs } from "../sampler";
import { BatchedKVCache } from "../model/batched-kv";
import { KVCache } from "../model/gemma4-base";
import type { DraftRowSampling, QwenMtpTarget } from "./source";
import type { MtpModule } from "./qwen-mtp-module";
import type { PreparedStateChange } from "../contracts/resources";
import { applyStateChanges, cleanupFailure, disposeResources } from "../engine/resources";

/** A committed request's draft KV and the preceding true target hidden row.
 * Construction borrows these arrays; extraction returns owned state. */
export interface MtpRowState {
  readonly cache: KVCache;
  readonly hidden: MlxArray;
}

/** Sampling owns each request's RNG policy. Scores are [B,V] log-probabilities;
 * the returned owned [B] token array stays on device through the draft chain. */
export type MtpRowSampling = DraftRowSampling;

/** The same draft graph and state lifecycle for one or several requests.
 * Admission, target verification, output publication and persistence belong to
 * the caller. Rows remain fixed within a draft/commit round. */
export class QwenMtpRows {
  #cache = new BatchedKVCache();
  #hidden: MlxArray | null = null;
  #prefilled: boolean[] = [];
  #drafts: number[][] = [];
  #depth = 0;

  constructor(
    readonly target: QwenMtpTarget,
    readonly module: MtpModule,
    readonly sampling: MtpRowSampling | null,
    states: readonly (MtpRowState | null)[],
  ) {
    this.append(states);
  }

  get rowCount(): number { return this.#cache.rowOffsets.length; }

  /** Add committed state at a method boundary. Inputs remain caller-owned. */
  append(states: readonly (MtpRowState | null)[]): void {
    if (!states.length) return;
    applyStateChanges([() => this.prepareAppend(states)]);
  }

  prepareAppend(states: readonly (MtpRowState | null)[]): PreparedStateChange {
    if (!states.length) return { commit() {}, dispose() {} };
    const prefilled = [...this.#prefilled, ...states.map(state => state !== null)];
    const example = this.#hidden ?? states.find(state => state !== null)?.hidden;
    let hidden: MlxArray | null = null;
    let cache: BatchedKVCache | null = new BatchedKVCache();
    const held: { dispose(): void }[] = [];
    try {
      if (example) {
        const zero = (rows: number) => {
          const array = ops.zeros([rows, 1, this.target.hiddenSize], example.dtype);
          held.push(array); return array;
        };
        hidden = ops.concatAxis([
          ...(this.rowCount ? [this.#hidden ?? zero(this.rowCount)] : []),
          ...states.map(state => state?.hidden ?? zero(1)),
        ], 0);
      }
      cache.mergeRows([...(this.rowCount ? [this.#cache] : []), ...states.map(state => {
        if (state) return state.cache;
        const empty = new KVCache(); held.push(empty); return empty;
      })]);
    } catch (error) { return cleanupFailure(error, () => disposeResources([cache!, ...(hidden ? [hidden] : [])])); }
    finally { disposeResources(held); }
    return {
      commit: () => {
        const previousCache = this.#cache, previousHidden = this.#hidden;
        this.#cache = cache!; this.#hidden = hidden;
        this.#prefilled = prefilled;
        cache = previousCache; hidden = previousHidden;
      },
      dispose: () => {
        const held = [cache, hidden].filter(value => value !== null);
        cache = null; hidden = null;
        disposeResources(held);
      },
    };
  }

  /** Retire/reorder committed requests without involving their sampler policy. */
  filterRows(keep: readonly number[]): void {
    if (!keep.length) { this.dispose(); return; }
    using indices = ops.fromInt32([...keep], [keep.length]);
    const hidden = this.#hidden ? ops.takeAxis(this.#hidden, indices, 0) : null;
    try { this.#cache.filterRows(keep); }
    catch (error) { hidden?.dispose(); throw error; }
    this.#hidden?.dispose(); this.#hidden = hidden;
    this.#prefilled = keep.map(row => this.#prefilled[row]!);
  }

  /** Build companion KV from borrowed new target tokens/taps at the same B.
   * The first token bridges to each restored row's preceding true hidden.
   * Cold rows discard that bridge. All later rows pair token[p+1] with h[p].
   * Only KV and the final true hidden are evaluated; unused attention/MLP
   * outputs remain outside the evaluated prefill graph. */
  prefill(tokens: MlxArray, context: MlxArray): void {
    const [B, length] = tokens.shape as [number, number];
    const H = context.shape[2]!;
    if (this.#prefilled.some(Boolean)) {
      using first = tokens.slice([0, 0], [B, 1]);
      using embeds = this.target.embed(first);
      const mixed = this.#prefilled.some(value => !value);
      if (mixed) this.#cache.specRoundBegin();
      this.module.forward(embeds, this.#hidden!, this.#cache).dispose();
      if (mixed) this.#cache.specRoundRollback(this.#prefilled.map(Number));
    }
    for (let pos = 0; pos + 1 < length; pos += 2048) {
      const end = Math.min(pos + 2048, length - 1);
      using ids = tokens.slice([0, pos + 1], [B, end + 1]);
      using embeds = this.target.embed(ids);
      using hidden = context.slice([0, pos, 0], [B, end, H]);
      this.module.forward(embeds, hidden, this.#cache).dispose();
      ops.evalAll(this.#cache.state());
    }
    using tail = context.slice([0, length - 1, 0], [B, length, H]);
    const hidden = materializeCopy(tail);
    this.#hidden?.dispose(); this.#hidden = hidden;
    ops.evalAll([hidden, ...this.#cache.state()]);
    this.#prefilled.fill(true);
  }

  materialize(): void {
    const state = [...this.#cache.state(), ...(this.#hidden ? [this.#hidden] : [])];
    if (state.length) ops.evalAll(state);
  }

  /** Nonnegative depth, with every request's first pending token already known.
   * Build the complete device dependency chain before reading proposal IDs. */
  draft(pending: readonly number[], depth: number, steps: readonly number[]): number[][] {
    const B = pending.length;
    const tokens: MlxArray[] = [];
    let ids: MlxArray | null = ops.fromInt32([...pending], [B, 1]);
    let chained: MlxArray | null = null;
    this.#cache.specRoundBegin();
    try {
      // A zero-proposal round still processes the pending target token. Keep
      // its companion KV aligned so a later round can resume speculation.
      if (depth === 0) {
        using embeds = this.target.embed(ids!);
        this.module.forward(embeds, this.#hidden!, this.#cache).dispose();
        this.#drafts = Array.from({ length: B }, () => []);
        this.#depth = 0;
        this.#hidden!.dispose(); this.#hidden = null;
        return this.#drafts;
      }
      for (let position = 0; position < depth; position++) {
        using embeds = this.target.embed(ids!);
        const output = this.module.forward(embeds, chained ?? this.#hidden!, this.#cache);
        chained?.dispose(); chained = output;
        using logits = this.target.logitsFromHidden(output);
        using flat = ops.reshape(logits, [B, logits.shape.at(-1)!]);
        using logprobs = toLogprobs(flat);
        const token = this.sampling!.sample(logprobs, steps.map(step => step + position));
        tokens.push(token);
        ids!.dispose(); ids = ops.reshape(token, [B, 1]);
      }
      using packed = ops.concatAxis(tokens, 0);
      const read = packed.toIntTokens();
      this.#drafts = Array.from({ length: B }, (_, row) =>
        Array.from({ length: depth }, (_, position) => read[position * B + row]!));
      this.#depth = depth;
      this.#hidden!.dispose(); this.#hidden = null;
      return this.#drafts;
    } finally {
      ids?.dispose(); chained?.dispose();
      for (const token of tokens) token.dispose();
    }
  }

  /** Resolve draft storage using each request's accepted prefix. The verify
   * context is borrowed [B,depth+1,H], before the target's final norm. */
  commit(accepted: readonly number[], context: MlxArray): void {
    const B = accepted.length, depth = this.#depth;
    const appended = Math.max(1, depth);
    const kept = accepted.map(count => Math.min(count + 1, appended));
    if (kept.every(count => count === appended)) this.#cache.specRoundCommit();
    else this.#cache.specRoundRollback(kept);

    // Full acceptance needs the last accepted token's missing draft row,
    // using the TRUE target hidden at its preceding position. Other requests
    // keep their current coverage; their temporary append is never retained.
    const extra = accepted.map(count => Number(depth > 0 && count === depth));
    if (extra.some(Boolean)) {
      using ids = ops.fromInt32(this.#drafts.map(row => row[depth - 1]!), [B, 1]);
      using embeds = this.target.embed(ids);
      using hidden = context.slice([0, depth - 1, 0], [B, depth, context.shape[2]!]);
      this.#cache.specRoundBegin();
      this.module.forward(embeds, hidden, this.#cache).dispose();
      this.#cache.specRoundRollback(extra);
    }
    using positions = ops.fromInt32([...accepted], [B, 1, 1]);
    this.#hidden = ops.takeAlongAxis(context, positions, 1);
    this.#drafts = []; this.#depth = 0;
  }

  /** Only between committed rounds. Returned state is independent of the
   * group's storage and uses the existing single-request cache representation. */
  extractRow(row: number): MtpRowState {
    const cache = this.#cache.extractRow(row);
    try {
      using view = this.#hidden!.slice([row, 0, 0], [row + 1, 1, this.#hidden!.shape[2]!]);
      return { cache, hidden: materializeCopy(view) };
    } catch (error) { cache.dispose(); throw error; }
  }

  dispose(): void {
    this.#cache.dispose(); this.#hidden?.dispose(); this.#hidden = null;
    this.#drafts = []; this.#depth = 0; this.#prefilled = [];
  }
}
