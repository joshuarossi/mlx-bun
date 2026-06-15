// HLG blind-judge harness. Generates N samples per config on the open-ended
// prompts and emits three things:
//   (1) a READABLE labeled transcript (stdout / .log) — so you can read the text;
//   (2) hlg-blind.json — structured, per-prompt ANONYMIZED sets (letters A/B/…)
//       with the letter→config key held separately (for un-blinding after);
//   (3) hlg-blind-prompts.md — paste-ready blind judge prompts for another model.
//
//   bun scripts/hlg-blind.ts --model gemma-4-e4b-it-OptiQ-4bit [--n 5]

import { readFileSync, writeFileSync } from "node:fs";
import { loadTaskModel, generateText, type TaskModel } from "../src/eval/runner";
import type { HlgConfig } from "../src/sampler";

function opt(name: string, dflt: string | null = null): string | null {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const PROMPTS = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "continuation", text: "Complete this thought in a vivid, original way: 'The strangest thing about human memory is'" },
  { tag: "brainstorm", text: "List five unusual but genuinely useful things you can do with an ordinary paperclip." },
];

const BASE = { window: 6, shoulderA: 0.35, sM: 0.7, targetGap: 15, refGap: 4, lw: 1200 };
// the configs under blind comparison.
const CONFIGS: { name: string; recipe?: boolean; over?: Partial<typeof BASE> }[] = [
  { name: "default (temp+top_p+top_k)", recipe: true },
  { name: "hlg-loose (A.01 sM.05)", over: { shoulderA: 0.01, sM: 0.05 } },
  { name: "hlg-base (A.35 sM.7)", over: {} },
];

function hlgFor(over: Partial<typeof BASE>): HlgConfig {
  const c = { ...BASE, ...over };
  return { enabled: true, shaper: true, width: 0, shoulder: 0, toe: 0, pivotOffset: 0, window: c.window, shoulderA: c.shoulderA, sM: c.sM, targetGap: c.targetGap, refGap: c.refGap, lw: c.lw };
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
  for (let i = 0; i < tries; i++) { try { return (await generateText(tm, text, { maxTokens, sampler })).replace(/\s+/g, " ").trim(); } catch { /* retry */ } }
  return "⟨gen failed⟩";
}
const LETTERS = "ABCDEFGH".split("");

async function main(): Promise<void> {
  const query = opt("model") ?? "gemma-4-e4b-it-OptiQ-4bit";
  const N = Number(opt("n", "5"));
  const maxTokens = Number(opt("max", "90"));
  const tm = await loadTaskModel(query);
  const rec = readRecommended(tm.dir);

  const samplerFor = (c: (typeof CONFIGS)[number], seed: number): Sampler =>
    c.recipe ? { temperature: rec.temperature, topP: rec.topP, topK: rec.topK, seed }
             : { temperature: 1, seed, hlg: hlgFor(c.over ?? {}) };

  const blind: Record<string, unknown>[] = [];
  let md = `# HLG blind judge — ${CONFIGS.length} samplers, ${N} samples each, model ${query}\n\nFor each prompt, rank the lettered sets by (a) diversity/variety across its samples and (b) writing quality, and flag any set with incoherent or broken text. You are NOT told which sampler produced which set.\n`;

  console.log(`# HLG blind harness — model "${query}", N=${N}/config\n`);
  for (let pi = 0; pi < PROMPTS.length; pi++) {
    const p = PROMPTS[pi]!;
    // generate N samples per config
    const byConfig: Record<string, string[]> = {};
    for (const c of CONFIGS) {
      const out: string[] = [];
      for (let i = 0; i < N; i++) out.push(await gen(tm, p.text, samplerFor(c, 3000 + i), maxTokens));
      byConfig[c.name] = out;
    }
    // readable LABELED transcript
    console.log(`\n${"═".repeat(78)}\n[${p.tag}] ${p.text}\n${"═".repeat(78)}`);
    for (const c of CONFIGS) {
      console.log(`\n  ▸ ${c.name}`);
      byConfig[c.name]!.forEach((s, i) => console.log(`      ${i + 1}. ${s}`));
    }
    // BLIND: rotate config→letter assignment per prompt
    const order = CONFIGS.map((_, j) => CONFIGS[(j + pi) % CONFIGS.length]!);
    const key: Record<string, string> = {};
    const sets: Record<string, string[]> = {};
    order.forEach((c, j) => { key[LETTERS[j]!] = c.name; sets[LETTERS[j]!] = byConfig[c.name]!; });
    blind.push({ prompt: p.text, tag: p.tag, key, sets });
    // paste-ready judge prompt
    md += `\n---\n\n## Prompt (${p.tag})\n> ${p.text}\n`;
    for (const L of order.map((_, j) => LETTERS[j]!)) {
      md += `\n**Set ${L}:**\n`;
      sets[L]!.forEach((s, i) => { md += `${i + 1}. ${s}\n`; });
    }
    md += `\n_Rank the sets by diversity and by quality; flag incoherent text._\n`;
  }

  const jsonPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-blind.json`;
  const mdPath = `${process.cwd()}/docs/investigations/hlg-runs/hlg-blind-prompts.md`;
  writeFileSync(jsonPath, JSON.stringify({ model: query, N, configs: CONFIGS.map((c) => c.name), prompts: blind }, null, 2));
  writeFileSync(mdPath, md);
  console.log(`\n(done — blind artifact → ${jsonPath}; paste-ready judge prompts → ${mdPath})`);
}

await main();
