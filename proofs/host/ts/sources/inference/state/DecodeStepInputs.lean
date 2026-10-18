import host.ts.Source
namespace Host.Ts.Sources.Inference.State.DecodeStepInputs
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/decode-step-inputs.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { DecodeStepInputs } from "../contracts/mlx/cache";

/** The per-step arrays a cache assembles its compiled-decode closure inputs from.
 *  Everything it creates is pushed onto `temps`, which the caller releases after the step. */
export function decodeStepInputs(temps: MlxArray[]): DecodeStepInputs {
  const writePositions = new Map<number, MlxArray>();
  return {
    activeView(array, length) {
      const stop = [...array.shape];
      stop[2] = length;
      const view = array.slice(stop.map(() => 0), stop);
      temps.push(view);
      return view;
    },
    own(array) {
      temps.push(array);
      return array;
    },
    writePosition(position) {
      let a = writePositions.get(position);
      if (!a) {
        a = ops.fromInt32([position], [1]);
        writePositions.set(position, a);
        temps.push(a);
      }
      return a;
    },
  };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.DecodeStepInputs
