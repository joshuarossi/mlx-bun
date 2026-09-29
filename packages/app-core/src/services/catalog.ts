import type { ModelOperation } from "./model-host";

export type CatalogKind = "model" | "adapter";

export interface CatalogEntry {
  /** The exact id every other service and module uses. */
  readonly id: string;
  readonly kind: CatalogKind;
  readonly directory: string;
  readonly bytes: number;
  readonly operations: readonly ModelOperation[];
  /** The model an adapter mounts on. */
  readonly base?: string;
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
  /** Adds a finished output (train, quantize, convert). Publishes `catalog.changed`. */
  register(directory: string, kind: CatalogKind): Promise<CatalogEntry>;
  download(id: string, signal?: AbortSignal): Promise<CatalogEntry>;
}
