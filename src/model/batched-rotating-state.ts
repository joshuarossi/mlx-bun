/** Host-side row and ring bookkeeping shared by plain and quantized storage. */
export class BatchedRotatingState {
  readonly maxSize: number;
  offsets: number[];
  leftPad: number[];
  ringIndex = 0;
  totalOffset = 0;
  rotated = false;

  constructor(maxSize: number, leftPad: readonly number[], offsets?: readonly number[]) {
    this.maxSize = maxSize;
    this.leftPad = [...leftPad];
    this.offsets = offsets ? [...offsets] : leftPad.map((pad) => -pad);
  }

  get batchSize(): number { return this.leftPad.length; }
  get validLength(): number { return Math.min(this.totalOffset, this.maxSize); }
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

  filter(keep: readonly number[]): void {
    this.offsets = keep.map((row) => this.offsets[row]!);
    this.leftPad = keep.map((row) => this.leftPad[row]!);
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
  }

  /** Physical ranges that expose a ring buffer in temporal order. */
  temporalRanges(bufferLength: number): readonly [number, number][] {
    if (this.ringIndex === bufferLength) return [[0, bufferLength]];
    if (this.ringIndex < this.totalOffset)
      return [[this.ringIndex, bufferLength], [0, this.ringIndex]];
    return [[0, this.ringIndex]];
  }
}
