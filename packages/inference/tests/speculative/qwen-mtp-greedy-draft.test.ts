import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { QwenMtpRows } from "../../src/execution/speculative/qwen-mtp-rows";
import type { MtpModule } from "../../src/models/qwen/mtp";
import type { Cache } from "../../src/contracts/cache";
import { toLogprobs } from "../../src/sampling/index";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/execution/config";
import { greedyDraftPolicy } from "../../src/generation/speculative/draft-policy";

const V = 6;
/** Row r at chained step s favors token (r * 2 + s) % V by a clear margin. */
function fixture(sampling: ConstructorParameters<typeof QwenMtpRows>[2]) {
  let step = 0;
  const target = { hiddenSize: 1, layerCount: 1,
    embed(ids: MlxArray) {
      using floats = ids.astype(Dtype.float32);
      return ops.reshape(floats, [...ids.shape, 1]);
    },
    logitsFromHidden(hidden: MlxArray): MlxArray {
      const B = hidden.shape[0]!;
      const values = Float32Array.from({ length: B * V }, (_, i) => {
        const row = Math.floor(i / V), token = i % V;
        return (token === (row * 2 + step) % V ? 4 : 0) + ((token * 3 + row) % 4) * 0.1;
      });
      step++;
      return MlxArray.fromFloat32(values, [B, 1, V]);
    },
  };
  const module = { forward(embeds: MlxArray, hidden: MlxArray, cache: Cache) {
    const [B, N] = embeds.shape;
    using k = ops.reshape(embeds, [B!, 1, N!, 1]);
    using v = ops.reshape(hidden, [B!, 1, N!, 1]);
    for (const view of cache.updateAndFetch(k, v)) view.dispose();
    return ops.copyOf(hidden);
  } } as MtpModule;
  const rows = new QwenMtpRows(target, module, sampling, []);
  rows.append([null, null]);
  using ids = ops.fromInt32([1, 2, 3, 11, 12, 13], [2, 3]);
  using context = MlxArray.fromFloat32(Float32Array.from([10, 20, 30, 110, 120, 130]), [2, 3, 1]);
  rows.prefill(ids, context);
  return rows;
}

test("greedy draft rows select the fused argmax without calling the request sampler", () => {
  let sampled = 0;
  const greedy = fixture({ greedy: true, sample() { sampled++; throw new Error("greedy rows must not sample"); } });
  const sampledRows = fixture({ sample(logprobs) { sampled++; return ops.argmaxAxis(logprobs, -1); } });
  try {
    const expected = [[0, 1, 2], [2, 3, 4]];
    expect(greedy.draft([4, 14], 3, [0, 10])).toEqual(expected);
    expect(sampled).toBe(0);
    expect(sampledRows.draft([4, 14], 3, [0, 10])).toEqual(expected);
    expect(sampled).toBe(3);
  } finally { greedy.dispose(); sampledRows.dispose(); }
});

test("greedy draft policy is an explicit opt-in runtime flag", () => {
  expect(withRuntimeConfig(createRuntimeConfig({}), greedyDraftPolicy)).toBe(false);
  expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_GREEDY_DRAFT: "1" }), greedyDraftPolicy)).toBe(true);
  expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_GREEDY_DRAFT: "0" }), greedyDraftPolicy)).toBe(false);
});

test("normalized argmax and sampled argmax agree on the draft logits", () => {
  using logits = MlxArray.fromFloat32(Float32Array.from([0.1, 4.0, 0.2, 0.3, 0.1, 0.0, 3.9, 0.2, 4.1, 0.3, 0.1, 0.0]), [2, V]);
  using logprobs = toLogprobs(logits);
  using viaLogprobs = ops.argmaxAxis(logprobs, -1);
  expect(viaLogprobs.toIntTokens()).toEqual([1, 2]);
});
