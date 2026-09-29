import type { GraphCapabilities } from "../contracts/portable/graph";
import type { MlxCompiledDecodeStep, MlxDeclaredGraph } from "../contracts/mlx/graph";

type Declaration = Partial<Omit<GraphCapabilities, "adapters" | "kv" | "prefill" | "speculation">> & {
  readonly adapters?: Partial<GraphCapabilities["adapters"]>;
  readonly prefill?: Partial<GraphCapabilities["prefill"]>;
  readonly kv?: Partial<GraphCapabilities["kv"]>;
  readonly speculation?: Partial<GraphCapabilities["speculation"]>;
};

/** Build a graph's declaration from the defaults an ordinary autoregressive
 * graph has (batched and mountable adapters, verification qualified for every
 * request shape, no media, no paging, no compiled step, no delayed affine KV, unbounded prefill chunks)
 * and what the graph does differently. */
export function declareGraph(declared: Declaration = {}): GraphCapabilities {
  return Object.freeze({
    method: "autoregressive", media: null, pagedAttention: false, compiledDecode: false,
    sparseAttention: false, embeddings: false, hiddenLayerTaps: false, nativeDraft: null,
    ...declared,
    adapters: Object.freeze({ batched: true, mountable: true, ...declared.adapters }),
    prefill: Object.freeze({ boundedWorkspace: false, ...declared.prefill }),
    kv: Object.freeze({ denseReads: false, delayedAffine: "none", ...declared.kv }),
    speculation: Object.freeze({ adapters: true, logprobs: true, affineKv: true, turboKv: true,
      immediateAffine4: false, externalTokens: true, grammarProposals: true, ...declared.speculation }),
  });
}

/** Verification qualified for plain KV rounds only: no adapters, logprobs,
 * TurboQuant, supplied external tokens or verified grammar proposals. */
export const PLAIN_KV_VERIFICATION = Object.freeze({
  adapters: false, logprobs: false, turboKv: false, externalTokens: false, grammarProposals: false,
});

/** A graph's declaration with the operations it promises, checked once where
 * composition binds it. A graph that declares nothing is refused, never read as
 * "no capabilities". */
export function declaredGraph(model: object): MlxDeclaredGraph & { readonly graphCapabilities: GraphCapabilities } {
  const graph = model as Partial<MlxDeclaredGraph>;
  const capabilities = graph.graphCapabilities;
  if (!capabilities) throw new TypeError("the graph must declare its capabilities (graphCapabilities)");
  if (capabilities.embeddings && typeof graph.embedPooled !== "function")
    throw new TypeError("the graph declares pooled embeddings but provides no embedPooled");
  if (capabilities.method === "denoising" && typeof graph.denoisingGraph !== "function")
    throw new TypeError("the graph declares the denoising method but provides no denoisingGraph");
  const media = capabilities.media;
  if (media && media.input !== "pixels" && typeof graph.bindMediaInput !== "function")
    throw new TypeError(`the graph declares ${media.input} media input but provides no bindMediaInput`);
  if (media?.input === "pixels" && typeof graph.pixelInput !== "function")
    throw new TypeError("the graph declares pixel media input but provides no pixelInput");
  return graph as MlxDeclaredGraph;
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
