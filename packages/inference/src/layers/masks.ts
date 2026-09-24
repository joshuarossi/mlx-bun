import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Mask } from "../contracts/cache";


/** Port of base.py create_causal_mask (bool, [N, offset+N]). */
export function createCausalMask(N: number, offset: number, windowSize: number | null): MlxArray {
  const rinds = ops.arange(0, offset + N, 1, Dtype.int32);
  const lindsFlat = offset ? ops.arange(offset, offset + N, 1, Dtype.int32) : rinds;
  const linds = ops.reshape(lindsFlat, [N, 1]);
  const rindsB = ops.reshape(rinds, [1, offset + N]);
  let mask = ops.greaterEqual(linds, rindsB);
  if (windowSize !== null) {
    const w = ops.fromInt32([windowSize], []);
    const rPlusW = ops.add(rindsB, w);
    const inWindow = ops.less(linds, rPlusW);
    const combined = ops.logicalAnd(mask, inWindow);
    for (const a of [w, rPlusW, inWindow, mask]) a.dispose();
    mask = combined;
  }
  if (lindsFlat !== rinds) lindsFlat.dispose();
  rinds.dispose();
  linds.dispose();
  rindsB.dispose();
  return mask;
}
/** Causal(+window) mask OR'd with image×image bidirectional attention. */
export function bidirMask(L: number, windowSize: number | null, bidir: MlxArray): Mask {
  const causal = createCausalMask(L, 0, windowSize);
  const col = ops.reshape(bidir, [L, 1]);
  const row = ops.reshape(bidir, [1, L]);
  const outer = ops.logicalAnd(col, row);
  col.dispose();
  row.dispose();
  const allow = ops.logicalOr(causal, outer);
  causal.dispose();
  outer.dispose();
  return { mode: "array", arr: allow };
}
