import type { ModelOperation } from "./model-host";

export type CatalogKind = "model" | "adapter";

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

export interface PublishRequest {
  /** The Hub repo, `org/name`. */
  readonly repoId: string;
  readonly signal?: AbortSignal;
}

/** Models and adapters known locally: the Hugging Face cache, the app's
 * model and adapter directories, and outputs modules register. */
export interface ModelCatalog {
  list(filter?: { readonly kind?: CatalogKind }): Promise<readonly CatalogEntry[]>;
  /** Exact id only; never scans or downloads. */
  resolve(id: string): Promise<CatalogEntry | undefined>;
  /** What a user typed: a model directory (its path is its id), an id, or a query that names exactly one local model. Rejects when it names none or several; never downloads. */
  find(query: string): Promise<CatalogEntry>;
  /** Bytes the model needs resident, for residency plans. */
  estimate(id: string): Promise<{ readonly residentBytes: number } | undefined>;
  /** Where a picked folder lives: the hub cache snapshot, the app's own models directory, or an indexed model. Undefined when it is none of them; never downloads. */
  locate(selection: FolderSelection): Promise<LocatedFolder | undefined>;
  /** Adds a finished output (train, quantize, convert). Publishes `catalog.changed`. */
  register(directory: string, kind: CatalogKind): Promise<CatalogEntry>;
  /** Fetches a model into the hub cache (resumable, verified) and indexes it; the signal stops it between checkpoints. */
  download(id: string, options?: { readonly signal?: AbortSignal; readonly onProgress?: DownloadProgress }): Promise<CatalogEntry>;
  /** Whether a Hub write token is available, so a verb can refuse before it does any work. */
  canPublish(): boolean;
  /** Pushes a finished model directory to the Hub; rejects when no write token is available. */
  publish(directory: string, request: PublishRequest): Promise<{ readonly url: string }>;
}
