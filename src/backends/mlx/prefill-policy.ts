import type { ModelConfig } from "../../config";
import type { PrefillPolicy } from "../../inference/prefill";
import { sdpaFallbackBytes } from "../../kv-scheme";
import type { RuntimeConfig } from "../../runtime-config";

/** Retain large chunks for short prompts, but bound the materialized attention
 * score workspace of recurrent-attention models at long context. This changes
 * work size, never request admission. Explicit chunk settings remain exact. */
export function resolveMlxPrefillPolicy(config: ModelConfig, runtime: RuntimeConfig,
  override?: number): PrefillPolicy {
  const explicit = override ?? (runtime.value("MLX_BUN_RD_PREFILL_CHUNK") === undefined
    ? undefined : runtime.number("MLX_BUN_RD_PREFILL_CHUNK", 2048));
  if (explicit !== undefined) {
    const chunk = Math.max(1, Math.floor(explicit));
    return { chunkSize: () => chunk };
  }
  if (!config.text?.layerTypes?.includes("linear_attention")) return { chunkSize: () => 2048 };
  // Capture geometry now, independently of later configuration mutation.
  const geometry = { ...config, text: { ...config.text, layerTypes: [...config.text.layerTypes] } };
  const workspaceBytes = 1024 ** 3;
  return { chunkSize(promptTokens) {
    let chunk = 2048;
    while (chunk > 8 && sdpaFallbackBytes(geometry, chunk, promptTokens) > workspaceBytes) chunk /= 2;
    return chunk;
  } };
}
