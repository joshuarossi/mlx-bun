// Capture REAL next-token logit distributions from the model (the actual 262k-wide
// incoming signal the sampler sees) for a few prompts of varying confidence. Reports
// calibration stats — top-token gaps in nats, how many tokens fall within the HLG
// window, top-p/top-k coverage, entropy — to check whether the nat-scale knobs
// (W, target_gap, refGap) are even in the right ballpark for real logits. Exports a
// JS data file the explorer loads (window.REAL_LOGITS), with sorted-descending logits.
//   bun scripts/hlg-capture-logits.ts --model gemma-4-e4b-it-OptiQ-4bit

import { writeFileSync } from "node:fs";
import { loadTaskModel, type TaskModel } from "../src/eval/runner";
import * as ops from "../src/mlx/ops";

function opt(name: string, dflt: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i >= 0 && i + 1 < process.argv.length ? process.argv[i + 1]! : dflt;
}

const PROMPTS = [
  { tag: "arithmetic", text: "What is 2 + 2? Reply with only the number." },        // near-deterministic
  { tag: "factual", text: "In one sentence, what causes the seasons on Earth?" },   // the canary
  { tag: "opposite", text: "The opposite of 'hot' is the word:" },                  // confident
  { tag: "creative", text: "Write the first sentence of a story about a lighthouse keeper." }, // uncertain
];

/** real next-token logits [V] for a chat-wrapped prompt. */
function nextTokenLogits(tm: TaskModel, body: string): Float32Array {
  const text = tm.template ? tm.template.render([{ role: "user", content: body }], { addGenerationPrompt: true }) : body;
  const ids = tm.tokenizer.encode(text);
  const cache = tm.model.makeCache();
  const logits = tm.model.forward(ids, cache); // [1, L, V]
  const [, L, V] = logits.shape as [number, number, number];
  const last = logits.slice([0, L - 1, 0], [1, L, V]); // [1,1,V]
  const f = last.toFloat32();
  logits.dispose(); last.dispose();
  for (const c of cache) c.dispose();
  return f;
}

function stats(logits: Float32Array): Record<string, unknown> {
  const V = logits.length;
  const sorted = Float64Array.from(logits).sort((a, b) => b - a);
  const top = sorted[0]!;
  // softmax for entropy / mass (numerically stable)
  let Z = 0; for (let i = 0; i < V; i++) Z += Math.exp(sorted[i]! - top);
  const lse = top + Math.log(Z);
  let H = 0, massTop1 = 0, massTop10 = 0, massTop64 = 0, pp = 0, ppCount = 0;
  for (let i = 0; i < V; i++) {
    const p = Math.exp(sorted[i]! - lse);
    if (p > 1e-12) H -= p * Math.log2(p);
    if (i === 0) massTop1 = p;
    if (i < 10) massTop10 += p;
    if (i < 64) massTop64 += p;
    if (pp < 0.95) { pp += p; ppCount++; }
  }
  const gap = (k: number): number => top - sorted[Math.min(k, V - 1)]!; // nats below top
  const within = (n: number): number => { let c = 0; for (let i = 0; i < V; i++) { if (top - sorted[i]! <= n) c++; else break; } return c; };
  return {
    vocab: V, topLogit: +top.toFixed(2), entropyBits: +H.toFixed(2),
    gapTo2: +gap(1).toFixed(2), gapTo5: +gap(4).toFixed(2), gapTo10: +gap(9).toFixed(2), gapTo50: +gap(49).toFixed(2), gapTo100: +gap(99).toFixed(2),
    withinW6: within(6), withinW8: within(8), withinW15: within(15),
    massTop1: +massTop1.toFixed(3), massTop10: +massTop10.toFixed(3), massTop64: +massTop64.toFixed(3),
    topP95count: ppCount,
    sorted, // kept for export
  };
}

async function main(): Promise<void> {
  const query = opt("model", "gemma-4-e4b-it-OptiQ-4bit");
  const tm = await loadTaskModel(query);
  console.log(`# Real logit calibration — model "${query}"`);
  console.log(`# the sampler's knobs are in NATS (logit-difference units). Are they sized for real logits?\n`);
  console.log(`tag          vocab  top   ent   │ gap→2  →5   →10   →50  →100 │ #≤6n  #≤8n  #≤15n │ mass1 mass10 mass64 │ top-p#`);

  const exported: Record<string, unknown>[] = [];
  for (const p of PROMPTS) {
    const lg = nextTokenLogits(tm, p.text);
    const s = stats(lg);
    const f = (x: unknown, w = 5): string => String(x).padStart(w);
    console.log(`${p.tag.padEnd(12)} ${f(s.vocab, 6)} ${f(s.topLogit)} ${f(s.entropyBits)}  │${f(s.gapTo2)}${f(s.gapTo5)}${f(s.gapTo10)}${f(s.gapTo50)}${f(s.gapTo100)} │${f(s.withinW6)}${f(s.withinW8)}${f(s.withinW15)} │${f(s.massTop1)}${f(s.massTop10, 7)}${f(s.massTop64, 7)} │${f(s.topP95count)}`);
    // export: round to 2dp; keep full sorted array (tail is flat but the user wants the whole vocab)
    const sorted = s.sorted as Float64Array;
    exported.push({ tag: p.tag, prompt: p.text, vocab: s.vocab, entropyBits: s.entropyBits, topP95count: s.topP95count, sorted: Array.from(sorted, (v) => Math.round(v * 100) / 100) });
  }
  const js = `// Real next-token logits captured from ${query} (sorted descending). Loaded by hlg-explorer.html.\nwindow.REAL_LOGITS = ${JSON.stringify(exported)};\n`;
  const outPath = `${process.cwd()}/docs/investigations/hlg-figs/hlg-logits.js`;
  writeFileSync(outPath, js);
  console.log(`\n(exported ${exported.length} real distributions → ${outPath}, ${(js.length / 1e6).toFixed(1)} MB)`);
}
await main();
