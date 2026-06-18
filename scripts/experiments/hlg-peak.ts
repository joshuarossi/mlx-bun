// Fine 1-D DIVERSITY sweeps at high K (default 20) — resolving the PEAKS that the
// coarse grids jumped over, with enough samples that self-BLEU actually settles.
//   Sweep 1  L_W around the e4b diversity peak (γ≈1.0) — is 0.76>default real?
//   Sweep 2  A "free lever" diversity gradient — is it a clean monotone?
// Each point: 1−self-BLEU over K samples on the OPEN prompts, plus a canary gate.
//
//   bun scripts/hlg-peak.ts --model gemma-4-e4b-it-OptiQ-4bit [--k 20]

import { writeFileSync, readFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import { hlgGammaForLw, type HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const K = Number(opt("k", "20"));

const CANARY = "In one sentence, what causes the seasons on Earth?";
const OPEN = [
  "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.",
  "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'",
];
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Key = keyof typeof BASE;
const THRESH = 0.01;

const SWEEPS: { name: string; key: Key; values: number[]; note: (v: number) => string }[] = [
  { name: "L_W around the diversity peak", key: "lw", values: [100, 150, 220, 320, 470, 680, 1000, 1500], note: (v) => `γ=${hlgGammaForLw(v).toFixed(2)}` },
  { name: "A diversity gradient (the free lever)", key: "shoulderA", values: [0.01, 0.05, 0.1, 0.2, 0.35, 0.7, 1.5, 3], note: () => "" },
];

function words(s: string): string[] { return s.toLowerCase().match(/[a-z0-9']+/g) ?? []; }
function junkRatio(s: string): number {
  const L = s.match(/\p{L}/gu) ?? [];
  return L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0;
}
function divergent(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}
function gramCount(toks: string[], n: number): Map<string, number> {
  const m = new Map<string, number>();
  for (let i = 0; i + n <= toks.length; i++) { const k = toks.slice(i, i + n).join(" "); m.set(k, (m.get(k) ?? 0) + 1); }
  return m;
}
function bleu4(cand: string[], refs: string[][]): number {
  if (!cand.length) return 0;
  let logSum = 0;
  for (let n = 1; n <= 4; n++) {
    const cg = gramCount(cand, n), refMax = new Map<string, number>();
    for (const r of refs) for (const [k, v] of gramCount(r, n)) refMax.set(k, Math.max(refMax.get(k) ?? 0, v));
    let clipped = 0, total = 0;
    for (const [k, v] of cg) { clipped += Math.min(v, refMax.get(k) ?? 0); total += v; }
    logSum += 0.25 * Math.log((clipped + 1e-9) / (total + 1e-9));
  }
  const closest = refs.map((r) => r.length).reduce((a, b) => (Math.abs(b - cand.length) < Math.abs(a - cand.length) ? b : a), cand.length);
  const bp = cand.length > closest ? 1 : Math.exp(1 - closest / Math.max(cand.length, 1));
  return bp * Math.exp(logSum);
}
function selfBleu(toks: string[][]): number {
  if (toks.length < 2) return 1;
  let s = 0;
  for (let i = 0; i < toks.length; i++) s += bleu4(toks[i]!, toks.filter((_, j) => j !== i));
  return s / toks.length;
}

type Sampler = { temperature: number; seed: number; topP?: number; topK?: number; hlg?: HlgConfig };
async function gen(tm: TaskModel, text: string, sampler: Sampler, maxTokens: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) { try { return await generateText(tm, text, { maxTokens, sampler }); } catch { /* retry */ } }
  return "⟨fail⟩";
}
function hlgFor(over: Partial<typeof BASE>): HlgConfig {
  const c = { ...BASE, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
}
/** diversity (mean over OPEN prompts of 1−self-BLEU on the divergent region) + junk, K samples each. */
async function divSet(tm: TaskModel, base: Omit<Sampler, "seed">): Promise<[number, number]> {
  let div = 0, junk = 0;
  for (const p of OPEN) {
    const out: string[] = [];
    for (let i = 0; i < K; i++) out.push(await gen(tm, p, { ...base, seed: 1234 + i }, 80));
    div += 1 - selfBleu(divergent(out));
    junk += out.reduce((a, s) => a + junkRatio(s), 0) / out.length;
  }
  return [div / OPEN.length, junk / OPEN.length];
}
function readRecommended(dir: string): { temperature: number; topP: number; topK: number } {
  try {
    const gc = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>;
    const num = (v: unknown, d: number): number => (typeof v === "number" ? v : d);
    return { temperature: num(gc.temperature, 1.0), topP: num(gc.top_p, 0), topK: num(gc.top_k, 0) };
  } catch { return { temperature: 1.0, topP: 0, topK: 0 }; }
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);
  console.log(`# HLG fine diversity peaks — model "${query}"  (1−self-BLEU, K=${K} samples/point)`);
  console.log(`# base ${JSON.stringify(BASE)} ; canary gate K=${K} too.\n`);
  const [refDiv, refJunk] = await divSet(tm, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK });
  console.log(`default recipe (T=${rec.temperature} topP=${rec.topP} topK=${rec.topK}): diversity ${refDiv.toFixed(3)}  junk ${(refJunk * 100).toFixed(1)}%   ← reference\n`);

  const out: Record<string, unknown>[] = [];
  for (const sw of SWEEPS) {
    console.log(`\n=== ${sw.name} ===`);
    console.log(`  ${sw.key.padEnd(8)} ${"note".padEnd(8)} canary   diversity (vs ${refDiv.toFixed(3)})`);
    for (const v of sw.values) {
      const hlg = hlgFor({ [sw.key]: v });
      const can: string[] = [];
      for (let i = 0; i < K; i++) can.push(await gen(tm, CANARY, { temperature: 1, seed: 7 + i, hlg }, 40));
      const canJunk = Math.max(...can.map(junkRatio));
      let diversity: number | null = null, openJunk: number | null = null;
      if (canJunk < THRESH) { const [d, j] = await divSet(tm, { temperature: 1, hlg }); diversity = d; openJunk = j; }
      const delta = diversity === null ? "" : (diversity > refDiv ? `  +${(diversity - refDiv).toFixed(3)}` : `  ${(diversity - refDiv).toFixed(3)}`);
      const divStr = diversity === null ? "REJECT" : `${diversity.toFixed(3)}${delta}${openJunk! >= THRESH ? ` (openjunk ${(openJunk! * 100).toFixed(0)}%)` : ""}`;
      console.log(`  ${String(v).padStart(7)} ${sw.note(v).padEnd(8)} ${(canJunk * 100).toFixed(0).padStart(4)}%   ${divStr}`);
      out.push({ sweep: sw.name, key: sw.key, value: v, note: sw.note(v), canaryJunk: canJunk, diversity, openJunk });
    }
  }
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-peak.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, k: K, base: BASE, refDiversity: refDiv, results: out }, null, 2));
  console.log(`\n(done — ${out.length} points; results → ${outPath})`);
}

await main();
