import { expect, test } from "bun:test";
import * as ops from "../../src/mlx/ops";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { KVCache, TurboQuantKVCache, type Cache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { captureCacheAttachment, restoreCacheAttachment } from "../../src/backends/mlx/cache-attachment";
import { disposeAttachments } from "../../src/backends/mlx/checkpoint-state";
import { leaseCacheStates } from "../../src/backends/mlx/state-views";
import { withResource, disposeResources } from "../../src/engine/resources";
import { cloneKvCaches } from "../../src/kv-store";

const ones = (shape: number[]) => MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)).fill(1), shape);

const bytes = (caches: Cache[]) => {
  const live = cloneKvCaches(caches);
  try {
    return withResource(leaseCacheStates(live), tensors => tensors.map(tensor => {
      using value = ops.contiguous(tensor);
      return { shape: value.shape, dtype: value.dtype, bytes: [...value.rawBytesView()] };
    }));
  } finally { disposeResources(live); }
};

test("companion cache codecs retain encoded and recurrent state after donor disposal", () => {
  const full = () => {
    const cache = new KVCache();
    using keys = ones([1, 2, 3, 64]), values = ops.zeros([1, 2, 3, 64], Dtype.float32);
    disposeResources(cache.updateAndFetch(keys, values)); return cache;
  };
  const ssm = new SSMCache(); ssm.offset = 3;
  ssm.conv = ones([1, 2, 64]); ssm.recurrent = ones([1, 2, 64, 64]);
  const affine = full().toQuantized(64, 4), turbo = TurboQuantKVCache.fromKVCache(full(), 8, 3);
  const caches: Cache[] = [full(), affine, turbo, ssm];
  caches[1]!.minimumReusableOffset = 3; caches[2]!.minimumReusableOffset = 3;
  const expected = bytes(caches);
  const attachment = captureCacheAttachment("test-companion-v1", caches, { pendingLast: 7, processedTokens: 4 });
  disposeResources(caches);
  const restored = restoreCacheAttachment(attachment, () => [new KVCache(), new KVCache(), new KVCache(), new SSMCache()]);
  disposeAttachments([attachment]);
  try {
    expect(bytes(restored)).toEqual(expected);
    expect(restored.map(cache => cache.offset)).toEqual([3, 3, 3, 3]);
    expect(restored.map(cache => cache.minimumReusableOffset ?? 0)).toEqual([0, 3, 3, 0]);
  } finally { disposeResources(restored); }
});

test("an empty companion boundary restores through its model factory", () => {
  const source = [new KVCache(), new SSMCache()];
  const attachment = captureCacheAttachment("empty", source, { processedTokens: 0, pendingLast: false });
  disposeResources(source);
  const restored = restoreCacheAttachment(attachment, () => [new KVCache(), new SSMCache()]);
  try {
    expect(attachment.tensors).toEqual([]);
    expect(restored.map(cache => cache.offset)).toEqual([0, 0]);
    expect(restored.map(cache => cache.state())).toEqual([[], []]);
  } finally { disposeResources(restored); disposeAttachments([attachment]); }
});
