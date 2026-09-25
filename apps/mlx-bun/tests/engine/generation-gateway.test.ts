import { expect, test } from "bun:test";
import { GenerationGateway } from "../../src/engine/generation-gateway";
import type { RequestShape, Vision } from "../../src/engine/completion";
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

test("unsupported methods are reported rather than relabeled or run on a hidden lane", () => {
  const f = fake({ plan: () => ({ ...execution, method: "denoising", mechanism: "serial", reasons: ["method-requires-serial"] }) });
  const gateway = new GenerationGateway(f.binding, 1);
  expect(() => gateway.place(shape())).toThrow("model replacement method denoising does not support shared execution");
  expect(f.created).toBe(0);
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
