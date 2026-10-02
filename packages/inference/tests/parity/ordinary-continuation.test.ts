// Opt in with MLX_BUN_TEST_CONTINUATION_MODEL=/cached/checkpoint. No downloads.
// Optional MLX_BUN_TEST_CONTINUATION_ADAPTER=/cached/adapter enables isolation checks.
// Optional MLX_BUN_TEST_CONTINUATION_WINDOW=<n> builds a custom graph over a
// Llama-family artifact's unchanged weights: alternating sliding (window n) and
// full layers, one descriptor for the parsed config and the graph arguments.
// It is not a published model.
// Optional MLX_BUN_TEST_CONTINUATION_FRESH_PROCESS=1 also restores interrupted
// checkpoints in a fresh process: the parent writes them to a directory it owns,
// releases its weights, runs this test once as a bounded child
// (MLX_BUN_TEST_CONTINUATION_PHASE=child, which only restores and never spawns),
// joins it, and then removes the directory.
// Optional MLX_BUN_TEST_CONTINUATION_IGNORED_DRAFT=1 (with an adapter) binds a
// two-model draft to adapter rows. The provider cannot serve adapters, so the
// row must decode ordinarily with checkpoints, never open draft rows, and match
// a draftless adapter control token for token and checkpoint for checkpoint.
import { expect, test, spyOn } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import { applyDescriptor, descriptorFor } from "./real-weight-inputs";
const target = Bun.env.MLX_BUN_TEST_CONTINUATION_MODEL;
const adapter = Bun.env.MLX_BUN_TEST_CONTINUATION_ADAPTER;
if (target && !existsSync(`${target}/config.json`)) throw new Error(`unavailable model: ${target}`);
if (adapter && !existsSync(`${adapter}/adapters.safetensors`)) throw new Error(`unavailable adapter: ${adapter}`);
const windowSetting = Bun.env.MLX_BUN_TEST_CONTINUATION_WINDOW;
const freshProcess = Bun.env.MLX_BUN_TEST_CONTINUATION_FRESH_PROCESS === "1";
const phase = Bun.env.MLX_BUN_TEST_CONTINUATION_PHASE ?? "parent";
const childDirectory = Bun.env.MLX_BUN_TEST_CONTINUATION_DIR;
const ignoredDraft = Bun.env.MLX_BUN_TEST_CONTINUATION_IGNORED_DRAFT === "1";
if (ignoredDraft && !adapter) throw new Error("MLX_BUN_TEST_CONTINUATION_IGNORED_DRAFT needs an adapter");
if (windowSetting !== undefined && !/^[1-9]\d*$/.test(windowSetting.trim()))
  throw new Error("MLX_BUN_TEST_CONTINUATION_WINDOW must be a positive integer");
if (phase !== "parent" && phase !== "child") throw new Error(`unknown continuation phase: ${phase}`);
if ((phase === "child") !== !!childDirectory) throw new Error("the child phase and its directory come together");
if (phase === "child" && freshProcess) throw new Error("a child never spawns another restore");

/** The artifact's config, or the custom window descriptor applied to both the
 * parsed config and the raw arguments the graph is built from. */
async function continuationConfig() {
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts");
  const config = await loadModelConfig(target!);
  if (windowSetting === undefined) return config;
  if (!["llama", "mistral"].includes(config.modelType)) throw new Error(`a custom window needs a Llama-family artifact, not ${config.modelType}`);
  applyDescriptor(config, descriptorFor(config.text.numHiddenLayers, Number(windowSetting)));
  return config;
}
/** The graph must carry the custom descriptor it was built from. */
function checkDescriptor(model: { args?: { layerTypes?: string[] | null; slidingWindow?: number | null } }, config: { text: { layerTypes: string[]; slidingWindow: number } }) {
  if (windowSetting === undefined) return;
  expect({ layerTypes: model.args?.layerTypes, slidingWindow: model.args?.slidingWindow })
    .toEqual({ layerTypes: config.text.layerTypes, slidingWindow: config.text.slidingWindow });
}

test.skipIf(!target)("ordinary B1/B4 restore pending tokens and sampler history from interrupted SSD checkpoints", async () => {
  const { AdapterManager } = await import("@mlx-bun/inference/adapters");
  const { Weights } = await import("@mlx-bun/inference/artifacts");
  const { loadModelConfig } = await import("@mlx-bun/inference/artifacts");
  const { createModel } = await import("@mlx-bun/inference/models");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { createOrdinaryContinuationRequest } = await import("@mlx-bun/inference/execution");
  const { ContinuationPersistence } = await import("@mlx-bun/inference/execution");
  const { SsdCacheStore } = await import("@mlx-bun/inference/state");
  const { TwoModelProvider } = await import("../../src/generation/speculative/sources/two-model");
  const ops = await import("@mlx-bun/mlx/ops");
  const { leaseCacheState, minimumReusableOffset, PromptCache, cloneKvCaches } = await import("@mlx-bun/inference/state");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const directory = phase === "child" ? childDirectory! : mkdtempSync(join(tmpdir(), "ordinary-continuation-"));
  const weights = await Weights.open(target!);
  let released = false;
  let manager: InstanceType<typeof AdapterManager> | undefined;
  type Restore = { keys: string[]; tokens: number[] };
  const expectedFresh: Record<number, { outputs: number[][]; captured: Record<string, string> } & Restore> = {};
  /** What a restored run must show: each row restores its last interrupted
   * capture (`tokens`, committed token counts in ascending order), then
   * captures exactly the control's later checkpoints (`keys`, never empty). */
  const restoredKeys = (batch: number, prompt: readonly number[], control: Map<string, string>, interrupted: Map<string, string>): Restore => {
    const parse = (key: string) => { const [, row, generated] = /^row-(\d+):(\d+)$/.exec(key)!.map(Number); return { row: row!, generated: generated! }; };
    const restoredAt = new Map<number, number>();
    for (const key of interrupted.keys()) {
      const { row, generated } = parse(key);
      restoredAt.set(row, Math.max(restoredAt.get(row) ?? 0, generated));
    }
    expect([...restoredAt.keys()].sort((x, y) => x - y)).toEqual(Array.from({ length: batch }, (_, row) => row));
    const keys = [...control.keys()].filter(key => parse(key).generated > restoredAt.get(parse(key).row)!).sort();
    expect(keys.length).toBeGreaterThan(0);
    return { keys, tokens: [...restoredAt.values()].map(generated => prompt.length + generated).sort((x, y) => x - y) };
  };
  const expectRestored = (replayed: { captured: Map<string, string>; restored: number[] }, expected: Restore, control: (key: string) => string | undefined) => {
    expect(expected.keys.length).toBeGreaterThan(0);
    expect([...replayed.restored].sort((x, y) => x - y)).toEqual(expected.tokens);
    expect([...replayed.captured.keys()].sort()).toEqual(expected.keys);
    for (const key of expected.keys) { expect(typeof control(key)).toBe("string"); expect(replayed.captured.get(key)).toBe(control(key)!); }
  };
  try {
    const config = await continuationConfig();
    const model = createModel(weights, config);
    checkDescriptor(model as never, config);
    if (!("loraState" in model) || !model.loraState) throw new Error("continuation test requires adapter state");
    manager = new AdapterManager(model);
    const adapters = manager;
    if (adapter) await manager.mount("upper", adapter);
    const adapterNamespace = adapter ? adapters.cacheNamespace(["upper"]) : "";
    const prompt = [2, 105, 2364, 107, 1567, 506, 2390, 107];
    const kv = await continuationKv(prompt.length);
    /** A saved or restored checkpoint of `tokens` committed tokens (always
     * after the prefill). Delayed conversion gives each converted cache the
     * offset it converted at as its reuse floor. A start within the prompt
     * converts at the first prefill maintenance boundary at or past it (a drain
     * chunk's end or the prompt's end); a later start converts inside the next
     * decode append once the committed offset has reached it, so a checkpoint
     * of exactly `start` tokens taken after a decode step is still plain.
     * Other artifacts may carry recurrent or other non-KV state, so they check
     * only the floor's bound;
     * the custom window graph is sliding and full KV layers throughout, so it
     * also pins the exact floor, every offset, and each layer's planes:
     * six encoded (K then V packed/scales/biases) once converted, two plain
     * before and for layers a per-layer scheme leaves unconverted. TurboQuant
     * checkpoints, including those from token 0, also pass checkTurbo. */
    /** TurboQuant's exact inventory once converted: each full-attention
     * cache holds the five encoded planes (K indices, float16 K scales and
     * zeros per 32-wide group, packed uint8 V, float16 V scales) at the
     * scheme's bits, each sliding cache stays a plain ring, and every KV
     * layer is at the checkpoint's offset. From token 0 there is no reuse
     * floor. Recurrent layers keep their own state and are not KV. */
    const checkTurbo = (caches: readonly Cache[], tokens: number) => {
      const { kBits, vBits } = kv.options.turboQuant!;
      // One effective type per cache for both the check and the count: a
      // config without layer types is full attention throughout.
      const types = caches.map((_, layer) => config.text.layerTypes[layer] ?? "full_attention");
      if (kv.start === 0) expect(minimumReusableOffset(caches)).toBe(0);
      let encoded = 0;
      caches.forEach((cache, layer) => {
        const type = types[layer]!;
        if (type === "linear_attention") return;
        expect(cache.offset).toBe(tokens);
        const lease = leaseCacheState(cache);
        try {
          const planes = lease.borrow();
          if (type === "sliding_attention") {
            expect((cache as { maxSize?: number }).maxSize).toBe(config.text.slidingWindow);
            expect(planes).toHaveLength(2);
            expect(planes[1]!.dtypeName).toBe(planes[0]!.dtypeName);
            expect(["bfloat16", "float16", "float32"]).toContain(planes[0]!.dtypeName);
            expect(planes[0]!.shape[2]!).toBeGreaterThanOrEqual(Math.min(tokens, config.text.slidingWindow));
            return;
          }
          const turbo = cache as Cache & { headDim: number | null; fusedDecode?: boolean };
          expect(turbo.signature()).toBe(`kv:turboquant:${kBits}:${vBits}`);
          if (Bun.env.MLX_BUN_TURBOQUANT_FUSED_DECODE === undefined) expect(turbo.fusedDecode).toBe(true);
          const dim = turbo.headDim!, groups = dim / 32;
          expect(planes.map(plane => plane.dtypeName)).toEqual([kBits === 8 ? "int8" : "uint8", "float16", "float16", "uint8", "float16"]);
          expect(planes.map(plane => plane.shape[3])).toEqual([kBits === 8 ? dim : dim * kBits / 8, groups, groups, dim * vBits / 8, groups]);
          for (const plane of planes) expect([plane.shape[0], plane.shape[1], plane.shape[2]]).toEqual([1, planes[0]!.shape[1], tokens]);
          encoded++;
        } finally { lease.close(); }
      });
      expect(encoded).toBeGreaterThan(0);
      expect(encoded).toBe(types.filter(type => type === "full_attention").length);
    };
    const checkSaved = (caches: readonly Cache[], tokens: number) => {
      if (kv.mode === "turbo" && (kv.start <= prompt.length || tokens > kv.start)) checkTurbo(caches, tokens);
      if (kv.mode === "bf16" || kv.start === 0) return;
      const converted = kv.start <= prompt.length || tokens > kv.start;
      const minimum = minimumReusableOffset(caches);
      if (windowSetting === undefined) {
        if (converted) expect(minimum).toBeGreaterThanOrEqual(kv.start);
        else expect(minimum).toBe(0);
        return;
      }
      if (!converted) expect(minimum).toBe(0);
      else if (kv.start > prompt.length) expect(minimum).toBe(kv.start);
      else { expect(minimum).toBeGreaterThanOrEqual(kv.start); expect(minimum).toBeLessThanOrEqual(prompt.length); }
      const layers = kv.options.kvConfig ? new Map(kv.options.kvConfig.map(entry => [entry.layerIdx, entry])) : null;
      caches.forEach((cache, layer) => {
        expect(cache.offset).toBe(tokens);
        if (kv.mode === "turbo") return;
        const spec = layers ? layers.get(layer) : { bits: kv.options.kvBits!, groupSize: kv.options.kvGroupSize ?? 64 };
        const lease = leaseCacheState(cache);
        try {
          const planes = lease.borrow();
          if (!converted || !spec) { expect(planes).toHaveLength(2); return; }
          expect(planes).toHaveLength(6);
          for (const at of [0, 3]) {
            const [packed, scales, biases] = [planes[at]!, planes[at + 1]!, planes[at + 2]!];
            expect(packed.dtypeName).toBe("uint32");
            expect(biases.shape).toEqual(scales.shape);
            expect(packed.shape.slice(0, 3)).toEqual(scales.shape.slice(0, 3));
            expect(packed.shape[3]! * 32).toBe(scales.shape[3]! * spec.groupSize * spec.bits);
          }
        } finally { lease.close(); }
      });
    };
    const widths: number[] = [];
    const forward = model.forwardHidden.bind(model);
    const probe = (active: string[]) => {
      const previous = model.loraState!.active, caches = model.makeCache();
      model.loraState!.active = active;
      try { using logits = model.forward(prompt, caches); using exact = ops.contiguous(logits); return Buffer.from(exact.rawBytes()); }
      finally { model.loraState!.active = previous; for (const cache of caches) cache.dispose(); }
    };
    const baseLogits = adapter ? probe([]) : undefined;
    if (adapter) {
      expect(manager.list()).toHaveLength(1);
      expect(probe(["upper"])).not.toEqual(baseLogits!);
    }
    for (const batch of [1, 4]) {
      const settings = (name: string) => ({ dir: join(directory, `${batch}-${name}`), maxBytes: 1024 ** 3,
        modelId: target!, configFingerprint: `ordinary-continuation-v1:${kv.scheme.cacheKey}`, tokenizerHash: "fixture", verify: true });
      const run = async (store: InstanceType<typeof SsdCacheStore>, interrupt: boolean, useAdapter = !!adapter,
        useDraft = ignoredDraft && useAdapter) => {
        let held = true;
        const unexpected = () => { throw new Error("an ignored draft opened rows"); };
        const binding = bindMlxGateway(model, useDraft ? { numDraftTokens: 3, provider: Object.assign(
          Object.create(TwoModelProvider.prototype), { id: "ignored-draft", weightsBytes: 0,
            grouped: { checkpointNamespace: () => "ignored-draft", open: unexpected, openPrefill: unexpected } }) } : undefined);
        const context = useAdapter ? binding.bindAdapterContext!(["upper"], "adapters:upper") : undefined;
        const namespace = useAdapter ? adapterNamespace : "";
        const activeContexts: string[][] = [];
        const contextGraph = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
          widths.push(ids.shape[0]!); activeContexts.push([...model.loraState!.active]); return forward(ids, caches);
        });
        const group = binding.createBatchGroup({ maxBatch: batch, kvScheme: kv.scheme, admissionHeld: () => held });
        const aborts = Array.from({ length: batch }, () => new AbortController());
        const captured = new Map<string, string>(), restored: number[] = [];
        let idle!: () => void;
        const idleGate = new Promise<void>(resolve => { idle = resolve; });
        const persistence = new ContinuationPersistence(store, { maxBytes: 1024 ** 3,
          runStep: async step => { await idleGate; return step(); } });
        const outputs: number[][] = Array.from({ length: batch }, () => []);
        const prefix = new PromptCache(1024 ** 2, null, null, cloneKvCaches);
        const requests: ReturnType<typeof createOrdinaryContinuationRequest>[] = [];
        try {
          binding.configureContinuation!({ promptCache: prefix, checkpoints: store, checkpointEveryTokens: 4,
            checkpointPersistence: persistence, identity: "same-B-fixture", cloneState: cloneKvCaches,
            adapterNamespace: ids => adapters.cacheNamespace(ids) });
          const options = { ...kv.options, ...(useAdapter ? { adapters: ["upper"] } : {}), maxTokens: 16,
            temperature: 0.7, seedWasExplicit: true, repetitionPenalty: 1.1, repetitionContextSize: 32 };
          const execution = binding.plan({ hasVision: false, hasAdapters: useAdapter, hasRepetitionPenalty: true,
            userSeed: true, kvQuant: kv.scheme.kind !== "bf16" && kv.scheme.kind !== "turbo", turboQuant: kv.scheme.kind === "turbo",
            hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: useDraft }, options,
          { continuous: binding.cachesBatchable(), quantizedBatch: binding.kvBatchable(kv.scheme), checkpoints: true });
          expect(execution).toMatchObject({ method: "autoregressive", mechanism: "continuous", checkpoint: true });
          if (useDraft) {
            expect(execution.reasons).toContain("draft-incompatible-with-request");
            expect(binding.methodRequest!(execution, options)).toBeUndefined();
          }
          for (const [row, tokens] of outputs.entries()) requests.push(createOrdinaryContinuationRequest({
            store, persistence, interval: 4, prompt,
            restore: entry => {
              const loaded = store.restore(entry, model);
              if (!loaded) return loaded;
              try {
                checkSaved(loaded.caches, loaded.tokens.length);
                const planes = loaded.caches.map(cache => { const lease = leaseCacheState(cache); try { return lease.borrow().length; } finally { lease.close(); } });
                console.log(`[continuation-restore] ${phase} B${batch} row ${row}: ${loaded.tokens.length} tokens, offsets ` +
                  `${[...new Set(loaded.caches.map(cache => cache.offset))]}, minimum ${minimumReusableOffset(loaded.caches)}, ` +
                  `planes ${[...new Set(planes)]} over ${loaded.caches.length} caches`);
              } catch (error) {
                // Ownership passes to the caller only on return.
                for (const cache of loaded.caches) cache.dispose();
                for (const attachment of loaded.attachments ?? []) for (const tensor of attachment.tensors) tensor.dispose();
                throw error;
              }
              restored.push(loaded.tokens.length);
              return loaded;
            },
            options: { ...options, seed: 42 + row }, execution, identity: "same-B-fixture",
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
              digest.update(JSON.stringify(state.caches.map(cache => ({ offset: cache.offset, minimum: cache.minimumReusableOffset ?? 0 }))));
              checkSaved(state.caches, state.cacheTokens.length);
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
          const pending = requests.map((request, row) => group.submit({ ...request, promptIds: prompt,
            cacheNamespace: adapter ? namespace : `row-${row}`, context, signal: aborts[row]!.signal, compiledDecode: false, maxTokens: 16, eosTokenIds: [] }));
          held = false; group.kick();
          const results = await Promise.allSettled(pending);
          if (!interrupt) for (const result of results) if (result.status === "rejected") throw result.reason;
          expect(results.map(result => result.status)).toEqual(Array(batch).fill(interrupt ? "rejected" : "fulfilled"));
          expect(activeContexts.length).toBeGreaterThan(0);
          expect(activeContexts.every(ids => JSON.stringify(ids) === JSON.stringify(useAdapter ? ["upper"] : []))).toBe(true);
          return { outputs, captured, restored };
        } finally {
          for (const abort of aborts) abort.abort(new Error("continuation test cleanup"));
          try { await group.close(); }
          finally {
            contextGraph.mockRestore(); idle();
            try { await persistence.flush(); }
            finally { requests.forEach(request => request.dispose()); prefix.clear(); clearCache(); }
          }
          expect(model.loraState!.active).toEqual([]);
        }
      };
      if (phase === "child") {
        // Fresh process: only restore the parent's interrupted checkpoints and
        // continue exactly as the parent's uninterrupted control did.
        const expected = JSON.parse(readFileSync(join(directory, "fresh-expected.json"), "utf8"))[batch];
        const store = new SsdCacheStore(settings("fresh"));
        expect(store.scan()).toBe(batch);
        const replayed = await run(store, false);
        expect(replayed.outputs).toEqual(expected.outputs);
        expectRestored(replayed, expected, key => expected.captured[key]);
        expect(store.stats.restores).toBe(batch);
        expect(new SsdCacheStore(settings("fresh")).scan()).toBe(0);
        continue;
      }
      widths.length = 0;
      const control = await run(new SsdCacheStore(settings("control")), false);
      expect(widths).toContain(batch);
      if (ignoredDraft) {
        const draftless = await run(new SsdCacheStore(settings("draftless-control")), false, true, false);
        expect(control.outputs).toEqual(draftless.outputs);
        expect(control.captured).toEqual(draftless.captured);
      }
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
      expect(control.restored).toEqual([]);
      expectRestored(replayed, restoredKeys(batch, prompt, control.captured, interrupted.captured), key => control.captured.get(key));
      expect(restarted.stats.restores).toBe(batch);
      expect(new SsdCacheStore(settings("restart")).scan()).toBe(0);
      if (freshProcess) {
        // Interrupted checkpoints for the fresh-process restore, left on disk.
        const fresh = await run(new SsdCacheStore(settings("fresh")), true);
        expect(fresh.outputs.map(tokens => tokens.length)).toEqual(Array(batch).fill(kv.interruptAt));
        for (const [key, hash] of fresh.captured) expect(hash).toBe(control.captured.get(key)!);
        expectedFresh[batch] = { outputs: control.outputs, captured: Object.fromEntries(control.captured),
          ...restoredKeys(batch, prompt, control.captured, fresh.captured) };
      }
    }
    if (phase === "child") return;
    if (adapter) {
      expect(manager.unmount("upper")).toBeGreaterThan(0);
      expect(manager.list()).toEqual([]);
      expect(probe(["upper"])).toEqual(baseLogits!);
    }
    if (freshProcess) {
      writeFileSync(join(directory, "fresh-expected.json"), JSON.stringify(expectedFresh));
      // Release this process's model before the child loads its own: no
      // overlapping GPU work and no parent weights held during the restore.
      if (adapter && manager.list().length) manager.unmount("upper");
      (model as { dispose?: () => void }).dispose?.();
      weights.dispose(); clearCache(); released = true;
      const child = Bun.spawnSync([process.execPath, "--no-env-file", "test", import.meta.path, "--test-name-pattern", "^ordinary B1/B4 restore"], {
        env: { ...process.env, MLX_BUN_TEST_CONTINUATION_PHASE: "child", MLX_BUN_TEST_CONTINUATION_DIR: directory,
          MLX_BUN_TEST_CONTINUATION_FRESH_PROCESS: "0" },
        stdout: "pipe", stderr: "pipe", timeout: 240_000, killSignal: "SIGKILL" });
      const stdout = child.stdout.toString(), stderr = child.stderr.toString(), output = stdout + stderr;
      if (child.exitCode !== 0 || !/\b1 pass\b/.test(output) || !/\b0 fail\b/.test(output)) {
        const diagnostics = `fresh-process restore child: exit ${child.exitCode}, signal ${child.signalCode ?? "none"}` +
          `${child.exitedDueToTimeout ? ", killed at its deadline" : ""}\n--- child stdout ---\n${stdout}\n--- child stderr ---\n${stderr}`;
        console.error(diagnostics);
        throw new Error(diagnostics);
      }
      for (const line of output.split("\n")) if (line.startsWith("[continuation-restore] child")) console.log(line);
    }
  } finally {
    try { if (adapter && manager?.list().length) manager.unmount("upper"); }
    finally {
      if (!released) weights.dispose();
      clearCache();
      // The parent owns the directory; the child never removes it.
      if (phase === "parent") rmSync(directory, { recursive: true, force: true });
    }
  }
}, freshProcess ? 600_000 : 300_000);

// Uses the same artifact/adapter opt-ins as continuation; a positive start is
// required so this cannot pass by exercising only already-encoded caches.
test.skipIf(!target || !adapter || !Bun.env.MLX_BUN_TEST_CONTINUATION_KV_START ||
  Bun.env.MLX_BUN_TEST_CONTINUATION_KV_START === "0")(
  "delayed affine adapter groups join, cancel, isolate queued base rows and reuse after drain", async () => {
  const { Weights, loadModelConfig } = await import("@mlx-bun/inference/artifacts");
  const { createModel } = await import("@mlx-bun/inference/models");
  const { AdapterManager } = await import("@mlx-bun/inference/adapters");
  const { bindMlxGateway, createRowSampling } = await import("@mlx-bun/inference/execution");
  const { makeStepSampler } = await import("@mlx-bun/inference/sampling");
  const { leaseCacheState, isBatchableCache } = await import("@mlx-bun/inference/state");
  const ops = await import("@mlx-bun/mlx/ops");
  const weights = await Weights.open(target!);
  let manager: InstanceType<typeof AdapterManager> | undefined;
  try {
    const config = await continuationConfig();
    const model = createModel(weights, config);
    checkDescriptor(model as never, config);
    manager = new AdapterManager(model);
    const adapters = manager, prompt = [2, 105, 2364, 107, 1567, 506, 2390, 107];
    const kv = await continuationKv(prompt.length);
    if (!["4", "8", "per-layer"].includes(kv.mode) || kv.start <= 0 || kv.start >= prompt.length + 16)
      throw new Error("adapter lifecycle requires delayed affine conversion inside the generated sequence");
    const binding = bindMlxGateway(model);
    const hash = (array: import("@mlx-bun/mlx/array").MlxArray) => {
      using exact = ops.contiguous(array);
      return [array.shape, array.dtype, new Bun.CryptoHasher("sha256").update(exact.rawBytes()).digest("hex")];
    };
    const validCache = (cache: ReturnType<typeof model.makeCache>[number]): unknown => {
      // Batchable codecs own row extraction: it removes padding and retains
      // the original packed/scales/biases representation without dequantizing.
      if (isBatchableCache(cache)) {
        const rows: unknown[] = [];
        expect(cache.batchSize).toBeGreaterThan(0);
        for (let row = 0; row < cache.batchSize!; row++) {
          const extracted = cache.extractRow(row);
          try { rows.push(validCache(extracted)); } finally { extracted.dispose(); }
        }
        return rows;
      }
      const lease = leaseCacheState(cache);
      try {
        const planes = lease.borrow();
        expect([2, 6]).toContain(planes.length);
        const batch = planes[0]!.shape[0]!;
        const port = cache as typeof cache & { ropeOffsetArr?: import("@mlx-bun/mlx/array").MlxArray; leftPadding?: number; minimumReusableOffset?: number };
        // Ordinary full-KV mask wrappers expose logical row positions through
        // their RoPE port; raw state() may still include alignment and capacity.
        const positions = port.ropeOffsetArr ? [...port.ropeOffsetArr.toFloat32()] : Array(batch).fill(cache.offset);
        expect(positions).toHaveLength(batch);
        return positions.map((offset, row) => {
          const start = port.leftPadding ?? cache.offset - offset, end = start + offset;
          expect(Number.isSafeInteger(offset) && offset > 0 && start >= 0).toBe(true);
          return { offset, minimum: port.minimumReusableOffset ?? 0, planes: planes.map(plane => {
            expect(plane.shape).toHaveLength(4);
            expect(plane.shape[0]).toBe(batch);
            expect(plane.shape[2]!).toBeGreaterThanOrEqual(end);
            using valid = plane.slice([row, 0, start, 0], [row + 1, plane.shape[1]!, end, plane.shape[3]!]);
            return hash(valid);
          }) };
        });
      } finally { lease.close(); }
    };
    await adapters.mount("upper", adapter!);
    const scenario = async (batch: number, cancel: boolean, baseOnly = false) => {
      let held = true, leased = false, joined = false, queuedBase = false;
      const group = binding.createBatchGroup({ maxBatch: batch, kvScheme: kv.scheme, admissionHeld: () => held,
        lock: { async acquire() { leased = true; return () => { leased = false; }; } } });
      const drained = async () => {
        const deadline = Date.now() + 10_000;
        while (group.activeRows || group.pendingRows || leased) {
          if (Date.now() > deadline) throw new Error("adapter group did not release its execution lease");
          await new Promise<void>(resolve => setImmediate(resolve));
        }
      };
      const calls: unknown[] = [], widths: number[] = [], active: string[] = [], outputs: number[][] = [];
      type JobResult = { status: "fulfilled"; stats: Awaited<ReturnType<typeof group.submit>> } | { status: "rejected"; error: unknown };
      const jobs: Promise<JobResult>[] = [], samplers: { dispose(): void }[] = [];
      const aborts: AbortController[] = [];
      let hidden: { mockRestore(): void } | undefined, logits: { mockRestore(): void } | undefined;
      let timer: ReturnType<typeof setTimeout> | undefined;
      try {
        const forward = model.forwardHidden.bind(model), project = model.logitsFromHidden.bind(model);
        const context = () => model.loraState!.active.join(",");
        hidden = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
          const value = forward(ids, caches);
          try {
            const planes = caches.map(validCache);
            calls.push(["forward", context(), hash(ids), planes]); widths.push(ids.shape[0]!); active.push(context());
          } catch (error) { value.dispose(); throw error; }
          return value;
        });
        logits = spyOn(model, "logitsFromHidden").mockImplementation(value => {
          const result = project(value);
          try { calls.push(["logits", context(), hash(result)]); } catch (error) { result.dispose(); throw error; }
          return result;
        });
        const enqueue = (row: number, adapted: boolean) => {
          const tokens: number[] = []; outputs[row] = tokens;
          const abort = new AbortController(); aborts.push(abort);
          const ids = row === batch - 1 && adapted ? [...prompt, 42, 43] : prompt;
          const options = { ...kv.options, maxTokens: row === 1 && !cancel ? 4 : 16, temperature: 0,
            ...(adapted ? { adapters: ["upper"] } : {}) };
          const execution = binding.plan({ hasVision: false, hasAdapters: adapted, hasRepetitionPenalty: false,
            userSeed: false, kvQuant: true, turboQuant: false, hasLogitsExtras: false,
            hasGrammar: false, wantsLogprobs: false, hasDraft: false }, options,
          { continuous: binding.cachesBatchable(), quantizedBatch: binding.kvBatchable(kv.scheme), checkpoints: false });
          expect(execution).toMatchObject({ mechanism: "continuous", method: "autoregressive", fill: false });
          const sampling = createRowSampling(makeStepSampler(options, { tokenRepresentation: "device",
            grammarWait: "external", historyUpdate: "after-sample", initialHistory: ids }), token => {
            tokens.push(token);
            if (adapted && row === 0 && tokens.length === 2 && !joined) {
              joined = true; enqueue(batch - 1, true);
              // Queue the incompatible context only after the joiner; it must
              // wait until every adapter row (including the join) retires.
              expect(group.activeRows).toBeGreaterThan(0);
              expect(context()).toBe("upper");
              queuedBase = true; enqueue(batch, false);
              expect(group.pendingRows).toBeGreaterThan(0);
            }
            if (adapted && cancel && row === 1 && tokens.length === 3) abort.abort(new Error("boundary cancellation"));
          });
          samplers.push(sampling);
          jobs[row] = group.submit({ promptIds: ids, ...sampling, maxTokens: options.maxTokens, eosTokenIds: [],
            context: adapted ? binding.bindAdapterContext!(["upper"], "upper") : undefined,
            cacheNamespace: adapted ? adapters.cacheNamespace(["upper"]) : "", signal: abort.signal,
            onAdmitted() { expect(context()).toBe(adapted ? "upper" : ""); }, compiledDecode: false,
          }).then(stats => ({ status: "fulfilled", stats }), error => ({ status: "rejected", error }));
        };
        timer = setTimeout(() => { for (const abort of aborts) abort.abort(new Error("adapter lifecycle deadline")); }, 120_000);
        if (baseOnly) enqueue(batch, false);
        else for (let row = 0; row < batch - 1; row++) enqueue(row, true);
        held = false; group.kick();
        // The first row creates the late join and base promises before settling.
        if (!baseOnly) { await jobs[0]; expect(joined && queuedBase).toBe(true); }
        const results = await Promise.all(jobs.filter(Boolean));
        if (!baseOnly) {
          expect(Math.max(...widths)).toBe(batch);
          expect(new Set(active)).toEqual(new Set(["upper", ""]));
          const baseAt = active.indexOf("");
          expect(baseAt).toBeGreaterThan(0);
          expect(active.slice(baseAt).every(value => value === "")).toBe(true);
          if (cancel) {
            expect(results[1]).toMatchObject({ status: "rejected", error: { message: "boundary cancellation" } });
            expect(outputs[1]).toHaveLength(3);
          }
        }
        for (const [row, output] of outputs.entries()) {
          if (!output) continue;
          const result = await jobs[row]!;
          const expected = !baseOnly && row === 1 ? (cancel ? 3 : 4) : 16;
          expect(output).toHaveLength(expected);
          if (!baseOnly && cancel && row === 1) expect(result.status).toBe("rejected");
          else {
            expect(result.status).toBe("fulfilled");
            if (result.status === "fulfilled") expect(result.stats).toMatchObject({ generatedTokens: expected, finishReason: "length" });
          }
        }
        await drained();
        expect(group.activeRows + group.pendingRows).toBe(0);
        const beforeReuse = calls.length, baseTokens = outputs[batch]!.slice();
        // Reuse the very same scheduler after complete drain.
        enqueue(batch + 1, false);
        expect(await jobs[batch + 1]).toMatchObject({ status: "fulfilled", stats: { generatedTokens: 16, finishReason: "length" } });
        await drained();
        expect(outputs[batch + 1]).toHaveLength(16);
        expect(outputs[batch + 1]).toEqual(baseTokens);
        const baseCalls = calls.slice(0, beforeReuse).filter(call => (call as unknown[])[1] === "");
        expect(calls.slice(beforeReuse)).toEqual(baseCalls);
        return { calls: calls.slice(0, beforeReuse), outputs, widths, active };
      } finally {
        if (timer) clearTimeout(timer);
        for (const abort of aborts) abort.abort(new Error("test cleanup"));
        try { await group.close(); }
        finally {
          try { await Promise.all(jobs.filter(Boolean)); }
          finally {
            hidden?.mockRestore(); logits?.mockRestore();
            try { for (const sampler of samplers) sampler.dispose(); }
            finally { expect(model.loraState!.active).toEqual([]); }
          }
        }
      }
    };
    for (const batch of [2, 4]) {
      const cancelled = await scenario(batch, true), stopped = await scenario(batch, false);
      // One pending step is already dispatched at callback cancellation, so
      // a four-token length stop has the same physical forwards as abort at 3.
      expect(cancelled.calls).toEqual(stopped.calls);
      for (let row = 0; row < cancelled.outputs.length; row++)
        if (row !== 1) expect(cancelled.outputs[row]).toEqual(stopped.outputs[row]);
      expect(cancelled.outputs[1]).toEqual(stopped.outputs[1]!.slice(0, 3));
      const base = await scenario(batch, false, true);
      expect(cancelled.calls.filter(call => (call as unknown[])[1] === "")).toEqual(base.calls);
    }
  } finally { try { if (manager?.list().length) manager.unmount("upper"); } finally { weights.dispose(); } }
}, 900_000);

/** Explicit parity matrix; defaults retain the original bf16 fixture. */
async function continuationKv(promptLength: number) {
  const { KvScheme } = await import("@mlx-bun/inference/state/kv-scheme");
  const mode = Bun.env.MLX_BUN_TEST_CONTINUATION_KV ?? "bf16";
  const requestedStart = Bun.env.MLX_BUN_TEST_CONTINUATION_KV_START ?? "0";
  const start = requestedStart.startsWith("prompt+")
    ? promptLength + Number(requestedStart.slice(7)) : Number(requestedStart);
  const interruptAt = Number(Bun.env.MLX_BUN_TEST_CONTINUATION_INTERRUPT ?? 6);
  if (!Number.isSafeInteger(start) || start < 0 || !Number.isSafeInteger(interruptAt) || interruptAt < 6 || interruptAt >= 16)
    throw new Error("continuation fixture requires start>=0 and 6<=interrupt<16");
  let options: KvSchemeOptions = {};
  let kind: ConstructorParameters<typeof KvScheme>[0] = "bf16";
  if (mode === "4" || mode === "8") {
    kind = "affine-uniform";
    options = { kvBits: Number(mode), kvGroupSize: 64, quantizedKvStart: start };
  } else if (mode === "turbo") {
    kind = "turbo";
    options = { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: start };
  } else if (mode === "per-layer") {
    kind = "affine-config";
    options = { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 1, bits: 8, groupSize: 64 }], quantizedKvStart: start };
  } else if (mode !== "bf16") throw new Error(`unknown continuation KV fixture: ${mode}`);
  return { mode, start, interruptAt, options, scheme: new KvScheme(kind, options) };
}
