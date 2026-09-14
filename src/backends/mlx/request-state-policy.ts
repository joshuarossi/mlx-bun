import { namespacedCache } from "../../engine/namespaced-cache";
import { runtimeConfig, runtimeFlag, withRuntimeConfig, type RuntimeConfig } from "../../runtime-config";
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

export function pagedPrefixNamespace(options: GenerateOptions, base: string,
  direct = runtimeFlag("MLX_BUN_PAGED_ATTN", false)): string {
  return JSON.stringify(["paged-v1", options.pagedKv?.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE,
    options.kvBits ?? 0, options.kvGroupSize ?? 64, direct, base]);
}

export function bindPagedRequestState(model: RuntimeModel, options: GenerateOptions,
  capacityTokens: number, cache?: RowPromptCache, runtime: RuntimeConfig = runtimeConfig()): MlxRequestStatePolicy | undefined {
  if (!options.pagedKv) return undefined;
  const blockSize = options.pagedKv.blockSize ?? PagedKVCache.DEFAULT_BLOCK_SIZE;
  const stateOptions = { pagedKv: { blockSize }, kvBits: options.kvBits, kvGroupSize: options.kvGroupSize };
  const direct = runtime.flag("MLX_BUN_PAGED_ATTN", false);
  const namespace = (base: string) => pagedPrefixNamespace(stateOptions, base, direct);
  return { key: namespace(""),
    promptCache: cache ? namespacedCache(cache, namespace) : undefined, create: () => withRuntimeConfig(runtime, () => {
    const caches = model.makeCache();
    try { maybePageKv(caches, stateOptions, capacityTokens); return caches; }
    catch (error) { disposeResources(caches); throw error; }
  }) };
}
