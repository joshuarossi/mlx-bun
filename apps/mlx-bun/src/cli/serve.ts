import { fileURLToPath } from "node:url";
import type { CommandArgs } from "./args";
import { resolveModelAuto } from "./model-selection";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { CacheServiceOptions } from "../engine/cache-services";
import type { RequestPrepOptions } from "../server/request-prep";

export interface ServeOptions {
  query: string | null;
  hostname: string;
  port: number;
  capacity: number;
  contextLimit: number | null;
  defaultGeneratedTokens?: number;
  kvBudgetBytes?: number;
  readOnly: boolean;
  noOpen: boolean;
  cache: CacheServiceOptions;
  request: RequestPrepOptions;
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
  const request: RequestPrepOptions = {
    ...(thinking !== undefined ? { defaultThinking: ["on", "1", "true"].includes(thinking) } : {}),
    ...(temperature !== undefined ? { defaultTemperature: temperature } : {}),
    ...(topP !== undefined ? { defaultTopP: topP } : {}),
    ...(topK !== undefined ? { defaultTopK: topK } : {}),
  };
  const host = value("host") ?? "127.0.0.1";
  if (!host.trim()) throw new Error("--host expects an address");
  const kvBudget = number("kv-budget");
  const maxTokens = number("max-tokens", 1, 10_000_000);
  return {
    query: value("model") ?? args.positionals[0] ?? value("query") ?? null,
    hostname: host, port: number("port", 0, 65535, true) ?? 8080,
    capacity: number("batch", 1, Number.MAX_SAFE_INTEGER, true) ?? 8,
    contextLimit: number("ctx", 1, Number.MAX_SAFE_INTEGER, true) ?? null,
    defaultGeneratedTokens: maxTokens === undefined ? undefined : Math.floor(maxTokens),
    ...(kvBudget ? { kvBudgetBytes: kvBudget * 1e9 } : {}),
    readOnly: args.values["read-only"] === true, noOpen: args.values["no-open"] === true,
    cache, request,
  };
}

export interface RunningApp { port: number; close(): Promise<void> }

/** CLI composition owns resources until each explicit ownership transfer. */
export async function startModelServer(model: ModelRecord, options: ServeOptions): Promise<RunningApp> {
  const [{ loadContext, modelServingBinding, createCacheServices, createAppEngine },
    { createCompletionRoutes }, { startServer }, { createPiBackend }, { createWebHandler },
    { downloadsSnapshot }, { configureRuntime }, { GeneratedTokenHistory }] = await Promise.all([
    import("../engine"), import("../server/routes"), import("../server/start"),
    import("../chat/pi-backend"), import("../web/assets"), import("@mlx-bun/hub/download"),
    import("@mlx-bun/inference/runtime/config"), import("../server/generated-token-history"),
  ]);
  const web = await createWebHandler();
  // Keep main's KV numerical composition while graph compilation stays a layer concern.
  const restoreRuntime = configureRuntime({ MLX_BUN_NO_FUSED_SDPA: options.cache.kvQuant === "config" ? "0" : "1" });
  let cleanup: (() => void | Promise<unknown>) | undefined;
  try {
    const context = await loadContext(model.path, model.repoId);
    cleanup = () => context.dispose();
    const binding = await modelServingBinding(context);
    const caches = await createCacheServices(context, binding, options.cache);
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
    const completions = createCompletionRoutes(engine, { ...options.request, promptCache: caches.promptCache,
      kvScheme: caches.kvScheme, contextLimit: options.contextLimit,
      defaultGeneratedTokens: options.defaultGeneratedTokens, tokenHistory });
    const [{ createJobHost }, { createJobRoutes }, { createQuantizeRoutes }, { createFinetuneRoutes }, { createAdapterArtifactRoutes }] = await Promise.all([
      import("../jobs/host"), import("../server/job-routes"), import("../server/quantize-routes"), import("../server/finetune-routes"), import("../server/adapter-artifact-routes"),
    ]);
    const jobs = createJobHost({ entry: fileURLToPath(new URL("./job-entry.ts", import.meta.url)),
      acquire: signal => engine.gateway.acquireExecutionLease(signal),
      onComplete: () => completions.invalidateLibrary(),
    });
    const closeApp = async () => { try { await jobs.close(); } finally { await engine.close(); } };
    cleanup = closeApp;
    const jobRoutes = createJobRoutes(jobs), quantizeRoutes = createQuantizeRoutes(jobs), finetuneRoutes = createFinetuneRoutes(jobs);
    const adapterArtifacts = createAdapterArtifactRoutes(engine.gateway);
    const routes = { handle: async (request: Request) => await jobRoutes.handle(request) ??
      await quantizeRoutes.handle(request) ?? await finetuneRoutes.handle(request) ?? await adapterArtifacts.handle(request) ?? await completions.handle(request) };
    let boundPort = options.port;
    const chat = createPiBackend({ port: () => boundPort, modelId: context.modelId,
      contextWindow: options.contextLimit ?? context.model.config.text.maxPositionEmbeddings,
      readOnly: options.readOnly, vision: !!(context.vision || context.loadVision),
      audio: !!(context.audio || context.loadAudio), thinking: context.template.supportsThinking,
      genDefaults: {
        temperature: options.request.defaultTemperature ?? context.genDefaults.temperature ?? null,
        topP: options.request.defaultTopP ?? context.genDefaults.topP ?? null,
        topK: options.request.defaultTopK ?? context.genDefaults.topK ?? null,
      }, downloadsSnapshot,
    });
    // startServer owns engine cleanup on entry, including a bind failure.
    cleanup = undefined;
    const listener = await startServer({ routes, web, chat, closeEngine: closeApp }, {
      port: options.port, hostname: options.hostname,
    });
    boundPort = listener.server.port!;
    return { port: boundPort, async close() { try { await listener.close(); } finally { restoreRuntime(); } } };
  } catch (error) {
    try { await cleanup?.(); }
    catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    finally { restoreRuntime(); }
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
  error: error => console.error(error instanceof Error ? (process.env.MLX_BUN_DEBUG ? error.stack ?? error.message : error.message) : String(error)),
};

export async function runServe(args: CommandArgs, supplied: Partial<ServeDependencies> = {}): Promise<RunningApp> {
  const options = parseServeOptions(args);
  const deps = { ...defaults, ...supplied };
  const { m, picked } = await deps.resolve(options.query);
  deps.log(`Loading ${m.repoId}${picked ? " (auto-selected)" : ""}`);
  const running = await deps.start(m, options);
  let closed: Promise<void> | undefined;
  const close = () => closed ??= (async () => { try { await running.close(); } finally { removeSignals(); } })();
  const removeSignals = installShutdownHandlers(close, { signals: deps.signals, exit: deps.exit, error: deps.error });
  const url = browserUrl(options.hostname, running.port);
  deps.log(`Serving ${m.repoId} with continuous batching (capacity ${options.capacity})\nApp ${url}\nAPI ${url.replace("/#/chat", "/v1")}\nStop: Ctrl+C`);
  if (deps.interactive && !options.noOpen) {
    try { await deps.open(url); } catch (error) { deps.error(error); }
  }
  return { port: running.port, close };
}
