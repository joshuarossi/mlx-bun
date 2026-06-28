// curve-temp-seedsearch.ts — "you can use seed, so we can know if the output appears."
// The seed is a free variable I control. So the real question isn't "does temperature
// match at the curve's seed" — it's "does this exact sentence appear from PURE temperature
// at ANY seed?" If it surfaces anywhere in a broad seed search, temperature can produce it.
// If hundreds of seeds never reach it, the curve put the model where temperature won't go.
export {};
const BASE = "http://localhost:8090";
const MODEL = "mlx-community/gemma-4-e4b-it-OptiQ-4bit";
const PROMPT = "Write the first sentence of a short story about a lighthouse keeper who discovers something strange in the fog.";
const TARGET = "The bone-chilling fog, which had been a familiar, suffocating blanket for Elias for countless seasons, suddenly seemed to press against the glass of the lantern room with malevolent intent, and through the swirling grey, an anomaly resolved itself—something neither bird nor piece of wreckage.";
const norm = (s: string) => s.replace(/\s+/g, " ").trim();
const nT = norm(TARGET);
const FORK = 84; // chars: "…suffocating blanket for Elias for " — where the curve chose "countless", temp chose "the"
const cp = (a: string, b: string) => { let i = 0; while (i < a.length && i < b.length && a[i] === b[i]) i++; return i; };
async function chat(temperature: number, seed: number): Promise<string> {
  const r = await fetch(`${BASE}/v1/chat/completions`, {
    method: "POST", headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: MODEL, messages: [{ role: "user", content: PROMPT }], temperature, top_p: 0, top_k: 0, seed, max_tokens: 72, stream: false }),
  });
  const j = await r.json() as any; if (!r.ok) throw new Error(j?.error?.message || `HTTP ${r.status}`);
  return norm(j.choices?.[0]?.message?.content ?? "");
}
async function sweep(T: number, seeds: number[]) {
  let exact = 0, reachedOpening = 0, crossedFork = 0, maxP = 0, maxSeed = -1, maxOut = "";
  for (const s of seeds) {
    const out = await chat(T, s); const p = cp(out, nT);
    if (out === nT) exact++;
    if (p >= FORK) reachedOpening++;          // reproduced the full distinctive opening
    if (p > FORK + 4) crossedFork++;          // got PAST the fork (temp picked "countless")
    if (p > maxP) { maxP = p; maxSeed = s; maxOut = out; }
  }
  return { T, n: seeds.length, exact, reachedOpening, crossedFork, maxP, maxSeed, maxOut };
}
function report(r: Awaited<ReturnType<typeof sweep>>) {
  console.log(`T=${r.T}  ${r.n} seeds → exact=${r.exact}  reached-opening(≥${FORK})=${r.reachedOpening}  crossed-fork=${r.crossedFork}  | deepest ${r.maxP} chars @seed ${r.maxSeed}`);
  if (r.maxP > FORK) console.log(`    past fork: …"${r.maxOut.slice(FORK, FORK + 70)}"`);
}

const range = (a: number, b: number) => Array.from({ length: b - a }, (_, i) => a + i);
console.log(`target opening through the fork (char ${FORK}): "${nT.slice(0, FORK)}|${nT.slice(FORK, FORK + 18)}…"\n`);

console.log("=== broad seed search at the best-tracking temperature ===");
report(await sweep(0.8, range(0, 300)));   // 300 fresh seeds at T=0.8

console.log("\n=== temp grid × seeds (does ANY temp+seed land it?) ===");
for (const T of [0.6, 1.0, 1.2]) report(await sweep(T, range(0, 80)));

console.log("\nIf exact=0 and crossed-fork=0 everywhere: pure temperature never produces the curve's sentence — at any seed.");
