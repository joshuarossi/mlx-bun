// P4-T2 · No-vector routing proof.
//
// Proves the deterministic name-match router (normalize → alias-lookup →
// trigram-shortlist → binary "same thing?" disambiguation) routes chunks to the
// articles they are about MORE PRECISELY than a vector top-K router — and
// measures the retrieval ceiling (oracle shortlist) that decides whether a
// disambiguation LoRA is even needed.
//
// Two PHASES, run as SEPARATE processes so the embedding model and e4b are NEVER
// co-resident (embeddings are an OFFLINE INSTRUMENT only, never the router):
//   bun scripts/memory/eval-route.ts --phase embed   # loads Qwen3-Embedding ONLY
//   bun scripts/memory/eval-route.ts --phase route   # loads Gemma-4-e4b ONLY
//
// Tractability: the binary disambig + embedding over the full ~7000-chunk corpus
// is too many GPU calls, so P4-T2 runs a DETERMINISTIC STRATIFIED SAMPLE across
// the 5 bucket-size bins (P4-T1 stays full-corpus). Exact sample + per-bin counts
// + live corpus COUNT(*) are logged — no silent truncation.
//
// Gates: name-match real-F1 > embedding-cosine F1, AND oracle-F1 ≥ 0.85.
// Writes reports/dreaming/p4-routing.md and appends research-journal.md.

import { mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { Glob } from "bun";
import {
  EntityIndex,
  loadEntities,
  loadGoldCorpus,
  chunkBin,
  normalize,
  BIN_ORDER,
  type Bin,
  type GoldCorpus,
} from "./dreaming-lex";

const ROOT = join(import.meta.dir, "..", "..");
const ENTITIES = join(ROOT, "goldens", "entities.json");
const REPORT_DIR = join(ROOT, "reports", "dreaming");
const CACHE = join(REPORT_DIR, ".p4-embed-cache.json");
const REPORT = join(REPORT_DIR, "p4-routing.md");
const JOURNAL = join(REPORT_DIR, "research-journal.md");
const NAME_RECALL_JSON = join(REPORT_DIR, "p4-name-recall.json");

// Knobs. K_SHORTLIST = trigram candidates fed to the binary disambiguator (set
// from the P4-T1 recall elbow). EMB_KS = the vector-router operating points swept
// for its BEST-case F1 (most charitable baseline to beat).
const TARGET_SAMPLE = 400;
const BIN_FLOOR = 30; // min chunks per non-empty bin so the <5 tail is measurable
const K_SHORTLIST = 10;
const EMB_KS = [1, 2, 3, 5, 8, 12];

const phase = process.argv.includes("--phase")
  ? process.argv[process.argv.indexOf("--phase") + 1]
  : undefined;
if (phase !== "embed" && phase !== "route") {
  console.error("usage: bun scripts/memory/eval-route.ts --phase <embed|route>");
  process.exit(1);
}

// ---- shared: build the deterministic stratified sample ---------------------
interface SampleInfo {
  ids: number[];
  perBin: Record<string, number>;
  corpus: GoldCorpus["counts"];
}

function buildSample(idx: EntityIndex, corpus: GoldCorpus): SampleInfo {
  const byBin = new Map<Bin, number[]>();
  for (const [cid, gold] of corpus.goldByChunk) {
    const b = chunkBin(gold, corpus.entitySize);
    (byBin.get(b) ?? byBin.set(b, []).get(b)!).push(cid);
  }
  const total = corpus.goldByChunk.size;
  const ids: number[] = [];
  const perBin: Record<string, number> = {};
  for (const bin of BIN_ORDER) {
    const pool = (byBin.get(bin) ?? []).sort((a, b) => a - b);
    if (pool.length === 0) continue;
    const take = Math.min(pool.length, Math.max(BIN_FLOOR, Math.round((TARGET_SAMPLE * pool.length) / total)));
    // Even deterministic spread across the id-sorted pool.
    for (let i = 0; i < take; i++) ids.push(pool[Math.floor((i * pool.length) / take)]!);
    perBin[bin] = take;
  }
  ids.sort((a, b) => a - b);
  return { ids, perBin, corpus: corpus.counts };
}

// ---- micro-F1 over a predicted/gold set per chunk --------------------------
function microF1(preds: Map<number, Set<string>>, golds: Map<number, Set<string>>) {
  let tp = 0;
  let fp = 0;
  let fn = 0;
  let jSum = 0;
  let n = 0;
  for (const [cid, gold] of golds) {
    const pred = preds.get(cid) ?? new Set<string>();
    let inter = 0;
    for (const p of pred) (gold.has(p) ? (inter++, tp++) : fp++);
    fn += gold.size - inter;
    const union = pred.size + gold.size - inter;
    jSum += union === 0 ? 1 : inter / union;
    n++;
  }
  const precision = tp + fp === 0 ? 0 : tp / (tp + fp);
  const recall = tp + fn === 0 ? 0 : tp / (tp + fn);
  const f1 = precision + recall === 0 ? 0 : (2 * precision * recall) / (precision + recall);
  return { precision, recall, f1, meanJaccard: n === 0 ? 0 : jSum / n, tp, fp, fn };
}

const idx = new EntityIndex(await loadEntities(ENTITIES));
const corpus = loadGoldCorpus(idx);
const sample = buildSample(idx, corpus);
const goldSample = new Map<number, Set<string>>();
for (const cid of sample.ids) goldSample.set(cid, corpus.goldByChunk.get(cid)!);

console.log(
  `lucien.db (live COUNT): ${corpus.counts.labeledChunks} labeled chunks, ` +
    `${corpus.counts.validEdges} valid gold edges over ${corpus.counts.chunksWithGold} chunks.`,
);
console.log(
  `stratified sample: ${sample.ids.length} chunks — per bin ` +
    BIN_ORDER.map((b) => `${b}:${sample.perBin[b] ?? 0}`).join(" "),
);

// ===========================================================================
// PHASE embed — Qwen3-Embedding ONLY. Vector top-K baseline (the router beaten).
// ===========================================================================
if (phase === "embed") {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { embedMany, isEmbeddingModel, resetEmbedCounter, getEmbedCounter } = await import("../../src/embed");

  const modelDir = await (async () => {
    const hub = `${process.env.HOME}/.cache/huggingface/hub`;
    for await (const f of new Glob("models--mlx-community--Qwen3-Embedding-*/snapshots/*/config.json").scan({
      cwd: hub,
      absolute: true,
    }))
      return f.replace(/\/config\.json$/, "");
    throw new Error("no Qwen3-Embedding snapshot on disk");
  })();
  const model = createModel(await Weights.open(modelDir), await loadModelConfig(modelDir));
  if (!isEmbeddingModel(model)) throw new Error("not an embedding model");
  const tok = await loadTokenizer(modelDir);
  resetEmbedCounter();

  const entityNames = idx.entities.map((e) => e.name);
  const ROUTE_INSTR = "Given a conversation topic, retrieve the names of the wiki articles it is about";
  console.log(`embedding ${entityNames.length} entity names (documents)…`);
  const entVecs = embedMany(model, tok, entityNames).map((r) => r.vector);
  const labels = sample.ids.map((cid) => corpus.label.get(cid)!);
  console.log(`embedding ${labels.length} chunk labels (queries, routing instruction)…`);
  const labVecs = embedMany(model, tok, labels, ROUTE_INSTR).map((r) => r.vector);
  console.log(`embedOne tripwire count = ${getEmbedCounter()} (instrument only — never the router)`);

  const dot = (a: Float32Array, b: Float32Array) => {
    let s = 0;
    for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!;
    return s;
  };
  // Per-chunk: entities ranked by cosine; predict top-K for each swept K.
  const rankedPerChunk = labVecs.map((lv) =>
    entVecs
      .map((ev, i) => ({ name: entityNames[i]!, s: dot(lv, ev) }))
      .sort((a, b) => b.s - a.s)
      .map((x) => x.name),
  );
  const sweep = EMB_KS.map((k) => {
    const preds = new Map<number, Set<string>>();
    sample.ids.forEach((cid, j) => preds.set(cid, new Set(rankedPerChunk[j]!.slice(0, k))));
    const m = microF1(preds, goldSample);
    return { k, ...m };
  });
  const best = sweep.reduce((a, b) => (b.f1 > a.f1 ? b : a));
  console.log(`\n=== embedding-cosine top-K baseline (sample) ===`);
  console.log(`  K | precision | recall | F1`);
  for (const s of sweep)
    console.log(`${String(s.k).padStart(3)} | ${s.precision.toFixed(3)}     | ${s.recall.toFixed(3)}  | ${s.f1.toFixed(3)}`);
  console.log(`BEST embedding-cosine F1 = ${best.f1.toFixed(3)} @ K=${best.k}`);

  mkdirSync(REPORT_DIR, { recursive: true });
  await Bun.write(
    CACHE,
    JSON.stringify(
      {
        sampleIds: sample.ids,
        perBin: sample.perBin,
        corpus: corpus.counts,
        embedTripwire: getEmbedCounter(),
        instruction: ROUTE_INSTR,
        sweep,
        best,
      },
      null,
      2,
    ) + "\n",
  );
  console.log(`\nembed cache → ${CACHE}`);
  process.exit(0);
}

// ===========================================================================
// PHASE route — Gemma-4-e4b ONLY. Deterministic shortlist + binary disambig.
// ===========================================================================
const { callLocal } = await import("../../src/memory/model");
const { parseBinary } = await import("../../src/memory/parse");

if (!existsSync(CACHE)) {
  console.error(`missing ${CACHE} — run "--phase embed" first.`);
  process.exit(1);
}
interface Cache {
  sampleIds: number[];
  perBin: Record<string, number>;
  corpus: GoldCorpus["counts"];
  embedTripwire: number;
  sweep: { k: number; precision: number; recall: number; f1: number }[];
  best: { k: number; precision: number; recall: number; f1: number };
}
const cache = (await Bun.file(CACHE).json()) as Cache;
// Re-derive the sample from the cache so embed/route phases agree exactly.
const sampleIds = cache.sampleIds;

// Binary disambiguation, memoized per (chunk, candidate).
const binaryCache = new Map<string, boolean>();
let modelCalls = 0;
async function sameThing(chunkId: number, label: string, candidate: string): Promise<boolean> {
  const key = `${chunkId}::${candidate}`;
  const hit = binaryCache.get(key);
  if (hit !== undefined) return hit;
  // No entity-extraction stage yet in P4 → the chunk's surface IS its label.
  const prompt = `A conversation chunk is titled: "${label}". Is this chunk about "${candidate}"? Answer yes or no.`;
  const out = await callLocal("route", { user: prompt }, { maxTokens: 4 });
  const yes = parseBinary(out);
  binaryCache.set(key, yes);
  modelCalls++;
  return yes;
}

const realPreds = new Map<number, Set<string>>();
const oraclePreds = new Map<number, Set<string>>();

let done = 0;
for (const cid of sampleIds) {
  const label = corpus.label.get(cid)!;
  const gold = corpus.goldByChunk.get(cid)!;
  const normLabel = normalize(label);

  // Deterministic stages: exact alias hit (auto-accept), then trigram shortlist.
  const aliasHit = idx.surfaceToName.get(normLabel);
  const shortlist = idx.topK(label, K_SHORTLIST).map((r) => r.name);
  const realCandidates = new Set<string>(shortlist);
  if (aliasHit) realCandidates.add(aliasHit);
  const oracleCandidates = new Set<string>([...realCandidates, ...gold]);

  const real = new Set<string>();
  if (aliasHit) real.add(aliasHit);
  for (const c of realCandidates) {
    if (c === aliasHit) continue; // alias hit already accepted
    if (await sameThing(cid, label, c)) real.add(c);
  }
  realPreds.set(cid, real);

  const oracle = new Set<string>();
  if (aliasHit) oracle.add(aliasHit);
  for (const c of oracleCandidates) {
    if (c === aliasHit) continue;
    if (await sameThing(cid, label, c)) oracle.add(c);
  }
  oraclePreds.set(cid, oracle);

  if (++done % 25 === 0) console.log(`  routed ${done}/${sampleIds.length} chunks (${modelCalls} model calls)`);
}

const real = microF1(realPreds, goldSample);
const oracle = microF1(oraclePreds, goldSample);
const embBest = cache.best;

console.log(`\n=== P4-T2 routing F1 (sample n=${sampleIds.length}) ===`);
console.log(`name-match  real   : P ${real.precision.toFixed(3)} R ${real.recall.toFixed(3)} F1 ${real.f1.toFixed(3)} · Jaccard ${real.meanJaccard.toFixed(3)}`);
console.log(`name-match  oracle : P ${oracle.precision.toFixed(3)} R ${oracle.recall.toFixed(3)} F1 ${oracle.f1.toFixed(3)}`);
console.log(`embedding-cosine   : F1 ${embBest.f1.toFixed(3)} @K=${embBest.k} (best of ${EMB_KS.join(",")})`);
console.log(`model calls (maxTokens=4): ${modelCalls}`);

const gateBeatsEmbedding = real.f1 > embBest.f1;
const gateOracle = oracle.f1 >= 0.85;
const gatesPassed = gateBeatsEmbedding && gateOracle;
console.log(
  `GATES: name-match>embedding ${gateBeatsEmbedding ? "PASS" : "FAIL"} (${real.f1.toFixed(3)} vs ${embBest.f1.toFixed(3)}) · ` +
    `oracle≥0.85 ${gateOracle ? "PASS" : "FAIL"} (${oracle.f1.toFixed(3)}) → ${gatesPassed ? "PASS" : "FAIL"}`,
);

// ---- fold in P4-T1 recall + write the durable report -----------------------
interface NameRecall {
  K: number;
  KS: number[];
  counts: GoldCorpus["counts"];
  entityVocab: number;
  overall: Record<string, number>;
  perBin: Record<string, Record<string, number>>;
  edgesPerBin: Record<string, number>;
  meanRankPerBin: Record<string, number | null>;
  headline: { overall: number; perBin: Record<string, number>; worstBin: number; fallbackNeeded: boolean };
}
const nr = existsSync(NAME_RECALL_JSON) ? ((await Bun.file(NAME_RECALL_JSON).json()) as NameRecall) : null;

const pct = (x: number) => `${(100 * x).toFixed(1)}%`;
const now = new Date().toISOString().slice(0, 10);
let md = `# P4 — No-vector routing proof (The Dreaming)\n\n`;
md += `_Generated ${now}. All corpus counts are live \`SELECT COUNT(*)\` from \`.lucien/lucien.db\` — never the 8809/7316/2063 literals._\n\n`;
md += `**Corpus (live):** ${corpus.counts.buckets} buckets, ${corpus.counts.labeledChunks} labeled chunks, ${corpus.counts.rawEdges} raw chunk_buckets edges → **${corpus.counts.validEdges} valid gold edges** over **${corpus.counts.chunksWithGold} chunks**; ${corpus.counts.matchedBuckets}/${corpus.counts.buckets} buckets alias-matched to ${idx.entities.length} gold entities (goldens/entities.json).\n\n`;

if (nr) {
  md += `## P4-T1 — Lexical-shortlist recall ceiling (FULL corpus, pure lexical: trigram + token-overlap, no model/embeddings)\n\n`;
  md += `Query = chunk label; ranked over the ${nr.entityVocab}-entity vocabulary; recall = gold entity in top-K.\n\n`;
  md += `| bin | edges | ${nr.KS.map((k) => `@${k}`).join(" | ")} | meanRank |\n`;
  md += `|-----|------:|${nr.KS.map(() => "----:").join("|")}|------:|\n`;
  for (const b of [...BIN_ORDER, "ALL"]) {
    const e = nr.edgesPerBin[b] ?? 0;
    if (!e) continue;
    const row = nr.KS.map((k) => pct((b === "ALL" ? nr.overall[String(k)]! : nr.perBin[b]?.[String(k)]) ?? 0));
    md += `| ${b} | ${e} | ${row.join(" | ")} | ${(nr.meanRankPerBin[b] ?? 0)!.toFixed(1)} |\n`;
  }
  md += `\n**Recall@${nr.K}: overall ${pct(nr.headline.overall)}, worst bin ${pct(nr.headline.worstBin)}.**\n\n`;
}

md += `## P4-T2 — Routing F1 (deterministic name-match vs vector baseline)\n\n`;
md += `**Sample:** ${sampleIds.length} chunks, deterministic stratified across bucket-size bins (proportional, floor ${BIN_FLOOR}/bin so the <5 tail is measurable): `;
md += BIN_ORDER.map((b) => `${b}:${cache.perBin[b] ?? 0}`).join(", ") + `.\n`;
md += `Binary disambiguation: \`callLocal("route", …, {maxTokens:4})\` on base Gemma-4-e4b (no memory-route adapter), parsed by \`parseBinary\`. Shortlist K=${K_SHORTLIST}. Model calls: ${modelCalls}.\n`;
md += `Embedding baseline tripwire: ${cache.embedTripwire} \`embedOne\` calls — OFFLINE INSTRUMENT, never the router.\n\n`;
md += `| router | precision | recall | F1 | mean Jaccard |\n`;
md += `|--------|----------:|-------:|---:|-------------:|\n`;
md += `| **name-match (real shortlist)** | ${real.precision.toFixed(3)} | ${real.recall.toFixed(3)} | **${real.f1.toFixed(3)}** | ${real.meanJaccard.toFixed(3)} |\n`;
md += `| name-match (oracle shortlist) | ${oracle.precision.toFixed(3)} | ${oracle.recall.toFixed(3)} | ${oracle.f1.toFixed(3)} | ${oracle.meanJaccard.toFixed(3)} |\n`;
md += `| embedding-cosine (best of K=${EMB_KS.join("/")}) | ${embBest.precision.toFixed(3)} | ${embBest.recall.toFixed(3)} | ${embBest.f1.toFixed(3)} | — |\n\n`;
md += `Embedding-cosine sweep (most-charitable baseline): ` + cache.sweep.map((s) => `K${s.k}=${s.f1.toFixed(3)}`).join(", ") + `.\n`;
md += `Retrieval tax (oracle − real F1) = ${(oracle.f1 - real.f1).toFixed(3)}.\n\n`;

md += `## Gates\n\n`;
md += `- name-match real-F1 > embedding-cosine F1: **${gateBeatsEmbedding ? "PASS" : "FAIL"}** (${real.f1.toFixed(3)} vs ${embBest.f1.toFixed(3)})\n`;
md += `- oracle-F1 ≥ 0.85: **${gateOracle ? "PASS" : "FAIL"}** (${oracle.f1.toFixed(3)})\n`;
md += `- **Overall: ${gatesPassed ? "PASS" : "FAIL"}**\n\n`;

md += `## Fallback DECISION\n\n`;
if (nr) {
  const failing = Object.entries(nr.headline.perBin)
    .filter(([, v]) => v < 0.8)
    .map(([b]) => b);
  const need = nr.headline.fallbackNeeded;
  md += `Rule: lexical recall@${nr.K} ≥ 0.90 overall AND ≥ 0.80 in every size-bin → NO embedding fallback; else fallback NEEDED scoped to failing bin(s) (offline instrument only, tripwire still applies).\n\n`;
  md += `Measured: overall ${pct(nr.headline.overall)}, worst bin ${pct(nr.headline.worstBin)}. `;
  md += need
    ? `**Fallback NEEDED**, scoped to bin(s): ${failing.length ? failing.join(", ") : "(overall miss)"} — narrow embedding shortlister as an OFFLINE instrument, never the router.\n`
    : `**NO embedding fallback** — lexical recall clears the bar in every bin.\n`;
} else {
  md += `(P4-T1 artifact ${NAME_RECALL_JSON} not found — run eval-name-recall.ts to populate the recall table + decision.)\n`;
}

mkdirSync(REPORT_DIR, { recursive: true });
await Bun.write(REPORT, md);
console.log(`\nreport → ${REPORT}`);

// ---- append a dated research-journal entry ---------------------------------
let journal = existsSync(JOURNAL) ? await Bun.file(JOURNAL).text() : `# The Dreaming — research journal\n`;
journal += `\n## ${now} — P4 routing instruments (T1 recall ceiling + T2 no-vector proof)\n\n`;
journal += `- Corpus (live): ${corpus.counts.validEdges} valid gold edges over ${corpus.counts.chunksWithGold} chunks; ${corpus.counts.matchedBuckets}/${corpus.counts.buckets} buckets alias-matched to ${idx.entities.length} entities.\n`;
if (nr) journal += `- P4-T1 lexical recall@${nr.K} (full corpus): overall ${pct(nr.headline.overall)}, worst bin ${pct(nr.headline.worstBin)}.\n`;
journal += `- P4-T2 (sample n=${sampleIds.length}, ${modelCalls} e4b calls): name-match real-F1 ${real.f1.toFixed(3)} (P ${real.precision.toFixed(3)}/R ${real.recall.toFixed(3)}, Jaccard ${real.meanJaccard.toFixed(3)}), oracle-F1 ${oracle.f1.toFixed(3)}, embedding-cosine best-F1 ${embBest.f1.toFixed(3)} @K=${embBest.k}.\n`;
journal += `- Gates: name-match>embedding ${gateBeatsEmbedding ? "PASS" : "FAIL"}, oracle≥0.85 ${gateOracle ? "PASS" : "FAIL"} → ${gatesPassed ? "PASS" : "FAIL"}.\n`;
if (nr)
  journal += `- DECISION: ${nr.headline.fallbackNeeded ? "embedding fallback NEEDED (offline instrument, scoped to weak bin(s))" : "NO embedding fallback"} — embeddings stay an offline instrument, the tripwire still gates the hot path.\n`;
await Bun.write(JOURNAL, journal);
console.log(`journal → ${JOURNAL}`);

process.exit(0);
