import type { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { materializeCopy } from "../../mlx/materialize";
import { FullPrefillPadding } from "../../model/full-prefill-padding";
import type { Mask, PrefillPadding } from "../../model/gemma4-base";
import { cleanupFailure, disposeResources } from "../../engine/resources";

/** Borrowed tensor planes with shared token positions. Plane shapes may differ
 * in head width and dtype. Every plane uses [row, head, token, field]. */
export interface KvTensorRowView {
  readonly planes: readonly MlxArray[];
  readonly rowOffsets: readonly number[];
  readonly leftPad: readonly number[];
}

/** Position and membership operations shared by packed KV representations.
 * A codec supplies tensor planes; this owner never encodes or decodes them. */
export class KvTensorRows implements KvTensorRowView {
  planes: MlxArray[] = [];
  rowOffsets: number[] = [];
  leftPad: number[] = [];
  #rope: MlxArray | undefined;
  #beforeRound: number[] | undefined;
  readonly #padding = new FullPrefillPadding();

  restorePrefillEnds(ends: readonly number[] | undefined): void { this.#padding.restoreEnds(ends); }
  preparePrefill(padding: PrefillPadding): void {
    this.#padding.prepare(this, padding); this.#positionsChanged();
  }
  finalizePrefill(): void {
    const next = this.#padding.finalize(this.planes, this);
    if (next) this.#replace(next, this.rowOffsets, this.leftPad);
  }

  /** Snapshot logical validity without changing physical row alignment. */
  captureDonorValidity(): Pick<import("../../model/gemma4-base").KvDonorRows, "offsets" | "starts" | "ends"> {
    const offsets = this.rowOffsets.map((offset, row) => Math.max(0, this.#padding.validOffset(offset, row)));
    return { offsets, starts: [...this.leftPad], ends: offsets.map((offset, row) => offset + this.leftPad[row]!) };
  }
  get offset(): number { return Math.max(0, ...this.#ends()); }
  get batchSize(): number | null { return this.rowOffsets.length || null; }
  #ends(): number[] { return this.rowOffsets.map((offset, row) => offset + this.leftPad[row]!); }
  get ropeOffsetArr(): MlxArray | undefined {
    if (this.leftPad.every(pad => pad === 0) && this.rowOffsets.every(offset => offset === this.rowOffsets[0])) return undefined;
    return this.#rope ??= ops.fromInt32(this.rowOffsets, [this.rowOffsets.length]);
  }
  #positionsChanged(): void { this.#rope?.dispose(); this.#rope = undefined; }
  bytesPerToken(): number {
    return this.planes.length && this.rowOffsets.length ? this.planes.reduce((bytes, plane) => bytes + plane.nbytes, 0) /
      (this.rowOffsets.length * this.planes[0]!.shape[2]!) : 0;
  }
  trim(count: number): void {
    this.rowOffsets = this.rowOffsets.map(offset => offset - count); this.#positionsChanged();
  }
  specRoundBegin(): void { this.#beforeRound = [...this.rowOffsets]; }
  specRoundCommit(): void { this.#beforeRound = undefined; }
  specRoundRollback(keep: number | readonly number[]): void {
    this.rowOffsets = this.#beforeRound!.map((offset, row) => offset + (typeof keep === "number" ? keep : keep[row]!));
    this.#beforeRound = undefined; this.#positionsChanged();
  }
  makeMask(N: number, window: number | null): Mask {
    const B = this.rowOffsets.length, ends = this.#ends(), S = this.offset + N;
    if (window === null && this.leftPad.every(pad => pad === 0) && ends.every(end => end === ends[0]))
      return { mode: N === 1 ? "" : "causal", arr: null };
    using starts = ops.fromInt32(ends, [B, 1, 1, 1]);
    using relative = ops.arange(0, N, 1, Dtype.int32);
    using queries = ops.reshape(relative, [1, 1, N, 1]);
    using position = ops.add(starts, queries);
    using indices = ops.arange(0, S, 1, Dtype.int32);
    using keys = ops.reshape(indices, [1, 1, 1, S]);
    using pads = ops.fromInt32(this.leftPad, [B, 1, 1, 1]);
    using causal = ops.lessEqual(keys, position);
    using valid = ops.greaterEqual(keys, pads);
    const mask = ops.logicalAnd(causal, valid);
    if (window === null) return { mode: "array", arr: mask };
    using windowSize = ops.fromInt32([window], []);
    using limit = ops.add(keys, windowSize);
    using within = ops.less(position, limit);
    try { return { mode: "array", arr: ops.logicalAnd(mask, within) }; }
    finally { mask.dispose(); }
  }
  #replace(planes: MlxArray[], offsets: number[], pads: number[]): void {
    const previous = this.planes;
    this.planes = planes; this.rowOffsets = offsets; this.leftPad = pads;
    this.#positionsChanged(); disposeResources(previous);
  }
  append(inputs: readonly MlxArray[]): void {
    const B = this.rowOffsets.length, N = inputs[0]!.shape[2]!, ends = this.#ends();
    const needed = Math.max(...ends) + N, capacity = Math.ceil(needed / 256) * 256;
    const common = ends.every(end => end === ends[0]);
    using positions = common ? null : ops.fromInt32(ends.flatMap(end =>
      Array.from({ length: N }, (_, position) => end + position)), [B, 1, N, 1]);
    const next: MlxArray[] = [];
    try {
      for (const [index, input] of inputs.entries()) {
        const old = this.planes[index];
        let base: MlxArray;
        if (!old) base = ops.zeros([B, input.shape[1]!, capacity, input.shape[3]!], input.dtype);
        else if (old.shape[2]! >= needed) base = old;
        else {
          using padding = ops.zeros([B, old.shape[1]!, capacity - old.shape[2]!, old.shape[3]!], old.dtype);
          base = ops.concatAxis([old, padding], 2);
        }
        try {
          const updated = common
            ? ops.sliceUpdate(base, input, [0, 0, ends[0]!, 0], [B, base.shape[1]!, ends[0]! + N, base.shape[3]!])
            : ops.putAlongAxis(base, positions!, input, 2);
          next.push(updated);
        } finally { if (base !== old) base.dispose(); }
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    this.#replace(next, this.rowOffsets.map(offset => offset + N), this.leftPad);
  }
  mergeRows(rows: readonly KvTensorRowView[]): void {
    const next: MlxArray[] = [], held: MlxArray[] = [];
    let offsets: number[], pads: number[];
    try {
      if (rows.length === 1) {
        const row = rows[0]!;
        for (const plane of row.planes) next.push(ops.copyOf(plane));
        offsets = [...row.rowOffsets]; pads = [...row.leftPad];
      } else {
        const widths = rows.map(row => Math.max(0, ...row.rowOffsets.map((offset, i) => offset + row.leftPad[i]!)));
        const width = Math.max(0, ...widths);
        if (width) {
          const prototype = rows.find((_, index) => widths[index]! > 0)!;
          for (const [field, geometry] of prototype.planes.entries()) {
            const pieces = rows.map((row, index) => {
              const active = widths[index]!;
              if (!active) {
                const empty = ops.zeros([row.rowOffsets.length, geometry.shape[1]!, width, geometry.shape[3]!], geometry.dtype);
                held.push(empty); return empty;
              }
              const plane = row.planes[field]!;
              const view = plane.slice([0, 0, 0, 0], [row.rowOffsets.length, plane.shape[1]!, active, plane.shape[3]!]);
              held.push(view);
              if (active === width) return view;
              using padding = ops.zeros([row.rowOffsets.length, plane.shape[1]!, width - active, plane.shape[3]!], plane.dtype);
              const padded = ops.concatAxis([padding, view], 2); held.push(padded); return padded;
            });
            next.push(ops.concatAxis(pieces, 0));
          }
        }
        offsets = rows.flatMap(row => [...row.rowOffsets]);
        pads = rows.flatMap((row, index) => row.leftPad.map(pad => pad + width - widths[index]!));
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    finally { disposeResources(held); }
    this.#replace(next, offsets, pads);
  }
  /** Preserve caller-owned physical positions when changing representation.
   * Live tensor bytes are copied; padding never participates in a codec. */
  alignRows(leftPad: readonly number[]): void {
    if (leftPad.every((pad, row) => pad === this.leftPad[row])) return;
    const width = Math.max(0, ...this.rowOffsets.map((offset, row) => offset + leftPad[row]!));
    const rows: MlxArray[][] = [], planes: MlxArray[] = [];
    try {
      for (let row = 0; row < this.rowOffsets.length; row++) rows.push(this.extractRow(row));
      for (let field = 0; field < this.planes.length; field++) {
        const parts: MlxArray[] = [];
        try {
          for (let row = 0; row < rows.length; row++) {
            const geometry = this.planes[field]!, live = rows[row]![field];
            using before = ops.zeros([1, geometry.shape[1]!, leftPad[row]!, geometry.shape[3]!], geometry.dtype);
            using after = ops.zeros([1, geometry.shape[1]!, width - leftPad[row]! - this.rowOffsets[row]!, geometry.shape[3]!], geometry.dtype);
            parts.push(ops.concatAxis(live ? [before, live, after] : [before, after], 2));
          }
          planes.push(ops.concatAxis(parts, 0));
        } finally { disposeResources(parts); }
      }
    } catch (error) { return cleanupFailure(error, () => disposeResources(planes)); }
    finally { disposeResources(rows.flat()); }
    this.#replace(planes, [...this.rowOffsets], [...leftPad]);
  }
  filterRows(keep: readonly number[]): void {
    if (!keep.length) { this.dispose(); return; }
    const next: MlxArray[] = [];
    using indices = this.planes.length ? ops.fromInt32([...keep], [keep.length]) : null;
    const pads = keep.map(row => this.leftPad[row]!);
    const sharedPadding = Math.min(...pads);
    try {
      for (const plane of this.planes) {
        const selected = ops.takeAxis(plane, indices!, 0);
        if (!sharedPadding) next.push(selected);
        else {
          try { next.push(selected.slice([0, 0, sharedPadding, 0], [...selected.shape])); }
          finally { selected.dispose(); }
        }
      }
    }
    catch (error) { return cleanupFailure(error, () => disposeResources(next)); }
    this.#replace(next, keep.map(row => this.rowOffsets[row]!), pads.map(pad => pad - sharedPadding));
    this.#padding.filter(keep);
  }
  extractRow(row: number): MlxArray[] {
    const start = this.leftPad[row]!, count = this.rowOffsets[row]!, result: MlxArray[] = [];
    if (!count) return result;
    try {
      for (const plane of this.planes) {
        using view = plane.slice([row, 0, start, 0], [row + 1, plane.shape[1]!, start + count, plane.shape[3]!]);
        result.push(materializeCopy(view));
      }
      return result;
    } catch (error) { return cleanupFailure(error, () => disposeResources(result)); }
  }
  dispose(): void {
    const previous = this.planes;
    this.planes = []; this.rowOffsets = []; this.leftPad = []; this.#beforeRound = undefined; this.#padding.clear();
    this.#positionsChanged(); disposeResources(previous);
  }
}
