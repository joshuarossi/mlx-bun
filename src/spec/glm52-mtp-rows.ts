import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { Dtype } from "../mlx/ffi";
import { materializeCopy } from "../mlx/materialize";
import { MLACache } from "../model/glm52-cache";
import { toLogprobs } from "../sampler";
import { applyStateChanges, disposeResources } from "../engine/resources";
import type { PreparedStateChange } from "../contracts/resources";
import type { DraftRowSampling } from "./source";
import type { Glm52MtpGraph } from "./glm52-mtp-graph";

export interface Glm52MtpRowState {
  readonly cache: MLACache;
  readonly hidden: MlxArray;
  readonly processedTokens: number;
}

/** Native Colibri draft history starts empty, independently of target prompt
 * length. Accepted draft rows are rebuilt from true target hidden states. */
export class Glm52MtpRows {
  #cache: MLACache;
  #hidden: MlxArray | null = null;
  #processed: number[] = [];
  #drafts: number[][] = [];
  #depth = 0;

  constructor(readonly graph: Glm52MtpGraph, readonly sampling: DraftRowSampling | null) {
    this.#cache = this.makeCache();
  }
  makeCache(): MLACache {
    const c = this.graph.model.glmConfig;
    return new MLACache({ kvLoraRank: c.kvLoraRank, ropeHeadDim: c.qkRopeHeadDim,
      maxTokens: c.maxPositionEmbeddings, role: "mtp" });
  }
  get rowCount(): number { return this.#processed.length; }
  append(states: readonly (Glm52MtpRowState | null)[]): void {
    applyStateChanges([() => this.prepareAppend(states)]);
  }
  prepareAppend(states: readonly (Glm52MtpRowState | null)[]): PreparedStateChange {
    if (!states.length) return { commit() {}, dispose() {} };
    let cache: MLACache | null = this.makeCache(), hidden: MlxArray | null = null;
    const held: { dispose(): void }[] = [];
    const processed = [...this.#processed, ...states.map(state => state?.processedTokens ?? 0)];
    try {
      cache.mergeRows([...(this.rowCount ? [this.#cache] : []), ...states.map(state => {
        if (state) return state.cache;
        const empty = this.makeCache(); held.push(empty); return empty;
      })]);
      hidden = ops.concatAxis([...(this.#hidden ? [this.#hidden] : []), ...states.map(state => {
        if (state) return state.hidden;
        const zero = ops.zeros([1, 1, this.graph.model.glmConfig.hiddenSize], Dtype.float32);
        held.push(zero); return zero;
      })], 0);
    } catch (error) { cache.dispose(); hidden?.dispose(); throw error; }
    finally { disposeResources(held); }
    return {
      commit: () => {
        const priorCache = this.#cache, priorHidden = this.#hidden;
        this.#cache = cache!; this.#hidden = hidden; this.#processed = processed;
        cache = priorCache; hidden = priorHidden;
      },
      dispose: () => { cache?.dispose(); hidden?.dispose(); cache = null; hidden = null; },
    };
  }
  prefill(tokens: MlxArray, context: MlxArray): void {
    const [batch, length] = tokens.shape as [number, number];
    using tail = context.slice([0, length - 1, 0], [batch, length, context.shape[2]!]);
    const hidden = materializeCopy(tail);
    this.#hidden?.dispose(); this.#hidden = hidden;
    this.#processed = this.#processed.map(count => count + length);
  }
  materialize(): void {
    ops.evalAll([...this.#cache.state(), ...(this.#hidden ? [this.#hidden] : [])]);
  }
  filterRows(keep: readonly number[]): void {
    if (!keep.length) { this.dispose(); return; }
    using indices = ops.fromInt32([...keep], [keep.length]);
    const hidden = ops.takeAxis(this.#hidden!, indices, 0);
    try { this.#cache.filterRows(keep); } catch (error) { hidden.dispose(); throw error; }
    this.#hidden!.dispose(); this.#hidden = hidden;
    this.#processed = keep.map(row => this.#processed[row]!);
  }
  async draft(pending: readonly number[], depth: number, steps: readonly number[]): Promise<number[][]> {
    const B = pending.length, tokens: MlxArray[] = [];
    let ids: MlxArray | null = ops.fromInt32([...pending], [B, 1]), chained: MlxArray | null = null;
    this.#cache.specRoundBegin();
    try {
      for (let position = 0; position < depth; position++) {
        const hidden = await this.graph.forward(ids!, chained ?? this.#hidden!, this.#cache);
        chained?.dispose(); chained = hidden;
        using logits = this.graph.project(hidden);
        using flat = ops.reshape(logits, [B, logits.shape.at(-1)!]);
        using logprobs = toLogprobs(flat);
        const next = this.sampling!.sample(logprobs, steps.map(step => step + position));
        tokens.push(next); ids!.dispose(); ids = ops.reshape(next, [B, 1]);
      }
      using packed = depth ? ops.concatAxis(tokens, 0) : null;
      const read = packed?.toIntTokens() ?? [];
      this.#drafts = Array.from({ length: B }, (_, row) =>
        Array.from({ length: depth }, (_, position) => read[position * B + row]!));
      this.#depth = depth; return this.#drafts;
    } finally { ids?.dispose(); chained?.dispose(); disposeResources(tokens); }
  }
  async commit(accepted: readonly number[], context: MlxArray): Promise<void> {
    const B = accepted.length, width = Math.max(...accepted);
    if (this.#depth) this.#cache.specRoundRollback(1);
    else this.#cache.specRoundCommit();
    if (width) {
      using ids = ops.fromInt32(this.#drafts.flatMap(tokens => Array.from({ length: width }, (_, i) => tokens[i] ?? 0)), [B, width]);
      using hidden = context.slice([0, 0, 0], [B, width, context.shape[2]!]);
      this.#cache.specRoundBegin();
      using output = await this.graph.forward(ids, hidden, this.#cache);
      output.eval(); this.#cache.specRoundRollback(accepted);
    }
    using positions = ops.fromInt32([...accepted], [B, 1, 1]);
    const hidden = ops.takeAlongAxis(context, positions, 1);
    this.#hidden!.dispose(); this.#hidden = hidden;
    this.#processed = this.#processed.map((count, row) => count + 1 + accepted[row]!);
    this.#drafts = []; this.#depth = 0;
  }
  extractRow(row: number): Glm52MtpRowState {
    const cache = this.#cache.extractRow(row);
    try {
      using hidden = this.#hidden!.slice([row, 0, 0], [row + 1, 1, this.#hidden!.shape[2]!]);
      return { cache, hidden: materializeCopy(hidden), processedTokens: this.#processed[row]! };
    } catch (error) { cache.dispose(); throw error; }
  }
  dispose(): void {
    this.#cache.dispose(); this.#hidden?.dispose(); this.#hidden = null;
    this.#processed = []; this.#drafts = []; this.#depth = 0;
  }
}
