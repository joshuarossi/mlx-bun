import { expect, test } from "bun:test";
import { bindSpeculativeGroupRequests } from "../../src/execution/speculative-group";
import type { MlxGroupMethodHost, MlxGroupPreparation, Row } from "../../src/execution/batch-types";
import { KVCache } from "../../src/state/kv";
import { type Cache, type Mask } from "../../src/contracts/mlx/cache";
import type { RuntimeModel } from "../../src/models/factory";
import { captureKvAttention } from "../../src/state/kv-attention-view";
import { NgramProvider } from "../../src/generation/speculative/sources/ngram-source";
import type { DraftProvider } from "../../src/generation/speculative/source";
import { PromptCache } from "../../src/state/prefix-cache";
import { runtimeConfig } from "../../src/runtime/config";
import { cleanupFailure, disposeResources, withResource } from "../../src/runtime/resources";
import { leaseCacheStates } from "../../src/state/leases";
import { disposeAttachments } from "../../src/state/checkpoint";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import type { GenerateOptions } from "../../src/generation/index";
import { createHash } from "node:crypto";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MlxArray } from "@mlx-bun/mlx/array";

/** Owned target state as stored: class, coverage, reuse floor and exact planes. */
function encoded(caches: readonly Cache[]) {
  return caches.map(layer => ({ kind: layer.constructor.name, offset: layer.offset,
    minimum: layer.minimumReusableOffset ?? 0,
    state: withResource(leaseCacheStates([layer]), arrays => arrays.map(array => {
      const end = [...array.shape]; end[2] = Math.min(end[2]!, layer.offset);
      using trimmed = array.slice(end.map(() => 0), end);
      using contiguous = ops.contiguous(trimmed);
      return { shape: end, dtype: array.dtype, sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") };
    })),
  }));
}

function fixture(provider: Pick<DraftProvider, "id" | "grouped"> & { dispose(): void } = new NgramProvider(), graph: object = {},
  options: Partial<GenerateOptions> = {}) {
  const shapes: number[][] = [], inputs: number[][] = [];
  const snapshots: { tokens: number[]; history: number[]; offset: number }[] = [];
  const puts: { tokens: number[]; history: number[]; state: ReturnType<typeof encoded> }[] = [];
  const failures: { row: Row; error: unknown }[] = [], joined: Row[] = [];
  const model = { config: { modelType: "fixture", eosTokenIds: [] }, makeCache: () => [new KVCache()],
    forwardHidden(ids: MlxArray, caches: Cache[]) {
      shapes.push([...ids.shape]); inputs.push([...ids.toIntTokens()]);
      using kv = ops.reshape(ids, [ids.shape[0]!, 1, ids.shape[1]!, 1]);
      for (const cache of caches) captureKvAttention(cache, kv, kv).dispose();
      return ops.reshape(ids, [ids.shape[0]!, ids.shape[1]!, 1]);
    },
    logitsFromHidden(hidden: MlxArray) { return ops.copyOf(hidden); },
    ...graph,
  } as unknown as RuntimeModel;
  const cache = new PromptCache(1024 ** 2);
  const host: MlxGroupMethodHost = { rows: joined, runtime: runtimeConfig(), prefillChunkSize: 3,
    promptCache: { take: cache.take.bind(cache), put(tokens, caches, namespace, retain, attachments) {
      snapshots.push({ tokens: [...tokens], history: attachments![0]!.tensors[0]!.toIntTokens(), offset: caches[0]!.offset });
      puts.push({ tokens: [...tokens], history: attachments![0]!.tensors[0]!.toIntTokens(), state: encoded(caches) });
      cache.put(tokens, caches, namespace, retain, attachments);
    } },
    join(row) { joined.push(row); },
    // As the scheduler does: the method filters its state, then membership.
    filterRows(keep) {
      const kept = keep.map(index => joined[index]!);
      method.filterRows(keep, false); joined.splice(0, joined.length, ...kept);
    },
    async publish(row, token) { return row.req.onToken(token); }, finish() {},
  };
  const binding = bindSpeculativeGroupRequests(model, provider, 2)!({ temperature: 0, maxTokens: 2, ...options });
  const method = binding.open(host);
  const row = (tokens: number[], signal?: AbortSignal): Row => {
    const request: Row = { req: { method: binding, promptIds: tokens, maxTokens: 2, eosTokenIds: [], signal,
      onToken() {} }, resolve() {}, reject(error) { failures.push({ row: request, error }); },
      current: 0, generated: 0, sampled: 0, promptTokens: tokens.length, cachedTokens: 0,
      admittedAt: 0, firstTokenAt: 0, fed: [], fedTainted: false, merged: false };
    return request;
  };
  return { method, model, host, row, shapes, inputs, snapshots, puts, failures, joined,
    dispose() { method.dispose(); cache.clear(); provider.dispose(); } };
}
async function drain(preparation: MlxGroupPreparation) {
  for (let step = 0; step < 30; step++) if (await preparation.advance()) return;
  throw new Error("preparation did not drain");
}

test("budgeted method prefill retains companion history through an injected model work port", async () => {
  const f = fixture(), row = f.row([1, 2, 3, 4, 5, 6, 7]);
  const preparation = f.method.prepare(row);
  let calls = 0;
  try {
    while (!await preparation.advance({ maxTokens: 2, forward: async (ids, caches) => {
      expect(ids.shape[0]! * ids.shape[1]!).toBeLessThanOrEqual(2); calls++;
      return f.model.forwardHidden(ids, caches);
    } })) { /* each bounded chunk returns to the scheduler */ }
    expect(calls).toBe(4);
    expect(f.joined).toEqual([row]);
    expect(f.method.runningTokens).toBe(3);
    expect(f.snapshots).toEqual([{ tokens: [1, 2, 3, 4, 5, 6], history: [1, 2, 3, 4, 5, 6], offset: 6 }]);
  } finally { preparation.dispose(); f.dispose(); }
});

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

test("rows that tap target layers their provider did not declare are refused before any forward and disposed", async () => {
  let disposed = 0;
  const undeclared = { id: "undeclared", dispose() {}, grouped: { checkpointNamespace: () => "undeclared",
    open: () => { throw new Error("decode rows must not open"); },
    openPrefill: () => ({ tapLayers: [0], dispose() { disposed++; } }) } };
  const f = fixture(undeclared as never), row = f.row([1, 2, 3, 4]);
  let thrown: unknown;
  try { await drain(f.method.prepare(row)); } catch (error) { thrown = error; }
  try {
    const errors = [thrown, ...f.failures.map(failure => failure.error)].filter(Boolean).map(String);
    expect(errors.some(error => error.includes("draft provider undeclared taps [0] but declared []"))).toBe(true);
    expect(disposed).toBe(1);
    expect(f.shapes).toEqual([]);
  } finally { f.dispose(); }
});

test("rows that tap exactly the layers resolved for their target are admitted", () => {
  let appended = 0, disposed = 0;
  const rows = { tapLayers: [0], prefillMode: "tail-split", namespace: "declared", rowCount: 0,
    append() { appended++; }, filterRows() {}, materialize() {}, dispose() { disposed++; } };
  const declared = { id: "declared", dispose() {}, grouped: { checkpointNamespace: () => "declared",
    targetTapLayers: () => [0], open: () => { throw new Error("decode rows must not open"); }, openPrefill: () => rows } };
  // The graph offers the hidden-tap operation over one layer, so the binding admits the declaration.
  const f = fixture(declared as never, { hiddenTap: null,
    config: { modelType: "fixture", eosTokenIds: [], text: { numHiddenLayers: 1 } } }), row = f.row([1, 2, 3, 4]);
  try {
    f.method.prepare(row);
    expect({ appended, disposed, failures: f.failures.length }).toEqual({ appended: 1, disposed: 0, failures: 0 });
  } finally { f.dispose(); }
});

test("the binding checks its own snapshot of the declared taps: a later change to the provider's list is refused", () => {
  const taps = [0];
  let disposed = 0;
  const rows = { tapLayers: taps, prefillMode: "tail-split", namespace: "mutable", rowCount: 0,
    append() {}, filterRows() {}, materialize() {}, dispose() { disposed++; } };
  const mutable = { id: "mutable", dispose() {}, grouped: { checkpointNamespace: () => "mutable",
    targetTapLayers: () => taps, open: () => { throw new Error("decode rows must not open"); }, openPrefill: () => rows } };
  const f = fixture(mutable as never, { hiddenTap: null,
    config: { modelType: "fixture", eosTokenIds: [], text: { numHiddenLayers: 1 } } }), row = f.row([1, 2, 3, 4]);
  // After the binding checked [0], the provider's shared list gains a layer this graph cannot capture.
  taps.push(5);
  let thrown: unknown;
  try { f.method.prepare(row); } catch (error) { thrown = error; }
  try {
    const errors = [thrown, ...f.failures.map(failure => failure.error)].filter(Boolean).map(String);
    expect(errors.some(error => error.includes("draft provider mutable taps [0,5] but declared [0]"))).toBe(true);
    expect(disposed).toBe(1);
    expect(f.shapes).toEqual([]);
  } finally { f.dispose(); }
});

const WIDTH = 128, START = 7;
const delayed: [string, Partial<GenerateOptions>][] = [
  ["affine", { kvBits: 8, quantizedKvStart: START }],
  ["TurboQuant", { turboQuant: { kBits: 4, vBits: 3 }, quantizedKvStart: START }],
];

/** Each layer attends through its cache's own storage, so the hidden state the
 * companion receives depends on the precision of the prefix it reads. */
function readingGraph() {
  const kinds: string[][] = [], inputs: number[][] = [];
  const graph = {
    forwardHidden(ids: MlxArray, caches: Cache[]) {
      const [batch, count] = ids.shape as [number, number], tokens = [...ids.toIntTokens()];
      kinds.push(caches.map(cache => cache.constructor.name)); inputs.push(tokens);
      using values = MlxArray.fromFloat32(Float32Array.from(tokens.flatMap(token =>
        Array.from({ length: WIDTH }, (_, column) => Math.sin(token + column / 13)))), [batch, 1, count, WIDTH]);
      using kv = values.astype(Dtype.bfloat16);
      const mask: Mask = { mode: count > 1 ? "causal" : "", arr: null };
      let hidden: MlxArray | null = null;
      try {
        for (const cache of caches) {
          const view = captureKvAttention(cache, kv, kv);
          try { const attended = view.attend(kv, WIDTH ** -0.5, mask); hidden?.dispose(); hidden = attended; }
          finally { view.dispose(); }
        }
        return ops.reshape(hidden!, [batch, count, WIDTH]);
      } finally { hidden?.dispose(); }
    },
    // One logit: every sample is token 0, which no prompt here contains, so
    // lookup drafting has no candidate after a fresh 0.
    logitsFromHidden(hidden: MlxArray) { return hidden.slice([0, 0, 0], [hidden.shape[0]!, hidden.shape[1]!, 1]); },
  };
  return { kinds, inputs, graph };
}

/** Lookup drafting ignores target context; record the context its prefill receives. */
function recordingNgram() {
  const contexts: { shape: number[]; sha256: string }[] = [];
  const inner = new NgramProvider(), grouped = inner.grouped;
  const provider = { id: inner.id, dispose: () => inner.dispose(), grouped: { ...grouped,
    openPrefill: (options: Parameters<typeof grouped.openPrefill>[0]) => {
      const rows = grouped.openPrefill(options), prefill = rows.prefill.bind(rows);
      rows.prefill = (tokens, context) => {
        if (context) {
          using contiguous = ops.contiguous(context);
          contexts.push({ shape: [...context.shape], sha256: createHash("sha256").update(contiguous.rawBytes()).digest("hex") });
        }
        return prefill(tokens, context);
      };
      return rows;
    } } };
  return { contexts, provider };
}

function delayedFixture(scheme: Partial<GenerateOptions>) {
  const reading = readingGraph(), recording = recordingNgram();
  const f = fixture(recording.provider, reading.graph, scheme);
  return { ...f, kinds: reading.kinds, forwards: reading.inputs, contexts: recording.contexts,
    reset() { reading.kinds.length = 0; reading.inputs.length = 0; recording.contexts.length = 0; f.puts.length = 0; } };
}

/** A finished request stores [1..5, 6, 0]. Its last verify round had no draft,
 * so that round's append reached START with no maintenance after it. */
async function storeOwedPrefix(f: ReturnType<typeof delayedFixture>): Promise<number[]> {
  const row = f.row([1, 2, 3, 4, 5, 6]), preparation = f.method.prepare(row);
  try { await drain(preparation); } finally { preparation.dispose(); }
  expect(f.joined).toEqual([row]);
  for (let round = 0; round < 2; round++) await f.method.advance();
  expect(f.joined).toEqual([]); expect(f.failures).toEqual([]);
  const stored = f.puts.at(-1)!;
  expect(stored.tokens).toEqual([1, 2, 3, 4, 5, 6, 0]);
  expect(stored.state.map(({ kind, offset }) => ({ kind, offset }))).toEqual([{ kind: "KVCache", offset: START }]);
  return stored.tokens;
}

/** The control reuses the same prefix maintained after its last append, as
 * mlx-lm leaves a cache; the subject reuses it as stored. */
function reuseMaintained(f: ReturnType<typeof delayedFixture>, scheme: Partial<GenerateOptions>) {
  const cache = f.host.promptCache!, take = cache.take.bind(cache);
  cache.take = (...args) => {
    const hit = take(...args);
    if (!hit) return hit;
    try { createKvMaintenance(scheme)(hit.caches); }
    catch (error) {
      cleanupFailure(error, () => disposeResources([...hit.caches,
        { dispose: () => disposeAttachments(hit.attachments) }, { dispose: () => hit.retain?.() }]));
    }
    return hit;
  };
}

test.each(delayed)("a reused speculative prefix owing its last append's conversion is maintained before its first suffix forward, alone or joining: %s", async (_name, scheme) => {
  const run = async (maintained: boolean, joining: boolean) => {
    const f = delayedFixture(scheme);
    try {
      const stored = await storeOwedPrefix(f);
      if (maintained) reuseMaintained(f, scheme);
      f.reset();
      const row = f.row([...stored, 31, 32, 33, 34]), peer = f.row([11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
      const preparation = f.method.prepare(joining ? peer : row);
      try {
        if (joining) { expect(await preparation.advance()).toBe(false); preparation.admit!(row); }
        expect(row.cachedTokens).toBe(stored.length);
        await drain(preparation);
      } finally { preparation.dispose(); }
      expect(f.failures).toEqual([]);
      return { kinds: f.kinds, forwards: f.forwards, contexts: f.contexts, puts: f.puts,
        current: [row.current, peer.current], joined: f.joined.length };
    } finally { f.dispose(); }
  };
  for (const joining of [false, true]) {
    const control = await run(true, joining), owed = await run(false, joining);
    if (!joining) expect(owed.kinds[0]).toEqual([scheme.turboQuant ? "TurboQuantKVCache" : "QuantizedKVCache"]);
    expect(owed.contexts.length).toBeGreaterThan(0);
    expect(owed).toEqual(control);
  }
});

test.each(delayed)("a reused speculative prefix covering the whole prefill runs no target prefill and verifies as the maintained prefix does: %s", async (_name, scheme) => {
  const run = async (maintained: boolean) => {
    const f = delayedFixture(scheme);
    try {
      const stored = await storeOwedPrefix(f);
      if (maintained) reuseMaintained(f, scheme);
      f.reset();
      const row = f.row([...stored, 9]), preparation = f.method.prepare(row);
      try {
        expect(row.cachedTokens).toBe(stored.length);
        await drain(preparation);
      } finally { preparation.dispose(); }
      expect(f.forwards).toEqual([]); expect(f.contexts).toEqual([]);
      expect(f.joined).toEqual([row]);
      for (let round = 0; round < 2; round++) await f.method.advance();
      expect(f.joined).toEqual([]); expect(f.failures).toEqual([]);
      return { kinds: f.kinds, forwards: f.forwards, puts: f.puts };
    } finally { f.dispose(); }
  };
  expect(await run(false)).toEqual(await run(true));
});

test.each(delayed)("a failed initial maintenance releases the reused prefix and its lease once and leaves a prefilling peer unchanged: %s", async (_name, scheme) => {
  const failure = new Error("injected conversion failure");
  const run = async (arrival: boolean) => {
    const f = delayedFixture(scheme), disposed: number[] = [];
    let released = 0;
    try {
      const stored = await storeOwedPrefix(f);
      const cache = f.host.promptCache!, take = cache.take.bind(cache);
      // The arrival's owned hit cannot convert; each release is counted.
      cache.take = (...args) => {
        const hit = take(...args);
        if (!hit) return hit;
        hit.caches.forEach((layer, index) => {
          const dispose = layer.dispose.bind(layer);
          Object.assign(layer, { temporalView() { throw failure; }, toQuantized() { throw failure; },
            dispose() { disposed.push(index); dispose(); } });
        });
        const retain = hit.retain;
        hit.retain = () => { released++; retain?.(); };
        return hit;
      };
      f.reset();
      const peer = f.row([11, 12, 13, 14, 15, 16, 17, 18, 19, 20]), preparation = f.method.prepare(peer);
      try {
        expect(await preparation.advance()).toBe(false);
        if (arrival) {
          expect(() => preparation.admit!(f.row([...stored, 41, 42, 43]))).toThrow(failure.message);
          expect({ disposed, released }).toEqual({ disposed: [0], released: 1 });
          expect(preparation.rows).toEqual([peer]);
        }
        await drain(preparation);
      } finally { preparation.dispose(); }
      expect(f.joined).toEqual([peer]); expect(f.failures).toEqual([]);
      return { kinds: f.kinds, forwards: f.forwards, contexts: f.contexts, puts: f.puts, current: peer.current };
    } finally { f.dispose(); }
  };
  expect(await run(true)).toEqual(await run(false));
});
