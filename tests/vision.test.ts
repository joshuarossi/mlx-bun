// Vision pipeline parity (slow tier): same fixture image through our
// preprocessing + vision tower + merged-embedding prefill must produce
// the oracle's exact prompt ids and greedy tokens (goldens/vision.json —
// fixture is 768×768 so preprocessing has no resize step).

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const goldenFile = Bun.file("goldens/vision.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("vision oracle parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    input_ids: number[];
    soft_tokens: number[];
    greedy_ids: number[];
    decoded: string;
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { VisionTower } = await import("../src/vision/embedder");
  const { preprocessImage } = await import("../src/vision/preprocess");
  const { buildVisionPrompt } = await import("../src/vision/prompt");
  const { ChatTemplate } = await import("../src/chat-template");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { generate } = await import("../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const tower = VisionTower.load(SNAPSHOT, model.embedScale, config.text.rmsNormEps);
  const tokenizer = await loadTokenizer(SNAPSHOT);
  const template = await ChatTemplate.load(SNAPSHOT);
  const imageBytes = new Uint8Array(
    await Bun.file("tests/fixtures/grad-768.png").arrayBuffer(),
  );

  test("preprocessing matches (soft tokens, no resize)", () => {
    const p = preprocessImage(imageBytes);
    expect(p.softTokens).toBe(golden.soft_tokens[0]!);
  });

  test("prompt ids and greedy generation match oracle", async () => {
    const vp = buildVisionPrompt(
      model, tower, tokenizer, template,
      [{
        role: "user",
        content: [
          { type: "image" as const, data: Buffer.from(imageBytes).toString("base64") },
          { type: "text" as const, text: "Describe this image in one short sentence." },
        ],
      }] as never,
      [imageBytes],
      { imageTokenId: 258880, boiTokenId: 255999, eoiTokenId: 258882 },
    );
    expect(vp.ids).toEqual(golden.input_ids);

    const gen = generate(model, vp.ids, {
      maxTokens: 16,
      temperature: 0,
      promptEmbeddings: vp.embeddings,
      imageMask: vp.imageMask,
    });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);
    vp.embeddings.dispose();
    vp.imageMask.dispose();
    expect(out).toEqual(golden.greedy_ids);
  }, 240_000);
});
