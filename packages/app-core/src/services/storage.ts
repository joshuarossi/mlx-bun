/** The kind of thing a storage entry holds; the host creates it on first use. */
export type StorageKind = "directory" | "file" | "sqlite";

export interface StorageEntrySpec {
  /** Unique within the module. */
  readonly key: string;
  /** Relative to the storage root, unique across installed modules. */
  readonly path: string;
  readonly kind: StorageKind;
  readonly purpose: string;
}

/** Resolves a module's declared entries under `MLX_BUN_HOME`. Nothing is
 * written elsewhere by default, and explicit user paths always win over these
 * defaults. */
export interface StorageService {
  /** Absolute path of an entry the module declared; throws for any other key. */
  path(key: string): string;
}
