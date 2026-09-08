import { expect, spyOn, test } from "bun:test";
import { appendFillHidden } from "../../src/backends/mlx/fill-append";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import type { Cache } from "../../src/model/gemma4-base";

const cache = (state: () => MlxArray[], owned = false): Cache =>
  ({ state, stateNeedsDispose: owned }) as Cache;

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
