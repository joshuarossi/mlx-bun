import { isUnservableDrafterModelType } from "./drafters";
import { familyOf, familyOfModelType } from "./families";
import type { ModelConfig } from "../artifacts/config";
import type { MoeDeclaration } from "./family";

/** Registry-level role of a `model_type` before any weights are read: a
 *  speech-to-text checkpoint, served by the transcription engine. */
export function isTranscriptionModelType(modelType: string): boolean {
  return familyOfModelType(modelType)?.transcribes === true;
}

/** Registry-level role of a `model_type` before any weights are read: its
 *  graph declares the pooled-embedding path (`embeddingDeclarationFor`). */
export function isEmbeddingModelType(modelType: string): boolean {
  return familyOfModelType(modelType)?.embedding !== undefined;
}

/** Speculative-decoding drafters (e.g. `gemma4_assistant`) are companion
 *  artifacts to a target model — Q-only, centroid-head, no standalone LM
 *  head. They are never servable/selectable on their own (the spec path
 *  loads them by explicit path), so they must be excluded from model
 *  resolution and the supported-model lists. See
 *  packages/inference/src/models/gemma4/assistant.ts. */
export function isDrafterModelType(modelType: string): boolean {
  return isUnservableDrafterModelType(modelType);
}

/** Support tier of a registry record's `model_type` (`02d723a:docs/design/generic-model-support.md`):
 *  "targeted" = dedicated/generated forward + L2/L3 paths;
 *  "generic"  = the Tier-0 universal module (L1 monolith only);
 *  null       = unsupported. Generic never shadows targeted. The type alone cannot
 *  tell a family that shares another's `model_type` (MiniCPM5 is `llama`); read
 *  the config for the exact family. */
export function supportTier(modelType: string): "targeted" | "generic" | null {
  if (isDrafterModelType(modelType)) return null;
  return familyOfModelType(modelType)?.tier ?? null;
}

export function isSupportedModelRecord(modelType: string): boolean {
  return supportTier(modelType) !== null;
}

/** Whether a family serves this config. A malformed config is unsupported, not a crash. */
export function isSupportedModelConfig(config: ModelConfig): boolean {
  if (isDrafterModelType(config.modelType)) return false;
  try {
    return familyOf(config) !== null;
  } catch {
    return false;
  }
}

/** The experts the config's family routes each token through; null for a dense,
 * unsupported or unreadable model (sizing estimates never throw). */
export function moeOf(config: ModelConfig): MoeDeclaration | null {
  try { return familyOf(config)?.moe?.(config) ?? null; } catch { return null; }
}
