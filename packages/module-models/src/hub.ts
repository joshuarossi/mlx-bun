// The hub routes: the downloaded models with their fit, Hugging Face search, downloads that outlive the request, and
// switching the served model. Search belongs to the request; downloads and the switch belong to the host's services.
import type { CatalogFailureCode, ModelCatalog, ModelHost, ResidencyFailure, RouteHandler } from "@mlx-bun/app-core";
import { hfToken } from "@mlx-bun/hub/download";
import { failure, jsonError, objectBody } from "./http";
import { hubLocalRow } from "./rows";

export interface HubOptions {
  /** The Hub token search sends; default the Hub library's own lookup. */
  token?: () => string | null;
  fetch?: typeof fetch;
  endpoint?: string;
}

const code = (error: unknown): string | undefined => error && typeof error === "object" && "code" in error && typeof error.code === "string" ? error.code : undefined;

export function createHubHandlers(services: { catalog: Pick<ModelCatalog, "list" | "startDownload">; modelHost: Pick<ModelHost, "serve"> },
  options: HubOptions = {}): Record<"hub-local" | "hub-search" | "hub-serve" | "hub-download", RouteHandler> {
  const { catalog, modelHost } = services;
  return {
    async "hub-local"(request) {
      try {
        request.signal.throwIfAborted();
        const models = [];
        for (const entry of await catalog.list({ companions: true, refresh: true })) {
          request.signal.throwIfAborted();
          models.push(await hubLocalRow(entry));
        }
        request.signal.throwIfAborted();
        return Response.json({ ok: true, models });
      } catch (error) { return failure(error, "GET /api/hub/local", request.signal); }
    },

    async "hub-download"(request) {
      try {
        request.signal.throwIfAborted();
        const body = await objectBody(request);
        const repo = typeof body?.repo === "string" ? body.repo.trim() : "";
        if (!repo) return jsonError('missing "repo"');
        // The id names cache directories and request paths; keep it to org/name.
        if (!/^[\w.-]+\/[\w.-]+$/.test(repo) || repo.split("/").some(part => part === "." || part === ".."))
          return jsonError('invalid "repo": expected org/name');
        try { catalog.startDownload(repo); }
        catch (error) {
          const failed = code(error) as CatalogFailureCode | undefined;
          if (failed === "duplicate-download") return jsonError((error as Error).message, 409);
          if (failed === "not-supported") return jsonError((error as Error).message, 404);
          throw error;
        }
        return Response.json({ ok: true, repo, started: true });
      } catch (error) { return failure(error, "POST /api/hub/download", request.signal); }
    },

    async "hub-serve"(request) {
      try {
        request.signal.throwIfAborted();
        const body = await objectBody(request);
        const model = typeof body?.model === "string" ? body.model.trim() : "";
        if (!model) return jsonError('missing "model"');
        try {
          await modelHost.serve(model, { signal: request.signal });
          return Response.json({ ok: true, model });
        } catch (error) {
          if (request.signal.aborted) throw error;
          const failed = code(error) as ResidencyFailure | undefined;
          if (failed === "not-switchable") return Response.json({ ok: false, restart_required: true, command: `mlx-bun serve ${model}` });
          if (failed === "not-found") return jsonError((error as Error).message, 404);
          if (failed) return jsonError((error as Error).message, failed === "load-failed" ? 502 : 400);
          throw error;
        }
      } catch (error) { return failure(error, "POST /api/hub/serve", request.signal); }
    },

    async "hub-search"(request) {
      try {
        request.signal.throwIfAborted();
        const query = new URL(request.url).searchParams.get("q")?.trim();
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
      } catch (error) { return failure(error, "GET /api/hub/search", request.signal); }
    },
  };
}
