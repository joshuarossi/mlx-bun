import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxPrefillCohort, type PrefillState } from "../../src/backends/mlx/prefill-cohort";
import type { Row } from "../../src/backends/mlx/batch-group";
import type { RuntimeModel } from "../../src/model/factory";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { captureKvAttention } from "../../src/model/kv-attention-view";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import type { KvSchemeOptions } from "../../src/kv-scheme";
import { leaseCacheStates } from "../../src/backends/mlx/state-views";
import { PromptResponseTrace, type P2RTraceRecord } from "../../src/serve/prompt-response-trace";
import { withResource } from "../../src/engine/resources";

const dispose = (cache: Cache[]) => { for (const layer of cache) layer.dispose(); };
function row(id: number, length: number, chunkSize: number, signal?: AbortSignal): Row {
  return {
    req: { promptIds: Array.from({ length }, (_, index) => id * 1000 + index),
      maxTokens: 1, eosTokenIds: [], prefillChunkSize: chunkSize, signal,
      sample: logits => ops.argmaxAxis(logits, -1), onToken() {}, snapshotAt: 256 },
    resolve() {}, reject() {}, current: 0, generated: 0, sampled: 0,
    promptTokens: length, cachedTokens: 0, admittedAt: 0, firstTokenAt: 0,
    fed: [], fedTainted: false, merged: false,
  };
}
function encoded(cache: Cache[]) {
  return cache.map(layer => ({ signature: layer.signature(), offset: layer.offset,
    minimum: layer.minimumReusableOffset ?? 0,
    state: withResource(leaseCacheStates([layer]), arrays => arrays.map(array => {
      const end = [...array.shape]; end[2] = Math.min(end[2]!, layer.offset);
      using trimmed = array.slice(end.map(() => 0), end);
      using contiguous = ops.contiguous(trimmed);
      return { shape: end, dtype: array.dtype, sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") };
    })),
  }));
}
function fixture(options: KvSchemeOptions = {}, failId?: number) {
  const completed = new Map<number, ReturnType<typeof encoded>>();
  const snapshots = new Map<number, ReturnType<typeof encoded>>();
  const rejected: unknown[] = [], shapes: number[][] = [], input: number[][][] = [];
  const model = { makeCache: () => [new KVCache()] } as unknown as RuntimeModel;
  const cohort = new MlxPrefillCohort({ model, chunkSize: 5, tailSplit: true,
    maintain: createKvMaintenance(options),
    promptCache: { take: () => null, put(tokens, cache) {
      snapshots.set(tokens[0]!, encoded(cache)); dispose(cache);
    } },
    async forward(ids, caches) {
      const [batch, count] = ids.shape as [number, number], tokens = [...ids.toIntTokens()];
      shapes.push([...ids.shape]);
      input.push(Array.from({ length: batch }, (_, r) => tokens.slice(r * count, (r + 1) * count)));
      // A deterministic token-to-KV graph exposes omissions, repeats and row
      // mixing. Precision/positions use the actual native cache layouts.
      using kv = MlxArray.fromFloat32(Float32Array.from(tokens.flatMap(token =>
        Array.from({ length: 128 }, (_, column) => Math.sin(token + column / 13)))), [batch, 1, count, 128]);
      for (const cache of caches) { const view = cache.attentionState?.appendAndFetch(kv, kv) ?? captureKvAttention(cache, kv, kv); view.dispose(); }
      return ops.reshape(ids, [batch, count, 1]);
    },
    project(hidden) { return ops.copyOf(hidden); },
    async complete(state: PrefillState, hidden) {
      const id = state.row.req.promptIds[0]!;
      if (id === failId) throw new Error("consumer failed");
      expect([...hidden.toIntTokens()]).toEqual(state.row.req.promptIds.slice(state.pos - hidden.shape[1]!));
      completed.set(id, encoded(state.solo)); dispose(state.solo);
    },
    reject(_row, error) { rejected.push(error); },
  });
  return { cohort, completed, snapshots, rejected, shapes, input };
}
async function drain(cohort: MlxPrefillCohort) {
  for (let step = 0; step < 100; step++) if (await cohort.advance()) return;
  throw new Error("cohort did not finish");
}

const schemes: [string, KvSchemeOptions][] = [
  ["plain", {}],
  ["affine immediate", { kvBits: 4, quantizedKvStart: 0 }],
  ["affine delayed", { kvBits: 8, quantizedKvStart: 5 }],
  ["TurboQuant immediate", { turboQuant: { kBits: 4, vBits: 3 }, quantizedKvStart: 0 }],
  ["TurboQuant delayed", { turboQuant: { kBits: 4, vBits: 3 }, quantizedKvStart: 5 }],
];
test.each(schemes)("staggered prefill joins preserve every real token and each request's precision boundary: %s", async (_name, scheme) => {
  const f = fixture(scheme), requests = [row(1, 18, 5), row(2, 13, 3), row(3, 9, 4)];
  try {
    f.cohort.admit(requests[0]!); expect(await f.cohort.advance()).toBe(false);
    f.cohort.admit(requests[1]!); expect(await f.cohort.advance()).toBe(false);
    f.cohort.admit(requests[2]!); await drain(f.cohort);
    expect(f.shapes.slice(0, 3)).toEqual([[1, 5], [2, 3], [3, 2]]);
    expect(f.rejected).toEqual([]);
    for (const request of requests) {
      const control = fixture(scheme);
      try {
        control.cohort.admit(request); await drain(control.cohort);
        expect(f.completed.get(request.req.promptIds[0]!)).toEqual(control.completed.get(request.req.promptIds[0]!));
        const supplied = f.input.flat().filter(tokens => Math.floor(tokens[0]! / 1000) === Math.floor(request.req.promptIds[0]! / 1000)).flat();
        expect(supplied).toEqual(request.req.promptIds);
      } finally { control.cohort.dispose(); }
    }
  } finally { f.cohort.dispose(); }
});

test("a late prefill join preserves each request's checkpoint and resumed tail", async () => {
  const f = fixture(), requests = [row(1, 270, 64), row(2, 267, 37)];
  try {
    f.cohort.admit(requests[0]!); expect(await f.cohort.advance()).toBe(false);
    f.cohort.admit(requests[1]!); await drain(f.cohort);
    expect(f.rejected).toEqual([]);
    for (const request of requests) {
      const control = fixture();
      try {
        control.cohort.admit(request); await drain(control.cohort);
        expect(f.snapshots.get(request.req.promptIds[0]!)).toEqual(control.snapshots.get(request.req.promptIds[0]!));
        expect(f.snapshots.get(request.req.promptIds[0]!)?.[0]?.offset).toBe(256);
        expect(f.completed.get(request.req.promptIds[0]!)).toEqual(control.completed.get(request.req.promptIds[0]!));
      } finally { control.cohort.dispose(); }
    }
  } finally { f.cohort.dispose(); }
});

test("cancellation during shared prefill preserves siblings and permits a later join", async () => {
  const abort = new AbortController(), f = fixture();
  try {
    f.cohort.admit(row(1, 18, 5, abort.signal)); f.cohort.admit(row(2, 13, 3));
    expect(await f.cohort.advance()).toBe(false); abort.abort(new Error("cancelled"));
    f.cohort.admit(row(3, 9, 4)); await drain(f.cohort);
    expect(f.rejected).toHaveLength(1); expect(f.rejected[0]).toHaveProperty("message", "cancelled");
    expect([...f.completed.keys()].sort()).toEqual([2000, 3000]);
    for (const request of [row(2, 13, 3), row(3, 9, 4)]) {
      const control = fixture();
      try {
        control.cohort.admit(request); await drain(control.cohort);
        expect(f.completed.get(request.req.promptIds[0]!)).toEqual(control.completed.get(request.req.promptIds[0]!));
      } finally { control.cohort.dispose(); }
    }
  } finally { f.cohort.dispose(); }
});

test("a completed-row consumer failure leaves another prefill running", async () => {
  const f = fixture({}, 1000);
  try {
    f.cohort.admit(row(1, 4, 3)); f.cohort.admit(row(2, 13, 3)); await drain(f.cohort);
    expect(f.rejected).toHaveLength(1); expect(f.rejected[0]).toHaveProperty("message", "consumer failed");
    expect([...f.completed.keys()]).toEqual([2000]);
  } finally { f.cohort.dispose(); }
});

test("a restored late arrival releases its backing lease after admission and preserves its prefix", async () => {
  const f = fixture(), restored = [new KVCache()], request = row(2, 13, 3);
  let releases = 0;
  using ids = ops.fromInt32(request.req.promptIds.slice(0, 3), [1, 3]);
  const hidden = await f.cohort.host.forward(ids, restored); hidden.dispose();
  f.cohort.host.promptCache!.take = tokens => tokens[0] === 2000
    ? { tokens: request.req.promptIds.slice(0, 3), caches: restored, retain: () => { releases++; } } : null;
  try {
    f.cohort.admit(row(1, 18, 5)); expect(await f.cohort.advance()).toBe(false);
    f.cohort.admit(request); expect(releases).toBe(0);
    expect(await f.cohort.advance()).toBe(false);
    expect(releases).toBe(1); expect(request.cachedTokens).toBe(3);
    await drain(f.cohort); expect(f.rejected).toEqual([]);
    const control = fixture();
    try {
      control.cohort.admit(row(2, 13, 3)); await drain(control.cohort);
      expect(f.completed.get(2000)).toEqual(control.completed.get(2000));
    } finally { control.cohort.dispose(); }
    expect(releases).toBe(1);
  } finally { f.cohort.dispose(); }
});


test("prefill traces preserve shared work identity and do not change row state", async () => {
  const f = fixture(), requests = [row(1, 270, 64), row(2, 267, 37)];
  const records: P2RTraceRecord[] = [];
  for (const [index, request] of requests.entries()) request.req.trace = new PromptResponseTrace({
    traceId: `row-${index}`, requestId: `row-${index}`, route: "test", emit: record => records.push(record),
  });
  try {
    f.cohort.admit(requests[0]!); await f.cohort.advance();
    f.cohort.admit(requests[1]!); await drain(f.cohort);
    for (const request of requests) request.req.trace!.finish("success");
    expect(f.rejected).toEqual([]);
    for (const record of records) {
      for (const phase of ["prefill.row_sync", "prefill.forward", "prefill.evaluate",
        "prefill.kv_maintenance", "prefill.checkpoint", "prefill.project", "prefill.complete"])
        expect(record.events.some(event => event.phase === phase)).toBe(true);
      expect(record.events.every(event => event.durationMs >= 0)).toBe(true);
    }
    const shared = records[0]!.events.find(event => event.phase === "prefill.forward" && event.attributes?.batchSize === 2)!;
    expect(records[1]!.events.some(event => event.phase === shared.phase && event.attributes?.workId === shared.attributes?.workId)).toBe(true);
    for (const request of requests) {
      const control = fixture();
      try {
        control.cohort.admit(row(Math.floor(request.req.promptIds[0]! / 1000), request.promptTokens, request.req.prefillChunkSize!));
        await drain(control.cohort);
        expect(f.completed.get(request.req.promptIds[0]!)).toEqual(control.completed.get(request.req.promptIds[0]!));
      } finally { control.cohort.dispose(); }
    }
  } finally { f.cohort.dispose(); }
});
