import { describe, expect, test } from "bun:test";
import { DenoisingKeys, denoiseAsync, denoiseSync, type DiffusionGenOptions } from "../../src/generation/diffusion";
import { denoisingRequestOptions, generateDenoising } from "../../src/generation/denoising";
import { bindLegacyDenoisingModel, type MlxDenoisingBinding } from "../../src/generation/bindings/denoising";
import type { GenerateOptions } from "../../src/generation/types";
import type { DenoisingGraph } from "../../src/contracts/portable/denoising";
import { MlxBatchExecutionGroup } from "../../src/execution/batch-group";
import type { BatchRequest, MlxBatchExecutionGroupOptions } from "../../src/execution/batch-types";
import { bindDenoisingGroupRequests } from "../../src/execution/denoising-group";
import { bindMlxGateway } from "../../src/execution/gateway-binding";
import { DiffusionGemmaModel } from "../../src/models/diffusion-gemma/model";
import type { RuntimeModel } from "../../src/models/factory";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, clearCache, synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

function fixture(onStep?: () => void) {
  const calls = { prefill: 0, steps: 0, closed: 0 };
  const graph: DenoisingGraph<MlxArray, { offset: number }> = {
    descriptor: { id: "independent-canvas", artifact: "fixture", backend: "mlx",
      graphAbi: "mlx-denoising-v1", stateAbi: "position-only-v1" },
    vocabSize: 4, canvasLength: 2, embedScale: 1,
    prefill(ids) { calls.prefill++; return { offset: ids.length }; },
    extendPrefill(ids, state) { state.offset += ids.shape[1]!; },
    decoderLogits(canvas, state) {
      calls.steps++; onStep?.();
      const data = new Float32Array(8);
      canvas.toIntTokens().forEach((id, i) => { data[i * 4 + (id + state.offset) % 4] = 1; });
      return MlxArray.fromFloat32(data, [1, 2, 4]);
    },
    dequantEmbedWeight: () => MlxArray.fromFloat32(new Float32Array([0, 1, 2, 3]), [4, 1]),
    softEmbeddings(logits, weight) {
      const probabilities = ops.softmaxAxis(logits, -1, true);
      try { return ops.matmul(probabilities, weight); }
      finally { probabilities.dispose(); }
    },
    closeState() { calls.closed++; },
  };
  return { graph, calls };
}

const options: DiffusionGenOptions = { maxTokens: 5, maxDenoisingSteps: 3,
  minCanvasLength: 2, eosTokenIds: [], seed: 0n };

test("sync and cooperative denoising preserve RNG-dependent canvases across blocks and samplers", async () => {
  const results = new Set<string>();
  for (const sampler of ["confidence-threshold", "entropy-bound"] as const) {
    for (const seed of [0n, 7n]) {
      const sync = fixture(); const async = fixture();
      const opts = { ...options, sampler, seed };
      const expected = denoiseSync(sync.graph, [1], opts);
      const actual = await denoiseAsync(async.graph, [1], opts);
      expect(actual).toEqual(expected);
      expect(actual.blocks).toHaveLength(3);
      expect(actual.steps).toBeGreaterThan(1);
      expect(sync.calls.closed).toBe(1); expect(async.calls.closed).toBe(1);
      results.add(JSON.stringify(actual.blocks));
    }
  }
  expect(results.size).toBeGreaterThan(1);
});

test("cancellation between denoising steps releases canvas and feedback without completing another step", async () => {
  const cancelRun = async () => {
    const abort = new AbortController();
    const f = fixture(() => setImmediate(() => abort.abort(new DOMException("cancelled", "AbortError"))));
    await expect(denoiseAsync(f.graph, [1], options, abort.signal)).rejects.toHaveProperty("name", "AbortError");
    expect(f.calls).toEqual({ prefill: 1, steps: 1, closed: 1 });
  };
  await cancelRun(); synchronize(gpuStream); clearCache();
  const baseline = activeMemory();
  for (let i = 0; i < 10; i++) await cancelRun();
  synchronize(gpuStream); clearCache();
  expect(activeMemory()).toBeLessThanOrEqual(baseline);
});

test("pre-cancelled and incompatible denoising requests allocate no state", async () => {
  const f = fixture();
  const abort = new AbortController(); abort.abort();
  await expect(denoiseAsync(f.graph, [1], options, abort.signal)).rejects.toHaveProperty("name", "AbortError");
  expect(() => denoiseSync({ ...f.graph, descriptor: { ...f.graph.descriptor, backend: "other" } }, [1], options))
    .toThrow("incompatible backend");
  expect(f.calls.prefill).toBe(0);
});

test("embedding preparation failure closes already-created graph state", () => {
  const f = fixture();
  expect(() => denoiseSync({ ...f.graph, dequantEmbedWeight() { throw new Error("embedding failed"); } }, [1], options))
    .toThrow("embedding failed");
  expect(f.calls.closed).toBe(1);
});

test("request-local keys draw byte-identically to the reseeded global key sequence", () => {
  const shapes = [[1, 2], [1, 7], [3, 5]], highs = [4, 262144];
  for (const seed of [0n, 1n, 7n, 0x7fffffffn, (1n << 40n) + 5n]) {
    ops.randomSeed(seed);
    const global = Array.from({ length: 60 }, (_, draw) => {
      using ids = ops.randint(0, highs[draw % 2]!, shapes[draw % 3]!, Dtype.int32);
      return { shape: ids.shape, dtype: ids.dtype, ids: ids.toIntTokens() };
    });
    const keys = new DenoisingKeys(seed);
    try {
      for (const [draw, expected] of global.entries()) {
        using ids = keys.randint(highs[draw % 2]!, shapes[draw % 3]!);
        expect({ shape: ids.shape, dtype: ids.dtype, ids: ids.toIntTokens() }).toEqual(expected);
      }
    } finally { keys.dispose(); }
  }
});

describe("interleaved shared denoising", () => {
  // Emitted ids avoid the served stopping set {1, 106}, so rows run to their limit.
  const EMITTED = [0, 2, 3];
  type RowState = { offset: number; prompt: string; steps: number };
  interface Hooks { onStep?(prompt: string, step: number): void; fail?(prompt: string, step: number): boolean }

  function interleaved(hooks: Hooks = {}) {
    const adapters = { active: [] as string[] };
    const events: string[] = [];
    const tables: MlxArray[] = [];
    const graph: DenoisingGraph<MlxArray, RowState> = {
      descriptor: { id: "interleaved-canvas", artifact: "fixture", backend: "mlx",
        graphAbi: "mlx-denoising-v1", stateAbi: "position-only-v1" },
      vocabSize: 4, canvasLength: 2, embedScale: 1,
      prefill(ids) {
        const prompt = ids.join(",");
        events.push(`prefill:${prompt}:${adapters.active.join("+")}`);
        return { offset: ids.length, prompt, steps: 0 };
      },
      extendPrefill(ids, state) { state.offset += ids.shape[1]!; },
      decoderLogits(canvas, state) {
        const step = ++state.steps;
        events.push(`step:${state.prompt}:${adapters.active.join("+")}`);
        hooks.onStep?.(state.prompt, step);
        if (hooks.fail?.(state.prompt, step)) throw new Error(`graph failed for ${state.prompt}`);
        // Mounted adapters change the graph built during this unit.
        const shift = adapters.active.reduce((sum, id) => sum + id.length, 0);
        const data = new Float32Array(8);
        canvas.toIntTokens().forEach((id, i) => { data[i * 4 + EMITTED[(id + state.offset + shift) % 3]!] = 1; });
        return MlxArray.fromFloat32(data, [1, 2, 4]);
      },
      dequantEmbedWeight() {
        const table = MlxArray.fromFloat32(new Float32Array([0, 1, 2, 3]), [4, 1]);
        const release = table.dispose.bind(table);
        let released = false;
        table.dispose = () => {
          if (!released) events.push("table-released");
          released = true; release();
        };
        tables.push(table);
        return table;
      },
      softEmbeddings(logits, weight) {
        const probabilities = ops.softmaxAxis(logits, -1, true);
        try { return ops.matmul(probabilities, weight); }
        finally { probabilities.dispose(); }
      },
      closeState(state) { events.push(`close:${state.prompt}`); },
    };
    const binding: MlxDenoisingBinding<RowState> = { graph, adapters, memory: { weightsBytes: 0 } };
    return { graph, binding, adapters, events, tables };
  }

  const groupModel = { config: { modelType: "diffusion_gemma", text: { enableMoeBlock: false }, eosTokenIds: [] },
    makeCache: () => [], weightsBytes: 0 } as unknown as RuntimeModel;

  type Fixture = ReturnType<typeof interleaved>;
  type RowOptions = Pick<BatchRequest, "signal" | "onAdmitted"> & { onToken?: (token: number) => unknown };

  function scheduler(fixture: Fixture, options: Partial<MlxBatchExecutionGroupOptions> = {},
    policy?: (options: GenerateOptions) => DiffusionGenOptions) {
    const method = bindDenoisingGroupRequests(fixture.binding, policy);
    const group = new MlxBatchExecutionGroup(groupModel, { maxBatch: 4, ...options });
    // maxTokens/eosTokenIds are the gateway's AR row defaults; denoising must ignore them.
    const submit = (prompt: number[], request: GenerateOptions, row: RowOptions = {}) => {
      const tokens: number[] = [];
      const stats = group.submit({ promptIds: prompt, maxTokens: 512, eosTokenIds: [0, 2, 3], method: method(request),
        signal: row.signal, onAdmitted: row.onAdmitted,
        async onToken(token) {
          tokens.push(token);
          fixture.events.push(`token:${prompt.join(",")}`);
          return (await row.onToken?.(token)) as void | boolean;
        } });
      return { tokens, stats };
    };
    return { group, submit };
  }

  /** Main's serial request path, including its request-lifetime adapter scope. */
  async function solo(prompt: number[], request: GenerateOptions): Promise<number[]> {
    const tokens: number[] = [];
    for await (const item of generateDenoising(interleaved().binding, prompt, request)) tokens.push(item.token);
    return tokens;
  }

  const steps = (events: string[], prompt: string) =>
    events.flatMap((event, index) => event.startsWith(`step:${prompt}:`) ? [index] : []);
  const released = (table: MlxArray) => expect(() => table.handle).toThrow("used after dispose");
  const settle = () => { synchronize(gpuStream); clearCache(); return activeMemory(); };

  test("one grouped row reproduces denoiseSync and denoiseAsync for both samplers across blocks", async () => {
    for (const sampler of ["confidence-threshold", "entropy-bound"] as const) {
      const policy = (options: GenerateOptions): DiffusionGenOptions => ({ ...denoisingRequestOptions(options), sampler });
      for (const seed of [0, 7]) {
        const request = { seed, maxTokens: 5 };
        const expected = denoiseSync(interleaved().graph, [1], policy(request));
        expect(await denoiseAsync(interleaved().graph, [1], policy(request))).toEqual(expected);
        expect(expected.blocks).toHaveLength(3);
        const f = interleaved();
        const { group, submit } = scheduler(f, {}, policy);
        try {
          const row = submit([1], request);
          expect(await row.stats).toMatchObject({ generatedTokens: 5, finishReason: "length", prefillMs: 0 });
          expect(row.tokens).toEqual(expected.tokens);
          expect(steps(f.events, "1")).toHaveLength(expected.steps);
          expect(f.events.at(-1)).toBe("table-released");
        } finally { await group.close(); }
      }
    }
  });

  test("B2/B4 rows with different seeds, prompts and limits each reproduce their solo run", async () => {
    const rows: [number[], GenerateOptions][] = [[[1], { seed: 3, maxTokens: 5 }], [[2, 3], { seed: 11, maxTokens: 3 }],
      [[4], { seed: 3, maxTokens: 7 }], [[1, 1, 1], { seed: 99, maxTokens: 4 }]];
    for (const count of [2, 4]) {
      // A foreign reseed of the process-wide key inside every unit cannot move any row.
      const f = interleaved({ onStep: (_prompt, step) => ops.randomSeed(1000n + BigInt(step)) });
      const { group, submit } = scheduler(f, { maxBatch: count });
      try {
        const running = rows.slice(0, count).map(([prompt, request]) => submit(prompt, request));
        await Promise.all(running.map(row => row.stats));
        for (const [index, [prompt, request]] of rows.slice(0, count).entries()) {
          expect(running[index]!.tokens).toEqual(await solo(prompt, request));
          const key = prompt.join(",");
          // Only the finished result is published: no token precedes the row's last unit.
          expect(f.events.indexOf(`token:${key}`)).toBeGreaterThan(steps(f.events, key).at(-1)!);
        }
        // Units alternate between rows instead of draining one request.
        expect(steps(f.events, "2,3")[0]!).toBeLessThan(steps(f.events, "1").at(-1)!);
        expect(f.tables).toHaveLength(1);
        released(f.tables[0]!);
      } finally { await group.close(); }
    }
  });

  test("a late joiner and the survivors of a cancelled row reproduce their solo runs", async () => {
    const run = async () => {
      const abort = new AbortController();
      let late: ReturnType<ReturnType<typeof scheduler>["submit"]> | undefined;
      let submitLate = () => {};
      const f = interleaved({ onStep(prompt, step) {
        if (prompt === "1" && step === 2) submitLate();
        if (prompt === "2,3" && step === 3) abort.abort(new DOMException("client left", "AbortError"));
      } });
      const { group, submit } = scheduler(f);
      submitLate = () => { late = submit([5], { seed: 5, maxTokens: 4 }); submitLate = () => {}; };
      try {
        const first = submit([1], { seed: 1, maxTokens: 6 });
        const cancelled = submit([2, 3], { seed: 2, maxTokens: 6 }, { signal: abort.signal });
        await expect(cancelled.stats).rejects.toHaveProperty("name", "AbortError");
        await first.stats; await late!.stats;
        expect(first.tokens).toEqual(await solo([1], { seed: 1, maxTokens: 6 }));
        expect(late!.tokens).toEqual(await solo([5], { seed: 5, maxTokens: 4 }));
        expect(cancelled.tokens).toEqual([]);
        // The cancelled run closed at its next boundary and ran no further unit.
        const closed = f.events.indexOf("close:2,3");
        expect(closed).toBeGreaterThan(steps(f.events, "2,3").at(-1)!);
        expect(steps(f.events, "5")[0]!).toBeLessThan(steps(f.events, "1").at(-1)!);
        // One table served every overlapping row and was released after the last run closed.
        expect(f.tables).toHaveLength(1);
        expect(f.events.at(-1)).toBe("table-released");
        released(f.tables[0]!);
      } finally { await group.close(); }
    };
    await run(); const baseline = settle();
    for (let i = 0; i < 3; i++) await run();
    expect(settle()).toBeLessThanOrEqual(baseline);
  });

  test("cancellation closes a row's run before the last row releases the shared table", async () => {
    // Active: the run's cleanup (close) precedes the table release.
    const abort = new AbortController();
    const f = interleaved({ onStep: (_prompt, step) => { if (step === 2) abort.abort(new DOMException("gone", "AbortError")); } });
    const { group, submit } = scheduler(f);
    try {
      await expect(submit([1], { seed: 1, maxTokens: 6 }, { signal: abort.signal }).stats).rejects.toHaveProperty("name", "AbortError");
      expect(f.events.slice(-2)).toEqual(["close:1", "table-released"]);
      released(f.tables[0]!);
    } finally { await group.close(); }
    // Preparing: cancelled after admission, before its first unit ran.
    const preparing = new AbortController();
    const g = interleaved();
    const second = scheduler(g);
    try {
      const row = second.submit([2], { seed: 2, maxTokens: 4 }, { signal: preparing.signal,
        onAdmitted: () => preparing.abort(new DOMException("gone", "AbortError")) });
      await expect(row.stats).rejects.toHaveProperty("name", "AbortError");
      expect(g.events).toEqual(["table-released"]);
      released(g.tables[0]!);
    } finally { await second.group.close(); }
  });

  test("a graph failure rejects only its row", async () => {
    const f = interleaved({ fail: (prompt, step) => prompt === "2,3" && step === 2 });
    const { group, submit } = scheduler(f);
    try {
      const ok = submit([1], { seed: 1, maxTokens: 5 });
      const failed = submit([2, 3], { seed: 2, maxTokens: 5 });
      await expect(failed.stats).rejects.toThrow("graph failed for 2,3");
      await ok.stats;
      expect(ok.tokens).toEqual(await solo([1], { seed: 1, maxTokens: 5 }));
      expect(f.events).toContain("close:2,3");
      expect(f.events.at(-1)).toBe("table-released");
    } finally { await group.close(); }
  });

  test("a stopping output callback ends the row after the delivered token", async () => {
    const f = interleaved();
    const { group, submit } = scheduler(f);
    try {
      const row = submit([1], { seed: 1, maxTokens: 6 }, { onToken: () => false });
      expect(await row.stats).toMatchObject({ generatedTokens: 1, finishReason: "stop" });
      expect(row.tokens).toEqual((await solo([1], { seed: 1, maxTokens: 6 })).slice(0, 1));
      expect(f.events.at(-1)).toBe("table-released");
    } finally { await group.close(); }
  });

  test("closing the group mid-run rejects rows and releases every run and the table", async () => {
    const run = async () => {
      let closing: Promise<void> | undefined;
      let close = () => {};
      const f = interleaved({ onStep: (prompt, step) => { if (prompt === "1" && step === 2) close(); } });
      const { group, submit } = scheduler(f);
      close = () => { closing ??= group.close(); };
      const rows = [submit([1], { seed: 1, maxTokens: 8 }), submit([2, 3], { seed: 2, maxTokens: 8 })];
      const outcomes = await Promise.all(rows.map(row => row.stats.then(() => null, (error: Error) => error.message)));
      expect(outcomes).toEqual(["scheduler closed", "scheduler closed"]);
      await closing;
      expect(f.events).toContain("close:1");
      expect(f.events).toContain("close:2,3");
      expect(f.events.at(-1)).toBe("table-released");
    };
    await run(); const baseline = settle();
    for (let i = 0; i < 3; i++) await run();
    expect(settle()).toBeLessThanOrEqual(baseline);
  });

  test("an exclusive lease waits for active rows and held admission defers new rows", async () => {
    let tail = Promise.resolve();
    const lock = { acquire(): Promise<() => void> {
      let release!: () => void;
      const gate = new Promise<void>(resolve => { release = resolve; });
      const wait = tail; tail = tail.then(() => gate);
      return wait.then(() => release);
    } };
    let held = false;
    let lease: Promise<() => void> | undefined;
    let deferred: ReturnType<ReturnType<typeof scheduler>["submit"]> | undefined;
    let onFirstUnit = () => {};
    const f = interleaved({ onStep: (prompt, step) => { if (prompt === "1" && step === 1) onFirstUnit(); } });
    const { group, submit } = scheduler(f, { lock, admissionHeld: () => held });
    onFirstUnit = () => {
      held = true;
      deferred = submit([2], { seed: 2, maxTokens: 2 });
      lease = lock.acquire().then(release => { f.events.push("lease"); return release; });
      onFirstUnit = () => {};
    };
    try {
      const first = submit([1], { seed: 1, maxTokens: 4 });
      await first.stats;
      const release = await lease!;
      expect(f.events.indexOf("lease")).toBeGreaterThan(f.events.lastIndexOf("token:1"));
      expect(f.events.some(event => event.startsWith("prefill:2"))).toBe(false);
      held = false; release(); group.kick();
      await deferred!.stats;
      expect(f.events.indexOf("prefill:2:")).toBeGreaterThan(f.events.indexOf("lease"));
      expect(deferred!.tokens).toEqual(await solo([2], { seed: 2, maxTokens: 2 }));
    } finally { await group.close(); }
  });

  test("differently adapted rows interleave with only their own adapters active", async () => {
    const requests: [number[], GenerateOptions][] = [[[1], { seed: 4, maxTokens: 5, adapters: ["upper"] }],
      [[2, 3], { seed: 4, maxTokens: 5, adapters: ["lower-case"] }], [[6], { seed: 9, maxTokens: 3 }]];
    for (const cancel of [false, true]) {
      const abort = new AbortController();
      const f = interleaved({ onStep: (prompt, step) => {
        if (cancel && prompt === "2,3" && step === 3) abort.abort(new DOMException("gone", "AbortError"));
      } });
      const { group, submit } = scheduler(f);
      try {
        const rows = requests.map(([prompt, request], index) => submit(prompt, request, index === 1 ? { signal: abort.signal } : {}));
        if (cancel) await expect(rows[1]!.stats).rejects.toHaveProperty("name", "AbortError");
        for (const [index, row] of rows.entries()) if (!cancel || index !== 1) await row.stats;
        for (const [index, [prompt, request]] of requests.entries()) {
          if (cancel && index === 1) continue;
          expect(rows[index]!.tokens).toEqual(await solo(prompt, request));
        }
        // Each unit built its graph under exactly its row's adapters; none leaked outside units.
        const expected = new Map(requests.map(([prompt, request]) => [prompt.join(","), (request.adapters ?? []).join("+")]));
        for (const event of f.events.filter(entry => entry.startsWith("step:") || entry.startsWith("prefill:"))) {
          const [, prompt, active] = event.split(":");
          expect(active).toBe(expected.get(prompt!)!);
        }
        expect(f.adapters.active).toEqual([]);
        expect(steps(f.events, "2,3")[0]!).toBeLessThan(steps(f.events, "1").at(-1)!);
      } finally { await group.close(); }
    }
    // The fixture's adapters really change the trajectory.
    expect(await solo([1], { seed: 4, maxTokens: 5, adapters: ["upper"] })).not.toEqual(await solo([1], { seed: 4, maxTokens: 5 }));
  });

  test("decode time covers the computation and excludes output delivery", async () => {
    const f = interleaved();
    const { group, submit } = scheduler(f);
    try {
      let first = 0;
      const started = performance.now();
      const row = submit([1], { seed: 1, maxTokens: 4 }, { onToken: async () => {
        first ||= performance.now();
        await Bun.sleep(40);
      } });
      const stats = await row.stats;
      const finished = performance.now();
      expect(stats.prefillMs).toBe(0);
      expect(stats.decodeMs).toBeGreaterThan(0);
      expect(stats.decodeMs).toBeLessThanOrEqual(first - started);
      expect(finished - started - stats.decodeMs).toBeGreaterThanOrEqual(4 * 40 - 1);
    } finally { await group.close(); }
  });

  test("the request's EOS union and limit apply, never the row's autoregressive defaults", async () => {
    expect(denoisingRequestOptions({})).toMatchObject({ maxTokens: 256, eosTokenIds: [1, 106],
      sampler: "confidence-threshold", temperature: 0 });
    expect(denoisingRequestOptions({ seed: 5, maxTokens: 9, eosTokenIds: [7, 1] }))
      .toMatchObject({ seed: 5n, maxTokens: 9, eosTokenIds: [1, 106, 7] });
    const f = interleaved();
    const { group, submit } = scheduler(f);
    try {
      // The row carries maxTokens 512 and EOS {0, 2, 3}; the request sets neither.
      const row = submit([1], { seed: 2 });
      expect(await row.stats).toMatchObject({ generatedTokens: 256, finishReason: "length" });
      expect(row.tokens).toEqual(await solo([1], { seed: 2 }));
      expect(new Set(row.tokens)).toEqual(new Set(EMITTED));
    } finally { await group.close(); }
  });

  test("the DiffusionGemma gateway binding places and runs rows through the shared group", async () => {
    const f = interleaved();
    const model = Object.assign(Object.create(DiffusionGemmaModel.prototype), {
      config: { modelType: "diffusion_gemma", text: { vocabSize: 4, enableMoeBlock: false }, eosTokenIds: [] },
      canvasLength: 2, embedScale: 1, loraState: f.adapters, weightsBytes: 0, makeCache: () => [],
      // The legacy binding closes an array of disposable caches.
      prefill: (ids: number[]) => {
        const state = f.graph.prefill(ids);
        return Object.assign([{ dispose: () => f.graph.closeState(state) }], state);
      },
      extendPrefill: f.graph.extendPrefill, decoderLogits: f.graph.decoderLogits,
      dequantEmbedWeight: f.graph.dequantEmbedWeight, softEmbeddings: f.graph.softEmbeddings,
    }) as DiffusionGemmaModel;
    const binding = bindMlxGateway(model);
    const shape = { hasVision: false, hasAdapters: true, hasRepetitionPenalty: false, userSeed: true, kvQuant: false,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: false };
    const execution = binding.plan(shape, {}, { continuous: binding.cachesBatchable(), quantizedBatch: false, checkpoints: false });
    expect(execution).toMatchObject({ method: "denoising", mechanism: "continuous", promptCache: false });
    const group = binding.createBatchGroup({ maxBatch: 2 });
    try {
      const requests: [number[], GenerateOptions][] = [[[1], { seed: 3, maxTokens: 5, adapters: ["upper"] }], [[2, 3], { seed: 8, maxTokens: 4 }]];
      const rows = requests.map(([prompt, request]) => {
        const tokens: number[] = [];
        const context = request.adapters ? binding.bindAdapterContext!(request.adapters, "adapters") : undefined;
        return { tokens, stats: group.submit({ promptIds: prompt, maxTokens: 512, eosTokenIds: [], context,
          method: binding.methodRequest!(execution, request)!, onToken: token => { tokens.push(token); } }) };
      });
      await Promise.all(rows.map(row => row.stats));
      const reference = bindLegacyDenoisingModel(model);
      for (const [index, [prompt, request]] of requests.entries()) {
        const expected: number[] = [];
        for await (const item of generateDenoising(reference, prompt, request)) expected.push(item.token);
        expect(rows[index]!.tokens).toEqual(expected);
      }
      expect(model.loraState.active).toEqual([]);
    } finally { await group.close(); }
  });
});

// Opt-in real-weight check. MLX_BUN_DIFFUSION_MODEL names a cached DiffusionGemma
// snapshot; MLX_BUN_DIFFUSION_REFERENCE optionally lists comma-separated
// trajectories in main's goldens/diffusion/gen*.json format.
const diffusionModel = process.env.MLX_BUN_DIFFUSION_MODEL;
const diffusionReferences = process.env.MLX_BUN_DIFFUSION_REFERENCE?.split(",").filter(Boolean) ?? [];
test.skipIf(!diffusionModel)("real DiffusionGemma rows reproduce solo runs and main's reference trajectories", async () => {
  const { Weights, loadModelConfig, createModel } = await import("../../src/index");
  const weights = await Weights.open(diffusionModel!);
  try {
    const config = await loadModelConfig(diffusionModel!);
    const model = createModel(weights, config) as DiffusionGemmaModel;
    const binding = bindLegacyDenoisingModel(model);
    const run = async (rows: { prompt: number[]; options: DiffusionGenOptions; cancelAtStep?: number; joinAfter?: number }[]) => {
      const states = new Map<unknown, number>(), stepsByRow = new Map<number, number>();
      const aborts = rows.map(() => new AbortController());
      let joinLate = () => {};
      const graph: typeof binding.graph = { ...binding.graph,
        prefill(ids, vision) { const state = binding.graph.prefill(ids, vision); states.set(state, rows.findIndex(row => row.prompt === ids)); return state; },
        decoderLogits(canvas, state, feedback) {
          const index = states.get(state)!, step = (stepsByRow.get(index) ?? 0) + 1;
          stepsByRow.set(index, step);
          if (rows[index]!.cancelAtStep === step) aborts[index]!.abort(new DOMException("client left", "AbortError"));
          if (rows.some(row => row.joinAfter === step) && index === 0) joinLate();
          return binding.graph.decoderLogits(canvas, state, feedback);
        } };
      const method = bindDenoisingGroupRequests({ ...binding, graph }, options => rows.find(row => row.options.seed === BigInt(options.seed!))!.options);
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 4 });
      const outputs = rows.map(() => [] as number[]);
      // One outcome per row, by row index: "done" or the rejection itself.
      const outcomes: Promise<unknown>[] = [];
      const submit = (index: number) => {
        outcomes[index] = group.submit({ promptIds: rows[index]!.prompt, maxTokens: 512, eosTokenIds: [],
          method: method({ seed: Number(rows[index]!.options.seed) }), signal: aborts[index]!.signal,
          onToken: token => { outputs[index]!.push(token); } }).then(() => "done", (error: unknown) => error);
      };
      try {
        rows.forEach((row, index) => { if (row.joinAfter === undefined) submit(index); });
        const late = rows.findIndex(row => row.joinAfter !== undefined);
        if (late >= 0) {
          const joined = Promise.withResolvers<void>();
          joinLate = () => { joinLate = () => {}; submit(late); joined.resolve(); };
          // If the first row ends before the join step, the late row still joins.
          void outcomes[0]!.then(() => joinLate());
          await joined.promise;
        }
        return { outputs, outcomes: await Promise.all(outcomes) };
      } finally { await group.close(); }
    };
    const expectAborted = (outcome: unknown) => {
      expect(outcome).toBeInstanceOf(DOMException);
      expect((outcome as DOMException).name).toBe("AbortError");
    };
    for (const path of diffusionReferences) {
      const reference = await Bun.file(path).json();
      const options: DiffusionGenOptions = { maxTokens: reference.max_tokens, maxDenoisingSteps: reference.max_denoising_steps,
        sampler: reference.sampler, threshold: reference.threshold, entropyBound: reference.entropy_bound, temperature: 0,
        tMin: reference.t_min, tMax: reference.t_max, eosTokenIds: reference.eos_token_id, seed: BigInt(reference.seed) };
      const direct = denoiseSync(binding.graph, reference.prompt_ids, options);
      expect({ tokens: direct.tokens, steps: direct.steps, finishReason: direct.finishReason })
        .toEqual({ tokens: reference.tokens, steps: reference.total_steps, finishReason: reference.finish_reason });
      const grouped = await run([{ prompt: reference.prompt_ids, options }]);
      expect(grouped.outcomes).toEqual(["done"]);
      expect(grouped.outputs[0]).toEqual(reference.tokens);
    }
    const prompt = diffusionReferences.length ? (await Bun.file(diffusionReferences[0]!).json()).prompt_ids as number[]
      : [2, 105, 2364, 107, 6974, 496, 678, 20517, 1003, 9947, 56125, 236761, 106, 107, 105, 4368, 107];
    const served = (seed: number, maxTokens: number) => denoisingRequestOptions({ seed, maxTokens });
    for (const count of [2, 4]) {
      // Distinct arrays identify each row's prefill; seeds select each row's options.
      // Step 1 always runs, so the cancellation and the late join always happen.
      const rows = [{ prompt: [...prompt], options: served(0, 64) }, { prompt: prompt.slice(0, -2), options: served(1, 32) },
        { prompt: [...prompt], options: served(2, 48), cancelAtStep: 1 },
        { prompt: prompt.slice(0, -4), options: served(3, 16), joinAfter: 1 }].slice(0, count);
      const { outputs, outcomes } = await run(rows);
      expect(outcomes).toHaveLength(rows.length);
      for (const [index, row] of rows.entries()) {
        if (row.cancelAtStep !== undefined) { expectAborted(outcomes[index]); continue; }
        expect(outcomes[index]).toBe("done");
        expect(outputs[index]).toEqual(denoiseSync(binding.graph, row.prompt, row.options).tokens);
      }
    }
  } finally { weights.dispose(); }
}, 1_800_000);
