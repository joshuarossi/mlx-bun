// SigLIP vision parity (slow tier): the same fixture image through our SigLIP
// preprocessing + vision encoder + MultimodalEmbedder + merged-embedding
// prefill (with e4b's per-layer inputs), validated against the optiq stack.
//
// Bars (matching PLAN Phase 12's exit criterion — "tier a on ids + greedy
// prefix"):
//   - spliced prompt ids: EXACT (build-independent — pure tokenization/splice)
//   - soft-token count: EXACT
//   - greedy PREFIX: matches the oracle for the leading tokens
//   - decoded output: grounded in the image (end-to-end vision works)
// Full bit-exact greedy is NOT asserted: every mlx primitive is bit-exact vs the
// oracle (verified, scripts/op-parity-*), but the 16-layer encoder accumulates a
// sub-bf16 (~0.0007%/layer) composition non-associativity amplified by its
// scale=1.0 peaked softmax (~1% on features), which flips the greedy argmax a
// few tokens in. NOT a kernel/cross-build issue. See src/vision/siglip.ts header.
//
// Oracle: goldens/e4b-vision.json (scripts/gen-e4b-vision-golden.py). Fixture
// is 768x768 so preprocessing has no resize step (bit-exact pixels).

import { describe, expect, test } from "bun:test";
import { goldenAt } from "./goldens";
import { SNAPSHOT_E4B, snapshotE4bAvailable } from "./paths";

const haveWeights = await snapshotE4bAvailable();
const goldenFile = goldenAt("e4b-vision.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("e4b SigLIP vision parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    input_ids: number[];
    soft_tokens: number[];
    greedy_ids: number[];
    decoded: string;
  };
  // leading greedy tokens that survive the encoder's sub-bf16 accumulation
  const GREEDY_PREFIX = 5;

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { SiglipVisionTower, parseSiglipConfig } = await import("../src/vision/siglip");
  const { buildVisionPrompt } = await import("../src/vision/prompt");
  const { ChatTemplate } = await import("../src/chat-template");
  const { loadTokenizer } = await import("../src/tokenizer");
  const { generate } = await import("../src/generate");

  const config = await loadModelConfig(SNAPSHOT_E4B);
  const weights = await Weights.open(SNAPSHOT_E4B);
  const model = new Gemma4Model(weights, config);
  const sigCfg = parseSiglipConfig(config.raw.vision_config as Record<string, unknown>);
  const tower = SiglipVisionTower.load(SNAPSHOT_E4B, sigCfg, model.embedScale);
  const tokenizer = await loadTokenizer(SNAPSHOT_E4B);
  const template = await ChatTemplate.load(SNAPSHOT_E4B);
  const imageBytes = new Uint8Array(
    await Bun.file("tests/fixtures/grad-768.png").arrayBuffer(),
  );
  const tokenIds = { imageTokenId: 258880, boiTokenId: 255999, eoiTokenId: 258882 };

  test("preprocessing matches (soft tokens, no resize)", async () => {
    const p = await tower.preprocess(imageBytes);
    expect(p.softTokens).toBe(golden.soft_tokens[0]!);
  });

  test("prompt ids and greedy generation match oracle", async () => {
    const vp = await buildVisionPrompt(
      model, tower, tokenizer, template,
      [{
        role: "user",
        content: [
          { type: "image" as const, data: Buffer.from(imageBytes).toString("base64") },
          { type: "text" as const, text: "Describe this image in one short sentence." },
        ],
      }] as never,
      [imageBytes],
      tokenIds,
    );
    // spliced prompt ids are build-independent → bit-exact
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

    // greedy prefix matches the oracle (tail diverges via the SDPA kernel —
    // see src/vision/siglip.ts header)
    expect(out.slice(0, GREEDY_PREFIX)).toEqual(golden.greedy_ids.slice(0, GREEDY_PREFIX));
    // and the description is grounded in the gradient image (end-to-end vision)
    const text = tokenizer.decode(out, true).toLowerCase();
    expect(text).toMatch(/gradient|blue|purple|pink|color/);
  }, 300_000);

  // The DEFAULT `mlx-bun serve` config: optiq's mixed-precision quantized-KV
  // (L2) path. Vision prefill falls back to the monolith (bidir mask), then
  // decode runs over the quantized cache. Verify it works end-to-end (no crash,
  // grounded) — the kv-quant path differs from L1's bf16 decode by design, so
  // we don't assert it against the bf16 golden, just that vision is live on it.
  test("vision works on the optiq quantized-KV (L2) path", async () => {
    const config2 = await loadModelConfig(SNAPSHOT_E4B);
    const vp = await buildVisionPrompt(
      model, tower, tokenizer, template,
      [{
        role: "user",
        content: [
          { type: "image" as const, data: Buffer.from(imageBytes).toString("base64") },
          { type: "text" as const, text: "Describe this image in one short sentence." },
        ],
      }] as never,
      [imageBytes], tokenIds,
    );
    const gen = generate(model, vp.ids, {
      maxTokens: 16, temperature: 0,
      promptEmbeddings: vp.embeddings, imageMask: vp.imageMask,
      kvConfig: config2.kvQuant ?? undefined, quantizedKvStart: 0,
    });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);
    vp.embeddings.dispose();
    vp.imageMask.dispose();
    expect(config2.kvQuant?.length).toBeGreaterThan(0); // e4b ships mixed-precision kv_config
    expect(out.length).toBeGreaterThan(0);
    const text = tokenizer.decode(out, true).toLowerCase();
    expect(text).toMatch(/gradient|blue|purple|pink|color/);
  }, 300_000);
});
