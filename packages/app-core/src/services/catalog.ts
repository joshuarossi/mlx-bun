import type { ModelOperation } from "./model-host";

export type CatalogKind = "model" | "adapter";

/** What an indexing catalog knows of a model beyond its id: what a listing, a fit estimate or a capability badge shows. */
export interface ModelDetails {
  /** Parameter count, when the checkpoint's index states it. */
  readonly parameters: number | null;
  readonly quantBits: number | null;
  readonly quantGroupSize: number | null;
  /** The license id of its model card. */
  readonly license: string | null;
  readonly vision: boolean;
  readonly audio: boolean;
  /** Ships a tool-calling chat template. */
  readonly tools: boolean;
  /** Ships a per-layer KV quantization config. */
  readonly kvQuant: boolean;
  /** Bytes of mixture-of-experts tensors; 0 for a dense model. */
  readonly expertsBytes: number;
  /** Bytes of the vision sidecar, which loads only for vision. */
  readonly sidecarBytes: number;
  /** How the engine supports its family; null when it does not. */
  readonly supportTier: "targeted" | "generic" | null;
  /** The Hub cache snapshot the entry is, absent for a plain directory. */
  readonly revision?: string;
  /** False on a snapshot a newer revision of the same repo superseded. */
  readonly canonical?: boolean;
}

export interface CatalogEntry {
  /** The exact id every other service and module uses. */
  readonly id: string;
  readonly kind: CatalogKind;
  readonly directory: string;
  readonly bytes: number;
  readonly operations: readonly ModelOperation[];
  /** The `model_type` of its config, when known. */
  readonly modelType?: string;
  /** The model an adapter mounts on. */
  readonly base?: string;
  /** What the index knows of a model; absent for a directory it does not index and for an adapter. */
  readonly details?: ModelDetails;
  /** An adapter's rank (null when its config states none) and scale. */
  readonly adapter?: { readonly rank: number | null; readonly scale: number };
}

/** What `list` returns: one entry per model by default. */
export interface CatalogFilter {
  readonly kind?: CatalogKind;
  /** A case-insensitive substring of the model id. */
  readonly query?: string;
  /** Only models that answer vision requests. */
  readonly vision?: boolean;
  /** Only models whose weights are at most this many bytes. */
  readonly maxBytes?: number;
  /** `snapshots` lists every Hub cache revision of a repo (the canonical one marked in `details`), not one per repo. */
  readonly revisions?: "canonical" | "snapshots";
  /** Also list companion artifacts (a speculative-decoding drafter), which are never selectable as a model. */
  readonly companions?: boolean;
  /** Re-index the Hub cache before listing, as a listing that must show what is on disk now does. Unlike `rescan` it announces nothing. */
  readonly refresh?: boolean;
}

/** A model directory an operating-system folder picker selected. The picker reveals a folder's name (and,
 * from a file input, its path inside the folder), never its location. */
export interface FolderSelection {
  /** The picked folder's name (a hub cache repo folder `models--org--name` or a snapshot hash). */
  readonly name?: string;
  /** The picked folder's path relative to the picked root, when the browser gave one. */
  readonly relPath?: string;
}

/** Where a selected folder lives. `id` is the model's exact catalog id when the folder is a known model. */
export interface LocatedFolder {
  readonly directory: string;
  readonly id?: string;
  /** The `model_type` its config declares, when the folder is an indexed model. */
  readonly type?: string;
}

export type DownloadProgress = (file: string, received: number, total: number) => void;

/** One transfer the catalog runs or ran: a repo the web asked for, with live progress. */
export interface DownloadRow {
  readonly repoId: string;
  readonly state: "active" | "done" | "error";
  readonly currentFile: string | null;
  readonly receivedBytes: number;
  readonly totalBytes: number;
  readonly bytesPerSec?: number;
  readonly error?: string;
}

export interface PublishRequest {
  /** The Hub repo, `org/name`. */
  readonly repoId: string;
  readonly private?: boolean;
  /** The commit message of the upload; the host's default otherwise. */
  readonly commitMessage?: string;
  readonly signal?: AbortSignal;
  /** Bytes of `file` sent so far out of `total`. */
  readonly onProgress?: DownloadProgress;
}

/** Why a catalog call failed, for the failures a caller answers differently. */
export type CatalogFailureCode = "duplicate-download" | "not-supported";
export interface CatalogError extends Error { readonly code: CatalogFailureCode }

/** Models and adapters known locally: the Hugging Face cache, the app's
 * model and adapter directories, and outputs modules register. */
export interface ModelCatalog {
  list(filter?: CatalogFilter): Promise<readonly CatalogEntry[]>;
  /** Exact id only; never scans or downloads. */
  resolve(id: string): Promise<CatalogEntry | undefined>;
  /** What a user typed: a model directory (its path is its id), an id, or a query that names exactly one local model. Rejects when it names none or several; never downloads. */
  find(query: string): Promise<CatalogEntry>;
  /** The model a verb runs on when the user names none: this host's automatic choice (the preferred model when it fits the machine, else the largest that leaves room for other apps; an empty cache fetches a starter first). Rejects when none fits or the host makes no such choice. */
  pickDefault(options?: { readonly signal?: AbortSignal }): Promise<CatalogEntry>;
  /** Bytes the model needs resident, for residency plans. */
  estimate(id: string): Promise<{ readonly residentBytes: number } | undefined>;
  /** Where a picked folder lives: the hub cache snapshot, the app's own models directory, or an indexed model. Undefined when it is none of them; never downloads. */
  locate(selection: FolderSelection): Promise<LocatedFolder | undefined>;
  /** Adds a finished output (train, quantize, convert). Publishes `catalog.changed`. */
  register(directory: string, kind: CatalogKind): Promise<CatalogEntry>;
  /** Re-indexes the Hub cache and the app's model directory without reading tensor bytes; resolves to the snapshots indexed. Publishes `catalog.changed`. */
  rescan(): Promise<number>;
  /** Fetches a model into the hub cache (resumable, verified) and indexes it; the signal stops it between checkpoints. `revision` is a git revision (default `main`). */
  download(id: string, options?: { readonly revision?: string; readonly signal?: AbortSignal; readonly onProgress?: DownloadProgress }): Promise<CatalogEntry>;
  /** Starts a download that outlives the caller (the web's) and returns at once; progress is `downloads()`. Throws a `CatalogError` coded `duplicate-download` while the repo already has one running, and `not-supported` on a host that owns none. Publishes `catalog.changed` when it completes. */
  startDownload(id: string): void;
  /** One row per transfer, the running ones and the recent finished ones. */
  downloads(): readonly DownloadRow[];
  /** Whether a Hub write token is available, so a verb can refuse before it does any work. */
  canPublish(): boolean;
  /** Pushes a finished model directory to the Hub; rejects when no write token is available. */
  publish(directory: string, request: PublishRequest): Promise<{ readonly url: string }>;
}
