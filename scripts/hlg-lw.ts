// HLG L_W (global OOTF gamma) mapper. L_W sets γ = 1.2 + 0.42·log10(L_W/1000);
// the OOTF stage raises the normalized shape to γ. Because the auto-out_scale
// pins the top→reference gap to target_gap, L_W bends the CURVATURE of the mid/
// tail rather than the top anchor — so this maps what that curvature does, not a
// second copy of target_gap. Two-stage: canary coherence gate → self-BLEU
// diversity on survivors. Prints γ next to each L_W so the knob→γ→effect chain
// is visible. Low end (L_W ≲ 1.4 ⇒ γ<0) inverts the ranking — expect a hard wall.
//
//   bun scripts/hlg-lw.ts --model gemma-4-12B-it-OptiQ-4bit [--fine]
//
// --fine: dense geometric grid (≈6 steps/decade) over the action zone (1..1000)
// for the more-sensitive models, to test whether finer steps resolve structure.

import { writeFileSync, readFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import { hlgGammaForLw, type HlgConfig } from "../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const FINE = process.argv.includes("--fine");

const CANARY = "In one sentence, what causes the seasons on Earth?";
const OPEN = [
  "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.",
  "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'",
];
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4 };

const COARSE = [1, 3, 10, 30, 100, 300, 1000, 3000, 10000, 30000, 100000, 1000000];
// ≈6 steps/decade over 1..1000 (where γ runs 0→1.2 — the whole transition), + high anchors.
const FINE_LW = [...new Set([...Array.from({ length: 19 }, (_, i) => Math.round(10 ** (i / 6))), 3162, 10000, 100000, 1000000])];
const LWS = FINE ? FINE_LW : COARSE;

const THRESH = 0.01, K_CAN = FINE ? 3 : 2, K_DIV = 6;

function words(s: string): string[] { return s.toLowerCase().match(/[a-z0-9']+/g) ?? []; }
function junkRatio(s: string): number {
  const L = s.match(/\p{L}/gu) ?? [];
  return L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0;
}
/** strip the word-prefix shared by all samples (scaffolding + common opening). */
function divergent(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}
function grams(toks: string[], n: number): Map<string, number> {
  const m = new Map<string, number>();
  for (let i = 0; i + n <= toks.length; i++) { const k = toks.slice(i, i + n).join(" "); m.set(k, (m.get(k) ?? 0) + 1); }
  return m;
}
function bleu4(cand: string[], refs: string[][]): number {
  if (!cand.length) return 0;
  let logSum = 0;
  for (let n = 1; n <= 4; n++) {
    const cg = grams(cand, n), refMax = new Map<string, number>();
    for (const r of refs) for (const [k, v] of grams(r, n)) refMax.set(k, Math.max(refMax.get(k) ?? 0, v));
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

function hlgFor(lw: number): HlgConfig {
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: BASE.window, shoulderA: BASE.shoulderA, sM: BASE.sM, targetGap: BASE.targetGap, refGap: BASE.refGap, lw };
}
type Sampler = { temperature: number; seed: number; topP?: number; topK?: number; hlg?: HlgConfig };
async function gen(tm: TaskModel, text: string, sampler: Sampler, maxTokens: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) { try { return await generateText(tm, text, { maxTokens, sampler }); } catch { /* optiq KV crash — retry */ } }
  return "⟨fail⟩";
}
/** diversity (1−self-BLEU on the divergent region) + mean junk, over the OPEN prompts. */
async function divSet(tm: TaskModel, base: Omit<Sampler, "seed">): Promise<[number, number]> {
  let div = 0, junk = 0;
  for (const p of OPEN) {
    const out: string[] = [];
    for (let i = 0; i < K_DIV; i++) out.push(await gen(tm, p, { ...base, seed: 1234 + i }, 80));
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
  console.log(`# HLG L_W (global OOTF γ) sweep — model "${query}"  ${FINE ? "[FINE grid]" : "[coarse grid]"}`);
  console.log(`# base ${JSON.stringify(BASE)} ; γ = 1.2 + 0.42·log10(L_W/1000) ; out_scale auto-holds target_gap, so L_W bends curvature.`);
  console.log(`# coherence = max non-Latin% on canary (K=${K_CAN}), clean < ${THRESH * 100}% ; diversity = 1−self-BLEU on OPEN (K=${K_DIV}), survivors only.\n`);

  const [refDiv, refJunk] = await divSet(tm, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK });
  console.log(`default recipe (T=${rec.temperature} topP=${rec.topP} topK=${rec.topK}): diversity ${refDiv.toFixed(2)}  junk ${(refJunk * 100).toFixed(1)}%   ← reference\n`);
  console.log(`   L_W        γ    canary   verdict       diversity (vs ${refDiv.toFixed(2)})`);

  const out: Record<string, unknown>[] = [];
  let lo: number | null = null, hi: number | null = null;
  for (const lw of LWS) {
    const gamma = hlgGammaForLw(lw);
    const can: string[] = [];
    for (let i = 0; i < K_CAN; i++) can.push(await gen(tm, CANARY, { temperature: 1, seed: 7 + i, hlg: hlgFor(lw) }, 40));
    const canJunk = Math.max(...can.map(junkRatio));
    let verdict = "REJECT", diversity: number | null = null, openJunk: number | null = null;
    if (canJunk < THRESH) {
      const [d, j] = await divSet(tm, { temperature: 1, hlg: hlgFor(lw) });
      diversity = d; openJunk = j;
      verdict = j < THRESH ? "ACCEPTABLE" : "MARGINAL";
      if (verdict === "ACCEPTABLE") { if (lo === null) lo = lw; hi = lw; }
    }
    const divStr = diversity === null ? "—" : `${diversity.toFixed(2)}${openJunk! >= THRESH ? ` (openjunk ${(openJunk! * 100).toFixed(0)}%)` : ""}`;
    console.log(`${String(lw).padStart(8)}  ${gamma.toFixed(2).padStart(6)}  ${(canJunk * 100).toFixed(0).padStart(4)}%   ${verdict.padEnd(11)}  ${divStr}`);
    out.push({ lw, gamma, canaryJunk: canJunk, verdict, diversity, openJunk });
  }
  console.log(`\n  → ACCEPTABLE L_W range: ${lo === null ? "(none)" : `[${lo}, ${hi}]`}  (γ ∈ [${hlgGammaForLw(lo ?? 1).toFixed(2)}, ${hlgGammaForLw(hi ?? 1).toFixed(2)}])`);
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-lw-${FINE ? "fine" : "coarse"}.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, fine: FINE, base: BASE, refDiversity: refDiv, results: out }, null, 2));
  console.log(`(done — ${out.length} points; results → ${outPath})`);
}

await main();
