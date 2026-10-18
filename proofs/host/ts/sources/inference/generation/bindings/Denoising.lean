import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Bindings.Denoising
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/bindings/denoising.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { DenoisingGraph } from "../../contracts/portable/denoising";
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
  for (const operation of ["extendPrefill", "decoderLogits", "dequantEmbedWeight", "softEmbeddings"] as const)
    if (typeof model[operation] !== "function")
      throw new TypeError(`the graph declares the denoising method but provides no ${operation}`);
  if (!model.denoisingPrefill && typeof model.prefill !== "function")
    throw new TypeError("the graph declares the denoising method but provides no prefill");
  return {
    runtime: runtimeConfig(),
    memory: resident, adapters: resident.loraState,
    graph: {
      descriptor: Object.freeze({ id: "legacy-diffusion-gemma", backend: "mlx",
        graphAbi: "mlx-denoising-v1", stateAbi: "legacy-cache-array-v1", artifact: "legacy-resident-model" }),
      vocabSize: model.config.text.vocabSize, canvasLength: model.canvasLength, embedScale: model.embedScale,
      prefill: (ids, vision) => model.denoisingPrefill
        ? model.denoisingPrefill.find(range => ids.length >= range.from && ids.length <= range.to)!.operation(ids, vision ?? null)
        : vision ? model.prefillVision!(ids, vision) : model.prefill!(ids),
      extendPrefill: (tokens,state) => model.denoisingAppend
        ? model.denoisingAppend.find(range=>tokens.size>=range.from && tokens.size<=range.to)!.operation(tokens,state)
        : model.extendPrefill(tokens,state),
      decoderLogits: (canvas,state,feedback) => model.denoisingDecode
        ? model.denoisingDecode.find(range=>canvas.size>=range.from && canvas.size<=range.to)!.operation(canvas,state,feedback)
        : model.decoderLogits(canvas,state,feedback),
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Bindings.Denoising
