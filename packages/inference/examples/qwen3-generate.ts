import { loadModelConfig, Weights, loadTokenizer, generate } from "@mlx-bun/inference";
import { Qwen3Model } from "@mlx-bun/inference/models/qwen3";

/** The caller chooses a Qwen3 checkpoint and owns its weights. */
export async function generateText(directory: string, prompt: string, maxTokens = 32) {
  const config = await loadModelConfig(directory);
  const tokenizer = await loadTokenizer(directory);
  const weights = await Weights.open(directory);
  try {
    const graph = new Qwen3Model(weights, config);
    const generation = generate(graph, tokenizer.encode(prompt), {
      maxTokens, temperature: 0, eosTokenIds: config.eosTokenIds,
    });
    const tokens: number[] = [];
    for await (const { token } of generation) tokens.push(token);
    return { text: tokenizer.decode(tokens), tokens, stats: generation.stats };
  } finally {
    weights.dispose();
  }
}

if (import.meta.main) {
  const directory = process.argv[2];
  if (!directory) throw new Error('Usage: bun qwen3-generate.ts <checkpoint-directory> [prompt]');
  console.log(await generateText(directory, process.argv[3] ?? "Hello"));
}
