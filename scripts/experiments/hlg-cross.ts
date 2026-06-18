// HLG cross-pair COHERENCE mapper. The within-pair grids (A×s_m, tg×W) showed
// coupled diagonal cliffs. This asks whether the coupling is GLOBAL: it sweeps
// the cross-pairings (a shaping knob × a gate knob) and maps ONLY the coherence
// boundary (cheap canary-only) — so we can see, across all pairs, whether one
// knob's break moves with the other (cross-talk) or stays put (independent).
//
//   bun scripts/hlg-cross.ts --model gemma-4-e4b-it-OptiQ-4bit
//
// Each axis spans from loose to that knob's discovered break, so the cliff is in frame.

import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import type { HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const CANARY = "In one sentence, what causes the seasons on Earth?";
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Key = keyof typeof BASE;

// per-knob value sets that span from loose to that knob's discovered break.
const VALS: Record<string, number[]> = {
  shoulderA: [0.5, 5, 30, 100], // breaks high (~100)
  sM: [0.2, 0.7, 2, 4], // breaks high (~4)
  targetGap: [8, 12, 20, 50], // breaks low (~12)
  window: [3, 5, 10, 30], // breaks low (~5)
};
// the cross-pairings: each shaping knob (A, s_m) × each gate knob (tg, W).
const PLANES: { y: Key; x: Key }[] = [
  { y: "shoulderA", x: "targetGap" },
  { y: "shoulderA", x: "window" },
  { y: "sM", x: "targetGap" },
  { y: "sM", x: "window" },
];

const THRESH = 0.01;
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
  console.log(`# HLG cross-pair COHERENCE map — model "${query}"  (canary-only; cell = ✓ clean or ✗junk%)`);
  console.log(`# base ${JSON.stringify(BASE)}; each grid varies its two axes over the discovered break-spanning ranges.\n`);

  const out: Record<string, unknown>[] = [];
  for (const pl of PLANES) {
    console.log(`\n=== ${pl.y} (rows) × ${pl.x} (cols) ===`);
    console.log(`${pl.y.padEnd(10)}\\${pl.x}`.padEnd(12) + VALS[pl.x]!.map((v) => String(v).padStart(8)).join(""));
    for (const yv of VALS[pl.y]!) {
      let row = String(yv).padEnd(12);
      for (const xv of VALS[pl.x]!) {
        const hlg = hlgFor({ [pl.y]: yv, [pl.x]: xv });
        let junk = 0;
        for (let i = 0; i < 2; i++) junk = Math.max(junk, junkRatio(await gen(tm, hlg, 7 + i)));
        const ok = junk < THRESH;
        row += (ok ? "      ✓ " : `   ✗${(junk * 100).toFixed(0).padStart(2)}%`);
        out.push({ plane: `${pl.y}×${pl.x}`, [pl.y]: yv, [pl.x]: xv, junk, ok });
      }
      console.log(row);
    }
  }
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-cross.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, base: BASE, vals: VALS, planes: PLANES, grid: out }, null, 2));
  console.log(`\n(done — ${out.length} cells; results → ${outPath})`);
}

await main();
