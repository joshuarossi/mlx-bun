import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { BuiltPrompt, ContextOwnership, DurabilityFlushResult, LoadedModelContext, ModelBinding, ModelPromptBuilder,
  RunningServer, ServerOptions, ServerShutdownResult } from "mlx-bun/server";

// The public `mlx-bun/server` entry: main's in-process createServer over a
// caller's context, composed as `mlx-bun serve` composes its app. Each example
// runs in a child Bun process with native MLX blocked, a temporary HOME, and
// the offline hub. Only the native edges are replaced: the allocator limit, the
// cache services (their storage is native), and Pi's agent (its own tests
// cover it). The engine, scheduler, routes, listener, web app, and persistent
// state are the real ones; the model is a supplied binding over a synthetic
// config, as in main's tests/serve/model-replacement.test.ts.

const app = resolve(import.meta.dir, "..") + "/";

async function runChild(script: string) {
  const scratch = mkdtempSync(join(tmpdir(), "mlx-server-entry-"));
  const home = join(scratch, "home");
  try {
    const child = Bun.spawn([process.execPath, "--no-env-file", "--eval", script], { stdout: "pipe", stderr: "pipe", cwd: app,
      // Bun's own runtime transpiler cache would otherwise land under HOME
      // (Library/Caches/bun); disable it so the HOME assertions see only the app.
      env: { ...process.env, MLX_BUN_LIBMLXC: "/does-not-exist", HF_HUB_OFFLINE: "1", HF_TOKEN: "", HOME: home, MLX_BUN_HOME: join(home, ".mlx-bun"),
        HF_HUB_CACHE: join(scratch, "hub"), SCRATCH: scratch, BUN_RUNTIME_TRANSPILER_CACHE_PATH: "0" } });
    const deadline = setTimeout(() => child.kill("SIGKILL"), 18_000);
    try {
      const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
      return { code, stdout, stderr };
    } finally { clearTimeout(deadline); }
  } finally { rmSync(scratch, { recursive: true, force: true }); }
}

/** The child's fixtures: a synthetic qwen3 directory, a supplied binding whose
 * two methods are chosen by temperature, a recording cache service, the
 * allocator port, and a caller context loaded through the public loadContext. */
const prelude = (mocks = "") => `
  import { mock } from "bun:test";
  import { strict as assert } from "node:assert";
  import { mkdirSync, readdirSync, statSync, writeFileSync } from "node:fs";
  import { join, relative } from "node:path";
  import { configureRuntime, runtimeConfig } from "@mlx-bun/inference/runtime/config";
  import { resolveKvScheme } from "@mlx-bun/inference/state/kv-scheme";
  const app = ${JSON.stringify(app)}, scratch = process.env.SCRATCH, home = process.env.HOME;
  const events = [];
  let limit = 77;
  mock.module("@mlx-bun/mlx/ffi", () => ({ setMemoryLimit(bytes) { events.push("allocator " + bytes); const previous = limit; limit = bytes; return previous; } }));
  const caches = { calls: [], fail: false, durable: true, closeFails: false };
  mock.module(app + "src/engine/cache-services.ts", () => ({ async createCacheServices(context, binding, options) {
    caches.calls.push({ binding, options });
    if (caches.fail) throw new Error("cache composition failed");
    const resolvedKvScheme = resolveKvScheme({ override: options.kvQuant, config: context.kvConfig });
    const pending = () => caches.durable ? { pendingSnapshots: 0, pendingSpills: 0, pendingSpillBytes: 0, droppedSpills: 0, failedSpills: 0 }
      : { pendingSnapshots: 1, pendingSpills: 2, pendingSpillBytes: 64, droppedSpills: 0, failedSpills: 1 };
    const result = () => ({ ...pending(), durable: caches.durable, flushedSnapshots: 1, missingSnapshots: 0, elapsedMs: 1 });
    return { resolvedKvScheme, kvScheme: resolvedKvScheme.generationOptions, stateCodecs: {}, checkpoints: null, continuationServices: {},
      adapterNamespace: () => "", stats: pending, flush: async () => result(), stopIdleDemotion() {},
      promptCache: { peekPrefixLen: () => 0, size: 0, totalBytes: 0, maxBytes: 0, hits: 0, misses: 0, sessionHits: 0, sessionMisses: 0,
        prefixScans: 0, objectHits: 0, objectMisses: 0, objectRestores: 0, demotions: 0, closeSession() {} },
      async close() { events.push("cache close"); if (caches.closeFails) throw new Error("cache close failed"); return result(); } };
  } }));
  mock.module(app + "src/chat/pi-backend.ts", () => ({ createPiBackend(options) { return send => ({
    async start() { send({ type: "text_delta", delta: ["pi", options.modelId, options.port(), options.thinking].join(" ") }); },
    async handle() {}, dispose() {} }); } }));
  ${mocks}
  const dir = join(scratch, "model");
  mkdirSync(dir);
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 16, num_hidden_layers: 1,
    num_attention_heads: 2, num_key_value_heads: 1, head_dim: 8, intermediate_size: 32, vocab_size: 16,
    max_position_embeddings: 4096, eos_token_id: 0 }));
  const selected = [], prompts = [], hold = { next: false };
  let config;
  const group = { activeRows: 0, pendingRows: 0, projectedKvBytes: 0, kvBudgetBytes: undefined, kick() {}, async close() {},
    async submit(request) {
      selected.push(request.method.id);
      if (hold.next) {
        hold.next = false;
        await request.onToken(1);
        await new Promise((_, reject) => {
          const abort = () => { events.push("aborted"); reject(request.signal.reason); };
          if (request.signal.aborted) abort(); else request.signal.addEventListener("abort", abort, { once: true });
        });
      }
      await request.onToken(request.method.id === "custom-exact" ? 1 : 2);
      return { promptTokens: 3, cachedTokens: 0, generatedTokens: 1, finishReason: "stop", prefillMs: 0, decodeMs: 0 };
    } };
  // No RuntimeModel, forward(), makeCache(), or native weights: this binding is the model.
  const binding = (stateCompatibility = "synthetic-runtime-v1") => ({ stateCompatibility,
    gateway: { config, runtime: runtimeConfig(), cachesBatchable: () => true, kvBatchable: () => false,
      plan: (_shape, options) => ({ method: options.temperature === 0 ? "custom-exact" : "custom-alternate", mechanism: "continuous",
        pagedKv: false, promptCache: false, checkpoint: false, fill: false, compiledDecode: false, grammarJump: false, reasons: [] }),
      methodRequest: execution => ({ id: execution.method }), createBatchGroup: () => group, configureContinuation() {} },
    restore: () => null, signal: async () => ({ bins: [1], vocab: 16 }),
    diagnostics: () => ({ custom_model: { method_count: 2 } }),
    discovery: { adapters: false, training: false, dsa: false, embeddings: false } });
  const buildPrompt = async () => { prompts.push("built");
    return { promptIds: [3, 4, 5], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null }; };
  const { createServer, loadContext } = await import("mlx-bun/server");
  // The app's modules load before any count: the Pi SDK's proper-lockfile installs
  // signal-exit's re-raising listeners at module load, as under mlx-bun serve.
  await Promise.all([import(app + "src/cli/serve.ts"), import(app + "src/cli/serve-host.ts"), import(app + "src/cli/memory-engine.ts")]);
  let opens = 0;
  const implementations = { select(resolved) {
    assert.equal(resolved.modelType, "qwen3");
    return { id: "independent", async create(source, loaded, profile) {
      opens++; assert.equal(source.modelDir, dir); config = loaded;
      const context = { model: { config: loaded, weightsBytes: 0 }, profile, modelId: "independent-model", disposals: 0,
        tokenizer: { encode: () => [3, 4, 5], decode: ids => ids.map(id => "t" + id).join(""), idToToken: id => "t" + id, bosTokenId: null, eosTokenId: 0 },
        template: { render: () => "<rendered>", supportsThinking: false, thinkingFormat: "none" },
        adapters: { resolveSpec: () => [], cacheNamespace: () => "", list: () => [], get: () => undefined,
          async mount() { throw new Error("unsupported"); }, unmount: () => 0 },
        kvConfig: null, genDefaults: {}, draft: null, memoryPlan: null, vision: null, loadVision: null, audio: null, loadAudio: null,
        audioTokenIds: null, visionTokenIds: { imageTokenId: 1, boiTokenId: 2, eoiTokenId: 3 },
        dispose() { context.disposals++; events.push("model dispose"); } };
      return context;
    } };
  } };
  const opened = await loadContext(dir, "independent-model", { implementations });
  /** Another caller context over the same config, with its own disposal count. */
  const another = (overrides = {}) => { const context = { ...opened, disposals: 0, ...overrides };
    context.dispose = () => { context.disposals++; events.push("model dispose"); }; return context; };
  const signals = () => ["SIGINT", "SIGTERM", "SIGHUP"].map(signal => process.listenerCount(signal));
  const post = (base, path, body, signal) => fetch(base + path, { method: "POST", signal,
    headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
  const chat = async (base, temperature = 0) => {
    const response = await post(base, "/v1/chat/completions", { messages: [{ role: "user", content: "hello" }], temperature, max_tokens: 4 });
    const text = await response.text();
    assert.equal(response.status, 200, text);
    return JSON.parse(text).choices[0].message.content;
  };
  const socketFrame = base => new Promise((resolve, reject) => {
    const socket = new WebSocket(base.replace("http:", "ws:") + "/ws/chat");
    socket.addEventListener("message", event => { resolve(JSON.parse(event.data)); socket.close(); }, { once: true });
    socket.addEventListener("error", () => reject(new Error("chat socket failed")), { once: true });
  });
  const tree = root => { const out = [];
    const walk = path => { for (const name of readdirSync(path)) { const child = join(path, name); out.push(relative(root, child)); if (statSync(child).isDirectory()) walk(child); } };
    try { walk(root); } catch (error) { if (error.code !== "ENOENT") throw error; }
    return out.sort(); };
`;

test("the entry imports through the export map without native MLX or side effects and exposes exactly its values", async () => {
  const child = Bun.spawn([process.execPath, "--no-env-file", "-e", `
    const signals = () => [process.listenerCount("SIGINT"), process.listenerCount("SIGTERM")];
    const before = signals();
    const entry = await import("mlx-bun/server");
    const manifest = (await import("mlx-bun/package.json")).default;
    console.log(JSON.stringify({ keys: Object.keys(entry).sort(), name: manifest.name, version: manifest.version,
      signals: signals().join() === before.join() }));`], {
    cwd: app, stdout: "pipe", stderr: "pipe", env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/mlx-server-import-test.dylib" },
  });
  const deadline = setTimeout(() => child.kill("SIGKILL"), 10_000);
  try {
    const [stdout, stderr, code] = await Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text(), child.exited]);
    expect({ code, stderr }).toEqual({ code: 0, stderr: "" });
    // main's package.json subpath is exported again, next to the entry.
    const { version } = JSON.parse(readFileSync(join(app, "package.json"), "utf8"));
    expect(JSON.parse(stdout)).toEqual({ keys: ["createServer", "loadContext"], name: "mlx-bun", version, signals: true });
  } finally { clearTimeout(deadline); }
  // The public types, including main's prompt-builder contract (the typecheck covers them).
  const built: BuiltPrompt = { promptIds: [1], vision: undefined, startInThinking: false, probeStableLen: false, diffusionPixels: null };
  const builder: ModelPromptBuilder = async () => built;
  const ownership: ContextOwnership = "borrowed";
  const options: ServerOptions = { hostname: "127.0.0.1", buildPrompt: builder, ownership, binding: undefined as ModelBinding | undefined,
    artifact: { sizeBytes: 1 }, cache: { promptCacheBytes: 0 } };
  const shutdown = (durability: DurabilityFlushResult): ServerShutdownResult => ({ stopped: true, timedOut: false, durability });
  const server = null as RunningServer | null, context = null as LoadedModelContext | null;
  expect([options.ownership, typeof shutdown, server, context]).toEqual(["borrowed", "function", null, null]);
});

test("one caller context and one supplied binding serve the full app across five sequential servers (main's model replacement)", async () => {
  const result = await runChild(prelude(`
    // No registry is consulted to create or serve; only the hub route opens one.
    const hub = await import("@mlx-bun/hub/registry");
    const Real = hub.Registry, registry = { allowed: false };
    mock.module("@mlx-bun/hub/registry", () => ({ ...hub, Registry: class extends Real {
      constructor(...args) { if (!registry.allowed) throw new Error("registry opened"); super(...args); } } }));
  `) + `
    assert.equal(opens, 1);
    const before = signals(), whisper = { modelDir: join(scratch, "whisper"), modelId: "org/whisper" };
    const first = binding();
    let server = await createServer(opened, 0, { hostname: "127.0.0.1", capacity: 1, binding: first, buildPrompt,
      memoryBudgetBytes: 8e9, artifact: { sizeBytes: 123, expertsBytes: 0 }, whisper, cache: { promptCacheBytes: 0 } });
    assert.deepEqual(signals(), before, "no signal handlers");
    assert.deepEqual(tree(home), [], "creating the server writes nothing under HOME");
    assert.deepEqual(events, ["allocator 8000000000"]);
    assert.equal(caches.calls[0].binding, first, "the supplied binding reaches cache composition as given");
    let base = "http://127.0.0.1:" + server.port;
    // The binding's two methods run through the real engine, chosen per request.
    assert.equal(await chat(base, 0), "t1");
    assert.equal(await chat(base, 1), "t2");
    assert.deepEqual(selected, ["custom-exact", "custom-alternate"]);
    assert.equal(prompts.length, 2, "the supplied prompt builder built both prompts");
    const models = await (await fetch(base + "/v1/models")).json();
    assert.deepEqual([models.data[0].id, models.data[0].embeddings, models.data[0].adapters], ["independent-model", false, false]);
    assert.ok(models.data.some(model => model.id === "org/whisper"), "the Whisper companion option threads through");
    assert.equal((await post(base, "/v1/embeddings", { input: "hello" })).status, 400);
    const stats = await (await fetch(base + "/stats")).json();
    assert.deepEqual(stats.custom_model, { method_count: 2 });
    assert.deepEqual(stats.kv_quant, { mode: "bf16", layers: { bf16: 1 }, attention: { global: 1, sliding_window: 0 }, recurrent_layers: 0 });
    assert.equal(stats.server.owner, "embedded"); assert.equal(stats.batch.configured, 1);
    assert.equal(stats.admission.memory_budget_bytes, 8e9);
    // The full app: browser assets, persistent route groups, Pi chat on /ws/chat.
    const page = await fetch(base + "/");
    assert.ok(page.headers.get("content-type").startsWith("text/html")); await page.arrayBuffer();
    assert.deepEqual(await (await fetch(base + "/health")).json(), { status: "ok" });
    assert.deepEqual(await (await fetch(base + "/api/sessions/search?q=hello")).json(), { ok: true, results: [] });
    assert.deepEqual(await (await fetch(base + "/api/settings/hf-token")).json(), { ok: true, hasToken: false });
    const memory = await (await fetch(base + "/api/memory/status")).json();
    assert.deepEqual([memory.ok, memory.enabled], [false, false]);
    assert.deepEqual(await (await fetch(base + "/api/jobs")).json(), { ok: true, jobs: [] });
    registry.allowed = true;
    assert.deepEqual(await (await fetch(base + "/api/hub/local")).json(), { ok: true, models: [] });
    registry.allowed = false;
    assert.deepEqual(await socketFrame(base), { type: "text_delta", delta: "pi independent-model " + server.port + " false" });
    assert.equal((await server.flush()).durable, true);
    const closed = await server.close();
    assert.deepEqual([closed.stopped, closed.timedOut, closed.durability.durable, closed.durability.flushedSnapshots], [true, false, true, 1]);
    assert.deepEqual(events, ["allocator 8000000000", "cache close", "allocator 77"]);
    assert.equal(opened.disposals, 0, "a borrowed context survives close");
    await assert.rejects(fetch(base + "/health"));
    // Four more servers over the same context, each with another numerical identity:
    // every one reaches cache composition without a reload.
    for (const stateCompatibility of ["runtime-A", "runtime-B", "runtime-A", "runtime-B"]) {
      server = await createServer(opened, 0, { hostname: "127.0.0.1", binding: binding(stateCompatibility), buildPrompt });
      assert.equal(caches.calls.at(-1).binding.stateCompatibility, stateCompatibility);
      assert.equal(await chat("http://127.0.0.1:" + server.port), "t1");
      assert.equal((await server.close()).stopped, true);
    }
    assert.deepEqual([opens, opened.disposals, caches.calls.length, limit], [1, 0, 5, 77]);
    assert.deepEqual(signals(), before);
    opened.dispose();
    assert.equal(opened.disposals, 1);
    // HOME holds only the stores these requests used: the job database (/api/jobs) and the hub registry (/api/hub/local).
    const stored = tree(home);
    assert.ok(stored.includes(".mlx-bun/db/jobs.sqlite") && stored.includes(".mlx-bun/db/registry.sqlite"), stored.join());
    const allowed = new Set([".mlx-bun", ".mlx-bun/db", ".mlx-bun/jobs",
      ...["jobs.sqlite", "registry.sqlite"].flatMap(name => ["", "-wal", "-shm"].map(suffix => ".mlx-bun/db/" + name + suffix))]);
    assert.deepEqual(stored.filter(path => !allowed.has(path)), []);
  `);
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
}, 20_000);

test("a context without a template serves through a supplied prompt builder; the default builder still refuses it", async () => {
  const result = await runChild(prelude() + `
    const bare = another({ template: null });
    await assert.rejects(createServer(bare, 0, { hostname: "127.0.0.1", binding: binding() }), /^Error: model independent-model has no chat template$/);
    assert.deepEqual([bare.disposals, events], [0, []], "refused before any host resource");
    const server = await createServer(bare, 0, { hostname: "127.0.0.1", binding: binding(), buildPrompt });
    const base = "http://127.0.0.1:" + server.port;
    assert.equal(await chat(base), "t1");
    assert.equal(prompts.length, 1);
    const models = await (await fetch(base + "/v1/models")).json();
    assert.equal(models.data[0].reasoning, false);
    assert.deepEqual(await socketFrame(base), { type: "text_delta", delta: "pi independent-model " + server.port + " false" });
    assert.equal((await server.close()).stopped, true);
    assert.equal(bare.disposals, 0);
  `);
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
}, 20_000);

test("every failed start leaves a borrowed context usable and disposes an owned one exactly once; owned cleanup failures still dispose once", async () => {
  const result = await runChild(prelude(`
    const web = { fail: false };
    mock.module(app + "src/web/assets.ts", () => ({ async createWebHandler() { if (web.fail) throw new Error("web assets failed"); return () => null; } }));
  `) + `
    const occupied = Bun.serve({ hostname: "127.0.0.1", port: 0, fetch: () => new Response() });
    const failures = [
      ["context-limit profile", /MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer/, () => configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: "abc" })],
      ["state creation", /web assets failed/, () => { web.fail = true; return () => { web.fail = false; }; }],
      ["cache composition", /cache composition failed/, () => { caches.fail = true; return () => { caches.fail = false; }; }],
      ["bind", /./, () => () => {}],
    ];
    const borrowed = another();
    for (const ownership of ["borrowed", "owned"]) for (const [name, message, arrange] of failures) {
      const context = ownership === "owned" ? another() : borrowed;
      const port = name === "bind" ? occupied.port : 0;
      events.length = 0;
      const restore = arrange();
      try { await assert.rejects(createServer(context, port, { hostname: "127.0.0.1", binding: binding(), buildPrompt, ownership, memoryBudgetBytes: 8e9 }), message); }
      finally { restore(); }
      assert.equal(context.disposals, ownership === "owned" ? 1 : 0, ownership + " " + name);
      assert.equal(limit, 77, "the allocator limit is restored after " + name);
      // A host that got as far as its caches closes them before any owned model.
      if (name === "bind") assert.deepEqual(events, ["allocator 8000000000", "cache close", ...(ownership === "owned" ? ["model dispose"] : []), "allocator 77"]);
    }
    occupied.stop(true);
    // The borrowed context outlived every failure and serves the next server.
    let server = await createServer(borrowed, 0, { hostname: "127.0.0.1", binding: binding(), buildPrompt });
    assert.equal(await chat("http://127.0.0.1:" + server.port), "t1");
    assert.equal((await server.close()).stopped, true);
    assert.equal(borrowed.disposals, 0);
    // A failed disposal before the host took an owned context is reported with the startup error.
    const failing = another();
    failing.dispose = () => { failing.disposals++; throw new Error("dispose failed"); };
    const restore = configureRuntime({ MLX_BUN_RD_CONTEXT_LIMIT: "0" });
    try {
      await assert.rejects(createServer(failing, 0, { hostname: "127.0.0.1", binding: binding(), ownership: "owned" }), error =>
        error instanceof AggregateError && error.message === "startup and cleanup failed" &&
        /MLX_BUN_RD_CONTEXT_LIMIT/.test(error.errors[0].message) && error.errors[1].message === "dispose failed");
    } finally { restore(); }
    assert.equal(failing.disposals, 1);
    // Owned: disposed once after close, however often close is called, even when cache cleanup fails.
    const owned = another();
    server = await createServer(owned, 0, { hostname: "127.0.0.1", binding: binding(), buildPrompt, ownership: "owned" });
    const [one, two] = await Promise.all([server.close(), server.close()]);
    assert.equal(one, two); assert.equal(owned.disposals, 1);
    const unlucky = another();
    server = await createServer(unlucky, 0, { hostname: "127.0.0.1", binding: binding(), buildPrompt, ownership: "owned" });
    caches.closeFails = true;
    await assert.rejects(server.close(), /server cleanup failed/);
    await assert.rejects(server.close(), /server cleanup failed/);
    assert.equal(unlucky.disposals, 1);
  `);
  expect(result).toEqual({ code: 0, stdout: "", stderr: "" });
}, 20_000);

test("close joins the app's producers first, reports honest evidence at a deadline without releasing anything, then drains an aborted stream", async () => {
  const result = await runChild(prelude(`
    mock.module(app + "src/jobs/host.ts", () => ({ createJobHost() { return { signal: new AbortController().signal,
      ensureStore() { throw new Error("unused"); }, submit() {}, submitTask() {},
      async close() { events.push("jobs closing"); await Bun.sleep(20); events.push("jobs closed"); } }; } }));
  `) + `
    const owned = another(), before = signals();
    caches.durable = false;
    const server = await createServer(owned, 0, { hostname: "127.0.0.1", binding: binding(), buildPrompt, ownership: "owned", memoryBudgetBytes: 8e9 });
    const base = "http://127.0.0.1:" + server.port;
    hold.next = true;
    const stream = await post(base, "/v1/chat/completions", { messages: [{ role: "user", content: "hello" }], temperature: 0, max_tokens: 4, stream: true });
    assert.equal(stream.status, 200);
    const reader = stream.body.getReader();
    assert.ok(new TextDecoder().decode((await reader.read()).value).includes("data:"));
    // Flush while serving reports the cache's own counters.
    assert.deepEqual(await server.flush(), { pendingSnapshots: 1, pendingSpills: 2, pendingSpillBytes: 64, droppedSpills: 0, failedSpills: 1,
      durable: false, flushedSnapshots: 1, missingSnapshots: 0, elapsedMs: 1 });
    // The deadline passes while the stream runs: nothing is released and nothing claims durability.
    const timed = await server.close({ timeoutMs: 100 });
    assert.deepEqual({ ...timed, durability: { ...timed.durability, elapsedMs: 0 } }, { stopped: false, timedOut: true,
      durability: { pendingSnapshots: 1, pendingSpills: 2, pendingSpillBytes: 64, droppedSpills: 0, failedSpills: 1,
        durable: false, flushedSnapshots: 0, missingSnapshots: 0, elapsedMs: 0 } });
    assert.ok(timed.durability.elapsedMs >= 100);
    assert.deepEqual(events, ["allocator 8000000000", "jobs closing", "jobs closed"], "the state closed before the drain; the model and caches are live");
    assert.deepEqual([owned.disposals, limit], [0, 8e9]);
    const late = await fetch(base + "/health").then(response => response.status, () => "refused");
    assert.ok(late === 503 || late === "refused", String(late));
    // The client leaves: its row is cancelled, the drain finishes, and the evidence is the final flush's.
    await reader.cancel();
    const done = await server.close({ timeoutMs: Infinity });
    assert.deepEqual(done, { stopped: true, timedOut: false, durability: { pendingSnapshots: 1, pendingSpills: 2, pendingSpillBytes: 64,
      droppedSpills: 0, failedSpills: 1, durable: false, flushedSnapshots: 1, missingSnapshots: 0, elapsedMs: 1 } });
    assert.equal(await server.close(), done);
    assert.deepEqual(events, ["allocator 8000000000", "jobs closing", "jobs closed", "aborted", "cache close", "model dispose", "allocator 77"]);
    assert.deepEqual([owned.disposals, limit], [1, 77]);
    assert.deepEqual(signals(), before);
  `);
  expect({ code: result.code, stdout: result.stdout, stderr: result.stderr.replace(/^\[server\] cache flush incomplete.*\n/m, "") })
    .toEqual({ code: 0, stdout: "", stderr: "" });
}, 20_000);
