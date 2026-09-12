import type { CacheCodec } from "../../kv-store";
import { BlockPool, PagedKVCache } from "../../lab/paged-kv/paged-kv";

/** Page layout owns its persistence codec, independently of SSD transport. */
export const pagedCacheCodec: CacheCodec = {
    matches: cache => cache instanceof PagedKVCache,
    snapshot(cache, context) {
      const c = cache as PagedKVCache, p = c.pool!;
      for (const array of p.arrays()) context.push(array, false);
      return { kind: "paged", offset: c.offset, tensors: context.slots,
        ...(p.quantization ? p.quantization : {}),
        paged: { capacityTokens: c.capacityTokens, blockSize: c.blockSize, blockTable: [...c.blockTable],
          numBlocks: p.numBlocks, headDim: p.headDim, vHeadDim: p.vHeadDim, dtype: p.dtype, direct: c.direct } };
    },
    clone: cache => (cache as PagedKVCache).clone(),
    load(entry, context) {
      const layout = entry.paged!;
      const quantization = entry.bits ? { bits: entry.bits as 4 | 8, groupSize: entry.groupSize! } : undefined;
      const cache = new PagedKVCache(layout.capacityTokens, layout.blockSize, layout.direct, quantization);
      const pool = new BlockPool({ ...layout, numKvHeads: entry.tensors[0]!.shape[1]!, quantization });
      try { pool.restoreArrays(entry.tensors.map(context.arr), layout.blockTable); }
      catch (error) { pool.dispose(); throw error; }
      cache.pool = pool; cache.offset = entry.offset; cache.blockTable = [...layout.blockTable];
      return cache;
    },
    headerTrimmable: () => true,
  };
