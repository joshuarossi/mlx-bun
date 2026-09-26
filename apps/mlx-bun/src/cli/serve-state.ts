// The persistent half of the serve composition: CPU-only services that outlive
// any loaded model (web assets, download owner, Responses history, memory,
// jobs, sessions, credentials, and their routes). Nothing here imports the
// engine or a native module at runtime, so a process without the MLX library
// can own this state while a model host runs elsewhere. The model host it
// serves is attached explicitly; no service reaches a model through globals.
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { Registry } from "@mlx-bun/hub/registry";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { PiBackendPaths } from "../chat/pi-backend";
import { defaultSessionDir } from "../chat/session-files";
import { createDatasetRunner } from "../dataset/job";
import { createDownloadOwner, type DownloadOwner } from "../hub/downloads";
import { JobStore } from "../jobs/db";
import { createJobHost } from "../jobs/host";
import { createMemorySurface } from "../memory/surface";
import { vaultRoot } from "../memory/vault";
import { createHfCredentials } from "../publishing/credentials";
import { createPublisher } from "../publishing/upload";
import { createDatasetRoutes } from "../server/dataset-routes";
import { createFinetuneRoutes } from "../server/finetune-routes";
import { createHubRoutes } from "../server/hub-routes";
import { createJobRoutes } from "../server/job-routes";
import { createMemoryRoutes } from "../server/memory-routes";
import { createPublishingRoutes } from "../server/publishing-routes";
import { createQuantizeRoutes } from "../server/quantize-routes";
import { ResponseStore, type ResponseHistory } from "../server/responses";
import { createSessionRoutes } from "../server/session-routes";
import { createWebHandler } from "../web/assets";

export interface AppStoragePaths { jobsDb?: string; jobsLogs?: string; credentialsFile?: string; artifactRoot?: string }

export interface AppStateOptions {
  /** The requested listener port; an attached host's bound port replaces it. */
  port: number;
  memoryPaths?: { vault: string; skills: string };
  chatPaths?: PiBackendPaths;
}

/** What a live model host lends the persistent services while it serves. */
export interface ModelHostLink {
  /** The public port loopback clients (dataset jobs) target. */
  readonly port: number;
  /** Managed GPU jobs hold this lease until their child exits and logs drain. */
  acquireExecutionLease(signal: AbortSignal): Promise<DisposableResource>;
  /** A finished download or job changes the model library the host lists. */
  invalidateLibrary(): void;
}

export interface RouteGroup { handle(request: Request): Promise<Response | null> }

export interface AppState {
  /** Serves already-built browser assets; never loads a model. */
  web(request: Request): Response | null;
  readonly downloads: DownloadOwner;
  /** Responses API conversation history, shared by every host this state serves. */
  readonly responses: ResponseHistory;
  readonly memoryPaths: { vault: string; skills: string };
  readonly chatPaths: PiBackendPaths | undefined;
  readonly sessionDir: string;
  readonly storagePaths: AppStoragePaths;
  /** The chat memory surface over the vault; undefined while memory is disabled. */
  memorySurface(): ReturnType<typeof createMemorySurface>;
  /** Persistent route groups; the host mounts them in the app's route order. */
  readonly routes: {
    hub: RouteGroup; sessions: RouteGroup; memory: RouteGroup; jobs: RouteGroup;
    quantize: RouteGroup; dataset: RouteGroup; finetune: RouteGroup; publishing: RouteGroup;
  };
  /** Lend a serving host to jobs, downloads, and loopback clients; returns the detach. */
  attach(link: ModelHostLink): () => void;
  /** Cancel and join background producers (jobs, downloads). Idempotent. */
  close(): Promise<void>;
}

/** CPU composition owns its services until the app closes them; the model host
 * only borrows what it mounts. */
export async function createAppState(options: AppStateOptions, storagePaths: AppStoragePaths = {}): Promise<AppState> {
  const web = await createWebHandler();
  let host: ModelHostLink | undefined;
  const requireHost = () => { if (!host) throw new Error("no model host is attached"); return host; };
  const invalidateLibrary = () => { host?.invalidateLibrary(); };
  // Web-started transfers outlive their request. The owner's rows feed
  // discovery and chat; completion refreshes the registry and discovery, and
  // shutdown joins every transfer before the engine closes.
  const downloads = createDownloadOwner({
    onComplete: async repoId => {
      const registry = new Registry();
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
  const memoryPaths = options.memoryPaths ?? { vault: vaultRoot(), skills: join(homedir(), ".mlx-bun", "skills") };
  const sessionDir = options.chatPaths?.sessionDir ?? defaultSessionDir();
  const credentials = createHfCredentials({ tokenFile: storagePaths.credentialsFile });
  const datasetRunner = createDatasetRunner();
  const routes: AppState["routes"] = {
    hub: createHubRoutes({ downloads }),
    sessions: createSessionRoutes(sessionDir),
    memory: createMemoryRoutes({ root: () => memoryPaths.vault }),
    jobs: createJobRoutes(jobs),
    quantize: createQuantizeRoutes(jobs),
    dataset: createDatasetRoutes({ serverPort: () => host?.port ?? options.port,
      submit: (config, output) => jobs.submitTask("dataset", config, datasetRunner, output) }),
    finetune: createFinetuneRoutes(jobs, storagePaths.artifactRoot
      ? () => join(storagePaths.artifactRoot!, "adapters", `adapter-${Date.now()}-${crypto.randomUUID()}`) : undefined),
    publishing: createPublishingRoutes({ credentials, publish: createPublisher({ credentials,
      getJob: id => jobs.ensureStore().get(id),
    }) }),
  };
  let closing: Promise<void> | undefined;
  return {
    web, downloads, responses: new ResponseStore(), memoryPaths, chatPaths: options.chatPaths, sessionDir, storagePaths,
    memorySurface: () => createMemorySurface(memoryPaths.vault, memoryPaths.skills),
    routes,
    attach(link) {
      host = link;
      return () => { if (host === link) host = undefined; };
    },
    close: () => closing ??= (async () => {
      const errors: unknown[] = [];
      for (const result of await Promise.allSettled([jobs.close(), downloads.close()]))
        if (result.status === "rejected") errors.push(result.reason);
      if (errors.length === 1) throw errors[0];
      if (errors.length) throw new AggregateError(errors, "background shutdown failed");
    })(),
  };
}
