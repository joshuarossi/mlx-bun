// curve-temp-grid.ts — the definitive version: sweep the WHOLE temperature axis with
// fresh seeds (seed is a free variable), and count how often pure temperature produces
// the curve's sentence or even crosses its fork. Saturating the (temp × seed) grid.
export {};
const BASE = "http://localhost:8090";
const MODEL = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
const PROMPT = "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.";
const TARGET = "The bone-chilling fog, which had been a familiar, suffocating blanket for Elias for countless seasons, suddenly seemed to press against the glass of the lantern room with malevolent intent, and through the swirling grey, an anomaly resolved itself—something neither bird nor piece of wreckage.";
const norm = (s: string) => s.replace(/\s+/g, " ").trim();
const nT = norm(TARGET);
const FORK = 84; // "…blanket for Elias for " — curve chose "countless", every temperature chose "the"
const cp = (a: string, b: string) => { let i = 0; while (i < a.length && i < b.length && a[i] === b[i]) i++; return i; };
async function chat(temperature: number, seed: number): Promise<string> {
  const r = await fetch(`${BASE}/v1/chat/completions`, {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: MODEL, messages: [{ role: "user", content: PROMPT }], temperature, top_p: 0, top_k: 0, seed, max_tokens: 64, stream: false }),
  });
  const j = await r.json() as any; if (!r.ok) throw new Error(j?.error?.message || `HTTP ${r.status}`);
  return norm(j.choices?.[0]?.message?.content ?? "");
}
const TEMPS = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.4, 1.6, 2.0];
const SEEDS = Array.from({ length: 32 }, (_, i) => 200 + i); // fresh band, disjoint from the earlier 0..299
let total = 0, exactAll = 0, forkAll = 0, deepest = 0, deepAt = "";
console.log(`fork at char ${FORK}: "…${nT.slice(60, FORK)}|${nT.slice(FORK, FORK + 16)}…"\n`);
console.log("temp   n   exact  crossed-fork  deepest-prefix");
for (const T of TEMPS) {
  let exact = 0, fork = 0, maxP = 0, maxSeed = -1;
  for (const s of SEEDS) {
    const out = await chat(T, s); const p = cp(out, nT); total++;
    if (out === nT) { exact++; exactAll++; }
    if (p > FORK + 4) { fork++; forkAll++; }
    if (p > maxP) { maxP = p; maxSeed = s; }
    if (p > deepest) { deepest = p; deepAt = `T=${T} seed=${s}`; }
  }
  console.log(`${T.toFixed(1).padStart(4)}  ${SEEDS.length}    ${String(exact).padStart(3)}    ${String(fork).padStart(6)}        ${maxP} chars @seed ${maxSeed}`);
}
console.log(`\nGRID TOTAL: ${total} pure-temperature samples across ${TEMPS.length} temperatures`);
console.log(`  exact matches:  ${exactAll}`);
console.log(`  crossed the fork: ${forkAll}`);
console.log(`  deepest any sample reached: ${deepest} chars (${deepAt})  — target is ${nT.length} chars`);
console.log(`\nCombined with the prior 540 samples: ${540 + total} total, exact=${exactAll}, crossed-fork=${forkAll}.`);
