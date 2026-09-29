// Conventions by which speculative-decoding artifacts and graphs declare
// themselves. Pure string facts, so the model index, the hub and the draft
// provider registry all read one definition without loading MLX.

/** A drafter whose weights are Q-only and have no standalone LM head
 *  (`gemma4_assistant`, `gemma4_unified_assistant`). */
export function isAssistantModelType(modelType: string): boolean {
  return modelType.includes("assistant");
}

/** A multi-token-prediction head split from a qwen3_5-family release
 *  (`qwen3_5_mtp`). */
export function isMtpModelType(modelType: string): boolean {
  return modelType.endsWith("_mtp");
}

/** Drafters with no standalone graph: never servable or selectable as a model. */
export function isUnservableDrafterModelType(modelType: string): boolean {
  return isAssistantModelType(modelType);
}

/** The `GraphCapabilities.nativeDraft` kind of a graph whose checkpoint carries
 *  its own multi-token-prediction row. */
export const NATIVE_MTP_DRAFT = "checkpoint-mtp";
