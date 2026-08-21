import type { KvQuantSpec, ModelConfig } from "../config";
import { kvBytesAt } from "../fit";

/** Project one batch row's worst-case KV bytes using the same per-layer
 * scheme that the server-wide admission ceiling uses. */
export function batchRowKvBytes(
  config: ModelConfig,
  promptTokens: number,
  maxTokens: number,
  kvConfig?: KvQuantSpec[],
): number {
  return kvBytesAt(
    config,
    promptTokens + maxTokens,
    kvConfig?.length ? { kvConfig } : undefined,
  );
}
