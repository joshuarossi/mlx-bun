import { requireChatTemplate } from "../engine/model-host";
import { createHubRoutes } from "../server/hub-routes";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { defaultSessionDir } from "../chat/session-files";
import { fileURLToPath } from "node:url";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import { fit } from "@mlx-bun/hub/fit";
import type { CommandArgs } from "./args";
import { resolveModelAuto } from "./model-selection";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { CacheServiceOptions } from "../engine/cache-services";
import type { Glm52MemoryPlan } from "@mlx-bun/inference/artifacts/glm52";
import type { RequestPrepOptions } from "../server/request-prep";
import type { PiBackendPaths } from "../chat/pi-backend";
import type { DownloadOwner } from "../hub/downloads";

export interface ServeOptions {
  query: string | null;
  hostname: string;
  port: number;
  capacity: number;
  contextLimit: number | null;
  defaultGeneratedTokens?: number;
  kvBudgetBytes?: number;
  /** Main's `--memory-budget`, decimal bytes: the usable envelope for load, admission, and the allocator. */
  memoryBudgetBytes?: number;
  /** Main's `--context-length`: GLM-5.2 resource-plan reservation; other families ignore it. */
  contextTokens?: number;
  forceWire?: boolean;
  expertOffload?: boolean;
  allowPrivateMedia?: boolean;
  /** Main's `--adapter`/`--adapter-path`: mounted at startup as the default adapter. */
  adapterDir?: string;
  readOnly: boolean;
  noOpen: boolean;
  cache: CacheServiceOptions;
  request: RequestPrepOptions;
  /** App-owned vault and skill destinations; not CLI flags. */
  memoryPaths?: { vault: string; skills: string };
  /** App composition only; shares Pi storage with its settings routes. */
  chatPaths?: PiBackendPaths;
  /** App-owned storage overrides for embedding and tests, like chatPaths and
   * memoryPaths: the job store, the saved Hugging Face token file, and the root
   * for adapter merge/export and fine-tune outputs. Defaults live under HOME. */
  storagePaths?: { jobsDb?: string; jobsLogs?: string; credentialsFile?: string; artifactRoot?: string };
}

/** Validate before opening a registry, loading a model, or creating a listener. */
export function parseServeOptions(args: CommandArgs): ServeOptions {
  const value = (name: string) => typeof args.values[name] === "string" ? args.values[name] as string : undefined;
  const number = (name: string, lo = 0, hi = Infinity, integer = false): number | undefined => {
    const raw = value(name);
    if (raw === undefined) return undefined;
    const parsed = Number(raw);
    if (!raw.trim() || !Number.isFinite(parsed) || parsed < lo || parsed > hi || (integer && !Number.isSafeInteger(parsed)))
      throw new Error(`--${name} expects ${integer ? "an integer" : "a number"} in [${lo}, ${hi}]`);
    return parsed;
  };
  const thinking = value("thinking");
  if (thinking !== undefined && !["on", "off", "1", "0", "true", "false"].includes(thinking))
    throw new Error("--thinking expects on|off");
  const kv = value("kv-quant") ?? "off";
  if (!["off", "config", "4", "8"].includes(kv)) throw new Error("--kv-quant expects off|config|4|8");
  const cache: CacheServiceOptions = { kvQuant: kv === "4" || kv === "8" ? Number(kv) : kv as "off" | "config" };
  const promptCache = number("prompt-cache");
  if (promptCache !== undefined) cache.promptCacheBytes = promptCache * 2 ** 30;
  const ssd = value("ssd-cache");
  if (ssd !== undefined && !ssd.trim()) throw new Error("--ssd-cache expects a directory");
  if (!ssd && ["ssd-cache-max", "ssd-demote-idle", "generation-checkpoint", "ssd-cache-verify"].some(name => args.values[name] !== undefined))
    throw new Error("SSD cache options require --ssd-cache");
  if (ssd) {
    if (promptCache === 0) throw new Error("SSD cache requires a nonzero RAM prompt cache");
    cache.ssdCacheDir = ssd;
    const max = number("ssd-cache-max"), idle = number("ssd-demote-idle"), checkpoint = number("generation-checkpoint", 1, Number.MAX_SAFE_INTEGER, true);
    if (max !== undefined) cache.ssdCacheMaxBytes = max === 0 ? Infinity : max * 2 ** 30;
    if (idle !== undefined) cache.ssdDemoteIdleSec = idle;
    if (checkpoint !== undefined) cache.generationCheckpointTokens = checkpoint;
    cache.ssdCacheVerify = args.values["ssd-cache-verify"] === true;
  }
  const temperature = number("temperature", 0, 5) ?? number("temp", 0, 5);
  const topP = number("top-p", 0, 1), topK = number("top-k", 0, 1_000_000);
  const hlg = value("hlg-sampling");
  if (hlg !== undefined && !["on", "off", "1", "0", "true", "false"].includes(hlg))
    throw new Error("--hlg-sampling expects on|off");
  const request: RequestPrepOptions = {
    ...(thinking !== undefined ? { defaultThinking: ["on", "1", "true"].includes(thinking) } : {}),
    ...(temperature !== undefined ? { defaultTemperature: temperature } : {}),
    ...(topP !== undefined ? { defaultTopP: topP } : {}),
    ...(topK !== undefined ? { defaultTopK: topK } : {}),
    // Main's HLG knobs in nats; the mid gain folds from --temperature.
    ...(hlg !== undefined && ["on", "1", "true"].includes(hlg) ? { hlg: { enabled: true,
      width: number("hlg-width", 0, 100) ?? 4, shoulder: number("hlg-shoulder", 0, 100) ?? 4,
      toe: number("hlg-toe", 0, 100) ?? 6, pivotOffset: number("hlg-pivot-offset", 0, 100) ?? 6, pivot: "top" } } : {}),
  };
  const adapterDir = value("adapter") ?? value("adapter-path");
  if (adapterDir !== undefined && !adapterDir.trim()) throw new Error("--adapter expects a directory");
  const memoryBudget = number("memory-budget");
  const contextTokens = number("context-length", 1, Number.MAX_SAFE_INTEGER, true);
  const host = value("host") ?? "127.0.0.1";
  if (!host.trim()) throw new Error("--host expects an address");
  const kvBudget = number("kv-budget");
  const maxTokens = number("max-tokens", 1, 10_000_000);
  const profileContext = runtimeValue("MLX_BUN_RD_CONTEXT_LIMIT");
  const profileLimit = profileContext === undefined ? null : Number(profileContext);
  if (profileLimit !== null && (!Number.isSafeInteger(profileLimit) || profileLimit < 1))
    throw new Error("MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer");
  return {
    query: value("model") ?? args.positionals[0] ?? value("query") ?? null,
    hostname: host, port: number("port", 0, 65535, true) ?? 8080,
    // Main's --decode-concurrency is an alias of --batch: the same continuous capacity, never a serial lane.
    capacity: number("batch", 1, Number.MAX_SAFE_INTEGER, true) ?? number("decode-concurrency", 1, Number.MAX_SAFE_INTEGER, true) ?? 8,
    contextLimit: profileLimit,
    defaultGeneratedTokens: maxTokens === undefined ? undefined : Math.floor(maxTokens),
    ...(kvBudget ? { kvBudgetBytes: kvBudget * 1e9 } : {}),
    ...(memoryBudget ? { memoryBudgetBytes: memoryBudget * 1e9 } : {}),
    ...(contextTokens !== undefined ? { contextTokens } : {}),
    forceWire: args.values["force-wire"] === true, expertOffload: args.values["expert-offload"] === true,
    allowPrivateMedia: args.values["allow-private-media"] === true,
    ...(adapterDir ? { adapterDir } : {}),
    readOnly: false, noOpen: args.values["no-open"] === true,
    cache, request,
  };
}

/** Main's loaded-model limits constrain the context window; an explicit output
 * cap overrides the model plan's default without changing its context budget.
 * An explicit memory budget makes the admission estimate's safe context the
 * enforced ceiling, as in main; without one only a GLM plan or profile cap applies. */
export function resolveServingLimits(
  options: Pick<ServeOptions, "contextLimit" | "defaultGeneratedTokens" | "memoryBudgetBytes">,
  plan?: Pick<Glm52MemoryPlan, "contextTokens" | "maxGenerationTokens"> | null,
  admission?: { maxSafeContext: number } | null,
) {
  const budgetLimit = options.memoryBudgetBytes !== undefined && admission ? admission.maxSafeContext : plan?.contextTokens ?? null;
  return {
    contextLimit: options.contextLimit === null ? budgetLimit
      : Math.min(options.contextLimit, budgetLimit ?? Infinity),
    defaultGeneratedTokens: options.defaultGeneratedTokens ?? plan?.maxGenerationTokens,
  };
}

export interface RunningApp {
  port: number;
  /** The app's transfer owner: startup hands it the recommended background
   * download; shutdown aborts and joins whatever it still carries. */
  downloads: Pick<DownloadOwner, "start" | "active">;
  close(): Promise<void>;
}

/** CLI composition owns resources until each explicit ownership transfer. */
export async function startModelServer(model: ModelRecord, options: ServeOptions): Promise<RunningApp> {
  const [{ loadContext, modelServingBinding, createCacheServices, createAppEngine },
    { createCompletionRoutes }, { createMemoryRoutes }, { startServer }, { createPiBackend }, { createWebHandler },
    { configureRuntime }, { GeneratedTokenHistory }, { createStatusRoutes }, { createManagementRoutes }, { createAdapterRoutes }, { vaultRoot }, { createMemorySurface }, { createSessionRoutes }, { createCacheRoutes }] = await Promise.all([
    import("../engine"), import("../server/routes"), import("../server/memory-routes"), import("../server/start"),
    import("../chat/pi-backend"), import("../web/assets"),
    import("@mlx-bun/inference/runtime/config"), import("../server/generated-token-history"), import("../server/status-routes"),
    import("../server/management-routes"), import("../server/adapter-routes"),
    import("../memory/vault"), import("../memory/surface"), import("../server/session-routes"), import("../server/cache-routes"),
  ]);
  const [{ createDownloadOwner }, { Registry }] = await Promise.all([import("../hub/downloads"), import("@mlx-bun/hub/registry")]);
  const web = await createWebHandler();
  // Keep main's KV numerical composition while graph compilation stays a layer concern.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: options.cache.kvQuant === "config" ? "0" : "1",
    ...(options.forceWire ? { MLX_BUN_FORCE_WIRE: "1" } : {}),
    ...(options.allowPrivateMedia ? { MLX_BUN_ALLOW_PRIVATE_MEDIA: "1" } : {}) });
  // Process-wide settings this app applies (offload routing, allocator limit,
  // runtime switches) are restored only after its engine has released the
  // model, on close and on startup failure alike, so a later app in the same
  // process starts from the state it found. Offload restore never unmaps.
  // The restore runs once: a repeated close must not undo a later app's settings.
  let restoreOffload: (() => void) | undefined, restoreAllocator: (() => void) | undefined, restored = false;
  const restoreProcess = () => {
    if (restored) return;
    restored = true;
    try { restoreOffload?.(); } finally { try { restoreAllocator?.(); } finally { restoreRuntime(); } }
  };
  let cleanup: (() => void | Promise<unknown>) | undefined;
  try {
    if (options.expertOffload) {
      // Main: dense models log and continue; MoE experts route through the
      // page-aligned file built on first use, activated before construction.
      if (model.expertsBytes === 0) console.warn("--expert-offload ignored: this model has no experts (dense)");
      else {
        const { ensureOffloadFile, activateExpertOffload } = await import("@mlx-bun/inference/artifacts");
        restoreOffload = activateExpertOffload(await ensureOffloadFile(model.path, message => console.log(`[serve] expert offload: ${message}`)));
      }
    }
    const context = await loadContext(model.path, model.repoId, {
      ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
      // Main's GLM resource plan inputs; other families ignore this block.
      glm: { batchSize: options.capacity, maxGenerationTokens: options.defaultGeneratedTokens ?? 128,
        ...(options.memoryBudgetBytes !== undefined ? { memoryBudgetBytes: options.memoryBudgetBytes } : {}),
        ...(options.contextTokens !== undefined ? { contextTokens: options.contextTokens } : {}) },
    });
    cleanup = () => context.dispose();
    requireChatTemplate(context);
    // Main: a startup adapter mounts before any request and becomes the default
    // for requests without an adapter field (an explicit adapter, including
    // "none", still wins); a bad adapter fails startup and releases the model.
    let defaultAdapter: string | undefined;
    if (options.adapterDir) {
      const directory = options.adapterDir.replace(/\/+$/, "");
      try {
        const info = await context.adapters.mount(directory.split("/").pop()!, directory);
        defaultAdapter = info.id;
        console.log(`[serve] adapter ${info.id} mounted (${info.mountedLayers} layers) · default for requests (select others via \`adapter\`)`);
      } catch (error) {
        throw new Error(`adapter mount failed: ${error instanceof Error ? error.message : String(error)}`);
      }
    }
    const binding = await modelServingBinding(context);
    // Main: the plan's allocator reserve, else the explicit budget, caps the
    // allocator for the whole process and bounds optional cache residency.
    const allocatorLimitBytes = context.glmMemoryPlan?.lineItems?.allocatorReserveBytes ?? options.memoryBudgetBytes;
    if (allocatorLimitBytes) {
      const { setMemoryLimit } = await import("@mlx-bun/mlx/ffi");
      const previous = setMemoryLimit(allocatorLimitBytes);
      restoreAllocator = () => { setMemoryLimit(previous); };
    }
    const caches = await createCacheServices(context, binding, { ...options.cache,
      ...(allocatorLimitBytes ? { allocatorLimitBytes } : {}) });
    const closeCaches = async () => {
      const result = await caches.close();
      if (!result.durable) console.warn(`[server] cache flush incomplete: ${result.pendingSnapshots} snapshots, ${result.pendingSpills} spills, ${result.failedSpills} failed`);
    };
    cleanup = async () => { try { await closeCaches(); } finally { context.dispose(); } };
    binding.gateway.configureContinuation?.(caches.continuationServices);
    // createAppEngine takes ownership even when its constructor rejects.
    cleanup = undefined;
    const engine = await createAppEngine(context, { capacity: options.capacity, binding,
      gateway: { kvBudgetBytes: options.kvBudgetBytes,
        checkpoints: !!(options.cache.generationCheckpointTokens && caches.checkpoints),
        stateCodecs: caches.stateCodecs, kvScheme: caches.resolvedKvScheme,
        promptCache: caches.promptCache, adapterNamespace: caches.adapterNamespace },
      beforeModelDispose: closeCaches,
    });
    cleanup = () => engine.close();
    const tokenHistory = new GeneratedTokenHistory(context.tokenizer);
    if (caches.checkpoints) for (const tokens of caches.checkpoints.tokenPrefixes()) tokenHistory.remember(tokens);
    caches.promptCache.onPut = tokens => tokenHistory.remember(tokens);
    const admission = context.glmMemoryPlan ?? fit(context.model.config, context.model.weightsBytes, 1,
      undefined, undefined, 0, options.memoryBudgetBytes, caches.resolvedKvScheme.fitOptions);
    const limits = resolveServingLimits(options, context.glmMemoryPlan, admission);
    // Web-started transfers outlive their request. The owner's rows feed
    // discovery and chat; completion refreshes the registry and discovery, and
    // shutdown joins every transfer before the engine closes.
    const downloads = createDownloadOwner({
      onComplete: async repoId => {
        const registry = new Registry();
        try { await registry.scan(); } finally { registry.close(); }
        completions.invalidateLibrary();
        console.log(`[hub] download complete: ${repoId}`);
      },
      onFailure: (repoId, error) => console.error(`[hub] download of ${repoId} failed: ${error instanceof Error ? error.message : String(error)}`),
    });
    const completions = createCompletionRoutes(engine, { ...options.request, promptCache: caches.promptCache,
      kvScheme: caches.kvScheme, ...limits, tokenHistory, downloads: downloads.snapshot,
      ...(defaultAdapter ? { defaultAdapter } : {}) });
    const status = createStatusRoutes({ owner: "serve", context, caches, gateway: engine.gateway,
      diagnostics: () => binding.diagnostics(), responseStats: completions.responseStats, artifact: model,
      capacity: options.capacity, contextLimit: limits.contextLimit, startedAt: Date.now(),
      ssdCacheDir: options.cache.ssdCacheDir, memoryBudgetBytes: options.memoryBudgetBytes });
    const hub = createHubRoutes({ downloads });
    const cacheAdmin = createCacheRoutes(caches);
    const adapters = createAdapterRoutes(context, engine.gateway);
    const management = createManagementRoutes({ invalidateLibrary: completions.invalidateLibrary,
      toolApprovalsFile: options.chatPaths?.toolApprovalsFile, servedModelPath: model.path });
    const [{ createJobHost }, { createJobRoutes }, { createQuantizeRoutes }, { createDatasetRoutes }, { createDatasetRunner }, { createFinetuneRoutes }, { createAdapterArtifactRoutes },
      { createHfCredentials }, { createPublisher }, { createPublishingRoutes }, { JobStore }] = await Promise.all([
      import("../jobs/host"), import("../server/job-routes"), import("../server/quantize-routes"),
      import("../server/dataset-routes"), import("../dataset/job"), import("../server/finetune-routes"), import("../server/adapter-artifact-routes"),
      import("../publishing/credentials"), import("../publishing/upload"), import("../server/publishing-routes"), import("../jobs/db"),
    ]);
    const storage = options.storagePaths ?? {};
    const jobs = createJobHost({ entry: fileURLToPath(new URL("./job-entry.ts", import.meta.url)),
      acquire: signal => engine.gateway.acquireExecutionLease(signal),
      onComplete: () => completions.invalidateLibrary(),
      ...(storage.jobsDb !== undefined || storage.jobsLogs !== undefined ? {
        createStore: () => new JobStore(storage.jobsDb,
          storage.jobsLogs ?? (storage.jobsDb !== undefined ? join(dirname(storage.jobsDb), "jobs") : undefined)),
      } : {}),
    });
    const closeApp = async () => {
      const errors: unknown[] = [];
      try { await jobs.close(); } catch (error) { errors.push(error); }
      try { await engine.close(); } catch (error) { errors.push(error); }
      if (errors.length) throw new AggregateError(errors, "application cleanup failed");
    };
    cleanup = closeApp;
    const jobRoutes = createJobRoutes(jobs), quantizeRoutes = createQuantizeRoutes(jobs);
    const finetuneRoutes = createFinetuneRoutes(jobs, storage.artifactRoot
      ? () => join(storage.artifactRoot!, "adapters", `adapter-${Date.now()}-${crypto.randomUUID()}`) : undefined);
    const memoryPaths = options.memoryPaths ?? { vault: vaultRoot(), skills: join(homedir(), ".mlx-bun", "skills") };
    const memory = createMemoryRoutes({ root: () => memoryPaths.vault });
    const sessionDir = options.chatPaths?.sessionDir ?? defaultSessionDir();
    const sessions = createSessionRoutes(sessionDir);
    const adapterArtifacts = createAdapterArtifactRoutes(engine.gateway, { outputRoot: storage.artifactRoot });
    const credentials = createHfCredentials({ tokenFile: storage.credentialsFile });
    const publishing = createPublishingRoutes({ credentials, publish: createPublisher({ credentials,
      getJob: id => jobs.ensureStore().get(id),
    }) });
    let boundPort = options.port;
    const datasetRunner = createDatasetRunner();
    const datasetRoutes = createDatasetRoutes({ serverPort: () => boundPort,
      submit: (config, output) => jobs.submitTask("dataset", config, datasetRunner, output) });
    const routes = { handle: async (request: Request) => await status.handle(request) ?? await cacheAdmin.handle(request) ?? await hub.handle(request) ?? await sessions.handle(request) ?? await adapters.handle(request) ?? await management.handle(request) ?? await memory.handle(request) ?? await jobRoutes.handle(request) ??
      await quantizeRoutes.handle(request) ?? await datasetRoutes.handle(request) ?? await finetuneRoutes.handle(request) ?? await adapterArtifacts.handle(request) ?? await publishing.handle(request) ?? await completions.handle(request) };
    const chat = createPiBackend({ port: () => boundPort, modelId: context.modelId,
      memory: () => createMemorySurface(memoryPaths.vault, memoryPaths.skills),
      paths: { ...options.chatPaths, sessionDir },
      contextWindow: limits.contextLimit ?? context.model.config.text.maxPositionEmbeddings,
      readOnly: options.readOnly, vision: !!(context.vision || context.loadVision),
      audio: !!(context.audio || context.loadAudio), thinking: context.template.supportsThinking,
      genDefaults: {
        temperature: options.request.defaultTemperature ?? context.genDefaults.temperature ?? null,
        topP: options.request.defaultTopP ?? context.genDefaults.topP ?? null,
        topK: options.request.defaultTopK ?? context.genDefaults.topK ?? null,
      }, downloadsSnapshot: downloads.snapshot,
    });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web, chat,
      beforeDrain: async () => {
        const errors: unknown[] = [];
        try { caches.stopIdleDemotion(); } catch (error) { errors.push(error); }
        for (const result of await Promise.allSettled([jobs.close(), downloads.close()]))
          if (result.status === "rejected") errors.push(result.reason);
        if (errors.length === 1) throw errors[0];
        if (errors.length) throw new AggregateError(errors, "background shutdown failed");
      },
      closeEngine: closeApp }, {
      port: options.port, hostname: options.hostname,
    });
    boundPort = listener.server.port!;
    return { port: boundPort, downloads, async close() { try { await listener.close(); } finally { restoreProcess(); } } };
  } catch (error) {
    try { await cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    finally { restoreProcess(); }
    throw error;
  }
}

export interface SignalPort {
  on(signal: "SIGINT" | "SIGTERM", listener: () => void): unknown;
  removeListener(signal: "SIGINT" | "SIGTERM", listener: () => void): unknown;
}
/** Keep listeners installed until teardown finishes, so a second signal cannot race it. */
export function installShutdownHandlers(close: () => Promise<void>, input: {
  signals: SignalPort; exit(code: number): void; error(error: unknown): void; timeoutMs?: number;
}) {
  let stopping = false;
  const remove = () => { input.signals.removeListener("SIGINT", stop); input.signals.removeListener("SIGTERM", stop); };
  const stop = () => {
    if (stopping) return;
    stopping = true;
    // Keep the deadline at the process owner. Resource owners keep joining
    // their work; timing out must not free model weights under a live borrower.
    let timer: ReturnType<typeof setTimeout> | undefined;
    const deadline = new Promise<never>((_, reject) => {
      timer = setTimeout(() => reject(new Error("Shutdown exceeded its deadline; persistence may be incomplete")), input.timeoutMs ?? 120_000);
      timer.unref();
    });
    const work = (async () => { await close(); })();
    void Promise.race([work, deadline]).then(() => input.exit(0), error => {
      input.error(error); input.exit(1);
    }).finally(() => { if (timer) clearTimeout(timer); remove(); });
  };
  input.signals.on("SIGINT", stop); input.signals.on("SIGTERM", stop);
  return remove;
}

export function browserUrl(hostname: string, port: number): string {
  const host = hostname === "0.0.0.0" || hostname === "::" ? "localhost" : hostname;
  return `http://${host.includes(":") && !host.startsWith("[") ? `[${host}]` : host}:${port}/#/chat`;
}

export interface ServeDependencies {
  resolve: typeof resolveModelAuto;
  start: typeof startModelServer;
  interactive: boolean;
  open(url: string): void | Promise<void>;
  log(message: string): void;
  signals: SignalPort;
  exit(code: number): void;
  error(error: unknown): void;
}
const defaults: ServeDependencies = {
  resolve: resolveModelAuto, start: startModelServer, interactive: !!process.stdout.isTTY,
  async open(url) { const child = Bun.spawn(["open", url], { stdout: "ignore", stderr: "ignore" }); if (await child.exited !== 0) throw new Error("Browser could not be opened"); },
  log: message => console.log(message), signals: process, exit: code => process.exit(code),
  error: error => console.error(error instanceof Error ? error.message : String(error)),
};

export async function runServe(args: CommandArgs, supplied: Partial<ServeDependencies> = {}): Promise<RunningApp> {
  const options = parseServeOptions(args);
  const deps = { ...defaults, ...supplied };
  // A signal before the app exists cancels selection (a starter download stays
  // resumable) and, once the model has loaded, closes the app right away; the
  // shutdown handlers take over as soon as the listener is up.
  const startup = new AbortController();
  const cancelStartup = () => startup.abort(new Error("startup cancelled by signal"));
  deps.signals.on("SIGINT", cancelStartup); deps.signals.on("SIGTERM", cancelStartup);
  let running: RunningApp | undefined, selection: Awaited<ReturnType<typeof resolveModelAuto>> | undefined, removeSignals = () => {};
  let closed: Promise<void> | undefined;
  const close = () => closed ??= (async () => { try { await running?.close(); } finally { removeSignals(); } })();
  try {
    selection = await deps.resolve(options.query, {}, startup.signal);
    // A signal that landed during selection must not start a native load.
    startup.signal.throwIfAborted();
    deps.log(`Loading ${selection.m.repoId}${selection.picked ? " (auto-selected)" : ""}`);
    running = await deps.start(selection.m, options);
    // Main's MLX_BUN_SHUTDOWN_TIMEOUT_MS: any finite value > 0, else 120 s.
    const rawTimeout = Number(runtimeValue("MLX_BUN_SHUTDOWN_TIMEOUT_MS"));
    removeSignals = installShutdownHandlers(close, { signals: deps.signals, exit: deps.exit, error: deps.error,
      ...(Number.isFinite(rawTimeout) && rawTimeout > 0 ? { timeoutMs: rawTimeout } : {}) });
  } finally { deps.signals.removeListener("SIGINT", cancelStartup); deps.signals.removeListener("SIGTERM", cancelStartup); }
  const app: RunningApp = { port: running.port, downloads: running.downloads, close };
  if (startup.signal.aborted) { await close(); return app; }
  if (selection.recommended) {
    // Main started this transfer during selection and dropped its handle; the
    // app's owner now carries it, reports it on /downloads, and joins it at shutdown.
    try { running.downloads.start(selection.recommended); } catch (error) { deps.error(error); }
  }
  const url = browserUrl(options.hostname, running.port);
  deps.log(`Serving ${selection.m.repoId} with continuous batching (capacity ${options.capacity})\nApp ${url}\nAPI ${url.replace("/#/chat", "/v1")}\nStop: Ctrl+C`);
  if (deps.interactive && !options.noOpen) {
    try { await deps.open(url); } catch (error) { deps.error(error); }
  }
  return app;
}
