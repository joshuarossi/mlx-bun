// Sampler tests (slow tier — needs weights): seeded reproducibility,
// top-k=1 ≡ greedy, and basic generation API behavior.

import { describe, expect, test } from "bun:test";
import { goldenAt } from "./goldens";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const haveGoldens = await goldenAt("parity.json").exists();

describe.skipIf(!haveWeights || !haveGoldens)("generation + sampling", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenAt("parity.json").json()) as {
    prompt_ids: number[];
    greedy_ids: number[];
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model } = await import("../src/model/gemma4");
  const { generate } = await import("../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);

  async function run(opts: Parameters<typeof generate>[2]): Promise<number[]> {
    const gen = generate(model, golden.prompt_ids, { maxTokens: 16, ...opts });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);
    return out;
  }

  test("temp=0 reproduces the oracle greedy prefix", async () => {
    expect(await run({ temperature: 0 })).toEqual(golden.greedy_ids.slice(0, 16));
  }, 120_000);

  test("topK=1 ≡ greedy regardless of temperature", async () => {
    expect(await run({ temperature: 0.9, topK: 1, seed: 7 }))
      .toEqual(golden.greedy_ids.slice(0, 16));
  }, 120_000);

  test("same seed → same sample; different seed → different", async () => {
    const a = await run({ temperature: 1.2, topP: 0.95, seed: 42 });
    const b = await run({ temperature: 1.2, topP: 0.95, seed: 42 });
    const c = await run({ temperature: 1.2, topP: 0.95, seed: 43 });
    expect(a).toEqual(b);
    expect(a).not.toEqual(c);
  }, 240_000);

  test("pre-warmed cache continuation is token-identical to cold run", async () => {
    const { fromInt32 } = await import("../src/mlx/ops");
    const cold = await run({ temperature: 0 });

    // prefill a prefix manually (as the server's prompt cache would)
    const caches = model.makeCache();
    const k = Math.floor(golden.prompt_ids.length / 2);
    const prefixIds = fromInt32(golden.prompt_ids.slice(0, k), [1, k]);
    const h = model.forwardHidden(prefixIds, caches);
    h.dispose();
    prefixIds.dispose();

    const gen = generate(model, golden.prompt_ids, {
      maxTokens: 16, temperature: 0, cache: caches,
    });
    const warm: number[] = [];
    for await (const t of gen) warm.push(t.token);
    expect(gen.stats!.cachedTokens).toBe(k);
    expect(warm).toEqual(cold);
    for (const c of caches) c.dispose();
  }, 240_000);

  test("repetition penalty changes output and still terminates", async () => {
    const a = await run({ temperature: 0, repetitionPenalty: 1.5 });
    expect(a.length).toBeGreaterThan(0);
    // greedy with penalty should diverge from pure greedy at some point
    expect(a).not.toEqual(golden.greedy_ids.slice(0, 16));
  }, 120_000);
});
