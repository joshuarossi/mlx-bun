import host.ts.Source
namespace Host.Ts.Sources.Inference.Input.TokenGroups
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/input/token-groups.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxPhaseGroup } from "../contracts/mlx/graph";

/** Apply a tokenwise block over the groups of a mixed forward: the groups that
 * may share it packed into one call of the class the caller named (`packed`),
 * a verify group (which keeps its projection geometry) and every group when
 * `pack` is off on its own rows, at its own class. */
export function mapTokenGroups(
  groups: readonly MlxPhaseGroup[], inputs: readonly MlxArray[],
  operation: (hidden: MlxArray, width: number) => MlxArray, packed: number, pack = true,
): MlxArray[] {
  const results: MlxArray[] = [];
  const packedRows = groups.flatMap((group, row) => pack && group.phase !== "verify" ? [row] : []);
  try {
    const outputs = packedRows.length === 1 ? [operation(inputs[packedRows[0]!]!, groups[packedRows[0]!]!.rows)]
      : packedRows.length ? mapPackedTokens(packedRows.map(row => inputs[row]!), hidden => operation(hidden, packed)) : [];
    for (const [index, row] of packedRows.entries()) results[row] = outputs[index]!;
    for (let row = 0; row < groups.length; row++) results[row] ??= operation(inputs[row]!, groups[row]!.rows);
    return results;
  } catch (error) { for (const result of results) result?.dispose(); throw error; }
}

/** Pack real tokens for a tokenwise operation, then restore each group's
 * geometry. Attention and recurrent operations must run outside this port.
 * No padding, host readback, or evaluation is introduced here. */
export function mapPackedTokens(
  inputs: readonly MlxArray[], operation: (packed: MlxArray) => MlxArray,
): MlxArray[] {
  if (inputs.length === 1) return [operation(inputs[0]!)];
  const flat = inputs.map(input => ops.reshape(input, [1, -1, input.shape.at(-1)!]));
  let packed: MlxArray;
  try { packed = ops.concatAxis(flat, 1); }
  finally { for (const input of flat) input.dispose(); }
  using joined = packed;
  using output = operation(joined);
  const results: MlxArray[] = [];
  let position = 0;
  try {
    for (const input of inputs) {
      const [batch, length] = input.shape;
      const end = position + batch! * length!;
      using part = output.slice([0, position, 0], [1, end, output.shape[2]!]);
      results.push(ops.reshape(part, [batch!, length!, output.shape[2]!]));
      position = end;
    }
    return results;
  } catch (error) { for (const result of results) result.dispose(); throw error; }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Input.TokenGroups
