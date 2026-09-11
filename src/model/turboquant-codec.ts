import type { MlxArray } from "../mlx/array";
import * as tq from "../mlx/turboquant-ops";
import type { KvCodec } from "../backends/mlx/kv-codec";

/** One TurboQuant-encoded (K, V) storage tuple — the 5 arrays kv-store.ts
 *  and toQuantized/fromKVCache pass around. Not `ops.QuantizedTensor`
 *  (mlx's affine int4/int8 scheme): this is the rotation + Lloyd-Max
 *  layout (docs/design/turboquant.md), asymmetric-affine for keys,
 *  FWHT+Lloyd-Max for values. Field order is the kv-store.ts tensor-slot
 *  contract — do not reorder without updating snapshotCache/loadKvCache. */
export interface TurboQuantTensor {
  kIdx: MlxArray;
  kScales: MlxArray;
  kZeros: MlxArray;
  vPacked: MlxArray;
  vScales: MlxArray;
}

export const disposeTurboQuant = (t: TurboQuantTensor): void => {
  t.kIdx.dispose();
  t.kScales.dispose();
  t.kZeros.dispose();
  t.vPacked.dispose();
  t.vScales.dispose();
};

/** Numerical representation only. Storage owns capacity, positions, row
 * membership and persistence; this codec retains the existing kernel choices. */
export class TurboQuantCodec implements KvCodec<TurboQuantTensor> {
  constructor(readonly kBits: number, readonly vBits: number, readonly fusedDecode: boolean) {}

  /** Encode k/v [B,H,L,D] into a fresh TurboQuantTensor (packed at rest). */
  encode(k: MlxArray, v: MlxArray): TurboQuantTensor {
    const signed = this.kBits === 8;
    const kEnc = tq.encodeKeys(k, this.kBits, signed);
    const kIdxPacked = this.kBits < 8 ? tq.packBits(kEnc.indices, this.kBits) : kEnc.indices;
    if (kIdxPacked !== kEnc.indices) kEnc.indices.dispose();
    const vEnc = tq.encodeValues(v, this.vBits);
    const vIdxPacked = this.vBits < 8 ? tq.packBits(vEnc.indices, this.vBits) : vEnc.indices;
    if (vIdxPacked !== vEnc.indices) vEnc.indices.dispose();
    return {
      kIdx: kIdxPacked, kScales: kEnc.scales, kZeros: kEnc.zeros,
      vPacked: vIdxPacked, vScales: vEnc.scales,
    };
  }

  /** Decode a TurboQuantTensor's active [B,H,upTo,*] window back to
   *  bf16 [B,H,upTo,headDim] (k, v). Caller owns the returned arrays.
   *  deferV leaves V in the rotated domain (decodeValuesRotated) — the
   *  caller un-rotates its attention output instead (tq.unrotateValues). */
  decode(t: TurboQuantTensor, upTo: number, headDim: number, deferV = false): [MlxArray, MlxArray] {
    const cut = (a: MlxArray): MlxArray => {
      const [B, H, , D] = a.shape as [number, number, number, number];
      return a.slice([0, 0, 0, 0], [B, H, upTo, D]);
    };
    if (this.fusedDecode) {
      const inputs = [cut(t.kIdx), cut(t.kScales), cut(t.kZeros), cut(t.vPacked), cut(t.vScales)] as const;
      try {
        const decoded = tq.tryDecodePackedKv(inputs, this.kBits, this.vBits, headDim, deferV);
        if (decoded) return decoded;
      } finally { for (const input of inputs) input.dispose(); }
    }
    const kIdxCut = cut(t.kIdx);
    const kIdxUnpacked = this.kBits < 8 ? tq.unpackBits(kIdxCut, this.kBits, headDim) : kIdxCut;
    if (kIdxUnpacked !== kIdxCut) kIdxCut.dispose();
    const kScalesCut = cut(t.kScales);
    const kZerosCut = cut(t.kZeros);
    const k = tq.decodeKeys(kIdxUnpacked, kScalesCut, kZerosCut);
    for (const a of [kIdxUnpacked, kScalesCut, kZerosCut]) a.dispose();

    const vPackedCut = cut(t.vPacked);
    const vIdxUnpacked = this.vBits < 8 ? tq.unpackBits(vPackedCut, this.vBits, headDim) : vPackedCut;
    if (vIdxUnpacked !== vPackedCut) vPackedCut.dispose();
    const vScalesCut = cut(t.vScales);
    const v = deferV
      ? tq.decodeValuesRotated(vIdxUnpacked, vScalesCut, this.vBits)
      : tq.decodeValues(vIdxUnpacked, vScalesCut, this.vBits);
    for (const a of [vIdxUnpacked, vScalesCut]) a.dispose();

    return [k, v];
  }

}
