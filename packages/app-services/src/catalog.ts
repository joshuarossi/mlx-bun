// The local model catalog over the hub's registry: what is downloaded or
// produced here, and what each model declares it can do. Resolving reads the
// index; nothing downloads and nothing is registered by this host.
import { existsSync, readdirSync, readFileSync, realpathSync, statSync } from "node:fs";
import { join, resolve as resolvePath } from "node:path";
import type { CatalogEntry, CatalogFilter, CatalogKind, DownloadProgress, DownloadRow, EventBus, FolderSelection, LocatedFolder, ModelCatalog, ModelDetails, ModelOperation, PublishRequest } from "@mlx-bun/app-core";
import { downloadsSnapshot } from "@mlx-bun/hub/download";
import { audioCapable, hubCacheRoot, visionCapable, type ModelRecord, type Registry } from "@mlx-bun/hub/registry";
import { adapterWeightsFile, listAvailableAdapters } from "@mlx-bun/inference/adapters/available";
import { isDrafterModelType, isEmbeddingModelType, isSupportedModelRecord, isTranscriptionModelType, listedSupportTier } from "@mlx-bun/inference/models/support";
import { CatalogFailure } from "./failure";
import { MODEL_LAYOUT, mlxBunHome, openModelRegistry } from "./home";

type CatalogRegistry = Pick<Registry, "list" | "listCanonical" | "resolve" | "scan" | "close">;

/** The Hub side a host may supply: what downloads a repo and what pushes a directory. Without them the catalog does neither. */
export interface CatalogHub {
  /** Fetches `id` into the hub cache; resolves to its snapshot directory. */
  download?(id: string, options: { revision?: string; signal?: AbortSignal; onProgress?: DownloadProgress }): Promise<string>;
  /** Transfers that outlive their caller (the web's): `start` admits one at once and throws a `CatalogFailure` coded `duplicate-download` for a repo already running; `snapshot` is the rows to show. A host without them lists the hub library's own tracker. */
  transfers?: { start(id: string): void; snapshot(): readonly DownloadRow[] };
  /** The host's automatic model choice (`CatalogEntry`'s directory and id); without it the catalog makes none. */
  pickDefault?(signal?: AbortSignal): Promise<{ id: string; directory: string }>;
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
  /** The adapter stores `list({ kind: "adapter" })` reads, in order; a directory two stores reach is listed once. Default none. */
  adapterDirs?: () => readonly string[];
  /** Where `catalog.changed` is published after an index refresh or a download. */
  events?: Pick<EventBus, "publish">;
}

/** What a model declares, from its `model_type`: consumers ask for these, never for a family. */
export function declaredOperations(modelType: string): ModelOperation[] {
  if (isTranscriptionModelType(modelType)) return ["transcribe"];
  if (isDrafterModelType(modelType)) return [];
  return [...(isSupportedModelRecord(modelType) ? ["generate" as const] : []), ...(isEmbeddingModelType(modelType) ? ["embed" as const] : [])];
}

const snapshotOf = (path: string) => /\/snapshots\/([^/]+)\/?$/.exec(path)?.[1];

function detailsOf(record: ModelRecord, canonical?: boolean): ModelDetails {
  const revision = snapshotOf(record.path);
  return { parameters: record.paramCount ?? null, quantBits: record.quantBits ?? null, quantGroupSize: record.quantGroupSize ?? null, license: record.license ?? null,
    vision: visionCapable(record) === true, audio: audioCapable(record) === true, tools: !!record.hasToolTemplate, kvQuant: !!record.hasKvConfig,
    expertsBytes: record.expertsBytes ?? 0, sidecarBytes: record.sidecarBytes ?? 0, supportTier: listedSupportTier(record),
    ...(revision !== undefined ? { revision } : {}), ...(canonical !== undefined ? { canonical } : {}) };
}

const entryOf = (record: ModelRecord, canonical?: boolean): CatalogEntry =>
  ({ id: record.repoId, kind: "model", directory: record.path, bytes: record.sizeBytes, operations: declaredOperations(record.modelType), modelType: record.modelType,
    details: detailsOf(record, canonical) });

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
  const resolve = (id: string) => withRegistry(registry => registry.listCanonical().filter(record => record.repoId === id).map(record => entryOf(record))[0]);
  const hub = options.hub ?? {};
  const changed = () => options.events?.publish({ type: "catalog.changed", at: Date.now() });
  /** Adapter directories under the stores, one entry each, in store order. */
  const adapters = async (): Promise<CatalogEntry[]> => {
    const stores: string[] = [], seen = new Set<string>();
    for (const store of options.adapterDirs?.() ?? []) {
      let key = resolvePath(store);
      try { key = realpathSync(store); } catch { /* a missing store lists nothing */ }
      if (!seen.has(key)) { seen.add(key); stores.push(store); }
    }
    return (await listAvailableAdapters(stores)).map(adapter => {
      let bytes = 0;
      try { bytes = statSync(adapterWeightsFile(adapter.path)).size; } catch { /* listed without weights size */ }
      return { id: adapter.id, kind: "adapter" as const, directory: adapter.path, bytes, operations: [], ...(adapter.baseModel !== null ? { base: adapter.baseModel } : {}),
        adapter: { rank: adapter.rank, scale: adapter.scale } };
    });
  };
  return {
    async list(filter: CatalogFilter = {}) {
      if (filter.kind === ("adapter" satisfies CatalogKind)) return adapters();
      const match = { ...(filter.vision !== undefined ? { vision: filter.vision } : {}), ...(filter.maxBytes !== undefined ? { maxBytes: filter.maxBytes } : {}),
        ...(filter.query !== undefined ? { query: filter.query } : {}) };
      return withRegistry(async registry => {
        if (filter.refresh) await registry.scan();
        const kept = (record: ModelRecord) => filter.companions || !isDrafterModelType(record.modelType);
        const canonical = new Set(registry.listCanonical(match).map(record => record.path));
        const records = filter.revisions === "snapshots" ? registry.list(match) : registry.listCanonical(match);
        return records.filter(kept).map(record => entryOf(record, canonical.has(record.path)));
      });
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
    async rescan() {
      const registry = open();
      try { return await registry.scan(); } finally { registry.close(); changed(); }
    },
    async download(id, downloadOptions = {}) {
      if (!hub.download) return notSupported("download models");
      const directory = await hub.download(id, downloadOptions);
      return withRegistry(async registry => {
        await registry.scan();
        changed();
        const record = registry.listCanonical().find(item => item.path === directory || item.repoId === id);
        return record ? entryOf(record) : { id, kind: "model" as const, directory, bytes: 0, operations: [] };
      });
    },
    startDownload(id) {
      if (!hub.transfers) throw new CatalogFailure("not-supported", "this host does not download models");
      hub.transfers.start(id);
    },
    downloads: () => hub.transfers?.snapshot() ?? downloadsSnapshot(),
    async pickDefault(pickOptions = {}) {
      if (!hub.pickDefault) return notSupported("choose a default model");
      const { id, directory } = await hub.pickDefault(pickOptions.signal);
      return withRegistry(registry => {
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
