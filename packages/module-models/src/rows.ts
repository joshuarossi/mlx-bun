// What a listing shows of a model on this machine: its fit, from the fit model over the model's own config.
import type { CatalogEntry } from "@mlx-bun/app-core";
import { loadModelConfig } from "@mlx-bun/inference/artifacts/config";
import { fit } from "@mlx-bun/inference/execution/fit";
import type { FitAssessment, HubLocalRow, LibraryRow } from "./protocol";

/** Fit at the context every listing assumes; null when the config is unreadable, which never hides a downloaded model. */
export async function assess(entry: CatalogEntry): Promise<FitAssessment | null> {
  try {
    const config = await loadModelConfig(entry.directory);
    const result = fit(config, entry.bytes, 8192, undefined, undefined, entry.details?.expertsBytes ?? 0);
    return { fits: result.fits, max_safe_context: result.maxSafeContext, predicted_decode_tps: result.predictedDecodeTps };
  } catch { return null; }
}

export async function hubLocalRow(entry: CatalogEntry): Promise<HubLocalRow> {
  const tier = entry.details?.supportTier ?? null;
  return { repo_id: entry.id, model_type: entry.modelType ?? "", size_bytes: entry.bytes,
    quant_bits: entry.details?.quantBits ?? null, quant_group_size: entry.details?.quantGroupSize ?? null,
    vision: entry.details?.vision ?? false, supported: tier !== null, support_tier: tier, assessment: await assess(entry) };
}

/** A library row before the host says what is running. */
export async function libraryRow(entry: CatalogEntry): Promise<Omit<LibraryRow, "serving" | "resident">> {
  const tier = entry.details?.supportTier ?? null;
  return { repo_id: entry.id, model_type: entry.modelType ?? "", size_bytes: entry.bytes, quant_bits: entry.details?.quantBits ?? null,
    vision: entry.details?.vision ?? false, audio: entry.details?.audio ?? false, supported: tier !== null, support_tier: tier, assessment: await assess(entry) };
}
