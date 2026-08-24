// Paged KV cache end-to-end parity (slow tier, weights-gated).
//
// The v1 claim is BIT-EXACT equivalence with the plain KVCache path — the
// paged cache stores the same bytes in a different physical arrangement
// and the gather reconstructs exactly the contiguous tensor the plain
// fetch would have produced, so unlike quantized-KV parity there is no
// knife-edge tolerance here: tol 0, full-trajectory agreement (a partial
// match would signal a real bug, per docs/design/kv-cache.md).
// mlx-lm is not the oracle (it has no paged cache); mlx-bun's own plain
// path is. Storage-layout unit parity (per-step fetch bytes, block
// boundaries, trim) runs model-free in tests/paged-kv.test.ts.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "../support/paths";

const haveWeights = await snapshotAvailable();

describe.skipIf(!haveWeights)("paged KV parity (12B)", async () => {
  if (!haveWeights) return;

  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Gemma4Model, KVCache, lastPositionLogits } = await import("../../src/model/gemma4");
  const { PagedKVCache } = await import("../../src/model/paged-kv");
  const { generate, maybePageKv } = await import("../../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);

  // A prompt long enough to cross block boundaries at blockSize 16 (the
  // small block forces multi-block writes in prefill AND a >1-block gather
  // on every decode step — the interesting paged codepaths).
  const promptIds = [2, 106, 1645, 107, 3689, 603, 573, 6996, 576, 1461,
    235336, 107, 106, 2516, 107, 651, 6996, 576, 1461, 603];
  const BLOCK = 16;

  test("maybePageKv swaps exactly the full-attention layers", () => {
    const caches = model.makeCache();
    maybePageKv(caches, { pagedKv: { blockSize: BLOCK } }, 128);
    const paged = caches.filter((c) => c instanceof PagedKVCache).length;
    const plain = caches.filter((c) => c instanceof KVCache).length;
    expect(paged).toBeGreaterThan(0); // 12B has full-attention donor layers
    expect(plain).toBe(0); // every plain full-attention cache converted
    for (const c of caches) c.dispose();
  }, 240_000);

  test("single-forward logits bit-exact vs plain caches", () => {
    const run = (pagedKv: boolean): Float32Array => {
      const caches = model.makeCache();
      if (pagedKv) maybePageKv(caches, { pagedKv: { blockSize: BLOCK } }, promptIds.length + 8);
      const logits = model.forward(promptIds, caches);
      const out = lastPositionLogits(logits);
      logits.dispose();
      for (const c of caches) c.dispose();
      return out;
    };
    const plain = run(false);
    const paged = run(true);
    expect(paged).toEqual(plain); // tol 0 — same bytes, different layout
  }, 240_000);

  test("greedy trajectory identical over 48 tokens (incl. trim-free decode)", async () => {
    const run = async (pagedKv: boolean): Promise<number[]> => {
      const tokens: number[] = [];
      const gen = generate(model, promptIds, {
        maxTokens: 48,
        temperature: 0,
        ...(pagedKv ? { pagedKv: { blockSize: BLOCK } } : {}),
      });
      for await (const t of gen) tokens.push(t.token);
      return tokens;
    };
    const plain = await run(false);
    const paged = await run(true);
    expect(paged).toEqual(plain); // FULL agreement — the v1 bit-exact claim
    expect(plain.length).toBeGreaterThan(0);
  }, 240_000);
});
