// The persistent half of the serve composition: CPU-only services that outlive
// any loaded model (web assets, download owner, Responses history, memory,
// jobs, the modules that run here (chat among them), credentials, and their
// routes and sockets). Nothing here imports the
// engine or a native module at runtime, so a process without the MLX library
// can own this state while a model host runs elsewhere. The model host it
// serves is attached explicitly; no service reaches a model through globals.
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { AppModule } from "@mlx-bun/app-core";
import { activateModules, createEventHub, createModuleRoutes, createModuleSockets, createRegistryCatalog, createStorage, mlxBunHome, type EventHub, type ModuleSockets } from "@mlx-bun/app-services/portable";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import { createDownloadOwner, type DownloadOwner } from "../hub/downloads";
import { JobStore } from "../jobs/db";
import { createJobHost } from "../jobs/host";
import { createJobService } from "../jobs/service";
import { createMemoryChatModule } from "../memory/chat";
import { vaultRoot } from "../memory/vault";
import { createCatalogHub } from "../publishing/catalog-hub";
import { createHfCredentials } from "../publishing/credentials";
import { createPublisher } from "../publishing/upload";
import { createFinetuneRoutes } from "../server/finetune-routes";
import { createHubRoutes } from "../server/hub-routes";
import { createModelFolderRoutes } from "../server/model-folder-routes";
import { createJobRoutes } from "../server/job-routes";
import type { InProcessMemoryClient } from "./memory-engine";
import { createServedModelHost, type ServedHostLink } from "./served-model-host";
import type { MemoryCompletionClient } from "../memory/model";
import { createMemoryRoutes } from "../server/memory-routes";
import { createMemorySynthesis } from "../server/memory-synthesis";
import { createPublishingRoutes } from "../server/publishing-routes";
import { ResponseStore, type ResponseHistory } from "../server/responses";
import { createWebHandler } from "../web/assets";
import { openRegistry, storagePath } from "../storage/paths";

/** Where an embedder or a test put the chat's stores instead of the module's storage entries (`sessions/`, `pi-sessions/`,
 * `tool-approvals.json` under MLX_BUN_HOME); an explicit path always wins. `cwd` is the directory Pi's tools work in. */
export interface ChatPaths { cwd?: string; agentDir?: string; sessionDir?: string; toolApprovalsFile?: string }

/** Overrides for the app's default storage (storage/paths.ts). `artifactRoot`
 * replaces MLX_BUN_HOME for produced artifacts: its models/, adapters/,
 * exports/ and datasets/ receive quantize, fine-tune, merge and dataset outputs. */
export interface AppStoragePaths { jobsDb?: string; jobsLogs?: string; credentialsFile?: string; artifactRoot?: string }

export interface AppStateOptions {
  /** The requested listener port; an attached host's bound port replaces it. */
  port: number;
  memoryPaths?: { vault: string; skills: string };
  chatPaths?: ChatPaths;
  /** A read-only server (`ServeOptions.readOnly`): the chat gets no file-changing tool and denies every gated call. */
  readOnly?: boolean;
  /** Memory synthesis's model in the direct composition: main's memory task
   * model (Gemma-4 e4b with its chunk adapter), created by the first run and
   * kept until close, each call under the attached host's execution lease. */
  memoryTaskModel?: () => InProcessMemoryClient;
  /** Memory synthesis's model in a process that loads none (the --isolate
   * parent): one run's client for a task model another process owns and
   * leases itself (the default model worker's). Nothing is leased here. */
  memoryCompletions?: (signal: AbortSignal) => MemoryCompletionClient;
}

/** What a live model host lends the persistent services while it serves: its model and listener
 * (`ServedHostLink`), the execution lease and the library refresh. */
export interface ModelHostLink extends ServedHostLink {
  /** Managed GPU jobs hold this lease until their child exits and logs drain. */
  acquireExecutionLease(signal: AbortSignal): Promise<DisposableResource>;
  /** A finished download or job changes the model library the host lists. */
  invalidateLibrary(): void;
  /** Make the named local model the one served (`POST /api/hub/serve`): loaded beside the others when it fits, else in place of the least recently used one. Absent on a host that serves one model. */
  serve?(model: string, signal: AbortSignal): Promise<{ model: string }>;
}

export interface RouteGroup { handle(request: Request): Promise<Response | null> }

export interface AppState {
  /** Serves already-built browser assets; never loads a model. */
  web(request: Request): Response | null;
  readonly downloads: DownloadOwner;
  /** The `events` core service's bus: the model loader and the engine adapter publish, modules subscribe. It lives as long as the state. */
  readonly events: EventHub;
  /** Responses API conversation history, shared by every host this state serves. */
  readonly responses: ResponseHistory;
  readonly memoryPaths: { vault: string; skills: string };
  readonly storagePaths: AppStoragePaths;
  /** The sockets the modules that run here declare (chat's `/ws/chat`); the listener upgrades them and the modules own each connection. */
  readonly sockets: ModuleSockets;
  /** Persistent route groups; the host mounts them in the app's route order. */
  readonly routes: {
    hub: RouteGroup; memory: RouteGroup; jobs: RouteGroup;
    models: RouteGroup; appModules: RouteGroup; finetune: RouteGroup; publishing: RouteGroup;
  };
  /** Lend a serving host to jobs, downloads, and loopback clients; returns the detach. */
  attach(link: ModelHostLink): () => void;
  /** Cancel and join background producers (jobs, downloads). Idempotent. */
  close(): Promise<void>;
}

/** CPU composition owns its services until the app closes them; the model host
 * only borrows what it mounts. `modules` are the installed modules that run
 * here (`installedModules("state")`, supplied by the composition root so this
 * file never reaches module packages that load the engine). */
export async function createAppState(options: AppStateOptions, storagePaths: AppStoragePaths = {}, modules: readonly AppModule[] = []): Promise<AppState> {
  const web = await createWebHandler();
  let host: ModelHostLink | undefined;
  const requireHost = () => { if (!host) throw new Error("no model host is attached"); return host; };
  const invalidateLibrary = () => { host?.invalidateLibrary(); };
  // Web-started transfers outlive their request. The owner's rows feed
  // discovery and chat; completion refreshes the registry and discovery, and
  // shutdown joins every transfer before the engine closes.
  const downloads = createDownloadOwner({
    onComplete: async repoId => {
      const registry = openRegistry();
      try { await registry.scan(); } finally { registry.close(); }
      invalidateLibrary();
      console.log(`[hub] download complete: ${repoId}`);
    },
    onFailure: (repoId, error) => console.error(`[hub] download of ${repoId} failed: ${error instanceof Error ? error.message : String(error)}`),
  });
  const jobs = createJobHost({ entry: fileURLToPath(new URL("./job-entry.ts", import.meta.url)),
    acquire: signal => requireHost().acquireExecutionLease(signal),
    onComplete: () => invalidateLibrary(),
    ...(storagePaths.jobsDb !== undefined || storagePaths.jobsLogs !== undefined ? {
      createStore: () => new JobStore(storagePaths.jobsDb,
        storagePaths.jobsLogs ?? (storagePaths.jobsDb !== undefined ? join(dirname(storagePaths.jobsDb), "jobs") : undefined)),
    } : {}),
  });
  const memoryPaths = options.memoryPaths ?? { vault: vaultRoot(), skills: storagePath("skills") };
  const credentials = createHfCredentials({ tokenFile: storagePaths.credentialsFile });
  // The model catalog the state's modules and the folder picker share: the hub cache and the models directory, with the app's token behind downloads and pushes.
  const catalog = createRegistryCatalog({ hub: createCatalogHub(credentials),
    ...(storagePaths.artifactRoot ? { registry: () => openRegistry(storagePaths.artifactRoot), modelsRoot: () => storagePath("models", storagePaths.artifactRoot) } : {}) });
  // The installed modules that need job runners (datasets) run here, beside
  // the job store. They reach the served model through the attached host's own
  // API: over its Unix socket when it listens on one, else over TCP to its port.
  const events = createEventHub();
  const jobService = createJobService(jobs, { acquire: signal => requireHost().acquireExecutionLease(signal) });
  const served = createServedModelHost({ link: () => host,
    fetch: (request, link) => fetch(request, link.unix ? { unix: link.unix } as RequestInit : undefined) });
  // Memory's tools reach chat through the registry, so they activate beside it. The chat's stores an embedder placed elsewhere win over its storage entries.
  const chatStores = { ...(options.chatPaths?.sessionDir !== undefined ? { "chat.sessions": options.chatPaths.sessionDir } : {}),
    ...(options.chatPaths?.agentDir !== undefined ? { "chat.agent": options.chatPaths.agentDir } : {}),
    ...(options.chatPaths?.toolApprovalsFile !== undefined ? { "chat.approvals": options.chatPaths.toolApprovalsFile } : {}) };
  const loaded = await activateModules([...modules, createMemoryChatModule(memoryPaths)], { sockets: true, bindings: { jobs: () => jobService, modelHost: () => served, catalog: () => catalog, events: scope => events.scoped(scope),
    // Produced artifacts follow `artifactRoot`; the chat's saved sessions and approvals are the user's data, which it never moved.
    storage: createStorage(moduleId => moduleId === "chat" ? mlxBunHome() : storagePaths.artifactRoot ?? mlxBunHome(), chatStores) } });
  jobService.serve(loaded.jobs);
  // Memory synthesis runs on the task model, created on first use (its weights
  // load with the first completion) and kept until close, as in main. Each of
  // its completions or batches runs under the attached host's execution lease,
  // taken before the weights load and released once every started row joined,
  // so memory work never overlaps a managed job. The --isolate parent owns no
  // task model: its client reaches the default model worker's, which takes that
  // worker's lease itself, so none is taken here. Close cancels and joins the
  // runs, then closes the task model, all ahead of any engine drain.
  let taskModel: InProcessMemoryClient | undefined;
  const leased = (client: MemoryCompletionClient, signal: AbortSignal): MemoryCompletionClient => {
    const hold = async <T>(work: () => Promise<T>) => {
      const lease = await requireHost().acquireExecutionLease(signal);
      try { return await work(); } finally { lease.dispose(); }
    };
    return { complete: request => hold(() => client.complete(request)), completeBatch: requests => hold(() => client.completeBatch(requests)) };
  };
  const synthesis = createMemorySynthesis({ root: memoryPaths.vault, client: signal => {
    if (options.memoryTaskModel) return leased((taskModel ??= options.memoryTaskModel()).clientFor(signal), signal);
    if (options.memoryCompletions) return options.memoryCompletions(signal);
    throw new Error("memory synthesis has no task model in this composition");
  } });
  const routes: AppState["routes"] = {
    hub: createHubRoutes({ downloads, serve: async (model, signal) => host?.serve ? await host.serve(model, signal) : undefined }),
    memory: createMemoryRoutes({ root: () => memoryPaths.vault, synthesize: synthesis.run }),
    jobs: createJobRoutes(jobs),
    models: createModelFolderRoutes(catalog),
    appModules: createModuleRoutes(loaded.routes),
    finetune: createFinetuneRoutes(jobs, storagePaths.artifactRoot
      ? () => join(storagePath("adapters", storagePaths.artifactRoot), `adapter-${Date.now()}-${crypto.randomUUID()}`) : undefined),
    publishing: createPublishingRoutes({ credentials, publish: createPublisher({ credentials,
      getJob: id => jobs.ensureStore().get(id),
    }) }),
  };
  let closing: Promise<void> | undefined;
  return {
    web, downloads, events, responses: new ResponseStore(), memoryPaths, storagePaths,
    sockets: createModuleSockets(loaded.sockets),
    routes,
    attach(link) {
      host = link;
      return () => { if (host === link) host = undefined; };
    },
    close: () => closing ??= (async () => {
      const errors: unknown[] = [];
      // Synthesis rows, managed children and transfers are cancelled and joined
      // before the task model's weights are released; no lease is taken here.
      // Modules stop before the job host, which joins their running tasks.
      const stopJobs = async () => {
        const failures: unknown[] = [];
        try { await loaded.stop(); } catch (error) { failures.push(error); }
        try { await jobs.close(); } catch (error) { failures.push(error); }
        if (failures.length === 1) throw failures[0];
        if (failures.length) throw new AggregateError(failures, "job shutdown failed");
      };
      for (const result of await Promise.allSettled([synthesis.close(), stopJobs(), downloads.close()]))
        if (result.status === "rejected") errors.push(result.reason);
      try { await taskModel?.close(); } catch (error) { errors.push(error); }
      events.close();
      if (errors.length === 1) throw errors[0];
      if (errors.length) throw new AggregateError(errors, "background shutdown failed");
    })(),
  };
}
