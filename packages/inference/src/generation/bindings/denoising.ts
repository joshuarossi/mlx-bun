import type { DenoisingGraph } from "../../contracts/portable/denoising";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxModelMemory } from "./autoregressive";
import type { MlxDeclaredGraph, MlxDenoisingOperations } from "../../contracts/mlx/graph";
import { declaredGraph } from "../../models/capabilities";
import { disposeResources } from "../../runtime/resources";
import { runtimeConfig, type RuntimeConfig } from "../../runtime/config";

export interface MlxDenoisingBinding<State = Cache[]> {
  readonly runtime?: RuntimeConfig;
  readonly graph: DenoisingGraph<MlxArray, State>;
  readonly memory: MlxModelMemory;
  readonly adapters?: { active: string[] };
}

/** A resident graph as the denoising binding takes it: its declaration, the denoising operations the
 * declared method promises, its weights for the wired-limit scope and its mounted adapters. */
export type MlxDenoisingModel = MlxDeclaredGraph & MlxModelMemory & Partial<MlxDenoisingOperations> &
  { readonly loraState?: { active: string[] } };

/** Only a graph that declares the denoising method binds here, and it must provide the operations. */
export function bindLegacyDenoisingModel(resident: MlxDenoisingModel): MlxDenoisingBinding {
  if (declaredGraph(resident).graphCapabilities.method !== "denoising")
    throw new TypeError("the graph does not declare the denoising method");
  const model = resident as MlxDenoisingOperations;
  for (const operation of ["prefill", "extendPrefill", "decoderLogits", "dequantEmbedWeight", "softEmbeddings"] as const)
    if (typeof model[operation] !== "function")
      throw new TypeError(`the graph declares the denoising method but provides no ${operation}`);
  return {
    runtime: runtimeConfig(),
    memory: resident, adapters: resident.loraState,
    graph: {
      descriptor: Object.freeze({ id: "legacy-diffusion-gemma", backend: "mlx",
        graphAbi: "mlx-denoising-v1", stateAbi: "legacy-cache-array-v1", artifact: "legacy-resident-model" }),
      vocabSize: model.config.text.vocabSize, canvasLength: model.canvasLength, embedScale: model.embedScale,
      prefill: (ids, vision) => vision ? model.prefillVision!(ids, vision) : model.prefill(ids),
      extendPrefill: model.extendPrefill.bind(model),
      decoderLogits: model.decoderLogits.bind(model),
      dequantEmbedWeight: model.dequantEmbedWeight.bind(model),
      softEmbeddings: model.softEmbeddings.bind(model),
      closeState: disposeResources,
    },
  };
}

export function assertMlxDenoisingGraph<State>(graph: DenoisingGraph<MlxArray, State>): void {
  const descriptor = graph.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-denoising-v1" ||
      !descriptor.stateAbi)
    throw new Error(`denoising graph ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}
