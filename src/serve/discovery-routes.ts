import pkgJson from "../../package.json" with { type: "json" };
import type { ServerContext } from "./model-host";
import type { GenerationGateway } from "./generation-gateway";
import { fit } from "../fit";
import { isEmbeddingModel } from "../embed";
import { Glm52Model } from "../model/glm52";

const pkgVersion = (pkgJson as { version: string }).version;

export type DiscoveryRoute =
  | "library"
  | "downloads"
  | "api-index"
  | "health"
  | "models";

export function matchDiscoveryRoute(method: string, pathname: string): DiscoveryRoute | null {
  if (method !== "GET") return null;
  switch (pathname) {
    case "/library": return "library";
    case "/downloads": return "downloads";
    case "/v1": return "api-index";
    case "/health": return "health";
    case "/v1/models": return "models";
    default: return pathname.startsWith("/v1/models/") ? "models" : null;
  }
}

export interface DiscoveryRoutes {
  handle(url: URL, request: Request): Promise<Response | null>;
  invalidateLibrary(): void;
}

export function createDiscoveryRoutes(
  ctx: ServerContext,
  gateway: Pick<GenerationGateway, "batchMode">,
  startedAt: number,
): DiscoveryRoutes {
  let libraryCache: { at: number; rows: unknown[] } | null = null;

  return {
    invalidateLibrary() {
      libraryCache = null;
    },

    async handle(url, request) {
      switch (matchDiscoveryRoute(request.method, url.pathname)) {
        case "library": {
          if (!libraryCache || Date.now() - libraryCache.at > 30_000) {
            const { Registry, visionCapable, audioCapable } = await import("../registry");
            const { loadModelConfig } = await import("../config");
            const { supportTier } = await import("../model/support");
            const registry = new Registry();
            await registry.scan();
            const rows = [];
            for (const model of registry.listCanonical()) {
              const tier = supportTier(model.modelType, model.repoId);
              const supported = tier !== null;
              let assessment = null;
              try {
                const config = await loadModelConfig(model.path);
                const result = fit(
                  config,
                  model.sizeBytes,
                  8192,
                  undefined,
                  undefined,
                  model.expertsBytes,
                );
                assessment = {
                  fits: result.fits,
                  max_safe_context: result.maxSafeContext,
                  predicted_decode_tps: result.predictedDecodeTps,
                };
              } catch {}
              rows.push({
                repo_id: model.repoId,
                model_type: model.modelType,
                size_bytes: model.sizeBytes,
                quant_bits: model.quantBits,
                vision: visionCapable(model),
                audio: audioCapable(model),
                supported,
                support_tier: tier,
                serving: model.repoId === ctx.modelId,
                assessment,
              });
            }
            libraryCache = { at: Date.now(), rows };
          }
          return Response.json({ models: libraryCache.rows });
        }

        case "downloads": {
          const { downloadsSnapshot } = await import("../download");
          return Response.json({ downloads: downloadsSnapshot() });
        }

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
              "GET /v1/models",
              "GET/POST/DELETE /v1/adapters",
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
            temperature: ctx.genDefaults.temperature ?? null,
            top_p: ctx.genDefaults.topP ?? null,
            top_k: ctx.genDefaults.topK ?? null,
          };
          const isGlm52 = ctx.model instanceof Glm52Model;
          const data: Array<Record<string, unknown>> = [{
            id: ctx.modelId,
            object: "model",
            created,
            owned_by: "mlx-bun",
            context_window:
              ctx.glmMemoryPlan?.contextTokens ??
              ctx.model.config.text.maxPositionEmbeddings,
            reasoning: ctx.template.supportsThinking,
            vision: !!(ctx.vision || ctx.loadVision),
            audio: !!(ctx.audio || ctx.loadAudio),
            batch_mode: gateway.batchMode,
            tools: true,
            structured_output: true,
            embeddings: isEmbeddingModel(ctx.model),
            adapters: !isGlm52,
            training: !isGlm52,
            dsa: ctx.model instanceof Glm52Model && ctx.model.capabilities.dsa,
            mtp: ctx.draft?.provider.id === "glm52-native-mtp",
            capabilities: {
              chat_completions: true,
              text_completions: true,
              anthropic_messages: true,
              responses: true,
              streaming: true,
              tools: true,
              structured_output: true,
              logprobs: true,
              embeddings: isEmbeddingModel(ctx.model),
              vision: !!(ctx.vision || ctx.loadVision),
              audio: !!(ctx.audio || ctx.loadAudio),
              adapters: !isGlm52,
              training: !isGlm52,
            },
            gen_defaults: genDefaults,
          }];
          try {
            const { Registry, visionCapable } = await import("../registry");
            const { supportTier } = await import("../model/support");
            const registry = new Registry();
            try {
              if (registry.list().length === 0) await registry.scan();
              for (const model of registry.listCanonical()) {
                if (model.repoId === ctx.modelId) continue;
                const tier = supportTier(model.modelType, model.repoId);
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
