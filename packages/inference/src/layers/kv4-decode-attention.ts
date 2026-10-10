import type { MlxArray } from "@mlx-bun/mlx/array";
import type * as ops from "@mlx-bun/mlx/ops";
import { kvq4DecodeEligible, kvq4DecodeSdpa } from "../kernels/attention/kvq4-decode";

/** One-row decode attention over a 4-bit, group-64 quantized KV cache with
 *  head dim 256 (kernels/attention/kvq4-decode): every packed K/V row is read
 *  once for all query heads of its KV head. q [1, H, 1, 256] → [1, H, 1, 256].
 *  Not bit-identical to quantizedSdpa (bf16-level). */
export function kv4DecodeAttention(q: MlxArray, keys: ops.QuantizedTensor, values: ops.QuantizedTensor, scale: number,
  groupSize: number, bits: number): MlxArray {
  if (!kvq4DecodeEligible(q, keys, groupSize, bits))
    throw new Error("kv4DecodeAttention: needs one query row, head dim 256, a 4-bit group-64 cache and an even GQA factor");
  return kvq4DecodeSdpa(q, keys, values, scale);
}
