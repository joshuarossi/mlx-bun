import { expect, test } from "bun:test";
import * as ops from "@mlx-bun/mlx/ops";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { KVCache } from "../../src/state/kv";
import { TurboQuantKVCache } from "../../src/state/turboquant-kv";
import { type Cache } from "../../src/contracts/mlx/cache";
import { SSMCache } from "../../src/state/ssm";
import { captureCacheAttachment, restoreCacheAttachment } from "../../src/state/attachment";
import { disposeAttachments } from "../../src/state/checkpoint";
import { leaseCacheStates } from "../../src/state/leases";
import { withResource, disposeResources } from "../../src/runtime/resources";
import { cloneKvCaches } from "../../src/state/persistence";

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
