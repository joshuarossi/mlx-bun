import type { AutoregressiveGraph } from "../../contracts/portable/graph";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxCompiledDecodeStep, MlxModelMemory, MlxTokenAppend } from "../../contracts/mlx/graph";
import { compiledDecodeStepOf } from "../../models/capabilities";
import { runtimeConfig, type RuntimeConfig } from "../../runtime/config";
import { bindMlxGraph, type MlxTokenGraph } from "../../models/graph";
import type { PrefillPolicy } from "../../contracts/portable/prefill";
import { resolveMlxPrefillPolicy } from "./prefill-policy";
import type { KvSchemeOptions } from "../../state/kv-scheme";

export type { MlxModelMemory, MlxTokenAppend };

export interface MlxDecodeStep {
  /** Consume one pending token and advance state once. Returned arrays belong
   * to the caller. null permits ordinary graph execution and MUST leave state
   * unchanged. Errors propagate unless this implementation can roll back. */
  tryStep(token: MlxArray, state: Cache[]): { logits: MlxArray; evalWith: MlxArray[] } | null;
  /** Release per-run workspaces after pending outputs are dropped and before
   * cache disposal. Wait for native work if releasing requires completion. */
  close(): void | Promise<void>;
}

/** The model declares which codecs retain its committed-span arithmetic. */
export function supportsCommittedAppendCache(
  append: Pick<MlxTokenAppend, "affineKvBits" | "turboQuantFormats"> | null | undefined,
  options: Pick<KvSchemeOptions, "kvBits" | "kvConfig" | "turboQuant">,
): boolean {
  if (options.turboQuant) return !!append?.turboQuantFormats?.some(format =>
    format.kBits === options.turboQuant!.kBits && format.vBits === options.turboQuant!.vBits);
  return options.kvConfig?.length
    ? options.kvConfig.every(layer => append?.affineKvBits?.includes(layer.bits))
    : !options.kvBits || !!append?.affineKvBits?.includes(options.kvBits);
}

/** One replaceable binding owns all graph-specific operations used by the AR
 * loop. The current method requires MLX tensors and the legacy Cache[] ABI.
 * Weights are borrowed for the binding's lifetime; generated caches are owned
 * by the run. Caller-provided caches and media remain borrowed. */
export interface MlxAutoregressiveBinding {
  readonly runtime?: RuntimeConfig;
  readonly prefillPolicy?: PrefillPolicy;
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
  createAppend?(policy: { hasAdapters: boolean; pagedKv: boolean }): MlxTokenAppend | null;
}

/** Bind a resident graph to the autoregressive method: its forward, caches and
 * memory, and the compiled decode step it declares. Nothing here reads which
 * model the graph is. */
export function bindMlxAutoregressiveGraph(model: MlxTokenGraph): MlxAutoregressiveBinding {
  const runtime = runtimeConfig();
  return {
    runtime,
    prefillPolicy: resolveMlxPrefillPolicy(model, runtime),
    graph: bindMlxGraph<Cache[]>(model, {
      id: `legacy:${model.config.modelType}`, artifact: "legacy-resident-model",
      stateAbi: "legacy-cache-array-v1", // not a persistence identity
    }),
    eosTokenIds: model.config.eosTokenIds,
    memory: model,
    adapters: model.loraState,
    makeCache: model.makeCache.bind(model),
    forwardEmbeddings: model.forwardEmbeddings?.bind(model),
    createAppend: model.createAppend?.bind(model),
    createDecode(policy) {
      // Only a graph that declares a compiled step has one. Adapters would bake
      // residuals into the tape.
      if (!runtime.flag("MLX_BUN_COMPILED_DECODE", true) || policy.hasAdapters || policy.pagedKv) return null;
      let compiled: MlxCompiledDecodeStep | null = compiledDecodeStepOf(model);
      if (!compiled) return null;
      return {
        tryStep(token, state) {
          if (!compiled || !compiled.accepts(state)) return null;
          try { return compiled.step(token, state); }
          catch (error) {
            // A compiled step restores committed writes on failure, so retrying
            // this token through the ordinary graph is safe. Other decoders
            // must establish that guarantee themselves before returning null.
            compiled = null;
            console.warn(`compiled decode disabled for this generation: ${error}`);
            return null;
          }
        },
        // The graph owns the compiled closures; its unload releases them.
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
