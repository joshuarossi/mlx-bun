// HLG frontier probe — the decisive diversity-vs-default test.
//
// Fixes the two gaps the marginal knob-map (hlg-map.ts) can't address:
//   (1) Metric: distinct-2 is lexical and noisy at small N. Here = self-BLEU on
//       the DIVERGENT region (shared chat/opening prefix stripped) at N=10.
//       diversity = 1 − self-BLEU (higher = more varied); also report distinct-2.
//   (2) Interactions: the map is one-knob-at-a-time from one base, so it can't
//       see a B-loose-type JOINT failure. Curated cells include the per-knob
//       diversity edges AND the target_gap×W / target_gap×A corners (the steep
//       axis crossed with the others) to confirm the ranges hold jointly.
//
// Falsifiable question, front and center: is there ANY clean-canary cell that
// beats the default's diversity at equal-or-better coherence? Dominance → win;
// otherwise the honest finding is "finer control, not dominance on the frontier".
//
//   bun scripts/hlg-frontier.ts --model gemma-4-e4b-it-OptiQ-4bit [--n 10]

import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import type { HlgConfig } from "../src/sampler";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const CANARY = "In one sentence, what causes the seasons on Earth?";
const OPEN = [
  "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.",
  "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'",
];

const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type Over = Partial<typeof BASE>;
// curated cells: per-knob loosest-acceptable edges + target_gap×{W,A,s_m} corners + stacked-loose.
// loose-edge cells from the WIDE map (the most-diverse acceptable per knob) +
// stacks — the real dominance candidates the narrow sweep missed.
const CELLS: { name: string; recipe?: boolean; over?: Over }[] = [
  { name: "default", recipe: true },
  { name: "base (W6 tg15 A.35)", over: {} },
  { name: "A=0.01 (loose)", over: { shoulderA: 0.01 } },
  { name: "sM=0.05 (loose)", over: { sM: 0.05 } },
  { name: "Lw=10 (loose)", over: { lw: 10 } },
  { name: "A.01 × sM.05", over: { shoulderA: 0.01, sM: 0.05 } },
  { name: "A.01 × sM.05 × Lw10", over: { shoulderA: 0.01, sM: 0.05, lw: 10 } },
];

const CANARY_THRESH = 0.01;

function letters(s: string): string[] {
  return s.match(/\p{L}/gu) ?? [];
}
function junkRatio(s: string): number {
  const L = letters(s);
  if (!L.length) return 0;
  return L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length;
}
function words(s: string): string[] {
  return s.toLowerCase().match(/[a-z0-9']+/g) ?? [];
}
/** strip the word-level prefix shared by all samples (chat scaffolding + common opening). */
function divergentTokens(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}
function distinct2(toks: string[][]): number {
  const g = new Set<string>();
  let total = 0;
  for (const w of toks) for (let i = 0; i + 2 <= w.length; i++) { g.add(`${w[i]} ${w[i + 1]}`); total++; }
  return total ? g.size / total : 0;
}
function countGrams(toks: string[], n: number): Map<string, number> {
  const m = new Map<string, number>();
  for (let i = 0; i + n <= toks.length; i++) {
    const k = toks.slice(i, i + n).join(" ");
    m.set(k, (m.get(k) ?? 0) + 1);
  }
  return m;
}
/** BLEU-4 of a candidate against a set of references (token arrays), +smoothing. */
function bleu4(cand: string[], refs: string[][]): number {
  if (cand.length === 0) return 0;
  let logSum = 0;
  for (let n = 1; n <= 4; n++) {
    const cg = countGrams(cand, n);
    const refMax = new Map<string, number>();
    for (const r of refs) for (const [k, v] of countGrams(r, n)) refMax.set(k, Math.max(refMax.get(k) ?? 0, v));
    let clipped = 0, total = 0;
    for (const [k, v] of cg) { clipped += Math.min(v, refMax.get(k) ?? 0); total += v; }
    logSum += 0.25 * Math.log((clipped + 1e-9) / (total + 1e-9));
  }
  const closest = refs.map((r) => r.length).reduce((a, b) => (Math.abs(b - cand.length) < Math.abs(a - cand.length) ? b : a), cand.length);
  const bp = cand.length > closest ? 1 : Math.exp(1 - closest / Math.max(cand.length, 1));
  return bp * Math.exp(logSum);
}
/** self-BLEU = mean BLEU of each sample vs the others. Lower ⇒ more diverse. */
function selfBleu(toks: string[][]): number {
  if (toks.length < 2) return 1;
  let s = 0;
  for (let i = 0; i < toks.length; i++) s += bleu4(toks[i]!, toks.filter((_, j) => j !== i));
  return s / toks.length;
}

/** mean-pooled last-hidden-state of `text` (the LM's own embedding), unit-normalized. */
function embed(tm: TaskModel, text: string): Float32Array {
  const ids = tm.tokenizer.encode(text);
  if (ids.length === 0) return new Float32Array([1]);
  const idsArr = MlxArray.fromInt32(Int32Array.from(ids), [1, ids.length]);
  const cache = tm.model.makeCache();
  const h = tm.model.forwardHidden(idsArr, cache); // [1, L, H]
  const pooled = ops.mulScalar(ops.sumAxis(h, 1, false), 1 / ids.length); // [1, H]
  const v = pooled.toFloat32();
  idsArr.dispose();
  h.dispose();
  pooled.dispose();
  for (const c of cache) c.dispose();
  let norm = 0;
  for (const x of v) norm += x * x;
  norm = Math.sqrt(norm) || 1;
  for (let i = 0; i < v.length; i++) v[i] = v[i]! / norm;
  return v;
}
function cosine(a: Float32Array, b: Float32Array): number {
  let s = 0;
  for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!;
  return s;
}
/** semantic diversity = 1 − mean pairwise cosine of the sample embeddings. */
function embeddingDiv(tm: TaskModel, samples: string[]): number {
  const vecs = samples.map((s) => embed(tm, s));
  let sum = 0, n = 0;
  for (let i = 0; i < vecs.length; i++) for (let j = i + 1; j < vecs.length; j++) { sum += cosine(vecs[i]!, vecs[j]!); n++; }
  return n ? 1 - sum / n : 0;
}

function hlgFor(over: Over): HlgConfig {
  const c = { ...BASE, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0,
    window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
}
function readRecommended(dir: string): { temperature: number; topP: number; topK: number } {
  try {
    const gc = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>;
    const num = (v: unknown, d: number): number => (typeof v === "number" ? v : d);
    return { temperature: num(gc.temperature, 1.0), topP: num(gc.top_p, 0), topK: num(gc.top_k, 0) };
  } catch { return { temperature: 1.0, topP: 0, topK: 0 }; }
}

type Sampler = { temperature: number; seed: number; topP?: number; topK?: number; hlg?: HlgConfig };
async function gen(tm: TaskModel, text: string, sampler: Sampler, maxTokens: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) {
    try { return await generateText(tm, text, { maxTokens, sampler }); } catch { /* retry */ }
  }
  return "⟨gen failed⟩";
}

/** N samples on each OPEN prompt → mean {sbleu-div (lexical), emb-div (semantic), distinct2, junk}. */
async function measure(tm: TaskModel, base: Omit<Sampler, "seed">, N: number, seedBase: number): Promise<{ sbleu: number; emb: number; d2: number; junk: number }> {
  let sbleu = 0, emb = 0, d2 = 0, junk = 0;
  for (const p of OPEN) {
    const samples: string[] = [];
    for (let i = 0; i < N; i++) samples.push(await gen(tm, p, { ...base, seed: seedBase + i }, 80));
    const tok = divergentTokens(samples);
    sbleu += 1 - selfBleu(tok);
    emb += embeddingDiv(tm, samples);
    d2 += distinct2(tok);
    junk += samples.reduce((a, s) => a + junkRatio(s), 0) / samples.length;
  }
  const n = OPEN.length;
  return { sbleu: sbleu / n, emb: emb / n, d2: d2 / n, junk: junk / n };
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const N = Number(opt("n", "10"));
  const seedBase = Number(opt("seed", "1000"));
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);

  console.log(`# HLG frontier probe — model "${query}"   |   N=${N}`);
  console.log(`# diversity: sbleu-div = 1−self-BLEU (lexical) · emb-div = 1−mean cosine of LM embeddings (semantic) · distinct2.`);
  console.log(`# canary-gated (<${CANARY_THRESH * 100}% non-Latin). Question: does any clean cell beat the default on EITHER metric?\n`);

  const ref = await measure(tm, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK }, N, seedBase);
  console.log(`default              sbleu-div ${ref.sbleu.toFixed(3)}  emb-div ${ref.emb.toFixed(3)}  distinct2 ${ref.d2.toFixed(2)}  junk ${(ref.junk * 100).toFixed(1)}%  ← REFERENCE\n`);

  const results: Record<string, unknown>[] = [];
  let dominance = false;
  for (const cell of CELLS) {
    if (cell.recipe) continue;
    const hlg = hlgFor(cell.over ?? {});
    const can: string[] = [];
    for (let i = 0; i < 2; i++) can.push(await gen(tm, CANARY, { temperature: 1, seed: seedBase + 7 + i, hlg }, 40));
    const canJunk = Math.max(...can.map(junkRatio));
    if (canJunk >= CANARY_THRESH) {
      console.log(`${cell.name.padEnd(20)} canary ${(canJunk * 100).toFixed(1)}%  REJECT`);
      results.push({ name: cell.name, over: cell.over, canaryJunk: canJunk, verdict: "REJECT" });
      continue;
    }
    const m = await measure(tm, { temperature: 1, hlg }, N, seedBase);
    const clean = m.junk < CANARY_THRESH;
    const beatsS = clean && m.sbleu > ref.sbleu;
    const beatsE = clean && m.emb > ref.emb;
    if (beatsS || beatsE) dominance = true;
    const tag = !clean ? "MARGINAL" : beatsS && beatsE ? "★★ BEATS both" : beatsS ? "★ beats self-BLEU" : beatsE ? "★ beats emb" : "acceptable";
    console.log(`${cell.name.padEnd(20)} sbleu-div ${m.sbleu.toFixed(3)}  emb-div ${m.emb.toFixed(3)}  distinct2 ${m.d2.toFixed(2)}  junk ${(m.junk * 100).toFixed(1)}%  ${tag}`);
    results.push({ name: cell.name, over: cell.over, canaryJunk: canJunk, ...m, verdict: tag });
  }

  console.log(`\nVERDICT: ${dominance ? "★ a clean cell beats the default on a diversity metric — investigate." : "no clean cell beats the default on self-BLEU or embedding — control, not dominance."}`);
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-frontier.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, N, reference: ref, dominance, results }, null, 2));
  console.log(`(results → ${outPath})`);
}

await main();
