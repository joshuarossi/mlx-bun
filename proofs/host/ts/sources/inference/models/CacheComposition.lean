import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.CacheComposition
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/cache-composition.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { Cache } from "../contracts/mlx/cache";
import type { MlxCacheLayer } from "../contracts/mlx/graph";
import type { Composition } from "../contracts/portable/composition";
import { AttentionMasks, foldedWindowRead, sdpaRead } from "../state/attention-read";
import { Bf16FirstKv4Head256Cache, composedFullAttentionCache, composedSlidingAttentionCache } from "../state/bf16-first-kv";
import { composedAffineKernels } from "../state/affine-attention";
import { SSMCache } from "../state/ssm";
import { composedLatentCache, latentLegoCodecs } from "../state/latent-legos";
import { maybePageKv } from "../state/request-policy";
import { disposeResources } from "../runtime/resources";
import { denseTurboQuantKernels, deferredTurboQuantKernels } from "../state/turboquant-attention";

/** The loader composes a request's cache legos from the file's declaration. */
export function composeGraphCaches(graph: { readonly cacheLayers: readonly MlxCacheLayer[]; readonly cachePaging?: boolean },
  composition: {readonly kv: Composition["kv"]; readonly pagedKv: {readonly blockSize: number; readonly direct?: boolean} | null}): Cache[] {
  const masks = new AttentionMasks();
  const { kv, pagedKv } = composition;
  const caches = graph.cacheLayers.map((layer, index) => {
    switch (layer.kind) {
      case "recurrent": return new SSMCache();
      case "sliding": return composedSlidingAttentionCache(kv, index, layer.window, masks);
      case "latent": return composedLatentCache(kv, pagedKv, index, layer.geometry);
      case "full":
        if (layer.kv4Head256 && kv.kind === "affine" && kv.bits === 4 && kv.groupSize === 64)
          return new Bf16FirstKv4Head256Cache(kv.quantizedKvStart ?? 0, composedAffineKernels(kv.kernels), masks, layer.kv4DecodeBlock);
        return composedFullAttentionCache(kv, index, masks,
          layer.turboQuant === "deferred" ? deferredTurboQuantKernels : denseTurboQuantKernels,
          layer.windowRead === "folded" ? foldedWindowRead : sdpaRead);
    }
  });
  if (graph.cachePaging) {
    try { maybePageKv(caches, kv, pagedKv ? {...pagedKv,direct:pagedKv.direct??false} : null, pagedKv?.blockSize ?? 0); }
    catch (error) { disposeResources(caches); throw error; }
  }
  return caches;
}

/** Bind request-state construction at load; the graph only declares layout. */
export function bindGraphCaches<Graph extends { readonly cacheLayers: readonly MlxCacheLayer[]; readonly cachePaging?: boolean }>(graph: Graph,
  composition: {readonly kv: Composition["kv"]; readonly pagedKv: {readonly blockSize: number; readonly direct?: boolean} | null}): Graph & { makeCache(): Cache[]; readonly stateCodecs?: import("../state/persistence-types").CacheCodecProvider } {
  return Object.assign(graph, { makeCache: () => composeGraphCaches(graph, composition),
    ...(graph.cacheLayers.some(layer => layer.kind === "latent") && (composition.kv.kind !== "bf16" || composition.pagedKv)
      ? { stateCodecs: latentLegoCodecs } : {}) });
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.CacheComposition
