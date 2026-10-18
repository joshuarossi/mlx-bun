import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Capabilities
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/capabilities.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { GraphCapabilities, GraphDeclaration } from "../contracts/portable/graph";
import type { MlxCompiledDecodeStep, MlxDeclaredGraph, MlxTokenPhases } from "../contracts/mlx/graph";
import type { Composition } from "../contracts/portable/composition";
import type { CacheCodecProvider } from "../state/persistence-types";

type Declaration = Partial<Omit<GraphDeclaration, "prefill" | "speculation">> & {
  readonly prefill?: Partial<GraphCapabilities["prefill"]>;
  readonly speculation?: Partial<GraphCapabilities["speculation"]>;
};

/** Build a graph's declaration from the defaults an ordinary autoregressive
 * graph has (batched and mountable adapters, verification qualified for every
 * request shape, no media, no compiled step, unbounded prefill chunks)
 * and what the graph does differently. */
export function declareGraph(declared: Declaration = {}): GraphDeclaration {
  if ("embeddings" in declared)
    throw new TypeError("pooled embedding support is declared by embedPooled, not an embeddings flag");
  return Object.freeze({
    method: "autoregressive", media: null, compiledDecode: false,
    sparseAttention: false, hiddenLayerTaps: false, nativeDraft: null,
    ...declared,
    prefill: Object.freeze({ boundedWorkspace: false, ...declared.prefill }),
    speculation: Object.freeze({ adapters: true, logprobs: true, externalTokens: true, grammarProposals: true,
      ...declared.speculation }),
  });
}

/** Verification qualified for ordinary rounds only: no adapters, logprobs,
 * supplied external tokens or verified grammar proposals (a graph whose
 * attention softcaps its scores). */
export const ORDINARY_VERIFICATION = Object.freeze({
  adapters: false, logprobs: false, externalTokens: false, grammarProposals: false,
});

/** A graph's declaration with the operations it promises, checked once where
 * composition binds it. A graph that declares nothing is refused, never read as
 * "no capabilities". */
export function declaredGraph(model: object): MlxDeclaredGraph {
  const graph = model as Partial<MlxDeclaredGraph>;
  const capabilities = graph.graphCapabilities;
  if (!capabilities) throw new TypeError("the graph must declare its capabilities (graphCapabilities)");
  if ("embeddings" in capabilities)
    throw new TypeError("pooled embedding support is declared by embedPooled, not an embeddings flag");
  if (graph.embedPooled !== undefined && typeof graph.embedPooled !== "function")
    throw new TypeError("the graph's embedPooled operation must be a function");
  const media = capabilities.media;
  if (media && media.input !== "pixels" && typeof graph.bindMediaInput !== "function")
    throw new TypeError(`the graph declares ${media.input} media input but provides no bindMediaInput`);
  if (media?.input === "pixels" && typeof graph.pixelInput !== "function")
    throw new TypeError("the graph declares pixel media input but provides no pixelInput");
  return graph as MlxDeclaredGraph;
}

/** Describe a validated graph for portable consumers. Operation presence is
 * the single source of pooled embedding support; retain the operation on the
 * graph so invocation preserves its receiver and resource ownership. */
export function graphCapabilitiesOf(graph: MlxDeclaredGraph): GraphCapabilities {
  return Object.freeze({ ...graph.graphCapabilities, embeddings: typeof graph.embedPooled === "function" });
}

/** The named token phases of a graph whose method is autoregressive, checked
 * once where composition binds it; null for a denoising graph, whose canvas
 * method runs none. An autoregressive graph without them is refused. */
export function tokenPhasesOf(model: object): MlxTokenPhases & { readonly composition?: Composition } | null {
  const graph = declaredGraph(model);
  if (graph.graphCapabilities.method !== "autoregressive") return null;
  const phases = model as Partial<MlxTokenPhases>;
  for (const name of ["prompt", "multiSequencePrompt", "decode", "verify", "appendKnown", "logits"] as const)
    if (!phases[name]) throw new TypeError(`the graph declares the autoregressive method but provides no ${name} phase`);
  return model as MlxTokenPhases & { readonly composition?: Composition };
}

/** The compiled decode step of a graph that declares one, created on first use
 * and kept by the graph; null for every other graph. A graph that promises a
 * step and provides none is refused where composition binds it. */
export function compiledDecodeStepOf(model: object): MlxCompiledDecodeStep | null {
  const graph = declaredGraph(model);
  if (!graph.graphCapabilities.compiledDecode) return null;
  if (typeof graph.compiledDecodeStep !== "function")
    throw new TypeError("the graph declares a compiled decode step but provides no compiledDecodeStep");
  return graph.compiledDecodeStep();
}

/** The persistence codecs a graph's caches need beyond the default set (the
 * graph's `stateCodecs`: GLM-5.2's under a quantized KV scheme or paging, whose
 * latent legos the default codecs do not save); undefined: the default set. */
export function stateCodecsOf(model: object): CacheCodecProvider | undefined {
  return (model as { readonly stateCodecs?: CacheCodecProvider }).stateCodecs;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Capabilities
