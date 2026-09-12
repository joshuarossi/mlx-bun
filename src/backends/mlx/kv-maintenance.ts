import { runtimeConfig, withRuntimeConfig } from "../../runtime-config";
import type { KvSchemeOptions } from "../../kv-scheme";
import { KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache, TurboQuantKVCache, type Cache } from "../../model/gemma4-base";
import type { KvQuantSpec, TurboQuantScheme } from "../../config";
import * as ops from "../../mlx/ops";
import { clearCache } from "../../mlx/ffi";

import { DelayedRotatingQuantizedKVCache } from "../../model/delayed-rotating-quantized-kv";
import { DelayedQuantizedKVCache } from "../../model/delayed-quantized-kv";
import { DelayedTurboQuantKVCache } from "../../model/delayed-turboquant-kv";

export interface KvMaintenance {
  (cache: Cache[]): void;
  /** Bind state requiring row-local maintenance before shared decode. */
  prepareBatch?(cache: Cache[]): void;
  /** Bind all precision policies before a prefill cohort owns row boundaries. */
  preparePrefill?(cache: Cache[]): void;
}

const unchanged = (_cache: Cache[]): void => {};
let warnedTurboRotating = false;

/** Port of mlx-lm maybe_quantize_kv_cache + BOTH halves of optiq serve's
 *  per-layer patched variant (incl. patch_rotating_to_quantized: rotating
 *  caches convert too — Phase 9):
 *  - per-layer bits/group_size selection (kvConfig overrides kvBits,
 *    matching optiq's --kv-config precedence; shipped kv_config.json
 *    files cover EVERY cache-owning layer, sliding ones included —
 *    verified 12B 48/48, 26B 30/30, e4b 24/24 distinct caches — so
 *    rotating quantization engages straight from the config; uniform
 *    kvBits — like optiq --kv-bits — reaches them too), and
 *  - STREAMING conversion (optiq streaming_kv_quant / serve.py
 *    patched_maybe_quantize): eval each layer's quantized triples and
 *    clear the buffer pool before building the next layer's conversion.
 *    Lazily batching every layer's toQuantized into one eval pins ALL
 *    layers' bf16 K/V as graph inputs alongside ALL quantized outputs —
 *    the exact transient optiq's fix kills (16.35 → 7.60 GB at 32k on a
 *    24 GB Mac). Numerics untouched: same quantize math, only the eval
 *    ordering is forced (tests/parity/kv-quant.test.ts, tests/parity/rotating-kvq.test.ts). */
export function createKvMaintenance(options: Readonly<Omit<KvSchemeOptions, "kvConfig">> & {
  readonly kvConfig?: readonly Readonly<KvQuantSpec>[];
}): KvMaintenance {
  const { kvBits, kvConfig, turboQuant } = options;
  if (turboQuant) {
    const start = options.quantizedKvStart ?? 0;
    const scheme = { ...turboQuant };
    const runtime = runtimeConfig();
    const fusedDecode = runtime.value("MLX_BUN_TURBOQUANT_FUSED_DECODE") === "1";
    const maintain: KvMaintenance = (cache) => withRuntimeConfig(runtime, () => maybeTurboQuantizeKv(cache, scheme, start));
    maintain.preparePrefill = (cache) => {
      for (let layer = 0; layer < cache.length; layer++) {
        const row = cache[layer]!;
        if (row instanceof KVCache || row instanceof TurboQuantKVCache)
          cache[layer] = new DelayedTurboQuantKVCache(scheme.kBits, scheme.vBits, start, maintain, row, fusedDecode);
      }
    };
    if (start > 0) maintain.prepareBatch = maintain.preparePrefill;
    return maintain;
  }
  if (!kvBits && !kvConfig?.length) return unchanged;
  const start = options.quantizedKvStart ?? (kvConfig?.length ? 0 : 5000);
  const groupSize = options.kvGroupSize ?? 64;
  // Resolve layer policy once when composing execution, never per token.
  const byLayer = kvConfig?.length
    ? new Map(kvConfig.map((entry) => [entry.layerIdx, { ...entry }]))
    : null;
  const maintain: KvMaintenance = (cache) => {
    for (let i = 0; i < cache.length; i++) {
      const c = cache[i]!;
      const conversion = c.affineConversion ?? (c instanceof KVCache || c instanceof RotatingKVCache ? c : undefined);
      if (!conversion || conversion.offset < start || conversion.offset === 0) continue;
      const conversionOffset = conversion.offset;
      // The populated-cache boundary is part of oracle parity: quantizing an
      // empty cache would also quantize the first prefill.
      if (byLayer) {
        const entry = byLayer.get(i);
        if (!entry) continue;
        cache[i] = conversion.toQuantized(entry.groupSize, entry.bits);
      } else {
        cache[i] = conversion.toQuantized(groupSize, kvBits!);
      }
      if (start > 0) cache[i]!.minimumReusableOffset = conversionOffset;
      // Materialize one layer before converting the next to bound the live
      // bf16 source plus quantized destination to one conversion at a time.
      ops.evalAll(cache[i]!.state());
      clearCache();
    }
  };
  maintain.preparePrefill = (cache) => {
    for (let layer = 0; layer < cache.length; layer++) {
      const row = cache[layer]!;
      if (!(row instanceof KVCache || row instanceof QuantizedKVCache || row instanceof RotatingKVCache || row instanceof RotatingQuantizedKVCache)) continue;
      const spec = byLayer ? byLayer.get(layer) : { bits: kvBits!, groupSize };
      if (!spec) continue;
      const rowMaintenance = createKvMaintenance({ kvBits: spec.bits, kvGroupSize: spec.groupSize, quantizedKvStart: start });
      cache[layer] = row instanceof RotatingKVCache || row instanceof RotatingQuantizedKVCache
        ? new DelayedRotatingQuantizedKVCache(row.maxSize, spec.groupSize, spec.bits, start, rowMaintenance, row)
        : new DelayedQuantizedKVCache(spec.groupSize, spec.bits, start, rowMaintenance, row);
    }
  };
  if (start > 0) maintain.prepareBatch = maintain.preparePrefill;
  return maintain;
}

function maybeTurboQuantizeKv(cache: Cache[], scheme: TurboQuantScheme, start: number): void {
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (c instanceof RotatingKVCache) {
      if (!warnedTurboRotating) {
        warnedTurboRotating = true;
        console.warn(
          "[turbo-quant] sliding-window (RotatingKVCache) layers stay bf16 in v1 " +
          "(full-attention only) — docs/design/turboquant.md.",
        );
      }
      continue;
    }
    const conversion = c.turboConversion ?? (c instanceof KVCache ? c : undefined);
    if (!conversion || conversion.offset < start || conversion.offset === 0) continue;
    const conversionOffset = conversion.offset;
    const tq = c.turboConversion ? c.turboConversion.toTurboQuantized(scheme.kBits, scheme.vBits)
      : TurboQuantKVCache.fromKVCache(c as KVCache, scheme.kBits, scheme.vBits);
    if (start > 0) tq.minimumReusableOffset = conversionOffset;
    cache[i] = tq;
    // state() allocates fresh trimmed slice views for this cache kind
    // (see evalCacheState) — dispose after materializing (throw included),
    // or they leak.
    const state = tq.state();
    try {
      ops.evalAll(state);
    } finally {
      for (const a of state) a.dispose();
    }
    clearCache();
  }
}
