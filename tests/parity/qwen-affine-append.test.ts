import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { loadModelConfig } from "../../src/config";
import { createModel } from "../../src/model/factory";
import { Weights } from "../../src/weights";
import * as ops from "../../src/mlx/ops";
import { clearCache } from "../../src/mlx/ffi";
import { maybeQuantizeKv } from "../../src/generate";
import { evalCacheState } from "../../src/backends/mlx/prefill";
import { cloneSingleRowState, leaseCacheState } from "../../src/backends/mlx/state-views";
import { appendFillHidden } from "../../src/backends/mlx/fill-append";
import { disposeResources } from "../../src/engine/resources";
import type { Cache } from "../../src/model/gemma4";
import type { MlxArray } from "../../src/mlx/array";

// Native M4 acceptance for the qualified packed/RTN4 Qwen append binding.
// Select the artifact with MLX_BUN_TEST_FILL_MODEL; explicit opt-in avoids
// loading 27B weights during an unrelated parity run.
test.skipIf(Bun.env.MLX_BUN_TEST_AFFINE_APPEND !== "1")(
  "Qwen affine append retains hidden, logits, complete state and continuation", async () => {
    const path = Bun.env.MLX_BUN_TEST_FILL_MODEL ??
      `${Bun.env.HOME}/models/Qwen3.8-27B-q3-trellis-ldlq-k300-packed-interleave2-rd`;
    const config = await loadModelConfig(path);
    const weights = await Weights.open(path);
    const hash = (a: MlxArray) => createHash("sha256").update(a.rawBytes()).digest("hex");
    const state = (cache: Cache[]) => cache.map(c => {
      const lease = leaseCacheState(c);
      try {
        return { offset: c.offset, arrays: lease.borrow().map(a =>
          ({ shape: a.shape, dtype: a.dtype, hash: hash(a) })) };
      } finally { lease.close(); }
    });
    try {
      const model = createModel(weights, config);
      if (!("createAppend" in model)) throw new Error("missing append");
      const appender = model.createAppend({ hasAdapters: false, pagedKv: false });
      if (!appender) throw new Error("unqualified append");
      for (const prefix of [128, 1021]) for (const bits of [4, 8]) {
        const base = model.makeCache();
        let a: Cache[] = [], b: Cache[] = [];
        try {
          using ids = ops.fromInt32(Array.from({ length: prefix }, (_, i) => 100 + i * 7 % 600), [1, prefix]);
          using prefill = model.forwardHidden(ids, base);
          prefill.eval(); evalCacheState(base);
          maybeQuantizeKv(base, { kvBits: bits, kvGroupSize: 64, quantizedKvStart: 0 });
          evalCacheState(base);
          a = cloneSingleRowState(base); b = cloneSingleRowState(base);
        } catch (error) {
          disposeResources([...a, ...b]); throw error;
        } finally { disposeResources(base); }
        const hiddenRows: MlxArray[] = [];
        try {
          const tokens = [333, 444, 555, 666];
          for (const id of tokens) {
            using x = ops.fromInt32([id], [1, 1]);
            const hidden = model.forwardHidden(x, a);
            hiddenRows.push(hidden);
            hidden.eval(); evalCacheState(a);
          }
          using expected = ops.concatAxis(hiddenRows, 1);
          using actual = await appendFillHidden(appender.forwardHidden.bind(appender), b,
            tokens, appender.maxChunkSize);
          actual.eval(); evalCacheState(b);
          using expectedLogits = model.logitsFromHidden(expected);
          using actualLogits = model.logitsFromHidden(actual);
          const label = `${prefix}/KV${bits}`;
          expect(hash(actual), `${label} hidden`).toBe(hash(expected));
          expect(hash(actualLogits), `${label} logits`).toBe(hash(expectedLogits));
          expect(state(b), `${label} state`).toEqual(state(a));
          for (const id of [777, 888, 999, 1010]) {
            using x = ops.fromInt32([id], [1, 1]);
            using h1 = model.forwardHidden(x, a), h2 = model.forwardHidden(x, b);
            using l1 = model.logitsFromHidden(h1), l2 = model.logitsFromHidden(h2);
            expect(hash(l2), `${label} continuation ${id}`).toBe(hash(l1));
          }
        } finally { disposeResources([...hiddenRows, ...a, ...b]); clearCache(); }
      }
    } finally { weights.dispose(); clearCache(); }
  }, 240_000,
);
