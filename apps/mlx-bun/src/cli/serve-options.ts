// Serve's option shape and the pure policy resolved from it. Both halves of
// the composition (serve-state, serve-host) and the CLI wrapper share these
// without importing each other.
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import type { CacheServiceOptions } from "../engine/cache-services";
import type { MemoryPlan } from "@mlx-bun/inference/contracts/portable";
import type { RequestPrepOptions } from "../server/request-prep";
import type { PiBackendPaths } from "../chat/pi-backend";
import type { DraftKind } from "../engine/model-host";
import type { DownloadOwner } from "../hub/downloads";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import type { AppStoragePaths } from "./serve-state";

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
  /** `--model-budget`, decimal bytes: what all resident models may use together; absent uses a share of the GPU's recommended working set. */
  modelBudgetBytes?: number;
  /** Main's `--context-length`: the context a memory-planning runtime reserves; models without a plan ignore it. */
  contextTokens?: number;
  /** Startup kernel override; absent derives from the selected KV scheme. */
  fusedSdpa?: boolean;
  forceWire?: boolean;
  expertOffload?: boolean;
  allowPrivateMedia?: boolean;
  /** Main's `--adapter`/`--adapter-path`: mounted at startup as the default adapter. */
  adapterDir?: string;
  /** Main's speculative-decoding flags. `model` is the query as typed; startup
   * resolves it like the main model into `modelDir` before loading. */
  draft?: { model?: string; modelDir?: string; kind?: DraftKind; numTokens?: number; ngramMax?: number; ngramMin?: number };
  /** Main's `--mtp on|off`: the checkpoint-native draft head; models without one ignore it. */
  mtp?: boolean;
  /** Main's `--whisper-*` and `--preload`: the speech-to-text companion. `model`
   * is the query as typed; startup resolves it into `modelDir`/`modelId` before
   * loading. Without one, the first downloaded Whisper checkpoint is resolved on
   * the first audio request. `preload` applies to the transcription-only server. */
  whisper?: { model?: string; modelDir?: string; modelId?: string; idleUnloadSec?: number; resident?: boolean; preload?: boolean };
  readOnly: boolean;
  noOpen: boolean;
  /** `--in-process`: the models load in this process (serve-host.ts) instead of in a worker process each behind this
   * process's proxy (serve-isolated.ts, the default). */
  inProcess?: boolean;
  cache: CacheServiceOptions;
  request: RequestPrepOptions;
  /** App-owned vault and skill destinations; not CLI flags. */
  memoryPaths?: { vault: string; skills: string };
  /** App composition only; shares Pi storage with its settings routes. */
  chatPaths?: PiBackendPaths;
  /** App-owned storage overrides for embedding and tests, like chatPaths and
   * memoryPaths: the job store, the saved Hugging Face token file, and the root
   * for adapter merge/export and fine-tune outputs. Defaults live under HOME. */
  storagePaths?: AppStoragePaths;
}

/** Main's loaded-model limits constrain the context window; an explicit output
 * cap overrides the model plan's default without changing its context budget.
 * An explicit memory budget makes the admission estimate's safe context the
 * enforced ceiling, as in main; without one only a runtime memory plan or profile cap applies. */
export function resolveServingLimits(
  options: Pick<ServeOptions, "contextLimit" | "defaultGeneratedTokens" | "memoryBudgetBytes">,
  plan?: Pick<MemoryPlan, "contextTokens" | "maxGenerationTokens"> | null,
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
  /** The bound TCP port; absent when the app listens on a Unix socket (the worker app form). */
  port?: number;
  /** The app's transfer owner: startup hands it the recommended background
   * download; shutdown aborts and joins whatever it still carries. */
  downloads: Pick<DownloadOwner, "start" | "active">;
  close(): Promise<void>;
}

/** Validate resolved startup policy before handing resources to the engine.
 * Paging must not silently replace a selected KV codec or draft provider. */
export function validatePagedServingOptions(
  pagedKv: RequestPrepOptions["pagedKv"],
  kvScheme: Pick<KvSchemeOptions, "kvConfig" | "turboQuant">,
  hasDraft: boolean,
): void {
  if (!pagedKv) return;
  if (kvScheme.kvConfig?.length || kvScheme.turboQuant)
    throw new Error("--paged-kv supports bf16 and uniform affine KV4/KV8; per-layer and TurboQuant pages are not implemented.");
  if (hasDraft)
    throw new Error("--paged-kv cannot combine with --draft-model in v1.");
}

/** Main's MLX_BUN_SHUTDOWN_TIMEOUT_MS: any finite value > 0, else 120 s. How long a close may take to drain work and flush saved state. */
export function shutdownTimeoutMs(): number {
  const raw = Number(runtimeValue("MLX_BUN_SHUTDOWN_TIMEOUT_MS"));
  return Number.isFinite(raw) && raw > 0 ? raw : 120_000;
}
