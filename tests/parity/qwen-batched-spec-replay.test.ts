import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
describe.skipIf(!enabled)("Qwen batched recurrent verify replay", async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype, clearCache } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { bindRowCacheRollback } = await import("../../src/backends/mlx/rollback");

  test("unequal accepted prefixes preserve each row's state, position and subsequent output", async () => {
    const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!;
    const config = await loadModelConfig(path), weights = await Weights.open(path);
    const model = new Qwen35Model(weights, config);
    const layer = model.layers.find(layer => layer.linearAttn)?.linearAttn!;
    expect(layer).toBeDefined();
    const H = config.text.hiddenSize;
    const input = (rows: number, length: number, phase: number) => {
      using data = MlxArray.fromFloat32(Float32Array.from({ length: rows * length * H },
        (_, index) => Math.sin(index * 0.017 + phase) * 0.2), [rows, length, H]);
      return data.astype(Dtype.bfloat16);
    };
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
    let base: InstanceType<typeof SSMCache> | null = null;
    try {
      for (const [row, length] of [3, 7].entries()) {
        const solo = new SSMCache();
        try {
          using hidden = input(1, length, row * 0.4);
          using output = layer.forward(hidden, solo);
          digest(solo.recurrent!);
          const previous = base;
          base = SSMCache.mergeRows(previous, solo);
          previous?.dispose();
        } finally { solo.dispose(); }
      }
      const clone = () => {
        const state = new SSMCache();
        state.conv = base!.conv!.slice([0, 0, 0], [...base!.conv!.shape]);
        state.recurrent = base!.recurrent!.slice([0, 0, 0, 0], [...base!.recurrent!.shape]);
        state.offset = base!.offset; state.offsets = [...base!.offsets!];
        return state;
      };
      using window = input(2, 4, 1.1);
      using continuation = input(2, 1, 1.7);
      for (const kept of [[0, 4], [1, 3], [3, 1], [4, 4]]) {
        const actual = clone();
        const references: InstanceType<typeof SSMCache>[] = [];
        try {
          const transaction = kept.every(count => count > 0) ? bindRowCacheRollback([actual], 2) : null;
          if (transaction) transaction.begin(3);
          else actual.specRoundBegin();
          layer.forward(window, actual).dispose();
          if (transaction) transaction.resolve(kept.map(count => count - 1));
          else actual.specRoundRollback(kept);
          expect(actual.offsets).toEqual([3 + kept[0]!, 7 + kept[1]!]);
          for (let row = 0; row < 2; row++) {
            const reference = clone(); references.push(reference);
            reference.specRoundBegin();
            layer.forward(window, reference).dispose();
            reference.specRoundRollback(kept[row]!);
            expect(rowDigest(actual.conv!, row)).toBe(rowDigest(reference.conv!, row));
            expect(rowDigest(actual.recurrent!, row)).toBe(rowDigest(reference.recurrent!, row));
          }
          using result = layer.forward(continuation, actual, true);
          for (let row = 0; row < 2; row++) {
            const reference = references[row]!;
            using expected = layer.forward(continuation, reference, true);
            expect(rowDigest(result, row)).toBe(rowDigest(expected, row));
            expect(rowDigest(actual.conv!, row)).toBe(rowDigest(reference.conv!, row));
            expect(rowDigest(actual.recurrent!, row)).toBe(rowDigest(reference.recurrent!, row));
          }
        } finally { actual.dispose(); for (const reference of references) reference.dispose(); }
      }
    } finally { base?.dispose(); weights.dispose(); clearCache(); }
  }, 120000);
});
