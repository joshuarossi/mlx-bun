// Valid per-row K/V of sliding-window (rotating) and full layers, read through
// public state only and hashed, for the real-weight consumers that compare
// rotating rows (rotating-join, sliding-grammar-fill). A rotating row is its
// newest min(offset, window) positions in chronological order, selected through
// the source position independently of temporalView; a full row is its valid,
// right-aligned span. Native modules load on first use.
import { strict as assert } from "node:assert";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../src/contracts/mlx/cache";
import { releaseAll, sha256 } from "./real-weight-inputs";

export interface Tensor { shape: number[]; dtype: string; sha: string }
export interface Layer { kind: "rotating" | "full"; offset: number; keys: Tensor; values: Tensor }
export interface RowState { offset: number; layers: Layer[] }

export async function rotatingRowReader() {
  const ops = await import("@mlx-bun/mlx/ops");
  const { RotatingKVCache } = await import("../../src/state/rotating-kv");
  const { KVCache } = await import("../../src/state/kv");
  const { BatchedRotatingCache } = await import("../../src/state/batched-rotating");
  const { BatchedDecodeMaskCache, PaddedKVRows } = await import("../../src/state/batched-mask");
  const { rotatingSourcePosition } = await import("../../src/state/rotating-kv-layout");
  const { plainRowStorage, temporalStorageView } = await import("../../src/state/batched-row-storage");
  const hash = (a: MlxArray) => { const c = ops.contiguous(a); try { return sha256(new Uint8Array(c.rawBytes())); } finally { c.dispose(); } };
  const tensor = (a: MlxArray): Tensor => ({ shape: [...a.shape], dtype: a.dtypeName, sha: hash(a) });
  /** A solo rotating cache's newest min(offset, window) rows, through the source
   * position; each view is handed to `own` as soon as it exists. */
  const newest = (c: InstanceType<typeof RotatingKVCache>, own: (a: MlxArray) => MlxArray): [MlxArray, MlxArray] => {
    const state = rotatingSourcePosition(c), valid = Math.min(c.offset, c.maxSize);
    const range = { from: Math.max(0, state.activeLength - valid), to: state.activeLength };
    const keys = own(temporalStorageView(plainRowStorage, c.keys!, state, range));
    return [keys, own(temporalStorageView(plainRowStorage, c.values!, state, range))];
  };
  /** Every row's valid state, read through public state only. Views made for a
   * layer are released before the next layer, even when a read throws. */
  const rowStates = (caches: Cache[], B: number): RowState[] => {
    const rows = Array.from({ length: B }, () => ({ offset: -1, layers: [] as Layer[] }));
    const batched = caches.find(c => c instanceof BatchedRotatingCache) as InstanceType<typeof BatchedRotatingCache> | undefined;
    for (const c of caches) {
      const owned: (() => void)[] = [];
      const own = <T extends { dispose(): void }>(a: T): T => { owned.push(() => a.dispose()); return a; };
      try {
        if (c instanceof RotatingKVCache) {
          assert.equal(B, 1, "solo rotating cache in a multi-row forward");
          const [k, v] = newest(c, own);
          rows[0]!.layers.push({ kind: "rotating", offset: c.offset, keys: tensor(k), values: tensor(v) });
        } else if (c instanceof BatchedRotatingCache) {
          for (let r = 0; r < B; r++) {
            const [k, v] = newest(own(c.extractRow(r)!), own);
            rows[r]!.layers.push({ kind: "rotating", offset: c.offsetArr[r]!, keys: tensor(k), values: tensor(v) });
          }
        } else {
          // Full layers: rows are right-aligned in the batched buffer; each holds its own offset.
          assert(c instanceof KVCache || c instanceof BatchedDecodeMaskCache || c instanceof PaddedKVRows, `unsupported cache ${c.signature()}`);
          const [keys, values] = c.state(), width = c.offset;
          for (let r = 0; r < B; r++) {
            const valid = B === 1 ? width : batched!.offsetArr[r]!;
            const cut = (a: MlxArray) => own(a.slice([r, 0, width - valid, 0], [r + 1, a.shape[1]!, width, a.shape[3]!]));
            const k = cut(keys!), v = cut(values!);
            rows[r]!.layers.push({ kind: "full", offset: valid, keys: tensor(k), values: tensor(v) });
          }
        }
      } finally { releaseAll(owned.reverse()); }
    }
    for (const row of rows) row.offset = row.layers[0]!.offset;
    return rows;
  };
  return { hash, tensor, newest, rowStates };
}
