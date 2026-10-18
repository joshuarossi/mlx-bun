import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Paged.Codec
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/paged/codec.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { CacheCodec } from "../persistence-types";
import type { KVCache } from "../kv";
import { turboQuantFusedDecode } from "../turboquant-codec";
import { BlockPool, PagedKVCache } from "./cache";

/** Page layout owns its persistence codec, independently of SSD transport.
 * Affine pages record their bit width and group size, TurboQuant pages their
 * key and value bit widths; a restored TurboQuant page reads with the read the
 * restoring graph composed into its cache (`LoadContext.prototype`). */
export const pagedCacheCodec: CacheCodec = {
    matches: cache => cache instanceof PagedKVCache,
    snapshot(cache, context) {
      const c = cache as PagedKVCache, p = c.pool!;
      for (const array of p.arrays()) context.push(array, false);
      return { kind: "paged", offset: c.offset, tensors: context.slots,
        ...(p.quantization ? p.quantization : {}),
        ...(p.turbo ? { kBits: p.turbo.kBits, vBits: p.turbo.vBits } : {}),
        paged: { capacityTokens: c.capacityTokens, blockSize: c.blockSize, blockTable: [...c.blockTable],
          numBlocks: p.numBlocks, headDim: p.headDim, vHeadDim: p.vHeadDim, dtype: p.dtype, direct: c.direct } };
    },
    clone: cache => (cache as PagedKVCache).clone(),
    load(entry, context) {
      const layout = entry.paged!;
      const quantization = entry.bits ? { bits: entry.bits, groupSize: entry.groupSize! } : undefined;
      const turbo = entry.kBits ? { kBits: entry.kBits, vBits: entry.vBits!, fusedDecode: turboQuantFusedDecode(),
        kernels: (context.prototype as PagedKVCache).turbo?.kernels ?? (context.prototype as KVCache).turboQuantKernels } : undefined;
      const cache = new PagedKVCache(layout.capacityTokens, layout.blockSize, layout.direct, quantization, undefined, turbo);
      const pool = new BlockPool({ ...layout, numKvHeads: entry.tensors[0]!.shape[1]!, quantization,
        ...(turbo ? { turbo: { kBits: turbo.kBits, vBits: turbo.vBits, fusedDecode: turbo.fusedDecode } } : {}) });
      try { pool.restoreArrays(entry.tensors.map(context.arr), layout.blockTable); }
      catch (error) { pool.dispose(); throw error; }
      cache.pool = pool; cache.offset = entry.offset; cache.blockTable = [...layout.blockTable];
      return cache;
    },
    headerTrimmable: () => true,
  };
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Paged.Codec
