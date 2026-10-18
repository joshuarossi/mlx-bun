import host.ts.Source
namespace Host.Ts.Sources.Inference.State.QuantizedTensor
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/quantized-tensor.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";


export const mapTriple = (
  t: ops.QuantizedTensor, f: (a: MlxArray) => MlxArray,
): ops.QuantizedTensor => ({ packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) });

export const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose();
  t.scales.dispose();
  t.biases.dispose();
};

/** The dense fetch of affine storage: the keys and values an affine append
 * fetched (`updateAndFetchQuantized`), each dequantized (to the activation
 * dtype its scales carry), as a read that attends keys and values as arrays
 * takes them. Takes ownership of both triples; the caller owns the result. */
export function dequantizedFetch([keys, values]: [ops.QuantizedTensor, ops.QuantizedTensor],
  groupSize: number, bits: number): [MlxArray, MlxArray] {
  try {
    const dense = (t: ops.QuantizedTensor) => ops.dequantize(t.packed, t.scales, t.biases, { groupSize, bits, mode: "affine" });
    const k = dense(keys);
    try { return [k, dense(values)]; } catch (error) { k.dispose(); throw error; }
  } finally { disposeTriple(keys); disposeTriple(values); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.QuantizedTensor
