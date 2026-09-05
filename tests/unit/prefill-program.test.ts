import { expect, test } from "bun:test";
import { nextPrefillStep, type PrefillPosition, type PrefillStep } from "../../src/inference/prefill";

function steps(input: PrefillPosition): PrefillStep[] {
  const result: PrefillStep[] = [];
  let position = input.position;
  while (position < input.length) {
    const step = nextPrefillStep({ ...input, position });
    result.push(step);
    position = step.end;
  }
  return result;
}

test("cold and warm prefill preserve the oracle's separate last-token forward", () => {
  for (const position of [0, 3, 7, 8]) {
    const program = steps({ length: 9, position, chunkSize: 3, tailSplit: true });
    expect(program.at(-1)).toEqual({ start: 8, end: 9, kind: "final", snapshot: false, batchYield: false });
    expect(program.flatMap((step) => Array.from({ length: step.end - step.start }, (_, i) => step.start + i)))
      .toEqual(Array.from({ length: 9 - position }, (_, i) => position + i));
    expect(program.filter((step) => step.kind === "drain").every((step) => step.end - step.start <= 3)).toBe(true);
  }
});

test("snapshot boundaries split chunks exactly once before ordinary draining", () => {
  const program = steps({ length: 12, position: 2, chunkSize: 4, tailSplit: true, snapshotAt: 7 });
  expect(program.map(({ start, end, kind, snapshot }) => [start, end, kind, snapshot])).toEqual([
    [2, 6, "drain", false], [6, 7, "drain", true], [7, 11, "drain", false], [11, 12, "final", false],
  ]);
  expect(program.map((step) => step.batchYield)).toEqual([true, true, false, false]);
});

test("the compatibility convention keeps the final multi-token chunk", () => {
  expect(steps({ length: 10, position: 0, chunkSize: 4, tailSplit: false })
    .map(({ start, end, kind }) => [start, end, kind])).toEqual([
    [0, 4, "drain"], [4, 8, "drain"], [8, 10, "final"],
  ]);
  expect(steps({ length: 4, position: 0, chunkSize: 4, tailSplit: false })).toHaveLength(1);
});

test("boundaries already covered or at the full prompt introduce no extra split", () => {
  const input = { length: 9, position: 3, chunkSize: 4, tailSplit: true };
  for (const snapshotAt of [0, 3, 9, null]) expect(steps({ ...input, snapshotAt })).toEqual(steps(input));
});

test("invalid positions fail rather than creating an empty or non-advancing step", () => {
  const input = { length: 9, position: 0, chunkSize: 4, tailSplit: true };
  for (const invalid of [{ position: 9 }, { position: -1 }, { chunkSize: 0 }, { chunkSize: NaN },
    { length: 0 }, { snapshotAt: 10 }, { snapshotAt: 0.5 }])
    expect(() => nextPrefillStep({ ...input, ...invalid })).toThrow(/invalid prefill/);
});
