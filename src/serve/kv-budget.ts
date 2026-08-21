import type { KvQuantSpec, ModelConfig } from "../config";
import { KvScheme, resolveKvScheme } from "../kv-scheme";

/** Project one batch row's worst-case KV bytes using the same per-layer
 * scheme that the server-wide admission ceiling uses. */
export function batchRowKvBytes(
  config: ModelConfig,
  promptTokens: number,
  maxTokens: number,
  scheme?: KvScheme | KvQuantSpec[],
): number {
  const resolved = scheme instanceof KvScheme
    ? scheme
    : resolveKvScheme({ override: scheme?.length ? "config" : undefined, config: scheme });
  return resolved.bytesAt(config, promptTokens + maxTokens);
}
