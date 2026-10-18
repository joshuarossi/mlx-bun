import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.QuantizedAppendAttention
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/quantized-append-attention.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { quantizedSdpaUnfused } from "./quantized-attention";

/** Committed positions retain single-token attention arithmetic (the unfused
 * port, which one query always takes). Projection work can still share the
 * span; each query sees its own causal KV prefix. */
export function quantizedAppendAttention(
  q: MlxArray, keys: ops.QuantizedTensor, values: ops.QuantizedTensor,
  scale: number, groupSize: number, bits: number,
): MlxArray {
  const [batch, heads, length, dim] = q.shape as [number, number, number, number];
  const prefix = keys.packed.shape[2]! - length;
  const outputs: MlxArray[] = [];
  const trim = (tensor: ops.QuantizedTensor, end: number) => {
    const slice = (a: MlxArray) => a.slice([0, 0, 0, 0],
      [a.shape[0]!, a.shape[1]!, end, a.shape[3]!]);
    return { packed: slice(tensor.packed), scales: slice(tensor.scales), biases: slice(tensor.biases) };
  };
  try {
    for (let row = 0; row < length; row++) {
      using queryView = q.slice([0, 0, row, 0], [batch, heads, row + 1, dim]);
      using query = ops.contiguous(queryView);
      const k = trim(keys, prefix + row + 1), v = trim(values, prefix + row + 1);
      try { outputs.push(quantizedSdpaUnfused(query, k, v, scale, { mode: "", arr: null }, groupSize, bits)); }
      finally {
        for (const t of [k, v]) { t.packed.dispose(); t.scales.dispose(); t.biases.dispose(); }
      }
    }
    return ops.concatAxis(outputs, 2);
  } finally { for (const output of outputs) output.dispose(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.QuantizedAppendAttention
