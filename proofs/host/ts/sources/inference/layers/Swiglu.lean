import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.Swiglu
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/swiglu.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import * as ops from "@mlx-bun/mlx/ops";


/** Verbatim port of mlx_lm/models/activations.py:
 *    `@partial(mx.compile, shapeless=True) def swiglu(gate, x): return nn.silu(gate) * x`
 *  mx.compile fuses sigmoid + mul + mul into ONE kernel (mlx-lm's decode
 *  `CV2ISigmoid…Multiply`) instead of our three separate dispatches. Traced
 *  once, replayed thereafter for decode and prefill. */
let _swigluClosure: CompiledFunction | null = null;
export function compiledSwiglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_swigluClosure) {
    _swigluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!;              // nn.silu(gate) * x
      const sig = ops.sigmoid(g);
      const silu = ops.mul(g, sig); sig.dispose();
      const out = ops.mul(silu, u); silu.dispose();
      return [out];
    });
  }
  return _swigluClosure.apply([gate, up])[0]!;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.Swiglu
