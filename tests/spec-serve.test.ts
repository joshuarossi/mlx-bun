// GATED: serve-time two-model speculative decoding (src/spec/serve-loop.ts +
// src/spec/two-model.ts — `serve --draft-model`, integration-plan Phase B).
//
//   MLX_BUN_TEST_SPEC_SERVE=1 bun test tests/spec-serve.test.ts
//
// Pair: Llama-3.2-3B-Instruct-4bit (target) + Llama-3.2-1B-Instruct-4bit
// (draft) — same tokenizer family, both UniversalDense (L1-verified archs).
//
// Gates:
//  1. L1 spec-vs-spec: token-for-token vs mlx-lm's speculative path on the
//     SAME pair (scripts/oracle-spec-two-model.py through the oracle venv,
//     when present — skipped cleanly on machines without it).
//  2. Spec output must be a sane generation: exact-match acceptance means
//     greedy spec reproduces the target's own greedy choices (modulo the
//     documented batched-verify-head knife-edges) — gated as long-prefix
//     agreement vs our non-spec generate(), same pattern as
//     tests/spec-decode.test.ts.
//  3. Structural: acceptance > 0 (the pair drafts usefully), maxTokens
//     truncation exact, onToken=false halts mid-burst, telemetry sums add up.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_SPEC_SERVE === "1";
const snap = (repo: string): string | null => {
  const base = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--${repo}/snapshots`;
  try {
    const { readdirSync } = require("node:fs") as typeof import("node:fs");
    for (const s of readdirSync(base))
      if (existsSync(`${base}/${s}/config.json`) && existsSync(`${base}/${s}/model.safetensors`))
        return `${base}/${s}`;
  } catch { /* not downloaded */ }
  return null;
};
const TARGET = snap("Llama-3.2-3B-Instruct-4bit");
const DRAFT = snap("Llama-3.2-1B-Instruct-4bit");
const ORACLE_PY = "/Users/joshrossi/Code/mlx-lm/.venv/bin/python";

describe.skipIf(!optIn || !TARGET || !DRAFT)("serve --draft-model (two-model spec, Llama 3B+1B)", () => {
  const PROMPT = "Briefly explain why the sky is blue.";

  const setup = async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { TwoModelProvider } = await import("../src/spec/two-model");
    const config = await loadModelConfig(TARGET!);
    const weights = await Weights.open(TARGET!);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(TARGET!);
    const provider = await TwoModelProvider.load(DRAFT!, config.text.vocabSize);
    return { model, weights, tok, provider, config };
  };

  test("L1 + structure: spec stream matches mlx-lm spec; telemetry sane; truncation exact", async () => {
    const { model, weights, tok, provider } = await setup();
    const { specServeRun } = await import("../src/spec/serve-loop");
    try {
      const ids = tok.encode(PROMPT);
      const MAX = 48;

      const got: number[] = [];
      const st = await specServeRun(model, provider, 3, ids, { maxTokens: MAX, temperature: 0 }, (t) => {
        got.push(t);
      });
      expect(got.length).toBe(st.generatedTokens);
      expect(st.generatedTokens).toBeGreaterThan(0);
      expect(st.generatedTokens).toBeLessThanOrEqual(MAX);
      const spec = st.spec!;
      expect(spec.drafted).toBeGreaterThan(0);
      expect(spec.accepted).toBeGreaterThan(0); // 1B usefully drafts 3B
      expect(spec.accepted).toBeLessThanOrEqual(spec.drafted);
      // every accepted draft saves a target call: calls = prefill + rounds
      expect(spec.targetCalls).toBeLessThan(1 + st.generatedTokens);
      console.log(
        `[spec-serve] gen=${st.generatedTokens} drafted=${spec.drafted} accepted=${spec.accepted} ` +
        `targetCalls=${spec.targetCalls} acceptance=${(spec.accepted / spec.drafted * 100).toFixed(0)}%`,
      );

      // determinism: an identical rerun reproduces the stream exactly
      const got2: number[] = [];
      await specServeRun(model, provider, 3, ids, { maxTokens: MAX, temperature: 0 }, (t) => {
        got2.push(t);
      });
      expect(got2).toEqual(got);

      // L1 oracle (spec-vs-spec) when the venv exists on this machine
      if (existsSync(ORACLE_PY)) {
        const proc = Bun.spawnSync(
          [ORACLE_PY, "scripts/oracle-spec-two-model.py", TARGET!, DRAFT!, "3", String(MAX), JSON.stringify(ids)],
          { cwd: `${import.meta.dir}/..`, env: { ...process.env, HF_HUB_DISABLE_XET: "1" } },
        );
        const line = proc.stdout.toString().trim().split("\n").at(-1)!;
        const oracle = JSON.parse(line).tokens as number[];
        expect(got).toEqual(oracle);
        console.log(`[spec-serve] L1 oracle match: ${got.length} tokens token-for-token`);
      } else {
        console.log("[spec-serve] oracle venv absent — L1 gate skipped on this machine");
      }

      // truncation: a tiny cap emits exactly that many tokens
      const short: number[] = [];
      const stShort = await specServeRun(model, provider, 3, ids, { maxTokens: 5, temperature: 0 }, (t) => {
        short.push(t);
      });
      expect(short.length).toBe(5);
      expect(stShort.generatedTokens).toBe(5);
      expect(short).toEqual(got.slice(0, 5)); // same greedy stream, cut

      // onToken=false halts mid-burst
      const halted: number[] = [];
      const stHalt = await specServeRun(model, provider, 3, ids, { maxTokens: MAX, temperature: 0 }, (t) => {
        halted.push(t);
        return halted.length < 7 ? undefined : false;
      });
      expect(halted.length).toBe(7);
      expect(stHalt.generatedTokens).toBe(7);
    } finally {
      provider.dispose();
      weights.dispose();
    }
  }, 600_000);

  test("long-prefix agreement vs non-spec generate()", async () => {
    const { model, weights, tok, provider } = await setup();
    const { specServeRun } = await import("../src/spec/serve-loop");
    const { generate } = await import("../src/generate");
    try {
      const ids = tok.encode(PROMPT);
      const MAX = 48;
      const spec: number[] = [];
      await specServeRun(model, provider, 3, ids, { maxTokens: MAX, temperature: 0 }, (t) => {
        spec.push(t);
      });
      const plain: number[] = [];
      const caches = model.makeCache();
      try {
        const gen = generate(model, ids, { maxTokens: MAX, temperature: 0, cache: caches });
        for await (const t of gen) plain.push(t.token);
      } finally {
        for (const c of caches) c.dispose();
      }
      // Spec legitimately diverges from stock decode at bf16 knife-edges
      // (batched verify lm-head — see src/spec/generate.ts header). The gate
      // is a long shared prefix: a rollback/trim bug corrupts within a few
      // tokens of the first rejection, which shows up as an early split.
      let common = 0;
      while (common < Math.min(spec.length, plain.length) && spec[common] === plain[common]) common++;
      console.log(`[spec-serve] shared prefix with non-spec: ${common}/${Math.min(spec.length, plain.length)}`);
      expect(common).toBeGreaterThanOrEqual(Math.min(16, Math.min(spec.length, plain.length)));
    } finally {
      provider.dispose();
      weights.dispose();
    }
  }, 600_000);
});
