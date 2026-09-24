import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype,deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Mask } from "../contracts/mlx/cache";
import { isCompiledTrace } from "../runtime/compiled-trace";
import { runtimeValue } from "../runtime/config";


export const FINFO_MIN: Partial<Record<Dtype, number>> = {
  [Dtype.bfloat16]: -3.3895313892515355e38,
  [Dtype.float16]: -65504,
  [Dtype.float32]: -3.4028234663852886e38,
};

/** Port of base.py quantized_scaled_dot_product_attention (stock,
 *  non-tiled): scores and output via quantized_matmul against the
 *  quantized KV triples; GQA via a 5-d reshape. Exported for the
 *  fused-vs-unfused parity tests. */
export function quantizedSdpaUnfused(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  const N = kq.packed.shape[2]!;

  // scale is 1.0 for Gemma4 (q/k are RMS-normed) — skip the identity multiply.
  let queries = q;
  const owned: MlxArray[] = [];
  if (scale !== 1.0) { queries = ops.mulScalar(q, scale); owned.push(queries); }

  let kT = kq;
  let vT = vq;
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    owned.push(qr);
    queries = qr;
    const expand = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const e = (a: MlxArray): MlxArray => {
        // expand_dims(axis=-3) like the reference — view-preserving;
        // reshape would copy the strided slice and change kernel paths
        const r = ops.expandDims(a, -3);
        owned.push(r);
        return r;
      };
      return { packed: e(t.packed), scales: e(t.scales), biases: e(t.biases) };
    };
    kT = expand(kq);
    vT = expand(vq);
  }

  // M4 Pro's native key matvec retains exact arithmetic when three GQA
  // heads share a batch. Restore score geometry before softmax/value work.
  const groupHeads = B <= 2 && H === 24 && KV === 4 && L === 3 && D === 256 &&
    N >= 8192 && groupSize === 64 && bits === 4 &&
    (q.dtype === Dtype.bfloat16 || q.dtype === Dtype.float32) &&
    deviceArchitecture() === "applegpu_g16s";
  let keyQueries = queries;
  if (groupHeads) {
    keyQueries = ops.reshape(queries, [B, KV, 2, 9, D]);
    owned.push(keyQueries);
  }
  let scores = ops.quantizedMatmulQT(keyQueries, kT, true, groupSize, bits);
  owned.push(scores);
  if (groupHeads) {
    scores = ops.reshape(scores, [B, KV, nRep, L, N]);
    owned.push(scores);
  }

  let maskArr: MlxArray | null = null;
  let ownsMask = false;
  if (mask.mode === "causal") {
    const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
    const kIdx = ops.arange(0, N, 1, Dtype.int32);
    const qCol = ops.reshape(qIdx, [L, 1]);
    const kRow = ops.reshape(kIdx, [1, N]);
    maskArr = ops.greaterEqual(qCol, kRow);
    ownsMask = true;
    for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  } else if (mask.mode === "array") {
    maskArr = mask.arr;
    // Batched padding masks are [B,1,L,S] (buildBatchedDecodeMask). When GQA
    // reshaped the scores to 5-D [B,KV,nRep,L,S], trailing-dim broadcasting
    // would misalign the mask's B with KV — insert the unit axis explicitly:
    // [B,1,1,L,S] broadcasts correctly over (KV, nRep).
    if (maskArr && maskArr.ndim === 4 && nRep > 1) {
      maskArr = ops.expandDims(maskArr, 1);
      ownsMask = true;
    }
  }
  if (maskArr) {
    let masked: MlxArray;
    if (maskArr.dtype === Dtype.bool) {
      using ninf = ops.scalarLike(FINFO_MIN[scores.dtype] ?? -3.4e38, scores);
      masked = ops.where(maskArr, scores, ninf);
    } else masked = ops.add(scores, maskArr);
    if (ownsMask) maskArr.dispose();
    owned.push(masked);
    scores = masked;
  }

  const probs = ops.softmaxAxis(scores, -1, true);
  owned.push(probs);
  let out = ops.quantizedMatmulQT(probs, vT, false, groupSize, bits);
  if (nRep > 1) {
    const r = ops.reshape(out, [B, H, L, D]);
    out.dispose();
    out = r;
  }
  for (const a of owned) a.dispose();
  return out;
}

/** Tile size for the fused quantized-SDPA prefill path (oracle default). */
export const FUSED_N_CHUNK = 512;

/** Port of optiq fused_quant_sdpa._prefill_flashattn_n_tiled: a
 *  FlashAttention-2 loop over the KV N axis with mx.quantized_matmul as
 *  the inner kernel. Never materializes the full [..., L, N] scores
 *  matrix — the per-tile transient is bounded by FUSED_N_CHUNK, which is
 *  the whole point (stock u4 KV prefill peaks ABOVE fp16 KV at long
 *  context; see the oracle's module docstring). Op composition order
 *  mirrors the oracle exactly: parity is tier a (bit-exact) vs the python
 *  fused path; vs quantizedSdpaUnfused it is tier b by construction
 *  (online softmax ≠ one-shot precise softmax in bf16). */
export function quantizedSdpaTiled(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  const N = kq.packed.shape[2]!;

  // scale is 1.0 for Gemma4 (q/k are RMS-normed) — skip the identity multiply.
  let queries = q;
  let ownsQueries = false;
  if (scale !== 1.0) { queries = ops.mulScalar(q, scale); ownsQueries = true; }

  let kT = kq;
  let vT = vq;
  const expanded: MlxArray[] = [];
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    if (ownsQueries) queries.dispose();
    queries = qr;
    ownsQueries = true;
    const expand = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const e = (a: MlxArray): MlxArray => {
        const r = ops.expandDims(a, -3);
        expanded.push(r);
        return r;
      };
      return { packed: e(t.packed), scales: e(t.scales), biases: e(t.biases) };
    };
    kT = expand(kq);
    vT = expand(vq);
  }

  // The oracle builds a bottom-right-aligned [L, N] bool causal matrix
  // and slices columns per tile; our "array" masks (createCausalMask at
  // offset > 0) are that same matrix already materialized — both slice
  // identically below.
  let maskArr: MlxArray | null = null;
  let ownsMask = false;
  if (mask.mode === "causal") {
    const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
    const kIdx = ops.arange(0, N, 1, Dtype.int32);
    const qCol = ops.reshape(qIdx, [L, 1]);
    const kRow = ops.reshape(kIdx, [1, N]);
    maskArr = ops.greaterEqual(qCol, kRow);
    ownsMask = true;
    for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  } else if (mask.mode === "array") {
    maskArr = mask.arr;
  }

  // Slice [..., n0:n1, :] (KV triples) / [..., n0:n1] (mask chunks).
  // Under a compiled-decode trace, subrange Slice swaps to DynamicSlice
  // (identical values; shapeless compile rejects Slice — same pattern as
  // the per-layer-input and MoE top-k slices).
  const sliceAxis = (a: MlxArray, axisFromEnd: 1 | 2, n0: number, n1: number): MlxArray => {
    const dims = a.shape;
    const axis = dims.length - axisFromEnd;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([n0], [1]);
      const size = [...dims];
      size[axis] = n1 - n0;
      const out = ops.sliceDynamic(a, start, [axis], size);
      start.dispose();
      return out;
    }
    const start = dims.map(() => 0);
    const stop = [...dims];
    start[axis] = n0;
    stop[axis] = n1;
    return a.slice(start, stop);
  };

  let oAcc: MlxArray | null = null;
  let rowMax: MlxArray | null = null;
  let rowSum: MlxArray | null = null;

  for (let n0 = 0; n0 < N; n0 += FUSED_N_CHUNK) {
    const n1 = Math.min(n0 + FUSED_N_CHUNK, N);
    const kChunk: ops.QuantizedTensor = {
      packed: sliceAxis(kT.packed, 2, n0, n1),
      scales: sliceAxis(kT.scales, 2, n0, n1),
      biases: sliceAxis(kT.biases, 2, n0, n1),
    };
    const vChunk: ops.QuantizedTensor = {
      packed: sliceAxis(vT.packed, 2, n0, n1),
      scales: sliceAxis(vT.scales, 2, n0, n1),
      biases: sliceAxis(vT.biases, 2, n0, n1),
    };

    let scores = ops.quantizedMatmulQT(queries, kChunk, true, groupSize, bits);
    for (const a of [kChunk.packed, kChunk.scales, kChunk.biases]) a.dispose();

    if (maskArr) {
      const maskChunk = sliceAxis(maskArr, 1, n0, n1);
      let masked: MlxArray;
      if (maskChunk.dtype === Dtype.bool) {
        const ninf = ops.scalarLike(FINFO_MIN[scores.dtype] ?? -3.4e38, scores);
        masked = ops.where(maskChunk, scores, ninf);
        ninf.dispose();
      } else {
        masked = ops.add(scores, maskChunk);
      }
      maskChunk.dispose();
      scores.dispose();
      scores = masked;
    }

    const chunkMax = ops.maxAxis(scores, -1, true);
    if (oAcc === null) {
      rowMax = chunkMax;
      const shifted = ops.sub(scores, rowMax);
      const exps = ops.exp(shifted);
      shifted.dispose();
      rowSum = ops.sumAxis(exps, -1, true);
      oAcc = ops.quantizedMatmulQT(exps, vChunk, false, groupSize, bits);
      exps.dispose();
    } else {
      const newMax = ops.maximum(rowMax!, chunkMax);
      chunkMax.dispose();
      const maxDiff = ops.sub(rowMax!, newMax);
      const factor = ops.exp(maxDiff);
      maxDiff.dispose();
      const shifted = ops.sub(scores, newMax);
      const exps = ops.exp(shifted);
      shifted.dispose();
      // new_sum = factor * row_sum + sum(exps)  (association order kept)
      const carried = ops.mul(factor, rowSum!);
      const sumExps = ops.sumAxis(exps, -1, true);
      const newSum = ops.add(carried, sumExps);
      carried.dispose();
      sumExps.dispose();
      const deltaOut = ops.quantizedMatmulQT(exps, vChunk, false, groupSize, bits);
      exps.dispose();
      // o_acc = o_acc * factor + delta_out
      const scaledAcc = ops.mul(oAcc!, factor);
      factor.dispose();
      const nextAcc = ops.add(scaledAcc, deltaOut);
      scaledAcc.dispose();
      deltaOut.dispose();
      oAcc!.dispose();
      oAcc = nextAcc;
      rowMax!.dispose();
      rowMax = newMax;
      rowSum!.dispose();
      rowSum = newSum;
    }
    scores.dispose();
    for (const a of [vChunk.packed, vChunk.scales, vChunk.biases]) a.dispose();
  }

  let out = ops.div(oAcc!, rowSum!);
  oAcc!.dispose();
  rowMax!.dispose();
  rowSum!.dispose();
  if (ownsMask) maskArr!.dispose();
  for (const a of expanded) a.dispose();
  if (ownsQueries) queries.dispose();
  if (nRep > 1) {
    const r = ops.reshape(out, [B, H, L, D]);
    out.dispose();
    out = r;
  }
  return out;
}

/** Gate for the tiled path — port of fused_quant_sdpa._supported plus the
 *  wrapper's mask check, with one documented deviation: the oracle wrapper
 *  falls back to unfused on ARRAY masks because mlx-lm always hands it the
 *  "causal" string for windowless continuations (its make_mask returns
 *  "causal" even at offset > 0); our makeMask materializes the equivalent
 *  bool matrix — so masks flagged causalEquivalent tile too (the oracle's
 *  INNER function handles them with the same column slicing we use).
 *  Window/bidir array masks do NOT tile, matching the reference's
 *  scenario-level dispatch exactly (Phase 9: sliding-layer quantized
 *  prefill is unfused in optiq too). */
function fusedSdpaSupported(q: MlxArray, mask: Mask, groupSize: number, bits: number): boolean {
  // Escape hatch mirroring optiq serve's --no-fused-kv: forces the
  // stock unfused path everywhere. Also the A/B lever for
  // scripts/bench-levers.ts fused-prefill. Read per call (cheap next to the
  // FFI work) so tests and paired A/B harnesses can flip it in-process.
  if (runtimeValue("MLX_BUN_NO_FUSED_SDPA") === "1") return false;
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal" || mask.mode === "") return true; // "" = oracle's mask=None
  if (mask.mode === "array")
    return mask.causalEquivalent === true && mask.arr !== null &&
      mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
  return false;
}

/** Quantized-cache SDPA dispatch: L > 1 (prefill/continuation) with a
 *  supported config goes through the N-tiled fused path; decode (L = 1)
 *  and unsupported configs stay on the stock unfused port. Exported for
 *  the dispatch-gate tests. */
export function quantizedSdpa(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const tile = q.shape[2]! > 1;
  if (tile && fusedSdpaSupported(q, mask, groupSize, bits)) {
    // The N-tiled loop CANNOT be traced: its tile count and slice extents
    // bake at trace-time N, so under shapeless replay a growing (concat-
    // phase) quantized cache's newest rows are silently never attended.
    // This throw is the backstop for any compiled caller — it lands in the
    // trace's transactional fallback instead of producing silently wrong
    // attention.
    if (isCompiledTrace())
      throw new Error(
        "quantizedSdpaTiled inside a compiled trace: the tile loop bakes trace-time N " +
          "(growing KV rows would be silently dropped) — run this generation uncompiled",
      );
    return quantizedSdpaTiled(q, kq, vq, scale, mask, groupSize, bits);
  }
  return quantizedSdpaUnfused(q, kq, vq, scale, mask, groupSize, bits);
}

/** The runtime-only half of fusedSdpaSupported (env flag, dtype, mask
 *  kind) — generated models (Phase D) bake the (bits, group_size) half
 *  as a compile-time constant and call this for the rest. The combined
 *  predicate is exactly fusedSdpaSupported. */
export function fusedSdpaRuntimeOk(q: MlxArray, mask: Mask): boolean {
  if (runtimeValue("MLX_BUN_NO_FUSED_SDPA") === "1") return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal" || mask.mode === "") return true;
  if (mask.mode === "array")
    return mask.causalEquivalent === true && mask.arr !== null &&
      mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
  return false;
}
