// Exclusive GPU: MLX_BUN_TEST_ORDINARY_CONTINUATION=1 bun test tests/parity/ordinary-continuation.test.ts
import { expect, test, spyOn } from "bun:test";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { continuationKv } from "./helpers/continuation-kv";
const target = Bun.env.MLX_BUN_TEST_CONTINUATION_MODEL ?? `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb`;
const adapter = Bun.env.MLX_BUN_TEST_CONTINUATION_ADAPTER === "1";
const enabled = Bun.env.MLX_BUN_TEST_ORDINARY_CONTINUATION === "1" && existsSync(`${target}/config.json`) && (!adapter || existsSync("fixtures/adapters/upper/adapters.safetensors"));

test.skipIf(!enabled)("ordinary B1/B4 restore pending tokens and sampler history from interrupted SSD checkpoints", async () => {
  const { AdapterManager } = await import("../../src/lora");
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { bindMlxGateway } = await import("../../src/backends/mlx/gateway-binding");
  const { createOrdinaryContinuationRequest } = await import("../../src/backends/mlx/continuation-request");
  const { ContinuationPersistence } = await import("../../src/backends/mlx/continuation-persistence");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const ops = await import("../../src/mlx/ops");
  const { leaseCacheState, minimumReusableOffset } = await import("../../src/backends/mlx/state-views");
  const { clearCache } = await import("../../src/mlx/ffi");
  const weights = await Weights.open(target), model = createModel(weights, await loadModelConfig(target));
  const manager = new AdapterManager(model);
  if (adapter) await manager.mount("upper", "fixtures/adapters/upper");
  const adapterNamespace = adapter ? manager.cacheNamespace(["upper"]) : "";
  const directory = mkdtempSync(join(tmpdir(), "ordinary-continuation-"));
  const execution = { method: "autoregressive", mechanism: "continuous", pagedKv: false,
    promptCache: true, checkpoint: true, fill: false, compiledDecode: false, grammarJump: false, reasons: [] } as const;
  const prompt = [2, 105, 2364, 107, 1567, 506, 2390, 107];
  const kv = continuationKv(prompt.length);
  const widths: number[] = [];
  const forward = model.forwardHidden.bind(model);
  try {
    for (const batch of [1, 4]) {
      const settings = (name: string) => ({ dir: join(directory, `${batch}-${name}`), maxBytes: 1024 ** 3,
        modelId: target, configFingerprint: `ordinary-continuation-v1:${kv.scheme.cacheKey}`, tokenizerHash: "fixture", verify: true });
      const run = async (store: InstanceType<typeof SsdCacheStore>, interrupt: boolean, useAdapter = adapter) => {
        let held = true;
        const binding = bindMlxGateway(model);
        const context = useAdapter ? binding.bindAdapterContext!(["upper"], "adapters:upper") : undefined;
        const namespace = useAdapter ? adapterNamespace : "";
        const activeContexts: string[][] = [];
        const contextGraph = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
          widths.push(ids.shape[0]!); activeContexts.push([...model.loraState!.active]); return forward(ids, caches);
        });
        const group = binding.createBatchGroup({ maxBatch: batch, kvScheme: kv.scheme, admissionHeld: () => held });
        const aborts = Array.from({ length: batch }, () => new AbortController());
        const captured = new Map<string, string>();
        let idle!: () => void;
        const idleGate = new Promise<void>(resolve => { idle = resolve; });
        const persistence = new ContinuationPersistence(store, { maxBytes: 1024 ** 3,
          runStep: async step => { await idleGate; return step(); } });
        const outputs: number[][] = Array.from({ length: batch }, () => []);
        const requests = outputs.map((tokens, row) => createOrdinaryContinuationRequest({
          store, persistence, restore: entry => store.restore(entry, model), interval: 4, prompt,
          options: { ...kv.options, ...(useAdapter ? { adapters: ["upper"] } : {}), maxTokens: 16, temperature: 0.7, seed: 42 + row, seedWasExplicit: true,
            repetitionPenalty: 1.1, repetitionContextSize: 32 }, execution, identity: "same-B-fixture",
          onToken(token) {
            tokens.push(token);
            if (interrupt && tokens.length === kv.interruptAt) {
              if (row % 2 === 0) aborts[row]!.abort(new Error("interrupted request"));
              else throw new Error("interrupted consumer");
            }
          },
        }));
        for (const [row, request] of requests.entries()) {
          const enqueue = request.continuation.captureOwned;
          request.continuation.captureOwned = state => {
            const digest = new Bun.CryptoHasher("sha256");
            const minimum = minimumReusableOffset(state.caches);
            digest.update(JSON.stringify(state.caches.map(cache => ({ offset: cache.offset, minimum: cache.minimumReusableOffset ?? 0 }))));
            if (kv.mode !== "bf16" && kv.start > 0) {
              if (state.cacheTokens.length < kv.start) expect(minimum).toBe(0);
              else expect(minimum).toBeGreaterThanOrEqual(kv.start);
            }
            for (const cache of state.caches) {
              const lease = leaseCacheState(cache);
              try { for (const plane of lease.borrow()) {
                using exact = ops.contiguous(plane);
                digest.update(JSON.stringify(plane.shape)); digest.update(exact.rawBytes());
              } } finally { lease.close(); }
            }
            captured.set(`row-${row}:${state.generatedTokens}`, digest.digest("hex"));
            enqueue(state);
          };
        }
        try {
          const pending = requests.map((request, row) => group.submit({ ...request, promptIds: prompt,
            cacheNamespace: adapter ? namespace : `row-${row}`, context, signal: aborts[row]!.signal, compiledDecode: false, maxTokens: 16, eosTokenIds: [] }));
          held = false; group.kick();
          const results = await Promise.allSettled(pending);
          if (!interrupt) for (const result of results) if (result.status === "rejected") throw result.reason;
          expect(results.map(result => result.status)).toEqual(Array(batch).fill(interrupt ? "rejected" : "fulfilled"));
          expect(activeContexts.length).toBeGreaterThan(0);
          expect(activeContexts.every(ids => JSON.stringify(ids) === JSON.stringify(useAdapter ? ["upper"] : []))).toBe(true);
          return { outputs, captured };
        } finally {
          await group.close(); contextGraph.mockRestore(); idle(); await persistence.flush();
          requests.forEach(request => request.dispose()); clearCache();
          expect(model.loraState!.active).toEqual([]);
        }
      };
      widths.length = 0;
      const control = await run(new SsdCacheStore(settings("control")), false);
      expect(widths).toContain(batch);
      const interruptedStore = new SsdCacheStore(settings("restart"));
      const interrupted = await run(interruptedStore, true);
      expect(interrupted.outputs.map(tokens => tokens.length)).toEqual(Array(batch).fill(kv.interruptAt));
      if (adapter) {
        const baseControl = await run(new SsdCacheStore(settings("base-control")), false, false);
        const isolated = new SsdCacheStore(settings("restart"));
        expect(isolated.scan()).toBe(batch);
        const base = await run(isolated, false, false);
        expect(base.outputs).toEqual(baseControl.outputs);
        expect(base.captured).toEqual(baseControl.captured);
        expect(isolated.stats.restores).toBe(0);
        expect(new SsdCacheStore(settings("restart")).scan()).toBe(batch);
      }
      const restarted = new SsdCacheStore(settings("restart"));
      expect(restarted.scan()).toBe(batch);
      const replayed = await run(restarted, false);
      expect(replayed.outputs).toEqual(control.outputs);
      for (const [key, hash] of interrupted.captured) expect(hash).toBe(control.captured.get(key)!);
      for (const [key, hash] of replayed.captured) expect(hash).toBe(control.captured.get(key)!);
      expect(restarted.stats.restores).toBe(batch);
      expect(new SsdCacheStore(settings("restart")).scan()).toBe(0);
    }
  } finally { if (adapter) manager.unmount("upper"); weights.dispose(); clearCache(); rmSync(directory, { recursive: true, force: true }); }
}, 300_000);
