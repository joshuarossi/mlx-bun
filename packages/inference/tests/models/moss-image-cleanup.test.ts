import { expect, spyOn, test } from "bun:test";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MossRefinerFeedForward } from "../../src/models/moss-image/blocks";
import { MossSitu, type MossLinear } from "../../src/models/moss-image/layers";

// No native arrays or GPU work: the failure occurs before numerical dispatch.
const tracked = () => {
  let disposals = 0;
  const array = { dispose() { disposals++; }, [Symbol.dispose]() { this.dispose(); } } as MlxArray;
  return { array, count: () => disposals };
};
const projection = (forward: MossLinear["forward"]): MossLinear => ({ forward, dispose() {} });

test("the refiner releases its up projection when the gate projection throws", () => {
  const input = tracked(), hidden = tracked(), failure = new Error("gate failed");
  let activated = false, down = false;
  const layer = new MossRefinerFeedForward(projection(() => hidden.array), projection(() => { throw failure; }),
    projection(() => { down = true; return input.array; }), { forward() { activated = true; return input.array; } });
  expect(() => layer.forward(input.array)).toThrow(failure);
  expect(hidden.count()).toBe(1);
  expect(input.count()).toBe(0);
  expect(activated).toBe(false);
  expect(down).toBe(false);
});

test("SITU consumes both inputs if its bound compiled operation throws", () => {
  const hidden = tracked(), gate = tracked(), failure = new Error("SITU dispatch failed");
  const layer = new MossSitu(Dtype.bfloat16);
  const apply = spyOn(CompiledFunction.prototype, "apply").mockImplementation(() => { throw failure; });
  try {
    expect(() => layer.forward(hidden.array, gate.array)).toThrow(failure);
    expect(hidden.count()).toBe(1);
    expect(gate.count()).toBe(1);
  } finally { apply.mockRestore(); }
});

test("the refiner releases its activation if the down projection throws", () => {
  const input = tracked(), hidden = tracked(), gate = tracked(), activated = tracked(), failure = new Error("down failed");
  const layer = new MossRefinerFeedForward(projection(() => hidden.array), projection(() => gate.array),
    projection(() => { throw failure; }), { forward(h, g) { h.dispose(); g.dispose(); return activated.array; } });
  expect(() => layer.forward(input.array)).toThrow(failure);
  expect(hidden.count()).toBe(1);
  expect(gate.count()).toBe(1);
  expect(activated.count()).toBe(1);
  expect(input.count()).toBe(0);
});
