import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { AutoregressiveGraph } from "../../inference/graph";
import type { Cache, BatchableCache, PaddedPrefillCache } from "../../model/gemma4-base";
import type { DraftRowSampling } from "../../spec/source";
import { toLogprobs } from "../../sampler";
import { disposeResources } from "../../engine/resources";
import { MlxStateRows } from "./state-rows";
import type { PreparedStateChange } from "../../contracts/resources";
import { evalCacheState } from "./prefill";

export interface MlxDraftLayout extends BatchableCache, PaddedPrefillCache {
  makeEmptyBatch(): MlxDraftLayout;
}

/** The draft graph and sampler operate at B. State snapshots own rewind and
 * membership independently of the graph, target verifier and scheduler. */
export class MlxAutoregressiveDraftRows {
  #history: MlxStateRows[] = [];
  #drafts: number[][] = [];
  #depth = 0;
  #pendingLast: Array<number | null>;
  constructor(readonly graph: AutoregressiveGraph<MlxArray, Cache[], MlxArray>,
    readonly state: MlxStateRows<MlxDraftLayout>, readonly sampling: DraftRowSampling | null) {
    this.#pendingLast = Array.from({ length: state.rowCount }, () => null);
  }
  get pendingLast(): readonly (number | null)[] { return this.#pendingLast; }
  prepareAppend(rows: readonly (readonly Cache[])[], pending: readonly (number | null)[]): PreparedStateChange {
    const state = this.state.prepareAppendMany(rows), next = [...this.#pendingLast, ...pending];
    return { commit: () => { state.commit(); this.#pendingLast = next; }, dispose: () => state.dispose() };
  }
  filterRows(keep: readonly number[]): void {
    this.state.filterRows(keep); this.#pendingLast = keep.map(row => this.#pendingLast[row]!);
  }

  async #forward(ids: MlxArray, lengths?: readonly number[]): Promise<MlxArray> {
    const width = ids.shape[1]!, padded = lengths?.some(length => length !== width);
    if (padded) for (const cache of this.state.caches) cache.preparePrefill({
      lengths: [...lengths!], rightPadding: lengths!.map(length => width - length),
    });
    const hidden = await this.graph.forwardHidden(ids, this.state.caches);
    try {
      if (padded) for (const cache of this.state.caches) cache.finalizePrefill();
      return hidden;
    } catch (error) { hidden.dispose(); throw error; }
  }

  /** A restored full-accept boundary may have one unprocessed draft token.
   * Combine it with the incoming block on device, retaining per-row lengths. */
  async prefill(tokens: MlxArray): Promise<void> {
    const [B, N] = tokens.shape as [number, number];
    if (this.#pendingLast.some(token => token !== null)) {
      using previous = ops.fromInt32(this.#pendingLast.map(token => token ?? 0), [B, 1]);
      using joined = ops.concatAxis([previous, tokens], 1);
      const lengths = this.#pendingLast.map(token => N + Number(token !== null));
      using indices = ops.fromInt32(lengths.flatMap(length => Array.from({ length: N + 1 },
        (_, position) => length === N + 1 ? position : Math.min(position + 1, N))), [B, N + 1]);
      using inputs = ops.takeAlongAxis(joined, indices, 1);
      (await this.#forward(inputs, lengths)).dispose();
    } else (await this.#forward(tokens)).dispose();
    this.#pendingLast.fill(null); this.materialize();
  }
  materialize(): void { evalCacheState(this.state.caches); }

  async draft(pending: readonly number[], depth: number, steps: readonly number[]): Promise<number[][]> {
    this.#releaseHistory();
    this.#depth = depth;
    const tokens: MlxArray[] = [];
    const feeds = pending.map((token, row) => this.#pendingLast[row] == null ? [token] : [this.#pendingLast[row]!, token]);
    const lengths = feeds.map(feed => feed.length), width = Math.max(...lengths);
    let ids = ops.fromInt32(feeds.flatMap(feed => [...feed, ...Array(width - feed.length).fill(0)]), [pending.length, width]);
    try {
      // With zero proposals, consume the pending input to keep companion
      // coverage aligned with the target's one-token verification.
      for (let position = 0; position < Math.max(1, depth); position++) {
        const padded = position === 0 && lengths.some(length => length !== width);
        using hidden = await this.#forward(ids, position === 0 ? lengths : undefined);
        this.#history.push(this.state.clone());
        if (depth === 0) break;
        using selection = padded ? ops.fromInt32(lengths.map(length => length - 1), [pending.length, 1, 1]) : null;
        using selected = selection ? ops.takeAlongAxis(hidden, selection, 1) : null;
        using logits = this.graph.projectLogits(selected ?? hidden, { type: "last" });
        using flat = ops.reshape(logits, [pending.length, logits.shape.at(-1)!]);
        using logprobs = toLogprobs(flat);
        const token = this.sampling!.sample(logprobs, steps.map(step => step + position));
        tokens.push(token);
        ids.dispose(); ids = ops.reshape(token, [pending.length, 1]);
      }
      if (depth === 0) this.#drafts = pending.map(() => []);
      else {
        using packed = ops.concatAxis(tokens, 0);
        const values = packed.toIntTokens();
        this.#drafts = pending.map((_, row) => Array.from({ length: depth },
          (_, position) => values[position * pending.length + row]!));
      }
      return this.#drafts;
    } catch (error) { this.#releaseHistory(); throw error; }
    finally { ids.dispose(); disposeResources(tokens); }
  }

  /** Preserve mlx-lm's full-accept re-feed shape: the final draft remains
   * pending and joins the next target token in one forward. Recurrent state
   * uses saved boundaries, never trimming. The lag is companion state. */
  async commit(accepted: readonly number[]): Promise<void> {
    const selected: Cache[][] = [];
    try {
      if (!accepted.every(count => count >= this.#depth - 1)) {
        for (const [row, count] of accepted.entries())
          selected.push(this.#history[Math.min(count, Math.max(0, this.#depth - 1))]!.extractRow(row));
        this.state.mergeRows(selected);
      }
    } finally { disposeResources(selected.flat()); this.#releaseHistory(); }

    this.#pendingLast = accepted.map((count, row) => this.#depth > 0 && count === this.#depth ? this.#drafts[row]!.at(-1)! : null);
    this.#drafts = []; this.#depth = 0;
  }

  #releaseHistory(): void { disposeResources(this.#history.splice(0)); }
  dispose(): void { this.#releaseHistory(); this.#drafts = []; this.state.dispose(); }
}
