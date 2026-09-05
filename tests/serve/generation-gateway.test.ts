// FAST: the --batch N scheduling declaration (GenerationGateway.place) — no
// model load. Placement is pure over the configured concurrency cap, cache
// capability, and RequestShape; the only model surface it touches is
// makeCache() (fresh caches hold no buffers), so a stub stands in. Scheduler
// numerics are gated separately in tests/batch-scheduler.test.ts.

import { describe, expect, test } from "bun:test";
import { GenerationGateway, type RequestShape } from "../../src/serve/generation-gateway";
import { KVCache, RotatingKVCache } from "../../src/model/gemma4-base";
import { SSMCache } from "../../src/model/qwen3-delta";
import type { RuntimeModel } from "../../src/model/factory";
import { resolveKvScheme } from "../../src/kv-scheme";
import { configureRuntime } from "../../src/runtime-config";
import { createLegacyInferenceEngine } from "../../src/backends/mlx/legacy-engine";

// place() reads only makeCache() off the model (the capability gate) and never
// the serialRun, so stubs are safe. The default stub models a
// full-attention model (all-KVCache — batch-capable).
const stubModel = {
  makeCache: () => [new KVCache()],
  config: { text: { numHiddenLayers: 1, layerTypes: ["full_attention"] } },
} as unknown as RuntimeModel;
const stubSerial = (async () => ({}) as never) as never;
const gateway = (batch: number) => new GenerationGateway(stubModel, batch, stubSerial);
const usesContinuous = (g: GenerationGateway, shape: RequestShape): boolean =>
  g.place(shape).mechanism === "continuous";
/** N-layer all-full-attention stub (Phase 3.1 kv-batchability probes). */
const fullModel = (n: number) =>
  ({
    makeCache: () => Array.from({ length: n }, () => new KVCache()),
    config: {
      text: { numHiddenLayers: n, layerTypes: Array.from({ length: n }, () => "full_attention") },
    },
  }) as unknown as RuntimeModel;
/** Layer 0 rotating, layer 1 full — a config naming layer 0 must stay serial. */
const mixedModel = () =>
  ({
    makeCache: () => [new RotatingKVCache(1024), new KVCache()],
    config: {
      text: { numHiddenLayers: 2, layerTypes: ["sliding_attention", "full_attention"] },
    },
  }) as unknown as RuntimeModel;
const serialRunStub = stubSerial;

// The all-clear shape: nothing that would force the serial lane.
const batchable: RequestShape = {
  hasVision: false,
  hasAdapters: false,
  hasRepetitionPenalty: false,
  hasLogitsExtras: false,
  wantsLogprobs: false,
  userSeed: false,
  kvQuant: false,
  turboQuant: false,
  hasGrammar: false,
  hasDraft: false,
};

describe("GenerationGateway.place", () => {
  test("a binding keeps its runtime snapshot while later bindings see new flags", () => {
    const restoreInitial = configureRuntime({ MLX_BUN_GRAMMAR_BATCH: "1" });
    try {
      const original = gateway(2);
      const restoreChanged = configureRuntime({ MLX_BUN_GRAMMAR_BATCH: "0" });
      try {
        const shape = { ...batchable, hasGrammar: true };
        expect(original.place(shape).mechanism).toBe("continuous");
        expect(gateway(2).place(shape).mechanism).toBe("serial");
      } finally { restoreChanged(); }
    } finally { restoreInitial(); }
  });

  test("the serial callback receives the exact plan, including draft fallback", async () => {
    let seen: unknown;
    const g = new GenerationGateway(stubModel, 1, async (_ids, _options, _sink, _vision, _trace, execution) => {
      seen = execution;
      return {} as never;
    });
    const shape = { ...batchable, hasDraft: true, wantsLogprobs: true };
    const placement = g.place(shape, { logprobs: true });
    await g.run([1], { logprobs: true }, () => {}, undefined, shape, placement);
    expect(seen).toBe(placement.execution);
    expect(placement.execution?.method).toBe("autoregressive");
  });
  test("place freezes one shape and declares its scheduling mechanism", () => {
    const g = gateway(2);
    const shape = { ...batchable };
    const placement = g.place(shape);
    expect(placement).toMatchObject({ shape, mechanism: "continuous", execution: { method: "autoregressive" } });
    expect(placement.shape).toBe(shape);
    expect(Object.isFrozen(placement)).toBe(true);
    expect(Object.isFrozen(placement.shape)).toBe(true);
    expect(() => Object.assign(shape, { hasVision: true })).toThrow();
    expect(placement.mechanism).toBe("continuous");
  });

  test("--batch 1 declares the preserved strict-serial mechanism", () => {
    const placement = gateway(1).place(batchable);
    expect(placement).toMatchObject({ shape: batchable, mechanism: "serial", execution: { method: "autoregressive" } });
  });

  test("--batch 1 never batches (serial mode), regardless of shape", () => {
    const g = gateway(1);
    expect(g.batchingEnabled).toBe(false);
    expect(usesContinuous(g, batchable)).toBe(false);
  });

  test("--batch 0 / negative clamps to serial", () => {
    expect(gateway(0).batchingEnabled).toBe(false);
    expect(gateway(-3).batchingEnabled).toBe(false);
  });

  test("--batch N (N>1) batches the all-clear shape", () => {
    const g = gateway(2);
    expect(g.batchingEnabled).toBe(true);
    expect(usesContinuous(g, batchable)).toBe(true);
  });

  test("idle gateway reports zero active rows (no scheduler created)", () => {
    expect(gateway(4).activeRows).toBe(0);
  });

  // Each disqualifier individually forces the serial lane.
  const disqualifiers: Array<[keyof RequestShape, string]> = [
    ["hasVision", "vision (offset-0 single-seq prefill + image mask)"],
    ["hasAdapters", "LoRA adapter (single per-generation loraState)"],
    ["wantsLogprobs", "logprobs/top_logprobs capture (serial-only, batch-lane deferred)"],
    ["userSeed", "explicit seed (reproducibility ⇒ solo)"],
    ["kvQuant", "kv-quant with NO scheme threaded (would silently drop the quantization)"],
    ["turboQuant", "TurboQuant is solo-only in v1, unconditionally (docs/design/turboquant.md)"],
  ];
  for (const [flag, why] of disqualifiers) {
    test(`${flag} drains to serial — ${why}`, () => {
      expect(usesContinuous(gateway(2), { ...batchable, [flag]: true })).toBe(false);
    });
  }

  // Phase 3.1 + milestone 2: a kv-quant request BATCHES when the gateway
  // carries a batchable scheme — a per-layer kvConfig whose every configured
  // layer is a full-attention KVCache (3.1) or rotating RotatingKVCache
  // (milestone 2: BatchedRotatingQuantCache — gemma's kv_config). Uniform
  // kvBits stays serial (quantizedKvStart threshold semantics).
  test("kvQuant BATCHES with an all-full-attention kvConfig scheme", () => {
    const g = new GenerationGateway(fullModel(4), 2, serialRunStub, {
      kvScheme: resolveKvScheme({
        override: "config",
        config: [0, 1, 2, 3].map((layerIdx) => ({ layerIdx, bits: 4, groupSize: 64 })),
      }),
    });
    expect(usesContinuous(g, { ...batchable, kvQuant: true })).toBe(true);
  });
  test("kvQuant stays serial for uniform kvBits", () => {
    const g = new GenerationGateway(fullModel(4), 2, serialRunStub, {
      kvScheme: resolveKvScheme({ override: 8 }),
    });
    expect(usesContinuous(g, { ...batchable, kvQuant: true })).toBe(false);
  });
  test("kvQuant BATCHES when the config names a rotating layer (milestone 2)", () => {
    const g = new GenerationGateway(mixedModel(), 2, serialRunStub, {
      kvScheme: resolveKvScheme({
        override: "config",
        config: [{ layerIdx: 0, bits: 4, groupSize: 64 }],
      }),
    });
    expect(usesContinuous(g, { ...batchable, kvQuant: true })).toBe(true);
  });

  test("kvQuant stays serial when a configured layer lacks KV conversion capability", () => {
    const nonConvertible = {
      makeCache: () => [new SSMCache()],
      config: {
        modelType: "stub",
        text: { numHiddenLayers: 1, layerTypes: ["full_attention"] },
      },
    } as unknown as RuntimeModel;
    const g = new GenerationGateway(nonConvertible, 2, serialRunStub, {
      kvScheme: resolveKvScheme({
        override: "config",
        config: [{ layerIdx: 0, bits: 4, groupSize: 64 }],
      }),
    });

    expect(usesContinuous(g, { ...batchable, kvQuant: true })).toBe(false);
  });

  // Unlike kvQuant (which can be partially batchable via a full-attention-only
  // kvConfig), turboQuant is UNCONDITIONALLY solo-only in v1 — no kvScheme
  // makes it batchable (TurboQuantKVCache is a novel Cache, never merge/
  // filter/temporalView-capable).
  test("turboQuant stays serial regardless of the gateway's kvScheme", () => {
    const g = new GenerationGateway(fullModel(4), 2, serialRunStub, {
      kvScheme: resolveKvScheme({
        override: "config",
        config: [0, 1, 2, 3].map((layerIdx) => ({ layerIdx, bits: 4, groupSize: 64 })),
      }),
    });
    expect(usesContinuous(g, { ...batchable, turboQuant: true })).toBe(false);
  });

  // Logits processors BATCH: the per-row sampler folds makeLogitsProcessors
  // over a per-row device-side token history (generate()'s pushHistory).
  // Load-bearing beyond opt-in knobs: Qwen3.5 ships a default repetition
  // penalty in generation_config.json — as serial-only gates these routed
  // EVERY Qwen3.5 request to the serial lane under --batch N.
  test("repetition penalty batches (per-row logits processor)", () => {
    expect(usesContinuous(gateway(2), { ...batchable, hasRepetitionPenalty: true })).toBe(true);
  });
  test("logits extras batch (min_p/XTC/logit_bias/presence+frequency)", () => {
    expect(usesContinuous(gateway(2), { ...batchable, hasLogitsExtras: true })).toBe(true);
  });

  // Grammar (B1): per-row matchers make it batchable by default; the kill
  // switch MLX_BUN_GRAMMAR_BATCH=0 forces the B0 serial fallback (A/B lever,
  // house style). Degrade-path requests have NO controller (hasGrammar=false)
  // and stay batchable regardless.
  test("grammar batches by default (B1 per-row matchers)", () => {
    const restore = configureRuntime({ MLX_BUN_GRAMMAR_BATCH: undefined });
    try {
      expect(usesContinuous(gateway(2), { ...batchable, hasGrammar: true })).toBe(true);
    } finally {
      restore();
    }
  });
  // serve --draft-model: a mounted draft routes EVERY request serial —
  // upstream parity (mlx_lm.server: is_batchable = draft is None). Spec is a
  // B=1 latency mode; batching is a throughput mode (integration plan).
  test("hasDraft routes serial (spec is serial-lane-only)", () => {
    expect(usesContinuous(gateway(2), { ...batchable, hasDraft: true })).toBe(false);
    expect(usesContinuous(gateway(2), { ...batchable, hasDraft: false })).toBe(true);
  });
  test("MLX_BUN_GRAMMAR_BATCH=0 forces grammar to serial (B0 fallback)", () => {
    const restore = configureRuntime({ MLX_BUN_GRAMMAR_BATCH: "0" });
    try {
      expect(usesContinuous(gateway(2), { ...batchable, hasGrammar: true })).toBe(false);
      // degrade-path (no controller) still batches:
      expect(usesContinuous(gateway(2), { ...batchable, hasGrammar: false })).toBe(true);
    } finally {
      restore();
    }
  });

  test("multiple disqualifiers still serial", () => {
    expect(
      usesContinuous(gateway(2), {
        ...batchable,
        hasVision: true,
        userSeed: true,
        kvQuant: true,
      }),
    ).toBe(false);
  });

  // The sampler knobs that DO batch are NOT part of RequestShape — they never
  // disqualify. Temperature/top-p/top-k/stop/tools/thinking all batch; this
  // test documents that the all-clear shape (which they leave untouched) batches.
  test("sampler knobs (temp/top-p/top-k/stop/tools) are not disqualifiers", () => {
    // None of them appear in RequestShape, so an all-clear shape stays batchable.
    expect(usesContinuous(gateway(2), batchable)).toBe(true);
  });

  // Cache-capability gate (mirrors mlx-lm server.py's all-caches-have-merge
  // check): the scheduler's dynamic-B ops exist on KVCache, RotatingKVCache,
  // and — since batching-perf-path P5 — SSMCache (mergeRows/filter, B-axis
  // surgery on the conv/recurrent state slots). MLX_BUN_BATCH_SSM=0 is the
  // kill switch back to the old serial routing.
  describe("cache-capability gate", () => {
    test("hybrid-cache model (Qwen3.5 SSMCache) batches (P5 SSM port)", () => {
      const qwen = {
        makeCache: () => [new SSMCache(), new KVCache()], // gated-DeltaNet + full-attn mix
      } as unknown as RuntimeModel;
      const g = new GenerationGateway(qwen, 2, stubSerial);
      expect(g.batchingEnabled).toBe(true);
      expect(usesContinuous(g, batchable)).toBe(true);
    });

    test("MLX_BUN_BATCH_SSM=0 re-gates hybrid models to serial", () => {
      const restore = configureRuntime({ MLX_BUN_BATCH_SSM: "0" });
      try {
        const qwen = {
          makeCache: () => [new SSMCache(), new KVCache()],
        } as unknown as RuntimeModel;
        const g = new GenerationGateway(qwen, 2, stubSerial);
        expect(usesContinuous(g, batchable)).toBe(false);
      } finally {
        restore();
      }
    });

    test("sliding-window models batch (RotatingKVCache is dynamic-B capable)", () => {
      const gemma = {
        makeCache: () => [new KVCache(), new RotatingKVCache(1024)],
      } as unknown as RuntimeModel;
      const g = new GenerationGateway(gemma, 2, stubSerial);
      expect(usesContinuous(g, batchable)).toBe(true);
    });
  });
});

// The engine-busy signal (2026-07-07 decode@ctx fix): the SSD write-behind
// gates every per-tensor flush step on onIdle(), so `busy` must cover the
// SERIAL lane too — activeRows/pendingRows read 0 while a serial generation
// holds the mutex, which is exactly when the old flush stole decode slices.
describe("GenerationGateway.busy / onIdle", () => {
  test("a managed execution lease drains earlier work and blocks later inference until released", async () => {
    const g = gateway(2);
    const order: string[] = [];
    const first = await g.acquireExecutionLease();
    const job = g.acquireExecutionLease().then((lease) => { order.push("job"); return lease; });
    const inference = g.runExclusive(async () => { order.push("inference"); });
    expect(order).toEqual([]);
    first.dispose();
    const jobLease = await job;
    expect(order).toEqual(["job"]);
    expect(g.busy).toBe(true);
    jobLease.dispose();
    jobLease.dispose();
    await inference;
    expect(order).toEqual(["job", "inference"]);
    await g.close();
    expect(g.busy).toBe(false);
  });

  test("idle gateway: busy=false, onIdle resolves immediately", async () => {
    const g = gateway(1);
    expect(g.busy).toBe(false);
    await g.onIdle(); // must not hang
  });

  test("busy while runExclusive holds the mutex (serial lane, zero rows); onIdle waits it out", async () => {
    const g = gateway(1);
    let release!: () => void;
    const gate = new Promise<void>((r) => { release = r; });
    const work = g.runExclusive(async () => { await gate; });
    expect(g.activeRows).toBe(0); // the serial lane never shows rows —
    expect(g.busy).toBe(true);    // busy must come from the mutex
    let idled = false;
    const idle = g.onIdle(1).then(() => { idled = true; });
    await new Promise<void>((r) => setTimeout(r, 10));
    expect(idled).toBe(false); // still generating → the flush stays paused
    release();
    await work;
    await idle;
    expect(g.busy).toBe(false);
  });

  test("busy covers a WAITER queued behind the lock (flush must yield to it)", async () => {
    const g = gateway(1);
    let release1!: () => void;
    const gate1 = new Promise<void>((r) => { release1 = r; });
    const first = g.runExclusive(async () => { await gate1; });
    const second = g.runExclusive(async () => {});
    release1();
    await first;
    // between first's release and second's turn, busy must never read false
    expect(g.busy).toBe(true);
    await second;
    await g.onIdle(1);
    expect(g.busy).toBe(false);
  });
});

describe("GenerationGateway request cancellation", () => {
  test("an already-aborted request releases its grammar before lane execution", async () => {
    let disposals = 0;
    const grammar = { dispose: () => { disposals++; } };
    const abort = new AbortController();
    const g = gateway(1);
    const shape = { ...batchable, hasGrammar: true };
    const placement = g.place(shape);
    abort.abort(new DOMException("client disconnected", "AbortError"));

    await expect(
      g.run(
        [1],
        { grammar } as any,
        () => {},
        undefined,
        shape,
        placement,
        abort.signal,
      ),
    ).rejects.toHaveProperty("name", "AbortError");
    expect(disposals).toBe(1);
  });

  test("an aborted serial waiter never starts generation and does not block the next request", async () => {
    let release!: () => void;
    const held = new Promise<void>((r) => { release = r; });
    let serialStarts = 0;
    const serial = async (
      _ids: number[],
      _options: any,
      onToken: (token: number) => void | boolean | Promise<void | boolean>,
    ) => {
      serialStarts++;
      await onToken(7);
      return {
        promptTokens: 1, cachedTokens: 0, generatedTokens: 1,
        prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0, cacheTokens: [],
      };
    };
    const g = new GenerationGateway(stubModel, 1, serial);
    const owner = g.runExclusive(async () => { await held; });
    const abort = new AbortController();
    let grammarDisposals = 0;
    const shape = { ...batchable, hasGrammar: true };
    const abandoned = g.run(
      [1],
      { grammar: { dispose: () => { grammarDisposals++; } } } as any,
      () => {},
      undefined,
      shape,
      g.place(shape),
      abort.signal,
    );
    abort.abort(new DOMException("client disconnected", "AbortError"));
    try {
      // The owner stays locked: removing this waiter must not depend on it.
      await expect(abandoned).rejects.toHaveProperty("name", "AbortError");
      expect(serialStarts).toBe(0);
      expect(grammarDisposals).toBe(1);
      expect(g.busy).toBe(true);
    } finally {
      release();
      await owner;
    }

    const next = await g.run(
      [1], {}, () => {}, undefined, batchable, g.place(batchable),
    );
    expect(next.generatedTokens).toBe(1);
    expect(serialStarts).toBe(1);
  });

  test("serial execution receives the request signal before producing tokens", async () => {
    const abort = new AbortController();
    const g = new GenerationGateway(stubModel, 1, async (_ids, options) => {
      expect(options.signal).toBe(abort.signal);
      abort.abort(new DOMException("client disconnected", "AbortError"));
      options.signal!.throwIfAborted();
      throw new Error("unreachable");
    });
    await expect(g.run(
      [1], {}, () => {}, undefined, batchable, g.place(batchable), abort.signal,
    )).rejects.toHaveProperty("name", "AbortError");
    expect(g.busy).toBe(false);
  });
});

describe("portable session through the real legacy gateway", () => {
  test("retains serial token order, metrics, and request snapshot", async () => {
    const g = new GenerationGateway(stubModel, 1, async (ids, options, onToken) => {
      expect(ids).toEqual([1, 2]);
      expect(options.temperature).toBe(0);
      await onToken(7); await onToken(8);
      return { promptTokens: 2, cachedTokens: 0, generatedTokens: 2,
        prefillMs: 0, decodeMs: 0, prefillTps: 0, decodeTps: 0, cacheTokens: [1, 2, 7] };
    });
    const engine = createLegacyInferenceEngine(g);
    const request = { promptIds: [1, 2], options: { temperature: 0 }, shape: { ...batchable } };
    const session = await engine.open(request, { output: "stream" });
    request.promptIds[0] = 999;
    request.options.temperature = 1;
    const events = await Array.fromAsync(session.events);
    expect(events.map((event) => event.type === "committed" ? event.tokenIds : [])).toEqual([[7], [8]]);
    expect(await session.result).toMatchObject({ status: "completed", result: {
      finishReason: "stop", metrics: { generatedTokens: 2 },
    } });
    await engine.close();
    expect(g.busy).toBe(false);
  });

  test("session cancellation removes its queued gateway waiter while the holder is still running", async () => {
    const g = gateway(1);
    let release!: () => void;
    const held = new Promise<void>((r) => { release = r; });
    const owner = g.runExclusive(() => held);
    const engine = createLegacyInferenceEngine(g);
    const session = await engine.open({ promptIds: [1], options: {}, shape: batchable }, { output: "collect" });
    try {
      await new Promise<void>((resolve) => setImmediate(resolve));
      await session.cancel();
      expect(await session.result).toMatchObject({ status: "cancelled" });
      expect(g.busy).toBe(true);
    } finally { release(); await owner; await engine.close(); }
    expect(g.busy).toBe(false);
  });
});
