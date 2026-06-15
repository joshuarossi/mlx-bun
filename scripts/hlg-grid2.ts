// Fine 2-D COHERENCE grids at high K — mixing variables to see how the cliffs
// bend when a second knob moves. Cell = mean canary junk% over K seeds (default 20).
//   Plane 1  target_gap RAMP × s_m   — does the coupling hub bend the ramp?
//   Plane 2  W sharp EDGE × A        — does the channel-close position move with A?
//
//   bun scripts/hlg-grid2.ts --model gemma-4-e4b-it-OptiQ-4bit [--k 20]

import { writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import type { HlgConfig } from "../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const K = Number(opt("k", "20"));

const CANARY = "In one sentence, what causes the seasons on Earth?";
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Key = keyof typeof BASE;

const PLANES: { name: string; yKey: Key; yVals: number[]; xKey: Key; xVals: number[] }[] = [
  { name: "target_gap ramp × s_m  (cliff × coupling hub)", yKey: "sM", yVals: [0.2, 0.7, 2, 4], xKey: "targetGap", xVals: [7, 8, 9, 10, 11, 12] },
  { name: "W sharp edge × A  (does the channel-close move with A?)", yKey: "shoulderA", yVals: [1, 10, 100], xKey: "window", xVals: [3, 4, 5, 6, 7, 8, 9, 10] },
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
  console.log(`# HLG fine 2-D coherence grids — model "${query}"  (cell = mean canary junk%, K=${K} seeds)`);
  console.log(`# base ${JSON.stringify(BASE)} ; fine steps through the cliffs, second knob varied per row.\n`);

  const out: Record<string, unknown>[] = [];
  for (const pl of PLANES) {
    console.log(`\n=== ${pl.name} ===`);
    console.log(`${pl.yKey}\\${pl.xKey}`.padEnd(10) + pl.xVals.map((v) => String(v).padStart(6)).join(""));
    for (const yv of pl.yVals) {
      let row = String(yv).padEnd(10);
      for (const xv of pl.xVals) {
        const hlg = hlgFor({ [pl.yKey]: yv, [pl.xKey]: xv });
        let sum = 0;
        for (let i = 0; i < K; i++) sum += junkRatio(await gen(tm, hlg, 7 + i));
        const mean = sum / K;
        row += `${(mean * 100).toFixed(0).padStart(5)}%`;
        out.push({ plane: pl.name, [pl.yKey]: yv, [pl.xKey]: xv, meanJunk: mean });
      }
      console.log(row);
    }
  }
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-grid2.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, k: K, base: BASE, planes: PLANES, grid: out }, null, 2));
  console.log(`\n(done — ${out.length} cells; results → ${outPath})`);
}

await main();
