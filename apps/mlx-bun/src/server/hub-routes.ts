import { hfToken } from "@mlx-bun/hub/download";
import { fit } from "@mlx-bun/hub/fit";
import { Registry, visionCapable, type ModelRecord } from "@mlx-bun/hub/registry";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { supportTier } from "@mlx-bun/inference/models/support";
import { errorResponse } from "./http";

export interface HubRouteOptions {
  hubDirectory?: string;
  /** The handler owns and closes each registry returned by this factory. */
  createRegistry?: () => Pick<Registry, "scan" | "listCanonical" | "close">;
  token?: () => string | null;
  fetch?: typeof fetch;
  endpoint?: string;
}

async function localRow(model: ModelRecord) {
  const tier = supportTier(model.modelType, model.repoId);
  let assessment: { fits: boolean; max_safe_context: number; predicted_decode_tps: number } | null = null;
  try {
    const config = await loadModelConfig(model.path);
    const result = fit(config, model.sizeBytes, 8192, undefined, undefined, model.expertsBytes);
    assessment = { fits: result.fits, max_safe_context: result.maxSafeContext,
      predicted_decode_tps: result.predictedDecodeTps };
  } catch { /* An unreadable config must not hide a downloaded model. */ }
  return { repo_id: model.repoId, model_type: model.modelType, size_bytes: model.sizeBytes,
    quant_bits: model.quantBits, quant_group_size: model.quantGroupSize,
    vision: visionCapable(model), supported: tier !== null, support_tier: tier, assessment };
}

/** Web hub policy over public registry/fit APIs. Search belongs to the current
 * request; this owner starts no downloads and never replaces the loaded model. */
export function createHubRoutes(options: HubRouteOptions = {}) {
  const jsonError = (error: string, status = 400) => Response.json({ ok: false, error }, { status });
  return { async handle(request: Request): Promise<Response | null> {
    const url = new URL(request.url);
    const route = `${request.method} ${url.pathname}`;
    if (!["GET /api/hub/local", "GET /api/hub/search", "POST /api/hub/serve"].includes(route)) return null;
    try {
      request.signal.throwIfAborted();
      if (route === "GET /api/hub/local") {
        const registry = options.createRegistry?.() ?? new Registry();
        try {
          await registry.scan(options.hubDirectory);
          const models = [];
          for (const model of registry.listCanonical()) {
            request.signal.throwIfAborted();
            models.push(await localRow(model));
          }
          request.signal.throwIfAborted();
          return Response.json({ ok: true, models });
        } finally { registry.close(); }
      }
      if (route === "POST /api/hub/serve") {
        const body: unknown = await request.json().catch(() => undefined);
        const model = body && typeof body === "object" && !Array.isArray(body) && "model" in body ? body.model : undefined;
        if (typeof model !== "string" || !model.trim()) return jsonError('missing "model"');
        return Response.json({ ok: false, restart_required: true, command: `mlx-bun serve ${model.trim()}` });
      }
      const query = url.searchParams.get("q")?.trim();
      if (!query) return jsonError("missing ?q=");
      const token = (options.token ?? hfToken)();
      const searchUrl = `${options.endpoint ?? "https://huggingface.co"}/api/models?search=${encodeURIComponent(query)}` +
        "&filter=mlx&sort=downloads&direction=-1&limit=30";
      const offline = (error: string) => Response.json({ ok: true, offline: true, error, results: [] });
      let response: Response;
      try {
        response = await (options.fetch ?? fetch)(searchUrl, {
          headers: token ? { authorization: `Bearer ${token}` } : {},
          signal: AbortSignal.any([request.signal, AbortSignal.timeout(10_000)]),
        });
      } catch (error) {
        request.signal.throwIfAborted();
        return offline((error as Error).message);
      }
      if (!response.ok) {
        await response.body?.cancel();
        return offline(`HF search ${response.status}`);
      }
      let body: unknown;
      try { body = await response.json(); }
      catch (error) {
        request.signal.throwIfAborted();
        return offline(`HF search: bad response (${(error as Error).message})`);
      }
      request.signal.throwIfAborted();
      const rows = Array.isArray(body) ? body : [];
      const results = rows
        .filter((row): row is Record<string, unknown> => !!row && typeof row === "object" && !Array.isArray(row))
        .filter(row => !Array.isArray(row.tags) || row.tags.includes("mlx"))
        .map(row => ({ id: String(row.id ?? row.modelId ?? ""),
          downloads: typeof row.downloads === "number" ? row.downloads : 0,
          likes: typeof row.likes === "number" ? row.likes : 0, size_estimate: null }))
        .filter(row => row.id.length > 0);
      return Response.json({ ok: true, offline: false, results });
    } catch (error) {
      return errorResponse(error, route, (status, message) => jsonError(message, status), request.signal);
    }
  } };
}
