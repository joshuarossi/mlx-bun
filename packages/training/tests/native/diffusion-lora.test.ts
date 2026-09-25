// OPT-IN DiffusionGemma LoRA (D5) gate over a real cached checkpoint — the port
// of main's tests/parity/diffusion-lora.test.ts. The denoising-objective LoRA
// trainer (`trainDiffusionLora`) must: mount LoRA on the decoder blocks, run
// the corrupt-canvas -> forward -> CE-on-corrupted loss with autograd through
// the MoE (routing indices stop_gradient'd), and DECREASE the loss. Also
// asserts the trained adapter actually CHANGES the canvas logits (it learned
// something).
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_DIFFUSION_MODEL=<snapshot-dir> \
//     bun test tests/native/diffusion-lora.test.ts
//
// Loads the caller-supplied DiffusionGemma-26B-A4B OptiQ checkpoint (~14 GB)
// and trains on the GPU, so it is skipped unless BOTH MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_TRAINING_DIFFUSION_MODEL are set; the skip happens before any native
// import and it never runs inside the default suite. MLX_BUN_TEST_NATIVE=1
// alone skips, like the sibling model tests (the `test:native` script runs this
// whole directory on Mac CI with no checkpoint). Naming a checkpoint without
// MLX_BUN_TEST_NATIVE=1, or naming a directory that is not a diffusion_gemma
// snapshot, fails loudly instead of skipping.
//
// Main read its inputs from goldens/diffusion/{forward-prompt.bin,forward.json};
// they are regenerated here from the checkpoint itself (no goldens):
//   - promptIds: the golden generator's prompt ("Write a haiku about Apple
//     Silicon.") rendered through the checkpoint's chat template with the
//     generation prompt and encoded by its tokenizer (BOS prepended, as the
//     generator's `tokenizer.encode` did).
//   - targetIds: the first 16 tokens of the model's own argmax canvas over a
//     seed-0 uniform-random full-length canvas — the golden's `argmax_canvas`
//     construction, computed by our forward instead of the oracle's.

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

// The explicit native command opts in with MLX_BUN_TEST_NATIVE=1 (Mac CI after
// staging MLX); this model test additionally needs the caller's cached
// DiffusionGemma snapshot directory in MLX_BUN_TRAINING_DIFFUSION_MODEL.
// Ordinary discovery skips before loading native modules.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_DIFFUSION_MODEL ?? "";
if (modelDir !== "") {
  if (!native) {
    throw new Error(
      "MLX_BUN_TRAINING_DIFFUSION_MODEL is set but MLX_BUN_TEST_NATIVE=1 is not; " +
      "refusing to skip a requested checkpoint run",
    );
  }
  const configPath = join(modelDir, "config.json");
  if (!existsSync(configPath)) {
    throw new Error(
      `MLX_BUN_TRAINING_DIFFUSION_MODEL must name a snapshot directory containing config.json: ${modelDir}`,
    );
  }
  const modelType = (JSON.parse(readFileSync(configPath, "utf8")) as { model_type?: unknown }).model_type;
  if (modelType !== "diffusion_gemma") {
    throw new Error(
      `MLX_BUN_TRAINING_DIFFUSION_MODEL must name a diffusion_gemma snapshot (config.json model_type is ${JSON.stringify(modelType)}): ${modelDir}`,
    );
  }
}
const optIn = native && modelDir !== "";
const { loadModelConfig, Weights } = optIn ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { DiffusionGemmaModel } = optIn ? await import("@mlx-bun/inference/models/diffusion-gemma") : {} as typeof import("@mlx-bun/inference/models/diffusion-gemma");
const { loadTokenizer, ChatTemplate } = optIn ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { trainDiffusionLora } = optIn ? await import("@mlx-bun/training") : {} as typeof import("@mlx-bun/training");
const ops = optIn ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { Dtype } = optIn ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");

// The golden generator's fixed prompt (scripts/oracle/gen-diffusion-golden.py
// PROMPT_TEXT) and seed; the target is the first 16 argmax-canvas tokens.
const PROMPT_TEXT = "Write a haiku about Apple Silicon.";
const CANVAS_SEED = 0n;
const TARGET_LEN = 16;

describe.skipIf(!optIn)("DiffusionGemma LoRA (denoising objective)", () => {
  test("loss decreases and the adapter changes the output", async () => {
    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    const model = new DiffusionGemmaModel(weights, config);
    try {
      const tok = await loadTokenizer(modelDir);
      const tmpl = await ChatTemplate.load(modelDir);
      const promptIds = tok.encode(
        tmpl.render([{ role: "user", content: PROMPT_TEXT }], { addGenerationPrompt: true }),
      );

      // A short, learnable target: 16 real tokens the model itself produces
      // (its argmax over a seed-0 random canvas, the golden's argmax_canvas).
      ops.randomSeed(CANVAS_SEED);
      const canvas = ops.randint(0, config.text.vocabSize, [1, model.canvasLength], Dtype.int32);
      const canvasLogits = model.forwardCanvasLogitsArr(promptIds, canvas);
      canvas.dispose();
      const argmax = ops.argmaxAxis(canvasLogits, -1);
      canvasLogits.dispose();
      const targetIds = argmax.toIntTokens().slice(0, TARGET_LEN);
      argmax.dispose();
      expect(targetIds.length).toBe(TARGET_LEN);

      // Baseline (no adapter) canvas logits, to confirm the adapter changes them.
      const base = model.forwardCanvasLogits(promptIds, targetIds);
      const baseLogits = base.toFloat32();
      base.dispose();

      const { lora, losses } = trainDiffusionLora(model, [{ promptIds, targetIds }], {
        rank: 4,
        scale: 8.0,
        iters: 30,
        learningRate: 2e-4,
        reportEvery: 5,
        seed: 0,
        onReport: (it, l) => console.log(`[diffusion-lora] iter ${it} loss ${l.toFixed(4)}`),
      });

      expect(losses.length).toBeGreaterThan(0);
      for (const l of losses) expect(Number.isFinite(l)).toBe(true);
      const early = losses.slice(0, 6).reduce((a, b) => a + b, 0) / 6;
      const late = losses.slice(-6).reduce((a, b) => a + b, 0) / Math.min(6, losses.length);
      console.log(`[diffusion-lora] early ${early.toFixed(4)} → late ${late.toFixed(4)}`);
      expect(late).toBeLessThan(early); // the denoising loss went down

      // With the trained LoRA active, the canvas logits differ from the base.
      model.loraState.active = ["train"];
      const adapted = model.forwardCanvasLogits(promptIds, targetIds);
      const adaptedLogits = adapted.toFloat32();
      adapted.dispose();
      model.loraState.active = [];
      let maxDiff = 0;
      for (let i = 0; i < baseLogits.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(adaptedLogits[i]! - baseLogits[i]!));
      console.log(`[diffusion-lora] adapter logit maxDiff ${maxDiff.toExponential(3)}`);
      expect(maxDiff).toBeGreaterThan(0);
      void lora;
    } finally {
      weights.dispose();
    }
  }, 600_000);
});
