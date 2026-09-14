// Same-B numerical/state gate for the shared committed-append primitive.
// MLX_BUN_TEST_COMMITTED_ROWS_MODEL selects one local artifact per process.
import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import type { Cache } from "../../src/model/gemma4-base";

const path = process.env.MLX_BUN_TEST_COMMITTED_ROWS_MODEL;
describe.skipIf(!path)("committed hidden rows against one-position model forwards", async () => {
  if (!path) return;
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { createModel } = await import("../../src/model/factory");
  const { bindLegacyAutoregressiveModel } = await import("../../src/backends/mlx/autoregressive");
  const { MlxStateRows } = await import("../../src/backends/mlx/state-rows");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { appendHiddenRows } = await import("../../src/backends/mlx/fill-append");
  const { leaseCacheState, leaseCacheStates } = await import("../../src/backends/mlx/state-views");
  const { withResource } = await import("../../src/engine/resources");
  const ops = await import("../../src/mlx/ops");
  const config = await loadModelConfig(path);
  const weights = await Weights.open(path);
  const model = createModel(weights, config);
  const binding = bindLegacyAutoregressiveModel(model);
  const append = binding.createAppend?.({ hasAdapters: false, pagedKv: false });
  console.log(JSON.stringify({ kind: "committed-row-append", model: path,
    modelType: config.modelType, modelAppend: !!append, oracle: "same-model same-B one-position forwards" }));
  afterAll(() => weights.dispose());

  const hash = (array: import("../../src/mlx/array").MlxArray) => {
    using packed = ops.contiguous(array);
    return { shape: packed.shape, dtype: packed.dtype,
      sha256: createHash("sha256").update(packed.rawBytesView()).digest("hex") };
  };
  const snapshot = (rows: InstanceType<typeof MlxStateRows>) =>
    Array.from({ length: rows.rowCount }, (_, row) => {
      const caches = rows.extractRow(row);
      try {
        return caches.map(cache => withResource(leaseCacheState(cache), arrays => ({
          offset: cache.offset, signature: cache.signature(), arrays: arrays.map(array => {
            const shape = array.shape;
            const live = cache.signature() !== "ssm" && shape.length === 4 && shape[2]! > cache.offset
              ? array.slice([0, 0, 0, 0], [shape[0]!, shape[1]!, cache.offset, shape[3]!]) : null;
            try { return hash(live ?? array); } finally { live?.dispose(); }
          }),
        })));
      } finally { caches.forEach(cache => cache.dispose()); }
    });

  for (const B of [1, 2, 4]) for (const scheme of ["bf16", "kv4", "k8v3", "kv4-delayed", "k8v3-delayed"] as const) {
    test(`${scheme} B${B} append, retirement and continuation`, async () => {
      const quantizedKvStart = scheme.endsWith("delayed") ? 7 : 0;
      const maintain = createKvMaintenance(scheme.startsWith("kv4")
        ? { kvBits: 4, kvGroupSize: 64, quantizedKvStart }
        : scheme.startsWith("k8v3") ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart } : {});
      const solos: Cache[][] = [];
      let candidate: InstanceType<typeof MlxStateRows> | undefined;
      let control: InstanceType<typeof MlxStateRows> | undefined;
      try {
        for (let row = 0; row < B; row++) {
          const caches = binding.makeCache(); solos.push(caches);
          const prompt = Array.from({ length: 5 + row * 2 }, (_, index) => 30 + row + index);
          using ids = ops.fromInt32(prompt, [1, prompt.length]);
          using hidden = await binding.graph.forwardHidden(ids, caches);
          withResource(leaseCacheStates(caches), arrays => ops.evalAll([hidden, ...arrays]));
          maintain(caches);
          maintain.prepareBatch?.(caches);
        }
        candidate = new MlxStateRows(solos[0]!.map(targetCacheLayout));
        candidate.mergeRows(solos);
        control = candidate.clone();
        const tokens = Array.from({ length: B }, (_, row) => [70 + row, 80 + row, 90 + row, 100 + row]);
        using input = ops.fromInt32(tokens.flat(), [B, 4]);
        const expectedSteps: import("../../src/mlx/array").MlxArray[] = [];
        try {
          for (let column = 0; column < 4; column++) {
            using ids = input.slice([0, column], [B, column + 1]);
            const hidden = await binding.graph.forwardHidden(ids, control.caches);
            expectedSteps.push(hidden);
            withResource(leaseCacheStates(control.caches), arrays => ops.evalAll([hidden, ...arrays]));
          }
          using all = ops.concatAxis(expectedSteps, 1);
          using actual = await appendHiddenRows(append?.forwardHidden.bind(append) ?? binding.graph.forwardHidden.bind(binding.graph),
            candidate.caches, input, (state, rows) => Math.min(append?.maxChunkSize(state, rows) ?? 1,
              maintain.maxAppendTokens?.(state) ?? Infinity));
          expect(hash(actual)).toEqual(hash(all));
        } finally { expectedSteps.forEach(array => array.dispose()); }
        expect(snapshot(candidate)).toEqual(snapshot(control));
        const keep = B === 4 ? [3, 1] : B === 2 ? [1] : [0];
        candidate.filterRows(keep); control.filterRows(keep);
        using next = ops.fromInt32(keep.map(row => 110 + row), [keep.length, 1]);
        using actual = await binding.graph.forwardHidden(next, candidate.caches);
        using expected = await binding.graph.forwardHidden(next, control.caches);
        using actualLogits = binding.graph.projectLogits(actual, { type: "all" });
        using expectedLogits = binding.graph.projectLogits(expected, { type: "all" });
        expect(hash(actualLogits)).toEqual(hash(expectedLogits));
        expect(snapshot(candidate)).toEqual(snapshot(control));
        // Retirement can make a previously wider cohort eligible for the
        // specialized B1 operation; compare that transition, including padding.
        using continuation = ops.fromInt32(keep.flatMap(row => [120 + row, 130 + row]), [keep.length, 2]);
        const steps: import("../../src/mlx/array").MlxArray[] = [];
        try {
          for (let column = 0; column < 2; column++) {
            using ids = continuation.slice([0, column], [keep.length, column + 1]);
            const h = await binding.graph.forwardHidden(ids, control.caches); steps.push(h);
            withResource(leaseCacheStates(control.caches), arrays => ops.evalAll([h, ...arrays]));
          }
          using wanted = ops.concatAxis(steps, 1);
          using got = await appendHiddenRows(append?.forwardHidden.bind(append) ?? binding.graph.forwardHidden.bind(binding.graph),
            candidate.caches, continuation, (state, rows) => Math.min(append?.maxChunkSize(state, rows) ?? 1,
              maintain.maxAppendTokens?.(state) ?? Infinity));
          expect(hash(got)).toEqual(hash(wanted));
          expect(snapshot(candidate)).toEqual(snapshot(control));
        } finally { steps.forEach(h => h.dispose()); }
      } finally {
        candidate?.dispose(); control?.dispose();
        solos.flat().forEach(cache => cache.dispose());
      }
    }, 120_000);
  }
});
