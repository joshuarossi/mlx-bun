import * as ops from "../../src/mlx/ops";
import { expect, test } from "bun:test";
import { AssistantSource } from "../../src/spec/assistant-source";
import { DflashSource } from "../../src/spec/dflash-source";
import { DeepspecSource } from "../../src/spec/deepspec-source";
import type { TargetView } from "../../src/spec/source";
import type { MlxArray } from "../../src/mlx/array";

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
