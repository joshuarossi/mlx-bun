import { homedir } from "node:os";
import { join } from "node:path";
import type { mergeAdapters } from "@mlx-bun/training/merge";
import type { exportAdapter } from "@mlx-bun/training/export";
import type { GenerationGateway } from "../engine/generation-gateway";

/** HTTP owns artifact request policy. Merge borrows the engine lock until the
 * library finishes cleanup; manifest export performs only filesystem I/O. */
export function createAdapterArtifactRoutes(
  gateway: Pick<GenerationGateway, "runExclusive">,
  options: { merge?: typeof mergeAdapters; export?: typeof exportAdapter; outputRoot?: string } = {},
) {
  const outputRoot = options.outputRoot ?? join(homedir(), ".cache/mlx-bun");
  const error = (message: string, status = 400) => Response.json({ ok: false, error: message }, { status });
  return { async handle(request: Request): Promise<Response | null> {
    const path = new URL(request.url).pathname;
    if (request.method !== "POST" || !["/api/finetune/merge", "/api/finetune/export"].includes(path)) return null;
    try {
      request.signal.throwIfAborted();
      const body: unknown = await request.json().catch(() => null);
      request.signal.throwIfAborted();
      if (!body || typeof body !== "object" || Array.isArray(body)) return error("expected a JSON object");
      const config = body as Record<string, unknown>;
      if (path.endsWith("/merge")) {
        const { adapter_a: a, adapter_b: b, scales } = config;
        if (typeof a !== "string" || !a.trim() || typeof b !== "string" || !b.trim())
          return error("adapter_a and adapter_b required");
        if (scales != null && (!Array.isArray(scales) || scales.length !== 2 || !scales.every(value => typeof value === "number" && Number.isFinite(value))))
          return error("scales must contain two finite numbers");
        const mergedPath = join(outputRoot, "adapters", `merged-${Date.now()}-${crypto.randomUUID()}`);
        const stats = await gateway.runExclusive(async () => {
          const merge = options.merge ?? (await import("@mlx-bun/training/merge")).mergeAdapters;
          request.signal.throwIfAborted();
          return merge([a, b], mergedPath, (scales ?? undefined) as number[] | undefined);
        }, undefined, request.signal);
        return Response.json({ ok: true, merged_path: mergedPath, stats });
      }
      const { base_model: base, adapter_path: adapter, method } = config;
      if (typeof base !== "string" || !base.trim() || typeof adapter !== "string" || !adapter.trim())
        return error("base_model and adapter_path required");
      if (method !== undefined && typeof method !== "string") return error("method must be a string");
      const exportPath = join(outputRoot, "exports", `export-${Date.now()}-${crypto.randomUUID()}`);
      const exportManifest = options.export ?? (await import("@mlx-bun/training/export")).exportAdapter;
      request.signal.throwIfAborted();
      const manifest = await exportManifest(exportPath, base, adapter, method as string | undefined);
      return Response.json({ ok: true, export_path: exportPath, manifest });
    } catch (failure) {
      if (request.signal.aborted) return error("Request cancelled", 499);
      return error(failure instanceof Error ? failure.message : String(failure));
    }
  } };
}
