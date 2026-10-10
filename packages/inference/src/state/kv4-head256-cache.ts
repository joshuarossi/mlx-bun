import { kv4DecodeAttention } from "../layers/kv4-decode-attention";
import { foldedQuantizedSdpa } from "../layers/quantized-attention";
import { unfusedKernel, type AffineKernels } from "./affine-attention";
import { AttentionMasks } from "./attention-read";
import { QuantizedKVCache } from "./quantized-kv";

/** The kernels of the Qwen3.8-27B Trellis M4 Pro graph's full-attention layers
 * (`decodeCore` and `foldedCore` there). Neither reads the mask: the window
 * kernel builds its own causal limits over the last L positions. Under an
 * array mask the graph's plans do not apply and it runs the generic forward,
 * whose `quantizedSdpa` is unfused there; this storage never makes one. */
const kernels: AffineKernels = {
  decode: (q, keys, values, scale) => kv4DecodeAttention(q, keys, values, scale, 64, 4),
  window: (q, keys, values, scale) => foldedQuantizedSdpa(q, keys, values, scale, 64, 4),
  maskedWindow: unfusedKernel(64, 4),
};

/** The 4-bit group-64 head-dim-256 full-attention cache the M4 Pro Qwen3.8
 * composition reads: `QuantizedKVCache` storage whose decode read is the fused
 * one-row KV4 kernel (`kv4DecodeAttention`, each packed key and value row read
 * once for every query head of its KV head) and whose window read folds GQA
 * into rows (`foldedQuantizedSdpa`, one quantized matmul per KV head for its
 * query rows, causal over the last L positions). The committed read is
 * `QuantizedKVCache`'s, which the graph's fill spans take today.
 *
 * One row (B = 1), head dim 256, an even GQA factor: the decode kernel throws
 * outside those shapes, and the window kernel's reshape takes one row. Each
 * read is bit-identical to the kernel the graph calls today;
 * neither kernel is bit-identical to `quantizedSdpa` (f32 online softmax,
 * regrouped rows: bf16-level). A one-row window takes the folded kernel, where
 * the graph's one-row plan takes the KV4 decode kernel. Row layouts made from
 * this cache keep its kernels. */
export class Kv4Head256Cache extends QuantizedKVCache {
  constructor(masks = new AttentionMasks()) { super(64, 4, kernels, masks); }
}
