import { namespacedCache } from "../../engine/namespaced-cache";
import { runtimeFlag } from "../../runtime-config";
import type { GenerateOptions } from "../../generate";
import type { RuntimeModel } from "../../model/factory";
import { KVCache, type Cache } from "../../model/gemma4-base";
import { PagedKVCache } from "../../lab/paged-kv/paged-kv";
import type { RowPromptCache } from "./batch-group";
import { disposeResources } from "../../engine/resources";

/** Request state construction and reusable-prefix policy. Equal keys declare
 * compatible state layouts; the executor need not inspect their settings. */
export interface MlxRequestStatePolicy {
  readonly key: string;
  readonly promptCache?: RowPromptCache;
  create(): Cache[];
}

/** Replace fresh full-attention storage before prefill. Sliding layers retain
 * their layout; pre-warmed library caches retain their existing storage. */
export function maybePageKv(
  cache: Cache[], options: GenerateOptions, capacityTokens: number,
): void {
  if (!options.pagedKv) return;
  if (cache.some((c) => c.offset > 0)) return;
  const blockSize = options.pagedKv.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE;
  for (let i = 0; i < cache.length; i++) {
    if (cache[i] instanceof KVCache) {
      cache[i]!.dispose(); // fresh (offset 0) — nothing stored yet
      cache[i] = new PagedKVCache(capacityTokens, blockSize, undefined,
        options.kvBits === 4 || options.kvBits === 8 ? { bits: options.kvBits, groupSize: options.kvGroupSize ?? 64 } : undefined);
    }
  }
}

export function pagedPrefixNamespace(options: GenerateOptions, base: string): string {
  return JSON.stringify(["paged-v1", options.pagedKv?.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE,
    options.kvBits ?? 0, options.kvGroupSize ?? 64, runtimeFlag("MLX_BUN_PAGED_ATTN", false), base]);
}

export function bindPagedRequestState(model: RuntimeModel, options: GenerateOptions,
  capacityTokens: number, cache?: RowPromptCache): MlxRequestStatePolicy | undefined {
  if (!options.pagedKv) return undefined;
  const blockSize = options.pagedKv.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE;
  return { key: pagedPrefixNamespace(options, ""),
    promptCache: cache ? namespacedCache(cache, base => pagedPrefixNamespace(options, base)) : undefined, create() {
    const caches = model.makeCache();
    try { maybePageKv(caches, { ...options, pagedKv: { blockSize } }, capacityTokens); return caches; }
    catch (error) { disposeResources(caches); throw error; }
  } };
}
