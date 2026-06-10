// Quantized KV cache parity (slow tier).
//
// Two-tier bar (see PLAN.md Phase 6 findings): greedy *trajectories* are
// loop-shape-sensitive at bf16 knife-edges (mlx-lm's own pipelined
// stream_generate diverges from its unpipelined loop), so:
//  1. single-forward logits from identical state must be BIT-EXACT
//  2. 48-token greedy trajectories must agree on a long prefix

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const MIN_PREFIX = 24; // of 48 — trajectories are knife-edge-sensitive; logits tests carry exactness

const haveWeights = await snapshotAvailable();
const goldenFile = Bun.file("goldens/kv-quant.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("quantized KV parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    prompt_ids: number[];
    fp16: number[];
    kv8: number[];
    kv4: number[];
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, KVCache, QuantizedKVCache, lastPositionLogits } =
    await import("../src/model/gemma4");
  const { generate } = await import("../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);

  const makeCaches = (kvBits: number | null) => {
    const caches = model.makeCache();
    if (kvBits !== null)
      for (let i = 0; i < caches.length; i++) {
        const c = caches[i]!;
        if (c instanceof KVCache) caches[i] = c.toQuantized(64, kvBits);
      }
    return caches;
  };

  // All three are bit-exact since Phase 10: goldens regenerated against
  // the FUSED serving reference (optiq installs fused_quant_sdpa whenever
  // kv-quant is on; our L>1 dispatch matches), and the rope freqs are now
  // computed on-device like ProportionalRoPE. kv4's old 1.0 tolerance
  // ("strided-vs-contiguous quantized_matmul rounding", Phase 6) no
  // longer reproduces — that divergence was plausibly the host-side f64
  // freqs knife-edge all along (PLAN Phase 10 findings).
  for (const [key, kvBits, tol] of
    [["fp16", null, 0], ["kv8", 8, 0], ["kv4", 4, 0]] as const) {
    test(`${key}: single-forward logits within ${tol === 0 ? "0 (bit-exact)" : tol}`, async () => {
      const caches = makeCaches(kvBits);
      const logits = model.forward(golden.prompt_ids, caches);
      const ours = lastPositionLogits(logits);
      logits.dispose();
      const ref = new Float32Array(
        await Bun.file(`goldens/kvq-logits-${key}.bin`).arrayBuffer(),
      );
      let maxDiff = 0;
      for (let i = 0; i < ref.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
      expect(maxDiff).toBeLessThanOrEqual(tol);
      for (const c of caches) c.dispose();
    }, 240_000);
  }

  for (const [key, kvBits] of [["kv8", 8], ["kv4", 4]] as const) {
    test(`${key}: long greedy prefix agreement + layers quantized`, async () => {
      const caches = model.makeCache();
      const gen = generate(model, golden.prompt_ids, {
        maxTokens: 48, temperature: 0, cache: caches,
        kvBits, kvGroupSize: 64, quantizedKvStart: 0,
      });
      const out: number[] = [];
      for await (const t of gen) out.push(t.token);
      expect(caches.filter((c) => c instanceof QuantizedKVCache)).toHaveLength(8);
      for (const c of caches) c.dispose();

      let prefix = 0;
      const ref = golden[key];
      while (prefix < ref.length && out[prefix] === ref[prefix]) prefix++;
      expect(prefix).toBeGreaterThanOrEqual(MIN_PREFIX);
    }, 240_000);
  }

  test("kv_config.json-driven mixed precision applies per-layer bits", async () => {
    // The 12B's kv_config assigns kv4 g64 to all 8 full-attention layers
    // — config-driven generation must land exactly those bits on exactly
    // those caches (sliding stays bf16 until Phase 9), and the greedy
    // trajectory must agree with the uniform-kv4 golden (numerically the
    // same scheme, reached via the kvConfig per-layer lookup path).
    expect(config.kvQuant).not.toBeNull();
    const fullIdx = new Set(
      config.text.layerTypes
        .map((t, i) => (t === "full_attention" ? i : -1))
        .filter((i) => i >= 0),
    );

    const caches = model.makeCache();
    const gen = generate(model, golden.prompt_ids, {
      maxTokens: 48, temperature: 0, cache: caches,
      kvConfig: config.kvQuant!,
    });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);

    for (let i = 0; i < caches.length; i++) {
      const c = caches[i]!;
      if (fullIdx.has(i)) {
        expect(c).toBeInstanceOf(QuantizedKVCache);
        const want = config.kvQuant!.find((e) => e.layerIdx === i)!;
        const qc = c as InstanceType<typeof QuantizedKVCache>;
        expect(qc.bits).toBe(want.bits);
        expect(qc.groupSize).toBe(want.groupSize);
      } else {
        expect(c).not.toBeInstanceOf(QuantizedKVCache);
      }
    }
    for (const c of caches) c.dispose();

    let prefix = 0;
    const ref = golden.kv4;
    while (prefix < ref.length && out[prefix] === ref[prefix]) prefix++;
    expect(prefix).toBeGreaterThanOrEqual(MIN_PREFIX);
  }, 240_000);
});
