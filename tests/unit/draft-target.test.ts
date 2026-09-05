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
    forward(_embedding, _hidden, _donors, position) {
      positions.push(position);
      return { token: 4 + step, nextHidden: tensor(20 + step++) };
    },
  }, {
    identity: {},
    assistant: {
      position: () => 9,
      embedScaled: (token) => tensor(token),
      readDonors: () => ({ sliding: [tensor(10), tensor(11)], full: [tensor(12), tensor(13)] }),
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
  const source = new AssistantSource({ forward() { throw new Error("draft failed"); } }, {
    identity: {}, assistant: {
      position: () => 0, embedScaled: () => tensor(1),
      readDonors: () => ({ sliding: [tensor(2), tensor(3)], full: [tensor(4), tensor(5)] }),
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
