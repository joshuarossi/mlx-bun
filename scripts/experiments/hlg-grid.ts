// HLG 2-D terrain mapper. Sweeps a grid over TWO knobs and reports, per cell,
// coherence (canary junk) + diversity (self-BLEU, embedding). A map layer, not a
// verdict: coarse N, held loosely — we're characterizing the shape of the
// coherent basin and how the two knobs interact across a plane.
//
//   bun scripts/hlg-grid.ts --model gemma-4-e4b-it-OptiQ-4bit [--n 5]
//
// Axes are set in AXIS_X / AXIS_Y below (default A × s_m, the loose corner).

import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import type { HlgConfig } from "../../src/sampler";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";

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
type Key = keyof typeof BASE;
// the plane to map: X across columns, Y across rows.
const AXIS_X: { key: Key; values: number[] } = { key: "targetGap", values: [10, 13, 16, 25, 50] };
const AXIS_Y: { key: Key; values: number[] } = { key: "window", values: [4, 5, 6, 10, 20] };

const CANARY_THRESH = 0.01;

function letters(s: string): string[] { return s.match(/\p{L}/gu) ?? []; }
function junkRatio(s: string): number {
  const L = letters(s);
  return L.length ? L.filter((c) => !/\p{Script=Latin}/u.test(c)).length / L.length : 0;
}
function words(s: string): string[] { return s.toLowerCase().match(/[a-z0-9']+/g) ?? []; }
function divergentTokens(samples: string[]): string[][] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks;
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p));
}
function countGrams(toks: string[], n: number): Map<string, number> {
  const m = new Map<string, number>();
  for (let i = 0; i + n <= toks.length; i++) { const k = toks.slice(i, i + n).join(" "); m.set(k, (m.get(k) ?? 0) + 1); }
  return m;
}
function bleu4(cand: string[], refs: string[][]): number {
  if (!cand.length) return 0;
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
function selfBleu(toks: string[][]): number {
  if (toks.length < 2) return 1;
  let s = 0;
  for (let i = 0; i < toks.length; i++) s += bleu4(toks[i]!, toks.filter((_, j) => j !== i));
  return s / toks.length;
}
function embed(tm: TaskModel, text: string): Float32Array {
  const ids = tm.tokenizer.encode(text);
  if (!ids.length) return new Float32Array([1]);
  const idsArr = MlxArray.fromInt32(Int32Array.from(ids), [1, ids.length]);
  const cache = tm.model.makeCache();
  const h = tm.model.forwardHidden(idsArr, cache);
  const pooled = ops.mulScalar(ops.sumAxis(h, 1, false), 1 / ids.length);
  const v = pooled.toFloat32();
  idsArr.dispose(); h.dispose(); pooled.dispose(); for (const c of cache) c.dispose();
  let norm = 0; for (const x of v) norm += x * x; norm = Math.sqrt(norm) || 1;
  for (let i = 0; i < v.length; i++) v[i] = v[i]! / norm;
  return v;
}
function embeddingDiv(tm: TaskModel, samples: string[]): number {
  const vecs = samples.map((s) => embed(tm, s));
  let sum = 0, n = 0;
  for (let i = 0; i < vecs.length; i++) for (let j = i + 1; j < vecs.length; j++) { let d = 0; for (let k = 0; k < vecs[i]!.length; k++) d += vecs[i]![k]! * vecs[j]![k]!; sum += d; n++; }
  return n ? 1 - sum / n : 0;
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
  for (let i = 0; i < tries; i++) { try { return await generateText(tm, text, { maxTokens, sampler }); } catch { /* retry */ } }
  return "⟨gen failed⟩";
}
function hlgFor(over: Partial<typeof BASE>): HlgConfig {
  const c = { ...BASE, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const N = Number(opt("n", "5"));
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);

  console.log(`# HLG 2-D terrain map — model "${query}"   |   ${AXIS_Y.key} (rows) × ${AXIS_X.key} (cols), N=${N}`);
  console.log(`# base: ${JSON.stringify(BASE)} ; each cell overrides the two axes.`);
  console.log(`# cell = coherence/diversity: "✗jj%" if canary junk ≥ ${CANARY_THRESH * 100}%, else self-BLEU-div (emb-div).\n`);

  // default reference diversity
  let refS = 0, refE = 0;
  for (const p of OPEN) {
    const s: string[] = [];
    for (let i = 0; i < N; i++) s.push(await gen(tm, p, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK, seed: 2000 + i }, 70));
    refS += 1 - selfBleu(divergentTokens(s)); refE += embeddingDiv(tm, s);
  }
  refS /= OPEN.length; refE /= OPEN.length;
  console.log(`default reference: self-BLEU-div ${refS.toFixed(3)}  emb-div ${refE.toFixed(3)}\n`);

  // header row
  const grid: Record<string, unknown>[] = [];
  const colHdr = AXIS_X.values.map((x) => String(x).padStart(13)).join("");
  console.log(`${AXIS_Y.key.padEnd(7)}\\${AXIS_X.key.padStart(5)}${colHdr}`);
  for (const yv of AXIS_Y.values) {
    let row = `${String(yv).padEnd(13)}`;
    for (const xv of AXIS_X.values) {
      const hlg = hlgFor({ [AXIS_Y.key]: yv, [AXIS_X.key]: xv });
      const can: string[] = [];
      for (let i = 0; i < 2; i++) can.push(await gen(tm, CANARY, { temperature: 1, seed: 7 + i, hlg }, 40));
      const canJunk = Math.max(...can.map(junkRatio));
      if (canJunk >= CANARY_THRESH) {
        row += `      ✗${(canJunk * 100).toFixed(0).padStart(2)}% `;
        grid.push({ [AXIS_Y.key]: yv, [AXIS_X.key]: xv, canaryJunk: canJunk, ok: false });
        continue;
      }
      let s = 0, e = 0, oj = 0;
      for (const p of OPEN) {
        const samples: string[] = [];
        for (let i = 0; i < N; i++) samples.push(await gen(tm, p, { temperature: 1, seed: 2000 + i, hlg }, 70));
        s += 1 - selfBleu(divergentTokens(samples)); e += embeddingDiv(tm, samples);
        oj += samples.reduce((a, t) => a + junkRatio(t), 0) / samples.length;
      }
      s /= OPEN.length; e /= OPEN.length; oj /= OPEN.length;
      const flag = oj >= CANARY_THRESH ? "~" : s > refS || e > refE ? "+" : " ";
      row += ` ${flag}${s.toFixed(2)}(${e.toFixed(2)})`;
      grid.push({ [AXIS_Y.key]: yv, [AXIS_X.key]: xv, canaryJunk: canJunk, sbleu: s, emb: e, openJunk: oj, ok: oj < CANARY_THRESH });
    }
    console.log(row);
  }
  console.log(`\n(legend: "✗jj%" canary-broke · "~" prose leaks junk · "+" beats default on a metric · value = self-BLEU-div (emb-div))`);
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-grid.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, base: BASE, axisX: AXIS_X, axisY: AXIS_Y, refSbleu: refS, refEmb: refE, grid }, null, 2));
  console.log(`(results → ${outPath})`);
}

await main();
