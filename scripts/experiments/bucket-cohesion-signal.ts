// Bucketing-stage eval instrument (step 1 of docs/design/bucketing-stage.md).
// Measures the EMBEDDING SHORTLIST RECALL CEILING for chunk→bucket: if a chunk's
// gold bucket isn't in its embedding top-K, no number of tiny binary checks can
// recover it. This verifies the foundation of the "narrow then decide" design
// BEFORE we build the binary-check machinery on it.
//
//   bun scripts/experiments/bucket-cohesion-signal.ts [--full] [--no-cache]
//
// Reads Lucien's cloud ground truth (lucien.db) read-only. Embeddings are the
// TEST instrument only — production classify is the local LLM, not this.

import { Database } from "bun:sqlite";
import { loadModelConfig } from "../../src/config";
import { Weights } from "../../src/weights";
import { createModel } from "../../src/model/factory";
import { loadTokenizer } from "../../src/tokenizer";
import { embedMany, isEmbeddingModel } from "../../src/embed";
import { Glob } from "bun";

const LUCIEN_DB = "/Users/joshrossi/Code/lucien/.lucien/lucien.db";
const SCRATCH = "/private/tmp/claude-501/-Users-joshrossi-Code-mlx-bun/f56d4770-e657-4b3b-93d9-3cbe0f4bb60d/scratchpad";
const CACHE = `${SCRATCH}/bucket-stage-embeds.json`;
const full = process.argv.includes("--full");
const noCache = process.argv.includes("--no-cache");
const SAMPLE = full ? Infinity : 2000;
const KS = [5, 8, 12, 20, 50];

interface Bucket { name: string; description: string }
interface Chunk { id: number; label: string }

const db = new Database(LUCIEN_DB, { readonly: true });
const buckets = db.query("SELECT name, description FROM buckets").all() as Bucket[];
const chunks = db.query("SELECT id, label FROM chunks WHERE label IS NOT NULL AND label != ''").all() as Chunk[];
const edges = db.query("SELECT chunk_id, bucket_name FROM chunk_buckets").all() as { chunk_id: number; bucket_name: string }[];
db.close();

const bucketNames = new Set(buckets.map((b) => b.name));
const chunkById = new Map(chunks.map((c) => [c.id, c]));
// gold edges (valid only) + per-chunk gold buckets + per-bucket member count.
const goldByChunk = new Map<number, string[]>();
const bucketSize = new Map<string, number>();
let validEdges = 0;
for (const e of edges) {
  if (!chunkById.has(e.chunk_id) || !bucketNames.has(e.bucket_name)) continue;
  validEdges++;
  (goldByChunk.get(e.chunk_id) ?? goldByChunk.set(e.chunk_id, []).get(e.chunk_id)!).push(e.bucket_name);
  bucketSize.set(e.bucket_name, (bucketSize.get(e.bucket_name) ?? 0) + 1);
}
console.log(`lucien.db: ${buckets.length} buckets, ${chunks.length} labeled chunks, ${validEdges} valid edges`);

// Bucket size bins (a bucket's gold member count) — fix C: tail must not be hidden.
const binOf = (n: number) => (n === 1 ? "1" : n <= 4 ? "2-4" : n <= 20 ? "5-20" : n <= 100 ? "21-100" : "100+");

// Stratify the chunk sample by gold-bucket-size-bin so the tail is represented.
const assigned = chunks.filter((c) => goldByChunk.has(c.id));
const sampled = assigned.length <= SAMPLE ? assigned : (() => {
  // deterministic stratified pick: sort by (bin, id), take every Nth
  const step = assigned.length / SAMPLE;
  const byBin = [...assigned].sort((a, b) => {
    const ba = binOf(Math.max(...goldByChunk.get(a.id)!.map((g) => bucketSize.get(g)!)));
    const bb = binOf(Math.max(...goldByChunk.get(b.id)!.map((g) => bucketSize.get(g)!)));
    return ba < bb ? -1 : ba > bb ? 1 : a.id - b.id;
  });
  return byBin.filter((_, i) => Math.floor(i / step) !== Math.floor((i - 1) / step));
})();
console.log(`${assigned.length} assigned chunks; embedding ${sampled.length === assigned.length ? "ALL" : sampled.length} (stratified) + ${buckets.length} bucket descriptions`);

// ---- embeddings (cached by string) -----------------------------------------
const needed = new Set<string>();
for (const b of buckets) needed.add(`B::${b.name}: ${b.description}`);
for (const c of sampled) needed.add(`L::${c.label}`);

let cache: Record<string, number[]> = {};
if (!noCache && (await Bun.file(CACHE).exists())) cache = (await Bun.file(CACHE).json()) as Record<string, number[]>;
const missing = [...needed].filter((s) => !cache[s]);
if (missing.length > 0) {
  console.log(`embedding ${missing.length} new strings (${needed.size - missing.length} cached)…`);
  const modelDir = await (async () => {
    const hub = `${process.env.HOME}/.cache/huggingface/hub`;
    for await (const f of new Glob("models--mlx-community--Qwen3-Embedding-*/snapshots/*/config.json").scan({ cwd: hub, absolute: true }))
      return f.replace(/\/config\.json$/, "");
    throw new Error("no Qwen3-Embedding snapshot");
  })();
  const model = createModel(await Weights.open(modelDir), await loadModelConfig(modelDir));
  if (!isEmbeddingModel(model)) throw new Error("not an embedding model");
  const tok = await loadTokenizer(modelDir);
  const texts = missing.map((s) => s.slice(3)); // strip B::/L:: prefix
  const CHUNK = 256;
  for (let i = 0; i < texts.length; i += CHUNK) {
    const res = embedMany(model, tok, texts.slice(i, i + CHUNK));
    res.forEach((r, j) => { cache[missing[i + j]!] = Array.from(r.vector); });
    if (i % 1024 === 0) console.log(`  ${Math.min(i + CHUNK, texts.length)}/${texts.length}`);
  }
  await Bun.write(CACHE, JSON.stringify(cache));
  console.log(`cached → ${CACHE}`);
}
const vec = (s: string) => Float32Array.from(cache[s]!);
const dot = (a: Float32Array, b: Float32Array) => { let s = 0; for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!; return s; };

// ---- two bucket representations: (1) name:desc, (2) member-centroid (LOO) ---
const H = vec(`B::${buckets[0]!.name}: ${buckets[0]!.description}`).length;
const descVec = new Map(buckets.map((b) => [b.name, vec(`B::${b.name}: ${b.description}`)]));

// member sums over ALL embedded member labels (complete only under --full).
const memSum = new Map<string, Float32Array>(), memCount = new Map<string, number>();
const memberOf = new Map<number, Set<string>>(); // chunk id → buckets it's a member of (for LOO)
let memberComplete = true;
for (const e of edges) {
  if (!chunkById.has(e.chunk_id) || !bucketNames.has(e.bucket_name)) continue;
  const key = `L::${chunkById.get(e.chunk_id)!.label}`;
  if (!cache[key]) { memberComplete = false; continue; }
  const v = vec(key);
  let s = memSum.get(e.bucket_name);
  if (!s) { s = new Float32Array(H); memSum.set(e.bucket_name, s); memCount.set(e.bucket_name, 0); }
  for (let i = 0; i < H; i++) s[i]! += v[i]!;
  memCount.set(e.bucket_name, memCount.get(e.bucket_name)! + 1);
  (memberOf.get(e.chunk_id) ?? memberOf.set(e.chunk_id, new Set()).get(e.chunk_id)!).add(e.bucket_name);
}
const doMember = full && memberComplete;
const norm = (a: Float32Array) => { let n = 0; for (const x of a) n += x * x; n = Math.sqrt(n) || 1; const o = new Float32Array(a.length); for (let i = 0; i < a.length; i++) o[i] = a[i]! / n; return o; };

const bins = ["1", "2-4", "5-20", "21-100", "100+"];
function recall(label: string, score: (cv: Float32Array, cid: number, b: string) => number) {
  const tally: Record<string, { edges: number; hit: Record<number, number>; rankSum: number }> = {};
  for (const bin of [...bins, "ALL"]) tally[bin] = { edges: 0, hit: Object.fromEntries(KS.map((k) => [k, 0])), rankSum: 0 };
  for (const c of sampled) {
    const cv = vec(`L::${c.label}`);
    const ranked = buckets.map((b) => ({ name: b.name, s: score(cv, c.id, b.name) })).sort((a, b) => b.s - a.s);
    const rankOf = new Map(ranked.map((r, i) => [r.name, i + 1]));
    for (const gold of goldByChunk.get(c.id)!) {
      const rank = rankOf.get(gold)!, bin = binOf(bucketSize.get(gold)!);
      for (const t of [tally[bin]!, tally.ALL!]) { t.edges++; t.rankSum += rank; for (const k of KS) if (rank <= k) t.hit[k]!++; }
    }
  }
  console.log(`\n=== recall ceiling: gold bucket in chunk-label top-K — ${label} ===`);
  console.log(`bin       |  edges |  ${KS.map((k) => `@${k}`.padStart(6)).join(" ")} | meanRank`);
  for (const bin of [...bins, "ALL"]) {
    const t = tally[bin]!;
    if (t.edges === 0) { console.log(`${bin.padEnd(9)} |      0 |`); continue; }
    console.log(`${bin.padEnd(9)} | ${String(t.edges).padStart(6)} |  ${KS.map((k) => `${(100 * t.hit[k]! / t.edges).toFixed(1)}%`.padStart(6)).join(" ")} | ${(t.rankSum / t.edges).toFixed(1)}`);
  }
  console.log(`HEADLINE ${label}: gold-in-top-12 = ${(100 * tally.ALL!.hit[12]! / tally.ALL!.edges).toFixed(1)}%`);
}

recall("name:desc centroids", (cv, _cid, b) => dot(cv, descVec.get(b)!));
if (doMember) {
  recall("member-centroid (leave-one-out)", (cv, cid, b) => {
    const sum = memSum.get(b)!, cnt = memCount.get(b)!;
    const isMember = memberOf.get(cid)?.has(b);
    const n = cnt - (isMember ? 1 : 0);
    if (n <= 0) return -2; // bucket would be empty without this chunk
    const c = new Float32Array(H);
    for (let i = 0; i < H; i++) c[i] = (sum[i]! - (isMember ? cv[i]! : 0)) / n;
    return dot(cv, norm(c));
  });
} else {
  console.log(`\n(member-centroid skipped — needs --full so every bucket's members are embedded; rerun with --full)`);
}
