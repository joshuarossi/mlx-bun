// Transcription-only discovery (main's `src/serve/transcription-server.ts`):
// `mlx-bun serve <whisper checkpoint>` serves the audio routes plus these
// four read-only surfaces. No chat model, no prompt cache, no web app: the
// process idles at a few tens of MB with the weights paged out.

import pkgJson from "../../package.json" with { type: "json" };
import type { TranscriptionService } from "../engine/transcription-service";

const pkgVersion = (pkgJson as { version: string }).version;

export const TRANSCRIPTION_SERVER_ENDPOINTS = [
  "POST /v1/audio/transcriptions", "POST /v1/audio/translations", "POST /v1/audio/sessions",
  "POST /v1/audio/sessions/:id/audio", "POST /v1/audio/sessions/:id/finish", "DELETE /v1/audio/sessions/:id",
  "POST /admin/transcription/unload", "GET /v1/models", "GET /health", "GET /stats",
];

/** `/v1`, `/health`, `/stats`, and `/v1/models` for a server whose only model
 * is the Whisper checkpoint; the audio routes are mounted separately. */
export function createTranscriptionServerRoutes(
  service: Pick<TranscriptionService, "modelId" | "resident" | "stats" | "sessionCount">,
  options: { startedAt?: number } = {},
) {
  const startedAt = options.startedAt ?? Date.now();
  return { async handle(request: Request): Promise<Response | null> {
    if (request.method !== "GET") return null;
    const { pathname } = new URL(request.url);
    if (pathname === "/health")
      return Response.json({ status: "ok", transcription: { ...service.stats, sessions: service.sessionCount } });
    if (pathname === "/stats")
      return Response.json({ model: service.modelId, transcription: service.stats, uptime_s: (Date.now() - startedAt) / 1000 });
    if (pathname === "/v1")
      return Response.json({ name: "mlx-bun", version: pkgVersion, model: service.modelId, mode: "transcription",
        endpoints: TRANSCRIPTION_SERVER_ENDPOINTS });
    if (pathname === "/v1/models" || pathname.startsWith("/v1/models/")) {
      const filterId = pathname.startsWith("/v1/models/") ? decodeURIComponent(pathname.slice("/v1/models/".length)) : null;
      const data = [{
        id: service.modelId, object: "model", created: Math.floor(startedAt / 1000), owned_by: "mlx-bun",
        transcription: true, resident: service.resident,
        capabilities: { transcription: true, translation: true, chat_completions: false },
      }];
      return Response.json({ object: "list", data: filterId ? data.filter(model => model.id === filterId) : data });
    }
    return null;
  } };
}
