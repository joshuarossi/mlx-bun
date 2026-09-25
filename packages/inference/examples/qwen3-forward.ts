import { loadModelConfig, Weights } from "@mlx-bun/inference/artifacts";
import { Qwen3Model } from "@mlx-bun/inference/models/qwen3";
import { argmaxLastPosition, lastPositionLogits } from "@mlx-bun/inference/scoring";

/** Explicit forward passes: the caller supplies tokens and owns the live cache. */
export async function forwardTokens(directory: string, promptTokens: number[]) {
  const config = await loadModelConfig(directory);
  const weights = await Weights.open(directory);
  try {
    const graph = new Qwen3Model(weights, config);
    const state = graph.makeCache();
    try {
      using prefill = graph.forward(promptTokens, state);
      const token = argmaxLastPosition(prefill);
      using continuation = graph.forward([token], state);
      return { token, nextToken: argmaxLastPosition(continuation),
        logits: lastPositionLogits(continuation), offset: state[0]!.offset };
    } finally {
      for (const cache of state) cache.dispose();
    }
  } finally {
    weights.dispose();
  }
}

if (import.meta.main) {
  const directory = process.argv[2], ids = process.argv[3];
  if (!directory || !ids) throw new Error('Usage: bun qwen3-forward.ts <checkpoint-directory> <token-ids-as-JSON>');
  console.log(await forwardTokens(directory, JSON.parse(ids)));
}
