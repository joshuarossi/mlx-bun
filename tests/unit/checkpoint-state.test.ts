import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, openSync, writeSync, closeSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { KVCache } from "../../src/model/gemma4-base";
import { PromptCache, cacheBytes } from "../../src/prompt-cache";
import { SsdCacheStore } from "../../src/ssd-cache";
import { SsdDurabilityCoordinator } from "../../src/ssd-durability";
import { cloneKvCaches, loadKvCache, readKvHeader, saveKvCache, SpillQueue } from "../../src/kv-store";
import { attachmentBytes, cloneAttachments, disposeAttachments,
  type CheckpointAttachment } from "../../src/backends/mlx/checkpoint-state";
import { disposeResources } from "../../src/engine/resources";

function companion(value = 7): CheckpointAttachment[] {
  return [{ schema: "test-method-v1", metadata: { offset: 2 },
    tensors: [MlxArray.fromFloat32(new Float32Array([value, value + 1]), [1, 2])] }];
}
function targetCache(length = 3): KVCache {
  const cache = new KVCache();
  const values = new Float32Array(length * 2).fill(1);
  cache.restoreState(MlxArray.fromFloat32(values, [1, 1, length, 2]),
    MlxArray.fromFloat32(values, [1, 1, length, 2]), length);
  return cache;
}
const model = { makeCache: () => [new KVCache()] };
const options = (dir: string) => ({ dir, maxBytes: 1024 ** 2,
  modelId: "test", configFingerprint: "test", tokenizerHash: "test", verify: true });

test("method checkpoints share the RAM budget and preserve an earlier divergent boundary", () => {
  const first = companion(), second = companion(20);
  const cache = new PromptCache(128);
  cache.put([1, 2], [targetCache(2)], "method", undefined, first);
  cache.put([1, 2, 3, 4], [targetCache(4)], "method", undefined, second);
  expect(cache.totalBytes).toBe(112);
  expect(cache.size).toBe(2); // method state cannot be trimmed to an ancestor
  expect(cache.peekPrefixLen([1, 2, 3, 9], "method")).toBe(2);
  const hit = cache.take([1, 2, 3, 9], "method")!;
  expect(hit.tokens).toEqual([1, 2]);
  expect(hit.attachments).not.toBe(first);
  expect(cache.size).toBe(2);
  expect(hit.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
  disposeResources(hit.caches); disposeAttachments(hit.attachments); hit.retain?.();
  cache.clear();
});

test("snapshot views survive donor disposal and SSD restores method tensors separately from model layers", () => {
  const dir = mkdtempSync(join(tmpdir(), "checkpoint-state-"));
  const original = companion(), snapshot = cloneAttachments(original);
  original[0]!.metadata.offset = 99;
  disposeAttachments(original);
  const caches = [targetCache()];
  try {
    const store = new SsdCacheStore(options(dir));
    expect(store.store([1, 2, 3], caches, "method", snapshot)).toBe(true);
    disposeResources(caches); disposeAttachments(snapshot);
    const restarted = new SsdCacheStore(options(dir));
    expect(restarted.scan()).toBe(1);
    expect(restarted.find([1, 2, 9], "method")).toBeNull();
    const found = restarted.find([1, 2, 3, 4], "method")!;
    expect(found.entry.trimmable).toBe(false);
    expect(readKvHeader(found.entry.path).formatVersion).toBe(4);
    const hit = restarted.restore(found.entry, model)!;
    try {
      expect(hit.caches).toHaveLength(1);
      expect(hit.attachments![0]!.metadata.offset).toBe(2);
      expect(hit.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
    } finally { disposeResources(hit.caches); disposeAttachments(hit.attachments); }
    const child = Bun.spawnSync([process.execPath, "-e", `
      import { loadKvCache } from ${JSON.stringify(new URL("../../src/kv-store.ts", import.meta.url).pathname)};
      import { KVCache } from ${JSON.stringify(new URL("../../src/model/gemma4-base.ts", import.meta.url).pathname)};
      const restored = loadKvCache(process.argv[1], { makeCache: () => [new KVCache()] }, { verify: true });
      console.log(JSON.stringify({ tokens: restored.tokens,
        metadata: restored.attachments[0].metadata,
        values: Array.from(restored.attachments[0].tensors[0].toFloat32()) }));
      for (const cache of restored.caches) cache.dispose();
      for (const attachment of restored.attachments) for (const tensor of attachment.tensors) tensor.dispose();
    `, found.entry.path]);
    expect(child.exitCode).toBe(0);
    expect(JSON.parse(new TextDecoder().decode(child.stdout))).toEqual({
      tokens: [1, 2, 3], metadata: { offset: 2 }, values: [7, 8],
    });
    expect(() => loadKvCache(found.entry.path, { makeCache: () => [] })).toThrow("cached layers");
    const header = readKvHeader(found.entry.path);
    const fd = openSync(found.entry.path, "r+");
    try { writeSync(fd, new Uint8Array([255]), 0, 1, header.dataStart + header.attachments![0]!.tensors[0]!.off); }
    finally { closeSync(fd); }
    expect(() => loadKvCache(found.entry.path, model, { verify: true })).toThrow("tensor hash mismatch");
  } finally {
    disposeResources(caches); disposeAttachments(snapshot);
    rmSync(dir, { recursive: true, force: true });
  }
});

test("ordinary cache files retain the existing v3 format", () => {
  const dir = mkdtempSync(join(tmpdir(), "checkpoint-v3-"));
  const caches = [targetCache()];
  try {
    const file = join(dir, "ordinary.mlxkv");
    saveKvCache(file, [1, 2], caches);
    expect(readKvHeader(file).formatVersion).toBe(3);
    const loaded = loadKvCache(file, model);
    expect(loaded.attachments).toBeUndefined();
    disposeResources(loaded.caches);
  } finally { disposeResources(caches); rmSync(dir, { recursive: true, force: true }); }
});

test("spill queue accounts for companion tensors and releases a dropped or failed write", async () => {
  const dropped = companion(), failed = companion();
  const queue = new SpillQueue(8, cacheBytes, async () => false, disposeResources);
  const old = queue.enqueue({ tokens: [1], caches: [], ns: "a", attachments: dropped });
  const next = queue.enqueue({ tokens: [2], caches: [], ns: "b", attachments: failed });
  expect(queue.pendingBytes).toBe(8);
  expect(queue.droppedCount).toBe(1);
  expect(await old).toBe(false);
  expect(await next).toBe(false);
  await queue.drain();
  expect(queue.pendingBytes).toBe(0);
  expect(queue.failedCount).toBe(1);
  expect(() => dropped[0]!.tensors[0]!.handle).toThrow();
  expect(() => failed[0]!.tensors[0]!.handle).toThrow();
});

test("write-behind captures companion state under the existing durability lifecycle", async () => {
  const dir = mkdtempSync(join(tmpdir(), "checkpoint-durable-"));
  const cache = new PromptCache(1024);
  const source = companion();
  const store = new SsdCacheStore(options(dir));
  const queue = new SpillQueue(1024, cacheBytes,
    (item) => store.storeAsync(item.tokens, item.caches, item.ns, undefined, item.attachments), disposeResources);
  const durability = new SsdDurabilityCoordinator(cache, queue, cloneKvCaches);
  try {
    cache.put([1, 2, 3], [targetCache()], "method", undefined, source);
    durability.schedule([1, 2, 3], "method");
    expect((await durability.flush()).durable).toBe(true);
    expect(attachmentBytes(source)).toBe(8);
    const hit = store.restore(store.find([1, 2, 3, 4], "method")!.entry, model)!;
    expect(hit.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
    disposeResources(hit.caches); disposeAttachments(hit.attachments);
  } finally { cache.clear(); await queue.drain(); rmSync(dir, { recursive: true, force: true }); }
});

test("RAM eviction spills the complete checkpoint and restores it through the same cache interface", async () => {
  const dir = mkdtempSync(join(tmpdir(), "checkpoint-tier-"));
  const store = new SsdCacheStore(options(dir));
  const queue = new SpillQueue(1024, cacheBytes,
    (item) => store.storeAsync(item.tokens, item.caches, item.ns, undefined, item.attachments), disposeResources);
  const cache = new PromptCache(64, { spillOwned: (entry) => { void queue.enqueue(entry); } }, {
    find: (tokens, ns) => {
      const hit = store.find(tokens, ns);
      return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null;
    },
    restore: (handle) => {
      const restored = store.restore(handle as Parameters<SsdCacheStore["restore"]>[0], model);
      return restored ? { ...restored, retain() {} } : null;
    },
    store: (tokens, caches, ns, attachments) => store.store(tokens, caches, ns, attachments),
  });
  try {
    cache.put([1, 2, 3], [targetCache()], "a", undefined, companion());
    cache.put([4, 5, 6], [targetCache()], "b", undefined, companion(20));
    expect(cache.size).toBe(1);
    await queue.drain();
    const restored = cache.take([1, 2, 3, 9], "a")!;
    expect(restored.tokens).toEqual([1, 2, 3]);
    expect(restored.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
    disposeResources(restored.caches); disposeAttachments(restored.attachments); restored.retain?.();
  } finally { cache.clear(); await queue.drain(); rmSync(dir, { recursive: true, force: true }); }
});


test("pending persistence leaves RAM reuse available and explicit flush waits for the write", async () => {
  const cache = new PromptCache(1024);
  const writing = Promise.withResolvers<void>();
  const release = Promise.withResolvers<void>();
  let persisted = false;
  const queue = new SpillQueue(1024, cacheBytes, async (item) => {
    writing.resolve();
    await release.promise;
    expect(item.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
    expect(item.caches[0]!.offset).toBe(3);
    persisted = true;
    return true;
  }, disposeResources);
  const durability = new SsdDurabilityCoordinator(cache, queue, cloneKvCaches,
    () => persisted, 0);
  let flushed = false;
  try {
    cache.put([1, 2, 3], [targetCache()], "method", undefined, companion());
    durability.schedule([1, 2, 3], "method");
    await writing.promise;
    const flush = durability.flush().then(result => { flushed = true; return result; });
    const hit = cache.take([1, 2, 3, 4], "method")!;
    expect(hit.tokens).toEqual([1, 2, 3]);
    expect(hit.attachments![0]!.tensors[0]!.toFloat32()).toEqual(new Float32Array([7, 8]));
    cache.clear();
    disposeResources(hit.caches); disposeAttachments(hit.attachments); hit.retain?.();
    await Promise.resolve();
    expect(flushed).toBe(false);
    expect(persisted).toBe(false);
    release.resolve();
    expect((await flush).durable).toBe(true);
  } finally { release.resolve(); await queue.drain(); cache.clear(); }
});


test("RAM checkpoint ownership releases unrelated target and companion batch allocations", async () => {
  const ops = await import("../../src/mlx/ops");
  const { activeMemory, clearCache, synchronize } = await import("../../src/mlx/ffi");
  const { SSMCache } = await import("../../src/model/qwen3-delta");
  const { materializeCopy } = await import("../../src/mlx/materialize");
  { using a = MlxArray.fromFloat32(new Float32Array([1]), [1]);
    using b = materializeCopy(a); ops.evalAll([b]); }
  synchronize(gpuStream); clearCache();
  const baseline = activeMemory(), store = new PromptCache(8 * 1024 ** 2);
  const source = new SSMCache();
  const companionRows = MlxArray.fromFloat32(new Float32Array(3 * 128 * 128).fill(7), [3, 128, 128]);
  let captured: CheckpointAttachment[] = [], target: InstanceType<typeof SSMCache> | undefined;
  try {
    source.conv = MlxArray.fromFloat32(new Float32Array(3 * 3 * 64).fill(2), [3, 3, 64]);
    source.recurrent = MlxArray.fromFloat32(new Float32Array(3 * 16 * 128 * 128).fill(3), [3, 16, 128, 128]);
    source.offset = 2; source.offsets = [2, 2, 2];
    ops.evalAll([...source.state(), companionRows]);
    target = source.extractRow(1);
    using row = companionRows.slice([1, 0, 0], [2, 128, 128]);
    captured = [{ schema: "test-batched-method-v1", metadata: { offset: 2 }, tensors: [materializeCopy(row)] }];
    const logicalBytes = cacheBytes([target]) + attachmentBytes(captured);
    store.put([1, 2], [target], "method", undefined, captured);
    target = undefined; captured = [];
    source.dispose(); companionRows.dispose(); row.dispose();
    synchronize(gpuStream); clearCache();
    // No take(), tensor readback or explicit snapshot evaluation before this
    // assertion: retaining an idle RAM entry must already own only its row.
    expect(activeMemory() - baseline).toBeLessThanOrEqual(logicalBytes + 16_384);
    expect(store.totalBytes).toBe(logicalBytes);
    const saved = store.findExact([1, 2], "method")!;
    expect((saved.caches[0] as InstanceType<typeof SSMCache>).recurrent!.toFloat32Host().every(v => v === 3)).toBe(true);
    expect(saved.attachments![0]!.tensors[0]!.toFloat32Host().every(v => v === 7)).toBe(true);
  } finally {
    source.dispose(); companionRows.dispose(); target?.dispose(); disposeAttachments(captured);
    store.clear(); synchronize(gpuStream); clearCache();
  }
});

test("snapshot materialization failure leaves ownership with the publisher", () => {
  const state = targetCache(2), attachments = companion();
  const failure = new Error("snapshot evaluation failed");
  const store = new PromptCache(1024, null, null, undefined, () => { throw failure; });
  try {
    expect(() => store.put([1, 2], [state], "method", undefined, attachments)).toThrow(failure);
    expect(store.size).toBe(0);
    expect(state.offset).toBe(2);
    expect(attachments[0]!.tensors[0]!.toFloat32Host()).toEqual(new Float32Array([7, 8]));
  } finally { state.dispose(); disposeAttachments(attachments); store.clear(); }
});
