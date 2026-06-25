// DiffusionGemma LoRA (D5) gate (OPT-IN slow tier — loads the 14 GB checkpoint
// and trains). The denoising-objective LoRA trainer
// (src/train/diffusion-lora.ts) must: mount LoRA on the decoder blocks, run the
// corrupt-canvas → forward → CE-on-corrupted loss with autograd through the MoE
// (routing indices stop_gradient'd), and DECREASE the loss. Also asserts the
// trained adapter actually CHANGES the canvas logits (it learned something).
//
//   MLX_BUN_TEST_DIFFUSION=1 bun test tests/diffusion-lora.test.ts

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { DiffusionGemmaModel } from "../src/model/diffusion-gemma";
import { trainDiffusionLora } from "../src/train/diffusion-lora";
import { Weights } from "../src/weights";
import { SNAPSHOT_DIFFUSION, snapshotDiffusionAvailable } from "./paths";

const FWD = "goldens/diffusion/forward.json";
const optIn = process.env.MLX_BUN_TEST_DIFFUSION === "1";
const haveWeights = await snapshotDiffusionAvailable();
const skip = !optIn || !haveWeights || !existsSync(FWD);

describe.skipIf(skip)("DiffusionGemma LoRA (denoising objective)", () => {
  test("loss decreases and the adapter changes the output", async () => {
    const fwd = (await Bun.file(FWD).json()) as { argmax_canvas: number[] };
    const promptIds = [
      ...new Int32Array(await Bun.file("goldens/diffusion/forward-prompt.bin").arrayBuffer()),
    ];
    // A short, learnable target: 16 real tokens the model itself produces.
    const targetIds = fwd.argmax_canvas.slice(0, 16);

    const config = await loadModelConfig(SNAPSHOT_DIFFUSION);
    const model = new DiffusionGemmaModel(await Weights.open(SNAPSHOT_DIFFUSION), config);

    // Baseline (no adapter) canvas logits, to confirm the adapter changes them.
    const baseLogits = model.forwardCanvasLogits(promptIds, targetIds).toFloat32();

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
    const adaptedLogits = model.forwardCanvasLogits(promptIds, targetIds).toFloat32();
    model.loraState.active = [];
    let maxDiff = 0;
    for (let i = 0; i < baseLogits.length; i++)
      maxDiff = Math.max(maxDiff, Math.abs(adaptedLogits[i]! - baseLogits[i]!));
    console.log(`[diffusion-lora] adapter logit maxDiff ${maxDiff.toExponential(3)}`);
    expect(maxDiff).toBeGreaterThan(0);
    void lora;
  }, 600_000);
});
