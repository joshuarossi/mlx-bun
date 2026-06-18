// Edge-texture zoom: pour K=20 resolution into the transition regions only — the
// target_gap ramp, the W channel-close, and the two L_W walls (inversion at γ→0,
// over-sharpen at γ→2.4). Sub-unit steps where the gradient lives, to feel the
// texture of each edge. Reports mean junk%, max, break-rate, and γ for L_W zooms.
//   bun scripts/hlg-edge.ts --model gemma-4-e4b-it-OptiQ-4bit [--k 20]

import { writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import { hlgGammaForLw, type HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const K = Number(opt("k", "20"));

const CANARY = "In one sentence, what causes the seasons on Earth?";
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Key = keyof typeof BASE;
const THRESH = 0.01;

const ZOOMS: { name: string; key: Key; over: Partial<typeof BASE>; values: number[]; gamma?: boolean }[] = [
  { name: "target_gap ramp (base) — sub-unit", key: "targetGap", over: {}, values: [7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11] },
  { name: "W channel-close @ A=100 — sub-unit", key: "window", over: { shoulderA: 100 }, values: [6, 6.5, 7, 7.25, 7.5, 7.75, 8, 8.5, 9] },
  { name: "L_W low wall (γ→0 inversion)", key: "lw", over: {}, values: [1.4, 1.6, 1.8, 2.0, 2.3, 2.7, 3.2, 4, 6, 10], gamma: true },
  { name: "L_W high wall (γ→2.4 over-sharpen)", key: "lw", over: {}, values: [150000, 200000, 300000, 500000, 700000, 1000000], gamma: true },
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
  console.log(`# HLG edge-texture zoom — model "${query}"  (mean canary junk%, K=${K} seeds)`);
  console.log(`# base ${JSON.stringify(BASE)} ; sub-unit steps inside the transitions.\n`);

  const out: Record<string, unknown>[] = [];
  for (const z of ZOOMS) {
    console.log(`\n=== ${z.name} ===`);
    console.log(`  ${z.key.padEnd(9)}${z.gamma ? "   γ  " : ""}  mean   max   break   bar`);
    for (const v of z.values) {
      const hlg = hlgFor({ ...z.over, [z.key]: v });
      const j: number[] = [];
      for (let i = 0; i < K; i++) j.push(junkRatio(await gen(tm, hlg, 7 + i)));
      const mean = j.reduce((a, b) => a + b, 0) / K, max = Math.max(...j), broke = j.filter((x) => x >= THRESH).length;
      const gtxt = z.gamma ? hlgGammaForLw(v).toFixed(2).padStart(5) + " " : "";
      console.log(`  ${String(v).padStart(8)} ${gtxt}  ${(mean * 100).toFixed(0).padStart(3)}%  ${(max * 100).toFixed(0).padStart(3)}%   ${broke}/${K}   ${"█".repeat(Math.round(mean * 40))}`);
      out.push({ zoom: z.name, key: z.key, value: v, gamma: z.gamma ? hlgGammaForLw(v) : null, meanJunk: mean, maxJunk: max, breakRate: broke / K });
    }
  }
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-edge.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, k: K, base: BASE, zooms: ZOOMS, grid: out }, null, 2));
  console.log(`\n(done — ${out.length} steps; results → ${outPath})`);
}

await main();
