import { expect, test } from "bun:test";
import { existsSync } from "node:fs";

const target = Bun.env.MLX_BUN_TEST_NORMALIZED_ARGMAX_MODEL ?? `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`;
const enabled = Bun.env.MLX_BUN_TEST_NORMALIZED_ARGMAX === "1" && existsSync(`${target}/config.json`);

test.skipIf(!enabled)("native model logits preserve normalized greedy IDs at single and concurrent row shapes", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { configureRuntime } = await import("../../src/runtime-config");
  const { normalizedArgmax } = await import("../../src/mlx/normalized-argmax");
  const { toLogprobs } = await import("../../src/sampler");
  const ops = await import("../../src/mlx/ops");
  using resources = new DisposableStack();
  resources.defer(configureRuntime({ MLX_BUN_COMPILED_DECODE: "0" }));
  const weights = await Weights.open(target); resources.defer(() => weights.dispose());
  const model = createModel(weights, await loadModelConfig(target));
  const tok = await loadTokenizer(target);
  const project = model.logitsFromHidden!.bind(model);
  const shapes = new Set<number>();
  let comparisons = 0;
  model.logitsFromHidden = hidden => {
    const logits = project(hidden);
    try {
      using scores = toLogprobs(logits);
      using reference = ops.argmaxAxis(scores, -1);
      using candidate = normalizedArgmax(logits);
      expect(candidate.toIntTokens()).toEqual(reference.toIntTokens());
      shapes.add(logits.shape[0]!); comparisons++;
      return logits;
    } catch (error) { logits.dispose(); throw error; }
  };
  const gateway = new GenerationGateway(model, 8, async () => { throw new Error("unexpected serial execution"); });
  const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false,
    kvQuant: false, turboQuant: false, hasLogitsExtras: false, wantsLogprobs: false, hasDraft: false, hasGrammar: false };
  try {
    for (const width of [1, 4]) await Promise.all(Array.from({ length: width }, async (_, row) => {
      const options = { temperature: 0, maxTokens: 32, eosTokenIds: [] };
      const placement = gateway.place(shape, options);
      expect(placement.execution?.mechanism).toBe("continuous");
      const ids: number[] = [];
      await gateway.run(tok.encode(`Explain how computers work. Example ${row}.`), options,
        id => { ids.push(id); }, undefined, shape, placement);
      expect(ids.length).toBe(32);
    }));
    expect(comparisons).toBeGreaterThanOrEqual(32);
    expect(shapes.has(1)).toBe(true);
    expect(shapes.has(4)).toBe(true);
  } finally { await gateway.close(); }
}, 240_000);
