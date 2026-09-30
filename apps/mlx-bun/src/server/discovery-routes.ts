import type { Registry } from "@mlx-bun/hub/registry";
import { openRegistry } from "../storage/paths";
import type { ModelBinding } from "../engine/model-binding";
import pkgJson from "../../package.json" with { type: "json" };
import type { LoadedModelContext as ModelContext } from "../engine/model-host";

const pkgVersion = (pkgJson as { version: string }).version;

export type DiscoveryRoute =
  | "api-index"
  | "health"
  | "models";

export function matchDiscoveryRoute(method: string, pathname: string): DiscoveryRoute | null {
  if (method !== "GET") return null;
  switch (pathname) {
    case "/v1": return "api-index";
    case "/health": return "health";
    case "/v1/models": return "models";
    default: return pathname.startsWith("/v1/models/") ? "models" : null;
  }
}

export interface DiscoveryRoutes {
  handle(url: URL, request: Request): Promise<Response | null>;
}

export interface TranscriptionInfo {
  id: string;
  resident: boolean;
}

export function createDiscoveryRoutes(
  ctx: ModelContext,
  binding: Pick<ModelBinding, "discovery">,
  startedAt: number,
  transcription: () => Promise<TranscriptionInfo | null> = async () => null,
  createRegistry: () => Pick<Registry, "scan" | "listCanonical" | "close"> = () => openRegistry(),
  /** The server's own sampling defaults (`--temperature`, `--top-p`, `--top-k`): they win over the model's, as they do for a request that names none. */
  serverDefaults: { temperature?: number; topP?: number; topK?: number } = {},
): DiscoveryRoutes {
  return {
    async handle(url, request) {
      switch (matchDiscoveryRoute(request.method, url.pathname)) {
        case "api-index":
          return Response.json({
            name: "mlx-bun",
            version: pkgVersion,
            model: ctx.modelId,
            endpoints: [
              "POST /v1/chat/completions",
              "POST /v1/completions",
              "POST /v1/messages",
              "POST /v1/responses",
              "POST /v1/embeddings",
              "POST /v1/audio/transcriptions",
              "POST /v1/audio/translations",
              "GET /v1/models",
              "GET /health",
              "GET /stats",
              "GET /fit",
              "GET /library",
              "GET /downloads",
            ],
          });

        case "health":
          return new Response('{"status": "ok"}', {
            headers: { "content-type": "application/json" },
          });

        case "models": {
          const filterId = url.pathname.length > "/v1/models/".length - 1
            ? decodeURIComponent(url.pathname.slice("/v1/models/".length))
            : null;
          const created = Math.floor(startedAt / 1000);
          const genDefaults = {
            temperature: serverDefaults.temperature ?? ctx.genDefaults.temperature ?? null,
            top_p: serverDefaults.topP ?? ctx.genDefaults.topP ?? null,
            top_k: serverDefaults.topK ?? ctx.genDefaults.topK ?? null,
          };
          const capabilities = binding.discovery;
          const stt = await transcription();
          const data: Array<Record<string, unknown>> = [{
            id: ctx.modelId,
            object: "model",
            created,
            owned_by: "mlx-bun",
            context_window:
              ctx.memoryPlan?.contextTokens ??
              ctx.model.config.text.maxPositionEmbeddings,
            reasoning: ctx.template?.supportsThinking ?? false,
            vision: !!(ctx.vision || ctx.loadVision),
            audio: !!(ctx.audio || ctx.loadAudio),
            batch_mode: "batch",
            tools: true,
            structured_output: true,
            embeddings: capabilities.embeddings,
            adapters: capabilities.adapters,
            training: capabilities.training,
            dsa: capabilities.dsa,
            mtp: ctx.draft?.native === true,
            capabilities: {
              chat_completions: true,
              text_completions: true,
              anthropic_messages: true,
              responses: true,
              streaming: true,
              tools: true,
              structured_output: true,
              logprobs: true,
              embeddings: capabilities.embeddings,
              vision: !!(ctx.vision || ctx.loadVision),
              audio: !!(ctx.audio || ctx.loadAudio),
              adapters: capabilities.adapters,
              training: capabilities.training,
              transcription: stt !== null,
            },
            gen_defaults: genDefaults,
          }];
          if (stt)
            data.push({
              id: stt.id, object: "model", created, owned_by: "mlx-bun",
              transcription: true, resident: stt.resident,
              capabilities: { transcription: true, translation: true, chat_completions: false },
            });
          try {
            const { visionCapable } = await import("@mlx-bun/hub/registry");
            const { listedSupportTier } = await import("@mlx-bun/inference/models/support");
            const registry = createRegistry();
            try {
              if (registry.listCanonical().length === 0) await registry.scan();
              for (const model of registry.listCanonical()) {
                if (model.repoId === ctx.modelId || model.repoId === stt?.id) continue;
                const tier = listedSupportTier(model);
                if (tier === null) continue;
                data.push({
                  id: model.repoId,
                  object: "model",
                  created,
                  vision: visionCapable(model),
                  tier,
                });
              }
            } finally {
              registry.close();
            }
          } catch {}
          return Response.json({
            object: "list",
            data: filterId ? data.filter((model) => model.id === filterId) : data,
          });
        }

        default:
          return null;
      }
    },
  };
}
