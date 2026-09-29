import type { ModelConfig } from "../../artifacts/config";
import type { GraphCapabilities } from "../../contracts/portable/graph";
import { declaredGraph } from "../../models/capabilities";
import type { PrefillPolicy } from "../../contracts/portable/prefill";
import { sdpaFallbackBytes } from "../../state/kv-scheme";
import type { RuntimeConfig } from "../../runtime/config";

/** The graph facts prefill sizing reads: its geometry and its declaration. */
export interface PrefillSizedGraph {
  readonly config: ModelConfig;
  readonly graphCapabilities: GraphCapabilities;
}

/** Retain large chunks for short prompts, but where the graph declares a
 * bounded prefill workspace, bound the materialized attention score workspace
 * at long context. This changes work size, never request admission. Explicit
 * chunk settings remain exact. */
export function resolveMlxPrefillPolicy(graph: PrefillSizedGraph, runtime: RuntimeConfig,
  override?: number): PrefillPolicy {
  const explicit = override ?? (runtime.value("MLX_BUN_RD_PREFILL_CHUNK") === undefined
    ? undefined : runtime.number("MLX_BUN_RD_PREFILL_CHUNK", 2048));
  if (explicit !== undefined) {
    const chunk = Math.max(1, Math.floor(explicit));
    return { chunkSize: () => chunk };
  }
  if (!declaredGraph(graph).graphCapabilities.prefill.boundedWorkspace) return { chunkSize: () => 2048 };
  const config = graph.config;
  // Capture geometry now, independently of later configuration mutation.
  const geometry = { ...config, text: { ...config.text, layerTypes: [...config.text.layerTypes] } };
  const workspaceBytes = 1024 ** 3;
  return { chunkSize(promptTokens) {
    let chunk = 2048;
    while (chunk > 8 && sdpaFallbackBytes(geometry, chunk, promptTokens) > workspaceBytes) chunk /= 2;
    return chunk;
  } };
}
