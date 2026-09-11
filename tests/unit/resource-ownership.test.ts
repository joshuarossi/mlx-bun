import { expect, test } from "bun:test";
import { applyStateChanges, cleanupFailure, disposeResources, ownResource } from "../../src/engine/resources";
import { RequestOwnership } from "../../src/serve/request-plan";
import { leaseCacheState, leaseCacheStates } from "../../src/backends/mlx/state-views";
import type { Cache } from "../../src/model/gemma4-base";
import type { MlxArray } from "../../src/mlx/array";

test("a transferred owner cannot borrow, transfer twice, or release its recipient's resource", () => {
  const released: string[] = [];
  const first = ownResource("weights", (value) => released.push(value));
  const second = ownResource(first.transfer(), (value) => released.push(value));
  expect(() => first.borrow()).toThrow("ownership has ended");
  expect(() => first.transfer()).toThrow("ownership has ended");
  first.close();
  expect(released).toEqual([]);
  expect(second.borrow()).toBe("weights");
  second.close(); second.close();
  expect(released).toEqual(["weights"]);
});

test("request cleanup attempts all owners exactly once despite a failed destructor", () => {
  const calls: string[] = [];
  const scope = new RequestOwnership();
  const bad = { dispose() { calls.push("bad"); throw new Error("release failed"); } };
  scope.own(bad); scope.own(bad);
  scope.own({ dispose() { calls.push("good"); } });
  expect(() => scope.dispose()).toThrow("release failed");
  scope.dispose();
  expect(calls).toEqual(["bad", "good"]);
  expect(() => scope.own(bad)).toThrow("ownership has ended");
});

test("cleanup failures retain the execution error and every failed release", () => {
  const execution = new Error("forward failed");
  const first = new Error("first release");
  const second = new Error("second release");
  try {
    cleanupFailure(execution, () => disposeResources([
      { dispose() { throw first; } }, { dispose() { throw second; } },
    ]));
    throw new Error("expected failure");
  } catch (error) {
    expect(error).toBeInstanceOf(AggregateError);
    expect((error as AggregateError).errors[0]).toBe(execution);
    expect(((error as AggregateError).errors[1] as AggregateError).errors).toEqual([first, second]);
  }
});

// Only the state-view portion of the legacy ABI is relevant to these tests.
const cache = (state: () => MlxArray[], owned = false): Cache =>
  ({ state, stateNeedsDispose: owned }) as Cache;
const array = (dispose: () => void): MlxArray => ({ dispose }) as MlxArray;

test("borrowed state survives lease close; temporary views release on partial acquisition", () => {
  const calls: string[] = [];
  const borrowed = array(() => calls.push("borrowed"));
  const owned = array(() => calls.push("owned"));
  const view = leaseCacheState(cache(() => [borrowed]));
  expect(view.borrow()).toEqual([borrowed]);
  view.close(); view.close();
  expect(calls).toEqual([]);
  expect(() => view.borrow()).toThrow("ownership has ended");
  expect(() => leaseCacheStates([
    cache(() => [borrowed]), cache(() => [owned], true),
    cache(() => { throw new Error("state failed"); }),
  ])).toThrow("state failed");
  expect(calls).toEqual(["owned"]);
});

test("view lease preserves owned-before-borrowed evaluation order", () => {
  const calls: string[] = [];
  const borrowed = array(() => calls.push("borrowed"));
  const owned = array(() => calls.push("owned"));
  const view = leaseCacheStates([cache(() => [borrowed]), cache(() => [owned], true)]);
  expect(view.borrow()).toEqual([owned, borrowed]);
  view.close(); view.close();
  expect(calls).toEqual(["owned"]);
});

test("state owners publish together before releasing old state, even when release fails", () => {
  const live = ["old", "old"], released: number[] = [];
  const failure = new Error("old allocation release failed");
  expect(() => applyStateChanges([0, 1].map(row => () => ({
    commit() { live[row] = "new"; },
    dispose() {
      expect(live).toEqual(["new", "new"]);
      released.push(row);
      if (row === 0) throw failure;
    },
  })))).toThrow(failure);
  expect(released).toEqual([0, 1]);
  expect(live).toEqual(["new", "new"]);
});

test("failed preparation releases unpublished state and preserves the preparation error", () => {
  const execution = new Error("prepare failed"), cleanup = new Error("replacement release failed");
  let committed = false, releases = 0;
  try {
    applyStateChanges([
      () => ({ commit() { committed = true; }, dispose() { releases++; throw cleanup; } }),
      () => { throw execution; },
    ]);
    throw new Error("expected failure");
  } catch (error) {
    expect(error).toBeInstanceOf(AggregateError);
    expect((error as AggregateError).errors).toEqual([execution, cleanup]);
  }
  expect(committed).toBe(false);
  expect(releases).toBe(1);
});
