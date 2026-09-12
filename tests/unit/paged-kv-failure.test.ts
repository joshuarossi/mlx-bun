import { expect, spyOn, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { KVCache } from "../../src/model/gemma4-base";
import type { RuntimeModel } from "../../src/model/factory";
import { MlxBatchExecutionGroup, type BatchRequest } from "../../src/backends/mlx/batch-group";
import { BlockPool, PagedKVCache, PagedPoolExhausted } from "../../src/lab/paged-kv/paged-kv";
import { PagedKvRows } from "../../src/lab/paged-kv/paged-kv-rows";

function block(batch: number, tokens: number): MlxArray {
  return MlxArray.fromFloat32(Float32Array.from({ length: batch * tokens * 8 }, (_, i) => i + 1), [batch, 1, tokens, 8]);
}

function trackPools() {
  const written = new Set<BlockPool>(), disposed = new Set<BlockPool>();
  const write = BlockPool.prototype.writeBlock, dispose = BlockPool.prototype.dispose;
  const writes = spyOn(BlockPool.prototype, "writeBlock").mockImplementation(function(this: BlockPool, ...args: Parameters<BlockPool["writeBlock"]>) {
    written.add(this); return write.apply(this, args);
  });
  const disposals = spyOn(BlockPool.prototype, "dispose").mockImplementation(function(this: BlockPool) {
    disposed.add(this); return dispose.call(this);
  });
  const growth = spyOn(BlockPool.prototype, "grow").mockImplementation(function(this: BlockPool) {
    throw new PagedPoolExhausted(this.numBlocks);
  });
  return { written, disposed, restore() { writes.mockRestore(); disposals.mockRestore(); growth.mockRestore(); } };
}

test("later paged row growth failure leaves earlier advancement for owner cleanup", () => {
  const tracking = trackPools();
  const sources = [new PagedKVCache(8, 1), new PagedKVCache(1, 1)];
  const rows = new PagedKvRows(8, 1);
  try {
    rows.mergeRows(sources);
    using data = block(2, 2);
    expect(() => rows.updateAndFetch(data, data)).toThrow(PagedPoolExhausted);
    // Row0 finished its append. Row1 wrote one block, then exhausted its
    // free list and failed to grow before publishing an offset. No rollback is promised.
    expect(rows.rowOffsets).toEqual([2, 0]);
    expect(tracking.written.size).toBe(2);
    rows.dispose();
    expect(rows.batchSize).toBe(0); expect(rows.state()).toEqual([]);
    for (const pool of tracking.written) expect(tracking.disposed.has(pool)).toBe(true);
  } finally { rows.dispose(); for (const source of sources) source.dispose(); tracking.restore(); }
});

test("paged prefill growth failure releases cohort pools and closing settles the pending request", async () => {
  const tracking = trackPools();
  let held = true, calls = 0, created = 0;
  let partialOffsets: number[] = [];
  const model = {
    weightsBytes: 0,
    config: { modelType: "fixture", text: { numHiddenLayers: 1, layerTypes: ["full_attention"],
      numGlobalKeyValueHeads: 1, globalHeadDim: 8, slidingWindow: 0 } },
    makeCache() { return [new KVCache()]; },
    forwardHidden(ids: MlxArray, caches: PagedKvRows[]) {
      calls++;
      expect(ids.shape).toEqual([2, 2]);
      expect(caches[0]).toBeInstanceOf(PagedKvRows);
      using data = block(ids.shape[0]!, ids.shape[1]!);
      try {
        const fetched = caches[0]!.updateAndFetch(data, data);
        for (const array of fetched) array.dispose();
        throw new Error("expected pool exhaustion");
      } catch (error) {
        partialOffsets = caches[0]!.rowOffsets;
        held = true; // Leave the third request queued until explicit close.
        throw error;
      }
    },
  } as unknown as RuntimeModel;
  const group = new MlxBatchExecutionGroup(model, { maxBatch: 2, admissionHeld: () => held,
    prefillChunkSize: 2 });
  const request = (capacity: number): BatchRequest => ({
    promptIds: [2, 3, 4], maxTokens: 2, eosTokenIds: [],
    statePolicy: { key: "paged:1", create() { created++; return [new PagedKVCache(capacity, 1)]; } },
    sample() { throw new Error("failed prefill must not sample"); },
    onToken() { throw new Error("failed prefill must not publish"); },
  });
  const settle = (promise: Promise<unknown>) => promise.then(() => null, (error: unknown) => error);
  try {
    const first = settle(group.submit(request(8))), second = settle(group.submit(request(1)));
    const pending = settle(group.submit(request(8)));
    held = false; group.kick();
    const errors = await Promise.all([first, second]);
    for (const error of errors) expect(error).toBeInstanceOf(PagedPoolExhausted);
    expect(calls).toBe(1); expect(created).toBe(2);
    expect(partialOffsets).toEqual([2, 0]);
    expect(group.activeRows).toBe(0); expect(group.pendingRows).toBe(1);
    expect(tracking.written.size).toBe(2);
    for (const pool of tracking.written) expect(tracking.disposed.has(pool)).toBe(true);
    await group.close();
    expect(await pending).toHaveProperty("message", "scheduler closed");
    expect(group.activeRows + group.pendingRows).toBe(0);
    expect(created).toBe(2); // A queued request never allocated a pool.
  } finally { await group.close(); tracking.restore(); }
}, 10_000);
