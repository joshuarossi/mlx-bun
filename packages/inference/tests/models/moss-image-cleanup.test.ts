import { expect, spyOn, test } from "bun:test";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { MossRefinerFeedForward, MossTimestepEmbedder } from "../../src/models/moss-image/blocks";
import { MossSilu, MossSitu, type MossLinear } from "../../src/models/moss-image/layers";

// No native arrays or GPU work: the failure occurs before numerical dispatch.
const tracked = (dtype = Dtype.bfloat16) => {
  let disposals = 0;
  const array = { dtype, dispose() { disposals++; }, [Symbol.dispose]() { this.dispose(); } } as MlxArray;
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

test("SITU consumes both inputs if an eager operation throws", () => {
  const hidden = tracked(), gate = tracked(), four = tracked(), failure = new Error("SITU dispatch failed");
  const layer = new MossSitu(Dtype.bfloat16);
  const scalar = spyOn(ops, "scalarLike").mockReturnValueOnce(four.array).mockImplementation(() => { throw failure; });
  try {
    expect(() => layer.forward(hidden.array, gate.array)).toThrow(failure);
    expect(hidden.count()).toBe(1);
    expect(gate.count()).toBe(1);
    expect(four.count()).toBe(1);
  } finally { scalar.mockRestore(); }
});

test("SITU consumes both inputs when their dtype differs from its binding", () => {
  const hidden = tracked(Dtype.float32), gate = tracked();
  const layer = new MossSitu(Dtype.bfloat16);
  expect(() => layer.forward(hidden.array, gate.array)).toThrow("bound dtype");
  expect(hidden.count()).toBe(1);
  expect(gate.count()).toBe(1);
});

test("SiLU borrows its input, returns its result and disposes its compiled operation", () => {
  const input = tracked(), output = tracked(), failure = new Error("SiLU dispatch failed");
  const layer = new MossSilu();
  const apply = spyOn(CompiledFunction.prototype, "apply").mockReturnValue([output.array]);
  const dispose = spyOn(CompiledFunction.prototype, "dispose");
  try {
    expect(layer.forward(input.array)).toBe(output.array);
    expect(apply).toHaveBeenCalledWith([input.array]);
    apply.mockImplementation(() => { throw failure; });
    expect(() => layer.forward(input.array)).toThrow(failure);
    layer.dispose();
    expect(dispose).toHaveBeenCalledTimes(1);
    expect(input.count()).toBe(0);
    expect(output.count()).toBe(0);
  } finally { apply.mockRestore(); dispose.mockRestore(); layer.dispose(); }
});

test("the timestep embedder disposes its projections and graph-supplied activation", () => {
  const disposed = [0, 0, 0];
  const owned = (i: number) => ({ forward: (x: MlxArray) => x, dispose() { disposed[i]!++; } });
  const layer = new MossTimestepEmbedder(owned(0), owned(1), 256, owned(2));
  layer.dispose();
  expect(disposed).toEqual([1, 1, 1]);
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
