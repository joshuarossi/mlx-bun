import { describe, expect, test } from "bun:test";
import { createInferenceEngine } from "../../src/engine/engine";
import { createAutoregressiveMethod, createSpeculativeMethod } from "../../src/backends/mlx/methods";
import { bindMlxGraph } from "../../src/backends/mlx/graph";
import { bindCacheRollback } from "../../src/backends/mlx/rollback";
import { MlxArray } from "../../src/mlx/array";
import { KVCache, type Cache } from "../../src/model/gemma4";
import type { MlxSpeculativeBinding } from "../../src/backends/mlx/speculative";
import type { MlxAutoregressiveBinding } from "../../src/backends/mlx/autoregressive";
import type { InferenceMethod, Timer } from "../../src/contracts/generation";
import type { GenerateStats } from "../../src/generate";

const timer: Timer = { after(ms, callback) { const id = setTimeout(callback, ms); return () => clearTimeout(id); } };

function fixture(fail = false) {
  const calls = { caches: 0, sources: 0, forwards: 0, rollbacks: 0 };
  const makeCache = () => {
    class OwnedCache extends KVCache {
      override dispose() { calls.caches++; super.dispose(); }
      override trim(n: number) { calls.rollbacks++; super.trim(n); }
    }
    return [new OwnedCache()];
  };
  const graph = bindMlxGraph({
    forwardHidden(ids: MlxArray, state: Cache[]) {
      if (fail && calls.forwards++ > 0) throw new Error("target failed");
      const tokens = ids.toIntTokens();
      const kv = MlxArray.fromFloat32(new Float32Array(tokens.length * 4), [1, 1, tokens.length, 4]);
      try { for (const view of state[0]!.updateAndFetch(kv, kv)) view.dispose(); }
      finally { kv.dispose(); }
      return MlxArray.fromFloat32(Float32Array.from(tokens), [1, tokens.length, 1]);
    },
    logitsFromHidden(hidden) {
      const ids = hidden.toFloat32Host();
      const values = new Float32Array(ids.length * 8);
      ids.forEach((id, i) => { values[i * 8 + ((id + 1) % 8)] = 10; });
      return MlxArray.fromFloat32(values, [1, ids.length, 8]);
    },
  }, { id: "replacement", artifact: "synthetic", stateAbi: "legacy-cache-array-v1" });
  const ar: MlxAutoregressiveBinding = { graph, makeCache, eosTokenIds: [7], memory: { weightsBytes: 0 } };
  const spec: MlxSpeculativeBinding = {
    descriptor: graph.descriptor,
    eosTokenIds: [7], prefillTailSplit: true, makeCache, bindRollback: bindCacheRollback,
    async forward(ids, caches) { return { hidden: await graph.forwardHidden(ids, caches), ctxML: null }; },
    projectLogits: (hidden) => graph.projectLogits(hidden, { type: "all" }),
    openDraft() {
      return { weightsBytes: 0, prefill() {}, draft: (_feed, n) => Array(n).fill(0),
        commit() {}, dispose() { calls.sources++; } };
    },
  };
  return { calls, ar, spec };
}

for (const method of ["AR", "speculative"] as const) {
  describe(`${method} uses the common native method/session contract`, () => {
    function setup(fail = false) {
      const f = fixture(fail);
      const options = { maxTokens: 4, temperature: 0 };
      const registration: InferenceMethod<GenerateStats> = method === "AR"
        ? createAutoregressiveMethod(f.ar, [0, 1], options)
        : createSpeculativeMethod(f.spec, 2, [0, 1], options);
      const engine = createInferenceEngine({ async plan() {
        return { id: "replacement", outputTokenLimit: 4, method: registration };
      } }, { timer });
      return { ...f, engine };
    }

    test("collection and streaming preserve committed output and release state", async () => {
      const { engine, calls } = setup();
      try {
        const collected = await (await engine.open({}, { output: "collect" })).result;
        expect(collected.status).toBe("completed");
        expect([...collected.output!]).toEqual([2, 3, 4, 5]);
        const session = await engine.open({}, { output: "stream" });
        const tokens: number[] = [];
        for await (const event of session.events) if (event.type === "committed") tokens.push(...event.tokenIds);
        expect(tokens).toEqual([2, 3, 4, 5]);
        expect((await session.result).status).toBe("completed");
        expect(calls.caches).toBe(2);
        if (method === "speculative") {
          expect(calls.sources).toBe(2);
          expect(calls.rollbacks).toBeGreaterThan(0);
        }
      } finally { await engine.close(); }
    });

    test("early reader close cancels execution and waits for state release", async () => {
      const { engine, calls } = setup();
      try {
        const session = await engine.open({}, { output: "stream" });
        for await (const event of session.events) if (event.type === "committed") break;
        expect((await session.result).status).toBe("cancelled");
        expect(calls.caches).toBe(1);
        if (method === "speculative") expect(calls.sources).toBe(1);
      } finally { await engine.close(); }
    });

    test("forward failure settles after cache and source cleanup", async () => {
      const { engine, calls } = setup(true);
      try {
        const result = await (await engine.open({}, { output: "collect" })).result;
        expect(result.status).toBe("failed");
        if (result.status === "failed") expect(result.error.message).toContain("target failed");
        expect(calls.caches).toBe(1);
        if (method === "speculative") expect(calls.sources).toBe(1);
      } finally { await engine.close(); }
    });
  });
}
