import { expect, test } from "bun:test";
import { resolveKvScheme } from "../../src/kv-scheme";
import { generationCheckpointKey } from "../../src/serve/checkpoint-identity";
import { snapshotGenerationPolicy } from "../../src/backends/mlx/request-policy";

test("optional server threshold preserves omitted policy and separates checkpoint identities", () => {
  const config = [{ layerIdx: 0, bits: 4, groupSize: 64 }, { layerIdx: 1, bits: 8, groupSize: 64 }];
  const arms = [{ override: 4 }, { override: 8 }, { turboQuant: { kBits: 8, vBits: 3 } },
    { override: "config" as const, config }];
  for (const input of arms) {
    const original = resolveKvScheme(input);
    expect(resolveKvScheme({ ...input, quantizedKvStart: undefined }).generationOptions).toEqual(original.generationOptions);
    const delayed = resolveKvScheme({ ...input, quantizedKvStart: 14 });
    expect(delayed.generationOptions.quantizedKvStart).toBe(14);
    expect(delayed.cacheKey).not.toBe(original.cacheKey);
    expect(generationCheckpointKey([1, 2], delayed.generationOptions)).not.toBe(generationCheckpointKey([1, 2], original.generationOptions));
  }
  for (const quantizedKvStart of [-1, 0.5, NaN, Infinity])
    expect(() => resolveKvScheme({ override: 4, quantizedKvStart })).toThrow("nonnegative integer");
});

test("continuation policy snapshots nested KV recipes before key construction", () => {
  const source = { kvConfig: [{ layerIdx: 0, bits: 4, groupSize: 64 }], quantizedKvStart: 14 };
  const captured = snapshotGenerationPolicy(source);
  const key = generationCheckpointKey([1, 2], captured);
  source.kvConfig[0]!.bits = 8;
  source.quantizedKvStart = 0;
  expect(generationCheckpointKey([1, 2], captured)).toBe(key);
  expect(generationCheckpointKey([1, 2], source)).not.toBe(key);
});
