import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { BatchableCache, Cache, Mask } from "../../model/gemma4-base";
import { KvTensorRows } from "./kv-tensor-rows";
import { leaseCacheStates, minimumReusableOffset } from "./state-views";
import { withResource, disposeResources } from "../../engine/resources";
import { cloneKvCaches } from "../../kv-store";

/** Encoded layouts retain physical row alignment across precision changes. */
export interface TransitionedKvLayout extends BatchableCache {
  alignRows?(leftPad: readonly number[]): void;
}
export interface SpeculativeTransitionedKvLayout extends TransitionedKvLayout {
  specRoundBegin(): void;
  specRoundCommit(): void;
  specRoundRollback(keep: number | readonly number[]): void;
}
export interface KvRowTransition<Layout extends TransitionedKvLayout> {
  readonly signature: string;
  maintain(rows: Cache[]): void;
  converted(row: Cache): boolean;
  makeLayout(): Layout;
  packRows?(layout: Layout, rows: readonly Cache[]): void;
  prepareRows?(rows: Cache[]): Cache[];
  extractRow?(row: Cache): Cache;
  rollbackRow?(row: Cache, before: number, keep: number, preserveColumns: boolean): void;
}


export interface TransitioningKvPositions {
  readonly rowOffsets: readonly number[];
  readonly leftPad: readonly number[];
  readonly offset: number;
  readonly batchSize: number | null;
  readonly ropeOffsetArr: MlxArray | undefined;
  sync(rows: readonly Cache[], preserve: boolean): void;
  filterRows(keep: readonly number[]): void;
  makeMask(tokens: number, window: number | null): Mask;
  dispose(): void;
}
export class FullKvPositions extends KvTensorRows implements TransitioningKvPositions {
  sync(rows: readonly Cache[], preserve: boolean): void {
    this.mergeRows(preserve
      ? [{ planes: [], rowOffsets: rows.map(row => row.offset), leftPad: [...this.leftPad] }]
      : rows.map(row => ({ planes: [], rowOffsets: [row.offset], leftPad: [0] })));
  }
}

/** Owns membership, committed positions and precision transitions. Codec and
 * attention adapters own tensor access; scheduling and persistence use the
 * existing batch and checkpoint contracts. Row conversion never examines an
 * uncommitted speculative suffix. */
export abstract class TransitioningKvRows<Layout extends TransitionedKvLayout> implements BatchableCache {
  protected readonly positions: TransitioningKvPositions;
  protected rows: Cache[] = [];
  protected packed?: Layout;
  #prefilling = false;

  readonly stateNeedsDispose = true;
  constructor(readonly transition: KvRowTransition<Layout>, row?: Cache, positions: TransitioningKvPositions = new FullKvPositions()) {
    this.positions = positions;
    if (row) { this.rows = transition.prepareRows?.([row]) ?? [row]; this.syncPositions(); }
  }
  signature(): string { return this.transition.signature; }
  get prefillMaintenance() { return this; }
  beginPrefill(): void { this.#prefilling = true; }
  commitPrefill(indices: readonly number[]): void {
    if (this.packed) return;
    for (const index of indices) {
      const row = [this.rows[index]!];
      try { this.transition.maintain(row); }
      finally { this.rows[index] = row[0]!; }
    }
  }
  endPrefill(): void { this.#prefilling = false; }
  get minimumReusableOffset(): number { return this.packed?.minimumReusableOffset ?? minimumReusableOffset(this.rows); }
  get rowOffsets(): readonly number[] { return this.packed?.rowOffsets ?? this.positions.rowOffsets; }
  get leftPad(): readonly number[] { return this.packed?.leftPad ?? this.positions.leftPad; }
  get offset(): number { return this.packed?.offset ?? this.positions.offset; }
  get batchSize(): number | null { return this.packed?.batchSize ?? this.positions.batchSize; }
  get ropeOffsetArr(): MlxArray | undefined { return this.packed ? this.packed.ropeOffsetArr : this.positions.ropeOffsetArr; }
  bytesPerToken(): number { return this.packed?.bytesPerToken?.() ?? Math.max(0, ...this.rows.map(row => row.bytesPerToken?.() ?? 0)); }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * tokens; }
  makeMask(tokens: number, window: number | null): Mask { return (this.packed ?? this.positions).makeMask(tokens, window); }
  isTrimmable(): boolean { return this.packed?.isTrimmable() ?? this.rows.every(row => row.isTrimmable()); }
  trim(count: number): void {
    if (this.packed) this.packed.trim(count);
    else { for (const row of this.rows) row.trim(count); this.syncPositions(true); }
  }
  protected syncPositions(preserve = false): void { this.positions.sync(this.rows, preserve); }
  protected advance(): void {
    if (this.packed) return;
    if (!this.#prefilling) this.transition.maintain(this.rows);
    if (this.rows.length && this.rows.every(row => this.transition.converted(row))) {
      const packed = this.transition.makeLayout();
      try {
        if (this.transition.packRows) this.transition.packRows(packed, this.rows);
        else packed.mergeRows(this.rows);
        packed.alignRows?.(this.positions.leftPad);
      }
      catch (error) { packed.dispose(); throw error; }
      const previous = this.rows; this.rows = []; this.packed = packed;
      this.positions.dispose(); disposeResources(previous);
    }
  }
  abstract updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray];
  abstract makeEmptyBatch(): TransitioningKvRows<Layout>;
  mergeRows(rows: readonly Cache[]): void {
    const owned: Cache[] = [];
    try {
      for (const row of rows) {
        if (row instanceof TransitioningKvRows) {
          for (let index = 0; index < row.batchSize!; index++) owned.push(row.extractRow(index));
        } else owned.push(...cloneKvCaches([row]));
      }
    } catch (error) { disposeResources(owned); throw error; }
    let prepared: Cache[];
    try { prepared = this.transition.prepareRows?.(owned) ?? owned; }
    catch (error) { disposeResources(owned); throw error; }
    this.dispose(); this.rows = prepared; this.syncPositions();
  }
  filterRows(keep: readonly number[]): void {
    if (this.packed) { this.packed.filterRows(keep); return; }
    const previous = this.rows; this.rows = keep.map(index => previous[index]!);
    disposeResources(previous.filter((_, index) => !keep.includes(index))); this.positions.filterRows(keep);
  }
  extractRow(row: number): Cache { return this.packed?.extractRow(row) ?? (this.transition.extractRow?.(this.rows[row]!) ?? cloneKvCaches([this.rows[row]!])[0]!); }
  state(): MlxArray[] {
    return withResource(leaseCacheStates(this.packed ? [this.packed] : this.rows), arrays => {
      const views: MlxArray[] = [];
      try { for (const array of arrays) views.push(ops.contiguous(array)); return views; }
      catch (error) { disposeResources(views); throw error; }
    });
  }
  dispose(): void {
    this.#prefilling = false;
    const previous = this.rows; this.rows = [];
    this.packed?.dispose(); this.packed = undefined; this.positions.dispose(); disposeResources(previous);
  }
}

/** Rollback is a method capability, separate from ordinary cache membership. */
export abstract class SpeculativeTransitioningKvRows<Layout extends SpeculativeTransitionedKvLayout> extends TransitioningKvRows<Layout> {
  #beforeRound?: number[];
  specRoundBegin(): void {
    this.advance(); this.#beforeRound = [...this.rowOffsets]; this.packed?.specRoundBegin();
  }
  specRoundCommit(): void {
    this.packed?.specRoundCommit(); this.#beforeRound = undefined; this.advance();
  }
  specRoundRollback(keep: number | readonly number[]): void {
    if (this.packed) this.packed.specRoundRollback(keep);
    else {
      for (const [index, row] of this.rows.entries()) {
        const count = typeof keep === "number" ? keep : keep[index]!;
        const before = this.#beforeRound![index]!;
        if (this.transition.rollbackRow) this.transition.rollbackRow(row, before, count, this.rows.length > 1);
        else row.trim(row.offset - before - count);
      }
      this.syncPositions(true);
    }
    this.#beforeRound = undefined; this.advance();
  }
  override dispose(): void { this.#beforeRound = undefined; super.dispose(); }
}
