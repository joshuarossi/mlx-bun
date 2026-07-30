import { describe, expect, test } from "bun:test";
import { diffusionGenerate } from "../src/diffusion/diffusion-generate";
import type { DiffusionGemmaModel } from "../src/model/diffusion-gemma";
import { MlxArray, gpuStream } from "../src/mlx/array";
import { activeMemory, clearCache, synchronize } from "../src/mlx/ffi";

const VOCAB = 4;
const CANVAS = 2;
const HIDDEN = 7; // unique shape marker for self-conditioning tensors

function stubModel(): DiffusionGemmaModel {
  return {
    config: { text: { vocabSize: VOCAB } },
    canvasLength: CANVAS,
    embedScale: 1,
    prefill: () => [],
    dequantEmbedWeight: () =>
      MlxArray.fromFloat32(
        Float32Array.from({ length: VOCAB * HIDDEN }, (_, i) => (i % HIDDEN) / HIDDEN),
        [VOCAB, HIDDEN],
      ),
    decoderLogits: () =>
      MlxArray.fromFloat32(
        Float32Array.from({ length: CANVAS * VOCAB }, (_, i) => (i % VOCAB === 0 ? 10 : 0)),
        [1, CANVAS, VOCAB],
      ),
  } as unknown as DiffusionGemmaModel;
}

describe("diffusion generation ownership", () => {
  test("stable+confident early stop disposes every pending soft embedding", () => {
    const generate = () => diffusionGenerate(stubModel(), [1], {
      maxTokens: CANVAS,
      maxDenoisingSteps: 4,
      minCanvasLength: CANVAS,
      maxCanvasLength: CANVAS,
      sampler: "entropy-bound" as const,
      stabilityThreshold: 1,
      confidenceThreshold: 100,
      eosTokenIds: [],
      seed: 0n,
    });

    // Warm MLX's process-global RNG/operator state before taking the lifetime
    // baseline; those one-time allocations are not per-generation ownership.
    generate();
    synchronize(gpuStream);
    clearCache();
    const before = activeMemory();

    const originalDispose = MlxArray.prototype.dispose;
    let softShapeDisposals = 0;
    MlxArray.prototype.dispose = function patchedDispose(this: MlxArray): void {
      try {
        if (this.shape.join(",") === `1,${CANVAS},${HIDDEN}`) softShapeDisposals++;
      } catch {
        // An already-disposed wrapper has no readable shape and must not count twice.
      }
      originalDispose.call(this);
    };

    const iterations = 50;
    try {
      for (let i = 0; i < iterations; i++) {
        const out = generate();
        expect(out.steps).toBe(2);
        expect(out.tokens).toEqual([0, 0]);
      }
    } finally {
      MlxArray.prototype.dispose = originalDispose;
    }

    synchronize(gpuStream);
    clearCache();
    // Each of the two denoising steps creates m, cast(m), and the final soft
    // embedding at [1,canvas,hidden]. All six wrappers must be explicitly
    // disposed per run, including the pending second-step output at early stop.
    expect(softShapeDisposals).toBe(iterations * 6);
    expect(activeMemory()).toBeLessThanOrEqual(before);
  });
});
