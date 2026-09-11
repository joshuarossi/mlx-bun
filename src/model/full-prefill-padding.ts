import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { PrefillPadding } from "./gemma4-base";
import { rowRollIndices } from "./batched-row-storage";
import { disposeResources } from "../engine/resources";

interface Positions { rowOffsets: number[]; leftPad: number[] }

/** mlx-lm BatchKVCache.prepare/finalize (MIT), over arbitrary stored planes.
 * Padding changes token positions; the representation's codec is uninvolved. */
export class FullPrefillPadding {
  constructor(readonly tokenAxis = 2) {}
  #ends?: number[];
  get endOffsets(): readonly number[] | undefined { return this.#ends; }
  restoreEnds(ends: readonly number[] | undefined): void { this.#ends = ends ? [...ends] : undefined; }
  validOffset(offset: number, row: number): number { return Math.min(offset, this.#ends?.[row] ?? offset); }

  prepare(positions: Positions, padding: PrefillPadding): void {
    if (!positions.rowOffsets.length) {
      positions.rowOffsets = padding.lengths.map(() => 0);
      positions.leftPad = [...positions.rowOffsets];
    }
    if (padding.leftPadding) {
      positions.leftPad = positions.leftPad.map((pad, row) => pad + padding.leftPadding![row]!);
      positions.rowOffsets = positions.rowOffsets.map((offset, row) => offset - padding.leftPadding![row]!);
    }
    // Like rotating storage, retain absolute valid ends. A cohort can finish
    // before its planned width when a longer request leaves during prefill.
    this.#ends = padding.rightPadding?.some(pad => pad > 0)
      ? padding.lengths.map((length, row) => positions.rowOffsets[row]! + length) : undefined;
  }

  /** Borrow planes; return owned replacements only when padding needs moving.
   * Stage every plane before committing positions, including on FFI failure. */
  finalize(planes: readonly MlxArray[], positions: Positions): MlxArray[] | undefined {
    if (!this.#ends) return;
    const padding = this.#ends.map((end, row) => Math.max(0, positions.rowOffsets[row]! - end));
    if (!padding.some(pad => pad > 0)) { this.#ends = undefined; return; }
    const next: MlxArray[] = [];
    try {
      if (planes.length) {
        const width = planes[0]!.shape[this.tokenAxis]!;
        using indices = rowRollIndices(width, padding);
        using compressed = this.tokenAxis === 1 ? ops.reshape(indices, [padding.length, width, 1]) : null;
        for (const plane of planes) next.push(ops.takeAlongAxis(plane, compressed ?? indices, this.tokenAxis));
      }
    } catch (error) { disposeResources(next); throw error; }
    positions.rowOffsets = positions.rowOffsets.map((offset, row) => offset - padding[row]!);
    positions.leftPad = positions.leftPad.map((pad, row) => pad + padding[row]!);
    this.#ends = undefined;
    return next;
  }

  filter(keep: readonly number[]): void { if (this.#ends) this.#ends = keep.map(row => this.#ends![row]!); }
  clear(): void { this.#ends = undefined; }
}
