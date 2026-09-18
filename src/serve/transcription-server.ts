// Whisper-only server: `mlx-bun serve <whisper checkpoint>` starts this
// instead of the chat server. Routes: the audio routes, /v1/models,
// /v1, /health, /stats. No chat machinery, no prompt cache — the process
// idles at a few tens of MB with the weights paged out (see
// TranscriptionService). This is the footprint sotto wants from a
// dictation backend.

import type { Server } from "bun";
import pkgJson from "../../package.json" with { type: "json" };
import { handleAudioRoute } from "./audio-routes";
import { TranscriptionService } from "./transcription-service";

const pkgVersion = (pkgJson as { version: string }).version;

export interface TranscriptionServerOptions {
  modelDir: string;
  modelId: string;
  port?: number;
  hostname?: string;
  unixSocket?: string;
  idleUnloadSec?: number;
  resident?: boolean;
  /** Load the weights before serving (default: on first request). */
  preload?: boolean;
}

export async function createTranscriptionServer(opts: TranscriptionServerOptions): Promise<{ server: Server<unknown>; service: TranscriptionService }> {
  const service = new TranscriptionService({
    modelDir: opts.modelDir, modelId: opts.modelId, idleUnloadSec: opts.idleUnloadSec, resident: opts.resident,
  });
  if (opts.preload) await service.ensureLoaded();
  const startedAt = Date.now();
  const server = Bun.serve({
    ...(opts.unixSocket
      ? ({ unix: opts.unixSocket } as unknown as Record<string, never>)
      : { port: opts.port ?? 0, ...(opts.hostname ? { hostname: opts.hostname } : {}) }),
    idleTimeout: 0,
    async fetch(request) {
      const url = new URL(request.url);
      const audio = await handleAudioRoute(url, request, { service: async () => service });
      if (audio) return audio;
      if (request.method === "GET" && url.pathname === "/health")
        return Response.json({ status: "ok", transcription: { ...service.stats, sessions: service.sessionCount } });
      if (request.method === "GET" && url.pathname === "/stats")
        return Response.json({ model: opts.modelId, transcription: service.stats, uptime_s: (Date.now() - startedAt) / 1000 });
      if (request.method === "GET" && url.pathname === "/v1")
        return Response.json({
          name: "mlx-bun", version: pkgVersion, model: opts.modelId, mode: "transcription",
          endpoints: ["POST /v1/audio/transcriptions", "POST /v1/audio/translations", "POST /v1/audio/sessions", "POST /v1/audio/sessions/:id/audio", "POST /v1/audio/sessions/:id/finish", "DELETE /v1/audio/sessions/:id", "POST /admin/transcription/unload", "GET /v1/models", "GET /health", "GET /stats"],
        });
      if (request.method === "GET" && (url.pathname === "/v1/models" || url.pathname.startsWith("/v1/models/")))
        return Response.json({
          object: "list",
          data: [{
            id: opts.modelId, object: "model", created: Math.floor(startedAt / 1000), owned_by: "mlx-bun",
            transcription: true, resident: service.resident,
            capabilities: { transcription: true, translation: true, chat_completions: false },
          }],
        });
      return Response.json({ error: { message: "not found" } }, { status: 404 });
    },
  });
  return { server, service };
}
