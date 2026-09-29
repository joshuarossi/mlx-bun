export type DraftKind = "dspark" | "deepspec" | "assistant" | "two-model" | "ngram" | "mtp";

/** Detect the draft artifact's kind so the right provider is loaded. All
 *  providers share ONE serve loop (run.ts). This is the provider-side
 *  convention for what each artifact declares about itself; callers never
 *  inspect a draft's model type. Reads files only, never loads MLX.
 *  "ngram" is never detected — it has no artifact (model-free prompt lookup,
 *  sources/ngram-source.ts) and mounts via an explicit `--draft-kind ngram`. */
export async function detectDraftKind(dir: string): Promise<DraftKind> {
  if (await Bun.file(`${dir}/dspark.json`).exists()) return "dspark"; // our trained module
  try {
    const cfg = (await Bun.file(`${dir}/config.json`).json()) as {
      model_type?: string;
      architectures?: string[];
    };
    // DeepSeek's released DSpark drafters (DeepSpec reference): no
    // dspark.json, plain HF config stamped Gemma4DSparkModel.
    if (cfg.architectures?.[0] === "Gemma4DSparkModel") return "deepspec";
    if (String(cfg.model_type ?? "").includes("assistant")) return "assistant";
    // Native MTP heads split from a qwen3_5-family release
    // (mlx-community/Qwen3.8-27B-MTP-*): model_type "qwen3_5_mtp". The
    // target's recurrent DeltaNet caches roll back via the serve loop's
    // spec-round snapshot/replay contract (SSMCache.specRound*).
    if (String(cfg.model_type ?? "").endsWith("_mtp")) return "mtp";
  } catch {
    // no/unreadable config → fall through to a full second model
  }
  return "two-model";
}
