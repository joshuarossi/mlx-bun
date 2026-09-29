// The local model catalog over the hub's registry: what is downloaded or
// produced here, and what each model declares it can do. Resolving reads the
// index; nothing downloads and nothing is registered by this host.
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import type { CatalogEntry, CatalogKind, ModelCatalog, ModelOperation } from "@mlx-bun/app-core";
import type { ModelRecord, Registry } from "@mlx-bun/hub/registry";
import { isDrafterModelType, isEmbeddingModelType, isSupportedModelRecord, isTranscriptionModelType } from "@mlx-bun/inference/models/support";
import { openModelRegistry } from "./home";

type CatalogRegistry = Pick<Registry, "list" | "listCanonical" | "resolve" | "scan" | "close">;

export interface RegistryCatalogOptions {
  /** A fresh handle per call, closed after it. Default: the index under MLX_BUN_HOME. */
  registry?: () => CatalogRegistry;
}

/** What a model declares, from its `model_type`: consumers ask for these, never for a family. */
export function declaredOperations(modelType: string): ModelOperation[] {
  if (isTranscriptionModelType(modelType)) return ["transcribe"];
  if (isDrafterModelType(modelType)) return [];
  return [...(isSupportedModelRecord(modelType) ? ["generate" as const] : []), ...(isEmbeddingModelType(modelType) ? ["embed" as const] : [])];
}

const entryOf = (record: Pick<ModelRecord, "repoId" | "path" | "sizeBytes" | "modelType">): CatalogEntry =>
  ({ id: record.repoId, kind: "model", directory: record.path, bytes: record.sizeBytes, operations: declaredOperations(record.modelType) });

export function createRegistryCatalog(options: RegistryCatalogOptions = {}): ModelCatalog {
  const open = options.registry ?? (() => openModelRegistry());
  /** The registry with an empty index scanned once, as the first lookup on a fresh machine needs. */
  const withRegistry = async <T>(use: (registry: CatalogRegistry) => T | Promise<T>): Promise<T> => {
    const registry = open();
    try {
      if (registry.list().length === 0) await registry.scan();
      return await use(registry);
    } finally { registry.close(); }
  };
  const notSupported = (what: string) => Promise.reject(new Error(`this host does not ${what}`));
  const resolve = (id: string) => withRegistry(registry => registry.listCanonical().filter(record => record.repoId === id).map(entryOf)[0]);
  return {
    async list(filter) {
      if (filter?.kind === ("adapter" satisfies CatalogKind)) return [];
      return withRegistry(registry => registry.listCanonical().filter(record => !isDrafterModelType(record.modelType)).map(entryOf));
    },
    resolve,
    async find(query) {
      // A directory with a config.json is used as given: its path is its id.
      if (existsSync(join(query, "config.json"))) {
        let modelType = "";
        try { modelType = String((JSON.parse(readFileSync(join(query, "config.json"), "utf8")) as { model_type?: unknown }).model_type ?? ""); } catch { /* unreadable: declares nothing */ }
        return { id: query, kind: "model", directory: query, bytes: 0, operations: declaredOperations(modelType) };
      }
      return withRegistry(registry => entryOf(registry.resolve(query)));
    },
    async estimate(id) {
      const entry = await resolve(id);
      return entry ? { residentBytes: entry.bytes } : undefined;
    },
    register: () => notSupported("register model outputs"),
    download: () => notSupported("download models"),
  };
}
