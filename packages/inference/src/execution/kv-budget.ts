import type { ModelConfig } from "../artifacts/config";
import { kvBytesAt, KvScheme } from "../state/kv-scheme";

/** Project one batch row's worst-case KV bytes using the same per-layer
 * scheme that the server-wide admission ceiling uses. */
export function batchRowKvBytes(
  config: ModelConfig,
  promptTokens: number,
  maxTokens: number,
  scheme?: KvScheme,
): number {
  const tokens = promptTokens + maxTokens;
  return scheme ? scheme.bytesAt(config, tokens) : kvBytesAt(config, tokens);
}
