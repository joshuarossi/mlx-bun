import { AuthStorage, ModelRegistry } from "@earendil-works/pi-coding-agent";

export interface PiModelOptions {
  name?: string;
  contextWindow?: number;
  maxTokens?: number;
  reasoning?: boolean;
  vision?: boolean;
}

/** Capabilities advertised by the local model through Pi's OpenAI adapter. */
export function piModelDefinition(options: PiModelOptions = {}) {
  return {
    id: "local",
    name: options.name ?? "mlx-bun (local)",
    api: "openai-completions" as const,
    reasoning: options.reasoning ?? false,
    compat: { supportsDeveloperRole: false, sendSessionAffinityHeaders: true,
      ...(options.reasoning ? { thinkingFormat: "qwen-chat-template" as const } : {}) },
    input: (options.vision ? ["text", "image"] : ["text"]) as ("text" | "image")[],
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow: options.contextWindow ?? 32768,
    maxTokens: options.maxTokens ?? 100_000,
  };
}

export const PI_PROVIDER_ID = "mlx-bun";
export const PI_API_KEY = "sk-mlx-bun-local";
export const PI_LOCAL_MODEL_ID = piModelDefinition().id;
export const PI_API = piModelDefinition().api;
export const DEFAULT_CONTEXT_WINDOW = piModelDefinition().contextWindow;
export const DEFAULT_MAX_TOKENS = piModelDefinition().maxTokens;


/** A resolved pi model handle. Not re-exported from the package index, so we
 *  derive it from the registry's `find()` return type. */
export type PiModel = NonNullable<ReturnType<ModelRegistry["find"]>>;

export interface PiProviderOptions extends PiModelOptions {}

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
    models: [piModelDefinition(opts)],
  });

  const model = modelRegistry.find(PI_PROVIDER_ID, PI_LOCAL_MODEL_ID);
  if (!model) throw new Error("failed to register mlx-bun/local model");
  return { authStorage, modelRegistry, model };
}
