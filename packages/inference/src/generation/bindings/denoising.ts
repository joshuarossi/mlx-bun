import type { DenoisingGraph } from "../../contracts/portable/denoising";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { DiffusionGemmaModel } from "../../models/diffusion-gemma/model";
import type { MlxModelMemory } from "./autoregressive";
import { disposeResources } from "../../runtime/resources";
import { runtimeConfig, type RuntimeConfig } from "../../runtime/config";

export interface MlxDenoisingBinding<State = Cache[]> {
  readonly runtime?: RuntimeConfig;
  readonly graph: DenoisingGraph<MlxArray, State>;
  readonly memory: MlxModelMemory;
  readonly adapters?: { active: string[] };
}

export function bindLegacyDenoisingModel(model: DiffusionGemmaModel): MlxDenoisingBinding {
  return {
    runtime: runtimeConfig(),
    memory: model, adapters: model.loraState,
    graph: {
      descriptor: Object.freeze({ id: "legacy-diffusion-gemma", backend: "mlx",
        graphAbi: "mlx-denoising-v1", stateAbi: "legacy-cache-array-v1", artifact: "legacy-resident-model" }),
      vocabSize: model.config.text.vocabSize, canvasLength: model.canvasLength, embedScale: model.embedScale,
      prefill: (ids, vision) => vision ? model.prefillVision(ids, vision) : model.prefill(ids),
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
