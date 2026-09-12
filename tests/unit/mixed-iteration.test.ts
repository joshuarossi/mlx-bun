import { expect, test } from "bun:test";
import { runMixedTokenIteration } from "../../src/backends/mlx/mixed-iteration";
import * as ops from "../../src/mlx/ops";

test("mixed execution publishes and retires decode before preparation joins", async () => {
  using decode = ops.fromInt32([7], [1, 1]);
  using prompt = ops.fromInt32([11, 12, 13], [1, 3]);
  const order: string[] = [];
  const advanced = await runMixedTokenIteration({
    async prepare(forward) {
      using hidden = await forward(prompt, []);
      expect(hidden.toIntTokens()).toEqual([11, 12, 13]);
      order.push("join");
    },
    async decode(forward) {
      using hidden = await forward(decode, []);
      expect(hidden.toIntTokens()).toEqual([7]);
      order.push("publish", "retire");
    },
    async forward() { throw new Error("separate forward was not expected"); },
    mixed(groups) {
      expect(groups.map(group => group.ids.shape)).toEqual([[1, 1], [1, 3]]);
      order.push("mixed");
      return groups.map(group => ops.copyOf(group.ids));
    },
  });
  expect(advanced).toBe(true);
  expect(order).toEqual(["mixed", "publish", "retire", "join"]);
});

test("restored or cancelled preparation completes without waiting for a model call", async () => {
  const advanced = await runMixedTokenIteration({
    async prepare() {},
    async decode() { throw new Error("unexpected decode"); },
    async forward() { throw new Error("unexpected forward"); },
    mixed() { throw new Error("unexpected mixed forward"); },
  });
  expect(advanced).toBe(false);
});

test("a final pending decode token can retire while preparation still advances", async () => {
  using ids = ops.fromInt32([1, 2], [1, 2]);
  const events: string[] = [];
  expect(await runMixedTokenIteration({
    async prepare(forward) { using h = await forward(ids, []); events.push("prepared"); },
    async decode() { events.push("retired"); },
    async forward(input) { events.push("forward"); return ops.copyOf(input); },
    mixed() { throw new Error("unexpected mixed forward"); },
  })).toBe(true);
  expect(events).toEqual(["retired", "forward", "prepared"]);
});

test("mixed work retains per-method taps and verification policy on every forward", async () => {
  using ids = ops.fromInt32([1], [1, 1]);
  const taps = [0, 0];
  const capture = taps.map((_, row) => () => { taps[row]!++; });
  await runMixedTokenIteration({
    async prepare(forward) {
      using h = await forward(ids, [], { captureLayer: capture[1] });
      using tail = await forward(ids, [], { captureLayer: capture[1] });
    },
    async decode(forward) { using h = await forward(ids, [], { captureLayer: capture[0], preserveTokenGeometry: true }); },
    async forward(input, _cache, policy) { policy?.captureLayer?.(0, input); return ops.copyOf(input); },
    mixed(groups) {
      expect(groups[0]!.preserveTokenGeometry).toBe(true);
      expect(groups[1]!.preserveTokenGeometry).toBeUndefined();
      for (const group of groups) group.captureLayer?.(0, group.ids);
      return groups.map(group => ops.copyOf(group.ids));
    },
  });
  expect(taps).toEqual([1, 2]);
});

test.each(["prepare", "mixed", "sample"])("%s failure unwinds both work producers without a stranded promise", async phase => {
  using ids = ops.fromInt32([1], [1, 1]);
  let preparationClosed = false;
  await expect(runMixedTokenIteration({
    async prepare(forward) {
      try {
        if (phase === "prepare") throw new Error(phase);
        using h = await forward(ids, []);
      } finally { preparationClosed = true; }
    },
    async decode(forward) { using h = await forward(ids, []); throw new Error("sample"); },
    async forward(input) { return ops.copyOf(input); },
    mixed(groups) {
      if (phase === "mixed") throw new Error(phase);
      return groups.map(group => ops.copyOf(group.ids));
    },
  })).rejects.toThrow(phase);
  expect(preparationClosed).toBe(true);
});
