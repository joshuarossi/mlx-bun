import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";


/** tanh(x / cap) * cap with weak-scalar semantics. */
export function logitSoftcap(logits: MlxArray, cap: number): MlxArray {
  const capArr = ops.scalarLike(cap, logits);
  const scaled = ops.div(logits, capArr);
  const t = ops.tanh(scaled);
  scaled.dispose();
  const out = ops.mul(t, capArr);
  t.dispose();
  capArr.dispose();
  return out;
}

/** argmax over vocab at the last sequence position of [1, L, V]. */
export function argmaxLastPosition(logits: MlxArray): number {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const am = ops.argmaxAxis(last, -1);
  const id = ops.itemUint32(am);
  last.dispose();
  am.dispose();
  return id;
}

/** Last-position logits as f32 (for the parity harness). */
export function lastPositionLogits(logits: MlxArray): Float32Array {
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]);
  const f32 = last.toFloat32();
  last.dispose();
  return f32;
}
