import { decodedKvDonorAttention } from "./decoded-kv-donor";
import type { MlxArray } from "../mlx/array";
import { KvTensorRows, type KvTensorRowView } from "../backends/mlx/kv-tensor-rows";
import { disposeResources } from "../engine/resources";
import { TurboQuantKVCache, type BatchableCache, type Cache, type Mask, type RotatedValueAttentionState, type PaddedPrefillCache, type PrefillPadding } from "./gemma4-base";
import { TurboQuantCodec, disposeTurboQuant, type TurboQuantTensor } from "./turboquant-codec";

const fields = ["kIdx", "kScales", "kZeros", "vPacked", "vScales"] as const;
function encoded(planes: readonly MlxArray[]): TurboQuantTensor {
  return { kIdx: planes[0]!, kScales: planes[1]!, kZeros: planes[2]!, vPacked: planes[3]!, vScales: planes[4]! };
}

/** The existing TurboQuant codec over shared tensor-row storage. Row changes
 * copy encoded bytes without decoding, rotating or requantizing their values. */
export class BatchedTurboQuantKVCache implements BatchableCache, PaddedPrefillCache {
  readonly #storage = new KvTensorRows();
  readonly #codec: TurboQuantCodec;
  #reuseOffsets: number[] = [];
  #headDim: number | null = null;
  constructor(readonly kBits: number, readonly vBits: number) {
    this.#codec = new TurboQuantCodec(kBits, vBits, process.env.MLX_BUN_TURBOQUANT_FUSED_DECODE === "1");
  }
  restorePrefillEnds(ends: readonly number[] | undefined): void { this.#storage.restorePrefillEnds(ends); }
  preparePrefill(padding: PrefillPadding): void {
    this.#storage.preparePrefill(padding);
    if (!this.#reuseOffsets.length) this.#reuseOffsets = padding.lengths.map(() => 0);
  }
  finalizePrefill(): void { this.#storage.finalizePrefill(); }
  captureDonorRows(): import("./gemma4-base").KvDonorRows {
    if (!this.#storage.planes.length || this.#headDim === null) throw new Error("cache is empty");
    const [keys, values] = this.#codec.decode(encoded(this.#storage.planes), this.offset, this.#headDim, false);
    return { keys, values, ...this.#storage.captureDonorValidity() };
  }
  captureDonorAttention(): import("./gemma4-base").KvDonorAttention {
    return decodedKvDonorAttention(this.captureDonorRows());
  }
  get rotatedValueAttention(): RotatedValueAttentionState { return this; }
  signature(): string { return `kv:batched-turboquant:${this.kBits}:${this.vBits}`; }
  get minimumReusableOffset(): number { return Math.max(0, ...this.#reuseOffsets); }
  get headDim(): number | null { return this.#headDim; }
  get rowOffsets(): readonly number[] { return this.#storage.rowOffsets; }
  get leftPad(): readonly number[] { return this.#storage.leftPad; }
  get batchSize(): number | null { return this.#storage.batchSize; }
  get offset(): number { return this.#storage.offset; }
  get ropeOffsetArr(): MlxArray | undefined { return this.#storage.ropeOffsetArr; }
  makeEmptyBatch(): BatchedTurboQuantKVCache { return new BatchedTurboQuantKVCache(this.kBits, this.vBits); }
  bytesPerToken(): number { return this.#storage.bytesPerToken(); }
  projectedBytes(tokens: number): number { return this.bytesPerToken() * tokens; }
  makeMask(tokens: number, window: number | null): Mask { return this.#storage.makeMask(tokens, window); }
  isTrimmable(): boolean { return true; }
  trim(count: number): void { this.#storage.trim(count); }
  specRoundBegin(): void { this.#storage.specRoundBegin(); }
  specRoundCommit(): void { this.#storage.specRoundCommit(); }
  specRoundRollback(keep: number | readonly number[]): void { this.#storage.specRoundRollback(keep); }
  #append(k: MlxArray, v: MlxArray, defer: boolean): [MlxArray, MlxArray] {
    const packed = this.#codec.encode(k, v);
    try {
      this.#storage.append(fields.map(field => packed[field]));
      this.#headDim = k.shape[3]!;
      return this.#codec.decode(encoded(this.#storage.planes), this.offset, this.#headDim, defer);
    } finally { disposeTurboQuant(packed); }
  }
  updateAndFetch(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.#append(k, v, false); }
  updateAndFetchDeferredV(k: MlxArray, v: MlxArray): [MlxArray, MlxArray] { return this.#append(k, v, true); }
  mergeRows(rows: readonly Cache[]): void {
    const views: KvTensorRowView[] = [], held: MlxArray[] = [];
    const reuseOffsets: number[] = [];
    let dim = this.#headDim;
    try {
      for (const row of rows) {
        if (row instanceof BatchedTurboQuantKVCache) {
          views.push(row.#storage); dim ??= row.headDim; reuseOffsets.push(...row.#reuseOffsets);
        } else if (row instanceof TurboQuantKVCache) {
          const planes = row.state(); held.push(...planes); reuseOffsets.push(row.minimumReusableOffset);
          views.push({ planes, rowOffsets: [row.offset], leftPad: [0] }); dim ??= row.headDim;
        } else throw new Error(`TurboQuant row layout cannot merge ${row.signature()}`);
      }
      this.#storage.mergeRows(views); this.#headDim = dim; this.#reuseOffsets = reuseOffsets;
    } finally { disposeResources(held); }
  }
  alignRows(leftPad: readonly number[]): void { this.#storage.alignRows(leftPad); }
  filterRows(keep: readonly number[]): void {
    this.#storage.filterRows(keep); this.#reuseOffsets = keep.map(row => this.#reuseOffsets[row]!);
  }
  state(): MlxArray[] { return this.#storage.planes; }
  extractRow(row: number): TurboQuantKVCache {
    const result = new TurboQuantKVCache(this.kBits, this.vBits), count = this.rowOffsets[row]!;
    if (count) result.restoreState(encoded(this.#storage.extractRow(row)), count, this.#headDim!);
    result.minimumReusableOffset = this.#reuseOffsets[row] ?? 0;
    return result;
  }
  dispose(): void { this.#storage.dispose(); this.#headDim = null; this.#reuseOffsets = []; }
}
