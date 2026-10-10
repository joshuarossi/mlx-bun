import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionRead, Mask } from "../contracts/mlx/cache";
import { quantizedAppendAttention } from "../layers/quantized-append-attention";
import { fusedSdpaConfigSupported, quantizedSdpaTiled, quantizedSdpaUnfused } from "../layers/quantized-attention";
import type { AttentionMasks, MaskLease } from "./attention-read";
import { disposeTriple } from "./quantized-tensor";

/** One attention kernel over affine-quantized keys and values: queries
 * [B, Hq, L, D] to an owned output [B, Hq, L, Dv]. Borrows every input. */
export type AffineKernel = (q: MlxArray, keys: ops.QuantizedTensor, values: ops.QuantizedTensor,
  scale: number, mask: Mask) => MlxArray;

/** The kernel an affine cache attends with for each read. The cache takes it
 * when it is built and never chooses again: `unfusedAffineKernels` for a
 * uniform `--kv-quant N`, `tiledCausalAffineKernels` for `--kv-quant config`,
 * `tiledAffineKernels` for the opt-in always-tiled composition, or a
 * device-specific cache's own. */
export interface AffineKernels {
  /** The decode read: one query per row. */
  readonly decode: AffineKernel;
  /** The window read (`L` causal queries per row) while the cache's own mask
   * is plain causal. */
  readonly window: AffineKernel;
  /** The window read once the cache's own state makes its mask an array:
   * padded or unequal rows in a batched cache, the sliding window bound in a
   * rotating cache. The cache picks it on the branch that picks that mask,
   * from state it owns, never from anything the caller passes. */
  readonly maskedWindow: AffineKernel;
}

/** The stock unfused port (`quantizedSdpaUnfused`). */
export function unfusedKernel(groupSize: number, bits: number): AffineKernel {
  return (q, keys, values, scale, mask) => quantizedSdpaUnfused(q, keys, values, scale, mask, groupSize, bits);
}

/** The N-tiled fused port (`quantizedSdpaTiled`). It folds GQA into 5-D
 * scores, so a per-row mask [B, 1, L, N] takes the unit KV-head axis there,
 * as the unfused port inserts it for itself. */
export function tiledKernel(groupSize: number, bits: number): AffineKernel {
  return (q, keys, values, scale, mask) => {
    if (mask.arr?.ndim === 4 && q.shape[1] !== keys.packed.shape[1]) {
      using arr = ops.expandDims(mask.arr, 1);
      return quantizedSdpaTiled(q, keys, values, scale, { mode: "array", arr }, groupSize, bits);
    }
    return quantizedSdpaTiled(q, keys, values, scale, mask, groupSize, bits);
  };
}

/** Every read unfused: mlx-lm's quantized SDPA port. The composition of a
 * uniform `--kv-quant N` (KV scheme `affine`), which keeps mlx-lm parity; it is
 * what `quantizedSdpa` computes with MLX_BUN_NO_FUSED_SDPA=1. The unfused port
 * takes any bits, group size and activation dtype, so the dtype only names the
 * configuration. */
export function unfusedAffineKernels(bits: number, groupSize: number, _dtype: Dtype): AffineKernels {
  const unfused = unfusedKernel(groupSize, bits);
  return { decode: unfused, window: unfused, maskedWindow: unfused };
}

/** OptiQ's wrapper rule: decode unfused (what one query gets in
 * `quantizedSdpa`); a window through the N-tiled fused port while the cache's
 * own mask is plain causal, and through the unfused port once the cache's own
 * state makes that mask an array (padded or unequal rows in a batched cache,
 * the sliding window bound in a rotating cache). The choice keys only on state
 * the cache owns, like the ring wrap or the delayed-quantization transition,
 * never on anything the caller passes. The composition of `--kv-quant config`
 * (KV scheme `affine-layers`), which keeps OptiQ parity; it is what
 * `quantizedSdpa` computes with fused SDPA on. Throws at construction when the
 * tiled port does not take these bits, group size and activation `dtype`. */
export function tiledCausalAffineKernels(bits: number, groupSize: number, dtype: Dtype): AffineKernels {
  supportsTiling("tiledCausalAffineKernels", bits, groupSize, dtype);
  const unfused = unfusedKernel(groupSize, bits);
  return { decode: unfused, window: tiledKernel(groupSize, bits), maskedWindow: unfused };
}

/** Decode unfused, every window through the N-tiled fused port, masked ones
 * included. The always-tiled composition: no oracle computes it, so it is
 * opt-in and gated by KL. Throws at construction when the tiled port does not
 * take these bits, group size and activation `dtype`
 * (`fusedSdpaConfigSupported`); it never falls back to the unfused port. */
export function tiledAffineKernels(bits: number, groupSize: number, dtype: Dtype): AffineKernels {
  supportsTiling("tiledAffineKernels", bits, groupSize, dtype);
  const tiled = tiledKernel(groupSize, bits);
  return { decode: unfusedKernel(groupSize, bits), window: tiled, maskedWindow: tiled };
}

function supportsTiling(name: string, bits: number, groupSize: number, dtype: Dtype): void {
  if (!fusedSdpaConfigSupported(groupSize, bits, dtype))
    throw new Error(`${name}: the tiled port takes 4- or 8-bit, group 32, 64 or 128, bf16 or f16 ` +
      `activations; got ${bits}-bit, group ${groupSize}, dtype ${dtype}`);
}

/** A read over fetched affine keys and values: `kernel` under the leased
 * mask. Takes ownership of `keys`, `values` and `mask`. */
export function affineRead(keys: ops.QuantizedTensor, values: ops.QuantizedTensor, mask: MaskLease,
  kernel: AffineKernel): AttentionRead {
  return {
    attend: (q, scale) => kernel(q, keys, values, scale, mask.mask),
    dispose() { disposeTriple(keys); disposeTriple(values); mask.release(); },
  };
}

/** The committed read over fetched affine keys and values: each position of
 * the span attends its own causal prefix through the one-query unfused port
 * (`quantizedAppendAttention`, the graphs' independent-rows path). One row.
 * Takes ownership of `keys` and `values`. */
export function committedAffineRead(keys: ops.QuantizedTensor, values: ops.QuantizedTensor,
  groupSize: number, bits: number): AttentionRead {
  return {
    attend: (q, scale) => quantizedAppendAttention(q, keys, values, scale, groupSize, bits),
    dispose() { disposeTriple(keys); disposeTriple(values); },
  };
}

/** The bottom-right-aligned causal matrix, bool [L, N] (query `i` sees keys
 * `0..N-L+i`), that both affine kernels build for themselves from the
 * "causal" mask, here built once per forward through `masks`. */
export function affineCausalLease(masks: AttentionMasks, L: number, N: number): MaskLease {
  return masks.lease("affine-causal", `${L}|${N}`, () => ({ mode: "array", arr: bottomRightCausal(L, N) }));
}

/** The kernels' "causal" branch, verbatim. */
function bottomRightCausal(L: number, N: number): MlxArray {
  const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
  const kIdx = ops.arange(0, N, 1, Dtype.int32);
  const qCol = ops.reshape(qIdx, [L, 1]);
  const kRow = ops.reshape(kIdx, [1, N]);
  const mask = ops.greaterEqual(qCol, kRow);
  for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  return mask;
}
