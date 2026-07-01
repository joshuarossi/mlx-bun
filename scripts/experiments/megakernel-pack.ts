// Phase 1 of the MiniCPM5 decode megakernel (docs/design/minicpm5-decode-megakernel.md):
// repack the model's ~340 quantized weight tensors into a SMALL fixed set of device
// buffers a single metal_kernel can take, plus a layout table the kernel GENERATOR
// bakes as compile-time literals (offsets, N, K, bits/group_size per (layer,matrix)).
//
// The weights STAY mixed-precision quantized (4/8-bit per tensor); we concat the
// packed `.w` bytes verbatim and dequant in-kernel. Streaming 0.694 GB of 4/8-bit
// weights — not bf16 — is the whole bandwidth point (see memory cpm5-decode-bandwidth-floor).
//
//   WBYTES : uint8  — every linear's packed `.w` bytes concatenated (L0.q .. lm_head)
//   SCALES : bf16   — every linear's scales concatenated
//   BIASES : bf16   — every linear's biases concatenated
//   NORMS  : bf16   — every RMSNorm weight concatenated (48 layer norms + finalNorm)
//   layout : offsets (WBYTES in BYTES; SCALES/BIASES/NORMS in bf16 ELEMENTS) + dims/bits
//
// Gate: scripts/experiments/megapack-check.ts rebuilds a QuantizedLinear from the
// sliced buffers and asserts byte-identical ops.quantizedMatmul vs the original.

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import type { MiniCPM5Model } from "../../src/model/minicpm5";
import type { QuantizedLinear, RMSNorm } from "../../src/model/gemma4-base";

/** One quantized matrix in the packed buffers. Offsets: `wOff` in BYTES into
 *  WBYTES; `sOff`/`bOff` in bf16 ELEMENTS into SCALES/BIASES. N=out, K=in. */
export interface MatLayout {
  wOff: number; sOff: number; bOff: number;
  N: number; K: number; bits: number; groupSize: number;
}

export interface LayerLayout {
  inputNormOff: number;   // bf16 element offset into NORMS (length H)
  postNormOff: number;
  q: MatLayout; k: MatLayout; v: MatLayout; o: MatLayout;
  gate: MatLayout; up: MatLayout; down: MatLayout;
}

export interface MegaLayout {
  H: number; I: number; V: number;
  nLayers: number; nHeads: number; nKvHeads: number; headDim: number;
  ropeBase: number; eps: number; scale: number;
  layers: LayerLayout[];
  finalNormOff: number;
  lmHead: MatLayout;
  /** Per-layer KV-cache quant bits from config.kvQuant (Phase 4, L2). 0 = bf16
   *  (L1, no kv quant). group_size always 64, quantized along head_dim. */
  kvBits: number[];
  kvGroupSize: number;
}

export interface PackedModel {
  wbytes: MlxArray;  // uint8 [totalBytes]
  scales: MlxArray;  // bf16  [totalScaleEls]
  biases: MlxArray;  // bf16  [totalBiasEls]
  norms: MlxArray;   // bf16  [49 * H]
  layout: MegaLayout;
}

/** Accumulates byte chunks for one packed buffer and tracks the running offset. */
class Concat {
  readonly chunks: Uint8Array[] = [];
  bytes = 0;
  /** Append `a`'s raw bytes; returns the offset (in `unit`-sized elements) where it landed. */
  push(a: MlxArray, unit: number): number {
    const off = this.bytes / unit;
    a.eval();
    const raw = a.rawBytes();
    this.chunks.push(raw);
    this.bytes += raw.byteLength;
    return off;
  }
  build(dtype: Dtype): MlxArray {
    const buf = new Uint8Array(this.bytes);
    let o = 0;
    for (const c of this.chunks) { buf.set(c, o); o += c.byteLength; }
    const elBytes = dtype === Dtype.uint32 ? 4 : dtype === Dtype.bfloat16 ? 2 : 1;
    return MlxArray.fromBytesCopy(buf, [this.bytes / elBytes], dtype);
  }
}

function assertBf16(a: MlxArray, what: string): void {
  if (a.dtype !== Dtype.bfloat16)
    throw new Error(`megakernel-pack: ${what} must be bf16, got ${a.dtypeName}`);
}

export function packMiniCpm5(model: MiniCPM5Model): PackedModel {
  const t = model.config.text;
  const H = t.hiddenSize, headDim = t.headDim;
  const I = model.layers[0]!.mlp.gate.outFeatures;
  const V = model.lmHead.outFeatures;

  const W = new Concat(), S = new Concat(), B = new Concat(), NM = new Concat();

  const pushMat = (lin: QuantizedLinear, what: string): MatLayout => {
    if (lin.biases == null) throw new Error(`megakernel-pack: ${what} has no biases (affine expected)`);
    if (lin.spec.groupSize !== 64) throw new Error(`megakernel-pack: ${what} groupSize=${lin.spec.groupSize}, expected 64`);
    if (lin.spec.bits !== 4 && lin.spec.bits !== 8) throw new Error(`megakernel-pack: ${what} bits=${lin.spec.bits}, expected 4|8`);
    assertBf16(lin.scales, `${what}.scales`);
    assertBf16(lin.biases, `${what}.biases`);
    const N = lin.outFeatures, K = lin.inFeatures;
    const wOff = W.push(lin.w, 1);
    const sOff = S.push(lin.scales, 2);
    const bOff = B.push(lin.biases, 2);
    return { wOff, sOff, bOff, N, K, bits: lin.spec.bits, groupSize: lin.spec.groupSize };
  };
  const pushNorm = (n: RMSNorm, what: string): number => {
    if (n.weight == null) throw new Error(`megakernel-pack: ${what} has no weight`);
    assertBf16(n.weight, what);
    if (n.weight.shape[0] !== H) throw new Error(`megakernel-pack: ${what} length ${n.weight.shape[0]} != H ${H}`);
    return NM.push(n.weight, 2);
  };

  const layers: LayerLayout[] = model.layers.map((layer, i) => ({
    inputNormOff: pushNorm(layer.inputNorm, `L${i}.inputNorm`),
    postNormOff: pushNorm(layer.postAttnNorm, `L${i}.postAttnNorm`),
    q: pushMat(layer.attn.qProj, `L${i}.q`),
    k: pushMat(layer.attn.kProj, `L${i}.k`),
    v: pushMat(layer.attn.vProj, `L${i}.v`),
    o: pushMat(layer.attn.oProj, `L${i}.o`),
    gate: pushMat(layer.mlp.gate, `L${i}.gate`),
    up: pushMat(layer.mlp.up, `L${i}.up`),
    down: pushMat(layer.mlp.down, `L${i}.down`),
  }));
  const finalNormOff = pushNorm(model.finalNorm, "finalNorm");
  const lmHead = pushMat(model.lmHead, "lmHead");

  // Per-layer KV quant bits (L2). config.kvQuant is the optiq kv_config; absent → bf16 (0).
  const kvByLayer = new Map<number, { bits: number; groupSize: number }>(
    (model.config.kvQuant ?? []).map((e) => [e.layerIdx, { bits: e.bits, groupSize: e.groupSize }]),
  );
  const kvGroupSizes = [...kvByLayer.values()].map((e) => e.groupSize);
  if (kvGroupSizes.some((g) => g !== 64)) throw new Error(`megakernel-pack: kv group_size must be 64, got ${kvGroupSizes}`);
  const kvBits = model.layers.map((_, i) => kvByLayer.get(i)?.bits ?? 0);

  const layout: MegaLayout = {
    H, I, V,
    nLayers: model.layers.length,
    nHeads: t.numAttentionHeads, nKvHeads: t.numKeyValueHeads, headDim,
    ropeBase: t.ropeParameters.full_attention?.ropeTheta ?? 10000,
    eps: t.rmsNormEps,
    scale: Math.pow(headDim, -0.5),
    layers, finalNormOff, lmHead,
    kvBits, kvGroupSize: 64,
  };

  return {
    wbytes: W.build(Dtype.uint32),
    scales: S.build(Dtype.bfloat16),
    biases: B.build(Dtype.bfloat16),
    norms: NM.build(Dtype.bfloat16),
    layout,
  };
}
