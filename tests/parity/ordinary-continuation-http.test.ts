// Exclusive GPU; actual HTTP transport and fresh server/cache/weight lifetimes.
import { expect, test, spyOn } from "bun:test";
import { existsSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { continuationKv } from "./helpers/continuation-kv";
function cacheFiles(directory: string): string[] {
  return readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? cacheFiles(path) : entry.name.endsWith(".mlxkv") ? [path] : [];
  });
}
const target = Bun.env.MLX_BUN_TEST_CONTINUATION_MODEL ?? `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb`;
const adapter = Bun.env.MLX_BUN_TEST_CONTINUATION_ADAPTER === "1";
const enabled = Bun.env.MLX_BUN_TEST_ORDINARY_CONTINUATION === "1" && existsSync(`${target}/config.json`) && (!adapter || existsSync("fixtures/adapters/upper/adapters.safetensors"));

test.skipIf(!enabled)("ordinary checkpoint HTTP interruption, flush and restart preserve held B1/B4 output", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { legacyCompiledDecodeAvailable } = await import("../../src/backends/mlx/autoregressive");
  const { createServer, shutdownServer } = await import("../../src/server");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { AdapterManager } = await import("../../src/lora");
  const { resolveModelProfile } = await import("../../src/model/profile");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { CompiledDecode } = await import("../../src/model/compiled-decode");
  const { SsdCacheStore } = await import("../../src/ssd-cache");
  const { readKvHeader } = await import("../../src/kv-store");
  const { clearCache } = await import("../../src/mlx/ffi");
  const config = await loadModelConfig(target);
  const tokenizer = await loadTokenizer(target), template = await ChatTemplate.load(target);
  const prompt = "Count upwards, continuing the sequence: 1, 2, 3,";
  const kv = continuationKv(tokenizer.encode(prompt).length);
  const directory = mkdtempSync(join(tmpdir(), "ordinary-continuation-http-"));
  const serialRestoredUsage = new Map<boolean, { prompt: number; cached: number }>();
  try {
    for (const { batch, requests, compiled, mixed } of [
      { batch: 1, requests: 1, compiled: false, mixed: false },
      { batch: 4, requests: 1, compiled: false, mixed: false },
      { batch: 4, requests: 4, compiled: false, mixed: false },
      { batch: 1, requests: 1, compiled: true, mixed: false },
      { batch: 4, requests: 1, compiled: true, mixed: false },
      { batch: 4, requests: 4, compiled: true, mixed: false },
      { batch: 4, requests: 2, compiled: false, mixed: true },
    ].filter(arm => (!adapter || (!arm.compiled && !arm.mixed)) && (kv.mode === "bf16" || Bun.env.MLX_BUN_TEST_CONTINUATION_EXPANDED === "1" || (!arm.compiled && !arm.mixed)))) {
      const checkpointRows = mixed ? 1 : requests;
      const arm = `${batch}-${requests}-${compiled}-${mixed}`;
      const run = async (name: string, interrupt: boolean, useAdapter = adapter, retainedCheckpoints = 0) => {
        // Packed models install a weights view during construction. Each fresh
        // server owns fresh handles, even when the shard files are unchanged.
        const weights = await Weights.open(target);
        try {
          const model = createModel(weights, config);
          const canCompile = legacyCompiledDecodeAvailable(model);
          const context = { model, tokenizer, template,
            profile: resolveModelProfile(model.config), modelId: "continuation-http", adapters: new AdapterManager(model),
            kvConfig: kv.options.kvConfig ?? null, genDefaults: {}, vision: null, loadVision: null,
            visionTokenIds: { imageTokenId: 0, boiTokenId: 0, eoiTokenId: 0 }, audio: null, loadAudio: null, audioTokenIds: null };
          const widths: number[] = [];
          const activeContexts: string[][] = [];
          const forward = model.forwardHidden.bind(model);
          const graph = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
            widths.push(ids.shape[0]!);
            activeContexts.push([...model.loraState!.active]); return forward(ids, caches);
          });
          const fullForward = model.forward.bind(model);
          const fullGraph = spyOn(model, "forward").mockImplementation((...args) => {
            activeContexts.push([...model.loraState!.active]); return fullForward(...args);
          });
          const groups = new Set<InstanceType<typeof MlxBatchExecutionGroup>>();
          const retracesBefore = CompiledDecode.unexpectedRetraces;
          let compiledSteps = 0, eligibleCompiledChecks = 0;
          const compiledDtypes = new Set<number>();
          const supports = CompiledDecode.supports;
          const compiledSupport = spyOn(CompiledDecode, "supports").mockImplementation(caches => {
            const result = supports(caches); if (result) eligibleCompiledChecks++; return result;
          });
          const step = CompiledDecode.prototype.step;
          const compiledCalls = spyOn(CompiledDecode.prototype, "step").mockImplementation(function (this: ReturnType<typeof CompiledDecode.for>, ...args) {
            if (Bun.env.MLX_BUN_TEST_CONTINUATION_TRACE === "1" && !compiledDtypes.has(args[0].dtype)) {
              compiledDtypes.add(args[0].dtype);
              console.log("[continuation compiled dtype]", { batch, requests, name, interrupt, step: compiledSteps,
                dtype: args[0].dtype, shape: args[0].shape, offset: args[1][0]?.offset });
            }
            const result = step.apply(this, args);
            if (batch > 1) expect([...groups].some(group => group.activeRows === 1)).toBe(true);
            widths.push(args[0].shape.reduce((size, dim) => size * dim, 1));
            compiledSteps++; return result;
          });
          let capturedWithGrammar = 0;
          const grammarRows = new Set<NonNullable<Parameters<InstanceType<typeof MlxBatchExecutionGroup>["submit"]>[0]["grammar"]>>();
          const submit = MlxBatchExecutionGroup.prototype.submit;
          const membership = spyOn(MlxBatchExecutionGroup.prototype, "submit").mockImplementation(function (this: InstanceType<typeof MlxBatchExecutionGroup>, request) {
            groups.add(this);
            if (request.grammar) { expect(request.continuation).toBeUndefined(); grammarRows.add(request.grammar); }
            if (request.continuation) {
              const capture = request.continuation.captureOwned;
              request.continuation.captureOwned = state => {
                if (this.activeRows === requests && [...grammarRows].some(grammar => !grammar.isTerminated)) capturedWithGrammar++;
                capture(state);
              };
            }
            return submit.call(this, request);
          });
          const server = createServer(context, 0, { batch, hostname: "127.0.0.1", ...kv.serverOptions,
            promptCacheBytes: 1024 ** 3, ssdCacheDir: join(directory, `${arm}-${name}`), generationCheckpointTokens: 4 });
          const base = `http://127.0.0.1:${server.port}`;
          if (adapter) {
            const mounted = await fetch(`${base}/v1/adapters`, { method: "POST",
              headers: { "content-type": "application/json" },
              body: JSON.stringify({ id: "upper", path: join(import.meta.dir, "../../fixtures/adapters/upper") }) });
            expect(mounted.status).toBe(200);
          }
          const namespace = useAdapter ? context.adapters.cacheNamespace(["upper"]) : "";
          const aborts = Array.from({ length: requests }, () => new AbortController());
          const tokens: number[][] = Array.from({ length: requests }, () => []);
          let active = 0;
          let arrivals = 0, release!: () => void;
          const ready = new Promise<void>(resolve => { release = resolve; });
          const timer = setTimeout(release, 5000);
          const original = GenerationGateway.prototype.run;
          const admission = spyOn(GenerationGateway.prototype, "run").mockImplementation(async function (this: InstanceType<typeof GenerationGateway>, ...args) {
            active++;
            try {
              const row = args[1].seed! - 734;
              // Adapter fixtures disable EOS identically in control/restart/base arms so
              // even an adapter that emits an early EOS reaches the checkpoint boundary.
              args[1] = { ...args[1], snapshotAt: 0, ...(adapter ? { eosTokenIds: [] } : {}) };
              const placement = args[5];
              if (!placement.execution) throw new Error("HTTP fixture requires resolved execution");
              args[5] = { ...placement, execution: { ...placement.execution, compiledDecode: compiled } }; // Same resolved policy for control, interruption and resume.
              if (++arrivals === requests) release();
              await ready;
              const sink = args[2];
              args[2] = async (token, extras) => {
                tokens[row]!.push(token);
                const result = await sink(token, extras);
                if (interrupt && tokens[row]!.length === kv.interruptAt) {
                  aborts[row]!.abort();
                  throw new Error("intentional HTTP disconnect at committed output boundary");
                }
                return result;
              };
              return await original.apply(this, args);
            } finally { active--; }
          });
          const restoredKeys: string[] = [];
          const restore = SsdCacheStore.prototype.restore;
          const restored = spyOn(SsdCacheStore.prototype, "restore").mockImplementation(function (this: InstanceType<typeof SsdCacheStore>, ...args) {
            const result = restore.apply(this, args);
            if (result?.header.generationCheckpoint) restoredKeys.push(result.header.generationCheckpoint.key);
            return result;
          });
          try {
            const before = await (await fetch(`${base}/stats`)).json() as any;
            const outcomes = await Promise.allSettled(Array.from({ length: requests }, async (_, row) => {
              const response = await fetch(`${base}/v1/completions`, { method: "POST", signal: aborts[row]!.signal,
                headers: { "content-type": "application/json" }, body: JSON.stringify({
                  prompt, temperature: 0.7, seed: 734 + row, ...(useAdapter ? { adapter: "upper" } : {}),
                  ...(mixed && row === 1 ? { guided_choice: ["One two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty twenty-one twenty-two twenty-three twenty-four twenty-five twenty-six twenty-seven twenty-eight twenty-nine thirty."] } : {}),
                  max_tokens: 32, stream: true, stream_options: { include_usage: true },
                }) });
              expect(response.status).toBe(200);
              const text = await response.text();
              const events = text.split("\n").filter(line => line.startsWith("data: ") && line !== "data: [DONE]")
                .map(line => JSON.parse(line.slice(6)));
              const streamErrors = events.filter(event => event.error);
              if (streamErrors.length) throw new Error(`HTTP SSE error: ${JSON.stringify(streamErrors)}`);
              const usage = events.find(event => event.usage)?.usage;
              if (!usage) console.log("[continuation-http missing usage]", { batch, requests, name, text });
              expect(usage).toBeDefined();
              expect(usage.prompt_tokens_details.cached_tokens).toBeLessThanOrEqual(usage.prompt_tokens);
              expect(usage.lane).toBe(batch === 1 ? "serial" : "batched");
              return { text: events.map(event => event.choices?.[0]?.text ?? "").join(""), usage };
            }));
            const errors = outcomes.flatMap(outcome => outcome.status === "rejected" ? [String(outcome.reason)] : []);
            if (errors.length) console.log("[continuation-http outcomes]", { batch, requests, name, interrupt, errors, tokens });
            // Serial work is not represented by batch row counters.
            for (let i = 0; i < 1000 && active; i++) await Bun.sleep(5);
            expect(active).toBe(0);
            if (!interrupt) for (const outcome of outcomes) if (outcome.status === "rejected") throw outcome.reason;
            const flushed = await (await fetch(`${base}/admin/cache/flush`, { method: "POST",
              headers: { "content-type": "application/json" }, body: "{}" })).json() as any;
            expect(flushed.durable).toBe(true);
            if (batch > 1) expect(widths).toContain(requests);
            if (compiled && canCompile && requests === 1 && (kv.mode === "bf16" || eligibleCompiledChecks > 0)) expect(compiledSteps).toBeGreaterThan(0);
            if (compiled) console.log("[continuation compiled]", { batch, requests, name, mode: kv.mode, eligibleCompiledChecks, compiledSteps });
            if (!compiled) expect(compiledSteps).toBe(0);
            expect(CompiledDecode.unexpectedRetraces).toBe(retracesBefore);
            if (mixed) expect(capturedWithGrammar).toBeGreaterThan(0);
            if (interrupt) expect(tokens.map(row => row.length)).toEqual(Array(requests).fill(kv.interruptAt));
            else expect(outcomes.every(outcome => outcome.status === "fulfilled")).toBe(true);
            const after = await (await fetch(`${base}/stats`)).json() as any;
            const headers = cacheFiles(join(directory, `${arm}-${name}`)).map(readKvHeader)
              .filter(header => header.generationCheckpoint);
            if (adapter) {
              expect(activeContexts.length).toBeGreaterThan(0);
              expect(activeContexts.every(ids => JSON.stringify(ids) === JSON.stringify(useAdapter ? ["upper"] : []))).toBe(true);
              expect(model.loraState!.active).toEqual([]);
            }
            if (interrupt) {
              expect(headers).toHaveLength(checkpointRows);
              for (const header of headers) {
                if (adapter) expect(header.generationCheckpoint!.cacheNs).toBe(namespace);
                const checkpoint = header.generationCheckpoint!;
                const row = checkpoint.seed - 734;
                expect(checkpoint.generatedTokens).toBeGreaterThan(0);
                if (kv.mode !== "bf16" && kv.start > 0) {
                  const minimum = Math.max(0, ...header.caches.map(cache => cache.minimumReusableOffset ?? 0));
                  if (header.tokens.length < kv.start) expect(minimum).toBe(0);
                  else expect(minimum).toBeGreaterThanOrEqual(kv.start);
                }
                expect(header.tokens.slice(checkpoint.originalPromptTokens)).toEqual(tokens[row]!.slice(0, checkpoint.generatedTokens));
                expect(checkpoint.pendingToken).toBe(tokens[row]![checkpoint.generatedTokens]!);
              }
            } else expect(headers).toHaveLength(retainedCheckpoints);
            return { tokens, outcomes, before, after, headers, restoredKeys };
          } finally {
            clearTimeout(timer); admission.mockRestore(); graph.mockRestore(); fullGraph.mockRestore(); restored.mockRestore(); membership.mockRestore(); compiledCalls.mockRestore(); compiledSupport.mockRestore();
            const stopped = await shutdownServer(server);
            expect(stopped.durability.durable).toBe(true);
            if (adapter) context.adapters.unmount("upper");
            if (canCompile) CompiledDecode.for(model as import("../../src/model/gemma4").Gemma4Model).dispose(); clearCache();
          }
        } finally { weights.dispose(); clearCache(); }
      };
      const control = await run("control", false);
      const interrupted = await run("restart", true);
      if (adapter) {
        const baseControl = await run("base-control", false, false);
        const isolated = await run("restart", false, false, checkpointRows);
        expect(isolated.restoredKeys).toEqual([]);
        expect(isolated.tokens).toEqual(baseControl.tokens);
        expect(isolated.headers).toEqual(interrupted.headers);
      }
      const resumed = await run("restart", false);
      expect(resumed.before.ssd_cache.restores).toBe(0);
      expect(resumed.after.ssd_cache.restores).toBeGreaterThanOrEqual(checkpointRows);
      expect(resumed.restoredKeys.sort()).toEqual(interrupted.headers.map(header => header.generationCheckpoint!.key).sort());
      let comparison = control;
      if (mixed) {
        const matchedInterrupted = await run("matched", true);
        comparison = await run("matched", false);
        const checkpointState = (result: typeof interrupted) => result.headers.map(header => ({
          tokens: header.tokens, caches: header.caches, checkpoint: header.generationCheckpoint }));
        expect(checkpointState(matchedInterrupted)).toEqual(checkpointState(interrupted));
        expect(resumed.tokens.slice(0, checkpointRows)).toEqual(control.tokens.slice(0, checkpointRows));
        expect(interrupted.tokens).toEqual(control.tokens.map(tokens => tokens.slice(0, kv.interruptAt)));
      }
      expect(resumed.tokens).toEqual(comparison.tokens);
      for (const [row, outcome] of resumed.outcomes.entries()) {
        if (mixed && row === 1) continue;
        expect(outcome.status).toBe("fulfilled");
        if (outcome.status !== "fulfilled") throw outcome.reason;
        const usage = outcome.value.usage;
        const counts = { prompt: usage.prompt_tokens, cached: usage.prompt_tokens_details.cached_tokens };
        expect(counts.cached).toBe(counts.prompt);
        if (batch === 1) serialRestoredUsage.set(compiled, counts);
        else expect(counts).toEqual(serialRestoredUsage.get(compiled)!);
      }
      const values = (result: typeof control) => result.outcomes.map(outcome => outcome.status === "fulfilled"
        ? { text: outcome.value.text, completion: outcome.value.usage.completion_tokens } : null);
      expect(values(resumed)).toEqual(values(comparison));
    }
  } finally { clearCache(); rmSync(directory, { recursive: true, force: true }); }
}, 1_200_000);
