// The public `mlx-bun/server` entry: main's in-process `createServer` over a
// caller-loaded model context, with main's `loadContext`. The server is the app
// `mlx-bun serve` composes (serve.ts startApp: the persistent state, then
// serve-host's startContextHost), so it serves the same routes, browser app,
// Pi chat, jobs, and hub. Loading this module loads no native library and
// starts nothing; `createServer` imports the composition when it is called.
import type { DurabilityFlushResult } from "@mlx-bun/inference/state";
import { releaseContext, type ContextOwnership, type LoadedModelContext } from "../engine/model-host";
import type { ContextHost, ContextHostOptions } from "./serve-host";
import type { ServeOptions } from "./serve-options";

export { loadContext } from "../engine/model-host";
export type { AdapterService, ContextOwnership, DraftKind, GenSamplingDefaults, LoadContextOptions, LoadedModelContext,
  ModelContext, ModelHostSource, ServedModelInfo } from "../engine/model-host";
export type { ModelBinding } from "../engine/model-binding";
export type { BuiltPrompt, ModelPromptBuilder, PromptNativeWork } from "../server/prompt-contracts";
export type { DurabilityFlushResult, DurabilitySnapshotStats } from "@mlx-bun/inference/state";

/** Serving policy, `mlx-bun serve`'s options by their programmatic names. */
export interface ServerOptions extends Partial<Pick<ServeOptions, "capacity" | "defaultGeneratedTokens" | "kvBudgetBytes" |
  "memoryBudgetBytes" | "readOnly" | "cache" | "request" | "memoryPaths" | "chatPaths" | "storagePaths">>,
  Omit<ContextHost, "ownership" | "owner"> {
  /** The interface to bind. Omitted: Bun's default, every interface (main's
   * library default); `mlx-bun serve` binds 127.0.0.1. */
  hostname?: string;
  /** The enforced context ceiling. Omitted: `MLX_BUN_RD_CONTEXT_LIMIT` when set, else none. */
  contextLimit?: number | null;
  /** The speech-to-text companion's checkpoint directory and residency; omitted,
   * the first downloaded Whisper checkpoint is found on the first audio request. */
  whisper?: Pick<NonNullable<ServeOptions["whisper"]>, "modelDir" | "modelId" | "idleUnloadSec" | "resident">;
  /** Default "borrowed" (main's): the server never disposes the context. */
  ownership?: ContextOwnership;
}

export interface ServerShutdownResult {
  /** The drain finished: the listener stopped and every resource the server created was released. */
  stopped: boolean;
  /** The deadline passed first. The drain continues; nothing was released early. */
  timedOut: boolean;
  /** The final cache flush's result. After a timeout, the pending counters with `durable: false`. */
  durability: DurabilityFlushResult;
}

export interface RunningServer {
  /** The bound TCP port. */
  readonly port: number;
  /** Flush prompt-cache persistence while serving (main's `flushServerCacheDurability`). */
  flush(): Promise<DurabilityFlushResult>;
  /** Stop admission and drain (main's `shutdownServer`); see createServer. */
  close(options?: { timeoutMs?: number }): Promise<ServerShutdownResult>;
}

/**
 * Serve a loaded model context in this process: the full `mlx-bun serve` app
 * (OpenAI, Anthropic, and Responses APIs, `/stats`, adapters, cache
 * administration, the browser app, Pi web chat on `/ws/chat`, jobs, hub,
 * memory, sessions, and publishing), over one shared continuous engine.
 * Resolves once the listener is bound; `port` 0 binds an ephemeral port.
 *
 * The context comes from `loadContext` or a caller's own implementation.
 * Without `options.binding` the built-in model classes supply the numerics; a
 * supplied `binding` and `buildPrompt` reach the engine and routes as given,
 * with no registry lookup, model class, or reload. Chat prompts render the
 * context's template, and a context without one is refused, unless
 * `buildPrompt` builds them (it then returns `probeStableLen: false`).
 * `artifact` only describes the weights for `/fit`, `/stats`, and hub GC
 * protection.
 *
 * The server applies no runtime switches and activates no expert offload; the
 * process's runtime configuration and whatever loaded the context own those.
 * It sets the MLX allocator limit from the context's runtime memory plan or
 * `memoryBudgetBytes` and restores the previous limit after close. That limit
 * is process-wide: servers running at the same time in one process share it,
 * the last applied wins, and each close restores the value it found. Sequential
 * servers over one context are supported. No signal handler, browser, or
 * download is started; user stores default to HOME unless `memoryPaths`,
 * `chatPaths`, or `storagePaths` name others.
 *
 * Ownership: by default the context is borrowed. Close, and any failed start
 * (options, state, binding, caches, engine, or bind), release everything the
 * server created and never the context, which stays usable (for another
 * server) until the caller disposes it after close has resolved with
 * `stopped: true`. With `ownership: "owned"` the server disposes the context
 * exactly once, after execution drains or when startup fails, even when other
 * cleanup fails.
 *
 * `close({ timeoutMs = 120_000 })` stops admission (new requests get 503),
 * stops jobs and downloads, closes chat sessions, waits for responses in
 * flight, then releases the engine, flushes and clears the caches, releases an
 * owned context, and restores the allocator limit. One drain runs however often
 * it is called; a failure rejects every call. It resolves `{ stopped: true,
 * timedOut: false, durability }` with the final flush's result, which is
 * `durable: false` when persistence is incomplete. If the deadline passes
 * first it resolves `{ stopped: false, timedOut: true }` with the pending
 * counters and `durable: false`, and the drain continues: weights are never
 * released under running execution. Call close again (`timeoutMs: Infinity`
 * waits without a deadline) before disposing a borrowed context.
 */
export async function createServer(context: LoadedModelContext, port = 0, options: ServerOptions = {}): Promise<RunningServer> {
  const ownership = options.ownership ?? "borrowed";
  // An owned context is released here if startup fails before the host takes
  // it; the host owns its release, and every later cleanup, from its call on.
  let transferred = false;
  let app;
  try {
    const [{ startApp, profileContextLimit }, { startContextHost }, { createInProcessMemoryClient }] = await Promise.all([
      import("./serve"), import("./serve-host"), import("./memory-engine"),
    ]);
    const serving: ContextHostOptions = { port, hostname: options.hostname ?? null, capacity: options.capacity ?? 8,
      contextLimit: options.contextLimit === undefined ? profileContextLimit() : options.contextLimit,
      readOnly: options.readOnly ?? false, cache: options.cache ?? {}, request: options.request ?? {},
      defaultGeneratedTokens: options.defaultGeneratedTokens, kvBudgetBytes: options.kvBudgetBytes,
      memoryBudgetBytes: options.memoryBudgetBytes, whisper: options.whisper };
    const served: ContextHost = { ownership, binding: options.binding, buildPrompt: options.buildPrompt,
      artifact: options.artifact, defaultAdapter: options.defaultAdapter };
    // Memory synthesis gets main's task model, as in `mlx-bun serve`; nothing
    // loads before a run. The host's drain joins the state's close (jobs,
    // downloads, synthesis) while the engine and model are still alive.
    app = await startApp({ port, memoryPaths: options.memoryPaths, chatPaths: options.chatPaths,
      memoryTaskModel: () => createInProcessMemoryClient() }, options.storagePaths ?? {}, state => {
      transferred = true;
      return startContextHost(state, context, serving, served, { beforeDrain: () => state.close() });
    });
  } catch (error) {
    if (!transferred) {
      try { releaseContext(context, ownership); }
      catch (failure) { throw new AggregateError([error, failure], "startup and cleanup failed"); }
    }
    throw error;
  }
  const { host } = app;
  let drain: Promise<ServerShutdownResult> | undefined;
  return {
    port: host.port,
    flush: () => host.flush(),
    async close({ timeoutMs = 120_000 } = {}) {
      const started = performance.now();
      const work = drain ??= app.close().then(durability => ({ stopped: true, timedOut: false, durability }));
      if (!Number.isFinite(timeoutMs)) return work;
      let timer: ReturnType<typeof setTimeout> | undefined;
      const deadline = new Promise<ServerShutdownResult>(resolve => {
        timer = setTimeout(() => resolve({ stopped: false, timedOut: true, durability: { ...host.stats(), durable: false,
          flushedSnapshots: 0, missingSnapshots: 0, elapsedMs: performance.now() - started } }), Math.max(0, timeoutMs));
      });
      try { return await Promise.race([work, deadline]); } finally { clearTimeout(timer); }
    },
  };
}
