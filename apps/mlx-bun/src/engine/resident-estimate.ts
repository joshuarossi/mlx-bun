// What a model holds once it is resident, for residency decisions: its weights
// plus the KV cache and prefill working set of a typical serving context, from
// the same fit model `/fit` reports. Loading replaces the estimate with what the
// loaded model reports (its real weights bytes and the state it carries).
import type { ModelConfig } from "@mlx-bun/inference/artifacts/config";
import { fit, type MachineSpec } from "@mlx-bun/inference/execution/fit";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";

/** The context the estimate reserves KV for; longer contexts grow into the budget's headroom or evict others. */
export const SERVING_CONTEXT_TOKENS = 8192;

/** Bytes a model's KV and prefill working set take at the serving context. */
export function servingReserveBytes(config: ModelConfig, weightsBytes: number,
  options: { expertsBytes?: number; kvScheme?: KvSchemeOptions; machine?: MachineSpec } = {}): number {
  const context = Math.max(1, Math.min(SERVING_CONTEXT_TOKENS, config.text.maxPositionEmbeddings));
  const report = fit(config, weightsBytes, context, options.machine, undefined, options.expertsBytes ?? 0, undefined, options.kvScheme);
  const reserve = report.kvBytes + report.transientBytes;
  // A config the fit model cannot size adds nothing: residency then counts the weights alone.
  return Number.isFinite(reserve) && reserve > 0 ? reserve : 0;
}
