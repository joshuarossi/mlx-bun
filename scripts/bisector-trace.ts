// bisector-trace.ts — where do prompts ROUTE into separate timelines?
// Method (rank-2 probe, parameter-free):
//   1. Greedy reference path (deterministic "default policy").
//   2. At each position i, FORCE the rank-2 token, then greedy-continue.
//   3. Classify: did the branch reconverge to the reference content, or stay diverged?
//   4. The diverging positions are BISECTORS. Depth-distribution per prompt type = the map.
// Reconvergence is judged alignment-free (longest common token-substring of the branch
// vs the reference continuation / |ref continuation|), so a same-content detour of a
// different length still counts as reconverged. Rank-2's probability is recorded so a
// "real fork" (available alternative that diverges) is distinguishable from a forced one.
import { writeFileSync } from "node:fs";
import { loadTaskModel } from "../src/eval/runner";
import { generate } from "../src/generate";
import * as ops from "../src/mlx/ops";

const CANDIDATE = "gemma-4-e4b-it-OptiQ-4bit";
const REF_TOKENS = 80;     // reference path length
const MAX_POS = 52;        // analyze the first N branch positions
const MIN_SUFFIX = 12;     // need ≥ this many reference tokens after i to judge reconvergence
const RECONV = 0.5, DIVERGE = 0.25; // convergence thresholds on the normalized LCSubstr
const PROMPTS = [
  { tag: "creative", text: "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog." },
  { tag: "advice", text: "My 14-year-old wants to start lifting weights. Is that safe, and how should they begin?" },
  { tag: "factual", text: "What is the capital of France, and roughly how many people live there?" },
];

const tm = await loadTaskModel(CANDIDATE);
const encode = (text: string) => tm.tokenizer.encode(tm.template!.render([{ role: "user", content: text }], { addGenerationPrompt: true }));
async function greedy(ids: number[], maxTokens: number): Promise<number[]> {
  const out: number[] = [];
  for await (const { token } of generate(tm.model, ids, { temperature: 0, maxTokens })) out.push(token);
  return out;
}
/** One teacher-forced pass over [prompt+ref]; returns {top1,rank2,p1,p2} per position. */
function rank2overRef(promptIds: number[], ref: number[]) {
  const all = [...promptIds, ...ref];
  const cache = tm.model.makeCache();
  const ids = ops.fromInt32(all, [1, all.length]);
  const h = tm.model.forwardHidden(ids, cache); ids.dispose();
  const Hd = h.shape[2]!;
  const start = promptIds.length - 1, count = Math.min(ref.length, MAX_POS);
  const hs = h.slice([0, start, 0], [1, start + count, Hd]); h.dispose();
  const logits = tm.model.logitsFromHidden(hs); hs.dispose();
  const V = logits.shape[2]!;
  const flat = logits.toFloat32(); logits.dispose();
  for (const c of cache) c.dispose();
  const rows: { top1: number; rank2: number; p1: number; p2: number }[] = [];
  for (let r = 0; r < count; r++) {
    const base = r * V; let m1 = -Infinity, i1 = -1, m2 = -Infinity, i2 = -1;
    for (let v = 0; v < V; v++) { const x = flat[base + v]!; if (x > m1) { m2 = m1; i2 = i1; m1 = x; i1 = v; } else if (x > m2) { m2 = x; i2 = v; } }
    let s = 0; for (let v = 0; v < V; v++) s += Math.exp(flat[base + v]! - m1);
    rows.push({ top1: i1, rank2: i2, p1: 1 / s, p2: Math.exp(m2 - m1) / s });
  }
  return rows;
}
/** Longest common contiguous run of tokens (alignment-free reconvergence). */
function lcSubstr(a: number[], b: number[]): number {
  const m = b.length; let best = 0; const dp = new Int32Array(m + 1);
  for (let i = 1; i <= a.length; i++) { let prev = 0; for (let j = 1; j <= m; j++) { const t = dp[j]!; if (a[i - 1] === b[j - 1]) { dp[j] = prev + 1; if (dp[j]! > best) best = dp[j]!; } else dp[j] = 0; prev = t; } }
  return best;
}

const report: any = { candidate: CANDIDATE, refTokens: REF_TOKENS, prompts: [] };
for (const P of PROMPTS) {
  const promptIds = encode(P.text);
  const ref = await greedy(promptIds, REF_TOKENS);
  const N = ref.length;
  const r2 = rank2overRef(promptIds, ref);
  let tfMismatch = 0;
  const nodes: any[] = [];
  for (let i = 0; i < Math.min(N, MAX_POS); i++) {
    const LR = N - 1 - i; if (LR < MIN_SUFFIX) break;
    if (r2[i]!.top1 !== ref[i]) tfMismatch++;
    const forced = [...promptIds, ...ref.slice(0, i), r2[i]!.rank2];
    const branch = await greedy(forced, LR + 8);
    const R = ref.slice(i + 1, N);
    const conv = lcSubstr(branch, R) / Math.max(1, LR);
    const cls = conv >= RECONV ? "reconv" : conv < DIVERGE ? "DIVERGE" : "partial";
    nodes.push({ i, rank2p: +r2[i]!.p2.toFixed(4), top1p: +r2[i]!.p1.toFixed(4), conv: +conv.toFixed(3), cls,
      forced: tm.tokenizer.decode([r2[i]!.rank2], true), refTok: tm.tokenizer.decode([ref[i]!], true),
      branch: tm.tokenizer.decode(branch.slice(0, 40), true) });
  }
  const div = nodes.filter((n) => n.cls === "DIVERGE");
  const depths = div.map((n) => n.i).sort((a, b) => a - b);
  const realForks = div.filter((n) => n.rank2p >= 0.05); // alternative the model would plausibly have taken
  console.log(`\n================  ${P.tag.toUpperCase()}  ================`);
  console.log(`"${P.text}"`);
  console.log(`reference: "${tm.tokenizer.decode(ref, true).slice(0, 140)}…"  (${N} tok, tf-mismatch ${tfMismatch})`);
  console.log(`nodes=${nodes.length}  reconv=${nodes.filter(n=>n.cls==="reconv").length}  partial=${nodes.filter(n=>n.cls==="partial").length}  DIVERGE=${div.length}  (real-forks rank2p≥.05: ${realForks.length})`);
  console.log(`bisector depths: [${depths.join(", ")}]  median=${depths.length ? depths[Math.floor(depths.length/2)] : "—"}`);
  for (const n of div.slice(0, 4)) console.log(`  i=${String(n.i).padStart(2)}  rank2 "${n.refTok}"→"${n.forced}" p2=${n.rank2p}  conv=${n.conv}  ⇒ "${n.branch.slice(0,70)}…"`);
  report.prompts.push({ tag: P.tag, text: P.text, N, tfMismatch, nodes, depths, diverge: div.length, realForks: realForks.length });
}
writeFileSync("docs/investigations/curve-runs/bisector-trace.json", JSON.stringify(report, null, 2));
console.log(`\nwrote docs/investigations/curve-runs/bisector-trace.json`);
console.log(`\nSUMMARY  (bisectors = diverging rank-2 branches; real-forks = rank2p≥0.05)`);
for (const p of report.prompts) console.log(`  ${p.tag.padEnd(9)} N=${p.N}  bisectors=${p.diverge}  real-forks=${p.realForks}  depths=[${p.depths.slice(0,8).join(",")}${p.depths.length>8?",…":""}]`);
