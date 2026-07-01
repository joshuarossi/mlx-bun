// curve-temp-match.ts — "but couldn't temperature do that anyway?"
// A curve I drew produced TARGET (default prompt, seed 100+i, n=4, max_tokens 90).
// Sweep PURE temperature (top-p/top-k OFF) at the curve's own seeds and look for an
// EXACT match. Same prompt, same RNG (stepKey(seed,step) is shared by both the curve
// and temperature paths), so a matching temperature would reproduce it token-for-token
// — iff the curve were equivalent to some temperature. It isn't (it's non-linear).
export {};
const BASE = "http://localhost:8080";
const MODEL = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
const PROMPT = "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.";
const TARGET = "The bone-chilling fog, which had been a familiar, suffocating blanket for Elias for countless seasons, suddenly seemed to press against the glass of the lantern room with malevolent intent, and through the swirling grey, an anomaly resolved itself—something neither bird nor piece of wreckage.";

const norm = (s: string) => s.replace(/\s+/g, " ").trim();
function commonPrefix(a: string, b: string): number { let i = 0; while (i < a.length && i < b.length && a[i] === b[i]) i++; return i; }
function pct(a: string, b: string): number { return Math.round((commonPrefix(a, b) / Math.max(a.length, b.length)) * 100); }

async function chat(temperature: number, seed: number, top_p = 0, top_k = 0): Promise<string> {
  const r = await fetch(`${BASE}/v1/chat/completions`, {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: MODEL, messages: [{ role: "user", content: PROMPT }], temperature, top_p, top_k, seed, max_tokens: 90, stream: false }),
  });
  const j = await r.json() as any;
  if (!r.ok) throw new Error(j?.error?.message || j?.error || `HTTP ${r.status}`);
  return (j.choices?.[0]?.message?.content ?? "").trim();
}
async function gen(seed: number, body: Record<string, unknown>): Promise<{ recipe: any; samples: { text: string }[] }> {
  const r = await fetch(`${BASE}/generate`, {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ prompt: PROMPT, n: 1, seed, max_tokens: 90, ...body }),
  });
  const j = await r.json() as any; if (!r.ok) throw new Error(j?.error || `HTTP ${r.status}`); return j;
}

const nT = norm(TARGET);
console.log(`target (${nT.length} chars):\n  "${nT}"\n`);

// ---- methodology check: reproduce a /generate DEFAULT sample via /v1/chat/completions ----
console.log("=== methodology check: /generate default  ==  /v1/chat/completions (same recipe+seed) ===");
const g = await gen(100, { default: true });
const viaGen = norm(g.samples[0]!.text);
const viaChat = norm(await chat(g.recipe.temperature, 100, g.recipe.topP, g.recipe.topK));
const ok = viaGen === viaChat;
console.log(`recipe T=${g.recipe.temperature} top_p=${g.recipe.topP} top_k=${g.recipe.topK}  seed 100`);
console.log(`  /generate : "${viaGen.slice(0, 90)}…"`);
console.log(`  /chat     : "${viaChat.slice(0, 90)}…"`);
console.log(`  IDENTICAL : ${ok ? "YES — tokenization+seeding match, sweep is valid" : "NO — paths differ, results below are advisory"}\n`);

// ---- the sweep: pure temperature, the curve's own seeds, coarse then fine ----
const SEEDS = [100, 101, 102, 103];
const coarse = Array.from({ length: 21 }, (_, i) => +(i * 0.1).toFixed(2)); // 0.0 .. 2.0
type Row = { T: number; seed: number; out: string; match: boolean; prefix: number; pctPrefix: number };
const rows: Row[] = [];
console.log("=== pure-temperature sweep (top_p=0, top_k=0) — looking for an EXACT match ===");
for (const T of coarse) {
  const seeds = T === 0 ? [100] : SEEDS; // T=0 is greedy → seed-independent
  for (const seed of seeds) {
    const out = norm(await chat(T, seed));
    const prefix = commonPrefix(out, nT);
    const row: Row = { T, seed, out, match: out === nT, prefix, pctPrefix: pct(out, nT) };
    rows.push(row);
    if (row.match) console.log(`  *** EXACT MATCH ***  T=${T} seed=${seed}`);
  }
  const best = rows.filter((r) => r.T === T).sort((a, b) => b.prefix - a.prefix)[0]!;
  console.log(`  T=${T.toFixed(1)}  best-of-seeds prefix ${best.prefix} chars (${best.pctPrefix}%)  @seed ${best.seed}`);
}

rows.sort((a, b) => b.prefix - a.prefix);
const anyMatch = rows.some((r) => r.match);
console.log(`\n=== verdict: ${anyMatch ? "TEMPERATURE REPRODUCED IT" : "NO temperature reproduced the sentence"} ===`);
const top = rows[0]!;
console.log(`closest: T=${top.T} seed=${top.seed} — shares first ${top.prefix} chars (${top.pctPrefix}%) then diverges:`);
console.log(`  shared : "${nT.slice(0, top.prefix)}"`);
console.log(`  target : …"${nT.slice(top.prefix, top.prefix + 70)}"`);
console.log(`  temp   : …"${top.out.slice(top.prefix, top.prefix + 70)}"`);
