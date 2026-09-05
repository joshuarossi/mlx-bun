import type { AutoregressiveGraph } from "../../inference/graph";
import type { MlxArray } from "../../mlx/array";
import type { Cache, Gemma4Model } from "../../model/gemma4";
import type { RuntimeModel } from "../../model/factory";
import { CompiledDecode } from "../../model/compiled-decode";
import { flagOn } from "../../runtime-config";
import { bindMlxGraph } from "./graph";

export interface MlxModelMemory {
  readonly weightsBytes: number;
  readonly expertRuntime?: {
    readonly plan: { readonly plannedBytes: number };
    flushUsage?: () => void;
    finishUsage?: () => Promise<void>;
  } | null;
}

export interface MlxDecodeStep {
  /** Consume one pending token and advance state once. Returned arrays belong
   * to the caller. null permits ordinary graph execution and MUST leave state
   * unchanged. Errors propagate unless this implementation can roll back. */
  tryStep(token: MlxArray, state: Cache[]): { logits: MlxArray; evalWith: MlxArray[] } | null;
  /** Release per-run workspaces after pending outputs are dropped and before
   * cache disposal. Wait for native work if releasing requires completion. */
  close(): void | Promise<void>;
}

/** One replaceable binding owns all graph-specific operations used by the AR
 * loop. The current method requires MLX tensors and the legacy Cache[] ABI.
 * Weights are borrowed for the binding's lifetime; generated caches are owned
 * by the run. Caller-provided caches and media remain borrowed. */
export interface MlxAutoregressiveBinding {
  readonly graph: AutoregressiveGraph<MlxArray, Cache[], MlxArray>;
  readonly eosTokenIds: readonly number[];
  readonly memory: MlxModelMemory;
  readonly adapters?: { active: string[] };
  makeCache(): Cache[];
  forwardEmbeddings?(
    embeddings: MlxArray, state: Cache[], imageMask: MlxArray | null,
    ids: MlxArray, multimodalMask: MlxArray | null,
  ): MlxArray;
  /** Called once after prefill. A compiled/fused decoder belongs to THIS graph,
   * never to a model inferred from a name or inherited by a replacement. */
  createDecode?(policy: { hasAdapters: boolean; pagedKv: boolean }): MlxDecodeStep | null;
}

/** Keep concrete model and compiled-decode decisions at the legacy boundary. */
export function bindLegacyAutoregressiveModel(model: RuntimeModel): MlxAutoregressiveBinding {
  return {
    graph: bindMlxGraph<Cache[]>(model, {
      id: `legacy:${model.config.modelType}`, artifact: "legacy-resident-model",
      stateAbi: "legacy-cache-array-v1", // not a persistence identity
    }),
    eosTokenIds: model.config.eosTokenIds,
    memory: model,
    adapters: model.loraState,
    makeCache: model.makeCache.bind(model),
    forwardEmbeddings: model.forwardEmbeddings?.bind(model),
    createDecode(policy) {
      // Preserve the existing Gemma path and exclusions. MoE shapeless replay
      // retraces growing windows; adapters would bake residuals into the tape.
      if (!flagOn("MLX_BUN_COMPILED_DECODE", true) || policy.hasAdapters || policy.pagedKv ||
          !model.config.modelType.startsWith("gemma4") || model.config.text.enableMoeBlock)
        return null;
      let compiled: CompiledDecode | null = CompiledDecode.for(model as Gemma4Model);
      return {
        tryStep(token, state) {
          if (!compiled || !CompiledDecode.supports(state)) return null;
          try { return compiled.step(token, state); }
          catch (error) {
            // CompiledDecode restores committed writes on failure, so retrying
            // this token through the ordinary graph is safe. Other decoders
            // must establish that guarantee themselves before returning null.
            compiled = null;
            console.warn(`compiled decode disabled for this generation: ${error}`);
            return null;
          }
        },
        // Compiled closures belong to the model's existing unload lifecycle.
        close() { compiled = null; },
      };
    },
  };
}

export function assertMlxAutoregressiveBinding(binding: MlxAutoregressiveBinding): void {
  const descriptor = binding.graph.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-hidden-bsh-v1" ||
      descriptor.stateAbi !== "legacy-cache-array-v1")
    throw new Error(`AR binding ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}
