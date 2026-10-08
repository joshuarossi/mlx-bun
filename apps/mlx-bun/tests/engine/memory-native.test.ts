// Opt-in with real weights: the `memory` verb's in-process task-model client on
// the continuous gateway. Runs only with MLX_BUN_TEST_NATIVE=1 and needs
// mlx-community/gemma-4-e4b-it-OptiQ-4bit in the Hugging Face cache (found,
// never downloaded). MLX_BUN_APP_TEST_MEMORY_ADAPTER names the trained
// memory-chunk adapter directory to mount (read only); without it the chunk
// cases skip. Each stage must decode token-for-token like main's bit-exact
// greedy loop (LM-head-free prefill of ids[:-1], then raw forward + argmax,
// EOS excluded) run on the same model; the adapter must change the chunk stage
// and only it; a same-stage batch at width 3 must decode as one group. The
// full-logits and KV comparison against main itself is PR evidence, not this test.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { MemoryEngine } from "../../src/cli/memory-engine";
import type { MemoryCompletionRequest } from "@mlx-bun/module-memory/model";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const adapter = process.env.MLX_BUN_APP_TEST_MEMORY_ADAPTER;

describe.skipIf(!native)("memory task model on the continuous gateway", () => {
  let memory: { client: import("@mlx-bun/module-memory/model").MemoryCompletionClient; close(): Promise<void> };
  let engine: MemoryEngine | undefined;
  let restoreRuntime: () => void;
  let ops: typeof import("@mlx-bun/mlx/ops");
  let promptIds: (request: MemoryCompletionRequest) => number[];
  let requests: Record<"chunk" | "entity" | "route", MemoryCompletionRequest>;
  let entityRows: MemoryCompletionRequest[];

  beforeAll(async () => {
    ops = await import("@mlx-bun/mlx/ops");
    const { configureRuntime } = await import("@mlx-bun/inference/runtime/config");
    const { CHUNK_PROMPT, chunkInput, formatConversation } = await import("@mlx-bun/module-memory/chunk");
    const { buildEntityPrompt } = await import("@mlx-bun/module-memory/entity");
    const { memoryPromptIds } = await import("@mlx-bun/module-memory/model");
    const { createInProcessMemoryClient, defaultMemoryEngineDependencies: defaults } = await import("../../src/cli/memory-engine");
    restoreRuntime = configureRuntime({ MLX_BUN_MEMORY_BATCH: "3" });
    memory = createInProcessMemoryClient({
      ...defaults,
      engine: async (context, scheme, capacity) => (engine = await defaults.engine(context, scheme, capacity)),
      adapterDir: stage => stage === "chunk" ? adapter : undefined,
    });
    const policy = "Meta policy (synthetic): record durable facts about the user's projects and preferences.";
    const turns = Array.from({ length: 6 }, (_, i) => ({ position: i, role: i % 2 ? "assistant" : "user", uuid: `m${i}`,
      text: i % 2 ? `Step ${i}: compare the grinders by noise, price and grind consistency.` : `Question ${i}: which espresso grinder is quiet and under 400 dollars?` }));
    const note = (k: number) => `The user compared ${["a Baratza Encore", "a Niche Zero", "a hand grinder"][k]} for home espresso.${" They dial in shots each morning.".repeat(k + 1)}`;
    requests = {
      chunk: { stage: "chunk", input: chunkInput(CHUNK_PROMPT.replace("{{META_DOCS}}", policy) + formatConversation("Grinders", "conv-native", turns as never)), maxTokens: 256 },
      entity: { stage: "entity", input: { user: buildEntityPrompt(note(0), policy) }, maxTokens: 64 },
      route: { stage: "route", input: { user: `Is "Niche Zero" the same thing as "Niche" — a coffee grinder brand? Answer yes or no.` }, maxTokens: 8 },
    };
    entityRows = [0, 1, 2].map(k => ({ stage: "entity", input: { user: buildEntityPrompt(note(k), policy) }, maxTokens: 64 }));
    await memory.client.complete(requests.route); // loads the model and the engine
    const context = engine!.context;
    const tokenizer = context.tokenizer;
    promptIds = request => memoryPromptIds(request.stage, request.input,
      { encode: text => tokenizer.encode(text), bosTokenId: tokenizer.bosTokenId ?? -1 }, context.template!);
  }, 300_000);
  afterAll(async () => { await memory?.close(); restoreRuntime?.(); });

  /** Main's greedyDecodeBitExact, op for op, on the engine's own model while the gateway is held. */
  const reference = (request: MemoryCompletionRequest, adapters: string[]) => engine!.gateway.runExclusive(async () => {
    const context = engine!.context;
    const model = context.model as unknown as {
      loraState: { active: string[] }; makeCache(): { dispose(): void }[];
      forwardHidden(ids: MlxArray, cache: unknown[]): MlxArray; forward(tokens: number[], cache: unknown[]): MlxArray;
      config: { eosTokenIds: number[] };
    };
    const ids = promptIds(request);
    model.loraState.active = adapters;
    const cache = model.makeCache();
    try {
      const prompt = ids.slice(0, -1);
      for (let start = 0; start < prompt.length; start += 2048) {
        const chunk = prompt.slice(start, start + 2048);
        const input = ops.fromInt32(chunk, [1, chunk.length]);
        model.forwardHidden(input, cache).dispose();
        input.dispose();
      }
      const eos = new Set(model.config.eosTokenIds);
      const out: number[] = [];
      let last = ids.at(-1)!;
      for (let i = 0; i < request.maxTokens; i++) {
        const logits = model.forward([last], cache);
        const best = ops.argmaxAxis(logits, -1);
        logits.dispose();
        const token = ops.itemUint32(best);
        best.dispose();
        if (eos.has(token)) break;
        out.push(token);
        last = token;
      }
      return context.tokenizer.decode(out, true);
    } finally {
      model.loraState.active = [];
      for (const layer of cache) layer.dispose();
    }
  });

  test.skipIf(!adapter)("the chunk stage decodes with the adapter, and the next base stage without it, as main's greedy loop", async () => {
    expect(await memory.client.complete(requests.chunk)).toBe(await reference(requests.chunk, ["memory-chunk"]));
    expect(await memory.client.complete(requests.entity)).toBe(await reference(requests.entity, []));
    // The same rendered prompt as a base stage runs without the adapter and decodes differently.
    const base = { ...requests.chunk, stage: "entity" };
    const [withAdapter, without] = [await memory.client.complete(requests.chunk), await memory.client.complete(base)];
    expect(without).toBe(await reference(base, []));
    expect(withAdapter).not.toBe(without);
  }, 300_000);

  test("base stages decode token-for-token as main's greedy loop", async () => {
    for (const request of [requests.route, requests.entity])
      expect(await memory.client.complete(request)).toBe(await reference(request, []));
  }, 300_000);

  test("a same-stage batch at width 3 decodes as one group, in input order, reproducibly", async () => {
    const model = engine!.context.model as unknown as { forwardHidden(ids: MlxArray, cache: unknown[]): MlxArray };
    const forwardHidden = model.forwardHidden;
    let widest = 0;
    model.forwardHidden = function (ids, cache) { widest = Math.max(widest, ids.shape[0]!); return forwardHidden.call(this, ids, cache); };
    try {
      const first = await memory.client.completeBatch(entityRows);
      expect(widest).toBe(3);
      expect(first).toHaveLength(3);
      expect(await memory.client.completeBatch(entityRows)).toEqual(first);
    } finally { model.forwardHidden = forwardHidden; }
  }, 300_000);

  test("a closed client refuses work", async () => {
    await memory.close();
    await expect(memory.client.complete(requests.route)).rejects.toThrow("closed");
  });
});

// `serve`'s own synthesis: the real direct composition serving a small model
// (MLX_BUN_APP_TEST_MODEL, not e4b) runs GET /v1/memory/synthesize over SSE on
// the memory task model loaded in the server process by that run, never on the
// served model. Needs a temporary HOME (the registry and the adapter link live
// there); with MLX_BUN_APP_TEST_MEMORY_ADAPTER the adapter is linked read only.
const servedModel = process.env.MLX_BUN_APP_TEST_MODEL;
test.skipIf(!native || !servedModel)("serve's own synthesis runs on the task model it loads, not on the served model", async () => {
  const { mkdirSync, mkdtempSync, realpathSync, readdirSync, rmSync, statSync, symlinkSync, writeFileSync } = await import("node:fs");
  const { homedir, tmpdir } = await import("node:os");
  const { join } = await import("node:path");
  if (![realpathSync(tmpdir()), "/private/tmp"].some(dir => realpathSync(homedir()).startsWith(`${dir}/`))) throw new Error("run with a temporary HOME");
  if (adapter) {
    const { storagePath } = await import("../../src/storage/paths");
    mkdirSync(storagePath("adapters"), { recursive: true });
    symlinkSync(adapter, join(storagePath("adapters"), "memory-chunk"));
  }
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { scanSnapshot } = await import("@mlx-bun/hub/registry");
  const { MEMORY_TASK_MODEL, locateTaskModel } = await import("@mlx-bun/module-memory/model");
  const model = await scanSnapshot(servedModel!, "test-model");
  if (!model) throw new Error("MLX_BUN_APP_TEST_MODEL has no loadable checkpoint");
  const { activeMemory } = await import("@mlx-bun/mlx/ffi");
  const snapshot = await locateTaskModel(MEMORY_TASK_MODEL);
  const taskBytes = readdirSync(snapshot).filter(name => name.endsWith(".safetensors")).reduce((sum, name) => sum + statSync(realpathSync(join(snapshot, name))).size, 0);
  const root = mkdtempSync(join(tmpdir(), "mlx-serve-synthesis-"));
  const vault = join(root, "vault");
  mkdirSync(join(vault, "articles"), { recursive: true });
  writeFileSync(join(vault, "articles", "Alpha.md"), "# Alpha\n\nAlpha is a test article about lenses. See [[Beta]].\n");
  writeFileSync(join(vault, "articles", "Beta.md"), "# Beta\n\nBeta links to [[Alpha]].\n");
  const options = parseServeOptions({ values: { port: "0", "max-tokens": "8", "prompt-cache": "0.125", "no-open": true, "in-process": true }, positionals: [] });
  options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
  options.memoryPaths = { vault, skills: join(root, "skills") };
  options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
  const app = await startModelServer(model, options);
  try {
    const base = `http://127.0.0.1:${app.port}`;
    const lookups = async () => { const { prompt_cache } = await (await fetch(`${base}/stats`)).json() as { prompt_cache: { hits: number; misses: number } };
      return prompt_cache.hits + prompt_cache.misses; };
    // The counter sees a served completion...
    const before = await lookups();
    const served = await fetch(`${base}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ model: model.repoId, max_tokens: 4, temperature: 0, messages: [{ role: "user", content: "Say hi." }] }) });
    expect(served.status).toBe(200);
    const afterServed = await lookups();
    expect(afterServed).toBeGreaterThan(before);
    const resident = activeMemory();
    // ...and none during synthesis, which loads the task model into this process and keeps it.
    const text = await (await fetch(`${base}/v1/memory/synthesize`)).text();
    expect(text).toContain('"type":"summary"');
    expect(text.trim().endsWith("data: [DONE]")).toBe(true);
    expect(text).not.toContain('"type":"error"');
    // The wikify sweep reached the model and was not skipped by a model error.
    expect(text).toContain("wikify");
    expect(text).not.toContain("skipped (error");
    expect(await lookups()).toBe(afterServed);
    expect(activeMemory() - resident).toBeGreaterThan(0.8 * taskBytes);
  } finally {
    await app.close();
    rmSync(root, { recursive: true, force: true });
  }
}, 600_000);
