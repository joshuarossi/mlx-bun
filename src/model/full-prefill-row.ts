import type { MlxArray } from "../mlx/array";
import { materializeCopy } from "../mlx/materialize";
import { withResource, disposeResources } from "../engine/resources";
import { leaseCacheState } from "../backends/mlx/state-views";
import { FullPrefillPadding } from "./full-prefill-padding";
import { KVCache, QuantizedKVCache, TurboQuantKVCache, type Cache, type Mask, type PrefillPadding } from "./gemma4-base";

type FullCache = KVCache | QuantizedKVCache | TurboQuantKVCache;

/** A physical full-attention row with separate valid-token coverage. Codecs
 * consume the same physical tensors; padding never advances their threshold. */
export class FullPrefillRow implements Cache {
  readonly padding = new FullPrefillPadding();
  leftPadding = 0;
  constructor(public inner: FullCache) {}
  get minimumReusableOffset(): number { return (this.inner as Cache).minimumReusableOffset ?? 0; }
  set minimumReusableOffset(value: number) { (this.inner as Cache).minimumReusableOffset = value; }
  get positionOffset(): number { return this.inner.offset - this.leftPadding; }
  get physicalLength(): number { return this.inner.offset; }
  get offset(): number { return Math.max(0, this.padding.validOffset(this.positionOffset, 0)); }
  get stateNeedsDispose(): boolean { return (this.inner as Cache).stateNeedsDispose ?? false; }
  get affineConversion(): FullPrefillRow | undefined { return this.inner instanceof KVCache ? this : undefined; }
  get turboConversion(): FullPrefillRow | undefined { return this.inner instanceof KVCache ? this : undefined; }
  get quantizedAttention() { return (this.inner as Cache).quantizedAttention; }
  get rotatedValueAttention() { return (this.inner as Cache).rotatedValueAttention; }
  signature(): string { return this.inner.signature(); }
  state(): MlxArray[] { return this.inner.state(); }
  makeMask(tokens: number, window: number | null): Mask { return this.inner.makeMask(tokens, window); }
  isTrimmable(): boolean { return true; }
  trim(count: number): void { this.inner.trim(count); }
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.inner.updateAndFetch(k, v); }
  bytesPerToken(): number { return (this.inner as Cache).bytesPerToken?.() ?? 0; }
  preparePrefill(padding: PrefillPadding): void {
    const positions = { rowOffsets: [this.positionOffset], leftPad: [this.leftPadding] };
    this.padding.prepare(positions, padding);
    this.leftPadding = positions.leftPad[0]!;
  }
  finalizePrefill(): void {
    const positions = { rowOffsets: [this.positionOffset], leftPad: [this.leftPadding] };
    const next = withResource(leaseCacheState(this.inner), state => this.padding.finalize(state, positions));
    if (next) this.replace(next, this.inner.offset);
    this.leftPadding = positions.leftPad[0]!;
  }
  removeLeftPadding(count: number): void {
    if (!count) return;
    const next: MlxArray[] = [];
    try {
      withResource(leaseCacheState(this.inner), state => {
        for (const plane of state) next.push(plane.slice([0, 0, count, 0], [...plane.shape]));
      });
      this.replace(next, this.inner.offset - count); next.length = 0;
      this.leftPadding -= count;
    } finally { disposeResources(next); }
  }
  private restored(planes: MlxArray[], offset: number): FullCache {
    const source = this.inner;
    if (source instanceof KVCache) {
      const result = new KVCache();
      if (planes.length) result.restoreState(planes[0]!, planes[1]!, offset);
      return result;
    }
    if (source instanceof QuantizedKVCache) {
      const result = new QuantizedKVCache(source.groupSize, source.bits);
      if (planes.length) result.restoreState({ packed: planes[0]!, scales: planes[1]!, biases: planes[2]! },
        { packed: planes[3]!, scales: planes[4]!, biases: planes[5]! }, offset);
      return result;
    }
    const result = new TurboQuantKVCache(source.kBits, source.vBits, source.fusedDecode);
    if (planes.length) result.restoreState({ kIdx: planes[0]!, kScales: planes[1]!, kZeros: planes[2]!,
      vPacked: planes[3]!, vScales: planes[4]! }, offset, source.headDim!);
    return result;
  }
  private replace(planes: MlxArray[], offset: number): void {
    const next = this.restored(planes, offset), previous = this.inner;
    (next as Cache).minimumReusableOffset = this.minimumReusableOffset;
    this.inner = next; previous.dispose();
  }
  extract(): Cache {
    const count = this.offset, planes: MlxArray[] = [];
    try {
      if (count) withResource(leaseCacheState(this.inner), state => {
        for (const plane of state) {
          using view = plane.slice([0, 0, this.leftPadding, 0], [1, plane.shape[1]!, this.leftPadding + count, plane.shape[3]!]);
          planes.push(materializeCopy(view));
        }
      });
      const result = this.restored(planes, count); planes.length = 0;
      (result as Cache).minimumReusableOffset = this.minimumReusableOffset;
      return result;
    } finally { disposeResources(planes); }
  }
  toQuantized(groupSize: number, bits: number): FullPrefillRow {
    this.inner = (this.inner as KVCache).toQuantized(groupSize, bits);
    return this;
  }
  toTurboQuantized(kBits: number, vBits: number): FullPrefillRow {
    this.inner = TurboQuantKVCache.fromKVCache(this.inner as KVCache, kBits, vBits);
    return this;
  }
  dispose(): void { this.inner.dispose(); this.padding.clear(); }
}

export function fullRowInner(row: Cache): Cache { return row instanceof FullPrefillRow ? row.inner : row; }
export function fullRowPadding(row: Cache): number { return row instanceof FullPrefillRow ? row.leftPadding : 0; }
export function fullRowPhysicalLength(row: Cache): number { return row instanceof FullPrefillRow ? row.physicalLength : row.offset; }
