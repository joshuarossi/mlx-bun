// Generates side-by-side A/B/C samples for the comparison viewer: the model's own
// recommended recipe (A) vs HLG-base (B) vs HLG-loose-A (C, the diversity-leaning
// config). Same prompts, N samples each, fixed seeds so it's reproducible. Writes
// JSON consumed by scripts/hlg-ab-html.ts.
//   bun scripts/hlg-ab.ts --model gemma-4-e4b-it-OptiQ-4bit [--n 3]

import { writeFileSync, readFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../../src/eval/runner";
import type { HlgConfig } from "../../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}
const N = Number(opt("n", "3"));

const PROMPTS = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "continuation", text: "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'" },
  { tag: "factual", text: "In one sentence, what causes the seasons on Earth?" },
  { tag: "explain", text: "Explain in two sentences why the sky is blue." },
  { tag: "lateral", text: "Give one unusual but genuinely plausible use for a paperclip, in a sentence." },
  { tag: "voice", text: "Describe the feeling of a city at 3am in one vivid sentence." },
];

function hlg(over: Record<string, number>): HlgConfig {
  const c = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
}
function readRecommended(dir: string): { temperature: number; topP: number; topK: number } {
  try {
    const gc = JSON.parse(readFileSync(`${dir}/generation_config.json`, "utf8")) as Record<string, unknown>;
    const num = (v: unknown, d: number): number => (typeof v === "number" ? v : d);
    return { temperature: num(gc.temperature, 1.0), topP: num(gc.top_p, 0), topK: num(gc.top_k, 0) };
  } catch { return { temperature: 1.0, topP: 0, topK: 0 }; }
}
async function gen(tm: TaskModel, text: string, sampler: Record<string, unknown>, tries = 3): Promise<string> {
  for (let i = 0; i < tries; i++) { try { return (await generateText(tm, text, { maxTokens: 90, sampler })).trim(); } catch { /* retry */ } }
  return "⟨generation failed⟩";
}

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);
  const configs = [
    { id: "A", label: "Default recipe", desc: `the model's recommended sampler — T=${rec.temperature}, top-p=${rec.topP}, top-k=${rec.topK}`, sampler: (seed: number) => ({ temperature: rec.temperature, topP: rec.topP, topK: rec.topK, seed }) },
    { id: "B", label: "HLG base", desc: "A=0.35, s_m=0.7, target_gap=15, W=6", sampler: (seed: number) => ({ temperature: 1, seed, hlg: hlg({}) }) },
    { id: "C", label: "HLG loose-A", desc: "A=0.01 (the diversity-leaning shoulder), rest as base", sampler: (seed: number) => ({ temperature: 1, seed, hlg: hlg({ shoulderA: 0.01 }) }) },
  ];
  const out: Record<string, unknown> = { model: query, n: N, configs: configs.map((c) => ({ id: c.id, label: c.label, desc: c.desc })), prompts: [] };
  const promptsOut: Record<string, unknown>[] = [];
  for (const p of PROMPTS) {
    process.stderr.write(`\n[${p.tag}] `);
    const cell: Record<string, string[]> = {};
    for (const c of configs) {
      const samples: string[] = [];
      for (let i = 0; i < N; i++) { samples.push(await gen(tm, p.text, c.sampler(100 + i))); process.stderr.write("·"); }
      cell[c.id] = samples;
    }
    promptsOut.push({ tag: p.tag, text: p.text, samples: cell });
  }
  out.prompts = promptsOut;
  const outPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-ab.json`;
  writeFileSync(outPath, JSON.stringify(out, null, 2));
  process.stderr.write(`\n(done — ${PROMPTS.length} prompts × ${configs.length} configs × ${N}; → ${outPath})\n`);
}

await main();
