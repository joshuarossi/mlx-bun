import { expect, test } from "bun:test";
import { mapPackedTokens } from "../../src/model/token-groups";
import * as ops from "../../src/mlx/ops";

test("tokenwise packing preserves unequal lengths and B>1 without padding", () => {
  using decode = ops.fromInt32([1, 2], [2, 1, 1]);
  using prefill = ops.fromInt32([3, 4, 5, 6, 7, 8], [2, 3, 1]);
  let shape: readonly number[] = [];
  const output = mapPackedTokens([decode, prefill], packed => {
    shape = packed.shape;
    return ops.add(packed, packed);
  });
  try {
    expect(shape).toEqual([1, 8, 1]);
    expect(output.map(array => array.shape)).toEqual([[2, 1, 1], [2, 3, 1]]);
    expect(output.map(array => array.toIntTokens())).toEqual([[2, 4], [6, 8, 10, 12, 14, 16]]);
    expect(decode.toIntTokens()).toEqual([1, 2]);
  } finally { for (const array of output) array.dispose(); }
});

test("a lone token group preserves the operation's original geometry", () => {
  using input = ops.fromInt32([1, 2, 3, 4], [2, 2, 1]);
  const output = mapPackedTokens([input], value => {
    expect(value).toBe(input);
    return ops.copyOf(value);
  });
  try { expect(output[0]!.shape).toEqual([2, 2, 1]); }
  finally { for (const array of output) array.dispose(); }
});
