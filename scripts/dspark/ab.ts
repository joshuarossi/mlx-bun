#!/usr/bin/env bun
// Phase 1c (docs/design/speculative-decoding.md): the drafter acceptance
// A/B — THE gate for every drafter-quantization experiment (Phase 1d runs
// 4-bit-vs-bf16 through this; Phase 5 reuses it unchanged for TurboQuant).
//
//   bun scripts/dspark.ts ab --target <registry-id-or-dir> \
//     --drafter-a <dir> --drafter-b <dir> \
//     [--num-draft-tokens N] [--max-tokens 64] [--n-prompts 32] \
//     [--prompts <txt: one per line>] [--max-drop 3] [--json <out.json>]
//
// Same target, same prompt set, temp 0; drafter A then drafter B (arms run
// sequentially so only one drafter's weights are resident at a time).
// Reports per-position acceptance, overall acceptance, τ, tok/s, and the
// paired Phase-1d verdict (acceptance drop ≤ max-drop pts AND wall-clock
// strictly improves). Paired per-prompt deltas survive machine load; the
// FINAL pre/post pair still belongs on a clean machine (house rule).
//
// GPU run — Josh's shell. The stats/verdict math is model-free and
// unit-tested (src/spec/dspark/ab-stats.ts, tests/using/dspark-ab-stats.test.ts).

import { Registry } from "../../src/registry";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { ChatTemplate } from "../../src/chat-template";
import { detectDraftKind } from "../../src/server";
import { specServeRun } from "../../src/spec/serve-loop";
import type { DraftProvider } from "../../src/spec/source";
import { clearCache } from "../../src/mlx/ffi";
import {
  pairedVerdict, renderReport, type AbPromptResult,
} from "../../src/spec/dspark/ab-stats";

const arg = (n: string, d: string | null = null): string | null => {
  const i = process.argv.indexOf(`--${n}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : d;
};
const TARGET = arg("target");
const DRAFTER_A = arg("drafter-a");
const DRAFTER_B = arg("drafter-b");
if (!TARGET || !DRAFTER_A || !DRAFTER_B) {
  console.error(
    "usage: bun scripts/dspark.ts ab --target <id-or-dir> --drafter-a <dir> --drafter-b <dir>\n" +
    "  [--num-draft-tokens N] [--max-tokens 64] [--n-prompts 32] [--prompts <file>] [--max-drop 3] [--json <out>]",
  );
  process.exit(2);
}
const MAX_TOKENS = parseInt(arg("max-tokens", "64")!, 10);
const N_PROMPTS = parseInt(arg("n-prompts", "32")!, 10);
const MAX_DROP = parseFloat(arg("max-drop", "3")!);
const JSON_OUT = arg("json");

// Deterministic default prompt set — a small on-distribution chat mix
// (instructions, QA, code, math, writing) in the spirit of the optiq
// 6-domain calibration mix; ≥32 per the 1c spec. --prompts overrides.
const DEFAULT_PROMPTS = [
  "Summarize how speculative decoding works in two sentences.",
  "What is 17 times 23? Show your reasoning briefly.",
  "Write a Python function that reverses a linked list.",
  "Name three primary colors and one thing each is associated with.",
  "Explain the difference between a process and a thread.",
  "Translate to French: 'The weather is beautiful today.'",
  "Write a haiku about mountains.",
  "What causes tides on Earth?",
  "Give me a one-paragraph plot for a mystery novel set in Lisbon.",
  "How do I revert the last git commit but keep the changes staged?",
  "List five capital cities in South America.",
  "What is the time complexity of binary search and why?",
  "Draft a polite email declining a meeting invitation.",
  "Explain recursion to a ten-year-old.",
  "What's the difference between TCP and UDP?",
  "Write a SQL query that finds duplicate emails in a users table.",
  "Why is the sky blue?",
  "Suggest three names for a coffee shop near a university.",
  "What does the Big-O notation O(n log n) mean?",
  "Convert 98.6 degrees Fahrenheit to Celsius.",
  "Write a short limerick about a cat who codes.",
  "What are the main differences between HTTP/1.1 and HTTP/2?",
  "Give a step-by-step plan to learn the guitar in three months.",
  "What is photosynthesis? Answer in one sentence.",
  "Write a JavaScript one-liner that removes falsy values from an array.",
  "Explain what a hash map is and when to use one.",
  "What year did the Berlin Wall fall, and why was it significant?",
  "Describe the taste of fresh bread to someone who has never eaten it.",
  "How does a refrigerator keep food cold?",
  "Write a regex that matches ISO-8601 dates (YYYY-MM-DD).",
  "What are two pros and two cons of remote work?",
  "Explain the birthday paradox briefly.",
];

async function loadPrompts(): Promise<string[]> {
  const file = arg("prompts");
  const all = file
    ? (await Bun.file(file).text()).split("\n").map((l) => l.trim()).filter(Boolean)
    : DEFAULT_PROMPTS;
  if (all.length < N_PROMPTS)
    console.warn(`[ab] only ${all.length} prompts available (asked for ${N_PROMPTS})`);
  return all.slice(0, N_PROMPTS);
}

async function loadProvider(dir: string): Promise<{ provider: DraftProvider; gamma: number | null }> {
  const kind = await detectDraftKind(dir);
  if (kind === "deepspec") {
    const { DeepspecProvider } = await import("../../src/spec/deepspec-source");
    const p = await DeepspecProvider.load(dir);
    return { provider: p, gamma: p.gamma };
  }
  if (kind === "dspark") {
    const { DflashProvider } = await import("../../src/spec/dflash-source");
    const p = await DflashProvider.load(dir);
    return { provider: p, gamma: p.gamma };
  }
  throw new Error(
    `dspark-drafter-ab: drafter kind "${kind}" (${dir}) not supported here — ` +
    `this harness A/Bs dir-loadable KV-borrowing drafters (deepspec/dspark)`,
  );
}

// ---- target (loaded ONCE, shared by both arms) ----------------------------
const targetDir = new Registry().resolve(TARGET).path;
console.log(`[ab] target  : ${TARGET} (${targetDir})`);
const config = await loadModelConfig(targetDir);
const weights = await Weights.open(targetDir);
const model = createModel(weights, config);
const tok = await loadTokenizer(targetDir);
// enable_thinking pinned OFF explicitly — the cross-stack prompt-drift
// hazard (CLAUDE.md: TokenizerWrapper injects it by default upstream).
const template = await ChatTemplate.load(targetDir);
const prompts = await loadPrompts();
console.log(`[ab] prompts : ${prompts.length}, temp 0, max ${MAX_TOKENS} tok`);

function encodePrompt(p: string): number[] {
  const rendered = template.render([{ role: "user", content: p }], {
    addGenerationPrompt: true,
    enableThinking: false,
  });
  return tok.encode(rendered);
}

async function runArm(label: string, drafterDir: string): Promise<AbPromptResult[]> {
  const { provider, gamma } = await loadProvider(drafterDir);
  const n = parseInt(arg("num-draft-tokens", String(gamma ?? 3))!, 10);
  console.log(`\n[ab] arm ${label}: ${drafterDir} (γ=${n})`);
  const results: AbPromptResult[] = [];
  try {
    for (let i = 0; i < prompts.length; i++) {
      const ids = encodePrompt(prompts[i]!);
      const t0 = performance.now();
      const stats = await specServeRun(
        model, provider, n, ids,
        { maxTokens: MAX_TOKENS, temperature: 0, eosTokenIds: config.eosTokenIds },
        () => {},
      );
      const wallMs = performance.now() - t0;
      const s = stats.spec!;
      results.push({
        prompt: prompts[i]!,
        generatedTokens: stats.generatedTokens,
        drafted: s.drafted,
        accepted: s.accepted,
        targetCalls: s.targetCalls,
        wallMs,
        draftedByPos: s.draftedByPos ?? [],
        acceptedByPos: s.acceptedByPos ?? [],
      });
      const acc = s.drafted > 0 ? ((s.accepted / s.drafted) * 100).toFixed(0) : "–";
      process.stdout.write(`  [${i + 1}/${prompts.length}] ${stats.generatedTokens}tok acc=${acc}% ${(wallMs / 1000).toFixed(1)}s\n`);
      clearCache();
    }
  } finally {
    provider.dispose();
    clearCache();
  }
  return results;
}

const resultsA = await runArm("A", DRAFTER_A);
const resultsB = await runArm("B", DRAFTER_B);

const v = pairedVerdict(resultsA, resultsB, { maxDropPts: MAX_DROP });
console.log(`\n=== drafter A/B (target ${TARGET}, ${prompts.length} prompts, temp 0) ===`);
console.log(renderReport(DRAFTER_A!, DRAFTER_B!, v));

if (JSON_OUT) {
  await Bun.write(JSON_OUT, JSON.stringify({
    target: TARGET, drafterA: DRAFTER_A, drafterB: DRAFTER_B,
    maxTokens: MAX_TOKENS, maxDropPts: MAX_DROP,
    prompts, resultsA, resultsB, verdict: v,
  }, null, 2));
  console.log(`[ab] full results → ${JSON_OUT}`);
}

process.exit(v.pass ? 0 : 1);
