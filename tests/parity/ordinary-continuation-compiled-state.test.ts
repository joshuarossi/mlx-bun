import { expect, test } from "bun:test";
import { Weights } from "../../src/weights";
import { loadModelConfig } from "../../src/config";
import { Gemma4Model } from "../../src/model/gemma4";
import { loadTokenizer } from "../../src/tokenizer";
import { CompiledDecode } from "../../src/model/compiled-decode";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { leaseCacheState } from "../../src/backends/mlx/state-views";
import { cloneKvCaches } from "../../src/kv-store";
import * as ops from "../../src/mlx/ops";
import { Dtype, clearCache } from "../../src/mlx/ffi";
import type { Cache } from "../../src/model/gemma4-base";

import { existsSync, readFileSync } from "node:fs";
const target = Bun.env.MLX_BUN_TEST_CONTINUATION_MODEL ?? `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/98d7dc6a93ae05583e8a10018c8099459b58aeeb`;
const enabled = Bun.env.MLX_BUN_TEST_ORDINARY_CONTINUATION === "1" && existsSync(`${target}/config.json`) &&
  JSON.parse(readFileSync(`${target}/config.json`, "utf8")).model_type === "gemma4";

test.skipIf(!enabled)("fresh compiled model preserves forced-token logits and active state through delayed conversion", async () => {
  const weights = await Weights.open(target), config = await loadModelConfig(target);
  const warm = new Gemma4Model(weights, config), fresh = new Gemma4Model(weights, config);
  const prompt = (await loadTokenizer(target)).encode("Count upwards, continuing the sequence: 1, 2, 3,");
  const retraces = CompiledDecode.unexpectedRetraces;
  const cache = warm.makeCache();
  let restored: Cache[] | undefined;
  const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: prompt.length + 6 });
  const hash = (array: import("../../src/mlx/array").MlxArray) => {
    using contiguous = ops.contiguous(array);
    return new Bun.CryptoHasher("sha256").update(contiguous.rawBytes()).digest("hex");
  };
  const state = (rows: Cache[]) => rows.map(cache => {
    const lease = leaseCacheState(cache);
    try {
      return { offset: cache.offset, signature: cache.signature(), minimumReusableOffset: cache.minimumReusableOffset ?? 0,
        planes: lease.borrow().map(array => {
          // Full-cache capacity is an allocation detail; compare every active
          // byte. Rotating caches retain their complete physical ring.
          const full = cache.signature() === "kv:plain" || cache.signature().startsWith("kv:quant:");
          using view = full
            ? array.slice([0, 0, 0, 0], [array.shape[0]!, array.shape[1]!, cache.offset, array.shape[3]!])
            : array.slice(array.shape.map(() => 0), array.shape);
          return { shape: view.shape, dtype: view.dtype, hash: hash(view) };
        }) };
    } finally { lease.close(); }
  });
  try {
    // Only warm gets a prefill. Fresh enters compiled execution directly from
    // cloned state, reproducing a model loaded for checkpoint restoration.
    for (const chunk of [prompt.slice(0, -1), prompt.slice(-1)]) {
      using ids = ops.fromInt32(chunk, [1, chunk.length]);
      using hidden = warm.forwardHidden(ids, cache);
      ops.evalAll([hidden]); maintain(cache);
    }
    const tokens = [236743, 236812, 236764, 236743, 236810, 236764, 236743, 236800, 236764, 236743];
    for (let step = 0; step < tokens.length; step++) {
      if (step === 4) restored = cloneKvCaches(cache);
      maintain(cache); if (restored) maintain(restored);
      using signed = ops.fromInt32([tokens[step]!], [1]);
      using token = signed.astype(Dtype.uint32);
      const original = CompiledDecode.for(warm).step(token, cache);
      using originalLogits = original.logits;
      ops.evalAll([originalLogits, ...original.evalWith]);
      if (restored) {
        const resumed = CompiledDecode.for(fresh).step(token, restored);
        using resumedLogits = resumed.logits;
        ops.evalAll([resumedLogits, ...resumed.evalWith]);
        expect(hash(resumedLogits)).toBe(hash(originalLogits));
        expect(state(restored)).toEqual(state(cache));
      }
    }
    expect(CompiledDecode.unexpectedRetraces).toBe(retraces);
  } finally {
    cache.forEach(cache => cache.dispose()); restored?.forEach(cache => cache.dispose());
    CompiledDecode.for(warm).dispose(); CompiledDecode.for(fresh).dispose();
    weights.dispose(); clearCache();
  }
}, 120_000);
