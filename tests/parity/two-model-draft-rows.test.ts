import { expect, test } from "bun:test";

const path = Bun.env.MLX_BUN_TEST_TWO_MODEL_DRAFT;
test.skipIf(!path)("standalone draft B1 retains exact native recurrent and attention state", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { bindLegacyAutoregressiveModel } = await import("../../src/backends/mlx/autoregressive");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { MlxStateRows } = await import("../../src/backends/mlx/state-rows");
  const { MlxAutoregressiveDraftRows } = await import("../../src/backends/mlx/autoregressive-draft-rows");
  const { leaseCacheState } = await import("../../src/backends/mlx/state-views");
  const { withResource, disposeResources } = await import("../../src/engine/resources");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const ops = await import("../../src/mlx/ops");
  const weights = await Weights.open(path!);
  try {
    const model = createModel(weights, await loadModelConfig(path!));
    const binding = bindLegacyAutoregressiveModel(model);
    for (const [depth, accepted] of [[0, 0], [1, 0], [1, 1], [3, 0], [3, 1], [3, 3], [4, 2]]) {
      const baseline = binding.makeCache(), initial = binding.makeCache();
      const states = new MlxStateRows(initial.map(targetCacheLayout));
      const draft = new MlxAutoregressiveDraftRows(binding.graph, states,
        { sample: logprobs => ops.argmaxAxis(logprobs, -1) });
      try {
        using prefix = ops.fromInt32([1, 2, 3], [1, 3]);
        (await binding.graph.forwardHidden(prefix, baseline)).dispose();
        (await binding.graph.forwardHidden(prefix, initial)).dispose();
        states.mergeRows([initial]);
        const proposals = await draft.draft([4], depth!, [0]);
        await draft.commit([accepted!]);
        for (const token of [4, ...proposals[0]!.slice(0, Math.min(accepted!, Math.max(0, depth! - 1)))]) {
          using ids = ops.fromInt32([token], [1, 1]);
          (await binding.graph.forwardHidden(ids, baseline)).dispose();
        }
        const actual = states.extractRow(0), expectedState = cloneKvCaches(baseline);
        try {
          expect(actual.map(cache => cache.offset)).toEqual(baseline.map(cache => cache.offset));
          for (let layer = 0; layer < actual.length; layer++) {
            withResource(leaseCacheState(actual[layer]!), arrays => withResource(leaseCacheState(expectedState[layer]!), expected => {
              expect(arrays.length).toBe(expected.length);
              for (let i = 0; i < arrays.length; i++) {
                expect(arrays[i]!.shape).toEqual(expected[i]!.shape);
                using a = ops.contiguous(arrays[i]!), b = ops.contiguous(expected[i]!);
                expect(a.rawBytesView(), `depth=${depth},accepted=${accepted},layer=${layer},tensor=${i}`).toEqual(b.rawBytesView());
              }
            }));
          }
          const feed = draft.pendingLast[0] == null ? [7] : [draft.pendingLast[0]!, 7];
          using next = ops.fromInt32(feed, [1, feed.length]);
          using expectedHidden = await binding.graph.forwardHidden(next, baseline);
          using expectedLogits = binding.graph.projectLogits(expectedHidden, { type: "last" });
          using expectedFlat = ops.reshape(expectedLogits, [1, expectedLogits.shape.at(-1)!]);
          using expectedToken = ops.argmaxAxis(expectedFlat, -1);
          expect((await draft.draft([7], 1, [accepted! + 1]))[0]).toEqual(expectedToken.toIntTokens());
          await draft.commit([0]);
        } finally { disposeResources([...actual, ...expectedState]); }
      } finally { draft.dispose(); disposeResources([...baseline, ...initial]); }
    }
  } finally { weights.dispose(); }
}, 120_000);
