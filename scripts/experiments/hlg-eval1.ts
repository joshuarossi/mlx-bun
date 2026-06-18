// Evaluate ONE HLG config (e.g. one you dialed in the explorer) at K=20: canary
// coherence + self-BLEU diversity vs the model's default recipe, plus a few sample
// generations so you can read its character. Defaults to the explorer config the
// values below; override any with --flag.
//   bun scripts/hlg-eval1.ts --model gemma-4-e4b-it-OptiQ-4bit [--k 20] [--sM 0.05 ...]

import { writeFileSync, readFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import { hlgGammaForLw, type HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: number): number {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? Number(process.argv[i + 1]) : dflt;
}
function sopt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const K = opt("k", 20);

// Accept a pasted explorer JSON ({"window":..,"A":..,...}) via --json; individual
// --flags still override it; otherwise fall back to the last config's defaults.
function jsonArg(): Record<string, number> {
  const i = process.argv.indexOf("--json");
  if (i >= 0 && i + 1 < process.argv.length) { try { return JSON.parse(process.argv[i + 1]!) as Record<string, number>; } catch { /* ignore */ } }
  return {};
}
const J = jsonArg();
const CFG = {
  window: opt("window", J.window ?? 7.5), shoulderA: opt("A", J.A ?? 3.55), sM: opt("sM", J.sM ?? 0.05), targetGap: opt("targetGap", J.targetGap ?? 4),
  refGap: opt("refGap", J.refGap ?? 3.5), lw: opt("lw", J.lw ?? 54954), xM: opt("xM", J.xM ?? 0.74), yM: opt("yM", J.yM ?? 0.67),
  xFloor: opt("xFloor", J.xFloor ?? 0.45), yFloor: opt("yFloor", J.yFloor ?? 0.05), p: opt("p", J.p ?? 1.7),
};

const CANARY = "In one sentence, what causes the seasons on Earth?";
const OPEN = [
  "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.",
  "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'",
];
const SHOW = "Write the first sentence of a short story about a clockmaker who finds a watch that runs backwards.";

function words(s: string): string[] { return s.toLowerCase().match(/[a-z0-9']+/g) ?? []; }
function junkRatio(s: string): number { const L = s.match(/\p{L}/gu) ?? []; return L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0; }
function divergent(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0; while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}
function gc(toks: string[], n: number): Map<string, number> { const m = new Map<string, number>(); for (let i = 0; i + n <= toks.length; i++) { const k = toks.slice(i, i + n).join(" "); m.set(k, (m.get(k) ?? 0) + 1); } return m; }
function bleu4(cand: string[], refs: string[][]): number {
  if (!cand.length) return 0; let logSum = 0;
  for (let n = 1; n <= 4; n++) {
    const cg = gc(cand, n), rm = new Map<string, number>();
    for (const r of refs) for (const [k, v] of gc(r, n)) rm.set(k, Math.max(rm.get(k) ?? 0, v));
    let cl = 0, t = 0; for (const [k, v] of cg) { cl += Math.min(v, rm.get(k) ?? 0); t += v; }
    logSum += 0.25 * Math.log((cl + 1e-9) / (t + 1e-9));
  }
  const closest = refs.map((r) => r.length).reduce((a, b) => (Math.abs(b - cand.length) < Math.abs(a - cand.length) ? b : a), cand.length);
  const bp = cand.length > closest ? 1 : Math.exp(1 - closest / Math.max(cand.length, 1));
  return bp * Math.exp(logSum);
}
function selfBleu(toks: string[][]): number { if (toks.length < 2) return 1; let s = 0; for (let i = 0; i < toks.length; i++) s += bleu4(toks[i]!, toks.filter((_, j) => j !== i)); return s / toks.length; }

function hlg(): HlgConfig { return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, ...CFG }; }
async function gen(tm: TaskModel, text: string, sampler: Record<string, unknown>, maxTokens: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) { try { return (await generateText(tm, text, { maxTokens, sampler })).trim(); } catch { /* retry */ } }
  return "⟨fail⟩";
}
function readRec(dir: string): { temperature: number; topP: number; topK: number } {
  try { const g = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>; const n = (v: unknown, d: number): number => (typeof v === "number" ? v : d); return { temperature: n(g.temperature, 1), topP: n(g.top_p, 0), topK: n(g.top_k, 0) }; } catch { return { temperature: 1, topP: 0, topK: 0 }; }
}
async function divSet(tm: TaskModel, base: Record<string, unknown>): Promise<[number, number]> {
  let div = 0, junk = 0;
  for (const pr of OPEN) { const out: string[] = []; for (let i = 0; i < K; i++) out.push(await gen(tm, pr, { ...base, seed: 1234 + i }, 80)); div += 1 - selfBleu(divergent(out)); junk += out.reduce((a, s) => a + junkRatio(s), 0) / out.length; }
  return [div / OPEN.length, junk / OPEN.length];
}

async function main(): Promise<void> {
  const query = sopt("model", "gemma-4-e4b-it-OptiQ-4bit");
  const tm = await loadTaskModel(query);
  const rec = readRec(tm.dir);
  const gamma = hlgGammaForLw(CFG.lw);
  console.log(`# HLG single-config eval — model "${query}"  (K=${K})`);
  console.log(`# config: ${JSON.stringify(CFG)}  (γ=${gamma.toFixed(2)})\n`);

  const [refDiv, refJunk] = await divSet(tm, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK });
  console.log(`default recipe: diversity ${refDiv.toFixed(3)}  junk ${(refJunk * 100).toFixed(1)}%`);

  // canary coherence at K
  const cj: number[] = [];
  for (let i = 0; i < K; i++) cj.push(junkRatio(await gen(tm, CANARY, { temperature: 1, seed: 7 + i, hlg: hlg() }, 40)));
  const canMean = cj.reduce((a, b) => a + b, 0) / K, canMax = Math.max(...cj), broke = cj.filter((j) => j >= 0.01).length;
  // diversity at K
  const [div, openJunk] = await divSet(tm, { temperature: 1, hlg: hlg() });
  console.log(`\nTHIS CONFIG:`);
  console.log(`  canary junk:  mean ${(canMean * 100).toFixed(1)}%  max ${(canMax * 100).toFixed(0)}%  broke ${broke}/${K}  →  ${broke === 0 ? "COHERENT" : broke <= 2 ? "MOSTLY COHERENT" : "INCOHERENT"}`);
  console.log(`  diversity:    ${div.toFixed(3)}  (vs default ${refDiv.toFixed(3)}, Δ ${(div - refDiv >= 0 ? "+" : "") + (div - refDiv).toFixed(3)})  openjunk ${(openJunk * 100).toFixed(1)}%`);

  console.log(`\nSAMPLES (clockmaker prompt):`);
  for (let i = 0; i < 4; i++) console.log(`  ${i + 1}. ${await gen(tm, SHOW, { temperature: 1, seed: 50 + i, hlg: hlg() }, 80)}`);

  writeFileSync(`${process.cwd()}/docs/investigations/hlg-runs/hlg-eval1.json`, JSON.stringify({ model: query, k: K, config: CFG, gamma, refDiv, refJunk, canMean, canMax, broke, div, openJunk }, null, 2));
  console.log(`\n(results → docs/investigations/hlg-runs/hlg-eval1.json)`);
}
await main();
