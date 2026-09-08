import { expect, test } from "bun:test";
import { bindMlxGraph } from "../../src/backends/mlx/graph";
import { bindCacheRollback } from "../../src/backends/mlx/rollback";
import type { MlxSpeculativeBinding } from "../../src/backends/mlx/speculative";
import { MlxArray } from "../../src/mlx/array";
import { KVCache, type Cache } from "../../src/model/gemma4";
import { specRun } from "../../src/spec/serve-loop";

// A tie-free vocabulary predicts token i+1, with 7 as EOS. This exercises
// the real verifier and sampler without weights or an external model.
function fixture(drafts: "accepted" | "rejected" | "none", fallback = false) {
  let disposed = 0;
  const graph = bindMlxGraph({
    forwardHidden(ids: MlxArray, caches: Cache[]) {
      const tokens = ids.toIntTokens();
      using kv = MlxArray.fromFloat32(new Float32Array(tokens.length), [1, 1, tokens.length, 1]);
      for (const view of caches[0]!.updateAndFetch(kv, kv)) view.dispose();
      return MlxArray.fromFloat32(Float32Array.from(tokens), [1, tokens.length, 1]);
    },
    logitsFromHidden(hidden) {
      const tokens = hidden.toFloat32Host(), values = new Float32Array(tokens.length * 8);
      tokens.forEach((token, i) => { values[i * 8 + ((token + 1) % 8)] = 10; });
      return MlxArray.fromFloat32(values, [1, tokens.length, 8]);
    },
  }, { id: "eos-count", artifact: "synthetic", stateAbi: "legacy-cache-array-v1" });
  const binding: MlxSpeculativeBinding = {
    descriptor: graph.descriptor, eosTokenIds: [7], prefillTailSplit: true,
    makeCache: () => [new KVCache()],
    bindRollback(caches) {
      const transaction = bindCacheRollback(caches);
      return fallback ? { ...transaction, canBegin: () => false } : transaction;
    },
    async forward(ids, caches) { return { hidden: await graph.forwardHidden(ids, caches), ctxML: null }; },
    projectLogits: hidden => graph.projectLogits(hidden, { type: "all" }),
    openDraft() {
      return { weightsBytes: 0, prefill() {}, commit() {}, dispose() { disposed++; },
        draft(feed, n) {
          if (drafts === "none") return [];
          return Array.from({ length: n }, (_, i) => drafts === "rejected" ? 0 : (feed.at(-1)! + i + 1) % 8);
        },
      };
    },
  };
  return { binding, disposed: () => disposed };
}

for (const c of [
  { name: "accepted first-token EOS", prompt: [5, 6], drafts: "accepted", gamma: 2, expected: [], count: 1 },
  { name: "correction EOS", prompt: [5, 6], drafts: "rejected", gamma: 2, expected: [], count: 1 },
  { name: "zero-draft correction EOS", prompt: [5, 6], drafts: "none", gamma: 2, expected: [], count: 1 },
  { name: "bonus EOS", prompt: [4, 5], drafts: "accepted", gamma: 1, expected: [6], count: 2 },
  { name: "bonus EOS at the token budget", prompt: [4, 5], drafts: "accepted", gamma: 1, expected: [6], count: 2, maxTokens: 2 },
  { name: "accepted EOS after content", prompt: [3, 4], drafts: "accepted", gamma: 3, expected: [5, 6], count: 3 },
  { name: "single-prompt-token EOS", prompt: [6], drafts: "accepted", gamma: 2, expected: [], count: 1 },
  { name: "single-token continuation fallback", prompt: [5, 6], drafts: "accepted", gamma: 2, expected: [], count: 1, fallback: true },
  { name: "budget stops before EOS", prompt: [3, 4], drafts: "accepted", gamma: 3, expected: [5, 6], count: 2, maxTokens: 2 },
  { name: "callback stop discards later verified EOS", prompt: [3, 4], drafts: "accepted", gamma: 3, expected: [5], count: 1, halt: true },
] as const) {
  test(`speculative usage counts ${c.name} without emitting EOS`, async () => {
    const f = fixture(c.drafts, "fallback" in c && c.fallback), tokens: number[] = [];
    const stats = await specRun(f.binding, c.gamma, [...c.prompt], {
      maxTokens: "maxTokens" in c ? c.maxTokens : 8, temperature: 0,
    }, token => { tokens.push(token); return !("halt" in c && c.halt); });
    expect(tokens).toEqual([...c.expected]);
    expect(tokens).not.toContain(7);
    expect(stats.generatedTokens).toBe(c.count);
    expect(stats.finishReason).toBe(c.count > c.expected.length ? "stop" : undefined);
    expect(f.disposed()).toBe(1);
  });
}
