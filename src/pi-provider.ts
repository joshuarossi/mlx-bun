// mlx-bun pi-provider — the in-memory pi provider/registry/auth wiring that
// points a pi AgentSession at the local mlx-bun server's loopback /v1.
//
// Shared by BOTH embed paths so the wiring can't drift:
//   - src/pi-web.ts      (headless web-chat session over a WebSocket)
//   - src/pi-terminal.ts (pi's own interactive TUI, in-process)
//
// The provider advertises a single, stable model id ("local"); the server
// runs exactly one model at a time and which one varies run-to-run, so a
// fixed id resolves to "whatever is loaded" and never goes stale. The real
// repo id rides in the model `name` and is still reported by /v1/models.
// This mirrors src/harness-pi.ts (the external-provider path).

import { AuthStorage, ModelRegistry } from "@earendil-works/pi-coding-agent";

/** A resolved pi model handle. Not re-exported from the package index, so we
 *  derive it from the registry's `find()` return type. */
export type PiModel = NonNullable<ReturnType<ModelRegistry["find"]>>;

// Provider/model constants — kept aligned with src/harness-pi.ts so every
// path (web embed, terminal embed, external pi) registers the same provider.
export const PI_PROVIDER_ID = "mlx-bun";
export const PI_LOCAL_MODEL_ID = "local";
export const PI_API_KEY = "sk-mlx-bun-local";
export const PI_API = "openai-completions" as const;

export const DEFAULT_CONTEXT_WINDOW = 32_768;
export const DEFAULT_MAX_TOKENS = 8_192;

export interface PiProviderOptions {
  /** Advertised context window. Default: DEFAULT_CONTEXT_WINDOW. */
  contextWindow?: number;
  /** Advertised max output tokens. Default: DEFAULT_MAX_TOKENS. */
  maxTokens?: number;
  /** Human-readable model label (e.g. the real repo id). Default: "mlx-bun (local)". */
  name?: string;
  /** The loaded model has a switchable reasoning channel (server's
   *  `ctx.template.supportsThinking` — true for any model whose chat template
   *  gates on enable_thinking: Qwen3.5, MiniCPM5, …). When true Pi engages
   *  reasoning and sends the on/off switch the server maps to enable_thinking.
   *  Default false. */
  reasoning?: boolean;
  /** The loaded model can accept images (server's `ctx.vision != null`).
   *  This MUST match the real model: pi-ai serializes user content as OpenAI
   *  multimodal content-parts (`[{type:"text",…}]`) for image-capable models
   *  and as a plain string otherwise. A text-only chat template renders nothing
   *  for a parts array, so declaring a non-vision model as image-capable makes
   *  the user's turn vanish ("I don't see any message"). Default false. */
  vision?: boolean;
}

export interface PiProviderWiring {
  authStorage: AuthStorage;
  modelRegistry: ModelRegistry;
  model: PiModel;
}

/**
 * Build the in-memory auth + registry and resolve the local model for a pi
 * session pointed at `baseUrl` (e.g. "http://127.0.0.1:8080/v1"). The runtime
 * key satisfies pi's auth check for our zero-cost local provider; no disk
 * (no models.json, no ~/.pi cross-talk).
 */
export function buildPiProvider(baseUrl: string, opts: PiProviderOptions = {}): PiProviderWiring {
  const authStorage = AuthStorage.inMemory();
  authStorage.setRuntimeApiKey(PI_PROVIDER_ID, PI_API_KEY);

  const modelRegistry = ModelRegistry.inMemory(authStorage);
  modelRegistry.registerProvider(PI_PROVIDER_ID, {
    baseUrl,
    apiKey: PI_API_KEY,
    api: PI_API,
    models: [
      {
        id: PI_LOCAL_MODEL_ID,
        name: opts.name ?? "mlx-bun (local)",
        api: PI_API,
        reasoning: opts.reasoning ?? false,
        // Compat flags that make pi emit the wire format our local server's
        // chat templates expect (docs/custom-provider.md "Model Definition
        // Reference"):
        //  - supportsDeveloperRole:false → pi sends the system prompt as the
        //    `system` role, not `developer` (our templates only know
        //    system/user/assistant/tool).
        //  - thinkingFormat:"qwen-chat-template" (reasoning models only) → pi
        //    sends chat_template_kwargs.enable_thinking, the boolean our
        //    Qwen3.5/MiniCPM5 templates gate on. pi computes the boolean from
        //    the selected thinking level (off → false), so no thinkingLevelMap.
        compat: {
          supportsDeveloperRole: false,
          ...(opts.reasoning ? { thinkingFormat: "qwen-chat-template" as const } : {}),
        },
        // input MUST match the loaded model. pi-ai serializes user content as a
        // plain string for text-only models and as OpenAI content-parts
        // (`[{type:"text",…}]`) once a model declares image input — and a
        // text-only chat template renders NOTHING for a parts array, dropping
        // the user's turn ("I don't see any message"). So declare image input
        // only for an actual vision model; the web `ready` frame's `vision`
        // flag is the same signal that drives the UI's image affordance.
        input: opts.vision ? ["text", "image"] : ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: opts.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
        maxTokens: opts.maxTokens ?? DEFAULT_MAX_TOKENS,
      },
    ],
  });

  const model = modelRegistry.find(PI_PROVIDER_ID, PI_LOCAL_MODEL_ID);
  if (!model) throw new Error("failed to register mlx-bun/local model");
  return { authStorage, modelRegistry, model };
}
