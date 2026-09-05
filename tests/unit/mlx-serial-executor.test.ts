import { expect, test } from "bun:test";
import { createMlxSerialExecutor, type MlxSerialBinding, type MlxSerialServices } from "../../src/backends/mlx/serial-executor";
import { Generation, type GenerateOptions, type GenerateStats } from "../../src/generate";
import { createRuntimeConfig } from "../../src/runtime-config";
import { KVCache, type Cache } from "../../src/model/gemma4";
import type { ResolvedExecution } from "../../src/contracts/execution";
import type { Vision } from "../../src/serve/generation-gateway";
import type { LoadedKvCache } from "../../src/kv-store";

const execution: ResolvedExecution = { method: "autoregressive", mechanism: "serial",
  pagedKv: false, promptCache: true, checkpoint: false, fill: false,
  compiledDecode: false, grammarJump: false, reasons: [] };

function fixture() {
  const released: string[] = [];
  const stored: Cache[][] = [];
  const stats: GenerateStats = { promptTokens: 2, cachedTokens: 0, generatedTokens: 1,
    prefillTps: 0, decodeTps: 0, prefillMs: 0, decodeMs: 0, cacheTokens: [0, 1] };
  class TrackedCache extends KVCache {
    override dispose() { released.push("cache"); super.dispose(); }
  }
  const binding: MlxSerialBinding = {
    runtime: createRuntimeConfig({}), makeCache: () => [new TrackedCache()],
    generate: () => new Generation((async function* () {
      try { yield { token: 2, index: 0 }; } finally { return stats; }
    })()),
    enterMedia: () => () => { released.push("context"); },
  };
  const services: MlxSerialServices = {
    promptCache: { take: () => null, put(_ids, caches) { stored.push(caches); } },
    checkpoints: null, identity: "fixture", adapterNamespace: () => "adapter",
    cloneState: () => { throw new Error("unexpected snapshot"); },
  };
  return { binding, services, released, stored, stats, TrackedCache };
}

test("serial execution transfers completed state to the prefix store after an early stop", async () => {
  const f = fixture();
  const cache = new f.TrackedCache();
  let retained: (() => void) | undefined;
  f.services.promptCache.take = () => ({ tokens: [0], caches: [cache], ns: "", retain() { f.released.push("retain"); } });
  f.services.promptCache.put = (_ids, caches, _ns, retain) => { f.stored.push(caches); retained = retain; };
  const run = createMlxSerialExecutor(f.binding, f.services);
  expect(await run([0, 1], {}, () => false, undefined, undefined, execution)).toEqual(f.stats);
  expect(f.stored).toEqual([[cache]]);
  expect(f.released).toEqual(["context"]);
  cache.dispose(); retained!();
  expect(f.released).toEqual(["context", "cache", "retain"]);
});

for (const phase of ["lookup", "construction", "trace"] as const) {
  test(`${phase} failure releases prepared inputs and any acquired state`, async () => {
    const f = fixture();
    const fail = () => { throw new Error(`${phase} failed`); };
    if (phase === "lookup") f.services.promptCache.take = fail;
    if (phase === "construction") f.binding.makeCache = fail;
    const vision = { embeddings: { dispose() { f.released.push("media"); } } } as Vision;
    const options = { grammar: { dispose() { f.released.push("grammar"); } } } as GenerateOptions;
    const trace = phase === "trace" ? { begin: () => fail } as unknown as NonNullable<Parameters<ReturnType<typeof createMlxSerialExecutor>>[4]> : undefined;
    const run = createMlxSerialExecutor(f.binding, f.services);
    await expect(run([0, 1], options, () => {}, vision, trace, execution)).rejects.toThrow(`${phase} failed`);
    expect(f.released).toEqual(phase === "trace" ? ["cache", "grammar", "media"] : ["grammar", "media"]);
    expect(f.stored).toEqual([]);
  });
}

test("one cleanup failure preserves the execution error and releases sibling resources", async () => {
  const f = fixture();
  f.services.promptCache.take = () => { throw new Error("lookup failed"); };
  const vision = { embeddings: { dispose() { f.released.push("media"); } } } as Vision;
  const options = { grammar: { dispose() { f.released.push("grammar"); throw new Error("cleanup failed"); } } } as unknown as GenerateOptions;
  const run = createMlxSerialExecutor(f.binding, f.services);
  const error = await run([0, 1], options, () => {}, vision, undefined, execution).catch((error: unknown) => error);
  expect(error).toBeInstanceOf(AggregateError);
  expect((error as AggregateError).errors.map((value: Error) => value.message)).toEqual(["lookup failed", "cleanup failed"]);
  expect(f.released).toEqual(["grammar", "media"]);
});

test("a rejected boundary snapshot releases its clone while generation retains the live state", async () => {
  const f = fixture();
  const live = new f.TrackedCache(), clone = new f.TrackedCache();
  f.binding.makeCache = () => [live];
  f.services.cloneState = () => [clone];
  f.services.promptCache.put = (ids, caches) => {
    if (ids.length === 299) throw new Error("snapshot rejected");
    f.stored.push(caches);
  };
  const binding: MlxSerialBinding = { ...f.binding, generate: (_prompt, options) => new Generation((async function* () {
    options!.onPrefillDone!();
    yield { token: 2, index: 0 };
    return f.stats;
  })()) };
  await createMlxSerialExecutor(binding, f.services)(Array(300).fill(0), {}, () => {}, undefined, undefined, execution);
  expect(f.stored).toEqual([[live]]);
  expect(f.released).toEqual(["cache", "context"]); // clone only
  live.dispose();
});

test("cancellation while replaying a checkpoint stops before the next saved token and frees restored state", async () => {
  const f = fixture();
  const abort = new AbortController();
  const cache = new f.TrackedCache();
  const binding = { ...f.binding, generate: () => { throw new Error("cancelled replay must not generate"); } };
  const services: MlxSerialServices = { ...f.services, checkpoints: {
    findGenerationCheckpoint: () => ({}) as never,
    restore: () => ({ caches: [cache], tokens: [0, 1, 2, 3], header: {
      generationCheckpoint: { pendingToken: 3, generatedTokens: 2, originalPromptTokens: 2, seed: 0 },
    } }) as unknown as LoadedKvCache,
    storeGenerationCheckpoint: async () => false,
    removeGenerationCheckpoints() { throw new Error("cancelled checkpoint must remain resumable"); },
  } };
  const emitted: number[] = [];
  await expect(createMlxSerialExecutor(binding, services)([0, 1], { signal: abort.signal }, (token) => {
    emitted.push(token); abort.abort(new Error("replay cancelled"));
  }, undefined, undefined, { ...execution, checkpoint: true })).rejects.toThrow("replay cancelled");
  expect(emitted).toEqual([2]);
  expect(f.released).toEqual(["cache", "context"]);
  expect(f.stored).toEqual([]);
});
