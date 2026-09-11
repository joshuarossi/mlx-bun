import { expect, test } from "bun:test";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { KVCache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { BatchedKVCache } from "../../src/model/batched-kv";
import { BatchedSSMCache } from "../../src/model/batched-ssm";
import { MlxStateRows } from "../../src/backends/mlx/state-rows";
import { MlxAutoregressiveDraftRows } from "../../src/backends/mlx/autoregressive-draft-rows";

test("batched draft graph retains independent attention and recurrent boundaries", async () => {
  const state = new MlxStateRows([new BatchedKVCache(), new BatchedSSMCache()]);
  const empty = Array.from({ length: 3 }, () => [new KVCache(), new SSMCache()]);
  state.mergeRows(empty); for (const row of empty) for (const cache of row) cache.dispose();
  const calls: number[][] = [], sampled: number[][] = [];
  const draft = new MlxAutoregressiveDraftRows({
    descriptor: { id: "test", backend: "mlx", graphAbi: "test", stateAbi: "test", artifact: "test" },
    forwardHidden(ids, caches) {
      const tokens = ids.toIntTokens(), B = ids.shape[0]!, N = ids.shape[1]!; calls.push(tokens);
      using floating = ids.astype(Dtype.float32);
      using kv = ops.reshape(floating, [B, 1, N, 1]);
      const pair = caches[0]!.updateAndFetch(kv, kv); pair.forEach(a => a.dispose());
      const ssm = caches[1] as SSMCache;
      const previous = ssm.recurrent ? [...ssm.recurrent.toFloat32()] : Array(B).fill(0);
      const counts = ssm.prefillPadding?.advance(N) ?? Array(B).fill(N);
      ssm.recurrent?.dispose(); ssm.conv?.dispose();
      ssm.recurrent = MlxArray.fromFloat32(Float32Array.from(counts.map((count, row) => previous[row]! + tokens.slice(row * N, row * N + count).reduce((a, b) => a + b, 0))), [B, 1, 1]);
      ssm.conv = MlxArray.fromFloat32(Float32Array.from(counts.map((count, row) => tokens[row * N + count - 1]!)), [B, 1, 1]);
      ssm.offsets = ssm.offsets!.map((offset, row) => offset + counts[row]!); ssm.offset = Math.max(...ssm.offsets);
      return ops.reshape(floating, [B, N, 1]);
    },
    projectLogits(hidden) {
      const values = [...hidden.toFloat32()], B = hidden.shape[0]!, N = hidden.shape[1]!;
      const tokens = Array.from({ length: B }, (_, row) => values[row * N + N - 1]!);
      return MlxArray.fromFloat32(Float32Array.from(tokens.flatMap(token => Array.from({ length: 32 }, (_, id) => id === token + 1 ? 10 : 0))), [tokens.length, 1, 32]);
    },
  }, state, { sample(logprobs, steps) { sampled.push([...steps]); return ops.argmaxAxis(logprobs, -1); } });
  const inspect = (row: number) => {
    const caches = state.extractRow(row);
    try {
      const kv = caches[0] as KVCache, ssm = caches[1] as SSMCache;
      return { offset: kv.offset, keys: [...kv.keys!.toFloat32()], sum: [...ssm.recurrent!.toFloat32()], recurrentOffset: ssm.offset };
    } finally { for (const cache of caches) cache.dispose(); }
  };
  try {
    expect(await draft.draft([1, 4, 7], 3, [0, 10, 20])).toEqual([[2, 3, 4], [5, 6, 7], [8, 9, 10]]);
    await draft.commit([0, 1, 3]);
    expect(calls).toEqual([[1, 4, 7], [2, 5, 8], [3, 6, 9]]);
    expect(sampled).toEqual([[0, 10, 20], [1, 11, 21], [2, 12, 22]]);
    expect([0, 1, 2].map(inspect)).toEqual([
      { offset: 1, keys: [1], sum: [1], recurrentOffset: 1 },
      { offset: 2, keys: [4, 5], sum: [9], recurrentOffset: 2 },
      { offset: 3, keys: [7, 8, 9], sum: [24], recurrentOffset: 3 },
    ]);
    expect(await draft.draft([11, 12, 13], 0, [1, 12, 24])).toEqual([[], [], []]);
    await draft.commit([0, 0, 0]);
    expect([0, 1, 2].map(row => inspect(row).sum[0])).toEqual([12, 21, 47]);
    expect(sampled).toHaveLength(3);
    expect(calls.at(-1)).toEqual([11, 0, 12, 0, 10, 13]);
    draft.filterRows([2, 0]);
    expect(await draft.draft([14, 15], 2, [25, 2])).toEqual([[15, 16], [16, 17]]);
    await draft.commit([2, 0]);
    expect(inspect(0)).toEqual({ offset: 7, keys: [7, 8, 9, 10, 13, 14, 15], sum: [76], recurrentOffset: 7 });
    expect(inspect(1)).toEqual({ offset: 3, keys: [1, 11, 15], sum: [27], recurrentOffset: 3 });
  } finally { draft.dispose(); }
});
