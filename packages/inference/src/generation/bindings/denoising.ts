import type { DenoisingGraph } from "../../contracts/portable/denoising";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxModelMemory } from "./autoregressive";
import type { MlxTokenGraph } from "../../models/graph";
import { declaredGraph } from "../../models/capabilities";
import { runtimeConfig, type RuntimeConfig } from "../../runtime/config";

export interface MlxDenoisingBinding<State = Cache[]> {
  readonly runtime?: RuntimeConfig;
  readonly graph: DenoisingGraph<MlxArray, State>;
  readonly memory: MlxModelMemory;
  readonly adapters?: { active: string[] };
}

/** Only a graph that declares the denoising method binds here; it provides the graph itself. */
export function bindLegacyDenoisingModel(resident: MlxTokenGraph): MlxDenoisingBinding {
  const declared = declaredGraph(resident);
  if (declared.graphCapabilities.method !== "denoising")
    throw new TypeError("the graph does not declare the denoising method");
  return { runtime: runtimeConfig(), memory: resident, adapters: resident.loraState, graph: declared.denoisingGraph!() };
}

export function assertMlxDenoisingGraph<State>(graph: DenoisingGraph<MlxArray, State>): void {
  const descriptor = graph.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-denoising-v1" ||
      !descriptor.stateAbi)
    throw new Error(`denoising graph ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}
