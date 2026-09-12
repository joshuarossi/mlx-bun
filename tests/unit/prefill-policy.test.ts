import { expect, test } from "bun:test";
import type { ModelConfig } from "../../src/config";
import { createRuntimeConfig } from "../../src/runtime-config";
import { sdpaFallbackBytes } from "../../src/kv-scheme";
import { resolveMlxPrefillPolicy } from "../../src/backends/mlx/prefill-policy";

const qwen = () => ({ text: { numHiddenLayers: 64, numAttentionHeads: 24,
  globalHeadDim: 256, headDim: 256, slidingWindow: 0,
  layerTypes: Array.from({ length: 64 }, (_, i) => i % 4 === 3 ? "full_attention" : "linear_attention"),
} }) as ModelConfig;

test("recurrent-attention default bounds long-prefill workspace and keeps short chunks", () => {
  const config = qwen(), policy = resolveMlxPrefillPolicy(config, createRuntimeConfig({}));
  expect(policy.chunkSize(10_398)).toBe(2048);
  expect(policy.chunkSize(78_678)).toBe(256);
  expect(policy.chunkSize(131_072)).toBe(128);
  for (const tokens of [1, 1024, 16_384, 78_678, 131_072, 1_048_576]) {
    const chunk = policy.chunkSize(tokens);
    expect(sdpaFallbackBytes(config, chunk, tokens)).toBeLessThanOrEqual(1024 ** 3);
    if (chunk < 2048) expect(sdpaFallbackBytes(config, chunk * 2, tokens)).toBeGreaterThan(1024 ** 3);
  }
});

test("explicit defaults win and captured model geometry cannot change later", () => {
  const config = qwen(), runtime = createRuntimeConfig({ MLX_BUN_RD_PREFILL_CHUNK: "2048" });
  expect(resolveMlxPrefillPolicy(config, runtime).chunkSize(78_678)).toBe(2048);
  expect(resolveMlxPrefillPolicy(config, runtime, 512).chunkSize(78_678)).toBe(512);
  const bound = resolveMlxPrefillPolicy(config, createRuntimeConfig({}));
  config.text.globalHeadDim = 128;
  config.text.layerTypes.fill("full_attention");
  expect(bound.chunkSize(78_678)).toBe(256);
  expect(resolveMlxPrefillPolicy(config, createRuntimeConfig({})).chunkSize(78_678)).toBe(2048);
});

test("fused attention and nonrecurrent models keep the established default", () => {
  const fused = qwen(); fused.text.globalHeadDim = 128;
  const ordinary = qwen(); ordinary.text.layerTypes.fill("full_attention");
  for (const config of [fused, ordinary])
    expect(resolveMlxPrefillPolicy(config, createRuntimeConfig({})).chunkSize(131_072)).toBe(2048);
});
