// What a model holds once it is resident, for residency decisions: its weights
// plus the KV cache and prefill working set of a typical serving context, from
// the same fit model `/fit` reports. Loading replaces the estimate with what the
// loaded model reports (its real weights bytes and the state it carries).
import { totalmem } from "node:os";
import type { ModelConfig } from "@mlx-bun/inference/artifacts/config";
import { fit, WIRED_FRACTION, type MachineSpec } from "@mlx-bun/inference/execution/fit";
import type { KvSchemeOptions } from "@mlx-bun/inference/state/kv-scheme";
import type { ModelRecord } from "@mlx-bun/hub/registry";

/** The context the estimate reserves KV for; longer contexts grow into the budget's headroom or evict others. */
export const SERVING_CONTEXT_TOKENS = 8192;

/** The share of the device working set all resident models may use together by default; the rest is headroom for
 * KV growth, prefill transients and the system. */
export const DEFAULT_BUDGET_FRACTION = 0.7;

/** The default residency budget, one rule for both compositions: a share of the device working set (Metal's recommended
 * maximum, which `cache-services` also plans against), or of the RAM the GPU may wire (`fit`'s rule) when the device does
 * not say. The in-process host reads the working set itself; an isolated host is told it by its first worker. */
export function defaultBudgetBytes(workingSetBytes?: number): number {
  const workingSet = workingSetBytes !== undefined && workingSetBytes > 0 ? workingSetBytes : totalmem() * WIRED_FRACTION;
  return Math.floor(workingSet * DEFAULT_BUDGET_FRACTION);
}

/** Bytes a model's KV and prefill working set take at the serving context. */
export function servingReserveBytes(config: ModelConfig, weightsBytes: number,
  options: { expertsBytes?: number; kvScheme?: KvSchemeOptions; machine?: MachineSpec } = {}): number {
  const context = Math.max(1, Math.min(SERVING_CONTEXT_TOKENS, config.text.maxPositionEmbeddings));
  const report = fit(config, weightsBytes, context, options.machine, undefined, options.expertsBytes ?? 0, undefined, options.kvScheme);
  const reserve = report.kvBytes + report.transientBytes;
  // A config the fit model cannot size adds nothing: residency then counts the weights alone.
  return Number.isFinite(reserve) && reserve > 0 ? reserve : 0;
}

/** What loading `record` would take: its weights and a typical context's KV and working set. A runtime that plans its
 * own memory is served alone, so it needs the whole budget. Reads the model's config only; loads nothing. */
export async function estimateRecordBytes(record: ModelRecord, input: {
  budgetBytes: number; machine?: MachineSpec;
  cache: { kvQuant?: "off" | "config" | number; turboQuant?: import("@mlx-bun/inference/artifacts/config").TurboQuantScheme; quantizedKvStart?: number };
}): Promise<number> {
  const [{ loadModelConfig }, { resolveModelProfile }, { plansMemory }, { resolveKvScheme }] = await Promise.all([
    import("@mlx-bun/inference/artifacts/config"), import("@mlx-bun/inference/models/profile"), import("@mlx-bun/inference/models/memory-plan"),
    import("@mlx-bun/inference/state/kv-scheme")]);
  const config = await loadModelConfig(record.path);
  if (plansMemory(resolveModelProfile(config))) return input.budgetBytes;
  const kvScheme = resolveKvScheme({ override: input.cache.kvQuant, turboQuant: input.cache.turboQuant,
    quantizedKvStart: input.cache.quantizedKvStart, config: config.kvQuant }).fitOptions;
  return record.sizeBytes + servingReserveBytes(config, record.sizeBytes, { expertsBytes: record.expertsBytes, kvScheme, ...(input.machine ? { machine: input.machine } : {}) });
}
