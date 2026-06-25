// DiffusionGemma image-text-to-text (D3 vision) parity (OPT-IN slow tier).
// The DEDICATED SigLIP vision tower (src/vision/diffusion-vision.ts) — a
// parity-exact port of optiq's gemma4 VisionModel at the DiffusionGemma geometry
// (hidden 1152, head_dim 72, 27 layers, standardize, the quantized-input_proj
// uint32 patch truncation, the fused-SDPA head_dim 80 padding) — feeds the
// encoder vision merge + bidirectional overlay, then the denoising engine.
//
//   MLX_BUN_TEST_DIFFUSION=1 bun test tests/diffusion-vision.test.ts
//
// Golden: scripts/gen-diffusion-vision-golden.py (fixture grad-768.png).
// Gate: spliced ids EXACT + generation TOKEN-FOR-TOKEN vs optiq.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig } from "../src/config";
import { DiffusionGemmaModel } from "../src/model/diffusion-gemma";
import { spliceImageTokens } from "../src/vision/diffusion-vision";
import { diffusionGenerate } from "../src/diffusion/diffusion-generate";
import { loadTokenizer } from "../src/tokenizer";
import { ChatTemplate } from "../src/chat-template";
import { Weights } from "../src/weights";
import { SNAPSHOT_DIFFUSION, snapshotDiffusionAvailable } from "./paths";

const GOLD = "goldens/diffusion/vision.json";
const optIn = process.env.MLX_BUN_TEST_DIFFUSION === "1";
const haveWeights = await snapshotDiffusionAvailable();
const skip = !optIn || !haveWeights || !existsSync(GOLD);

interface Gen {
  prompt: string;
  input_ids: number[];
  soft_tokens: number;
  tokens: number[];
  total_steps: number;
  finish_reason: string;
}

describe.skipIf(skip)("DiffusionGemma image-text-to-text parity (vs mlx-optiq)", () => {
  test("preprocess + splice + tower + engine match optiq token-for-token", async () => {
    const g = (await Bun.file(GOLD).json()) as Gen;
    const config = await loadModelConfig(SNAPSHOT_DIFFUSION);
    const raw = (config as unknown as { raw: Record<string, any> }).raw;
    const tokenIds = {
      image: (raw.image_token_id as number) ?? 258880,
      boi: (raw.boi_token_id as number) ?? 255999,
      eoi: (raw.eoi_token_id as number) ?? 258882,
    };
    const model = new DiffusionGemmaModel(await Weights.open(SNAPSHOT_DIFFUSION), config);
    const tokenizer = await loadTokenizer(SNAPSHOT_DIFFUSION);
    const template = await ChatTemplate.load(SNAPSHOT_DIFFUSION);

    // Preprocess the fixture (the dedicated tower's resize/rescale).
    const bytes = new Uint8Array(await Bun.file("tests/fixtures/grad-768.png").arrayBuffer());
    const { pixels, softTokens } = await model.visionTower!.preprocess(bytes);
    expect(softTokens).toBe(g.soft_tokens);

    // Render the chat turn with a leading <|image|>, encode, splice — must equal
    // the optiq spliced input_ids exactly.
    const text = template.render([{ role: "user", content: "<|image|>" + g.prompt }], {
      addGenerationPrompt: true,
    });
    const rawIds = tokenizer.encode(text, /* addSpecialTokens */ false);
    const spliced = spliceImageTokens(rawIds, [softTokens], tokenIds);
    expect(spliced).toEqual(g.input_ids);

    // Generate (confidence-threshold, temp 0, seed 0) — token-for-token vs optiq.
    const out = diffusionGenerate(model, spliced, {
      maxTokens: 64,
      sampler: "confidence-threshold",
      temperature: 0,
      eosTokenIds: [1, 106],
      seed: 0n,
      visionPixels: pixels,
    });
    pixels.dispose();

    // eslint-disable-next-line no-console
    console.log(
      `[diffusion vision] ours ${JSON.stringify(out.tokens)} (${out.steps} steps) · ` +
        `ref ${JSON.stringify(g.tokens)} (${g.total_steps} steps)`,
    );
    expect(out.steps).toBe(g.total_steps);
    expect(out.tokens).toEqual(g.tokens);
  }, 600_000);
});
