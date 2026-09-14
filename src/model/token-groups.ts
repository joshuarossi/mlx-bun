import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Cache } from "./gemma4-base";

export interface TokenWorkOptions {
  /** Verification keeps its established GEMV/GEMM geometry. Other groups may
   * still pack their tokenwise work independently. */
  readonly preserveTokenGeometry?: boolean;
  /** Borrows a residual stream; the method copies only the layers it needs.
   * The layer-count index denotes the post-final-norm output. */
  readonly captureLayer?: (layer: number, hidden: MlxArray) => void;
}

/** Independent sequences presented to one model execution. Each item keeps
 * its existing rectangular row geometry and owns a disjoint cache. */
export interface TokenGroup extends TokenWorkOptions {
  readonly ids: MlxArray;
  readonly cache: Cache[];
}

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
