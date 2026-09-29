import { realpathSync } from "node:fs";
import { resolve } from "node:path";
import type { AvailableAdapter } from "@mlx-bun/inference/adapters";
import type { LoadedModelContext } from "../engine/model-host";
import type { GenerationGateway } from "../engine/generation-gateway";
import { legacyAdapterDirs, storagePath } from "../storage/paths";

/** The stores `GET /v1/adapters/available` lists: the app's adapter store,
 * where `train`, web fine-tunes, merges and memory stages write by default,
 * then the stores earlier versions wrote, read-only. Stores reaching the same
 * directory (a symlink) are listed once. */
export function adapterCatalogDirs(): string[] {
  const seen = new Set<string>();
  return [storagePath("adapters"), ...legacyAdapterDirs()].filter(dir => {
    let key = resolve(dir);
    try { key = realpathSync(dir); } catch { /* a missing store lists nothing */ }
    if (seen.has(key)) return false;
    seen.add(key); return true;
  });
}

/** HTTP owns presentation; the borrowed engine owns adapter tensors and locking. */
export function createAdapterRoutes(
  context: Pick<LoadedModelContext, "modelId" | "adapters">,
  gateway: Pick<GenerationGateway, "runExclusive">,
  catalog: () => Promise<AvailableAdapter[]> = async () => {
    const { listAvailableAdapters } = await import("@mlx-bun/inference/adapters");
    return listAvailableAdapters(adapterCatalogDirs());
  },
) {
  const error = (message: string, status = 400) => Response.json({ error: { message } }, { status });
  return { async handle(request: Request): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    const route = `${request.method} ${path}`;
    const remove = request.method === "DELETE" && path.startsWith("/v1/adapters/");
    if (!["GET /v1/adapters/available", "GET /v1/adapters", "POST /v1/adapters"].includes(route) && !remove) return null;
    try {
      request.signal.throwIfAborted();
      if (route === "GET /v1/adapters/available") {
        const available = await catalog();
        request.signal.throwIfAborted();
        const mounted = new Set(context.adapters.list().map(adapter => adapter.id));
        const bareName = (value: string) => value.split("/").pop()!.toLowerCase();
        return Response.json({ adapters: available.map(adapter => ({
          id: adapter.id, path: adapter.path, rank: adapter.rank, scale: adapter.scale,
          base_model: adapter.baseModel, mounted: mounted.has(adapter.id),
          compatible: adapter.baseModel == null || bareName(adapter.baseModel) === bareName(context.modelId),
        })) });
      }
      if (route === "GET /v1/adapters") return Response.json({ adapters: context.adapters.list().map(adapter => ({
        id: adapter.id, path: adapter.path, rank: adapter.rank, scale: adapter.scale,
        size_bytes: adapter.sizeBytes, mounted_layers: adapter.mountedLayers, ram_bytes: adapter.ramBytes,
      })) });
      if (remove) {
        const id = decodeURIComponent(path.slice("/v1/adapters/".length));
        if (!id) return error("adapter id required");
        const removed = await gateway.runExclusive(async () => context.adapters.unmount(id), undefined, request.signal);
        return removed > 0 ? Response.json({ id, removed_layers: removed }) : error(`adapter ${id} not mounted`, 404);
      }
      let body: unknown;
      try { body = await request.json(); } catch { request.signal.throwIfAborted(); return error("invalid JSON body"); }
      if (!body || typeof body !== "object" || Array.isArray(body)) return error("invalid JSON body");
      const { id, path: directory } = body as Record<string, unknown>;
      if (typeof id !== "string" || !id.trim() || typeof directory !== "string" || !directory.trim()) return error("id and path required");
      const info = await gateway.runExclusive(() => context.adapters.mount(id, directory), undefined, request.signal);
      return Response.json({ id: info.id, mounted_layers: info.mountedLayers, rank: info.rank, scale: info.scale, ram_bytes: info.ramBytes });
    } catch (failure) {
      if (request.signal.aborted) return error("Request cancelled", 499);
      return error(failure instanceof Error ? failure.message : "Adapter operation failed");
    }
  } };
}
