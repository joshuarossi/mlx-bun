import { expect, spyOn, test } from "bun:test";
import { appendFillHidden, appendHiddenRows } from "../../src/backends/mlx/fill-append";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import type { Cache } from "../../src/model/gemma4-base";

const cache = (state: () => MlxArray[], owned = false): Cache =>
  ({ state, stateNeedsDispose: owned }) as Cache;

test("shared committed appends preserve each row and recheck the model's boundary", async () => {
  using input = ops.fromInt32([1, 2, 3, 4, 5, 11, 12, 13, 14, 15], [2, 5]);
  const state = { offset: 0, state: () => [] } as unknown as Cache;
  const chunks: number[][] = [];
  const decisions: number[][] = [];
  using output = await appendHiddenRows((ids) => {
    // Column chunks retain row strides; only the test's host reader needs
    // contiguous storage. Numerical consumers receive the borrowed view.
    using readable = ops.contiguous(ids);
    chunks.push(readable.toIntTokens());
    state.offset += ids.shape[1]!;
    return ops.reshape(ids, [2, ids.shape[1]!, 1]);
  }, [state], input, (caches, rows) => {
    decisions.push([rows, caches[0]!.offset]);
    return caches[0]!.offset === 2 ? 1 : 2;
  });
  expect(chunks).toEqual([[1, 2, 11, 12], [3, 13], [4, 5, 14, 15]]);
  expect(decisions).toEqual([[2, 0], [2, 2], [2, 3]]);
  expect(output.shape).toEqual([2, 5, 1]);
  expect(output.toIntTokens()).toEqual(input.toIntTokens());
  expect(state.offset).toBe(5);
});

test("shared append failure releases completed chunks without releasing the caller's input", async () => {
  using input = ops.fromInt32([1, 2, 11, 12], [2, 2]);
  const hidden = ops.fromInt32([1, 11], [2, 1, 1]);
  const release = spyOn(hidden, "dispose");
  const failure = new Error("second chunk failed");
  let calls = 0;
  try {
    await expect(appendHiddenRows(() => {
      if (++calls === 2) throw failure;
      return hidden;
    }, [], input, () => 1)).rejects.toBe(failure);
    expect(release).toHaveBeenCalledTimes(1);
    expect(input.toIntTokens()).toEqual([1, 2, 11, 12]);
  } finally { release.mockRestore(); hidden.dispose(); }
});

test("a single shared append returns owned output while borrowing the input", async () => {
  const input = ops.fromInt32([1, 2, 11, 12], [2, 2]);
  try {
    using output = await appendHiddenRows(ids => ops.reshape(ids, [2, 2, 1]), [], input, () => 4);
    expect(input.toIntTokens()).toEqual([1, 2, 11, 12]);
    input.dispose();
    expect(output.toIntTokens()).toEqual([1, 2, 11, 12]);
  } finally { input.dispose(); }
});

test("committed appends release temporary state before the next chunk and preserve borrowed state", async () => {
  const borrowed = ops.fromInt32([7, 8], [2]);
  const borrowedDispose = spyOn(borrowed, "dispose");
  const views: MlxArray[] = [];
  const releases: ReturnType<typeof spyOn>[] = [];
  let output: MlxArray | undefined;
  try {
    const state = [cache(() => [borrowed]), cache(() => {
      const view = borrowed.slice([0], [1]);
      views.push(view);
      releases.push(spyOn(view, "dispose"));
      return [view];
    }, true)];
    output = await appendFillHidden((ids) => {
      for (const release of releases) expect(release).toHaveBeenCalledTimes(1);
      return ops.reshape(ids, [1, ids.shape[1]!, 1]);
    }, state, [1, 2, 3, 4, 5], () => 2);
    expect(output.toIntTokens()).toEqual([1, 2, 3, 4, 5]);
    expect(releases).toHaveLength(3);
    for (const release of releases) expect(release).toHaveBeenCalledTimes(1);
    expect(borrowedDispose).not.toHaveBeenCalled();
    expect(borrowed.toIntTokens()).toEqual([7, 8]);
  } finally {
    output?.dispose();
    for (const release of releases) release.mockRestore();
    borrowedDispose.mockRestore();
    for (const view of views) view.dispose();
    borrowed.dispose();
  }
});

test("failed append state acquisition releases its hidden output and previously acquired views", async () => {
  const borrowed = ops.fromInt32([7, 8], [2]);
  const view = borrowed.slice([0], [1]);
  const release = spyOn(view, "dispose");
  const hidden = ops.fromInt32([1], [1, 1, 1]);
  const releaseHidden = spyOn(hidden, "dispose");
  const failure = new Error("state acquisition failed");
  try {
    await expect(appendFillHidden(() => hidden, [
      cache(() => [view], true),
      cache(() => { throw failure; }),
    ], [1, 2], () => 1)).rejects.toBe(failure);
    expect(release).toHaveBeenCalledTimes(1);
    expect(releaseHidden).toHaveBeenCalledTimes(1);
    expect(borrowed.toIntTokens()).toEqual([7, 8]);
  } finally {
    release.mockRestore();
    releaseHidden.mockRestore();
    hidden.dispose();
    view.dispose();
    borrowed.dispose();
  }
});
