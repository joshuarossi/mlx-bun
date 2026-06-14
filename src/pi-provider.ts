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
}

export interface PiProviderWiring {
  authStorage: AuthStorage;
  modelRegistry: ModelRegistry;
  model: PiModel;
}

/**
 * Build the in-memory auth + registry and resolve the local model for a pi
 * session pointed at `baseUrl` (e.g. "http://127.0.0.1:8090/v1"). The runtime
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
        reasoning: false,
        // Declare image capability so pi will carry image content to /v1.
        // Whether the *loaded* model can actually see images is gated at the
        // server (non-vision models 400) and surfaced to the web UI via the
        // `ready` frame's `vision` flag.
        input: ["text", "image"],
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
