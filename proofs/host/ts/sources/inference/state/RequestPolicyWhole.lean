import host.ts.Source
namespace Host.Ts.Sources.Inference.State.RequestPolicyWhole
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/request-policy.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { KvStorageScheme, PagedKvComposition } from "../contracts/portable/composition";
import { type Cache } from "../contracts/mlx/cache";
import { PagedKVCache, type PagedQuantization, type PagedTurboQuant } from "./paged/cache";
import type { KVCache } from "./kv";
import { turboQuantFusedDecode } from "./turboquant-codec";
import { composedStorageOf, isPlainKvCache } from "./capabilities";

/** The affine pages the composition's KV scheme `kv` names for the layer at
 * cache index `layer`: every layer of a uniform scheme, the listed layers of a
 * per-layer one; none (bf16 or TurboQuant pages) otherwise. */
function pageQuantization(kv: KvStorageScheme, layer: number): PagedQuantization | undefined {
  if (kv.kind === "affine") return { bits: kv.bits, groupSize: kv.groupSize };
  if (kv.kind !== "affine-layers") return undefined;
  const entry = kv.layers.find(item => item.layer === layer);
  return entry ? { bits: entry.bits, groupSize: entry.groupSize } : undefined;
}

/** Replace fresh full-attention storage before prefill with pages storing what
 * the composition's scheme `kv` names for each layer (bf16, affine at the
 * layer's width, TurboQuant read with the layer's composed read), sized for
 * `capacityTokens` (the pool grows past it). Pages store their format from the
 * first position. Sliding layers retain their layout; pre-warmed caches retain
 * their existing storage. Nothing changes without paging. */
export function maybePageKv(cache: Cache[], kv: KvStorageScheme, paged: PagedKvComposition | null, capacityTokens: number): void {
  if (!paged) return;
  if (cache.some((c) => c.offset > 0)) return;
  for (let i = 0; i < cache.length; i++) {
    const storage = composedStorageOf(cache[i]!);
    if (!isPlainKvCache(storage)) continue;
    const turbo: PagedTurboQuant | undefined = kv.kind === "turbo" ? Object.freeze({ kBits: kv.kBits, vBits: kv.vBits,
      fusedDecode: turboQuantFusedDecode(), kernels: (storage as KVCache).turboQuantKernels }) : undefined;
    cache[i]!.dispose(); // fresh (offset 0) — nothing stored yet
    cache[i] = new PagedKVCache(capacityTokens, paged.blockSize, paged.direct, pageQuantization(kv, i), undefined, turbo);
  }
}

/** The prefix namespace of paged state over a method's namespace `base`: the
 * block size, what the pages store and their read (bf16 and uniform affine
 * pages keep the namespace they had before per-layer and TurboQuant pages
 * existed). */
export function pagedPrefixNamespace(kv: KvStorageScheme, paged: PagedKvComposition, base: string): string {
  const direct = paged.direct;
  if (kv.kind === "affine-layers")
    return JSON.stringify(["paged-v1", paged.blockSize, "layers", kv.layers.map(entry => [entry.layer, entry.bits, entry.groupSize]), direct, base]);
  if (kv.kind === "turbo") return JSON.stringify(["paged-v1", paged.blockSize, "turbo", kv.kBits, kv.vBits, direct, base]);
  const pages = pageQuantization(kv, 0);
  return JSON.stringify(["paged-v1", paged.blockSize, pages?.bits ?? 0, pages?.groupSize ?? 64, direct, base]);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.RequestPolicyWhole
