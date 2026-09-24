import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";

/** Apply a tokenwise block while respecting each method's numerical policy. */
export function mapTokenGroups(
  groups: readonly TokenGroup[], inputs: readonly MlxArray[],
  operation: (hidden: MlxArray) => MlxArray, pack = true,
): MlxArray[] {
  const results: MlxArray[] = [];
  const packedRows = groups.flatMap((group, row) => pack && !group.preserveTokenGeometry ? [row] : []);
  try {
    const packed = packedRows.length ? mapPackedTokens(packedRows.map(row => inputs[row]!), operation) : [];
    for (const [index, row] of packedRows.entries()) results[row] = packed[index]!;
    for (let row = 0; row < groups.length; row++) results[row] ??= operation(inputs[row]!);
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

import { TokenGroup } from "../contracts/mlx/token-work";
export { type MixedTokenModel,type TokenGroup,type TokenWorkOptions } from "../contracts/mlx/token-work";
