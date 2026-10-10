// Drafter models as the layers above build them. Each loader imports its
// implementation on first use and hands the drafter over as the port the draft
// sources consume (`contracts/mlx/drafter`); no source names a class.

import type { ModelConfig } from "../artifacts/config";
import type { Weights } from "../artifacts/weights";
import type { AssistantDrafterModel, DeepspecDrafterModel, Dflash2DrafterModel, Dflash2TargetBasis, DsparkDrafterModel, NativeMtpHead, RecurrentMtpModule }
  from "../contracts/mlx/drafter";
import type { MlxDeclaredGraph } from "../contracts/mlx/graph";

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

/** A DFlash 2 drafter in `dir` (projections quantized to `bits`, 0 = BF16). */
export async function loadDflash2Drafter(dir: string,
  opts: { bits?: number; basis?: Dflash2TargetBasis | null } = {}): Promise<Dflash2DrafterModel> {
  const { Dflash2Drafter } = await import("./speculative/dflash2");
  return Dflash2Drafter.load(dir, opts);
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
