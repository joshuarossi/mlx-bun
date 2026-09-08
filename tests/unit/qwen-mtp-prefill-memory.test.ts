import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { activeMemory, clearCache, Dtype, synchronize } from "../../src/mlx/ffi";
import { KVCache } from "../../src/model/gemma4-base";
import { QwenMtpSource } from "../../src/spec/qwen-mtp-source";

test("MTP prefill releases the prompt backing buffer and preserves its final hidden row", async () => {
  const length = 8193, width = 256;
  let pendingHidden: number[] = [];
  const target = {
    hiddenSize: width, layerCount: 1,
    embed(ids: MlxArray) { return ops.zeros([1, ids.shape[1]!, width], Dtype.float32); },
    logitsFromHidden() { return ops.zeros([1, 1, 8], Dtype.float32); },
  };
  // A small lazy KV projection lets this ownership test exercise the real
  // source and cache without model weights or a full attention operation.
  const module = { forward(_embeds: MlxArray, hidden: MlxArray, cache: KVCache) {
    const count = hidden.shape[1]!;
    if (count === 1) pendingHidden = [...hidden.toFloat32Host()];
    using column = hidden.slice([0, 0, 0], [1, count, 1]);
    using kv = ops.reshape(column, [1, 1, count, 1]);
    for (const view of cache.updateAndFetch(kv, kv)) view.dispose();
    return ops.zeros([1, count, width], Dtype.float32);
  } } as unknown as ConstructorParameters<typeof QwenMtpSource>[1];
  const liveBytes = () => { synchronize(gpuStream); clearCache(); return activeMemory(); };
  Bun.gc(true);
  await Bun.sleep(0);
  const baseline = liveBytes();
  const source = new QwenMtpSource(target, module,
    () => MlxArray.fromInt32(new Int32Array([1]), [1]));
  const values = Float32Array.from({ length: length * width }, (_, i) => i % 1009);
  try {
    await source.prefill(Array(length).fill(7), MlxArray.fromFloat32(values, [1, length, width]));
    // KV is at most 64 KiB and the pending row is 1 KiB. Neither the lazy
    // prefill graph nor that row may keep the 8 MiB prompt buffer alive.
    expect(liveBytes() - baseline).toBeLessThan(256 * 1024);
    await source.draft([7], 1, 0);
    expect(pendingHidden).toEqual([...values.slice(-width)]);
  } finally { source.dispose(); }
  expect(liveBytes() - baseline).toBeLessThan(4096);
});

test("a failed MTP sample releases its logits and in-flight module output", async () => {
  const width = 65536;
  const array = (length: number) =>
    MlxArray.fromFloat32(new Float32Array(length), [1, 1, length]);
  const target = {
    hiddenSize: width, layerCount: 1,
    embed() { return array(width); },
    logitsFromHidden() { return array(width); },
  };
  const module = { forward(_embeds: MlxArray, _hidden: MlxArray, cache: KVCache) {
    using kv = MlxArray.fromFloat32(new Float32Array([1]), [1, 1, 1, 1]);
    for (const view of cache.updateAndFetch(kv, kv)) view.dispose();
    return array(width);
  } } as unknown as ConstructorParameters<typeof QwenMtpSource>[1];
  const liveBytes = () => { synchronize(gpuStream); clearCache(); return activeMemory(); };
  Bun.gc(true);
  await Bun.sleep(0);
  const baseline = liveBytes();
  const source = new QwenMtpSource(target, module, () => { throw new Error("sample failed"); });
  try {
    await source.prefill([7], array(width));
    await expect(source.draft([7], 1, 0)).rejects.toThrow("sample failed");
  } finally { source.dispose(); }
  // No GC after the failure: the request must release these arrays itself.
  expect(liveBytes() - baseline).toBeLessThan(4096);
});
