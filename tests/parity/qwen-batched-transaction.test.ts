import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("Batched target transaction", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { BatchedQuantizedKVCache } = await import("../../src/model/batched-quantized-kv");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const { bindRowCacheRollback } = await import("../../src/backends/mlx/rollback");
  const ops = await import("../../src/mlx/ops");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  type State = ReturnType<typeof targetCacheLayout>;
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
    const weights = await Weights.open(path), model = createModel(weights, await loadModelConfig(path));
    let base: State[] = [];
    try {
      const windowSize = Number(Bun.env.MLX_BUN_TEST_TRANSACTION_WINDOW ?? 0);
      const prompts = windowSize ? [windowSize - 2, windowSize + 3].map((length, row) =>
        Array.from({ length }, (_, i) => 1 + (i + row * 11) % 97)) : [[1, 2, 3], [11, 12, 13, 14, 15, 16, 17]];
      for (const tokens of prompts) {
        const solo = model.makeCache();
        try {
          using ids = ops.fromInt32(tokens, [1, tokens.length]);
          using hidden = model.forwardHidden(ids, solo);
          digest(hidden);
          const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
          const turboQuant = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
          if (turboQuant || bits) createKvMaintenance({ ...(turboQuant ? { turboQuant } : { kvBits: bits, kvGroupSize: 64 }), quantizedKvStart: 0 })(solo);
          base = solo.map((cache, layer) => {
            const previous = base[layer];
            const merged = targetCacheLayout(cache);
            merged.mergeRows(previous ? [previous, cache] : [cache]);
            previous?.dispose();
            return merged;
          });
        } finally { for (const cache of solo) cache.dispose(); }
      }
      const clone = () => base.map(cache => { const copy = cache.makeEmptyBatch(); copy.mergeRows([cache]); return copy; });
      const compareRow = (actual: State[], reference: State[], row: number) => {
        for (let layer = 0; layer < actual.length; layer++) {
          const a = actual[layer]!, b = reference[layer]!;
          const x = a.extractRow(row), y = b.extractRow(row);
          try {
            expect(x.offset).toBe(y.offset);
            const xs = x.state(), ys = y.state();
            expect(xs.length).toBe(ys.length);
            for (let i = 0; i < xs.length; i++) expect(digest(xs[i]!), `row=${row} layer=${layer} plane=${i}`).toBe(digest(ys[i]!));
          } finally { x.dispose(); y.dispose(); }
        }
      };
      using window = ops.fromInt32([31, 32, 33, 34, 41, 42, 43, 44], [2, 4]);
      using tail = ops.fromInt32([51, 61], [2, 1]);
      // Zero candidates cannot require rollback. Compare the optimized row
      // binding with the previous explicit snapshot/commit at identical B/S,
      // then advance both again to catch retained-state differences.
      {
        const actual = clone(), reference = clone();
        try {
          const tx = bindRowCacheRollback(actual, 2); tx.begin(0);
          for (const cache of reference) cache.specRoundBegin();
          using output = model.forwardHidden(tail, actual);
          using expected = model.forwardHidden(tail, reference);
          expect(digest(output)).toBe(digest(expected));
          tx.resolve([0, 0]);
          for (const cache of reference) cache.specRoundCommit();
          for (let row = 0; row < 2; row++) compareRow(actual, reference, row);
          using continued = model.forwardHidden(tail, actual);
          using continuedReference = model.forwardHidden(tail, reference);
          expect(digest(continued)).toBe(digest(continuedReference));
          for (let row = 0; row < 2; row++) compareRow(actual, reference, row);
        } finally { dispose(actual); dispose(reference); }
      }
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
          // Affine matmul reductions depend on the fetched width, even when
          // extra columns are masked. Compare the same physical rectangle:
          // Python reproduces the different-width bf16 rounding exactly.
          // This changes only retained reference views, never logical state.
          if (Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0)) {
            for (const reference of references) for (let layer = 0; layer < reference.length; layer++) {
              const cache = reference[layer]!;
              if (!(cache instanceof BatchedQuantizedKVCache)) continue;
              const width = actual[layer]!.offset + 1;
              const makeMask = cache.makeMask.bind(cache);
              cache.makeMask = (tokens, window) => {
                const mask = makeMask(tokens, window);
                if (!mask.arr || mask.arr.shape.at(-1)! >= width) return mask;
                const shape = [...mask.arr.shape]; shape[shape.length - 1] = width - shape.at(-1)!;
                using padding = ops.zeros(shape, Dtype.bool);
                try { return { mode: "array", arr: ops.concatAxis([mask.arr, padding], shape.length - 1) }; }
                finally { mask.arr.dispose(); }
              };
              const update = cache.updateAndFetchQuantized.bind(cache);
              cache.updateAndFetchQuantized = (k, v) => update(k,v).map(triple => {
                for (const field of ["packed", "scales", "biases"] as const) {
                  const array = triple[field], shape = [...array.shape];
                  if (shape[2]! >= width) continue;
                  shape[2] = width - shape[2]!;
                  using padding = ops.zeros(shape, array.dtype);
                  triple[field] = ops.concatAxis([array, padding], 2); array.dispose();
                }
                return triple;
              }) as [import("../../src/mlx/ops").QuantizedTensor, import("../../src/mlx/ops").QuantizedTensor];
            }
          }
          using output = model.forwardHidden(tail, actual);
          for (let row = 0; row < 2; row++) {
            using expected = model.forwardHidden(tail, references[row]!);
            compareRow(actual, references[row]!, row);
            expect(rowDigest(output, row), `accepted=${accepted} row=${row}`).toBe(rowDigest(expected, row));
          }
        } finally { dispose(actual); for (const reference of references) dispose(reference); }
      }
    } finally { dispose(base); weights.dispose(); clearCache(); }
  }, 180000);
});
