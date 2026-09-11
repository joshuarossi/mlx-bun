import type { PrefillPadding } from "./gemma4-base";

export interface RotatingPositionSnapshot {
  readonly maxSize: number;
  readonly offsets: readonly number[];
  readonly leftPad: readonly number[];
  readonly ringIndex: number;
  readonly totalOffset: number;
  readonly rotated: boolean;
  readonly prefillEnds?: readonly number[];
}

/** Acceptance changes row positions, independently of plain or encoded planes. */
export function rotatingRollbackPlan(snapshot: RotatingPositionSnapshot, before: readonly number[],
  keep: number | readonly number[], preserveColumns = false): { trim: number } | { shifts: number[]; position: RotatingPositionSnapshot } {
  const counts = before.map((_, row) => typeof keep === "number" ? keep : keep[row]!);
  if (!preserveColumns && before.length === 1 && snapshot.totalOffset < snapshot.maxSize)
    return { trim: snapshot.offsets[0]! - before[0]! - counts[0]! };
  const offsets = before.map((offset, row) => offset + counts[row]!);
  const shifts = snapshot.offsets.map((offset, row) => offset - offsets[row]!);
  return { shifts, position: { ...snapshot, offsets,
    leftPad: snapshot.leftPad.map((pad, row) => pad + shifts[row]!) } };
}

/** Host-side row and ring bookkeeping shared by plain and quantized storage. */
export class BatchedRotatingState {
  readonly maxSize: number;
  offsets: number[];
  leftPad: number[];
  ringIndex = 0;
  totalOffset = 0;
  rotated = false;
  #prefillEnds?: number[];

  constructor(maxSize: number, leftPad: readonly number[], offsets?: readonly number[]) {
    this.maxSize = maxSize;
    this.leftPad = [...leftPad];
    this.offsets = offsets ? [...offsets] : leftPad.map((pad) => -pad);
  }

  snapshot(): RotatingPositionSnapshot {
    return { maxSize: this.maxSize, offsets: [...this.offsets], leftPad: [...this.leftPad],
      ringIndex: this.ringIndex, totalOffset: this.totalOffset, rotated: this.rotated,
      ...(this.#prefillEnds ? { prefillEnds: [...this.#prefillEnds] } : {}) };
  }
  restore(snapshot: RotatingPositionSnapshot): void {
    this.offsets = [...snapshot.offsets]; this.leftPad = [...snapshot.leftPad];
    this.ringIndex = snapshot.ringIndex; this.totalOffset = snapshot.totalOffset; this.rotated = snapshot.rotated;
    this.#prefillEnds = snapshot.prefillEnds ? [...snapshot.prefillEnds] : undefined;
  }

  preparePrefill(padding: PrefillPadding, rightPaddedBatch = padding.rightPadding?.some(pad => pad > 0)): void {
    if (!this.batchSize) { this.leftPad = padding.lengths.map(() => 0); this.offsets = [...this.leftPad]; }
    if (padding.leftPadding) {
      this.leftPad = this.leftPad.map((pad, row) => pad + padding.leftPadding![row]!);
      this.offsets = this.offsets.map((offset, row) => offset - padding.leftPadding![row]!);
    }
    this.#prefillEnds = rightPaddedBatch
      ? padding.lengths.map((length, row) => length + this.offsets[row]!) : undefined;
  }
  get hasPendingPadding(): boolean { return this.#prefillEnds !== undefined; }
  validOffset(row: number): number {
    return Math.min(this.offsets[row]!, this.#prefillEnds?.[row] ?? this.offsets[row]!);
  }

  prefillRoll(): number[] | undefined {
    return this.#prefillEnds?.map((end, row) => Math.max(0, this.offsets[row]! - end));
  }
  #rollPadding(): void {
    const shifts = this.prefillRoll();
    if (!shifts) return;
    this.leftPad = this.leftPad.map((pad, row) => pad + shifts[row]!);
    this.offsets = this.offsets.map((offset, row) => offset - shifts[row]!);
  }
  finalizePrefill(): void { this.#rollPadding(); this.#prefillEnds = undefined; }

  get batchSize(): number { return this.leftPad.length; }
  get validLength(): number { return Math.min(this.totalOffset, this.maxSize); }
  get activeLength(): number { return this.rotated ? this.maxSize : this.ringIndex; }
  get trimmable(): boolean { return this.totalOffset < this.maxSize; }

  markGrown(previousOffset: number): void {
    this.ringIndex = previousOffset;
  }

  trimOvershoot(tokens: number): void {
    if (tokens <= 0) return;
    this.ringIndex = this.maxSize;
    this.leftPad = this.leftPad.map((pad) => pad - tokens);
  }

  /** Prepare an N-token write and return its physical ring column. */
  beginWrite(tokens: number): number {
    if (this.ringIndex === this.maxSize) {
      this.rotated = true;
      this.ringIndex = 0;
    }
    if (this.rotated) this.leftPad = this.leftPad.map((pad) => pad - tokens);
    return this.ringIndex;
  }

  commitWrite(tokens: number): void {
    this.totalOffset += tokens;
    this.offsets = this.offsets.map((offset) => offset + tokens);
    this.ringIndex += tokens;
  }

  /** mlx-lm BatchRotatingKVCache._update_concat: the block keeps up to
   * maxSize - 1 historical columns so each query has a complete window. */
  commitConcat(tokens: number, historicalLength: number): void {
    if (historicalLength) this.#rollPadding();
    const trim = Math.max(0, historicalLength - this.maxSize + 1);
    this.leftPad = this.leftPad.map(pad => pad - trim);
    this.totalOffset += tokens;
    this.offsets = this.offsets.map(offset => offset + tokens);
    this.ringIndex = historicalLength - trim + tokens;
    this.rotated = false;
  }

  filter(keep: readonly number[]): void {
    this.offsets = keep.map((row) => this.offsets[row]!);
    this.leftPad = keep.map((row) => this.leftPad[row]!);
    if (this.#prefillEnds) this.#prefillEnds = keep.map(row => this.#prefillEnds![row]!);
  }

  trim(tokens: number): number {
    const amount = Math.min(this.totalOffset, tokens);
    this.totalOffset -= amount;
    this.ringIndex -= amount;
    this.offsets = this.offsets.map((offset) => offset - amount);
    return amount;
  }

  restoreMerged(width: number, offsets: readonly number[]): void {
    this.totalOffset = width;
    this.ringIndex = width;
    this.offsets = [...offsets];
    this.rotated = false;
    this.#prefillEnds = undefined;
  }

  /** Physical ranges that expose a ring buffer in temporal order. */
  temporalRanges(bufferLength: number): readonly [number, number][] {
    if (this.ringIndex === bufferLength) return [[0, bufferLength]];
    if (this.ringIndex < this.totalOffset)
      return [[this.ringIndex, bufferLength], [0, this.ringIndex]];
    return [[0, this.ringIndex]];
  }
}
