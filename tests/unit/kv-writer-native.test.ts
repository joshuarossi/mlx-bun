import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { KVCache, RotatingKVCache, RotatingQuantizedKVCache,
  TurboQuantKVCache, type Cache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import { MLACache } from "../../src/model/glm52-cache";
import { cloneKvCaches, loadKvCache, readKvHeader, saveKvCache, saveKvCacheAsync } from "../../src/kv-store";
import { disposeResources } from "../../src/engine/resources";

function values(shape: number[], dtype = Dtype.float32): MlxArray {
  using source = MlxArray.fromFloat32(Float32Array.from(
    { length: shape.reduce((a, b) => a * b, 1) }, (_, i) => Math.sin(i * 1.3)), shape);
  return source.astype(dtype).eval();
}

test("CPU persistence matches native contiguous serialization for every cache codec and dtype", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-writer-native-"));
  const caches: Cache[] = [];
  const full = (dtype = Dtype.float32) => {
    const cache = new KVCache();
    // Offset below capacity creates a strided live slice between heads.
    cache.restoreState(values([1, 2, 8, 64], dtype), values([1, 2, 8, 64], dtype), 3);
    return cache;
  };
  caches.push(full(), full(Dtype.float16), full(Dtype.bfloat16));
  const affineSource = full(Dtype.bfloat16);
  try { caches.push(affineSource.toQuantized(64, 4)); }
  finally { affineSource.dispose(); }
  const turboSource = full();
  try { caches.push(TurboQuantKVCache.fromKVCache(turboSource, 8, 3)); }
  finally { turboSource.dispose(); }
  const ring = new RotatingKVCache(8);
  ring.restoreState(values([1, 2, 8, 64], Dtype.bfloat16), values([1, 2, 8, 64], Dtype.bfloat16), 12, 4);
  caches.push(ring);
  const quantRing = new RotatingQuantizedKVCache(8, 64, 4);
  using keys = values([1, 2, 8, 64], Dtype.bfloat16), vals = values([1, 2, 8, 64], Dtype.bfloat16);
  quantRing.restoreState(ops.quantize(keys, 64, 4), ops.quantize(vals, 64, 4), 12, 4);
  caches.push(quantRing);
  const ssm = new SSMCache();
  ssm.conv = values([1, 4, 3, 8], Dtype.bfloat16);
  ssm.recurrent = values([1, 4, 8, 8]); ssm.offset = 3;
  caches.push(ssm);
  for (const geometry of [
    { kvLoraRank: 8, ropeHeadDim: 4 },
    { kvLoraRank: 8, ropeHeadDim: 4, dsa: { headDim: 4 } },
    { kvLoraRank: 8, ropeHeadDim: 4, role: "mtp" as const },
  ]) {
    const cache = new MLACache(geometry);
    cache.restoreCompressedState(values([1, 3, 8]), values([1, 3, 4]), geometry.dsa ? values([1, 3, 4]) : null, 3);
    caches.push(cache);
  }
  const tensors = [Dtype.uint8, Dtype.int8, Dtype.uint32, Dtype.int32].map(dtype => {
    using source = MlxArray.fromFloat32(new Float32Array([0, 1, 17, 63]), [2, 2]);
    return source.astype(dtype).eval();
  });
  tensors.push(MlxArray.fromFloat32(new Float32Array([NaN, Infinity, -Infinity, -0]), [2, 2]));
  const attachments = [{ schema: "writer-test", metadata: { pending: 7 }, tensors }];
  try {
    for (const cache of caches) cache.minimumReusableOffset ??= 0;
    const reference = join(dir, "reference.mlxkv"), candidate = join(dir, "worker.mlxkv");
    saveKvCache(reference, [1, 2, 3], caches, { attachments });
    const writing = saveKvCacheAsync(candidate, [1, 2, 3], caches, { attachments });
    // Continue a borrower while the worker reads the immutable checkpoint.
    const borrower = cloneKvCaches([caches[0]!]);
    try {
      using next = values([1, 2, 1, 64]);
      const fetched = borrower[0]!.updateAndFetch(next, next);
      try { ops.evalAll(fetched); }
      finally { disposeResources(fetched); }
    } finally { disposeResources(borrower); }
    await writing;
    const expected = readKvHeader(reference), actual = readKvHeader(candidate);
    expect(actual.caches).toEqual(expected.caches);
    expect(actual.attachments).toEqual(expected.attachments);
    expect(readFileSync(candidate).subarray(actual.dataStart))
      .toEqual(readFileSync(reference).subarray(expected.dataStart));
    expect(new Set(actual.caches.map(entry => entry.kind)).size).toBe(9);
    const restored = loadKvCache(candidate, { makeCache: () => caches.map(cache =>
      cache instanceof MLACache ? new MLACache({ kvLoraRank: cache.kvLoraRank,
        ropeHeadDim: cache.ropeHeadDim, ...(cache.dsa ? { dsa: { headDim: cache.dsa.headDim } } : {}),
        role: cache.role }) : new KVCache()) }, { verify: true });
    try {
      const resaved = join(dir, "restored.mlxkv");
      await saveKvCacheAsync(resaved, [1, 2, 3], restored.caches, { attachments: restored.attachments });
      expect(readKvHeader(resaved).caches).toEqual(expected.caches);
      expect(readKvHeader(resaved).attachments).toEqual(expected.attachments);
    } finally {
      disposeResources(restored.caches);
      disposeResources(restored.attachments?.flatMap(attachment => attachment.tensors) ?? []);
    }
  } finally {
    disposeResources(caches); disposeResources(tensors);
    rmSync(dir, { recursive: true, force: true });
  }
}, 30_000);
