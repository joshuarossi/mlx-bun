import { expect, test } from "bun:test";
import { bindMlxGraph } from "../../src/backends/mlx/graph";
import { MlxArray } from "../../src/mlx/array";

test("MLX binding selects hidden positions before projecting the vocabulary", () => {
  const seen: number[][] = [];
  const graph = bindMlxGraph({
    forwardHidden(ids: MlxArray, _state: null) { return ids; },
    logitsFromHidden(hidden: MlxArray) {
      seen.push(hidden.shape);
      return hidden.slice([0, 0, 0], hidden.shape);
    },
  }, { id: "test", artifact: "fixture", stateAbi: "test-v1" });
  const hidden = MlxArray.fromFloat32(Float32Array.from([1, 2, 3, 4, 5, 6]), [1, 3, 2]);
  try {
    const last = graph.projectLogits(hidden, { type: "last" });
    const range = graph.projectLogits(hidden, { type: "range", start: 0, end: 2 });
    const all = graph.projectLogits(hidden, { type: "all" });
    try {
      expect(seen).toEqual([[1, 1, 2], [1, 2, 2], [1, 3, 2]]);
      expect([...last.toFloat32Host()]).toEqual([5, 6]);
      expect([...range.toFloat32Host()]).toEqual([1, 2, 3, 4]);
      expect([...all.toFloat32Host()]).toEqual([1, 2, 3, 4, 5, 6]);
      expect(() => graph.projectLogits(hidden, { type: "range", start: -1, end: 1 })).toThrow("selection");
      expect(hidden.shape).toEqual([1, 3, 2]);
    } finally { last.dispose(); range.dispose(); all.dispose(); }
  } finally { hidden.dispose(); }
});

test("binding preserves sync dispatch and binds the streamed async implementation once", async () => {
  const ids = MlxArray.fromInt32(Int32Array.from([1]), [1, 1]);
  const state = { calls: 0 };
  const operations = {
    forwardHidden(value: MlxArray, current: typeof state) { current.calls++; return value; },
    logitsFromHidden(value: MlxArray) { return value; },
  };
  try {
    const sync = bindMlxGraph(operations, { id: "sync", artifact: "fixture", stateAbi: "test-v1" });
    expect(sync.forwardHidden(ids, state)).toBe(ids);
    const streamed = { ...operations, multiplier: 10,
      async forwardHiddenAsync(value: MlxArray, current: typeof state) { current.calls += this.multiplier; return value; } };
    const asyncGraph = bindMlxGraph(streamed, { id: "async", artifact: "fixture", stateAbi: "test-v1" });
    expect(await asyncGraph.forwardHidden(ids, state)).toBe(ids);
    expect(state.calls).toBe(11);
  } finally { ids.dispose(); }
});
