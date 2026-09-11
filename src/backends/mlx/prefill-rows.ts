import type { BatchableCache, Cache } from "../../model/gemma4-base";
import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import { clearCache } from "../../mlx/ffi";
import type { PrefillStep } from "../../inference/prefill";
import { cloneKvCaches, type CacheCodecProvider } from "../../kv-store";
import { disposeResources, cleanupFailure } from "../../engine/resources";
import type { MlxGroupPreparation, Row } from "./batch-group";
import { evalCacheState } from "./prefill";
import { prefillCacheLayout } from "./cache-layout";
import { MlxStateRows } from "./state-rows";
import type { KvMaintenance } from "./kv-maintenance";

export interface MlxPrefillStep extends PrefillStep {
  /** Some methods maintain their final target chunk before sampling. */
  readonly maintain?: boolean;
}

export interface MlxPrefillState {
  row: Row;
  solo: Cache[];
  pos: number;
  retain?: () => void;
  planned?: MlxPrefillStep;
}

/** The method owns initialization, planning, companion state, snapshots and
 * completion. This driver owns common target batching and work boundaries.
 * Checkpoint factories return owned cache state; close/dispose are idempotent. */
export interface MlxPrefillRowsHost<State extends MlxPrefillState> {
  stateCodecs?: CacheCodecProvider;
  maintain?: KvMaintenance;
  open(row: Row): State;
  plan(state: State): MlxPrefillStep;
  /** Already prepared state can complete without any target forward. */
  ready?(state: State): boolean;
  forward(ids: MlxArray, caches: Cache[], states: readonly State[]): Promise<MlxArray>;
  project(hidden: MlxArray, caches: Cache[], completed: readonly State[]): MlxArray | null;
  /** Consume method context after target maintenance, before snapshots. */
  afterForward?(ids: MlxArray, caches: Cache[], states: readonly State[], hidden: MlxArray): void | Promise<void>;
  checkpoint(state: State, capture: () => Cache[], row: number): void;
  complete(state: State, logits: MlxArray | null, row: number): Promise<void>;
  reject(row: Row, error: unknown): void;
  close(state: State): void;
  filterRows?(keep: readonly number[]): void;
  dispose?(): void;
}

/** One target preparation lifecycle at B1/B>1. Late joins retain each row's
 * planned chunk endpoint, precision transition and checkpoint boundary. */
export class MlxPrefillRows<State extends MlxPrefillState> implements MlxGroupPreparation {
  #states: State[] = [];
  #rows: Row[] = [];
  #stateRows?: MlxStateRows;
  constructor(readonly operations: MlxPrefillRowsHost<State>) {}
  get rows(): readonly Row[] { return this.#rows; }
  get canAdmit(): boolean { return this.#rows.length > 0; }
  /** Keep a request's prefill weight until retirement so a nearly completed
   * request does not repeatedly attract another long prefill into its tail. */
  get tokenWeight(): number { return this.#states.reduce((sum, state) => sum + state.row.promptTokens - state.row.cachedTokens, 0); }

  admit(row: Row): void {
    this.#states.push(this.operations.open(row));
    this.#rows.push(row);
  }

  #release(state: State): void {
    const caches = state.solo; state.solo = [];
    const retain = state.retain; state.retain = undefined;
    disposeResources([...caches, { dispose: () => retain?.() }, { dispose: () => this.operations.close(state) }]);
  }
  #filter(keep: number[]): void {
    if (keep.length) this.#stateRows?.filterRows(keep);
    else { const rows = this.#stateRows; this.#stateRows = undefined; rows?.dispose(); }
    this.operations.filterRows?.(keep);
    this.#states = keep.map(row => this.#states[row]!);
    this.#rows = keep.map(row => this.#rows[row]!);
  }
  /** Admission changes membership only between forwards. Existing planned
   * endpoints survive a join, including partially consumed drain chunks. */
  #synchronizeRows(): void {
    if (!this.#stateRows && this.#states.length === 1) return;
    if (!this.#stateRows) {
      for (const state of this.#states) this.operations.maintain?.preparePrefill?.(state.solo);
      const layouts: BatchableCache[] = [];
      try { for (const cache of this.#states[0]!.solo) layouts.push(prefillCacheLayout(cache)); }
      catch (error) { return cleanupFailure(error, () => disposeResources(layouts)); }
      this.#stateRows = new MlxStateRows(layouts);
      this.#stateRows.mergeRows(this.#states.map(state => state.solo));
    } else {
      for (const state of this.#states.slice(this.#stateRows.rowCount)) {
        this.operations.maintain?.preparePrefill?.(state.solo);
        this.#stateRows.append(state.solo);
      }
    }
    // Resolve input-backed copies before releasing SSD restore leases.
    if (this.#states.some(state => state.solo.length)) {
      evalCacheState(this.#stateRows.caches);
      for (const state of this.#states) {
        const caches = state.solo; state.solo = [];
        const retain = state.retain; state.retain = undefined;
        disposeResources([...caches, { dispose: () => retain?.() }]);
      }
    }
    for (const cache of this.#stateRows.caches) cache.prefillMaintenance?.beginPrefill();
  }

  async advance(): Promise<boolean> {
    // Complete restored inputs before merging: their cache coverage must not
    // introduce padding or a zero-width forward into unrelated cold rows.
    if (this.operations.ready && this.#states.some(state => this.operations.ready!(state))) {
      const remaining: State[] = [];
      for (const state of this.#states) {
        if (!this.operations.ready(state)) { remaining.push(state); continue; }
        try {
          state.row.req.signal?.throwIfAborted();
          await this.operations.complete(state, null, -1);
          state.solo = []; state.retain = undefined;
        } catch (error) { this.operations.reject(state.row, error); this.#release(state); }
        finally { this.operations.close(state); }
      }
      this.#states = remaining; this.#rows = remaining.map(state => state.row);
      if (!remaining.length) { this.dispose(); return true; }
    }
    this.#synchronizeRows();
    const keep: number[] = [];
    for (const [index, state] of this.#states.entries()) {
      if (!state.row.req.signal?.aborted) { keep.push(index); continue; }
      this.#release(state); this.operations.reject(state.row, state.row.req.signal.reason);
    }
    if (keep.length !== this.#states.length) this.#filter(keep);
    if (!this.#states.length) { this.dispose(); return true; }
    while (this.#states.length) {
      for (const state of this.#states) state.planned ??= this.operations.plan(state);
      const count = Math.min(...this.#states.map(state => state.planned!.end - state.pos));
      const closes = this.#states.map(state => state.row.req.trace?.begin("prefill.chunk", {
        mechanism: "continuous", startToken: state.pos, batchSize: this.#states.length,
      }));
      const caches = this.#stateRows?.caches ?? this.#states[0]!.solo;
      try {
        using ids = count ? ops.fromInt32(this.#states.flatMap(state => state.row.req.promptIds.slice(state.pos, state.pos + count)),
          [this.#states.length, count]) : null;
        using hidden = ids ? await this.operations.forward(ids, caches, this.#states) : null;
        const drains: number[] = [], finals: number[] = [];
        let batchYield = false;
        for (const [row, state] of this.#states.entries()) {
          state.pos += count;
          if (state.pos !== state.planned!.end) continue;
          if (state.planned!.kind === "final") finals.push(row);
          else drains.push(row);
          batchYield ||= state.planned!.batchYield;
        }
        const maintained = [...drains, ...finals.filter(row => this.#states[row]!.planned!.maintain)];
        if (count && (maintained.length || !finals.length)) {
          evalCacheState(caches);
          if (this.#stateRows) {
            for (const cache of caches) cache.prefillMaintenance?.commitPrefill(maintained);
          } else if (maintained.length) this.operations.maintain?.(this.#states[0]!.solo);
          clearCache();
        }
        if (ids) {
          const companion = this.operations.afterForward?.(ids, caches, this.#states, hidden!);
          if (companion) await companion;
        }
        for (const row of [...drains, ...finals]) {
          const state = this.#states[row]!;
          if (state.planned!.snapshot) this.operations.checkpoint(state, () =>
            this.#stateRows ? this.#stateRows.extractRow(row) : cloneKvCaches(state.solo, this.operations.stateCodecs), row);
          if (!finals.includes(row)) state.planned = undefined;
        }
        using logits = hidden && finals.length ? this.operations.project(hidden, caches, finals.map(row => this.#states[row]!)) : null;
        for (const row of finals) {
          const state = this.#states[row]!;
          if (this.#stateRows) state.solo = this.#stateRows.extractRow(row);
          using part = logits ? logits.slice([row, logits.shape[1]! - 1, 0], [row + 1, logits.shape[1]!, logits.shape[2]!]) : null;
          try {
            state.row.req.signal?.throwIfAborted();
            await this.operations.complete(state, part, row);
            state.solo = []; state.retain = undefined;
          } catch (error) {
            this.operations.reject(state.row, error);
            this.#release(state);
          } finally { this.operations.close(state); }
        }
        for (const cache of caches) (cache as { releaseRopeArr?: () => void }).releaseRopeArr?.();
        if (finals.length) this.#filter(this.#states.flatMap((_, row) => finals.includes(row) ? [] : [row]));
        if (!this.#states.length) { this.dispose(); return true; }
        if (batchYield || finals.length) return false;
      } finally { for (const close of closes) close?.(); }
    }
    return true;
  }

  dispose(): void {
    const states = this.#states; this.#states = []; this.#rows = [];
    const rows = this.#stateRows; this.#stateRows = undefined;
    disposeResources([...(rows ? [rows] : []), ...states.map(state => ({ dispose: () => this.#release(state) })),
      { dispose: () => this.operations.dispose?.() }]);
  }
}
