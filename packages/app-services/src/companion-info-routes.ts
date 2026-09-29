// Discovery for a server whose only model is a transcription checkpoint
// (`mlx-bun serve <whisper checkpoint>`, the transcription-only host): the
// four read-only surfaces beside the module's audio routes. No chat model, no
// prompt cache, no web app: the process idles at a few tens of MB with the
// weights paged out.
import type { ModelHost, ModelId } from "@mlx-bun/app-core";

export interface CompanionInfoOptions {
  /** The served checkpoint. */
  modelId: ModelId;
  models: Pick<ModelHost, "stats">;
  /** The transcription module's live counters (`requests`, `sessions`), by `LoadedModules.status`. */
  counters(): Readonly<Record<string, number | string | boolean | null>> | undefined;
  /** The `/v1` document's `name`, `version` and advertised endpoints (`METHOD /path`). */
  name: string;
  version: string;
  endpoints: readonly string[];
  startedAt?: number;
}

/** The `transcription` block of `/health` and `/stats`: residency counters then the module's. */
export function transcriptionStats(options: Pick<CompanionInfoOptions, "modelId" | "models" | "counters">) {
  const model = options.models.stats(options.modelId), counters = options.counters() ?? {};
  return { resident: model.resident, loads: model.loads, unloads: model.unloads, requests: Number(counters.requests ?? 0),
    last_load_ms: model.lastLoadMs, idle_unload_sec: model.idleUnloadSec };
}

export function createCompanionInfoRoutes(options: CompanionInfoOptions) {
  const startedAt = options.startedAt ?? Date.now();
  return { async handle(request: Request): Promise<Response | null> {
    if (request.method !== "GET") return null;
    const { pathname } = new URL(request.url);
    const stats = () => transcriptionStats(options);
    if (pathname === "/health")
      return Response.json({ status: "ok", transcription: { ...stats(), sessions: Number(options.counters()?.sessions ?? 0) } });
    if (pathname === "/stats")
      return Response.json({ model: options.modelId, transcription: stats(), uptime_s: (Date.now() - startedAt) / 1000 });
    if (pathname === "/v1")
      return Response.json({ name: options.name, version: options.version, model: options.modelId, mode: "transcription", endpoints: options.endpoints });
    if (pathname === "/v1/models" || pathname.startsWith("/v1/models/")) {
      const filterId = pathname.startsWith("/v1/models/") ? decodeURIComponent(pathname.slice("/v1/models/".length)) : null;
      const data = [{
        id: options.modelId, object: "model", created: Math.floor(startedAt / 1000), owned_by: "mlx-bun",
        transcription: true, resident: options.models.stats(options.modelId).resident,
        capabilities: { transcription: true, translation: true, chat_completions: false },
      }];
      return Response.json({ object: "list", data: filterId ? data.filter(model => model.id === filterId) : data });
    }
    return null;
  } };
}
