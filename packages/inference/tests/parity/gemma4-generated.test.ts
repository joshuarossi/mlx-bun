// Generated Gemma4 graphs against the dedicated graph on real weights. A
// generated specialization (12B, e4b or 26B, dispatched by config fingerprint)
// serves only the artifact's kv_config cache layout and must equal the monolith
// bit for bit there, falling back to the monolith under plain caches. This
// ports `02d723a:tests/parity/generated-parity.test.ts` (12B and e4b cells) to
// every registered fingerprint:
// - createModel selects the generated graph registered for the fingerprint;
// - three uncompiled steps over caches converted to kv_config before the first
//   forward, from a prompt past the sliding window: byte-identical full
//   vocabulary vectors, with at least every decode step on the unrolled path;
// - 24-token greedy trajectories under kv_config (quantized from token 0; stop
//   tokens off, since e4b's first token for this raw prompt is EOS) are
//   identical uncompiled, where every forward is generated, and with compiled
//   decode, whose trace runs the generated layers (12B: exactly the one
//   quantized step the dense segmented closure leaves to it, as in main);
// - under plain bf16 caches the generated graph takes its monolith fallback:
//   identical vectors and no generated forward;
// - two different rows in one forward over kv_config caches equal the monolith's.
// This is within-tree specialization identity, not external-oracle parity; the
// monolith's oracle consumer is gemma4-parity.test.ts.
// Opt in with MLX_BUN_TEST_GENERATED_MODEL=/gemma4/snapshot (an artifact whose
// fingerprint has a generated graph and which ships kv_config.json). Unset
// skips; a blank value or an artifact without kv_config.json fails. No downloads.
import { expect, test } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { releaseAll } from "./real-weight-inputs";

type A = any;
const MODEL = "MLX_BUN_TEST_GENERATED_MODEL";
const STEPS = 3, TOKENS = 24, ROW_TOKENS = 16;

export function optIn(env: Record<string, string | undefined>) {
  const model = env[MODEL];
  if (model === undefined) return null;
  if (!model.trim()) throw new Error(`${MODEL} is blank`);
  assert(existsSync(join(model, "config.json")), `${MODEL}: no config.json in ${model}`);
  assert(existsSync(join(model, "kv_config.json")), `${MODEL}: generated graphs serve the kv_config layout; no kv_config.json in ${model}`);
  const raw = JSON.parse(readFileSync(join(model, "config.json"), "utf8"));
  assert(String(raw.model_type).startsWith("gemma4"), `${MODEL}: not a Gemma4 artifact (${raw.model_type})`);
  return { model };
}

/** Main's prompt lengths: 1100 tokens for the 12B (window 1024), 700 for e4b (512). */
export const promptLength = (window: number) => Math.max(700, window + 76);

const inputs = optIn(Bun.env);

test.skipIf(!inputs)("generated Gemma4 graph equals the monolith under kv_config and falls back under plain caches", async () => {
  const ffi = await import("@mlx-bun/mlx/ffi");
  const ops = await import("@mlx-bun/mlx/ops");
  const { loadModelConfig, Weights, configFingerprint } = await import("@mlx-bun/inference/artifacts");
  const { createModel } = await import("@mlx-bun/inference/models");
  const { Gemma4Model } = await import("@mlx-bun/inference/models/gemma4");
  const { CompiledDecode } = await import("@mlx-bun/inference/models/gemma4/compiled-decode");
  const { generate } = await import("@mlx-bun/inference/generation");
  const { loadTokenizer } = await import("@mlx-bun/inference/input");
  const { unfusedAffineKernels } = await import("../../src/state/affine-attention");
  // The fast-path counters live in each generated module.
  const modules = await Promise.all([import("../../src/models/gemma4/generated/gemma4-12b"),
    import("../../src/models/gemma4/generated/gemma4-e4b"), import("../../src/models/gemma4/generated/gemma4-26b")]);
  const path = inputs!.model;
  const config = await loadModelConfig(path);
  const fingerprint = configFingerprint(config);
  const generated = modules.find(module => module.FINGERPRINT === fingerprint);
  assert(generated, `no generated graph is registered for fingerprint ${fingerprint}`);
  const kvConfig = config.kvQuant;
  assert(kvConfig?.length, "the artifact's kv_config.json did not load");
  const tokenizer = await loadTokenizer(path);
  let message = "Explain the memory hierarchy of a modern computer in detail.";
  const filler = "Context: caches, DRAM, bandwidth, and latency all interact. ";
  const length = promptLength(config.text.slidingWindow);
  while (tokenizer.encode(message).length < length) message = filler + message;
  const prompt = tokenizer.encode(message).slice(0, length);
  const weights = await Weights.open(path);
  let mono: A, gen: A;
  /** The last position's full vector (bytes) and its argmax. */
  const lastVector = (logits: A): { bytes: Buffer; next: number } => {
    const [, L, V] = logits.shape as [number, number, number];
    using last = logits.slice([0, L - 1, 0], [1, L, V]);
    using exact = ops.contiguous(last);
    using arg = ops.argmaxAxis(last, -1);
    return { bytes: Buffer.from(exact.rawBytes()), next: arg.toIntTokens()[0]! };
  };
  try {
    mono = new Gemma4Model(weights, config);
    gen = createModel(weights, config);
    expect(gen).toBeInstanceOf(generated.GeneratedGemma4);
    expect(mono).not.toBeInstanceOf(generated.GeneratedGemma4);

    // 1. Per-step vectors over caches converted before the first forward.
    const restore = configureRuntime({ MLX_BUN_COMPILED_DECODE: "0" });
    try {
      const steps = (model: A) => {
        const caches: A[] = model.makeCache();
        try {
          // The serve scenario: each cache the kv_config names converts before any forward.
          for (let layer = 0; layer < caches.length; layer++) {
            const entry = kvConfig.find(item => item.layerIdx === layer);
            if (entry) caches[layer] = caches[layer].toQuantized(entry.groupSize, entry.bits, unfusedAffineKernels);
          }
          const vectors: Buffer[] = [];
          let tokens = prompt;
          for (let step = 0; step < STEPS; step++) {
            const logits = model.forward(tokens, caches);
            try { const { bytes, next } = lastVector(logits); vectors.push(bytes); tokens = [next]; }
            finally { logits.dispose(); }
          }
          return vectors;
        } finally { releaseAll(caches.map(cache => () => cache.dispose())); ffi.clearCache(); }
      };
      const before = generated.generatedForwardUses;
      const specialized = steps(gen);
      const used = generated.generatedForwardUses - before;
      // At least every decode step; the long first forward may also qualify.
      expect(used).toBeGreaterThanOrEqual(STEPS - 1);
      const dedicated = steps(mono);
      expect(generated.generatedForwardUses - before).toBe(used);
      specialized.forEach((vector, step) => expect({ step, equal: vector.equals(dedicated[step]!) }).toEqual({ step, equal: true }));
    } finally { restore(); }

    // 2. Greedy trajectories under kv_config, uncompiled and compiled.
    for (const compiled of [false, true]) {
      const reset = configureRuntime({ MLX_BUN_COMPILED_DECODE: compiled ? "1" : "0" });
      try {
        const run = async (model: A) => {
          const out: number[] = [];
          // No stop tokens: every trajectory is TOKENS long whatever the artifact's first token (e4b's is EOS here).
          const generation = generate(model, prompt, { maxTokens: TOKENS, temperature: 0, kvConfig, quantizedKvStart: 0, eosTokenIds: [] });
          for await (const token of generation) out.push(token.token);
          ffi.clearCache();
          return out;
        };
        const before = generated.generatedForwardUses;
        const specialized = await run(gen);
        const used = generated.generatedForwardUses - before;
        const dedicated = await run(mono);
        expect(specialized.length).toBe(TOKENS);
        expect({ compiled, specialized }).toEqual({ compiled, specialized: dedicated });
        if (!compiled) expect(used).toBeGreaterThanOrEqual(specialized.length - 1);
        else if (fingerprint === modules[0].FINGERPRINT) expect(used).toBe(1);
        else expect(used).toBeGreaterThanOrEqual(1);
        console.log(`[generated ${fingerprint}] compiled ${compiled}: ${specialized.length} tokens identical, ${used} generated forwards`);
      } finally { reset(); }
    }

    // 3. Plain caches take the monolith fallback.
    const before = generated.generatedForwardUses;
    const plain = (model: A) => {
      const caches: A[] = model.makeCache();
      try {
        const logits = model.forward(prompt.slice(0, 64), caches);
        try { return lastVector(logits).bytes; } finally { logits.dispose(); }
      } finally { releaseAll(caches.map(cache => () => cache.dispose())); }
    };
    expect(plain(gen).equals(plain(mono))).toBe(true);
    expect(generated.generatedForwardUses).toBe(before);

    // 4. Two different rows through one forward over kv_config caches: the batch axis is not
    // assumed to be one (e4b slices its per-layer inputs per layer; row 1 must get its own).
    const rows = (model: A) => {
      const caches: A[] = model.makeCache();
      try {
        for (let layer = 0; layer < caches.length; layer++) {
          const entry = kvConfig.find(item => item.layerIdx === layer);
          if (entry) caches[layer] = caches[layer].toQuantized(entry.groupSize, entry.bits, unfusedAffineKernels);
        }
        const ids = ops.fromInt32([...prompt.slice(0, ROW_TOKENS), ...prompt.slice(-ROW_TOKENS)], [2, ROW_TOKENS]);
        try {
          const hidden = model.forwardHidden(ids, caches);
          try { using exact = ops.contiguous(hidden); return Buffer.from(exact.rawBytes()); } finally { hidden.dispose(); }
        } finally { ids.dispose(); }
      } finally { releaseAll(caches.map(cache => () => cache.dispose())); ffi.clearCache(); }
    };
    const usedBefore = generated.generatedForwardUses;
    const batched = rows(gen);
    expect(generated.generatedForwardUses - usedBefore).toBe(1);
    expect(batched.equals(rows(mono))).toBe(true);
  } finally {
    // Compiled closures borrow weight arrays: release their tapes before the weights.
    try { releaseAll([mono, gen].filter(Boolean).map(model => () => CompiledDecode.for(model).dispose())); }
    finally {
      try { weights.dispose(); }
      finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()).concat([() => ffi.clearCache()])); }
    }
  }
}, 900_000);

// ---- CPU-only validation (no native libraries) ------------------------------------------
test("opt-in: unset skips; blank or incomplete artifacts fail (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [MODEL]: " " })).toThrow("blank");
  expect(() => optIn({ [MODEL]: "/nonexistent-generated-model" })).toThrow("no config.json");
});

test("prompt lengths reproduce main's and pass the window (CPU only)", () => {
  expect(promptLength(1024)).toBe(1100);
  expect(promptLength(512)).toBe(700);
  for (const window of [512, 1024, 4096]) expect(promptLength(window)).toBeGreaterThan(window);
});
