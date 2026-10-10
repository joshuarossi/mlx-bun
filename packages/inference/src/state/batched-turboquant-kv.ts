import { decodedKvDonorAttention } from "./decoded-kv-donor";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { KvTensorRows, type KvTensorRowView } from "./kv-tensor-rows";
import { disposeResources } from "../runtime/resources";
import { TurboQuantKVCache, rotatedValueRead } from "./turboquant-kv";
import { type AttentionCache, type AttentionRead, type BatchableCache, type Cache, type Mask, type RotatedValueAttentionState, type PaddedPrefillCache, type PrefillPadding } from "../contracts/mlx/cache";
import { TurboQuantCodec, turboQuantFusedDecode, disposeTurboQuant, type TurboQuantTensor } from "./turboquant-codec";
import { decodedKvStorage } from "./dense-kv-reads";
import { AttentionMasks, causalLease, unmaskedLease, withLease, type MaskLease } from "./attention-read";

const fields = ["kIdx", "kScales", "kZeros", "vPacked", "vScales"] as const;
function encoded(planes: readonly MlxArray[]): TurboQuantTensor {
  return { kIdx: planes[0]!, kScales: planes[1]!, kZeros: planes[2]!, vPacked: planes[3]!, vScales: planes[4]! };
}

/** The existing TurboQuant codec over shared tensor-row storage. Row changes
 * copy encoded bytes without decoding, rotating or requantizing their values.
 *
 * Reads: append as `updateAndFetchDeferredV` does, then `rotatedValueRead`
 * (the fused SDPA on rotated values, then the inverse value rotation of its
 * output), so no caller sees rotated values. While every row is unpadded and at
 * one position, decode passes no mask and a window the fused causal mask;
 * otherwise both pass the per-row mask (causal, past each row's left padding)
 * that `makeMask` builds for their query count, built once per forward through
 * `masks`. */
export class BatchedTurboQuantKVCache implements AttentionCache, BatchableCache, PaddedPrefillCache {
  readonly denseKvReads = decodedKvStorage;
  readonly #storage = new KvTensorRows();
  readonly #codec: TurboQuantCodec;
  #reuseOffsets: number[] = [];
  #headDim: number | null = null;
  constructor(readonly kBits: number, readonly vBits: number,
    readonly fusedDecode = turboQuantFusedDecode(),
    /** The per-forward masks of the model this layout serves. */
    readonly masks = new AttentionMasks()) {
    this.#codec = new TurboQuantCodec(kBits, vBits, fusedDecode);
  }

  appendDecode(k: MlxArray, v: MlxArray): AttentionRead {
    return this.#read(k, v, this.#mask(1, unmaskedLease));
  }

  appendWindow(k: MlxArray, v: MlxArray): AttentionRead {
    return this.#read(k, v, this.#mask(k.shape[2]!, causalLease));
  }

  #read(k: MlxArray, v: MlxArray, mask: MaskLease): AttentionRead {
    return withLease(mask, held => {
      const [keys, values] = this.#append(k, v, true);
      return rotatedValueRead(keys, values, held);
    });
  }

  /** `aligned` while every row is unpadded at one position; otherwise the
   * per-row mask of an `N`-position append, before it. */
  #mask(N: number, aligned: MaskLease): MaskLease {
    const pads = this.leftPad, ends = this.rowOffsets.map((offset, row) => offset + pads[row]!);
    if (pads.every(pad => pad === 0) && ends.every(end => end === ends[0])) return aligned;
    return this.masks.lease("batched-turboquant", `${N}|${this.rowOffsets.join(",")}|${pads.join(",")}`,
      () => this.#storage.makeMask(N, null));
  }
  restorePrefillEnds(ends: readonly number[] | undefined): void { this.#storage.restorePrefillEnds(ends); }
  preparePrefill(padding: PrefillPadding): void {
    this.#storage.preparePrefill(padding);
    if (!this.#reuseOffsets.length) this.#reuseOffsets = padding.lengths.map(() => 0);
  }
  finalizePrefill(): void { this.#storage.finalizePrefill(); }
  captureDonorRows(): import("../contracts/mlx/cache").KvDonorRows {
    if (!this.#storage.planes.length || this.#headDim === null) throw new Error("cache is empty");
    const [keys, values] = this.#codec.decode(encoded(this.#storage.planes), this.offset, this.#headDim, false);
    return { keys, values, ...this.#storage.captureDonorValidity() };
  }
  captureDonorAttention(): import("../contracts/mlx/cache").KvDonorAttention {
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
  makeEmptyBatch(): BatchedTurboQuantKVCache { return new BatchedTurboQuantKVCache(this.kBits, this.vBits, this.fusedDecode, this.masks); }
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
    const result = new TurboQuantKVCache(this.kBits, this.vBits, this.fusedDecode), count = this.rowOffsets[row]!;
    if (count) result.restoreState(encoded(this.#storage.extractRow(row)), count, this.#headDim!);
    result.minimumReusableOffset = this.#reuseOffsets[row] ?? 0;
    return result;
  }
  dispose(): void { this.#storage.dispose(); this.#headDim = null; this.#reuseOffsets = []; this.masks.clear(); }
}
