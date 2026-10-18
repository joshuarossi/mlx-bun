import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Bindings.AutoregressiveWhole
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/bindings/autoregressive.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { pagedDecodeCompiles } from "../../state/paged/cache";
import type { GraphDescriptor } from "../../contracts/portable/graph";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxCompiledDecodeStep, MlxKnownSpans, MlxModelMemory } from "../../contracts/mlx/graph";
import { compiledDecodeStepOf, tokenPhasesOf } from "../../models/capabilities";
import { runtimeConfig, type RuntimeConfig } from "../../runtime/config";
import type { MlxTokenGraph } from "../../models/graph";
import type { PrefillPolicy } from "../../contracts/portable/prefill";
import { resolveMlxPrefillPolicy } from "./prefill-policy";
import { COMPOSITION_DEFAULTS, type KvStorageScheme, type PagedKvComposition } from "../../contracts/portable/composition";
import { MlxPhaseDispatch } from "../phase-dispatch";

export type { MlxModelMemory };

export interface MlxDecodeStep {
  /** Consume one pending token and advance state once. Returned arrays belong
   * to the caller. A step that throws fails the generation. */
  step(token: MlxArray, state: Cache[]): { logits: MlxArray; evalWith: MlxArray[] };
  /** Release per-run workspaces after pending outputs are dropped and before
   * cache disposal. Wait for native work if releasing requires completion. */
  close(): void | Promise<void>;
}

/** One replaceable binding owns all graph-specific operations used by the AR
 * loop: the graph's named phases and the facts the loop reads once. The
 * current method requires MLX tensors and the legacy Cache[] ABI. Weights are
 * borrowed for the binding's lifetime; generated caches are owned by the run.
 * Caller-provided caches and media remain borrowed. */
export interface MlxAutoregressiveBinding {
  readonly runtime?: RuntimeConfig;
  readonly prefillPolicy?: PrefillPolicy;
  readonly descriptor: GraphDescriptor;
  /** The graph's phase operations. */
  readonly phases: MlxPhaseDispatch;
  readonly eosTokenIds: readonly number[];
  readonly memory: MlxModelMemory;
  readonly adapters?: { active: string[] };
  /** The composition's KV scheme, which `makeCache` composes; absent: bf16. */
  readonly kv?: KvStorageScheme;
  /** The composition's paging (`pagedKv`); absent: none. */
  readonly pagedKv?: PagedKvComposition | null;
  /** The composition's `prefillTailSplit`; absent: the default. */
  readonly prefillTailSplit?: boolean;
  /** The composition's `grammarJump`; absent: the default. */
  readonly grammarJump?: boolean;
  /** The graph's committed known-token spans, when it declares them. */
  readonly knownSpans?: MlxKnownSpans;
  makeCache(): Cache[];
  /** The vision prefill phase over prepared embeddings (borrowed). */
  prefillEmbeddings?(
    embeddings: MlxArray, state: Cache[], imageMask: MlxArray | null,
    ids: MlxArray, multimodalMask: MlxArray | null, width: number,
  ): MlxArray;
  /** The graph's compiled decode step for this run, chosen once after
   * prefill: present when the graph declares one, the run allows replay and
   * its composition kept compiled decode on. A compiled/fused decoder belongs to
   * THIS graph, never to a model inferred from a name or inherited by a
   * replacement. */
  createDecode?(policy: { hasAdapters: boolean }): MlxDecodeStep | null;
}

/** Bind a resident graph to the autoregressive method: its phases, caches and
 * memory, and the compiled decode step it declares. Nothing here reads which
 * model the graph is. */
export function bindMlxAutoregressiveGraph(model: MlxTokenGraph): MlxAutoregressiveBinding {
  const runtime = runtimeConfig();
  const facts = model.composition ?? COMPOSITION_DEFAULTS;
  const compiledOn = (!model.composition?.pagedKv || pagedDecodeCompiles(model.composition.pagedKv, model.composition.kv));
  return {
    runtime,
    prefillPolicy: resolveMlxPrefillPolicy(model, runtime),
    descriptor: Object.freeze({ id: `legacy:${model.config.modelType}`, artifact: "legacy-resident-model",
      stateAbi: "legacy-cache-array-v1", backend: "mlx", graphAbi: "mlx-hidden-bsh-v1" }),
    phases: new MlxPhaseDispatch(tokenPhasesOf(model)),
    eosTokenIds: model.config.eosTokenIds,
    memory: model,
    adapters: model.loraState,
    ...(model.composition ? { kv: model.composition.kv } : {}),
    pagedKv: facts.pagedKv ?? null, prefillTailSplit: facts.prefillTailSplit, grammarJump: facts.grammarJump,
    ...(model.knownSpans ? { knownSpans: model.knownSpans } : {}),
    makeCache: model.makeCache.bind(model),
    prefillEmbeddings: model.embeddingPrompt ? (embeddings, caches, imageMask, ids, multimodalMask, rows) =>
      model.embeddingPrompt!.find(range => rows >= range.from && rows <= range.to)!.operation(embeddings, caches, imageMask, ids, multimodalMask)
      : model.prefillEmbeddings?.bind(model),
    createDecode(policy) {
      // Only a graph that declares a compiled step has one, and only a
      // composition whose storage the step drives keeps it on. Adapters would
      // bake residuals into the tape.
      if (!compiledOn || policy.hasAdapters) return null;
      const compiled: MlxCompiledDecodeStep | null = compiledDecodeStepOf(model);
      if (!compiled) return null;
      // The graph owns the compiled closures; its unload releases them.
      return { step: (token, caches) => compiled.step(token, caches), close() {} };
    },
  };
}

export function assertMlxAutoregressiveBinding(binding: MlxAutoregressiveBinding): void {
  const descriptor = binding.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-hidden-bsh-v1" ||
      descriptor.stateAbi !== "legacy-cache-array-v1")
    throw new Error(`AR binding ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Bindings.AutoregressiveWhole
