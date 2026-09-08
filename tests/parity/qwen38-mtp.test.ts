// Qwen3.8 native-MTP serve-loop gate (OPT-IN heavy tier — loads the 20 GB
// target + the 0.85 GB Qwen-trained MTP head).
//
//   MLX_BUN_TEST_QWEN38_MTP=1 bun test tests/parity/qwen38-mtp.test.ts
// Explicit target/draft overrides select one compatible artifact pair.
// MLX_BUN_TEST_MTP_REPORT enables warm paired wall-time diagnostics;
// GAMMA (1..4), BLOCKS (1..12), PROMPT and REVERSE use the same TEST_MTP prefix.
//
// Gate: on a tie-free prompt, greedy serve-loop speculation with the native
// MTP head must be TOKEN-IDENTICAL to the non-spec greedy baseline
// (losslessness — the head only proposes; the target verifies every token).
// A passing fixture is observed agreement, not a proof for arbitrary prompts.
// Timings on a machine failing preflight remain diagnostics, including ratios.
// Quotable throughput comes from the quiet scripts/bench-serve.ts benchmark.

import { afterAll, describe, expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { hostname } from "node:os";
import {
  SNAPSHOT_QWEN38 as DEFAULT_TARGET,
  SNAPSHOT_QWEN38_MTP as DEFAULT_DRAFT,
} from "../support/paths";

const optIn = process.env.MLX_BUN_TEST_QWEN38_MTP === "1";
// This gate compares two methods on the same artifact; it does not consume a
// different quant's logit golden. Explicit paths let each Mac test its quants.
const SNAPSHOT_QWEN38 = process.env.MLX_BUN_TEST_MTP_TARGET ?? DEFAULT_TARGET;
const SNAPSHOT_QWEN38_MTP = process.env.MLX_BUN_TEST_MTP_DRAFT ?? DEFAULT_DRAFT;
const gamma = Number(process.env.MLX_BUN_TEST_MTP_GAMMA ?? "2");
if (![1, 2, 3, 4].includes(gamma)) throw new Error("MLX_BUN_TEST_MTP_GAMMA must be 1..4");
const blocks = Number(process.env.MLX_BUN_TEST_MTP_BLOCKS ?? "6");
if (!Number.isInteger(blocks) || blocks < 1 || blocks > 12) throw new Error("MLX_BUN_TEST_MTP_BLOCKS must be 1..12");
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
  const { setMemoryLimit, clearCache, peakMemory } = await import("../../src/mlx/ffi");
  setMemoryLimit(23_000_000_000);
  const { generate } = await import("../../src/generate");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");

  const config = await loadModelConfig(SNAPSHOT_QWEN38);
  const weights = await Weights.open(SNAPSHOT_QWEN38);
  const model = new Qwen35Model(weights, config);
  const provider = await QwenMtpProvider.load(SNAPSHOT_QWEN38_MTP);
  const tok = await loadTokenizer(SNAPSHOT_QWEN38);
  const template = await ChatTemplate.load(SNAPSHOT_QWEN38);
  // Same stop policy as loadRuntimeModel and mlx-lm's tokenizer wrapper.
  if (tok.eosTokenId != null && !config.eosTokenIds.includes(tok.eosTokenId))
    config.eosTokenIds = [...config.eosTokenIds, tok.eosTokenId];
  afterAll(() => { provider.dispose(); weights.dispose(); clearCache(); });

  const MAX_TOKENS = 48;
  // Tie-free, list-like prompt; thinking disabled so the continuation is the
  // deterministic enumeration (same reasoning as spec-serve-assistant).
  const PROMPT = process.env.MLX_BUN_TEST_MTP_PROMPT ?? "List the planets of the solar system in order from the Sun.";
  const ids = (() => {
    const rendered = template.render(
      [{ role: "user", content: PROMPT }],
      { enableThinking: false },
    );
    const t = tok.encode(rendered);
    return t[0] === t[1] && t[0] === tok.bosTokenId ? t.slice(1) : t;
  })();

  test("greedy MTP spec == greedy non-spec (lossless) + paired TPS", async () => {
    const reportPath = process.env.MLX_BUN_TEST_MTP_REPORT;
    if (reportPath) {
      const { checkMachine } = await import("../../src/preflight");
      const machineBefore = checkMachine();
      const run = async (mtp: boolean, limit: number) => {
        const tokens: number[] = [];
        const start = performance.now();
        let firstTokenMs: number | undefined;
        const emit = (token: number) => {
          firstTokenMs ??= performance.now() - start;
          tokens.push(token);
        };
        let stats;
        if (mtp) stats = await specServeRun(model, provider, gamma, ids,
          { maxTokens: limit, temperature: 0 }, emit);
        else {
          const gen = generate(model, ids, { maxTokens: limit, temperature: 0 });
          for await (const token of gen) emit(token.token);
          stats = gen.stats!;
        }
        return { wallMs: performance.now() - start, firstTokenMs, tokens, stats };
      };
      // Compile/warm both execution paths before the measured AB/BA blocks.
      await run(false, 8); await run(true, 8);
      const trials = [];
      for (let block = 0; block < blocks; block++) {
        const reversed = process.env.MLX_BUN_TEST_MTP_REVERSE === "1";
        const order = Boolean(block % 2) !== reversed ? [true, false] : [false, true];
        const results = new Map<boolean, Awaited<ReturnType<typeof run>>>();
        for (const mtp of order) results.set(mtp, await run(mtp, MAX_TOKENS));
        const baseline = results.get(false)!, candidate = results.get(true)!;
        const tokenIdentity = JSON.stringify(candidate.tokens) === JSON.stringify(baseline.tokens);
        trials.push({ block, order, tokenIdentity, baseline, candidate });
      }
      const sha = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
      const command = (args: string[]) => Bun.spawnSync(args, { stdout: "pipe", stderr: "pipe" }).stdout.toString().trim();
      const report = { kind: "native-mtp-diagnostic", httpMeasurement: false, host: hostname(),
        chip: command(["sysctl", "-n", "machdep.cpu.brand_string"]),
        ramBytes: Number(command(["sysctl", "-n", "hw.memsize"])),
        target: resolve(SNAPSHOT_QWEN38), draft: resolve(SNAPSHOT_QWEN38_MTP), gamma,
        variant: process.env.MLX_BUN_TRELLIS_VARIANT ?? "6",
        targetConfigSha256: sha(await Bun.file(`${SNAPSHOT_QWEN38}/config.json`).bytes()),
        draftConfigSha256: sha(await Bun.file(`${SNAPSHOT_QWEN38_MTP}/config.json`).bytes()),
        sourceCommit: command(["git", "rev-parse", "HEAD"]),
        sourceDiffSha256: sha(new TextEncoder().encode(command(["git", "diff", "HEAD", "--", "src"]))),
        kernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-balanced-scatter.ts", import.meta.url)).bytes()),
        sharedKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-m.ts", import.meta.url)).bytes()),
        sharedScatterKernelSha256: sha(await Bun.file(new URL("../../src/model/trellis-shared-scatter.ts", import.meta.url)).bytes()),
        harnessSha256: sha(await Bun.file(import.meta.path).bytes()),
        machineBefore, machineAfter: checkMachine(), peakBytes: peakMemory(), prompt: PROMPT, promptIds: ids,
        eosTokenIds: config.eosTokenIds,
        note: "One repeated short greedy fixture, fresh request cache each arm, one resident target and MTP head in both arms. Wall time includes prefill and completion; no SSE-rate comparison. Diagnostic only; not a held-out or quiet-machine result.", trials };
      mkdirSync(dirname(resolve(reportPath)), { recursive: true });
      await Bun.write(reportPath, JSON.stringify(report, null, 2) + "\n");
      for (const trial of trials) {
        expect(trial.tokenIdentity).toBe(true);
        expect(trial.baseline.tokens.some((t) => config.eosTokenIds.includes(t))).toBe(false);
        expect(trial.candidate.tokens.some((t) => config.eosTokenIds.includes(t))).toBe(false);
        expect(trial.candidate.stats.spec!.drafted).toBeGreaterThan(0);
      }
      return;
    }
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
      model, provider, gamma, ids,
      { maxTokens: MAX_TOKENS, temperature: 0 },
      (token: number) => { out.push(token); },
    );

    expect(out).toEqual(ref); // losslessness — the whole point
    const spec = stats.spec!;
    expect(spec.drafted).toBeGreaterThan(0);
    expect(spec.accepted).toBeGreaterThanOrEqual(0);
    expect(spec.accepted).toBeLessThanOrEqual(spec.drafted);

    // A short native diagnostic. Compare the report's complete wall times;
    // these legacy per-method counters do not share a decode-time definition.
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
