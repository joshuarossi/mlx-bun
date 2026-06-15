// HLG cliff resolver. The coarse maps jumped OVER the steepest features —
// target_gap's 8→12 cliff (clean→~27% junk in a span of 4) and W's lower edge at
// high A (the channel-closing). This steps through those transitions at unit
// resolution and reports the junk% GRADIENT (mean junk + break-rate over K seeds),
// so the cliff shape is visible and its steepness is comparable across models.
// Rails (tg 20→50, A interior) are dropped — they're established flat.
//
//   bun scripts/hlg-cliff.ts --model gemma-4-12B-it-OptiQ-4bit
//
// Reports, per fine step: mean junk%, max junk%, and break-rate (seeds ≥ 1% junk).

import { writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import type { HlgConfig } from "../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const CANARY = "In one sentence, what causes the seasons on Earth?";
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Key = keyof typeof BASE;
const THRESH = 0.01, K = 5;

// the two steep features, stepped at unit resolution across the transition.
const CLIFFS: { name: string; key: Key; over: Partial<typeof BASE>; values: number[] }[] = [
  { name: "target_gap cliff (base: A=0.35, s_m=0.7, W=6)", key: "targetGap", over: {}, values: [7, 8, 9, 10, 11, 12, 13] },
  { name: "W lower edge @ high A (A=100, channel-closing)", key: "window", over: { shoulderA: 100 }, values: [3, 4, 5, 6, 7, 8, 9, 10] },
];

function junkRatio(s: string): number {
  const L = s.match(/\p{L}/gu) ?? [];
  return L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0;
}
function hlgFor(over: Partial<typeof BASE>): HlgConfig {
  const c = { ...BASE, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
}
async function gen(tm: TaskModel, hlg: HlgConfig, seed: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) { try { return await generateText(tm, CANARY, { maxTokens: 40, sampler: { temperature: 1, seed, hlg } }); } catch { /* retry */ } }
  return "⟨fail⟩";
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const tm = await loadTaskModel(query);
  console.log(`# HLG cliff resolver — model "${query}"  (canary junk gradient, K=${K} seeds/step)`);
  console.log(`# base ${JSON.stringify(BASE)} ; unit steps through the steep features, rails dropped.\n`);

  const out: Record<string, unknown>[] = [];
  for (const cl of CLIFFS) {
    console.log(`\n=== ${cl.name} ===`);
    console.log(`  ${cl.key.padEnd(10)} meanjunk   maxjunk   break-rate   bar`);
    for (const v of cl.values) {
      const hlg = hlgFor({ ...cl.over, [cl.key]: v });
      const junks: number[] = [];
      for (let i = 0; i < K; i++) junks.push(junkRatio(await gen(tm, hlg, 7 + i)));
      const mean = junks.reduce((a, b) => a + b, 0) / K;
      const max = Math.max(...junks);
      const broke = junks.filter((j) => j >= THRESH).length;
      const bar = "█".repeat(Math.round(mean * 40));
      console.log(`  ${String(v).padStart(8)}    ${(mean * 100).toFixed(0).padStart(3)}%     ${(max * 100).toFixed(0).padStart(3)}%      ${broke}/${K}       ${bar}`);
      out.push({ cliff: cl.name, key: cl.key, value: v, over: cl.over, meanJunk: mean, maxJunk: max, breakRate: broke / K });
    }
  }
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-cliff.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, base: BASE, cliffs: CLIFFS, grid: out }, null, 2));
  console.log(`\n(done — ${out.length} steps; results → ${outPath})`);
}

await main();
