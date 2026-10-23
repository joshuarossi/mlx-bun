// Text-to-image generation over substitute stage implementations: the stage
// contracts are all generation reads, so small fakes drive every path. Stage
// order and release, guided and conditional steps, the Euler arithmetic,
// validation before any stage opens, cancellation and failure at each stage
// (stages released, nothing left allocated), and the pixel postprocess on a
// decoder whose output is a transposed view.
import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, clearCache, synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type {
  FlowMatchingSchedule, ImageConditioner, ImageDenoiser, ImageLatentDecoder, TextToImagePipeline,
} from "../../src/contracts/mlx/image-generation";
import type { ImageGenerationProgress, ImageStage } from "../../src/contracts/portable/image-generation";
import { ConditionalVelocity, decodePixels, denoiseLatents, generateImage, initialLatents, resolveImageRequest } from "../../src/generation/image";

const CHANNELS = 2, PIXELS = 4, DEPTH = 3;

/** Levels 1 .. 0 in `steps` equal float32 decrements; timestep = sigma * 1000. */
const schedule: FlowMatchingSchedule = {
  sigmas: steps => Float32Array.from({ length: steps + 1 }, (_, i) => 1 - i / steps),
  timestep: sigma => sigma * 1000,
};

interface Faults { encode?: boolean; velocityAt?: number; decode?: boolean; abortAt?: (progress: ImageGenerationProgress) => boolean }

/** A pipeline of fakes that records what was opened, released, encoded and asked of the denoiser. */
function fakePipeline(faults: Faults = {}) {
  const events: string[] = [], encoded: string[] = [];
  const calls: { context: number; skip: number[] }[] = [];
  const conditioner: ImageConditioner = {
    encode(prompt) {
      if (faults.encode) throw new Error("encode failed");
      encoded.push(prompt);
      // The context length tells the denoiser's calls apart: positive prompts are longer.
      using wide = MlxArray.fromFloat32(new Float32Array((prompt.length + 1) * 4).fill(1), [1, prompt.length + 1, 4]);
      const out = wide.astype(Dtype.bfloat16);
      out.eval();
      return out;
    },
    dispose() { events.push("dispose:conditioner"); },
  };
  const denoiser: ImageDenoiser = {
    latentChannels: CHANNELS, pixelsPerLatent: PIXELS, depth: DEPTH,
    velocity(latents, _timestep, context, skip) {
      calls.push({ context: context.shape[1]!, skip: [...(skip ?? [])] });
      if (faults.velocityAt === calls.length) throw new Error("velocity failed");
      using zero = ops.zeros(latents.shape, Dtype.float32), one = ops.scalarLike(1, zero);
      return ops.add(zero, one);
    },
    dispose() { events.push("dispose:denoiser"); },
  };
  const decoder: ImageLatentDecoder = {
    decode(latents) {
      if (faults.decode) throw new Error("decode failed");
      const [, , h, w] = latents.shape as [number, number, number, number];
      return ops.zeros([1, h * PIXELS, w * PIXELS, 3], Dtype.float32);
    },
    dispose() { events.push("dispose:decoder"); },
  };
  const stages = { conditioner, denoiser, decoder } as const;
  const pipeline: TextToImagePipeline = {
    defaults: { width: 16, height: 8, steps: 4, guidance: 3, negativePrompt: "", uncondSkipLayers: [1] },
    schedule, latentChannels: CHANNELS, pixelsPerLatent: PIXELS, depth: DEPTH,
    stageBytes: { conditioner: 1, denoiser: 1, decoder: 1 },
    conditioner: async () => { events.push("open:conditioner"); return stages.conditioner; },
    denoiser: async () => { events.push("open:denoiser"); return stages.denoiser; },
    decoder: async () => { events.push("open:decoder"); return stages.decoder; },
    release: (stage: ImageStage) => { events.push(`release:${stage}`); },
    dispose: () => { events.push("dispose"); },
  };
  return { pipeline, events, encoded, calls };
}

/** Active bytes once the GPU stream has finished and released what it held. */
function settled(): number { synchronize(gpuStream); clearCache(); return activeMemory(); }

/** Runs `body` and checks that nothing it allocated is still active afterwards. Buffers return when their command
 * buffers complete, so the check waits (bounded) for the count to settle. */
async function leakFree(body: () => Promise<unknown>): Promise<void> {
  const before = settled();
  await body().catch(() => {});
  const deadline = performance.now() + 2000;
  while (settled() - before >= 4096 && performance.now() < deadline) await Bun.sleep(5);
  expect(settled() - before).toBeLessThan(4096);
}

test("each stage opens, runs and is released before the next opens", async () => {
  const { pipeline, events } = fakePipeline();
  const image = await generateImage(pipeline, { prompt: "a cat", seed: 7 });
  expect(events).toEqual(["open:conditioner", "release:conditioner", "open:denoiser", "release:denoiser", "open:decoder", "release:decoder"]);
  expect([image.width, image.height, image.seed, image.steps, image.guidance]).toEqual([16, 8, 7, 4, 3]);
  expect(image.pixels.length).toBe(16 * 8 * 3);
});

test("with releaseStages false every stage stays open for the next request", async () => {
  const { pipeline, events } = fakePipeline();
  await generateImage(pipeline, { prompt: "a cat" }, { releaseStages: false });
  expect(events).toEqual(["open:conditioner", "open:denoiser", "open:decoder"]);
});

test("guidance other than 1 runs both branches per step, the unconditional one skipping its blocks", async () => {
  const { pipeline, encoded, calls } = fakePipeline();
  await generateImage(pipeline, { prompt: "a cat", negativePrompt: "dog", steps: 2, uncondSkipLayers: [2] });
  expect(encoded).toEqual(["a cat", "dog"]);
  expect(calls).toEqual([{ context: 6, skip: [] }, { context: 4, skip: [2] }, { context: 6, skip: [] }, { context: 4, skip: [2] }]);
});

test("guidance 1 runs the conditional prediction alone and encodes no negative prompt", async () => {
  const { pipeline, encoded, calls } = fakePipeline();
  await generateImage(pipeline, { prompt: "a cat", guidance: 1, steps: 3 });
  expect(encoded).toEqual(["a cat"]);
  expect(calls.map(call => call.skip)).toEqual([[], [], []]);
});

test("the Euler steps integrate the velocity down the schedule in float32", async () => {
  const denoiser = await fakePipeline().pipeline.denoiser();
  using latents = MlxArray.fromFloat32(Float32Array.from([0.25, -1.5, 2, 3]), [1, 1, 2, 2]);
  using context = MlxArray.fromFloat32(new Float32Array(4), [1, 1, 4]);
  const done: number[] = [];
  const result = denoiseLatents(new ConditionalVelocity(denoiser, context), schedule, latents, { steps: 4, onStep: step => done.push(step) });
  using final = result.latents;
  // Velocity 1 from sigma 1 to 0: x - 1.
  expect(Array.from(final.toFloat32())).toEqual([-0.75, -2.5, 1, 2]);
  expect(done).toEqual([1, 2, 3, 4]);
});

test("an invalid request is refused before any stage opens", async () => {
  for (const [request, message] of [
    [{ prompt: "x", width: 18 }, "width must be a positive multiple of 4"],
    [{ prompt: "x", height: 0 }, "height must be a positive multiple of 4"],
    [{ prompt: "x", steps: 0 }, "steps must be a positive integer"],
    [{ prompt: "x", guidance: -1 }, "guidance must be finite and nonnegative"],
    [{ prompt: "x", seed: -1 }, "seed must be an integer"],
    [{ prompt: "x", uncondSkipLayers: [3] }, "uncondSkipLayers must name blocks in [0, 3)"],
  ] as const) {
    const { pipeline, events } = fakePipeline();
    await expect(generateImage(pipeline, request)).rejects.toThrow(message);
    expect(events).toEqual([]);
  }
  expect(resolveImageRequest(fakePipeline().pipeline, { prompt: "x", seed: 3 })).toEqual(
    { prompt: "x", negativePrompt: "", width: 16, height: 8, steps: 4, guidance: 3, seed: 3, uncondSkipLayers: [1] });
});

test("cancellation at each stage rejects, releases what opened and leaves nothing allocated", async () => {
  const already = new AbortController();
  already.abort();
  const { pipeline: idle, events: idleEvents } = fakePipeline();
  await expect(generateImage(idle, { prompt: "a cat" }, { signal: already.signal })).rejects.toThrow();
  expect(idleEvents).toEqual([]);
  for (const [label, at, expected] of [
    ["while denoising", (p: ImageGenerationProgress) => p.stage === "denoiser" && p.step === 2,
      ["open:conditioner", "release:conditioner", "open:denoiser", "release:denoiser"]],
    ["before decoding", (p: ImageGenerationProgress) => p.stage === "decoder",
      ["open:conditioner", "release:conditioner", "open:denoiser", "release:denoiser"]],
  ] as const) {
    const { pipeline, events } = fakePipeline();
    const controller = new AbortController();
    await leakFree(async () => {
      await expect(generateImage(pipeline, { prompt: "a cat", width: 64, height: 64 }, {
        signal: controller.signal, onProgress: progress => { if (at(progress)) controller.abort(); },
      })).rejects.toThrow();
    });
    expect(events, label).toEqual([...expected]);
  }
});

test("a failing stage rejects with its error, releases what opened and leaves nothing allocated", async () => {
  for (const [faults, message, expected] of [
    [{ encode: true }, "encode failed", ["open:conditioner", "release:conditioner"]],
    [{ velocityAt: 3 }, "velocity failed", ["open:conditioner", "release:conditioner", "open:denoiser", "release:denoiser"]],
    [{ decode: true }, "decode failed",
      ["open:conditioner", "release:conditioner", "open:denoiser", "release:denoiser", "open:decoder", "release:decoder"]],
  ] as const) {
    const { pipeline, events } = fakePipeline(faults);
    await leakFree(async () => {
      await expect(generateImage(pipeline, { prompt: "a cat", width: 64, height: 64 })).rejects.toThrow(message);
    });
    expect(events, message).toEqual([...expected]);
  }
});

test("pixels follow the reference postprocess and are read row-major from a transposed decoder output", () => {
  // Values chosen at the rounding points: -1, -0.5, 0, 0.5, 1 and one beyond the clamp.
  const values = [-1, -0.5, 0, 0.5, 1, 2];
  const decoder: ImageLatentDecoder = {
    decode: () => {
      // Build [1, W=2, H=1, 3] and transpose to [1, H=1, W=2, 3]: a view whose storage order differs from its logical order.
      using columns = MlxArray.fromFloat32(Float32Array.from(values), [1, 2, 1, 3]);
      return ops.transposeAxes(columns, [0, 2, 1, 3]);
    },
    dispose() {},
  };
  using latents = ops.zeros([1, 1, 1, 1], Dtype.float32);
  const { pixels, width, height } = decodePixels(decoder, latents);
  expect([width, height]).toEqual([2, 1]);
  expect(Array.from(pixels)).toEqual([0, 64, 128, 191, 255, 255]);
});

test("seeded noise repeats for a seed and differs across seeds", () => {
  using a = initialLatents(CHANNELS, PIXELS, 16, 8, 11), b = initialLatents(CHANNELS, PIXELS, 16, 8, 11), c = initialLatents(CHANNELS, PIXELS, 16, 8, 12);
  expect(a.shape).toEqual([1, CHANNELS, 2, 4]);
  expect(Array.from(a.toFloat32())).toEqual(Array.from(b.toFloat32()));
  expect(Array.from(a.toFloat32())).not.toEqual(Array.from(c.toFloat32()));
});
