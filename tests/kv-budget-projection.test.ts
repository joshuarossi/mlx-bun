import { describe, expect, test } from "bun:test";
import type { KvQuantSpec, ModelConfig } from "../src/config";
import { kvBytesAt } from "../src/fit";
import { batchRowKvBytes } from "../src/serve/kv-budget";

const config = {
  text: {
    numHiddenLayers: 4,
    layerTypes: [
      "sliding_attention",
      "full_attention",
      "sliding_attention",
      "full_attention",
    ],
    numKeyValueHeads: 2,
    headDim: 64,
    numGlobalKeyValueHeads: 1,
    globalHeadDim: 128,
    slidingWindow: 128,
    maxPositionEmbeddings: 4096,
  },
} as unknown as ModelConfig;

describe("batch KV budget projection", () => {
  const promptTokens = 80;
  const maxTokens = 48;
  const totalTokens = promptTokens + maxTokens;

  test("matches bf16 admission when no per-layer scheme is active", () => {
    expect(batchRowKvBytes(config, promptTokens, maxTokens)).toBe(
      kvBytesAt(config, totalTokens),
    );
  });

  test("matches admission for the active per-layer quantization scheme", () => {
    const kvConfig: KvQuantSpec[] = [
      { layerIdx: 1, bits: 4, groupSize: 64 },
      { layerIdx: 3, bits: 8, groupSize: 64 },
    ];
    const projected = batchRowKvBytes(config, promptTokens, maxTokens, kvConfig);

    expect(projected).toBe(kvBytesAt(config, totalTokens, { kvConfig }));
    expect(projected).toBeLessThan(kvBytesAt(config, totalTokens));
  });
});
