// The local model catalog over the hub's registry: what is downloaded or
// produced here, and what each model declares it can do. Resolving reads the
// index; nothing downloads and nothing is registered by this host.
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import type { CatalogEntry, CatalogKind, DownloadProgress, FolderSelection, LocatedFolder, ModelCatalog, ModelOperation, PublishRequest } from "@mlx-bun/app-core";
import { hubCacheRoot, type ModelRecord, type Registry } from "@mlx-bun/hub/registry";
import { isDrafterModelType, isEmbeddingModelType, isSupportedModelRecord, isTranscriptionModelType } from "@mlx-bun/inference/models/support";
import { MODEL_LAYOUT, mlxBunHome, openModelRegistry } from "./home";

type CatalogRegistry = Pick<Registry, "list" | "listCanonical" | "resolve" | "scan" | "close">;

/** The Hub side a host may supply: what downloads a repo and what pushes a directory. Without them the catalog does neither. */
export interface CatalogHub {
  /** Fetches `id` into the hub cache; resolves to its snapshot directory. */
  download?(id: string, options: { signal?: AbortSignal; onProgress?: DownloadProgress }): Promise<string>;
  /** Whether a write token is available. */
  canPublish?(): boolean;
  publish?(directory: string, request: PublishRequest): Promise<{ url: string }>;
}

export interface RegistryCatalogOptions {
  /** A fresh handle per call, closed after it. Default: the index under MLX_BUN_HOME. */
  registry?: () => CatalogRegistry;
  /** The app's own model directory, searched when locating a picked folder. Default: `models/` under MLX_BUN_HOME. */
  modelsRoot?: () => string;
  hub?: CatalogHub;
}

/** What a model declares, from its `model_type`: consumers ask for these, never for a family. */
export function declaredOperations(modelType: string): ModelOperation[] {
  if (isTranscriptionModelType(modelType)) return ["transcribe"];
  if (isDrafterModelType(modelType)) return [];
  return [...(isSupportedModelRecord(modelType) ? ["generate" as const] : []), ...(isEmbeddingModelType(modelType) ? ["embed" as const] : [])];
}

const entryOf = (record: Pick<ModelRecord, "repoId" | "path" | "sizeBytes" | "modelType">): CatalogEntry =>
  ({ id: record.repoId, kind: "model", directory: record.path, bytes: record.sizeBytes, operations: declaredOperations(record.modelType), modelType: record.modelType });

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
  const hub = options.hub ?? {};
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
    locate: selection => locateFolder(selection, open, options.modelsRoot ?? (() => join(mlxBunHome(), MODEL_LAYOUT.models))),
    register: () => notSupported("register model outputs"),
    async download(id, downloadOptions = {}) {
      if (!hub.download) return notSupported("download models");
      const directory = await hub.download(id, downloadOptions);
      return withRegistry(async registry => {
        await registry.scan();
        const record = registry.listCanonical().find(item => item.path === directory || item.repoId === id);
        return record ? entryOf(record) : { id, kind: "model" as const, directory, bytes: 0, operations: [] };
      });
    },
    canPublish: () => hub.canPublish?.() ?? false,
    publish: (directory, request) => hub.publish ? hub.publish(directory, request) : notSupported("publish models"),
  };
}

const hasConfig = (directory: string): boolean => { try { return statSync(join(directory, "config.json")).isFile(); } catch { return false; } };
const repoIdOf = (folder: string) => folder.slice("models--".length).replaceAll("--", "/");

/** Where a folder an OS picker selected lives. The picker reveals only the folder's name and, from a file input, its
 * path inside it, so this rebuilds the location from what the app owns: the hub cache's layout, its own models
 * directory, and the index. */
async function locateFolder(selection: FolderSelection, open: () => CatalogRegistry, modelsRoot: () => string): Promise<LocatedFolder | undefined> {
  const hubRoot = hubCacheRoot(), models = modelsRoot();
  const folder = (selection.name ?? "").replace(/\\/g, "/").split("/").filter(Boolean).pop() ?? "";
  const relSegments = (selection.relPath ?? "").replace(/\\/g, "/").split("/").filter(Boolean);
  const configDir = relSegments.length >= 2 ? relSegments[relSegments.length - 2] : "";
  const pickSnapshot = (repoDir: string): string | null => {
    const snapshots = join(repoDir, "snapshots");
    let head = "";
    try { head = readFileSync(join(repoDir, "refs", "main"), "utf8").trim(); } catch { /* no ref */ }
    if (head && hasConfig(join(snapshots, head))) return join(snapshots, head);
    try { for (const hash of readdirSync(snapshots)) if (hasConfig(join(snapshots, hash))) return join(snapshots, hash); } catch { /* no snapshots */ }
    return null;
  };

  if (folder.startsWith("models--")) {
    const directory = pickSnapshot(join(hubRoot, folder));
    if (directory) return { directory, id: repoIdOf(folder) };
  }
  const hashDir = configDir || folder;
  if (hashDir) {
    try {
      for (const repo of readdirSync(hubRoot)) {
        if (!repo.startsWith("models--")) continue;
        const candidate = join(hubRoot, repo, "snapshots", hashDir);
        if (hasConfig(candidate)) return { directory: candidate, id: repoIdOf(repo) };
      }
    } catch { /* no hub cache */ }
  }
  if (folder && hasConfig(join(hubRoot, folder))) return { directory: join(hubRoot, folder) };
  // The app's own models are plain directories whose name is their id.
  if (folder && hasConfig(join(models, folder))) return { directory: join(models, folder), id: folder };

  const registry = open();
  try {
    await registry.scan();
    const all = registry.list();
    const record = (folder.startsWith("models--") ? all.find(model => model.repoId === repoIdOf(folder)) : undefined) ??
      all.find(model => model.path.split("/").pop() === hashDir) ?? all.find(model => model.repoId.split("/").pop() === folder);
    return record ? { directory: record.path, id: record.repoId, type: record.modelType } : undefined;
  } finally { registry.close(); }
}
