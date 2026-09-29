import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import { parseTurboQuantScheme } from "@mlx-bun/inference/artifacts/config";
import { isTranscriptionModelType } from "@mlx-bun/inference/models/support";
import { parseCommand, type CommandArgs } from "./args";
import { numericalPolicy } from "./numerical-policy";
import { resolveModelAuto } from "./model-selection";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { CacheServiceOptions } from "../engine/cache-services";
import type { RequestPrepOptions } from "../server/request-prep";
import type { DraftKind } from "../engine/model-host";
import { installedModules } from "../modules";
import { createAppState, type AppState, type AppStateOptions, type AppStoragePaths, type ModelHostLink } from "./serve-state";
import type { ModelHostHooks } from "./serve-host";
import { resolveServingLimits, validatePagedServingOptions, type RunningApp, type ServeOptions } from "./serve-options";

// The composition lives in two halves: serve-state (persistent, CPU-only) and
// serve-host (model-scoped). This module parses flags, composes both, and owns
// the process (signals, browser, shutdown deadline). The model half is
// imported only by the composition that runs it, so an isolated parent
// (serve-isolated.ts) never loads the engine.
export { resolveServingLimits, validatePagedServingOptions, type RunningApp, type ServeOptions };

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
  const policy = numericalPolicy(args);
  // An explicit --kv-quant is the policy's own choice; reading it here keeps its
  // accepted values and default in the generated configuration reference.
  const kv = value("kv-quant") ?? policy.kv ?? "off";
  // Main's TurboQuant spec, turbo (k8v3) or turbo:k<bits>v<bits>, is its own scheme beside affine KV.
  const turboQuant = parseTurboQuantScheme(kv);
  if (!turboQuant && !["off", "config", "4", "8"].includes(kv)) throw new Error("--kv-quant expects off|config|4|8|turbo[:k<bits>v<bits>]");
  const cache: CacheServiceOptions = turboQuant ? { turboQuant }
    : { kvQuant: kv === "4" || kv === "8" ? Number(kv) : kv as "off" | "config" };
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
  // Main's speculative flags, validated before model selection with its messages.
  const draftModel = value("draft-model");
  if (draftModel !== undefined && !draftModel.trim()) throw new Error("--draft-model expects a path or query");
  const numDraftRaw = value("num-draft-tokens");
  const numDraftTokens = numDraftRaw === undefined ? undefined : Number(numDraftRaw);
  if (numDraftTokens !== undefined && (!Number.isInteger(numDraftTokens) || numDraftTokens < 1))
    throw new Error(`--num-draft-tokens expects an integer >= 1 (got "${numDraftRaw}")`);
  const draftKinds: DraftKind[] = ["dspark", "deepspec", "assistant", "two-model", "ngram", "mtp"];
  const draftKindRaw = value("draft-kind");
  if (draftKindRaw !== undefined && !draftKinds.includes(draftKindRaw as DraftKind))
    throw new Error(`--draft-kind expects two-model|assistant|dspark|deepspec|mtp|ngram (got "${draftKindRaw}")`);
  const draftKind = draftKindRaw as DraftKind | undefined;
  const ngramInt = (name: string): number | undefined => {
    const raw = value(name);
    if (raw === undefined) return undefined;
    const parsed = Number(raw);
    if (!Number.isInteger(parsed) || parsed < 1) throw new Error(`--${name} expects an integer >= 1 (got "${raw}")`);
    return parsed;
  };
  const ngramMax = ngramInt("ngram-max"), ngramMin = ngramInt("ngram-min");
  if (ngramMax !== undefined && ngramMin !== undefined && ngramMin > ngramMax)
    throw new Error(`--ngram-min (${ngramMin}) must be <= --ngram-max (${ngramMax})`);
  if ((ngramMax !== undefined || ngramMin !== undefined) && draftKind !== "ngram")
    console.warn("--ngram-max/--ngram-min only apply with --draft-kind ngram — ignored");
  const mtpRaw = value("mtp");
  if (mtpRaw !== undefined && !["on", "off", "1", "0", "true", "false"].includes(mtpRaw)) throw new Error(`--mtp expects on|off (got "${mtpRaw}")`);
  // Main's speech-to-text companion: explicit checkpoint + residency policy.
  const whisperModel = value("whisper-model");
  if (whisperModel !== undefined && !whisperModel.trim()) throw new Error("--whisper-model expects a path or query");
  const whisperIdleRaw = value("whisper-idle-unload");
  const whisperIdle = whisperIdleRaw === undefined ? undefined : Number(whisperIdleRaw);
  if (whisperIdle !== undefined && (!whisperIdleRaw!.trim() || !Number.isFinite(whisperIdle) || whisperIdle < 0))
    throw new Error(`--whisper-idle-unload expects seconds >= 0 (got "${whisperIdleRaw}")`);
  const whisperResident = args.values["whisper-resident"] === true, preload = args.values.preload === true;
  const whisper = whisperModel !== undefined || whisperIdle !== undefined || whisperResident || preload
    ? { ...(whisperModel !== undefined ? { model: whisperModel } : {}), ...(whisperIdle !== undefined ? { idleUnloadSec: whisperIdle } : {}),
      ...(whisperResident ? { resident: true } : {}), ...(preload ? { preload: true } : {}) } : undefined;
  const draft = draftModel !== undefined || draftKind !== undefined || numDraftTokens !== undefined || ngramMax !== undefined || ngramMin !== undefined
    ? { ...(draftModel !== undefined ? { model: draftModel } : {}), ...(draftKind ? { kind: draftKind } : {}),
      ...(numDraftTokens !== undefined ? { numTokens: numDraftTokens } : {}),
      ...(ngramMax !== undefined ? { ngramMax } : {}), ...(ngramMin !== undefined ? { ngramMin } : {}) } : undefined;
  // Main's paged KV: the flag or its env mirror; the block size only with paging.
  const pagedKv = args.values["paged-kv"] === true || runtimeValue("MLX_BUN_PAGED_KV") === "1";
  const blockSize = number("paged-kv-block-size", 1, Number.MAX_SAFE_INTEGER, true);
  if (blockSize !== undefined && !pagedKv) throw new Error("--paged-kv-block-size requires --paged-kv");
  if (pagedKv) request.pagedKv = blockSize !== undefined ? { blockSize } : {};
  const memoryBudget = number("memory-budget");
  const contextTokens = number("context-length", 1, Number.MAX_SAFE_INTEGER, true);
  const host = value("host") ?? "127.0.0.1";
  if (!host.trim()) throw new Error("--host expects an address");
  const kvBudget = number("kv-budget");
  const maxTokens = number("max-tokens", 1, 10_000_000);
  // Main's --model-pool: pool policy is the parent's and means nothing without a worker.
  const isolate = args.values.isolate === true;
  const modelPool = number("model-pool", 1, Number.MAX_SAFE_INTEGER, true);
  if (modelPool !== undefined && !isolate) console.warn("--model-pool has no effect without --isolate (child-per-model pool) — ignored");
  const profileLimit = profileContextLimit();
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
    ...(draft ? { draft } : {}),
    ...(mtpRaw !== undefined ? { mtp: ["on", "1", "true"].includes(mtpRaw) } : {}),
    ...(whisper ? { whisper } : {}),
    readOnly: false, noOpen: args.values["no-open"] === true, isolate,
    ...(isolate && modelPool !== undefined ? { modelPool } : {}),
    cache, request, fusedSdpa: policy.fusedSdpa,
  };
}

/** Main's MLX_BUN_RD_CONTEXT_LIMIT: the enforced context cap when set, else none. */
export function profileContextLimit(): number | null {
  const profileContext = runtimeValue("MLX_BUN_RD_CONTEXT_LIMIT");
  const profileLimit = profileContext === undefined ? null : Number(profileContext);
  if (profileLimit !== null && (!Number.isSafeInteger(profileLimit) || profileLimit < 1))
    throw new Error("MLX_BUN_RD_CONTEXT_LIMIT must be a positive integer");
  return profileLimit;
}

/** Internal (the worker app form, `cli/worker-entry.ts`), never a CLI flag:
 * listen on a Unix socket, let the worker's admin surface wrap the routes and
 * close ahead of the app's producers, and see the model host's link while it
 * is attached (the admin lease reaches the gateway through it). */
export interface AppSocketHooks extends Pick<ModelHostHooks, "unix" | "routes" | "beforeDrain"> {
  link?: { current?: ModelHostLink };
}

/** Lend the host's link to the state and keep it in `holder` while attached. */
function observeLink(state: AppState, holder: { current?: ModelHostLink }): AppState {
  return { ...state, attach(link) {
    const detach = state.attach(link);
    holder.current = link;
    return () => { if (holder.current === link) holder.current = undefined; detach(); };
  } };
}

/** The app's lifetime around one model host (the CLI's and `mlx-bun/server`'s):
 * the persistent state first, then the host that borrows it. The host loads
 * the installed modules (`src/modules.ts`) over its own core services and stops
 * them in its drain. `start` makes the host's drain step close the state's
 * producers while the engine is alive; a failed start closes the state. Close
 * resolves with the host's own result once the state has closed too. */
export async function startApp<Host extends { close(): Promise<unknown> }>(options: AppStateOptions, storagePaths: AppStoragePaths,
  start: (state: AppState) => Promise<Host>) {
  const state = await createAppState(options, storagePaths, await installedModules("state"));
  let host: Host;
  try {
    host = await start(state);
  } catch (error) {
    try { await state.close(); } catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    throw error;
  }
  return { state, host, async close(): Promise<Awaited<ReturnType<Host["close"]>>> {
    const errors: unknown[] = [];
    let result: unknown;
    try { result = await host.close(); } catch (error) { errors.push(error); }
    // The host's drain already closed the state; a repeated failure here is the same one.
    try { await state.close(); } catch (error) { errors.push(error); }
    if (errors.length) throw errors[0];
    return result as Awaited<ReturnType<Host["close"]>>;
  } };
}

/** CLI composition: the persistent state first, then the model host that
 * borrows it. The host stops the state's producers inside its drain step, so
 * jobs and downloads end while the engine is alive, as before the split. */
export async function startModelServer(model: ModelRecord, options: ServeOptions, hooks: AppSocketHooks = {}): Promise<RunningApp> {
  // --isolate: the same persistent state, with the model host in a worker process behind a proxy.
  if (options.isolate) {
    // A nested isolated app would bind TCP and never the launch socket.
    if (hooks.unix) throw new Error("--isolate is not supported in a worker app launch");
    return (await import("./serve-isolated")).startIsolatedServer(model, options, { modules: await installedModules("state") });
  }
  const [{ startModelHost }, { createInProcessMemoryClient }] = await Promise.all([import("./serve-host"), import("./memory-engine")]);
  // Memory synthesis gets main's own task model, loaded by the first run (the isolated parent has none).
  const app = await startApp({ ...options, memoryTaskModel: () => createInProcessMemoryClient() }, options.storagePaths ?? {},
    state => startModelHost(hooks.link ? observeLink(state, hooks.link) : state, model, options, {
      ...(hooks.unix ? { unix: hooks.unix } : {}), ...(hooks.routes ? { routes: hooks.routes } : {}),
      beforeDrain: async () => { try { await hooks.beforeDrain?.(); } finally { await state.close(); } } }));
  return { ...("port" in app.host ? { port: app.host.port } : {}), downloads: app.state.downloads, async close() { await app.close(); } };
}

/** Main's `serve <whisper checkpoint>`: the transcription-only host has no
 * chat model, jobs, downloads, or web app, so no persistent state is composed. */
export async function startTranscriptionServer(model: ModelRecord, options: ServeOptions,
  hooks: Pick<ModelHostHooks, "unix" | "routes" | "beforeDrain"> = {}): Promise<RunningApp> {
  return (await import("./serve-host")).startTranscriptionHost(model, options, hooks);
}

/** Main's MLX_BUN_SHUTDOWN_TIMEOUT_MS: any finite value > 0, else 120 s. */
export function shutdownTimeoutMs(): number {
  const raw = Number(runtimeValue("MLX_BUN_SHUTDOWN_TIMEOUT_MS"));
  return Number.isFinite(raw) && raw > 0 ? raw : 120_000;
}

/** Internal (the worker app form; a parent may call it to fail fast before
 * spawning): serve arguments parsed and validated exactly as the CLI does,
 * minus what cannot run behind a launch socket. `--host`, `--port`, and
 * `--no-open` are accepted and never steer the socket bind. `--isolate` and
 * `--model-pool` are refused: a nested isolated app binds TCP, never the
 * socket. A missing or empty model is refused: automatic selection may
 * download the starter model. */
export function validateAppLaunchArgv(argv: readonly string[]): CommandArgs {
  const args = parseCommand("serve", [...argv]);
  for (const flag of ["isolate", "model-pool"])
    if (args.values[flag] !== undefined) throw new Error(`--${flag} is not supported in a worker app launch: nested isolation would bind TCP, never the launch socket`);
  if (!parseServeOptions(args).query?.trim())
    throw new Error("a worker app launch needs a non-empty --model: automatic selection may download the starter model");
  return args;
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
  startTranscription: typeof startTranscriptionServer;
  interactive: boolean;
  open(url: string): void | Promise<void>;
  log(message: string): void;
  signals: SignalPort;
  exit(code: number): void;
  error(error: unknown): void;
}
const defaults: ServeDependencies = {
  resolve: resolveModelAuto, start: startModelServer, startTranscription: startTranscriptionServer, interactive: !!process.stdout.isTTY,
  async open(url) { const child = Bun.spawn(["open", url], { stdout: "ignore", stderr: "ignore" }); if (await child.exited !== 0) throw new Error("Browser could not be opened"); },
  log: message => console.log(message), signals: process, exit: code => process.exit(code),
  error: error => console.error(error instanceof Error ? error.message : String(error)),
};

/** `aborted`: a stop signal landed during startup, so the app is already
 * closed and was never announced (no URL, no browser). */
export interface ServedApp extends RunningApp { readonly aborted: boolean }

/** runServe's rejection when a stop signal cancels startup before an app
 * exists. A load failure, or a failed close of an app a stop interrupted,
 * rejects with its own error instead. */
export class StartupCancelledError extends Error {
  constructor() { super("startup cancelled by signal"); this.name = "StartupCancelledError"; }
}

export async function runServe(args: CommandArgs, supplied: Partial<ServeDependencies> = {}): Promise<ServedApp> {
  let options = parseServeOptions(args);
  const deps = { ...defaults, ...supplied };
  // A signal before the app exists cancels selection (a starter download stays
  // resumable) and, once the model has loaded, closes the app right away; the
  // shutdown handlers take over as soon as the listener is up.
  const startup = new AbortController();
  const cancelStartup = () => startup.abort(new StartupCancelledError());
  deps.signals.on("SIGINT", cancelStartup); deps.signals.on("SIGTERM", cancelStartup);
  let running: RunningApp | undefined, selection: Awaited<ReturnType<typeof resolveModelAuto>> | undefined, removeSignals = () => {};
  let closed: Promise<void> | undefined;
  const close = () => closed ??= (async () => { try { await running?.close(); } finally { removeSignals(); } })();
  try {
    selection = await deps.resolve(options.query, {}, startup.signal);
    // A signal that landed during selection must not start a native load.
    startup.signal.throwIfAborted();
    if (isTranscriptionModelType(selection.m.modelType)) {
      // Main: a Whisper checkpoint as the main model starts the transcription-only server.
      if (options.isolate) throw new Error("--isolate is not supported for the transcription-only server: a Whisper checkpoint as the main model has no chat model to isolate");
      deps.log(`Serving ${selection.m.repoId} as a transcription-only server${options.whisper?.preload ? " (loading the weights first)" : ""}`);
      running = await deps.startTranscription(selection.m, options);
    } else {
      // Main resolves the draft model like the main model (a query never downloads).
      if (options.draft?.model) {
        const draft = await deps.resolve(options.draft.model, {}, startup.signal);
        startup.signal.throwIfAborted();
        options = { ...options, draft: { ...options.draft, modelDir: draft.m.path } };
      }
      // Main resolves --whisper-model the same way and refuses a non-Whisper checkpoint before loading.
      if (options.whisper?.model) {
        const whisper = await deps.resolve(options.whisper.model, {}, startup.signal);
        startup.signal.throwIfAborted();
        if (!isTranscriptionModelType(whisper.m.modelType))
          throw new Error(`--whisper-model ${options.whisper.model} resolved to ${whisper.m.repoId} (model_type ${whisper.m.modelType}), not a Whisper checkpoint`);
        options = { ...options, whisper: { ...options.whisper, modelDir: whisper.m.path, modelId: whisper.m.repoId } };
      }
      deps.log(`Loading ${selection.m.repoId}${selection.picked ? " (auto-selected)" : ""}`);
      running = await deps.start(selection.m, options);
    }
    removeSignals = installShutdownHandlers(close, { signals: deps.signals, exit: deps.exit, error: deps.error, timeoutMs: shutdownTimeoutMs() });
  } finally { deps.signals.removeListener("SIGINT", cancelStartup); deps.signals.removeListener("SIGTERM", cancelStartup); }
  const app: ServedApp = { port: running.port, downloads: running.downloads, close, aborted: false };
  if (startup.signal.aborted) { await close(); return { ...app, aborted: true }; }
  if (selection.recommended) {
    // Main started this transfer during selection and dropped its handle; the
    // app's owner now carries it, reports it on /downloads, and joins it at shutdown.
    try { running.downloads.start(selection.recommended); } catch (error) { deps.error(error); }
  }
  // Socket mode (the worker app form) has no URL to announce and no browser to open.
  const url = running.port === undefined ? undefined : browserUrl(options.hostname, running.port);
  if (isTranscriptionModelType(selection.m.modelType)) {
    // No web app: nothing to open. Residency is the policy the flags set.
    const idle = options.whisper?.idleUnloadSec ?? 0;
    const residency = options.whisper?.resident ? "always resident" : idle === 0 ? "released after every take" : `idle unload ${idle}s`;
    deps.log(`POST ${url ? url.replace("/#/chat", "/v1/audio/transcriptions") : "/v1/audio/transcriptions over the Unix socket"} (${residency}; ${options.whisper?.preload ? "loaded" : "loads on first request"})${url ? "\nStop: Ctrl+C" : ""}`);
    return app;
  }
  if (!url) {
    deps.log(`Serving ${selection.m.repoId} with continuous batching (capacity ${options.capacity}) over the Unix socket`);
    return app;
  }
  deps.log(`Serving ${selection.m.repoId} with continuous batching (capacity ${options.capacity})${options.isolate ? ` in an isolated engine worker (model pool ${options.modelPool ?? 1})` : ""}\nApp ${url}\nAPI ${url.replace("/#/chat", "/v1")}\nStop: Ctrl+C`);
  if (deps.interactive && !options.noOpen) {
    try { await deps.open(url); } catch (error) { deps.error(error); }
  }
  return app;
}
