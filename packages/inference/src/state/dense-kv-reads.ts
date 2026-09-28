import type { Cache, DenseKvReads } from "../contracts/mlx/cache";

/** Plain storage: every append is read plain. */
export const plainKvStorage: DenseKvReads = Object.freeze({ appendable: () => true });

/** Encoded storage that decodes on read: `updateAndFetch` returns the
 * dequantized window, so every append is read dense. */
export const decodedKvStorage: DenseKvReads = Object.freeze({ appendable: () => true });

/** Rows (of `rows`) whose next append is not certified plain-readable in
 * every listed layer. An absent capability is not a certification. */
export function unreadableRows(caches: readonly Cache[], layers: readonly number[], rows: number): number[] {
  const unreadable: number[] = [];
  for (let row = 0; row < rows; row++)
    if (layers.some(layer => !caches[layer]?.denseKvReads?.appendable(row))) unreadable.push(row);
  return unreadable;
}

/** A row whose KV can no longer be read plain by a graph that reads plain keys
 * and values: its precision transition is not attended by that graph. Only
 * that row is rejected. */
export class DenseKvReadError extends Error {
  constructor() {
    super("this model's attention reads plain KV, and the request's KV reached a precision transition it cannot read");
    this.name = "DenseKvReadError";
  }
}
