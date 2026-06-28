// curve-temp-weights.ts — "see if temp alone would hit this output" (case 2: advice).
// Same method as the lighthouse test: pure temperature (top-p/top-k OFF), swept across
// T and seeds, looking for an exact match to a curve-generated sample. Advice text is
// far more constrained than creative prose, so temperature may track much further here.
export {};
const BASE = "http://localhost:8090";
const MODEL = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
const PROMPT = "My 14-year-old wants to start lifting weights. Is that safe, and how should they begin?";
const TARGET = "It is definitely possible and, when approached correctly, **safe and beneficial for a 14-year-old to start weight training.** At this age, their body is going through massive hormonal and physical changes, so the focus absolutely **must be on proper form, building good movement patterns, and injury prevention**, not lifting heavy.\n\nThe goal right now should be to teach them how the muscles move, what a controlled movement feels like, and";
const norm = (s: string) => s.replace(/\s+/g, " ").trim();
const nT = norm(TARGET);
const cp = (a: string, b: string) => { let i = 0; while (i < a.length && i < b.length && a[i] === b[i]) i++; return i; };
async function chat(temperature: number, seed: number): Promise<string> {
  const r = await fetch(`${BASE}/v1/chat/completions`, {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: MODEL, messages: [{ role: "user", content: PROMPT }], temperature, top_p: 0, top_k: 0, seed, max_tokens: 96, stream: false }),
  });
  const j = await r.json() as any; if (!r.ok) throw new Error(j?.error?.message || `HTTP ${r.status}`);
  return norm(j.choices?.[0]?.message?.content ?? "");
}
const SEEDS = [100, 101, 102, 103]; // designer Generate uses seed 100 + i (n=4)
console.log(`target (${nT.length} chars):\n  "${nT}"\n`);

// ---- matched sweep: the curve's own seeds, full temperature axis ----
console.log("=== pure-temperature sweep (top_p=0, top_k=0) at the curve's seeds ===");
type Row = { T: number; seed: number; out: string; p: number; exact: boolean };
const rows: Row[] = [];
for (let i = 0; i <= 20; i++) {
  const T = +(i * 0.1).toFixed(2);
  const seeds = T === 0 ? [100] : SEEDS;
  for (const seed of seeds) { const out = await chat(T, seed); rows.push({ T, seed, out, p: cp(out, nT), exact: out === nT }); }
  const best = rows.filter((r) => r.T === T).sort((a, b) => b.p - a.p)[0]!;
  if (best.exact || rows.some(r => r.T === T && r.exact)) console.log(`  *** EXACT MATCH at T=${T} ***`);
  console.log(`  T=${T.toFixed(1)}  best prefix ${best.p}/${nT.length} chars (${Math.round(best.p / nT.length * 100)}%) @seed ${best.seed}`);
}
rows.sort((a, b) => b.p - a.p);
const top = rows[0]!;
console.log(`\nmatched-sweep best: T=${top.T} seed=${top.seed} — ${top.p}/${nT.length} chars (${Math.round(top.p / nT.length * 100)}%)${top.exact ? "  *** EXACT ***" : ""}`);
if (!top.exact) {
  console.log(`  shared: "${nT.slice(0, top.p)}"`);
  console.log(`  target: …"${nT.slice(top.p, top.p + 70)}"`);
  console.log(`  temp  : …"${top.out.slice(top.p, top.p + 70)}"`);
}

// ---- broad seed search at the best-tracking temperature ----
const bestT = top.T || 0.8;
console.log(`\n=== broad seed search at T=${bestT} (does the output appear at ANY seed?) ===`);
let exact = 0, maxP = 0, maxSeed = -1, maxOut = "";
for (let s = 0; s < 200; s++) { const out = await chat(bestT, s); const p = cp(out, nT); if (out === nT) exact++; if (p > maxP) { maxP = p; maxSeed = s; maxOut = out; } }
console.log(`  200 seeds @T=${bestT}: exact=${exact}  deepest=${maxP}/${nT.length} chars @seed ${maxSeed}`);
if (maxP > top.p) { console.log(`  (deeper than the matched seeds) …"${maxOut.slice(top.p, top.p + 70)}"`); }
console.log(`\nverdict: ${exact || top.exact ? "TEMPERATURE HIT IT" : "no temperature reproduced the full output"}.`);
