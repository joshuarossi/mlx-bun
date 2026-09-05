export interface PiModelOptions {
  name?: string;
  contextWindow?: number;
  maxTokens?: number;
  reasoning?: boolean;
  vision?: boolean;
}

/** Self-contained so the standalone Pi extension can embed the same builder. */
export function piModelDefinition(options: PiModelOptions = {}) {
  return {
    id: "local",
    name: options.name ?? "mlx-bun (local)",
    api: "openai-completions" as const,
    reasoning: options.reasoning ?? false,
    compat: { supportsDeveloperRole: false,
      ...(options.reasoning ? { thinkingFormat: "qwen-chat-template" as const } : {}) },
    input: (options.vision ? ["text", "image"] : ["text"]) as ("text" | "image")[],
    cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
    contextWindow: options.contextWindow ?? 32768,
    maxTokens: options.maxTokens ?? 8192,
  };
}

export const PI_PROVIDER_ID = "mlx-bun";
export const PI_API_KEY = "sk-mlx-bun-local";
export const PI_LOCAL_MODEL_ID = piModelDefinition().id;
export const PI_API = piModelDefinition().api;
export const DEFAULT_CONTEXT_WINDOW = piModelDefinition().contextWindow;
export const DEFAULT_MAX_TOKENS = piModelDefinition().maxTokens;
