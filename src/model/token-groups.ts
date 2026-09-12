import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Cache } from "./gemma4-base";

/** Independent sequences presented to one model execution. Each item keeps
 * its existing rectangular row geometry and owns a disjoint cache. */
export interface TokenGroup {
  readonly ids: MlxArray;
  readonly cache: Cache[];
}

export interface MixedTokenModel {
  /** Borrows inputs/state; returns one owned hidden array per input group. */
  forwardHiddenMixed(groups: readonly TokenGroup[]): MlxArray[];
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
