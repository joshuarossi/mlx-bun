import type { GraphCapabilities } from "../contracts/portable/graph";
import type { MlxDeclaredGraph } from "../contracts/mlx/graph";

type Declaration = Partial<Omit<GraphCapabilities, "adapters" | "kv" | "speculation">> & {
  readonly adapters?: Partial<GraphCapabilities["adapters"]>;
  readonly kv?: Partial<GraphCapabilities["kv"]>;
  readonly speculation?: Partial<GraphCapabilities["speculation"]>;
};

/** Build a graph's declaration from the defaults an ordinary autoregressive
 * graph has (batched and mountable adapters, verification qualified for every
 * request shape, no media, no paging, no compiled step, no delayed affine KV)
 * and what the graph does differently. */
export function declareGraph(declared: Declaration = {}): GraphCapabilities {
  return Object.freeze({
    method: "autoregressive", media: null, pagedAttention: false, compiledDecode: false,
    sparseAttention: false, embeddings: false, hiddenLayerTaps: false,
    ...declared,
    adapters: Object.freeze({ batched: true, mountable: true, ...declared.adapters }),
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
  const media = capabilities.media;
  if (media && media.input !== "pixels" && typeof graph.bindMediaInput !== "function")
    throw new TypeError(`the graph declares ${media.input} media input but provides no bindMediaInput`);
  if (media?.input === "pixels" && typeof graph.pixelInput !== "function")
    throw new TypeError("the graph declares pixel media input but provides no pixelInput");
  return graph as MlxDeclaredGraph;
}
