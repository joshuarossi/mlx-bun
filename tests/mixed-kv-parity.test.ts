// Per-layer MIXED (kv_config.json) quantized-KV parity vs the DIRECT optiq
// oracle golden (slow tier) — closes the comparison-2 gap: before this,
// mixed-KV was verified ours-fast vs ours-monolith and against the UNIFORM
// kv4 golden; goldens/mixed-kv.json is produced by the optiq-side composition
// itself (scripts/regen.ts mixed-kv: bf16 prefill of ids[:-1] →
// per-layer quantize of the populated caches, rotating included → L=1
// step-0 forward of the last prompt token → stock unfused quantized decode
// — the oracle serve-loop geometry our maybeQuantizeKv + tail-split prefill
// copy, re-anchored 2026-07-07).
//
// Same two-tier bar as kv-quant.test.ts: per-step logits BIT-EXACT
// (teacher-forced down the golden trajectory so knife-edge argmax ties can't
// desynchronize the comparison), greedy trajectory long-prefix.

import { describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { goldenAt } from "./goldens";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const MIN_PREFIX = 24; // of 48 — same knife-edge allowance as kv-quant.test.ts

const haveWeights = await snapshotAvailable();
const goldenFile = goldenAt("mixed-kv.json");
const haveGoldens = await goldenFile.exists();


describe.skipIf(!haveWeights || !haveGoldens)("mixed-KV (kv_config) parity vs optiq golden", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    prompt_ids: number[];
    mixed: number[];
    logit_steps: number;
    layers: number[];
    logit_sha256: string[];
  };

  const { loadModelConfig } = await import("../src/config");
  const { Weights } = await import("../src/weights");
  const { Gemma4Model, lastPositionLogits } = await import("../src/model/gemma4");
  const { generate, maybeQuantizeKv } = await import("../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);
  const kvOpts = { kvConfig: config.kvQuant!, quantizedKvStart: 0 };

  test("per-step logits bit-exact (teacher-forced down the golden path)", async () => {
    expect(config.kvQuant?.length).toBeGreaterThan(0);
    const cache = model.makeCache();
    const maxDiffAt = async (step: number, logits: any) => {
      const ours = lastPositionLogits(logits);
      const bytes = await goldenAt(`mixedkv-logits-step${step}.bin`).arrayBuffer();
      const digest = createHash("sha256").update(new Uint8Array(bytes)).digest("hex");
      const expectedDigest = golden.logit_sha256[step];
      if (!expectedDigest)
        throw new Error(`mixed-KV golden is missing SHA-256 for step ${step}`);
      expect(digest).toBe(expectedDigest);
      const ref = new Float32Array(bytes);
      let maxDiff = 0;
      for (let i = 0; i < ref.length; i++)
        maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
      return maxDiff;
    };

    // Tail-split composition (2026-07-07, mirrors the regen script and the
    // oracle serve loop): bf16 prefill of ids[:-1], convert the populated
    // caches per kv_config, then step-0 logits from an L=1 forward of the
    // last prompt token (its KV lands in the quantized caches).
    const ids = golden.prompt_ids;
    const head = model.forward(ids.slice(0, -1), cache);
    head.dispose();
    maybeQuantizeKv(cache, kvOpts);
    let l = model.forward([ids[ids.length - 1]!], cache);
    expect(await maxDiffAt(0, l)).toBe(0);
    l.dispose();
    // steps 1..3: decode reads the quantized caches (stock unfused L=1)
    for (let step = 1; step < golden.logit_steps; step++) {
      l = model.forward([golden.mixed[step - 1]!], cache);
      expect(await maxDiffAt(step, l)).toBe(0);
      l.dispose();
    }
    for (const c of cache) c.dispose();
  }, 240_000);

  test("48-token greedy long-prefix agreement via generate()", async () => {
    const cache = model.makeCache();
    const gen = generate(model, golden.prompt_ids, {
      maxTokens: 48, temperature: 0, cache, ...kvOpts,
    });
    const out: number[] = [];
    for await (const t of gen) out.push(t.token);
    for (const c of cache) c.dispose();

    let prefix = 0;
    while (prefix < golden.mixed.length && out[prefix] === golden.mixed[prefix]) prefix++;
    expect(prefix).toBeGreaterThanOrEqual(MIN_PREFIX);
  }, 240_000);
});
