// Analyse expert-routing traces from src/expert-trace.ts (PLAN Phase 19, E0).
//
//   bun scripts/analyze-expert-trace.ts coding.jsonl [writing.jsonl ...]
//
// Answers the make-or-break E0 question — does a session concentrate its
// routing on a small, stable expert subset?  Per file it reports the coverage
// curve (experts needed for 90/95/99% of activations), the working-set size
// and its cold-load time, and within-task stability (does the hot set drift
// across the session?).  With >=2 files it reports cross-task specialisation
// (do different tasks use different experts?).  All grounded in the measured
// gemma-4-26B-A4B geometry.

const NUM_EXPERTS = 128;
const MOE_LAYERS = 30;
const PER_EXPERT_MB = 3.94; // measured (weight+scales+biases, gate+up+down)
const SSD_GBPS = 5.0; // conservative sequential SSD read
const WINDOWS = 4; // chronological windows for stability

type Rec = { l: number; ids: number[] };

function load(path: string): Rec[] {
  const out: Rec[] = [];
  for (const line of require("node:fs").readFileSync(path, "utf8").split("\n")) {
    if (!line) continue;
    const o = JSON.parse(line);
    if (typeof o.l !== "number" || !Array.isArray(o.i)) continue; // skip meta
    out.push({ l: o.l, ids: o.i });
  }
  return out;
}

// counts[layer] = Int32Array(128) of activation counts
function tally(recs: Rec[]): Map<number, Int32Array> {
  const m = new Map<number, Int32Array>();
  for (const r of recs) {
    let c = m.get(r.l);
    if (!c) { c = new Int32Array(NUM_EXPERTS); m.set(r.l, c); }
    for (const e of r.ids) if (e >= 0 && e < NUM_EXPERTS) c[e]!++;
  }
  return m;
}

function countToCover(counts: Int32Array, frac: number): number {
  const total = counts.reduce((a, b) => a + b, 0);
  if (!total) return 0;
  const sorted = [...counts].sort((a, b) => b - a);
  let cum = 0, n = 0;
  for (const c of sorted) { cum += c; n++; if (cum >= frac * total) break; }
  return n;
}

function hotSet(counts: Int32Array, frac: number): Set<number> {
  const total = counts.reduce((a, b) => a + b, 0);
  if (!total) return new Set();
  const order = [...counts.keys()].sort((a, b) => counts[b]! - counts[a]!);
  const set = new Set<number>();
  let cum = 0;
  for (const e of order) { if (cum >= frac * total) break; cum += counts[e]!; set.add(e); }
  return set;
}

function jaccard(a: Set<number>, b: Set<number>): number {
  if (!a.size && !b.size) return 1;
  let inter = 0;
  for (const x of a) if (b.has(x)) inter++;
  return inter / (a.size + b.size - inter);
}

const median = (xs: number[]) => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? s[Math.floor(s.length / 2)]! : 0;
};

function analyzeFile(path: string): Map<number, Int32Array> {
  const recs = load(path);
  const counts = tally(recs);
  const tokens = recs.reduce((a, r) => a + r.ids.length / 8, 0); // k=8

  // coverage across layers
  const cov90: number[] = [], cov95: number[] = [], cov99: number[] = [], uniq: number[] = [];
  for (const c of counts.values()) {
    cov90.push(countToCover(c, 0.90));
    cov95.push(countToCover(c, 0.95));
    cov99.push(countToCover(c, 0.99));
    uniq.push(c.reduce((a, b) => a + (b > 0 ? 1 : 0), 0));
  }
  const uniqTotal = uniq.reduce((a, b) => a + b, 0);
  const wsMB = uniqTotal * PER_EXPERT_MB;

  // within-task stability: hot-set drift across chronological windows
  const per = Math.ceil(recs.length / WINDOWS);
  const winCounts: Map<number, Int32Array>[] = [];
  for (let w = 0; w < WINDOWS; w++) winCounts.push(tally(recs.slice(w * per, (w + 1) * per)));
  const jac: number[] = [];
  for (let w = 1; w < WINDOWS; w++)
    for (const l of counts.keys()) {
      const a = winCounts[w - 1]!.get(l), b = winCounts[w]!.get(l);
      if (a && b) jac.push(jaccard(hotSet(a, 0.90), hotSet(b, 0.90)));
    }
  const stability = jac.length ? jac.reduce((a, b) => a + b, 0) / jac.length : 0;

  console.log(`\n=== ${path} ===`);
  console.log(`  router calls ${recs.length}, ~${Math.round(tokens)} tokens, ${counts.size} MoE layers`);
  console.log(`  experts to cover 90% of activations (per layer): median ${median(cov90)} / ${NUM_EXPERTS}  (${(100 * median(cov90) / NUM_EXPERTS).toFixed(0)}%)   [min ${Math.min(...cov90)}, max ${Math.max(...cov90)}]`);
  console.log(`  experts to cover 95% / 99%: median ${median(cov95)} / ${median(cov99)} of ${NUM_EXPERTS}`);
  console.log(`  unique experts touched: ${uniqTotal} / ${NUM_EXPERTS * MOE_LAYERS} instances (${(100 * uniqTotal / (NUM_EXPERTS * MOE_LAYERS)).toFixed(0)}%)`);
  console.log(`  working set: ~${(wsMB / 1024).toFixed(2)} GB  ->  cold-load ~${(wsMB / 1024 / SSD_GBPS).toFixed(2)} s once @ ${SSD_GBPS} GB/s`);
  console.log(`  within-task stability (hot-set Jaccard across ${WINDOWS} windows): ${stability.toFixed(2)}  ${stability >= 0.8 ? "(stable ✓)" : stability >= 0.6 ? "(moderate)" : "(drifty ✗)"}`);

  // E0 gate
  const hotFrac = median(cov90) / NUM_EXPERTS;
  const pass = hotFrac <= 0.5 && stability >= 0.6;
  console.log(`  E0 gate (hot<=50% covers 90% AND stability>=0.6): ${pass ? "PROCEED ✓" : "RECONSIDER ✗"}`);
  return counts;
}

const files = process.argv.slice(2);
if (!files.length) {
  console.error("usage: bun scripts/analyze-expert-trace.ts <trace.jsonl> [more.jsonl ...]");
  process.exit(1);
}
const all = files.map((f) => ({ f, counts: analyzeFile(f) }));

// cross-task specialisation: do different tasks use different experts?
if (all.length >= 2) {
  console.log(`\n=== cross-task specialisation ===`);
  for (let i = 0; i < all.length; i++)
    for (let j = i + 1; j < all.length; j++) {
      const js: number[] = [];
      for (let l = 0; l < MOE_LAYERS; l++) {
        const a = all[i]!.counts.get(l), b = all[j]!.counts.get(l);
        if (a && b) js.push(jaccard(hotSet(a, 0.90), hotSet(b, 0.90)));
      }
      const m = js.length ? js.reduce((a, b) => a + b, 0) / js.length : 0;
      console.log(`  ${all[i]!.f} vs ${all[j]!.f}: hot-set Jaccard ${m.toFixed(2)}  ${m < 0.6 ? "(task-specialised — domain prefetch pays ✓)" : "(experts shared across tasks)"}`);
    }
}
console.log("");
