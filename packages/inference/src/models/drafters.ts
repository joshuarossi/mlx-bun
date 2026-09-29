// Drafter models, as the layers above meet them. The conventions by which
// speculative-decoding artifacts and graphs declare themselves are pure string
// facts, so the model index, the hub and the draft provider registry read one
// definition without loading MLX. The loaders build a drafter on first use
// (each imports its implementation lazily) and hand it over as the port the
// draft sources consume (`contracts/mlx/drafter`); no source names a class.

import type { ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import type { AssistantDrafterModel, DeepspecDrafterModel, DsparkDrafterModel, NativeMtpHead, RecurrentMtpModule }
  from "../contracts/mlx/drafter";
import type { MlxDeclaredGraph } from "../contracts/mlx/graph";
import { isDeepspecArchitecture } from "./speculative/deepspec-artifact";

/** A DeepSpec drafter (DeepSeek's released DSpark checkpoints): a plain HF config stamped with its
 *  architecture. */
export function isDeepspecDrafterConfig(config: Record<string, unknown> | null): boolean {
  return isDeepspecArchitecture(config?.architectures);
}

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

/** The KV-borrowing assistant drafter in `dir`. */
export async function loadAssistantDrafter(dir: string): Promise<AssistantDrafterModel> {
  const { GemmaAssistantDrafter } = await import("./gemma4/assistant");
  return GemmaAssistantDrafter.load(dir);
}

/** A DeepSpec drafter in `dir`. */
export async function loadDeepspecDrafter(dir: string): Promise<DeepspecDrafterModel> {
  const { DeepspecDrafter } = await import("./speculative/deepspec");
  return DeepspecDrafter.load(dir);
}

/** Our trained DSpark drafter in `dir` (`dspark.json` beside the weights), dispatching on its variant. */
export async function loadDsparkDrafter(dir: string): Promise<DsparkDrafterModel> {
  const { loadDsparkDrafter: load } = await import("./speculative/loader");
  return load(dir);
}

/** The recurrent MTP block of a Qwen companion checkpoint. Its tensors belong to `weights`; the
 *  module's own views belong to `resources`. */
export async function loadQwenMtpModule(weights: Weights, config: ModelConfig,
  resources: DisposableStack): Promise<RecurrentMtpModule> {
  const { MtpModule } = await import("./qwen/mtp");
  return new MtpModule(weights, config, resources);
}

/** The native MTP head a graph declares (`nativeDraft`). Only a graph that provides its head binds. */
export function nativeMtpHeadOf(graph: object): NativeMtpHead {
  const head = (graph as Partial<MlxDeclaredGraph>).nativeDraftHead;
  if (typeof head !== "function")
    throw new Error("native GLM-5.2 MTP binds only to the GLM-5.2 graph that declares it");
  return head.call(graph);
}
