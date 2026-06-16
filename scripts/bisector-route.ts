// bisector-route.ts — do curves ACTUALLY route at the bisectors?
// Ground truth: the bisector trace's per-position labels (FORK / RE-MERGE / LOCKED).
// Test: under matched seeds, generate samples with each policy, align to the greedy
// reference, find the FIRST DEPARTURE position, and ask — does the policy depart
// disproportionately at FORK nodes vs RE-MERGE nodes (a hazard ratio)?
//   temperature: departs ∝ local entropy → can't tell fork from re-merge → ratio ≈ 1
//   curve (router): claim is it departs MORE at forks → ratio > temperature's
// Step 5 coherence: a fork-departure only counts if the continuation stays coherent
// (mean self-logprob under the model), not garbage. That's the real test.
import { readFileSync } from "node:fs";
import { loadTaskModel } from "../src/eval/runner";
import { generate } from "../src/generate";
import * as ops from "../src/mlx/ops";

const CANDIDATE = "gemma-4-e4b-it-OptiQ-4bit";
const SEEDS = Array.from({ length: 20 }, (_, i) => i + 1);
const PROMPTS = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "factual", text: "What is the capital of France, and roughly how many people live there?" },
];
const P = (a: [number, number][]) => ({ space: "logprob" as const, points: a.map(([x, y]) => ({ x_pct: x, y_pct: y })), monotonic: true });
const CURVE_ID = P([[1e-4, 1e-4], [0.1, 0.1], [1, 1], [9, 9], [100, 100]]);            // control: identity ≡ T1
const CURVE_ROUTER = P([[1e-4, 1e-5], [0.1, 0.3], [1, 3], [9, 20], [100, 100]]);       // gate tail (slope>1), open head (slope<1)
const POLICIES: [string, (seed: number) => any][] = [
  ["default", (seed) => ({ temperature: 1, topP: 0.95, topK: 64, seed })],
  ["temp0.8", (seed) => ({ temperature: 0.8, topP: 0, topK: 0, seed })],
  ["curve-id", (seed) => ({ curve: CURVE_ID, seed })],
  ["curve-router", (seed) => ({ curve: CURVE_ROUTER, seed })],
];

const trace = JSON.parse(readFileSync("docs/investigations/curve-runs/bisector-trace.json", "utf8"));
const tm = await loadTaskModel(CANDIDATE);
const encode = (t: string) => tm.tokenizer.encode(tm.template!.render([{ role: "user", content: t }], { addGenerationPrompt: true }));
async function gen(ids: number[], o: any, maxTokens: number): Promise<number[]> {
  const out: number[] = []; for await (const { token } of generate(tm.model, ids, { ...o, maxTokens })) out.push(token); return out;
}
/** mean per-token logprob the model assigns to seq[from..] given prompt+seq (coherence). */
function meanLogprob(promptIds: number[], seq: number[], from: number): number {
  const all = [...promptIds, ...seq]; const cache = tm.model.makeCache();
  const ids = ops.fromInt32(all, [1, all.length]); const h = tm.model.forwardHidden(ids, cache); ids.dispose();
  const Hd = h.shape[2]!; const s = promptIds.length - 1 + from, c = seq.length - from;
  const hs = h.slice([0, s, 0], [1, s + c, Hd]); h.dispose();
  const logits = tm.model.logitsFromHidden(hs); hs.dispose(); const V = logits.shape[2]!;
  const flat = logits.toFloat32(); logits.dispose(); for (const cc of cache) cc.dispose();
  let sum = 0; for (let r = 0; r < c; r++) { const base = r * V; let mx = -Infinity; for (let v = 0; v < V; v++) if (flat[base + v]! > mx) mx = flat[base + v]!; let z = 0; for (let v = 0; v < V; v++) z += Math.exp(flat[base + v]! - mx); sum += flat[base + seq[from + r]!]! - mx - Math.log(z); }
  return sum / c;
}

const summary: any[] = [];
for (const pr of PROMPTS) {
  const promptIds = encode(pr.text);
  const ref = await gen(promptIds, { temperature: 0 }, 80); const N = ref.length;
  const tp = trace.prompts.find((x: any) => x.tag === pr.tag);
  const label = new Map<number, string>(); // i -> FORK|REMERGE|LOCKED (trace cls is reconv|partial|DIVERGE + rank2p)
  for (const n of tp.nodes) label.set(n.i, n.cls === "DIVERGE" ? (n.rank2p >= 0.05 ? "FORK" : "LOCKED") : "REMERGE");
  const bucketAt = (p: number) => label.get(p) ?? "LOCKED"; // unlabeled tail = locked
  const refLP = meanLogprob(promptIds, ref, 0);
  const bc = { FORK: 0, REMERGE: 0, LOCKED: 0 } as Record<string, number>;
  for (let p = 0; p < N; p++) bc[bucketAt(p)]!++;
  console.log(`\n================  ${pr.tag.toUpperCase()}  (ref ${N} tok, mean logprob ${refLP.toFixed(2)}, trace-N ${tp.N}) ================`);
  console.log(`labels over ${N} positions: FORK=${bc.FORK} REMERGE=${bc.REMERGE} LOCKED=${bc.LOCKED}`);
  console.log(`policy        depart%   FORK-rate  REMERGE-rate  LOCKED-rate  FORK/REMERGE   coherent-fork (meanLP)`);
  for (const [pol, mk] of POLICIES) {
    const departAt: number[] = []; // first-departure position per seed (N if none)
    const coh: number[] = []; // mean logprob of fork-departing continuations
    for (const seed of SEEDS) {
      const s = await gen(promptIds, mk(seed), N);
      let d = N; for (let p = 0; p < Math.min(N, s.length); p++) if (s[p] !== ref[p]) { d = p; break; }
      departAt.push(d);
      if (d < N && bucketAt(d) === "FORK") coh.push(meanLogprob(promptIds, s, d));
    }
    const buckets = { FORK: [0, 0], REMERGE: [0, 0], LOCKED: [0, 0] } as Record<string, [number, number]>; // [depart, atRisk]
    for (let p = 0; p < N; p++) {
      const b = bucketAt(p); const atRisk = departAt.filter((d) => d >= p).length; const dep = departAt.filter((d) => d === p).length;
      buckets[b]![1] += atRisk; buckets[b]![0] += dep;
    }
    const rate = (b: string) => buckets[b]![1] ? buckets[b]![0] / buckets[b]![1] : 0;
    const fr = rate("FORK"), rr = rate("REMERGE"), lr = rate("LOCKED");
    const ratio = rr > 0 ? fr / rr : Infinity;
    const departedPct = departAt.filter((d) => d < N).length / SEEDS.length;
    const cohMean = coh.length ? coh.reduce((a, b) => a + b, 0) / coh.length : NaN;
    const cohOk = coh.filter((x) => x > refLP - 1.5).length; // within 1.5 nats/tok of the reference = coherent
    console.log(`${pol.padEnd(13)} ${(departedPct * 100).toFixed(0).padStart(5)}%   ${(fr * 100).toFixed(0).padStart(7)}%   ${(rr * 100).toFixed(0).padStart(9)}%   ${(lr * 100).toFixed(0).padStart(8)}%   ${(ratio === Infinity ? "∞" : ratio.toFixed(2)).padStart(10)}     ${coh.length ? `${cohOk}/${coh.length} ok (${cohMean.toFixed(2)})` : "—"}`);
    summary.push({ tag: pr.tag, pol, departedPct, fr, rr, lr, ratio, cohMean, cohN: coh.length, cohOk });
  }
}
console.log(`\nPREDICTION: curve-router's FORK/REMERGE ratio > the temperature policies' (and coherent), esp. on creative.`);
console.log(`FALSIFIED if curve-router's ratio ≈ temp's — then the curve is just an entropy reshuffle, not a router.`);
require("node:fs").writeFileSync("docs/investigations/curve-runs/bisector-route.json", JSON.stringify(summary, null, 2));
