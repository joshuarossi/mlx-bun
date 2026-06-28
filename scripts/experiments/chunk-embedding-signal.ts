// Cheap embedding signal for chunk quality vs the two LLM judges (HANDOFF step 3).
// Explores SEVERAL boundary-local distance features to find one whose per-variant
// ordering matches the judges — the v1 centroid-adjacency cohesion saturated.
//
//   bun scripts/experiments/chunk-embedding-signal.ts [--no-cache] [--dump]
//
// Embeddings are cached to scratchpad so metric iteration doesn't re-embed.
// Reads lucien data by absolute path (machine-specific, like scripts/chunk-eval.ts).

import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { embedMany, isEmbeddingModel } from "../../src/embed";
import { Glob } from "bun";

const LUCIEN = "/Users/joshrossi/Code/lucien/benchmark";
const DATASET = `${LUCIEN}/dataset/chunk.json`;
const GEN = (v: string) => `${LUCIEN}/results/chunk-eval/gen-e4b-${v}.json`;
const VARIANTS = ["base", "chunk-300", "chunk-400"] as const;
const CACHE = "/private/tmp/claude-501/-Users-joshrossi-Code-mlx-bun/f56d4770-e657-4b3b-93d9-3cbe0f4bb60d/scratchpad/turn-embeds.json";
const noCache = process.argv.includes("--no-cache");
const dump = process.argv.includes("--dump");

// Judge aggregates from the HANDOFF (isolated single-conversation LLM judges).
const JUDGE: Record<string, { chunks: number; purity: number; cohesion: number }> = {
  base: { chunks: 7.6, purity: 99.5, cohesion: 58.8 },
  "chunk-300": { chunks: 2.9, purity: 92.2, cohesion: 87.8 },
  "chunk-400": { chunks: 2.6, purity: 87.1, cohesion: 89.8 },
};

interface Msg { uuid: string; sender: string; text: string }
interface Conv { id: string; name: string; messages: Msg[] }
interface Chunk { start: number; end: number; label: string }

const dot = (a: Float32Array, b: Float32Array): number => {
  let s = 0;
  for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!;
  return s;
};
function centroid(vecs: Float32Array[]): Float32Array {
  const H = vecs[0]!.length;
  const c = new Float32Array(H);
  for (const v of vecs) for (let i = 0; i < H; i++) c[i]! += v[i]!;
  let n = 0;
  for (let i = 0; i < H; i++) n += c[i]! * c[i]!;
  n = Math.sqrt(n) || 1;
  for (let i = 0; i < H; i++) c[i]! /= n;
  return c;
}
const mean = (xs: number[]) => (xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : NaN);

const dataset = (await Bun.file(DATASET).json()) as Conv[];

// ---- embeddings (cached) ---------------------------------------------------
let turnVecs = new Map<string, Float32Array[]>();
if (!noCache && (await Bun.file(CACHE).exists())) {
  const raw = (await Bun.file(CACHE).json()) as Record<string, number[][]>;
  for (const [id, rows] of Object.entries(raw)) turnVecs.set(id, rows.map((r) => Float32Array.from(r)));
  console.log(`loaded ${turnVecs.size} conv embeddings from cache`);
} else {
  console.log(`embedding turns for ${dataset.length} conversations…`);
  const modelDir = await (async () => {
    const hub = `${process.env.HOME}/.cache/huggingface/hub`;
    for await (const f of new Glob("models--mlx-community--Qwen3-Embedding-*/snapshots/*/config.json").scan({ cwd: hub, absolute: true }))
      return f.replace(/\/config\.json$/, "");
    throw new Error("no Qwen3-Embedding snapshot");
  })();
  const model = createModel(await Weights.open(modelDir), await loadModelConfig(modelDir));
  if (!isEmbeddingModel(model)) throw new Error("not an embedding model");
  const tok = await loadTokenizer(modelDir);
  const out: Record<string, number[][]> = {};
  for (const conv of dataset) {
    const vecs = embedMany(model, tok, conv.messages.map((m) => `[${m.sender}] ${m.text}`)).map((r) => r.vector);
    turnVecs.set(conv.id, vecs);
    out[conv.id] = vecs.map((v) => Array.from(v));
  }
  await Bun.write(CACHE, JSON.stringify(out));
  console.log(`embedded + cached → ${CACHE}`);
}
const byId = new Map(dataset.map((c) => [c.id, c]));

// ---- per-conversation features for one chunking ----------------------------
interface Feats {
  nChunks: number;
  intraSpread: number;          // contamination (purity↓)
  boundaryPairSim: number | null;   // cos(last_left, first_right) at cuts (dispersion↑)
  boundaryContrast: number | null;  // within-adj cos − across-boundary-adj cos (cohesion↑)
  silhouette: number | null;        // mean per-turn (ownSim − bestOtherSim) (cohesion↑)
  misplaceRate: number | null;      // boundary msgs closer to neighbor centroid (dispersion↑)
}

function feats(vecs: Float32Array[], chunks0: Chunk[]): Feats | null {
  const M = vecs.length;
  const chunks = chunks0.filter((c) => c.start >= 0 && c.end < M && c.end >= c.start)
    .sort((a, b) => a.start - b.start);
  if (chunks.length === 0) return null;
  const centroids = chunks.map((c) => centroid(vecs.slice(c.start, c.end + 1)));

  // purity: intra-chunk spread.
  const intraSpread = mean(chunks.map((c, ci) => {
    const members = vecs.slice(c.start, c.end + 1);
    return members.length < 2 ? 0 : mean(members.map((m) => 1 - dot(m, centroids[ci]!)));
  }));

  // adjacent-message cosines along the whole conversation + which gaps are cuts.
  const adjCos: number[] = [];
  for (let i = 0; i < M - 1; i++) adjCos.push(dot(vecs[i]!, vecs[i + 1]!));
  const cutGap = new Set(chunks.slice(0, -1).map((c) => c.end)); // gap i↔i+1 is a cut if i == chunk.end

  const withinAdj: number[] = [], acrossAdj: number[] = [];
  for (let i = 0; i < adjCos.length; i++) (cutGap.has(i) ? acrossAdj : withinAdj).push(adjCos[i]!);

  const boundaryPairSim = acrossAdj.length ? mean(acrossAdj) : null;
  const boundaryContrast = (withinAdj.length && acrossAdj.length) ? mean(withinAdj) - mean(acrossAdj) : null;

  // silhouette per turn: ownSim − best other-chunk-centroid sim.
  const sil: number[] = [];
  chunks.forEach((c, ci) => {
    for (let m = c.start; m <= c.end; m++) {
      const own = dot(vecs[m]!, centroids[ci]!);
      let best = -Infinity;
      centroids.forEach((cen, cj) => { if (cj !== ci) best = Math.max(best, dot(vecs[m]!, cen)); });
      if (best > -Infinity) sil.push(own - best);
    }
  });
  const silhouette = sil.length ? mean(sil) : null;

  // misplacement: a cut's straddling messages closer to the OTHER chunk's centroid.
  let misN = 0, misTot = 0;
  for (let ci = 0; ci < chunks.length - 1; ci++) {
    const L = chunks[ci]!.end, R = chunks[ci + 1]!.start;
    misTot += 2;
    if (dot(vecs[L]!, centroids[ci + 1]!) > dot(vecs[L]!, centroids[ci]!)) misN++;
    if (dot(vecs[R]!, centroids[ci]!) > dot(vecs[R]!, centroids[ci + 1]!)) misN++;
  }
  const misplaceRate = misTot ? misN / misTot : null;

  return { nChunks: chunks.length, intraSpread, boundaryPairSim, boundaryContrast, silhouette, misplaceRate };
}

// ---- aggregate per variant -------------------------------------------------
const perConvOut: Record<string, { id: string; name: string; silhouette: number | null; intraSpread: number }[]> = {};
const agg: Record<string, Record<keyof Feats, number>> = {};
for (const v of VARIANTS) {
  const gen = (await Bun.file(GEN(v)).json()) as { convs: { id: string; chunks: Chunk[] }[] };
  const rows: Feats[] = [];
  perConvOut[v] = [];
  for (const gc of gen.convs) {
    const conv = byId.get(gc.id);
    if (!conv) continue;
    const f = feats(turnVecs.get(gc.id)!, gc.chunks);
    if (f) { rows.push(f); perConvOut[v]!.push({ id: gc.id, name: conv.name, silhouette: f.silhouette, intraSpread: f.intraSpread }); }
  }
  const col = (k: keyof Feats) => mean(rows.map((r) => r[k]).filter((x): x is number => x != null));
  agg[v] = {
    nChunks: col("nChunks"), intraSpread: col("intraSpread"), boundaryPairSim: col("boundaryPairSim"),
    boundaryContrast: col("boundaryContrast"), silhouette: col("silhouette"), misplaceRate: col("misplaceRate"),
  } as Record<keyof Feats, number>;
}

if (process.argv.includes("--per-conv")) {
  const PCOUT = CACHE.replace("turn-embeds.json", "per-conv-feats.json");
  await Bun.write(PCOUT, JSON.stringify(perConvOut, null, 1));
  console.log(`per-conv features → ${PCOUT}`);
}

// ---- report ----------------------------------------------------------------
console.log("\n=== raw per-variant features (means over 25 convs) ===");
console.log("variant     | chunks | intraSpread | bndPairSim | bndContrast | silhouette | misplace");
for (const v of VARIANTS) {
  const a = agg[v]!;
  console.log(
    `${v.padEnd(11)} | ${a.nChunks.toFixed(2).padStart(5)}  | ${a.intraSpread.toFixed(4).padStart(10)}  | ` +
    `${a.boundaryPairSim.toFixed(4).padStart(9)}  | ${a.boundaryContrast.toFixed(4).padStart(10)}  | ` +
    `${a.silhouette.toFixed(4).padStart(9)}  | ${a.misplaceRate.toFixed(4).padStart(7)}`,
  );
}

// Map each feature → a cohesion-direction value (higher = more cohesive) and
// check ordering vs the judge cohesion ranking (base < 300 < 400).
const order = (vals: Record<string, number>) => [...VARIANTS].sort((a, b) => vals[a]! - vals[b]!).join(" < ");
const judgeCohOrder = order(Object.fromEntries(VARIANTS.map((v) => [v, JUDGE[v]!.cohesion])));
const judgePurOrder = order(Object.fromEntries(VARIANTS.map((v) => [v, JUDGE[v]!.purity])));

const cohesionCandidates: Record<string, (a: Record<keyof Feats, number>) => number> = {
  "1 − boundaryPairSim": (a) => 1 - a.boundaryPairSim,
  "boundaryContrast":    (a) => a.boundaryContrast,
  "silhouette":          (a) => a.silhouette,
  "1 − misplaceRate":    (a) => 1 - a.misplaceRate,
};
console.log(`\n=== cohesion: judge order = ${judgeCohOrder} ===`);
for (const [name, fn] of Object.entries(cohesionCandidates)) {
  const vals = Object.fromEntries(VARIANTS.map((v) => [v, fn(agg[v]!)]));
  const o = order(vals);
  console.log(`  ${o === judgeCohOrder ? "✅" : "❌"} ${name.padEnd(20)} ${o}   [${VARIANTS.map((v) => vals[v]!.toFixed(3)).join(", ")}]`);
}
const purVals = Object.fromEntries(VARIANTS.map((v) => [v, -agg[v]!.intraSpread]));
console.log(`\n=== purity: judge order = ${judgePurOrder} ===`);
console.log(`  ${order(purVals) === judgePurOrder ? "✅" : "❌"} −intraSpread        ${order(purVals)}`);

// ---- sanity: do the distances make sense? print adjacency profiles ---------
if (dump) {
  console.log("\n=== adjacency profiles (| = a cut in base) — do cuts land at dips? ===");
  for (const name of ["Mud versus clay differences", "File Size Creation Date"]) {
    const conv = dataset.find((c) => c.name === name);
    if (!conv) continue;
    const vecs = turnVecs.get(conv.id)!;
    const gen = (await Bun.file(GEN("base")).json()) as { convs: { id: string; chunks: Chunk[] }[] };
    const cuts = new Set((gen.convs.find((c) => c.id === conv.id)?.chunks ?? []).slice(0, -1).map((c) => c.end));
    const seq = [];
    for (let i = 0; i < vecs.length - 1; i++) seq.push(`${dot(vecs[i]!, vecs[i + 1]!).toFixed(2)}${cuts.has(i) ? " |" : "  "}`);
    console.log(`  [${name}] adj-cos: ${seq.join(" ")}`);
  }
}
