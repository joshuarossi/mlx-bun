import { expect, test } from "bun:test";
import { GenerationGateway } from "../../src/engine/generation-gateway";
import type { RequestShape, Vision } from "../../src/engine/completion";
import { UnsupportedExecutionError } from "../../src/engine/completion";
import { runtimeConfig } from "@mlx-bun/inference/runtime/config";
import type { MlxGatewayBinding, MlxBatchGroup } from "@mlx-bun/inference/execution";
import type { GenerateOptions } from "@mlx-bun/inference/generation";
import type { ResolvedExecution } from "@mlx-bun/inference/contracts/portable";

const shape = (): RequestShape => ({ hasVision: false, hasAdapters: false,
  hasRepetitionPenalty: false, userSeed: false, kvQuant: false, turboQuant: false,
  hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false });
const execution: ResolvedExecution = { method: "autoregressive", mechanism: "continuous",
  pagedKv: false, promptCache: true, checkpoint: false, fill: false,
  compiledDecode: false, grammarJump: false, reasons: [] };
const result = { promptTokens: 1, cachedTokens: 0, generatedTokens: 1,
  finishReason: "length" as const, prefillMs: 1, decodeMs: 1 };
function fake(options: { submit?: MlxBatchGroup["submit"]; plan?: MlxGatewayBinding["plan"]; failSetup?: boolean } = {}) {
  let samplingDisposed = 0, created = 0, capacity = 0, closed = false;
  const group: MlxBatchGroup = { activeRows: 0, pendingRows: 0, projectedKvBytes: 0,
    kvBudgetBytes: undefined, kick() {}, async close() { closed = true; },
    submit: options.submit ?? (async request => { await request.onToken(7); return result; }),
  };
  const binding = { config: { modelType: "replacement", eosTokenIds: [2] } as MlxGatewayBinding["config"], runtime: runtimeConfig(),
    plan: options.plan ?? (() => execution), cachesBatchable: () => true, kvBatchable: () => true,
    continuationRequest(_execution, _options, _prompt, onToken) {
      if (options.failSetup) throw new Error("sampling setup failed");
      return { continuation: { interval: 1, restore: () => null, resumeSampling() {}, captureOwned() {}, complete() {} },
        sample() { throw new Error("CPU fake never samples tensors"); }, plainGreedy: true,
        onToken, dispose() { samplingDisposed++; } };
    },
    createBatchGroup(opts) { created++; capacity = opts.maxBatch!; return group; },
    mediaInput() { return { forward() { throw new Error("CPU fake never forwards"); } }; },
  } as MlxGatewayBinding;
  return { binding, group, get samplingDisposed() { return samplingDisposed; },
    get created() { return created; }, get capacity() { return capacity; }, get closed() { return closed; } };
}
function grammar() { let disposed = 0; return {
  value: { dispose() { disposed++; } } as GenerateOptions["grammar"],
  get disposed() { return disposed; },
}; }

for (const capacity of [1, 4]) test(`capacity ${capacity} uses the same continuous submission path`, async () => {
  const f = fake(); const gateway = new GenerationGateway(f.binding, capacity);
  const s = shape(); const placement = gateway.place(s);
  expect(placement.mechanism).toBe("continuous");
  const tokens: number[] = [];
  expect((await gateway.run([1], { maxTokens: 1 }, token => { tokens.push(token); }, undefined, s, placement)).generatedTokens).toBe(1);
  expect(tokens).toEqual([7]); expect(f.created).toBe(1); expect(f.capacity).toBe(capacity);
  expect(f.samplingDisposed).toBe(1); expect(gateway.submittedRows).toBe(1);
  await gateway.close(); expect(f.closed).toBe(true);
});

test("unsupported methods report typed exclusion reasons without unrelated compilation diagnostics", () => {
  const f = fake({ plan: () => ({ ...execution, method: "denoising", mechanism: "serial",
    reasons: ["method-requires-serial", "compiled-decode-unavailable-for-request"] }) });
  const gateway = new GenerationGateway(f.binding, 1);
  let failure: unknown;
  try { gateway.place(shape()); } catch (error) { failure = error; }
  expect(failure).toBeInstanceOf(UnsupportedExecutionError);
  expect(failure).toMatchObject({ modelType: "replacement", method: "denoising", reasons: ["method-requires-serial"],
    message: "model replacement method denoising does not support shared execution: method-requires-serial" });
  expect(f.created).toBe(0);
});

test("unsupported cache capability is probed once even when every placement fails", () => {
  const f = fake({ plan: (_shape, _options, support) => ({ ...execution,
    mechanism: support.continuous ? "continuous" : "serial", reasons: support.continuous ? [] : ["continuous-unavailable"] }) });
  let probes = 0;
  f.binding.cachesBatchable = () => { probes++; return false; };
  const gateway = new GenerationGateway(f.binding, 2);
  expect(() => gateway.place(shape())).toThrow(UnsupportedExecutionError);
  expect(() => gateway.place(shape())).toThrow(UnsupportedExecutionError);
  expect(probes).toBe(1); expect(f.created).toBe(0);
});

test("two rows interleave at shared capacity and cancelling one preserves the other", async () => {
  type Request = Parameters<MlxBatchGroup["submit"]>[0];
  const rows = new Map<number, { request: Request; finish: () => void }>();
  const bothEntered = Promise.withResolvers<void>();
  const f = fake({ submit: request => {
    const task = Promise.withResolvers<typeof result>();
    const id = request.promptIds[0]!;
    const abort = () => task.reject(request.signal!.reason);
    request.signal?.addEventListener("abort", abort, { once: true });
    rows.set(id, { request, finish: () => task.resolve(result) });
    if (rows.size === 2) bothEntered.resolve();
    return task.promise.finally(() => { request.signal?.removeEventListener("abort", abort); rows.delete(id); });
  } });
  Object.defineProperty(f.group, "activeRows", { get: () => rows.size });
  let probes = 0;
  f.binding.cachesBatchable = () => { probes++; return true; };
  const gateway = new GenerationGateway(f.binding, 2), abort = new AbortController();
  const firstShape = shape(), secondShape = shape(), firstGrammar = grammar(), secondGrammar = grammar();
  const emitted: string[] = [];
  const first = gateway.run([1], { grammar: firstGrammar.value }, token => { emitted.push(`a${token}`); },
    undefined, firstShape, gateway.place(firstShape), abort.signal);
  const second = gateway.run([2], { grammar: secondGrammar.value }, token => { emitted.push(`b${token}`); },
    undefined, secondShape, gateway.place(secondShape));
  await bothEntered.promise;
  expect(gateway.activeRows).toBe(2); expect(f.created).toBe(1); expect(f.capacity).toBe(2);
  expect(probes).toBe(1); expect(gateway.submittedRows).toBe(2);
  await rows.get(1)!.request.onToken(7);
  await rows.get(2)!.request.onToken(8);
  await rows.get(1)!.request.onToken(9);
  abort.abort(new Error("caller left mid-stream"));
  await expect(first).rejects.toThrow("caller left mid-stream");
  expect(gateway.activeRows).toBe(1); expect(gateway.busy).toBe(true);
  expect(firstGrammar.disposed).toBe(1); expect(secondGrammar.disposed).toBe(0); expect(f.samplingDisposed).toBe(1);
  await rows.get(2)!.request.onToken(10); rows.get(2)!.finish(); await second;
  expect(emitted).toEqual(["a7", "b8", "a9", "b10"]);
  expect(secondGrammar.disposed).toBe(1); expect(f.samplingDisposed).toBe(2);
  expect(gateway.activeRows).toBe(0); expect(gateway.pendingRows).toBe(0); expect(gateway.busy).toBe(false);
  await gateway.close(); expect(f.closed).toBe(true);
});

for (const failure of ["setup", "submit", "none"] as const) test(`request-owned media and grammar release after ${failure}`, async () => {
  let mediaDisposed = 0;
  const controller = grammar();
  const f = fake({ failSetup: failure === "setup", submit: async () => {
    expect(mediaDisposed).toBe(0); if (failure === "submit") throw new Error("submission failed"); return result;
  } });
  const gateway = new GenerationGateway(f.binding, 1); const s = { ...shape(), hasVision: true };
  const vision = { embeddings: { dispose() { mediaDisposed++; } } } as Vision;
  const run = gateway.run([1], { grammar: controller.value }, () => {}, vision, s, gateway.place(s));
  if (failure === "none") await run; else await expect(run).rejects.toThrow("failed");
  expect(mediaDisposed).toBe(1); expect(controller.disposed).toBe(1);
  expect(f.samplingDisposed).toBe(failure === "setup" ? 0 : 1); await gateway.close();
});

test("cancelled queued work frees its inputs without entering the group", async () => {
  const entered = Promise.withResolvers<void>(); const finish = Promise.withResolvers<void>(); let submitted = 0;
  const f = fake({ submit: async () => { submitted++; entered.resolve(); await finish.promise; return result; } });
  const gateway = new GenerationGateway(f.binding, 1); const firstShape = shape();
  const first = gateway.run([1], {}, () => {}, undefined, firstShape, gateway.place(firstShape));
  await entered.promise;
  const controller = grammar(); const abort = new AbortController(); const secondShape = shape();
  const second = gateway.run([1], { grammar: controller.value }, () => {}, undefined, secondShape, gateway.place(secondShape), abort.signal);
  abort.abort(new Error("caller left")); await expect(second).rejects.toThrow("caller left");
  expect(controller.disposed).toBe(1); expect(submitted).toBe(1);
  finish.resolve(); await first; await gateway.close();
});

test("a placement from another request cannot consume native input", async () => {
  const f = fake(); const gateway = new GenerationGateway(f.binding, 1); const controller = grammar();
  await expect(gateway.run([1], { grammar: controller.value }, () => {}, undefined, shape(), gateway.place(shape())))
    .rejects.toThrow("does not belong");
  expect(controller.disposed).toBe(1); expect(f.created).toBe(0); await gateway.close();
});

test("exclusive mutations share the scheduler lock and release aborted waiters", async () => {
  const f = fake(); const gateway = new GenerationGateway(f.binding, 1);
  const held = await gateway.acquireExecutionLease(); const abort = new AbortController();
  const waiter = gateway.acquireExecutionLease(abort.signal); abort.abort(new Error("cancel lease"));
  await expect(waiter).rejects.toThrow("cancel lease");
  expect(gateway.busy).toBe(true); held.dispose(); await gateway.onIdle();
  expect(gateway.busy).toBe(false); await gateway.close();
});


// Importing the real graph/binding loads MLX, even though placement creates no
// tensors. Keep this qualification check out of the native-blocked CPU suite.
test.skipIf(process.env.MLX_BUN_GEMMA2_NATIVE !== "1")("Gemma2 admits ordinary plain KV and rejects unqualified shared compositions before execution", async () => {
  const { UniversalDenseModel } = await import("@mlx-bun/inference/models/universal");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { KVCache } = await import("@mlx-bun/inference/state");
  const { KvScheme } = await import("@mlx-bun/inference/state/kv-scheme");
  const model = Object.assign(Object.create(UniversalDenseModel.prototype), {
    args: { modelType: "gemma2", maskArray: true, attnLogitSoftcap: 50, layerTypes: null },
    config: { modelType: "gemma2", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [new KVCache()], loraState: { active: [] },
  });
  const binding = bindMlxGateway(model);
  let created = false;
  binding.createBatchGroup = () => { created = true; throw new Error("unexpected execution"); };
  const gateway = new GenerationGateway(binding, 4);
  try {
    expect(gateway.place(shape())).toMatchObject({ mechanism: "continuous",
      execution: { method: "autoregressive", compiledDecode: false, fill: false, checkpoint: false } });
    for (const kind of ["affine-uniform", "affine-config", "turbo"] as const)
      expect(binding.kvBatchable(new KvScheme(kind, {}))).toBe(false);
    for (const request of [{ hasDraft: true }, { hasDraft: true, wantsLogprobs: true },
      { hasAdapters: true }, { hasGrammar: true }, { hasVision: true }, { kvQuant: true }, { turboQuant: true }])
      expect(() => gateway.place({ ...shape(), ...request })).toThrow(UnsupportedExecutionError);
    expect(() => gateway.place(shape(), { pagedKv: {} })).toThrow(UnsupportedExecutionError);
    expect(() => gateway.place(shape(), { fill: { plan: {} } } as GenerateOptions)).toThrow(UnsupportedExecutionError);
    // Even a caller advertising generic encoded support cannot qualify this graph.
    expect(binding.plan({ ...shape(), kvQuant: true }, { kvBits: 4 },
      { continuous: true, quantizedBatch: true, checkpoints: true }).mechanism).toBe("serial");
    model.args.layerTypes = ["sliding_attention"];
    expect(binding.cachesBatchable()).toBe(false);
    expect(created).toBe(false);
  } finally { await gateway.close(); }
});
