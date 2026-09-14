import { expect, test } from "bun:test";
import { bindQwenMediaInput } from "../../src/backends/mlx/qwen-prompt-input";
import type { Qwen35Model } from "../../src/model/qwen3_5";
import type { Cache } from "../../src/model/gemma4-base";
import type { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";

test("request positions follow padded rows, reordered rows and retirement without model mutation", () => {
  const sentinel = { delta: 99 }, captured: number[][] = [];
  const model = { faIdx: 0, mrope: sentinel,
    forwardHiddenAtPositions(_ids: MlxArray, _cache: Cache[], positions: MlxArray) {
      captured.push(positions.toIntTokens()); return ops.contiguous(positions);
    },
  } as unknown as Qwen35Model;
  using embeddings = ops.fromInt32([0], [1, 1, 1]);
  const state = (delta: number) => ({ delta,
    positions: [new Int32Array(), new Int32Array(), new Int32Array()] as [Int32Array, Int32Array, Int32Array] });
  const a = bindQwenMediaInput(model, embeddings, state(-2)).decodeState!;
  const b = bindQwenMediaInput(model, embeddings, state(-4)).decodeState!;
  using ids = ops.fromInt32([1, 2, 3, 4, 5, 6], [2, 3]);
  using offsets = ops.fromInt32([7, 11], [2]);
  using first = a.forward(ids, [{ offset: 1000, ropeOffsetArr: offsets } as unknown as Cache], [a, b]);
  expect(first.shape).toEqual([3, 2, 3]);
  expect(captured[0]).toEqual(Array(3).fill([5, 6, 7, 7, 8, 9]).flat());
  using reverseOffsets = ops.fromInt32([11, 7], [2]);
  using reversed = b.forward(ids, [{ offset: 1000, ropeOffsetArr: reverseOffsets } as unknown as Cache], [b, a]);
  expect(captured[1]).toEqual(Array(3).fill([7, 8, 9, 5, 6, 7]).flat());
  using soloIds = ops.fromInt32([4], [1, 1]);
  using retired = b.forward(soloIds, [{ offset: 12 } as Cache], [b]);
  expect(captured[2]).toEqual([8, 8, 8]);
  expect(model.mrope).toBe(sentinel as never);
});
