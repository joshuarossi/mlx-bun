import { describe, expect, test } from "bun:test";
import type { KvQuantSpec, ModelConfig } from "../../src/config";
import { kvBytesAt } from "../../src/fit";
import { KvScheme, resolveKvScheme } from "../../src/kv-scheme";
import { batchRowKvBytes } from "../../src/serve/kv-budget";

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
  test("storage summary excludes recurrent state from every attention codec", () => {
    const hybrid = { ...config, text: { ...config.text, numHiddenLayers: 64,
      layerTypes: Array.from({ length: 64 }, (_, i) => i % 4 === 3 ? "full_attention" : "linear_attention") } };
    for (const [scheme, layers] of [
      [resolveKvScheme({}), { bf16: 16 }],
      [resolveKvScheme({ override: 4 }), { kv4: 16 }],
      [resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 } }), { "turbo-k8v3": 16 }],
      [resolveKvScheme({ override: "config", config: Array.from({ length: 64 }, (_, layerIdx) =>
        ({ layerIdx, bits: 8, groupSize: 64 })) }), { kv8: 16 }],
    ] as const) {
      expect(scheme.describe(hybrid)).toEqual({ mode: scheme.label, layers,
        attention: { global: 16, sliding_window: 0 }, recurrent_layers: 48 });
    }
  });

  test("storage summary keeps sliding affine layers and unconfigured bf16 attention", () => {
    expect(resolveKvScheme({ override: 4 }).describe(config).layers).toEqual({ kv4: 4 });
    expect(resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 } }).describe(config)).toEqual({
      mode: "turbo k8v3", layers: { bf16: 2, "turbo-k8v3": 2 },
      attention: { global: 2, sliding_window: 2 }, recurrent_layers: 0,
    });
    expect(resolveKvScheme({ override: "config", config: [
      { layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 3, bits: 8, groupSize: 64 },
    ] }).describe(config).layers).toEqual({ kv4: 1, bf16: 2, kv8: 1 });
    expect(resolveKvScheme({}).describe({ ...config, text: { ...config.text, layerTypes: [] } })
      .attention).toEqual({ global: 4, sliding_window: 0 });
  });

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
    const scheme = resolveKvScheme({ override: "config", config: kvConfig });
    const projected = batchRowKvBytes(config, promptTokens, maxTokens, scheme);

    expect(projected).toBe(scheme.bytesAt(config, totalTokens));
    expect(projected).toBe(kvBytesAt(config, totalTokens, { kvConfig }));
    expect(projected).toBeLessThan(kvBytesAt(config, totalTokens));
  });

  test("one resolved value owns options, labels, keys, and batchability", () => {
    const configScheme = resolveKvScheme({
      override: "config",
      config: [{ layerIdx: 0, bits: 4, groupSize: 64 }],
    });
    expect(configScheme.kind).toBe("affine-config");
    expect(configScheme.cacheKey).toBe("config");
    expect(configScheme.label).toBe("mixed (kv_config.json)");
    expect(configScheme.batchable(config)).toBe(false);
    expect(configScheme.batchable(config, () => true)).toBe(true);

    const uniform = resolveKvScheme({ override: 8 });
    expect(uniform.options).toEqual({ kvBits: 8, quantizedKvStart: 0 });
    expect(uniform.batchable(config)).toBe(false);
    expect(uniform.batchable(config, () => true)).toBe(true);
    expect(uniform.batchable(config, () => false)).toBe(false);
    expect(new KvScheme("affine-uniform", { kvBits: 8 }).batchable(config, () => true)).toBe(false);
    expect(new KvScheme("affine-config", {
      kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], quantizedKvStart: 100,
    }).batchable(config, () => true)).toBe(false);
  });

  test("resolved schemes do not retain mutable caller-owned configuration", () => {
    const entry: KvQuantSpec = { layerIdx: 1, bits: 4, groupSize: 64 };
    const kvConfig = [entry];
    const scheme = resolveKvScheme({ override: "config", config: kvConfig });
    const projected = scheme.bytesAt(config, totalTokens);

    entry.bits = 8;
    kvConfig.push({ layerIdx: 3, bits: 8, groupSize: 64 });

    expect(scheme.bytesAt(config, totalTokens)).toBe(projected);
    expect(scheme.options.kvConfig).toEqual([
      { layerIdx: 1, bits: 4, groupSize: 64 },
    ]);
    expect(Object.isFrozen(scheme.options.kvConfig)).toBe(true);
    expect(Object.isFrozen(scheme.options.kvConfig![0])).toBe(true);
    const generationOptions = scheme.generationOptions;
    generationOptions.kvConfig![0]!.bits = 8;
    expect(scheme.options.kvConfig![0]!.bits).toBe(4);

    const turboQuant = { kBits: 8, vBits: 3 };
    const turbo = resolveKvScheme({ turboQuant });
    turboQuant.vBits = 8;
    expect(turbo.cacheKey).toBe("turbo-k8v3");
    expect(Object.isFrozen(turbo.options.turboQuant)).toBe(true);
  });
});


test("TurboQuant batch conversion requires convertible cache layers", () => {
  const config = { text: { numHiddenLayers: 2, layerTypes: ["full_attention", "linear_attention"] } } as ModelConfig;
  const scheme = resolveKvScheme({ turboQuant: { kBits: 8, vBits: 3 } });
  expect(scheme.batchable(config, layer => layer === 0)).toBe(true);
  expect(scheme.batchable(config, () => false)).toBe(false);
  expect(scheme.batchable(config)).toBe(false);
  expect(new KvScheme("turbo", { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 5 })
    .batchable(config, () => true)).toBe(true);
});

test("delayed TQ persistence keys distinguish the conversion boundary", () => {
  const zero = new KvScheme("turbo", { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 });
  const delayed = new KvScheme("turbo", { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 5 });
  expect(zero.cacheKey).toBe("turbo-k8v3");
  expect(delayed.cacheKey).toBe("turbo-k8v3-start5");
});


test("affine cache identity separates precision schedules and group geometry", () => {
  const immediate = new KvScheme("affine-uniform", { kvBits: 4, quantizedKvStart: 0 });
  const delayed = new KvScheme("affine-uniform", { kvBits: 4, quantizedKvStart: 25 });
  const otherGroup = new KvScheme("affine-uniform", { kvBits: 4, kvGroupSize: 128, quantizedKvStart: 25 });
  expect(immediate.cacheKey).toBe("kv4");
  expect(new Set([immediate.cacheKey, delayed.cacheKey, otherGroup.cacheKey]).size).toBe(3);
  expect(delayed.batchable(config, () => true)).toBe(false);
  expect(delayed.batchable(config, () => true, config.text.numHiddenLayers, { delayedAffine: true })).toBe(true);
});
