import { expect, test } from "bun:test";
import { captureRopeOffsets } from "../../src/model/gemma4-base";
import { KvTensorRows } from "../../src/backends/mlx/kv-tensor-rows";
import * as ops from "../../src/mlx/ops";

test("attention owns pre-write row positions across append and donor reuse", () => {
  const rows = new KvTensorRows();
  using short = ops.fromInt32([1, 2, 3], [1, 1, 3, 1]);
  using long = ops.fromInt32([1, 2, 3, 4, 5, 6, 7], [1, 1, 7, 1]);
  rows.mergeRows([{ planes: [short], rowOffsets: [3], leftPad: [0] },
    { planes: [long], rowOffsets: [7], leftPad: [0] }]);
  const borrowed = rows.ropeOffsetArr!;
  const position = captureRopeOffsets(rows)!;
  try {
    using update = ops.fromInt32([8, 9], [2, 1, 1, 1]);
    rows.append([update]);
    expect(() => borrowed.handle).toThrow("MlxArray used after dispose");
    expect([...position.toIntTokens()]).toEqual([3, 7]);
    expect([...rows.ropeOffsetArr!.toIntTokens()]).toEqual([4, 8]);
    rows.append([update]);
    expect([...position.toIntTokens()]).toEqual([3, 7]);
    expect([...rows.ropeOffsetArr!.toIntTokens()]).toEqual([5, 9]);
  } finally { position.dispose(); rows.dispose(); }
});

test("scalar attention positions need no retained array", () => {
  expect(captureRopeOffsets({})).toBeUndefined();
});
