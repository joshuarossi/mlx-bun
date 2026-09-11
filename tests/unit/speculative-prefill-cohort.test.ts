import { expect, test } from "bun:test";
import { bindSpeculativeGroupRequests } from "../../src/backends/mlx/speculative-group";
import type { MlxGroupMethodHost, MlxGroupPreparation, Row } from "../../src/backends/mlx/batch-group";
import { KVCache, type Cache } from "../../src/model/gemma4-base";
import type { RuntimeModel } from "../../src/model/factory";
import { captureKvAttention } from "../../src/model/kv-attention-view";
import { NgramProvider } from "../../src/spec/ngram-source";
import { PromptCache } from "../../src/prompt-cache";
import { runtimeConfig } from "../../src/runtime-config";
import * as ops from "../../src/mlx/ops";
import type { MlxArray } from "../../src/mlx/array";

function fixture() {
  const shapes: number[][] = [], inputs: number[][] = [];
  const snapshots: { tokens: number[]; history: number[]; offset: number }[] = [];
  const failures: { row: Row; error: unknown }[] = [], joined: Row[] = [];
  const model = { config: { modelType: "fixture", eosTokenIds: [] }, makeCache: () => [new KVCache()],
    forwardHidden(ids: MlxArray, caches: Cache[]) {
      shapes.push([...ids.shape]); inputs.push([...ids.toIntTokens()]);
      using kv = ops.reshape(ids, [ids.shape[0]!, 1, ids.shape[1]!, 1]);
      for (const cache of caches) captureKvAttention(cache, kv, kv).dispose();
      return ops.reshape(ids, [ids.shape[0]!, ids.shape[1]!, 1]);
    },
    logitsFromHidden(hidden: MlxArray) { return ops.copyOf(hidden); },
  } as unknown as RuntimeModel;
  const cache = new PromptCache(1024 ** 2), provider = new NgramProvider();
  const host: MlxGroupMethodHost = { rows: joined, runtime: runtimeConfig(), prefillChunkSize: 3,
    promptCache: { take: cache.take.bind(cache), put(tokens, caches, namespace, retain, attachments) {
      snapshots.push({ tokens: [...tokens], history: attachments![0]!.tensors[0]!.toIntTokens(), offset: caches[0]!.offset });
      cache.put(tokens, caches, namespace, retain, attachments);
    } },
    join(row) { joined.push(row); }, filterRows() {},
    async publish(row, token) { return row.req.onToken(token); }, finish() {},
  };
  const binding = bindSpeculativeGroupRequests(model, provider, 2)({ temperature: 0, maxTokens: 2 });
  const method = binding.open(host);
  const row = (tokens: number[], signal?: AbortSignal): Row => {
    const request: Row = { req: { method: binding, promptIds: tokens, maxTokens: 2, eosTokenIds: [], signal,
      onToken() {} }, resolve() {}, reject(error) { failures.push({ row: request, error }); },
      current: 0, generated: 0, sampled: 0, promptTokens: tokens.length, cachedTokens: 0,
      admittedAt: 0, firstTokenAt: 0, fed: [], fedTainted: false, merged: false };
    return request;
  };
  return { method, row, shapes, inputs, snapshots, failures, joined,
    dispose() { method.dispose(); cache.clear(); provider.dispose(); } };
}
async function drain(preparation: MlxGroupPreparation) {
  for (let step = 0; step < 30; step++) if (await preparation.advance()) return;
  throw new Error("preparation did not drain");
}

test("lookup joins during prefill preserve target coverage and companion histories", async () => {
  const f = fixture(), a = f.row([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), b = f.row([11, 12, 13, 14, 15, 16, 17]);
  const preparation = f.method.prepare(a);
  try {
    expect(await preparation.advance()).toBe(false);
    expect(preparation.canAdmit).toBe(true); preparation.admit!(b);
    await drain(preparation);
    expect(f.shapes).toEqual([[1, 3], [2, 3], [2, 3]]);
    expect(f.inputs).toEqual([[1, 2, 3], [4, 5, 6, 11, 12, 13], [7, 8, 9, 14, 15, 16]]);
    expect(f.joined).toEqual([a, b]); expect(f.failures).toEqual([]);
    expect([a.current, b.current]).toEqual([10, 17]);
    expect(f.snapshots).toEqual([a, b].map(row => ({ tokens: row.req.promptIds.slice(0, -1),
      history: row.req.promptIds.slice(0, -1), offset: row.promptTokens - 1 })));
  } finally { preparation.dispose(); f.dispose(); }
});

test("a restored lookup prefix joins without a zero-length target forward", async () => {
  const f = fixture(), tokens = [1, 2, 3, 4, 5, 6, 7];
  const original = f.method.prepare(f.row(tokens));
  try {
    await drain(original);
    const calls = f.shapes.length, row = f.row(tokens), restored = f.method.prepare(row);
    try {
      expect(row.cachedTokens).toBe(6);
      await drain(restored);
      expect(f.shapes.length).toBe(calls); expect(row.current).toBe(7);
      expect(f.joined).toContain(row); expect(f.failures).toEqual([]);
    } finally { restored.dispose(); }
  } finally { original.dispose(); f.dispose(); }
});

test("cancellation after prefill completion retires only the cancelled ready row", async () => {
  const f = fixture(), abort = new AbortController();
  const a = f.row([1, 2, 3, 4], abort.signal), b = f.row([5, 6, 7, 8]);
  const preparation = f.method.prepare(a);
  try {
    preparation.admit!(b);
    expect(await preparation.advance()).toBe(false); expect(f.joined).toEqual([]);
    const reason = new Error("cancelled before decode admission"); abort.abort(reason);
    await drain(preparation);
    expect(f.failures).toEqual([{ row: a, error: reason }]); expect(f.joined).toEqual([b]);
  } finally { preparation.dispose(); f.dispose(); }
});

test("cancelling an unfinished lookup row preserves companion membership for a later arrival", async () => {
  const f = fixture(), abort = new AbortController();
  const a = f.row([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], abort.signal);
  const b = f.row([11, 12, 13, 14, 15, 16, 17]), c = f.row([21, 22, 23, 24]);
  const preparation = f.method.prepare(a);
  try {
    preparation.admit!(b); expect(await preparation.advance()).toBe(false);
    abort.abort(new Error("cancelled during prefill")); preparation.admit!(c);
    await drain(preparation);
    expect(f.joined).toEqual([b, c]); expect(f.failures).toHaveLength(1);
    expect(f.failures[0]!.row).toBe(a);
    expect(f.snapshots).toEqual([b, c].map(row => ({ tokens: row.req.promptIds.slice(0, -1),
      history: row.req.promptIds.slice(0, -1), offset: row.promptTokens - 1 })));
  } finally { preparation.dispose(); f.dispose(); }
});

test("a first-token consumer failure leaves an unfinished speculative prefill running", async () => {
  const f = fixture(), a = f.row([1]), b = f.row([11, 12, 13, 14, 15, 16, 17]);
  const reason = new Error("first-token consumer failed");
  a.req.onToken = () => { throw reason; };
  const preparation = f.method.prepare(a);
  try {
    preparation.admit!(b); await drain(preparation);
    expect(f.failures).toEqual([{ row: a, error: reason }]); expect(f.joined).toEqual([b]);
    expect(f.snapshots).toEqual([{ tokens: b.req.promptIds.slice(0, -1),
      history: b.req.promptIds.slice(0, -1), offset: 6 }]);
  } finally { preparation.dispose(); f.dispose(); }
});
