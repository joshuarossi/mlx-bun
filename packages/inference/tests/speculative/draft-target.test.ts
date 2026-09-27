import * as ops from "@mlx-bun/mlx/ops";
import { expect, test } from "bun:test";
import { AssistantSource } from "../../src/generation/speculative/sources/assistant-source";
import { DflashSource } from "../../src/generation/speculative/sources/dflash-source";
import { DeepspecSource } from "../../src/generation/speculative/sources/deepspec-source";
import type { TargetView } from "../../src/generation/speculative/source";
import { projectedDraftGroups } from "../../src/generation/speculative/bindings/projected-draft-rows";
import { deepspecGroups } from "../../src/generation/speculative/bindings/deepspec-rows";
import { MlxArray } from "@mlx-bun/mlx/array";
import { bindSpeculativeTargetModel } from "../../src/generation/speculative/bindings/binding";

test("an assistant uses an independent target's ports and releases each borrowed view", () => {
  const released: number[] = [];
  const tensor = (id: number) => ({ dispose() { released.push(id); } }) as MlxArray;
  const positions: number[] = [];
  let step = 0;
  const source = new AssistantSource({
    forwardRows(_embedding, _hidden, _donors, position) {
      positions.push(position as number);
      const token = 4 + step;
      return { tokens: ops.fromInt32([token], [1]), nextHidden: tensor(20 + step++) };
    },
  }, {
    identity: {},
    assistantRows: {
      hiddenSize: 1, embed: (ids) => tensor(ops.itemUint32(ids)),
      readDonors: () => ({ positions: [9], sliding: {} as never, full: {} as never, dispose() { released.push(10, 11, 12, 13); } }),
    },
  });
  expect(source.draft([3], 2, 0, tensor(99))).toEqual([4, 5]);
  expect(positions).toEqual([9, 10]);
  expect(released.sort((a, b) => a - b)).toEqual([3, 4, 10, 11, 12, 13, 20, 21]);
  // The anchor is borrowed from the verifier, which owns its release.
  expect(released).not.toContain(99);
  source.dispose();
});

test("assistant draft failure releases retained donors and its current embedding", () => {
  const released: number[] = [];
  const tensor = (id: number) => ({ dispose() { released.push(id); } }) as MlxArray;
  const source = new AssistantSource({ forwardRows() { throw new Error("draft failed"); } }, {
    identity: {}, assistantRows: {
      hiddenSize: 1, embed: () => tensor(1),
      readDonors: () => ({ positions: [0], sliding: {} as never, full: {} as never, dispose() { released.push(2, 3, 4, 5); } }),
    },
  });
  expect(() => source.draft([1], 1, 0, tensor(99))).toThrow("draft failed");
  expect(released).toEqual([1, 2, 3, 4, 5]);
});

test("target extensions refuse unsupported pairings before touching the drafter", () => {
  const target: TargetView = { identity: {} };
  expect(() => new AssistantSource(undefined as never, target)).toThrow("donor views");
  expect(() => new DflashSource(undefined as never, target)).toThrow("Gemma4 target");
  expect(() => new DeepspecSource(undefined as never, target)).toThrow("Gemma4 target");
});

test("projected draft providers declare the immutable target tap list their rows consume", () => {
  const layers = [3, 8, 12];
  const grouped = projectedDraftGroups("fixture", layers, () => ({ namespace: "fixture", schema: "fixture-v1", layers: 1,
    project: () => { throw new Error("unused"); }, draft: () => [] }));
  layers.push(99); // declared at construction, not read through later
  const target = { identity: {} } as TargetView, declared = grouped.targetTapLayers!(target);
  expect(declared).toEqual([3, 8, 12]);
  expect(Object.isFrozen(declared)).toBe(true);
  for (const open of [grouped.open, grouped.openPrefill]) {
    const rows = open({ target, checkpoints: [], sampling: {} as never });
    try { expect(rows.tapLayers).toBe(declared); } finally { rows.dispose(); }
  }
  // DSpark-style context providers declare their drafter's own list.
  const deepspec = deepspecGroups({ tapLayers: [1, 4], cfg: { num_hidden_layers: 1 } } as never, "deepspec");
  expect(deepspec.targetTapLayers!(target)).toEqual([1, 4]);
});

test("the target binding taps its graph's layers and supplies an uncaptured post-norm sentinel from the forward output", async () => {
  const H = 2, L = 3, created: MlxArray[] = [];
  const filled = (value: number) => { const array = MlxArray.fromFloat32(new Float32Array(L * H).fill(value), [1, L, H]); created.push(array); return array; };
  // A graph like Qwen3.5's ordinary forward: its hidden tap covers layers 0..N-1
  // and it returns the post-final-norm output without tapping it.
  const model = { config: { modelType: "fixture", eosTokenIds: [], text: { enableMoeBlock: false, numHiddenLayers: 2 } },
    hiddenTap: null as { layers: Set<number>; captured: Map<number, MlxArray> } | null,
    makeCache: () => [], logitsFromHidden: (hidden: MlxArray) => hidden,
    forwardHidden(this: { hiddenTap: { layers: Set<number>; captured: Map<number, MlxArray> } | null }) {
      for (let layer = 0; layer < 2; layer++)
        if (this.hiddenTap?.layers.has(layer)) this.hiddenTap.captured.set(layer, ops.contiguous(filled(layer + 1)));
      return ops.contiguous(filled(9));
    } };
  const binding = bindSpeculativeTargetModel(model as never);
  expect([binding.supportsTapLayers([]), binding.supportsTapLayers([1, 2]), binding.supportsTapLayers([3]),
    binding.supportsTapLayers([-1])]).toEqual([true, true, false, false]);
  using ids = ops.fromInt32([1, 2, 3], [1, 3]);
  const { hidden, ctxML } = await binding.forward(ids, [], [1, 2]);
  try {
    expect(ctxML!.shape).toEqual([1, L, 2 * H]);
    expect([...ctxML!.toFloat32()]).toEqual(Array.from({ length: L }, () => [2, 2, 9, 9]).flat());
    expect([...hidden.toFloat32()]).toEqual(new Array(L * H).fill(9)); // the caller keeps the forward output
    expect(model.hiddenTap).toBeNull();
  } finally { hidden.dispose(); ctxML?.dispose(); for (const array of created) array.dispose(); }
  // Without a hidden-tap operation only an empty declaration is supported.
  const { hiddenTap: _absent, ...untapped } = model;
  const plain = bindSpeculativeTargetModel(untapped as never);
  expect([plain.supportsTapLayers([]), plain.supportsTapLayers([0])]).toEqual([true, false]);
});
