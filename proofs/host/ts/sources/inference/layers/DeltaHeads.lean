import host.ts.Source
namespace Host.Ts.Sources.Inference.Layers.DeltaHeads
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/layers/delta-heads.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { siluRmsHeads } from "../kernels/delta/silu-rms-heads";

const functions = new Map<string, CompiledFunction>();

/** Shape-aware replay of the fused activation and Q/K RMS norms.
 * Shared traces take both scale vectors as inputs and retain no layer weights. */
export class CompiledSiluRMSHeads {
  readonly #operation: CompiledFunction;
  constructor(readonly keyHeads: number, readonly valueHeads: number, readonly valueWidth: number) {
    const key = `${keyHeads}:${valueHeads}:${valueWidth}`;
    let operation = functions.get(key);
    if (!operation) {
      operation = new CompiledFunction(inputs => siluRmsHeads(inputs[0]!, inputs[1]!, inputs[2]!, keyHeads, valueHeads, valueWidth), false);
      functions.set(key, operation);
    }
    this.#operation = operation;
  }
  forward(x: MlxArray, qScale: MlxArray, kScale: MlxArray): [MlxArray, MlxArray, MlxArray] {
    return this.#operation.apply([x, qScale, kScale]) as [MlxArray, MlxArray, MlxArray];
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Layers.DeltaHeads
