import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("Qwen TurboQuant target row transaction", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { BatchedTurboQuantKVCache } = await import("../../src/model/batched-turboquant-kv");
  const { MlxArray } = await import("../../src/mlx/array");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const maintain = createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 });
  const { clearCache } = await import("../../src/mlx/ffi");
  const { bindRowCacheRollback } = await import("../../src/backends/mlx/rollback");
  const ops = await import("../../src/mlx/ops");
  type State = InstanceType<typeof SSMCache> | InstanceType<typeof BatchedTurboQuantKVCache>;
  const digest = (array: InstanceType<typeof MlxArray>) => {
    using data = ops.contiguous(array);
    return createHash("sha256").update(data.rawBytesView()).digest("hex");
  };
  const rowDigest = (array: InstanceType<typeof MlxArray>, row: number) => {
    const start = array.shape.map(() => 0), end = [...array.shape];
    start[0] = row; end[0] = row + 1;
    using view = array.slice(start, end);
    return digest(view);
  };
  const dispose = (state: readonly State[]) => { for (const cache of state) cache.dispose(); };

  test("all target layers retain unequal prefixes and continue from the same per-row state", async () => {
    const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
    const weights = await Weights.open(path), model = new Qwen35Model(weights, await loadModelConfig(path));
    let base: State[] = [];
    try {
      for (const tokens of [[1, 2, 3], [11, 12, 13, 14, 15, 16, 17]]) {
        const solo = model.makeCache();
        try {
          using ids = ops.fromInt32(tokens, [1, tokens.length]);
          using hidden = model.forwardHidden(ids, solo);
          digest(hidden);
          maintain(solo);
          base = solo.map((cache, layer) => {
            const previous = base[layer];
            let merged: State;
            if (cache instanceof SSMCache) merged = SSMCache.mergeRows(previous as InstanceType<typeof SSMCache> ?? null, cache);
            else { merged = new BatchedTurboQuantKVCache(8, 3); merged.mergeRows(previous ? [previous, cache] : [cache]); }
            previous?.dispose();
            return merged;
          });
        } finally { for (const cache of solo) cache.dispose(); }
      }
      const clone = () => base.map(cache => {
        if (cache instanceof BatchedTurboQuantKVCache) {
          const copy = new BatchedTurboQuantKVCache(8, 3); copy.mergeRows([cache]); return copy;
        }
        const copy = new SSMCache();
        copy.conv = ops.copyOf(cache.conv!); copy.recurrent = ops.copyOf(cache.recurrent!);
        copy.offset = cache.offset; copy.offsets = [...cache.offsets!]; return copy;
      });
      const compareRow = (actual: State[], reference: State[], row: number) => {
        for (let layer = 0; layer < actual.length; layer++) {
          const a = actual[layer]!, b = reference[layer]!;
          if (a instanceof SSMCache && b instanceof SSMCache) {
            expect(a.offsets![row]).toBe(b.offsets![row]);
            expect(rowDigest(a.conv!, row)).toBe(rowDigest(b.conv!, row));
            expect(rowDigest(a.recurrent!, row)).toBe(rowDigest(b.recurrent!, row));
          } else if (a instanceof BatchedTurboQuantKVCache && b instanceof BatchedTurboQuantKVCache) {
            const x = a.extractRow(row), y = b.extractRow(row);
            try {
              expect(x.offset).toBe(y.offset);
              const xx = x.state(), yy = y.state();
              try { expect(xx.map(digest)).toEqual(yy.map(digest)); }
              finally { for (const field of [...xx, ...yy]) field.dispose(); }
            } finally { x.dispose(); y.dispose(); }
          } else throw new Error("state layer family changed");
        }
      };
      using window = ops.fromInt32([31, 32, 33, 34, 41, 42, 43, 44], [2, 4]);
      using tail = ops.fromInt32([51, 61], [2, 1]);
      for (const accepted of [[0, 3], [3, 0], [1, 2], [3, 3]]) {
        const actual = clone(), references: State[][] = [];
        try {
          const tx = bindRowCacheRollback(actual, 2); tx.begin(3);
          model.forwardHidden(window, actual).dispose(); tx.resolve(accepted);
          for (let row = 0; row < 2; row++) {
            const reference = clone(); references.push(reference);
            const rt = bindRowCacheRollback(reference, 2); rt.begin(3);
            model.forwardHidden(window, reference).dispose();
            rt.resolve([accepted[row]!, accepted[row]!]);
            compareRow(actual, reference, row);
          }
          using output = model.forwardHidden(tail, actual);
          for (let row = 0; row < 2; row++) {
            using expected = model.forwardHidden(tail, references[row]!);
            expect(rowDigest(output, row)).toBe(rowDigest(expected, row));
            compareRow(actual, references[row]!, row);
          }
        } finally { dispose(actual); for (const reference of references) dispose(reference); }
      }
    } finally { dispose(base); weights.dispose(); clearCache(); }
  }, 180000);
});
