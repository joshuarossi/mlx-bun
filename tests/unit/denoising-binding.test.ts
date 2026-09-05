import { expect, test } from "bun:test";
import { denoiseAsync, denoiseSync, type DiffusionGenOptions } from "../../src/diffusion/diffusion-generate";
import type { DenoisingGraph } from "../../src/inference/denoising";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

function fixture(onStep?: () => void) {
  const calls = { prefill: 0, steps: 0, closed: 0 };
  const graph: DenoisingGraph<MlxArray, { offset: number }> = {
    descriptor: { id: "independent-canvas", artifact: "fixture", backend: "mlx",
      graphAbi: "mlx-denoising-v1", stateAbi: "position-only-v1" },
    vocabSize: 4, canvasLength: 2, embedScale: 1,
    prefill(ids) { calls.prefill++; return { offset: ids.length }; },
    extendPrefill(ids, state) { state.offset += ids.shape[1]!; },
    decoderLogits(canvas, state) {
      calls.steps++; onStep?.();
      const data = new Float32Array(8);
      canvas.toIntTokens().forEach((id, i) => { data[i * 4 + (id + state.offset) % 4] = 1; });
      return MlxArray.fromFloat32(data, [1, 2, 4]);
    },
    dequantEmbedWeight: () => MlxArray.fromFloat32(new Float32Array([0, 1, 2, 3]), [4, 1]),
    softEmbeddings(logits, weight) {
      const probabilities = ops.softmaxAxis(logits, -1, true);
      try { return ops.matmul(probabilities, weight); }
      finally { probabilities.dispose(); }
    },
    closeState() { calls.closed++; },
  };
  return { graph, calls };
}

const options: DiffusionGenOptions = { maxTokens: 5, maxDenoisingSteps: 3,
  minCanvasLength: 2, eosTokenIds: [], seed: 0n };

test("sync and cooperative denoising preserve RNG-dependent canvases across blocks and samplers", async () => {
  const results = new Set<string>();
  for (const sampler of ["confidence-threshold", "entropy-bound"] as const) {
    for (const seed of [0n, 7n]) {
      const sync = fixture(); const async = fixture();
      const opts = { ...options, sampler, seed };
      const expected = denoiseSync(sync.graph, [1], opts);
      const actual = await denoiseAsync(async.graph, [1], opts);
      expect(actual).toEqual(expected);
      expect(actual.blocks).toHaveLength(3);
      expect(actual.steps).toBeGreaterThan(1);
      expect(sync.calls.closed).toBe(1); expect(async.calls.closed).toBe(1);
      results.add(JSON.stringify(actual.blocks));
    }
  }
  expect(results.size).toBeGreaterThan(1);
});

test("cancellation between denoising steps releases canvas and feedback without completing another step", async () => {
  const cancelRun = async () => {
    const abort = new AbortController();
    const f = fixture(() => setImmediate(() => abort.abort(new DOMException("cancelled", "AbortError"))));
    await expect(denoiseAsync(f.graph, [1], options, abort.signal)).rejects.toHaveProperty("name", "AbortError");
    expect(f.calls).toEqual({ prefill: 1, steps: 1, closed: 1 });
  };
  await cancelRun(); synchronize(gpuStream); clearCache();
  const baseline = activeMemory();
  for (let i = 0; i < 10; i++) await cancelRun();
  synchronize(gpuStream); clearCache();
  expect(activeMemory()).toBeLessThanOrEqual(baseline);
});

test("pre-cancelled and incompatible denoising requests allocate no state", async () => {
  const f = fixture();
  const abort = new AbortController(); abort.abort();
  await expect(denoiseAsync(f.graph, [1], options, abort.signal)).rejects.toHaveProperty("name", "AbortError");
  expect(() => denoiseSync({ ...f.graph, descriptor: { ...f.graph.descriptor, backend: "other" } }, [1], options))
    .toThrow("incompatible backend");
  expect(f.calls.prefill).toBe(0);
});

test("embedding preparation failure closes already-created graph state", () => {
  const f = fixture();
  expect(() => denoiseSync({ ...f.graph, dequantEmbedWeight() { throw new Error("embedding failed"); } }, [1], options))
    .toThrow("embedding failed");
  expect(f.calls.closed).toBe(1);
});
