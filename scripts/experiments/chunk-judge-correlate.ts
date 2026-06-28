// Correlate the cheap embedding signals against the per-conversation LLM-judge
// scores from the chunk-judge-correlation workflow. Joins by (variant, conv id):
//   cohesion axis: silhouette   vs judge cohesion_score (expect ρ > 0)
//   purity   axis: −intraSpread vs judge purity_score   (expect ρ > 0)
//
//   bun scripts/experiments/chunk-judge-correlate.ts <judgments.json>
//
// judgments.json = the workflow's returned array: [{variant, axis, id, score, count}, …]

export {}; // module (top-level await)

const SCRATCH = "/private/tmp/claude-501/-Users-joshrossi-Code-mlx-bun/f56d4770-e657-4b3b-93d9-3cbe0f4bb60d/scratchpad";
const judgments = (await Bun.file(process.argv[2] ?? `${SCRATCH}/judgments.json`).json()) as
  { variant: string; axis: string; id: string; score: number; count: number }[];
const feats = (await Bun.file(`${SCRATCH}/per-conv-feats.json`).json()) as
  Record<string, { id: string; name: string; silhouette: number | null; intraSpread: number }[]>;

const silBy = new Map<string, number>();      // `${variant}|${id}` → silhouette
const spreadBy = new Map<string, number>();
for (const [v, rows] of Object.entries(feats))
  for (const r of rows) { if (r.silhouette != null) silBy.set(`${v}|${r.id}`, r.silhouette); spreadBy.set(`${v}|${r.id}`, r.intraSpread); }

function spearman(xs: number[], ys: number[]): number {
  const rank = (a: number[]) => {
    const idx = a.map((v, i) => [v, i] as [number, number]).sort((p, q) => p[0] - q[0]);
    const r = Array(a.length).fill(0);
    for (let k = 0; k < idx.length;) {
      let j = k; while (j < idx.length && idx[j]![0] === idx[k]![0]) j++;
      const avg = (k + j - 1) / 2 + 1;
      for (let m = k; m < j; m++) r[idx[m]![1]] = avg;
      k = j;
    }
    return r;
  };
  const rx = rank(xs), ry = rank(ys), n = xs.length;
  const mx = rx.reduce((a, b) => a + b, 0) / n, my = ry.reduce((a, b) => a + b, 0) / n;
  let num = 0, dx = 0, dy = 0;
  for (let i = 0; i < n; i++) { num += (rx[i]! - mx) * (ry[i]! - my); dx += (rx[i]! - mx) ** 2; dy += (ry[i]! - my) ** 2; }
  return num / Math.sqrt(dx * dy);
}

// approx significance: t = ρ√((n-2)/(1-ρ²)); flag p<0.05 (|t|>~2.0 for n≈25, >~2.0 for n≈75).
const tStat = (rho: number, n: number) => rho * Math.sqrt((n - 2) / (1 - rho * rho));

const VARIANTS = ["base", "chunk-300", "chunk-400"];
function report(axis: string, feat: "sil" | "spread", expectSign: string) {
  const featName = feat === "sil" ? "silhouette" : "−intraSpread";
  const judgeName = axis === "cohesion" ? "cohesion_score" : "purity_score";
  console.log(`\n=== ${axis}: ρ(${featName}, judge ${judgeName})  [expect ${expectSign}] ===`);
  const pooledX: number[] = [], pooledY: number[] = [];
  for (const v of VARIANTS) {
    const xs: number[] = [], ys: number[] = [];
    for (const j of judgments.filter((j) => j.axis === axis && j.variant === v)) {
      const key = `${v}|${j.id}`;
      const f = feat === "sil" ? silBy.get(key) : spreadBy.has(key) ? -spreadBy.get(key)! : undefined;
      if (f == null) continue;
      xs.push(f); ys.push(j.score);
    }
    if (xs.length < 3) { console.log(`  ${v.padEnd(11)} n=${xs.length} (too few)`); continue; }
    const rho = spearman(xs, ys), t = tStat(rho, xs.length);
    console.log(`  ${v.padEnd(11)} n=${String(xs.length).padStart(2)}  ρ=${rho.toFixed(3).padStart(6)}  t=${t.toFixed(2).padStart(5)}  ${Math.abs(t) > 2 ? "✅ p<0.05" : "ns"}`);
    pooledX.push(...xs); pooledY.push(...ys);
  }
  const rho = spearman(pooledX, pooledY), t = tStat(rho, pooledX.length);
  console.log(`  ${"POOLED".padEnd(11)} n=${String(pooledX.length).padStart(2)}  ρ=${rho.toFixed(3).padStart(6)}  t=${t.toFixed(2).padStart(5)}  ${Math.abs(t) > 2 ? "✅ p<0.05" : "ns"}`);
}

console.log(`loaded ${judgments.length} judgments`);
const counts: Record<string, number> = {};
for (const j of judgments) counts[`${j.axis}|${j.variant}`] = (counts[`${j.axis}|${j.variant}`] ?? 0) + 1;
console.log("per group:", JSON.stringify(counts));
report("cohesion", "sil", "ρ > 0");
report("purity", "spread", "ρ > 0");
