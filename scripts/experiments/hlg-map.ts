// HLG knob-space mapper — automated, two-stage, per-knob 1-D sweeps.
//
// Goal: map each knob's (1) what-it-controls and (2) valid range, objectively.
//   Stage 1  COHERENCE gate — the factual canary (short, breaks last). Score =
//            non-Latin letter ratio (the word-salad signature). Cheap; screens
//            the whole grid. Cells over threshold are REJECTED before Stage 2.
//   Stage 2  DIVERSITY — distinct-2 across samples on the open-ended prompts,
//            scored ONLY for canary survivors (so garbage can't win diversity).
//            If the open prompts themselves leak junk → MARGINAL, not ACCEPTABLE.
//
// Per-knob sweeps from a known-good base; the default recipe is the diversity
// reference. Results → docs/investigations/hlg-runs/hlg-map.json (+ printed tables).
//
//   bun scripts/hlg-map.ts --model gemma-4-e4b-it-OptiQ-4bit

import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import type { HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const CANARY = { tag: "factual", text: "In one sentence, what causes the seasons on Earth?" };
const OPEN = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "continuation", text: "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'" },
];

// sane default center; each sweep varies ONE key over a WIDE range (orders of
// magnitude) and holds the rest here. Goal: find what each knob does + its range.
const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
type BaseKey = keyof typeof BASE;
const SWEEPS: { knob: string; key: BaseKey; values: number[] }[] = [
  { knob: "W (candidate gate, nats)", key: "window", values: [1, 2, 3, 4, 6, 8, 12, 20, 40] },
  { knob: "A (shoulder/confidence)", key: "shoulderA", values: [0.01, 0.05, 0.2, 0.35, 0.7, 2, 5, 20, 100, 1000] },
  { knob: "target_gap (sharpness)", key: "targetGap", values: [2, 4, 6, 10, 15, 25, 50, 100] },
  { knob: "s_m (mid sharpness)", key: "sM", values: [0.05, 0.2, 0.5, 0.7, 1.5, 4, 12] },
  { knob: "L_W (global gamma)", key: "lw", values: [1, 10, 100, 1000, 10000, 100000, 1000000] },
];

const CANARY_THRESH = 0.01; // <1% non-Latin letters ⇒ clean
const K_CANARY = 2;
const K_DIV = 3;

function letters(s: string): string[] {
  return s.match(/\p{L}/gu) ?? [];
}
/** fraction of letters that are NOT Latin script — the word-salad signature. */
function junkRatio(s: string): number {
  const L = letters(s);
  if (!L.length) return 0;
  const nonLatin = L.filter((c) => !/\p{Script=Latin}/u.test(c)).length;
  return nonLatin / L.length;
}
function words(s: string): string[] {
  return s.toLowerCase().match(/[a-z0-9']+/g) ?? [];
}
function distinct2(samples: string[]): number {
  const grams = new Set<string>();
  let total = 0;
  for (const s of samples) {
    const w = words(s);
    for (let i = 0; i + 2 <= w.length; i++) {
      grams.add(`${w[i]} ${w[i + 1]}`);
      total++;
    }
  }
  return total ? grams.size / total : 0;
}

function hlgFor(over: Partial<typeof BASE>): HlgConfig {
  const c = { ...BASE, ...over };
  return {
    enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0,
    window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw,
  };
}

function readRecommended(dir: string): { temperature: number; topP: number; topK: number } {
  try {
    const gc = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>;
    const num = (v: unknown, d: number): number => (typeof v === "number" ? v : d);
    return { temperature: num(gc.temperature, 1.0), topP: num(gc.top_p, 0), topK: num(gc.top_k, 0) };
  } catch {
    return { temperature: 1.0, topP: 0, topK: 0 };
  }
}

type Sampler = { temperature: number; seed: number; topP?: number; topK?: number; hlg?: HlgConfig };
async function gen(tm: TaskModel, text: string, sampler: Sampler, maxTokens: number, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) {
    try {
      return await generateText(tm, text, { maxTokens, sampler });
    } catch { /* optiq KV crash — retry */ }
  }
  return "⟨gen failed⟩";
}

/** generate K samples, return [diversity, meanJunk]. */
async function sampleSet(tm: TaskModel, text: string, base: Omit<Sampler, "seed">, K: number, maxTokens: number): Promise<[number, number]> {
  const out: string[] = [];
  for (let i = 0; i < K; i++) out.push(await gen(tm, text, { ...base, seed: 1234 + i }, maxTokens));
  const junk = out.reduce((a, s) => a + junkRatio(s), 0) / out.length;
  return [distinct2(out), junk];
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);

  console.log(`# HLG knob-space map — model "${query}"`);
  console.log(`# base: W=${BASE.window} A=${BASE.shoulderA} s_m=${BASE.sM} target_gap=${BASE.targetGap} L_W=${BASE.lw}`);
  console.log(`# coherence = max non-Latin% on the factual canary (K=${K_CANARY}); ACCEPTABLE < ${CANARY_THRESH * 100}%.`);
  console.log(`# diversity = distinct-2 over open-ended prompts (K=${K_DIV}), scored only for survivors.\n`);

  // diversity reference: the default recipe, untouched.
  let refDiv = 0, refJunk = 0;
  for (const p of OPEN) {
    const [d, j] = await sampleSet(tm, p.text, { temperature: rec.temperature, topP: rec.topP, topK: rec.topK }, K_DIV, 80);
    refDiv += d; refJunk += j;
  }
  refDiv /= OPEN.length; refJunk /= OPEN.length;
  console.log(`A (default recipe): diversity ${refDiv.toFixed(2)}  junk ${(refJunk * 100).toFixed(1)}%   ← reference\n`);

  const results: Record<string, unknown>[] = [];
  for (const sweep of SWEEPS) {
    console.log(`\n=== ${sweep.knob} ===`);
    let lo: number | null = null, hi: number | null = null;
    for (const v of sweep.values) {
      const hlg = hlgFor({ [sweep.key]: v });
      // Stage 1 — canary screen
      const canSamples: string[] = [];
      for (let i = 0; i < K_CANARY; i++) canSamples.push(await gen(tm, CANARY.text, { temperature: 1, seed: 7 + i, hlg }, 40));
      const canJunk = Math.max(...canSamples.map(junkRatio));
      let verdict = "REJECT", diversity: number | null = null, openJunk: number | null = null;
      if (canJunk < CANARY_THRESH) {
        // Stage 2 — diversity on open prompts (survivors only)
        let d = 0, j = 0;
        for (const p of OPEN) {
          const [dd, jj] = await sampleSet(tm, p.text, { temperature: 1, hlg }, K_DIV, 80);
          d += dd; j += jj;
        }
        diversity = d / OPEN.length; openJunk = j / OPEN.length;
        verdict = openJunk < CANARY_THRESH ? "ACCEPTABLE" : "MARGINAL";
        if (verdict === "ACCEPTABLE") { if (lo === null) lo = v; hi = v; }
      }
      const divStr = diversity === null ? "—" : `div ${diversity.toFixed(2)} (vs ${refDiv.toFixed(2)})`;
      const openStr = openJunk === null ? "" : ` openjunk ${(openJunk * 100).toFixed(1)}%`;
      console.log(`  ${sweep.key}=${String(v).padStart(5)}  canary ${(canJunk * 100).toFixed(1).padStart(4)}%  ${verdict.padEnd(10)} ${divStr}${openStr}`);
      results.push({ knob: sweep.knob, key: sweep.key, value: v, canaryJunk: canJunk, verdict, diversity, openJunk });
    }
    console.log(`  → ACCEPTABLE range: ${lo === null ? "(none)" : `[${lo}, ${hi}]`}`);
  }

  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-map.json`;
  writeFileSync(outPath, JSON.stringify({ model: query, base: BASE, refDiversity: refDiv, results }, null, 2));
  console.log(`\n(done — ${results.length} configs; results → ${outPath})`);
}

await main();
