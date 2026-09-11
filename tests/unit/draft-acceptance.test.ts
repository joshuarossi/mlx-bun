import { expect, test } from "bun:test";
import { DraftAcceptance } from "../../src/inference/draft-acceptance";

const run = (drafts: number[], target: number[], remaining = 20, grammarAt = -1) => {
  const state = new DraftAcceptance(drafts, remaining, [0]);
  while (!state.done) {
    const position = state.position;
    state.accept(target[position]!, position === grammarAt);
  }
  return state;
};

test("acceptance stops at the first mismatch and retains the correction", () => {
  const result = run([10, 11, 12], [10, 99, 12, 13]);
  expect(result.accepted).toBe(1);
  expect(result.correction).toBe(99);
  expect(result.emitted).toEqual([10, 99]);
  expect(result.position).toBe(2);
});

test("full acceptance includes a bonus; an empty proposal still samples the target", () => {
  const full = run([10, 11], [10, 11, 12]);
  expect(full.accepted).toBe(2); expect(full.emitted).toEqual([10, 11, 12]);
  expect(full.correction).toBe(12);
  const empty = run([], [99]);
  expect(empty.accepted).toBe(0); expect(empty.emitted).toEqual([99]);
  expect(empty.correction).toBe(99);
});

test("accepted, correction and bonus EOS stop sampling without becoming content", () => {
  for (const [drafts, target, accepted, emitted] of [
    [[10, 0, 12], [10, 0, 12, 13], 2, [10]],
    [[10, 11, 12], [10, 0, 12, 13], 1, [10]],
    [[10, 11], [10, 11, 0], 2, [10, 11]],
  ] as const) {
    const result = run([...drafts], [...target]);
    expect(result.accepted).toBe(accepted); expect(result.emitted).toEqual([...emitted]);
    expect(result.sawEos).toBe(true); expect(result.done).toBe(true);
  }
});

test("token budget and grammar termination stop inside an accepted burst", () => {
  const budget = run([10, 11, 12], [10, 11, 12, 13], 2);
  expect(budget.emitted).toEqual([10, 11]); expect(budget.accepted).toBe(2);
  expect(budget.correction).toBeNull(); expect(budget.position).toBe(2);
  const grammar = run([10, 11, 12], [10, 11, 12, 13], 20, 0);
  expect(grammar.emitted).toEqual([10]); expect(grammar.grammarDone).toBe(true);
  expect(grammar.position).toBe(1);
});

test("a group samples only its live walks while other requests finish", () => {
  const states = [new DraftAcceptance([10, 11], 20, [0]),
    new DraftAcceptance([0, 21], 20, [0]), new DraftAcceptance([], 20, [0])];
  const targets = [[10, 99], [0], [77]], sampled: number[][] = [];
  while (states.some(state => !state.done)) {
    const active = states.flatMap((state, row) => state.done ? [] : [row]);
    sampled.push(active);
    for (const row of active) {
      const state = states[row]!;
      state.accept(targets[row]![state.position]!);
    }
  }
  expect(sampled).toEqual([[0, 1, 2], [0]]);
  expect(states.map(state => state.emitted)).toEqual([[10, 99], [], [77]]);
  expect(states.map(state => state.accepted)).toEqual([1, 1, 0]);
});
