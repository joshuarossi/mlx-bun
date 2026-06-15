// HLG sampling comparison harness — hold the model's OWN recommended recipe
// fixed (generation_config.json: temperature / top_p / top_k) and change ONLY
// the post-gating sampling curve. The "standard" row is the control (plain
// temperature scaling); each "hlg-*" row swaps in an HLG variant while keeping
// the recommended top_p/top_k. Reports lexical diversity + length and prints the
// samples. Qualitative precursor to the Piece 5 diversity lens
// (docs/design/hlg-sampling.md). Not a recorded benchmark; an eyeball tool.
//
//   bun scripts/hlg-compare.ts --model gemma-4-e4b-it-OptiQ-4bit [--k 4] [--max 80]
//
// Heavy: ~ (#prompts × #patterns × K) generations — run on an idle machine.

import { readFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import type { HlgConfig } from "../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

type SamplerOverride = { temperature: number; seed: number; topP?: number; topK?: number; hlg?: HlgConfig };
interface Pattern { name: string; temperature: number; topP: number; topK: number; hlg?: HlgConfig }

// ONE curve, three pivot (middle-grey) placements — the only thing that varies
// across the hlg-* rows. HLG is a REPLACEMENT sampler: when on, the curve is the
// whole methodology (its toe does the tail control), so the hlg-* rows carry NO
// top_p/top_k. The "standard" row is the model's recipe (what we used to do).
const OETF_OFF = { width: 0, shoulder: 0, toe: 0, pivotOffset: 0 }; // ignored in pipeline mode
// B = the exact user-specified HLGShaper (min-max → piecewise OETF w/ cubic
// suppress-toe → OOTF → ×out_scale). L_W=1200, out_scale=12 (the spec defaults).
// Verify the dominant cells (loose A × loose s_m) — do they READ as good:
// factual still correct, prose genuinely varied (not degenerate)?
const VARIANTS: { name: string; hlg: HlgConfig }[] = [
  { name: "B  A.01×sM.05", hlg: { enabled: true, shaper: true, lw: 1200, window: 6, sM: 0.05, shoulderA: 0.01, targetGap: 15, refGap: 4, ...OETF_OFF } },
  { name: "B  A.01×sM.05×Lw10", hlg: { enabled: true, shaper: true, lw: 10, window: 6, sM: 0.05, shoulderA: 0.01, targetGap: 15, refGap: 4, ...OETF_OFF } },
];

/** The model's own recommended sampling recipe (generation_config.json). */
function readRecommended(dir: string): { temperature: number; topP: number; topK: number } {
  try {
    const gc = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>;
    const num = (v: unknown, d: number): number => (typeof v === "number" ? v : d);
    return { temperature: num(gc.temperature, 1.0), topP: num(gc.top_p, 0), topK: num(gc.top_k, 0) };
  } catch {
    return { temperature: 1.0, topP: 0, topK: 0 };
  }
}

// Five prompts spanning the regimes the thesis cares about: open-ended (want
// diversity), brainstorm (want diversity), factual + reasoning (want NO
// tail-garbage), and an ambiguous continuation (want interesting-but-coherent).
const PROMPTS: { tag: string; text: string }[] = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "brainstorm", text: "List five unusual but genuinely useful things you can do with an ordinary paperclip." },
  { tag: "factual", text: "In one sentence, what causes the seasons on Earth?" },
  { tag: "reasoning", text: "A bat and a ball cost $1.10 in total. The bat costs $1.00 more than the ball. How much does the ball cost? Think step by step, then give the final answer." },
  { tag: "continuation", text: "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'" },
];

function words(s: string): string[] {
  return s.toLowerCase().match(/[a-z0-9']+/g) ?? [];
}

/** Drop the word-level common prefix shared by all samples (the chat-template
 *  scaffolding) so diversity reflects the generated content, not the boilerplate. */
function stripCommonPrefix(samples: string[]): string[] {
  const toks = samples.map(words);
  if (toks.length < 2) return toks.map((t) => t.join(" "));
  const minLen = Math.min(...toks.map((t) => t.length));
  let p = 0;
  while (p < minLen && toks.every((t) => t[p] === toks[0]![p])) p++;
  return toks.map((t) => t.slice(p).join(" "));
}

/** distinct-n pooled across samples (after stripping shared scaffolding):
 *  unique n-grams / total n-grams. Higher = more varied. */
function distinctN(stripped: string[], n: number): number {
  const grams = new Set<string>();
  let total = 0;
  for (const s of stripped) {
    const w = words(s);
    for (let i = 0; i + n <= w.length; i++) {
      grams.add(w.slice(i, i + n).join(" "));
      total++;
    }
  }
  return total === 0 ? 0 : grams.size / total;
}

function meanWords(samples: string[]): number {
  return samples.length === 0 ? 0 : samples.reduce((a, s) => a + words(s).length, 0) / samples.length;
}

function oneLine(s: string, max = 2000): string {
  const t = s.replace(/\s+/g, " ").trim();
  return t.length > max ? t.slice(0, max) + "…" : t;
}

async function genWithRetry(tm: TaskModel, text: string, sampler: SamplerOverride, maxTokens: number, tries = 3): Promise<string> {
  let lastErr: unknown;
  for (let i = 0; i < tries; i++) {
    try {
      return await generateText(tm, text, { maxTokens, sampler });
    } catch (e) {
      lastErr = e;
    }
  }
  return `⟨generation failed after ${tries} tries: ${String(lastErr)}⟩`;
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const K = Number(opt("k", "4"));
  const maxTokens = Number(opt("max", "80"));
  const baseSeed = Number(opt("seed", "1234"));

  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);
  const recLabel = `temp ${rec.temperature} · top_p ${rec.topP} · top_k ${rec.topK}`;

  // A/B: A = the model's default recipe, untouched. B = the HLG replacement sampler
  // (no temp/top_p/top_k — it IS the whole sampler).
  const patterns: Pattern[] = [
    { name: "A (default)", temperature: rec.temperature, topP: rec.topP, topK: rec.topK },
    ...VARIANTS.map((v) => ({ name: v.name, temperature: rec.temperature, topP: 0, topK: 0, hlg: v.hlg })),
  ];

  console.log(`# 1-D A sweep — model "${query}"   |   ${K} samples each, maxTokens=${maxTokens}`);
  console.log(`# A (default) = the model's recipe, untouched: ${recLabel}`);
  console.log(`# B A=… = HLGShaper, only A varies (W=6, s_m=.7, L_W=1200, out_scale auto). Factual = canary.\n`);

  for (const prompt of PROMPTS) {
    console.log(`\n${"═".repeat(78)}`);
    console.log(`[${prompt.tag}] ${prompt.text}`);
    console.log("═".repeat(78));

    for (const p of patterns) {
      const n = p.temperature === 0 ? 1 : K; // greedy ignores the seed
      const samples: string[] = [];
      for (let i = 0; i < n; i++) {
        const sampler: SamplerOverride = {
          temperature: p.temperature,
          seed: baseSeed + i,
          ...(p.topP ? { topP: p.topP } : {}),
          ...(p.topK ? { topK: p.topK } : {}),
          ...(p.hlg ? { hlg: p.hlg } : {}),
        };
        samples.push(await genWithRetry(tm, prompt.text, sampler, maxTokens));
      }
      console.log(`\n  ▸ ${p.name}`);
      samples.forEach((s, i) => console.log(`      ${i + 1}. ${oneLine(s)}`));
    }
  }
  console.log("\n(done)");
}

await main();
