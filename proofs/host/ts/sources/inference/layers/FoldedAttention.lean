import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.FoldedAttention
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/folded-attention.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** The windows MLX's fused SDPA hands to its unfused fallback for want of a
 *  vector kernel: at most 8 causal queries per row (above that its full
 *  attention kernel serves), more than 32 query vectors per KV head (the
 *  vector kernel's limit), no more queries than keys. q [B, H, L, D], keys
 *  [B, KVH, N, D]. */
export function foldedSdpaEligible(q: MlxArray, keys: MlxArray): boolean {
  const [, H, L] = q.shape as [number, number, number, number];
  const KVH = keys.shape[1]!;
  return L <= 8 && H % KVH === 0 && L * (H / KVH) > 32 && L <= keys.shape[2]!;
}

/** Causal attention over bf16 keys and values with GQA folded into rows: the
 *  rep·L query vectors of each KV head multiply its keys in one matmul and its
 *  values in another, so the cache is read once per KV head instead of once per
 *  query head (MLX's fallback broadcasts each KV head over its query heads).
 *  Otherwise MLX's fallback arithmetic, op for op: the scale cast to the query
 *  dtype, the bottom-right causal mask at -inf, the precise softmax. Bit for bit
 *  `ops.sdpa` on the windows `foldedSdpaEligible` takes on `applegpu_g13s`, where
 *  it was measured, and to bf16 precision elsewhere (rows (r, i): head
 *  KVH·rep + r, query i, which sees keys j <= N - L + i). q [B, H, L, D], keys
 *  and values [B, KVH, N, D] (any strides) → [B, H, L, D], owned by the caller. */
export function foldedSdpa(q: MlxArray, keys: MlxArray, values: MlxArray, scale: number): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KVH = keys.shape[1]!, N = keys.shape[2]!, rep = H / KVH;
  using scaled = ops.mulScalar(q, scale);
  using rows = ops.reshape(scaled, [B, KVH, rep * L, D]);
  using keysT = ops.transposeAxes(keys, [0, 1, 3, 2]);
  using scores = ops.matmul(rows, keysT);                          // [B, KVH, rep·L, N]
  using cols = ops.arange(0, N, 1, Dtype.int32);
  using colRow = ops.reshape(cols, [1, N]);
  using limits = ops.fromInt32(Array.from({ length: rep * L }, (_, row) => N - L + (row % L)), [rep * L, 1]);
  using visible = ops.lessEqual(colRow, limits);
  using ninf = ops.scalarLike(-Infinity, scores);
  using masked = ops.where(visible, scores, ninf);
  using probs = ops.softmaxAxis(masked, -1, true);
  using out = ops.matmul(probs, values);                            // [B, KVH, rep·L, Dv]
  return ops.reshape(out, [B, H, L, out.shape[3]!]);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.FoldedAttention
