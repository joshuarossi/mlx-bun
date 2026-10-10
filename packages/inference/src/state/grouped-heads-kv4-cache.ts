import { quantizedSdpaGroupedHeads } from "../layers/quantized-attention";
import { unfusedKernel, type AffineKernels } from "./affine-attention";
import { AttentionMasks } from "./attention-read";
import { BatchedQuantizedKVCache } from "./batched-quantized-kv";

const grouped: AffineKernels["window"] = (q, keys, values, scale, mask) =>
  quantizedSdpaGroupedHeads(q, keys, values, scale, mask, 64, 4);
const kernels: AffineKernels = { decode: unfusedKernel(64, 4), window: grouped, maskedWindow: grouped };

/** The 4-bit group-64 batched full-attention cache of a depth-2 speculative
 * verify composition on the M4 Pro GPU (applegpu_g16s): `BatchedQuantizedKVCache`
 * whose window read is the grouped-heads key matmul
 * (`quantizedSdpaGroupedHeads`, three GQA heads per batch, where MLX's native
 * key matvec keeps exact arithmetic at 8192 or more keys) and whose decode read
 * is the stock unfused port. Masks are the batched layout's.
 *
 * The window kernel's contract is the verify window: 3 queries per row, 24
 * query heads, 4 KV heads, head dim 256, B <= 2, bf16 or f32 queries. Today
 * `quantizedSdpaUnfused` applied it on that GPU at those shapes and 8192 or
 * more keys, whenever the dispatch ran unfused; this cache applies it to every
 * window, so it serves only a composition whose windows are all verify windows.
 * Constructed explicitly; nothing selects it by device. */
export class GroupedHeadsKv4Cache extends BatchedQuantizedKVCache {
  constructor(masks = new AttentionMasks()) { super(64, 4, kernels, masks); }
  override makeEmptyBatch(): GroupedHeadsKv4Cache { return new GroupedHeadsKv4Cache(this.masks); }
}
