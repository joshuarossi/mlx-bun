import { MlxArray } from "@mlx-bun/mlx/array";

/** Dispose `old` and return `next` — for h = disposing(h, op(h)) chains. */
export function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
