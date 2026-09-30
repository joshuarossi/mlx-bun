// Adapters: what is on disk (the catalog's), what is mounted on the served model and mounting, unmounting and merging
// (the model's `adapters` operation, which runs under the model's execution lease in the process that holds the model,
// never in the host's), and writing an export manifest (file system only).
import { join } from "node:path";
import type { AdapterOperation, ModelCatalog, ModelHost, RouteHandler, StorageService } from "@mlx-bun/app-core";
import type { exportAdapter } from "@mlx-bun/training/export";
import { errorMessage, jsonError, objectBody, openAiError } from "./http";
import type { AvailableAdapterRow, MountedAdapterRow } from "./protocol";

export interface AdapterOptions {
  /** Test seam: the export writer. */
  export?: typeof exportAdapter;
}

type Ids = "adapters-available" | "adapters" | "adapter-mount" | "adapter-unmount" | "adapter-merge" | "adapter-export";

const bareName = (value: string) => value.split("/").pop()!.toLowerCase();
const isPair = (value: unknown): value is [number, number] => Array.isArray(value) && value.length === 2 && value.every(item => typeof item === "number" && Number.isFinite(item));

class NothingServed extends Error { constructor() { super("no model is loaded to mount adapters on"); this.name = "NothingServed"; } }

export function createAdapterHandlers(services: { catalog: Pick<ModelCatalog, "list">; modelHost: Pick<ModelHost, "defaultFor" | "acquire">; storage: StorageService },
  options: AdapterOptions = {}): Record<Ids, RouteHandler> {
  const { catalog, modelHost, storage } = services;
  /** Runs `use` on the served model's adapter operation, holding the model resident meanwhile. */
  async function onServed<T>(signal: AbortSignal, use: (adapters: AdapterOperation, modelId: string) => Promise<T>): Promise<T> {
    const id = await modelHost.defaultFor("generate");
    if (id === undefined) throw new NothingServed();
    const lease = await modelHost.acquire(id, { signal });
    try {
      const adapters = lease.operations.adapters;
      if (!adapters) throw new Error(`${id} does not mount adapters`);
      return await use(adapters, id);
    } finally { lease.release(); }
  }
  /** A model host that is closed, or a worker that is down, is unavailable (503); anything else is the operation's own refusal (400). */
  const unavailable = (error: unknown) => error instanceof NothingServed || (error as { code?: unknown } | null)?.code === "closed";
  /** The adapter routes answer OpenAI's envelope; a request that went away is a 499. */
  const adapterFailure = (error: unknown, signal: AbortSignal) =>
    signal.aborted ? openAiError("Request cancelled", 499) : unavailable(error) ? openAiError(errorMessage(error), 503) : openAiError(error instanceof Error ? error.message : "Adapter operation failed");
  const artifactFailure = (error: unknown, signal: AbortSignal) =>
    signal.aborted ? jsonError("Request cancelled", 499) : unavailable(error) ? jsonError(errorMessage(error), 503) : jsonError(errorMessage(error));

  return {
    async "adapters-available"(request) {
      try {
        request.signal.throwIfAborted();
        const available = await catalog.list({ kind: "adapter" });
        request.signal.throwIfAborted();
        return await onServed(request.signal, async (adapters, modelId) => {
          const mounted = new Set((await adapters.list(request.signal)).map(adapter => adapter.id));
          return Response.json({ adapters: available.map((adapter): AvailableAdapterRow => ({
            id: adapter.id, path: adapter.directory, rank: adapter.adapter?.rank ?? null, scale: adapter.adapter?.scale ?? 1,
            base_model: adapter.base ?? null, mounted: mounted.has(adapter.id),
            compatible: adapter.base == null || bareName(adapter.base) === bareName(modelId) })) });
        });
      } catch (error) { return adapterFailure(error, request.signal); }
    },

    async adapters(request) {
      try {
        request.signal.throwIfAborted();
        return await onServed(request.signal, async adapters => Response.json({ adapters: (await adapters.list(request.signal)).map((adapter): MountedAdapterRow => ({
          id: adapter.id, path: adapter.path, rank: adapter.rank, scale: adapter.scale, size_bytes: adapter.sizeBytes,
          mounted_layers: adapter.mountedLayers, ram_bytes: adapter.ramBytes })) }));
      } catch (error) { return adapterFailure(error, request.signal); }
    },

    async "adapter-mount"(request) {
      try {
        request.signal.throwIfAborted();
        const body = await objectBody(request);
        if (!body) { request.signal.throwIfAborted(); return openAiError("invalid JSON body"); }
        const { id, path: directory } = body;
        if (typeof id !== "string" || !id.trim() || typeof directory !== "string" || !directory.trim()) return openAiError("id and path required");
        const info = await onServed(request.signal, adapters => adapters.mount(id, directory, request.signal));
        return Response.json({ id: info.id, mounted_layers: info.mountedLayers, rank: info.rank, scale: info.scale, ram_bytes: info.ramBytes });
      } catch (error) { return adapterFailure(error, request.signal); }
    },

    async "adapter-unmount"(request) {
      try {
        request.signal.throwIfAborted();
        const id = decodeURIComponent(new URL(request.url).pathname.slice("/v1/adapters/".length));
        if (!id) return openAiError("adapter id required");
        const removed = await onServed(request.signal, adapters => adapters.unmount(id, request.signal));
        return removed > 0 ? Response.json({ id, removed_layers: removed }) : openAiError(`adapter ${id} not mounted`, 404);
      } catch (error) { return adapterFailure(error, request.signal); }
    },

    async "adapter-merge"(request) {
      try {
        request.signal.throwIfAborted();
        const body = await objectBody(request);
        request.signal.throwIfAborted();
        if (!body) return jsonError("expected a JSON object");
        const { adapter_a: a, adapter_b: b, scales } = body;
        if (typeof a !== "string" || !a.trim() || typeof b !== "string" || !b.trim()) return jsonError("adapter_a and adapter_b required");
        if (scales != null && !isPair(scales)) return jsonError("scales must contain two finite numbers");
        const mergedPath = join(storage.path("adapters"), `merged-${Date.now()}-${crypto.randomUUID()}`);
        const stats = await onServed(request.signal, adapters => adapters.merge({ adapters: [a, b], output: mergedPath, ...(scales ? { scales } : {}) }, request.signal));
        return Response.json({ ok: true, merged_path: mergedPath, stats });
      } catch (error) { return artifactFailure(error, request.signal); }
    },

    async "adapter-export"(request) {
      try {
        request.signal.throwIfAborted();
        const body = await objectBody(request);
        request.signal.throwIfAborted();
        if (!body) return jsonError("expected a JSON object");
        const { base_model: base, adapter_path: adapter, method } = body;
        if (typeof base !== "string" || !base.trim() || typeof adapter !== "string" || !adapter.trim()) return jsonError("base_model and adapter_path required");
        if (method !== undefined && typeof method !== "string") return jsonError("method must be a string");
        const exportPath = join(storage.path("exports"), `export-${Date.now()}-${crypto.randomUUID()}`);
        const write = options.export ?? (await import("@mlx-bun/training/export")).exportAdapter;
        request.signal.throwIfAborted();
        const manifest = await write(exportPath, base, adapter, method);
        return Response.json({ ok: true, export_path: exportPath, manifest });
      } catch (error) { return artifactFailure(error, request.signal); }
    },
  };
}
