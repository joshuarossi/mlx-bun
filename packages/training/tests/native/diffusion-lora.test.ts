// OPT-IN DiffusionGemma LoRA (D5) gate over a real cached checkpoint — the port
// of `02d723a:tests/parity/diffusion-lora.test.ts`. The denoising-objective LoRA
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
// Main read its inputs from goldens/diffusion/forward-prompt.bin (untracked) and
// `02d723a:goldens/diffusion/forward.json`;
// they are regenerated here from the checkpoint itself (no goldens):
//   - promptIds: the golden generator's prompt ("Write a haiku about Apple
//     Silicon.") rendered through the checkpoint's chat template with the
//     generation prompt and encoded by its tokenizer (BOS prepended, as the
//     generator's `tokenizer.encode` did).
//   - targetIds: the first 16 tokens of the model's own argmax canvas over a
//     seed-0 uniform-random full-length canvas — the golden's `argmax_canvas`
//     construction, computed by our forward instead of the oracle's.
//
// Beyond main's check, the trained adapter is saved in the mountable layout
// (`saveAdapter`), the training graph and weights are released, and a fresh
// graph mounts it through the public `AdapterManager`: canvas logits and
// seeded denoising generations (tokens, blocks, steps, finish) must equal the
// in-memory adapter's exactly, and unmounting restores the base exactly.
// MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT=<new or empty directory> keeps that
// saved adapter (for the app's DiffusionGemma adapter serving check);
// otherwise it is written to a temporary directory and removed.

import { describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
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
const adapterOut = process.env.MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT ?? "";
if (adapterOut !== "") {
  if (modelDir === "")
    throw new Error("MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT is set without MLX_BUN_TRAINING_DIFFUSION_MODEL");
  if (existsSync(adapterOut) && readdirSync(adapterOut).length > 0)
    throw new Error(`MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT must name a new or empty directory: ${adapterOut}`);
}
const optIn = native && modelDir !== "";
const { loadModelConfig, Weights } = optIn ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { DiffusionGemmaModel } = optIn ? await import("@mlx-bun/inference/models/diffusion-gemma") : {} as typeof import("@mlx-bun/inference/models/diffusion-gemma");
const { loadTokenizer, ChatTemplate } = optIn ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { trainDiffusionLora, saveAdapter, detachTraining, disposeLora } = optIn ? await import("@mlx-bun/training") : {} as typeof import("@mlx-bun/training");
const { DEFAULT_LORA_KEYS } = optIn ? await import("@mlx-bun/training/diffusion") : {} as typeof import("@mlx-bun/training/diffusion");
const { AdapterManager } = optIn ? await import("@mlx-bun/inference/adapters") : {} as typeof import("@mlx-bun/inference/adapters");
const { diffusionGenerate } = optIn ? await import("@mlx-bun/inference/generation/diffusion") : {} as typeof import("@mlx-bun/inference/generation/diffusion");
const ops = optIn ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { Dtype } = optIn ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");

// The golden generator's fixed prompt (`02d723a:scripts/oracle/gen-diffusion-golden.py`
// PROMPT_TEXT) and seed; the target is the first 16 argmax-canvas tokens.
const PROMPT_TEXT = "Write a haiku about Apple Silicon.";
const CANVAS_SEED = 0n;
const TARGET_LEN = 16;
// Seeded greedy generation for the save/reload comparison (request-local keys).
const GENERATION = { maxTokens: 32, seed: 7n } as const;
const ADAPTER_ID = "diffusion-lora";

type Model = InstanceType<typeof DiffusionGemmaModel>;
/** Softcapped fp32 canvas logits, read back as bytes. */
function canvasBytes(model: Model, promptIds: number[], canvas: number[]): Uint8Array {
  const logits = model.forwardCanvasLogits(promptIds, canvas);
  try { return logits.rawBytes(); } finally { logits.dispose(); }
}
function generate(model: Model, promptIds: number[]) {
  const { tokens, blocks, steps, finishReason } = diffusionGenerate(model, promptIds, GENERATION);
  return { tokens, blocks, steps, finishReason };
}

describe.skipIf(!optIn)("DiffusionGemma LoRA (denoising objective)", () => {
  test("loss decreases, the adapter changes the output, and the saved adapter reloads and generates exactly", async () => {
    const config = await loadModelConfig(modelDir);
    const scratch = adapterOut === "" ? mkdtempSync(join(tmpdir(), "mlx-diffusion-lora-")) : null;
    const adapterDir = adapterOut === "" ? join(scratch!, "adapter") : adapterOut;
    let promptIds: number[] = [], targetIds: number[] = [], targets = 0;
    let baseBytes: Uint8Array | undefined, adaptedBytes: Uint8Array | undefined;
    let baseGeneration: ReturnType<typeof generate> | undefined, adaptedGeneration: ReturnType<typeof generate> | undefined;
    try {
      const weights = await Weights.open(modelDir);
      const model = new DiffusionGemmaModel(weights, config);
      try {
        const tok = await loadTokenizer(modelDir);
        const tmpl = await ChatTemplate.load(modelDir);
        promptIds = tok.encode(
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
        targetIds = argmax.toIntTokens().slice(0, TARGET_LEN);
        argmax.dispose();
        expect(targetIds.length).toBe(TARGET_LEN);

        // Baseline (no adapter) canvas logits, to confirm the adapter changes them.
        const base = model.forwardCanvasLogits(promptIds, targetIds);
        const baseLogits = base.toFloat32();
        baseBytes = base.rawBytes();
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
        try {
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
          adaptedBytes = adapted.rawBytes();
          adapted.dispose();
          adaptedGeneration = generate(model, promptIds);
          model.loraState.active = [];
          baseGeneration = generate(model, promptIds);
          let maxDiff = 0;
          for (let i = 0; i < baseLogits.length; i++)
            maxDiff = Math.max(maxDiff, Math.abs(adaptedLogits[i]! - baseLogits[i]!));
          console.log(`[diffusion-lora] adapter logit maxDiff ${maxDiff.toExponential(3)}`);
          expect(maxDiff).toBeGreaterThan(0);
          const changed = JSON.stringify(adaptedGeneration.tokens) !== JSON.stringify(baseGeneration.tokens);
          console.log(`[diffusion-lora] seeded generation ${changed ? "changed" : "unchanged"} by the adapter`);

          // Save in the mountable layout, then release the training leaves.
          targets = lora.targets.length;
          await saveAdapter(lora, adapterDir, {
            rank: 4, scale: 8.0, rankScaling: "constant", targetModules: [...DEFAULT_LORA_KEYS],
            numLayers: -1, method: "diffusion", baseModel: modelDir,
          }, Object.fromEntries(lora.targets.map(target => [target.modulePath, target.lw.rank])));
        } finally {
          detachTraining(model, lora);
          disposeLora(lora);
        }
      } finally {
        weights.dispose();
      }

      // A fresh graph from the checkpoint mounts the saved adapter through the public manager.
      const fresh = await Weights.open(modelDir);
      try {
        const reloaded = new DiffusionGemmaModel(fresh, config);
        const manager = new AdapterManager(reloaded);
        const info = await manager.mount(ADAPTER_ID, adapterDir);
        expect(info.mountedLayers).toBe(targets);
        expect(info.scale).toBe(8);
        reloaded.loraState.active = [ADAPTER_ID];
        expect(Buffer.compare(canvasBytes(reloaded, promptIds, targetIds), adaptedBytes!)).toBe(0);
        expect(generate(reloaded, promptIds)).toEqual(adaptedGeneration!);
        reloaded.loraState.active = [];
        expect(Buffer.compare(canvasBytes(reloaded, promptIds, targetIds), baseBytes!)).toBe(0);
        expect(generate(reloaded, promptIds)).toEqual(baseGeneration!);
        expect(manager.unmount(ADAPTER_ID)).toBe(targets);
        expect(Buffer.compare(canvasBytes(reloaded, promptIds, targetIds), baseBytes!)).toBe(0);
      } finally {
        fresh.dispose();
      }
    } finally {
      if (scratch) rmSync(scratch, { recursive: true, force: true });
    }
  }, 1_800_000);
});
