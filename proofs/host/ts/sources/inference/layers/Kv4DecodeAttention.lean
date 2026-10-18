import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.Kv4DecodeAttention
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/kv4-decode-attention.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import type * as ops from "@mlx-bun/mlx/ops";
import { kvq4DecodeEligible, kvq4DecodeSdpa } from "../kernels/attention/kvq4-decode";

/** One-row decode attention over a 4-bit, group-64 quantized KV cache with
 *  head dim 256 (kernels/attention/kvq4-decode): every packed K/V row is read
 *  once for all query heads of its KV head, `block` tokens per threadgroup.
 *  q [1, H, 1, 256] → [1, H, 1, 256]. Not bit-identical to quantizedSdpa
 *  (bf16-level). */
export function kv4DecodeAttention(q: MlxArray, keys: ops.QuantizedTensor, values: ops.QuantizedTensor, scale: number,
  groupSize: number, bits: number, block: number): MlxArray {
  if (!kvq4DecodeEligible(q, keys, groupSize, bits))
    throw new Error("kv4DecodeAttention: needs one query row, head dim 256, a 4-bit group-64 cache and an even GQA factor");
  return kvq4DecodeSdpa(q, keys, values, scale, block);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.Kv4DecodeAttention
