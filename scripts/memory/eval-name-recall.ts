// P4-T1 · Lexical-shortlist recall ceiling over NAMES.
//
// The Dreaming routes a chunk to the articles it is ABOUT by a deterministic
// name/category lookup — never a vector index. Before building the binary-check
// ROUTE machinery (P5-T4) on a lexical shortlist, this instrument measures the
// shortlist's RECALL CEILING: for each Lucien chunk, is its gold entity in the
// chunk-label's trigram + token-overlap top-K? If not, no number of yes/no
// disambiguations downstream can recover it.
//
//   bun scripts/memory/eval-name-recall.ts
//
// PURE LEXICAL — no model, no embeddings. Runs the FULL corpus (it is cheap).
// Reads Lucien gold (lucien.db) read-only; gold = goldens/entities.json
// alias-matched to bucket names. Writes a machine-readable artifact that
// eval-route.ts (P4-T2) folds into reports/dreaming/p4-routing.md.

import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { EntityIndex, loadEntities, loadGoldCorpus, BIN_ORDER, binOf } from "./dreaming-lex";

const ROOT = join(import.meta.dir, "..", "..");
const ENTITIES = join(ROOT, "goldens", "entities.json");
const OUT_JSON = join(ROOT, "reports", "dreaming", "p4-name-recall.json");
const KS = [5, 8, 12, 20, 50];
const HEADLINE_K = 12;

const idx = new EntityIndex(await loadEntities(ENTITIES));
const corpus = loadGoldCorpus(idx);
const c = corpus.counts;
console.log(
  `lucien.db (live COUNT): ${c.buckets} buckets, ${c.labeledChunks} labeled chunks, ` +
    `${c.rawEdges} raw edges → ${c.validEdges} valid gold edges over ${c.chunksWithGold} chunks; ` +
    `${c.matchedBuckets}/${c.buckets} buckets alias-matched to ${idx.entities.length} gold entities`,
);

// For each chunk, rank entities ONCE; record each gold entity's rank.
const bins = [...BIN_ORDER, "ALL"] as const;
type Tally = { edges: number; hit: Record<number, number>; rankSum: number };
const tally: Record<string, Tally> = {};
for (const b of bins) tally[b] = { edges: 0, hit: Object.fromEntries(KS.map((k) => [k, 0])), rankSum: 0 };

let done = 0;
for (const [chunkId, gold] of corpus.goldByChunk) {
  const label = corpus.label.get(chunkId)!;
  const ranked = idx.rank(label);
  const rankOf = new Map(ranked.map((r, i) => [r.name, i + 1]));
  for (const g of gold) {
    const rank = rankOf.get(g)!;
    const bin = binOf(corpus.entitySize.get(g)!);
    for (const t of [tally[bin]!, tally.ALL!]) {
      t.edges++;
      t.rankSum += rank;
      for (const k of KS) if (rank <= k) t.hit[k]!++;
    }
  }
  if (++done % 1000 === 0) console.log(`  ranked ${done}/${corpus.goldByChunk.size} chunks`);
}

console.log(`\n=== P4-T1 recall ceiling: gold entity in chunk-label lexical top-K (trigram+token) ===`);
console.log(`bin       |  edges | ${KS.map((k) => `@${k}`.padStart(7)).join(" ")} | meanRank`);
const perBin: Record<string, Record<number, number>> = {};
for (const bin of bins) {
  const t = tally[bin]!;
  if (t.edges === 0) {
    console.log(`${bin.padEnd(9)} |      0 |`);
    continue;
  }
  perBin[bin] = Object.fromEntries(KS.map((k) => [k, t.hit[k]! / t.edges]));
  console.log(
    `${bin.padEnd(9)} | ${String(t.edges).padStart(6)} | ` +
      `${KS.map((k) => `${(100 * t.hit[k]! / t.edges).toFixed(1)}%`.padStart(7)).join(" ")} | ` +
      `${(t.rankSum / t.edges).toFixed(1)}`,
  );
}

const overallK = tally.ALL!.hit[HEADLINE_K]! / tally.ALL!.edges;
const perBinK: Record<string, number> = {};
for (const bin of BIN_ORDER) if (tally[bin]!.edges > 0) perBinK[bin] = tally[bin]!.hit[HEADLINE_K]! / tally[bin]!.edges;
const minBin = Math.min(...Object.values(perBinK));
const decisionNeeded = overallK < 0.9 || minBin < 0.8;
console.log(
  `\nHEADLINE recall@${HEADLINE_K}: overall ${(100 * overallK).toFixed(1)}%, ` +
    `worst bin ${(100 * minBin).toFixed(1)}%`,
);
console.log(
  `DECISION (recall@${HEADLINE_K} ≥ 0.90 overall AND ≥ 0.80 every bin?): ` +
    `${decisionNeeded ? "FAIL → embedding fallback NEEDED (scope to failing bins)" : "PASS → NO embedding fallback"}`,
);

mkdirSync(join(ROOT, "reports", "dreaming"), { recursive: true });
await Bun.write(
  OUT_JSON,
  JSON.stringify(
    {
      K: HEADLINE_K,
      KS,
      counts: c,
      entityVocab: idx.entities.length,
      overall: Object.fromEntries(KS.map((k) => [k, tally.ALL!.hit[k]! / tally.ALL!.edges])),
      perBin,
      edgesPerBin: Object.fromEntries(bins.map((b) => [b, tally[b]!.edges])),
      meanRankPerBin: Object.fromEntries(bins.map((b) => [b, tally[b]!.edges ? tally[b]!.rankSum / tally[b]!.edges : null])),
      headline: { overall: overallK, perBin: perBinK, worstBin: minBin, fallbackNeeded: decisionNeeded },
    },
    null,
    2,
  ) + "\n",
);
console.log(`\nartifact → ${OUT_JSON}`);
