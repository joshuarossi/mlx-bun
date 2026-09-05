// Qwen3.8 native-MTP serve-loop gate (OPT-IN heavy tier — loads the 20 GB
// target + the 0.85 GB Qwen-trained MTP head).
//
//   MLX_BUN_TEST_QWEN38_MTP=1 bun test tests/qwen38-mtp.test.ts
//
// Gate: on a tie-free prompt, greedy serve-loop speculation with the native
// MTP head must be TOKEN-IDENTICAL to the non-spec greedy baseline
// (losslessness — the head only proposes; the target verifies every token).
// Also logs the paired prefill/decode TPS for both arms — the MTP-on vs
// MTP-off comparison. NOTE on this 24 GB machine the ABSOLUTE numbers are
// swap-garbage (dirty-machine doctrine); the paired ratio is the signal, and
// quotable numbers come from a cleared 32 GB box via scripts/bench-serve.ts all.

import { describe, expect, test } from "bun:test";
import {
  SNAPSHOT_QWEN38 as DEFAULT_TARGET,
  SNAPSHOT_QWEN38_MTP as DEFAULT_DRAFT,
} from "../support/paths";

const optIn = process.env.MLX_BUN_TEST_QWEN38_MTP === "1";
// This gate compares two methods on the same artifact; it does not consume a
// different quant's logit golden. Explicit paths let each Mac test its quants.
const SNAPSHOT_QWEN38 = process.env.MLX_BUN_TEST_MTP_TARGET ?? DEFAULT_TARGET;
const SNAPSHOT_QWEN38_MTP = process.env.MLX_BUN_TEST_MTP_DRAFT ?? DEFAULT_DRAFT;
const have = await Bun.file(`${SNAPSHOT_QWEN38}/config.json`).exists() &&
  await Bun.file(`${SNAPSHOT_QWEN38_MTP}/config.json`).exists();

describe.skipIf(!optIn || !have)("Qwen3.8 native MTP (serve loop)", async () => {
  if (!optIn || !have) return;
  console.log(`MTP compatibility target=${SNAPSHOT_QWEN38} draft=${SNAPSHOT_QWEN38_MTP}`);
  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Qwen35Model } = await import("../../src/model/qwen3_5");
  // Metal's default working-set cap on a 24 GB box (~18.6 GB) is below
  // target+drafter residency (21.2 GB) — the first generate() forward throws
  // a C++ [metal::malloc] exception without this. Same lever the server's
  // --memory-budget uses (server.ts:1980); swap covers the overage (slowly).
  const { setMemoryLimit } = await import("../../src/mlx/ffi");
  setMemoryLimit(23_000_000_000);
  const { generate } = await import("../../src/generate");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");

  const config = await loadModelConfig(SNAPSHOT_QWEN38);
  const model = new Qwen35Model(await Weights.open(SNAPSHOT_QWEN38), config);
  const provider = await QwenMtpProvider.load(SNAPSHOT_QWEN38_MTP);
  const tok = await loadTokenizer(SNAPSHOT_QWEN38);
  const template = await ChatTemplate.load(SNAPSHOT_QWEN38);

  const MAX_TOKENS = 48;
  // Tie-free, list-like prompt; thinking disabled so the continuation is the
  // deterministic enumeration (same reasoning as spec-serve-assistant).
  const PROMPT = "List the planets of the solar system in order from the Sun.";
  const ids = (() => {
    const rendered = template.render(
      [{ role: "user", content: PROMPT }],
      { enableThinking: false },
    );
    const t = tok.encode(rendered);
    return t[0] === t[1] && t[0] === tok.bosTokenId ? t.slice(1) : t;
  })();

  test("greedy MTP spec == greedy non-spec (lossless) + paired TPS", async () => {
    // Arm 1: plain greedy baseline (MTP off).
    const t0 = performance.now();
    const gen = generate(model, ids, { maxTokens: MAX_TOKENS, temperature: 0 });
    const ref: number[] = [];
    let baseFirstTokenAt = 0;
    for await (const t of gen) {
      if (ref.length === 0) baseFirstTokenAt = performance.now();
      ref.push(t.token);
    }
    const baseTotalMs = performance.now() - t0;
    const basePrefillMs = baseFirstTokenAt - t0;
    const baseDecodeMs = baseTotalMs - basePrefillMs;

    // Arm 2: serve-loop speculation with the native MTP head.
    const out: number[] = [];
    const stats = await specServeRun(
      model, provider, 2, ids,
      { maxTokens: MAX_TOKENS, temperature: 0 },
      (token: number) => { out.push(token); },
    );

    expect(out).toEqual(ref); // losslessness — the whole point
    const spec = stats.spec!;
    expect(spec.drafted).toBeGreaterThan(0);
    expect(spec.accepted).toBeGreaterThanOrEqual(0);
    expect(spec.accepted).toBeLessThanOrEqual(spec.drafted);

    // The paired A/B (absolute values are machine-pressure-bound; the ratio
    // and the acceptance rate are the durable signal).
    console.log(
      `[qwen38-mtp A/B] MTP OFF: prefill ${(ids.length / Math.max(basePrefillMs, 1e-6) * 1000).toFixed(1)} tok/s, ` +
      `decode ${(ref.length / Math.max(baseDecodeMs, 1e-6) * 1000).toFixed(2)} tok/s | ` +
      `MTP ON: prefill ${stats.prefillTps.toFixed(1)} tok/s, ` +
      `decode ${stats.decodeTps.toFixed(2)} tok/s | ` +
      `acceptance ${(spec.accepted / Math.max(spec.drafted, 1) * 100).toFixed(0)}% ` +
      `(${spec.accepted}/${spec.drafted}), tokens/forward ` +
      `${(out.length / Math.max(spec.targetCalls - 1, 1)).toFixed(2)}`,
    );
  }, 3_600_000);
});
