// P5 · EXTRACTION-SAMPLE dump for the cloud LLM-judge.
//
// This is DATA COLLECTION, not scoring. We hand the judge a deterministic,
// domain-stratified slice of the REAL ingested corpus together with the base
// model's entity extractions, so a CLOUD judge (not a bucket-F1) can grade
// extraction quality. Per the methodology, the LoRA decision keys off JUDGE
// quality — never Lucien's `chunk_buckets` bin taxonomy, which is the very thing
// this project replaces. So this script deliberately touches NO Lucien gold and
// NO bucket edges: it samples mlx-bun's own ingested chunks and records exactly
// what the model said.
//
// Selection (deterministic, no RNG):
//   - Pool = every ingested chunk whose reassembled text falls in a length band
//     [MIN_LEN, MAX_LEN] (substantive but bounded so the model sees real content
//     without a 300k-char outlier).
//   - Conv spread: collapse to ONE chunk per conversation (the longest in-band
//     chunk, ties broken by chunk id) so 30 entries come from 30 conversations,
//     not 30 slices of one thread.
//   - Domain spread: classify each conversation into photography / ai-tooling /
//     alphapoint-work / misc by title+text keywords, then draw a length-spread
//     (short→long) quota from each domain so the judge sees all four.
//
// Extraction runs base Gemma-4-e4b + `Meta/Entities.md` (NO memory-entity
// adapter — none is symlinked), ONE model load shared across all chunks via the
// callLocal mount cache. The pure extractEntityNames is used (no DB writes — a
// sample dump must not mutate the production synthesis ledger).
//
//   bun scripts/memory/dump-extract-sample.ts
//
// Writes reports/dreaming/p5-extract-sample.json (the artifact the judge reads).

import { mkdirSync } from "node:fs";
import { join } from "node:path";

import { MemoryStore } from "../../src/memory/db";
import { loadMetaPolicy } from "../../src/memory/prompts";
import { extractEntityNames } from "../../src/memory/entity";

const ROOT = join(import.meta.dir, "..", "..");
const REPORT_DIR = join(ROOT, "reports", "dreaming");
const REPORT = join(REPORT_DIR, "p5-extract-sample.json");

const TARGET = Number(process.env.SAMPLE ?? 30);
const MIN_LEN = Number(process.env.MIN_LEN ?? 300); // floor: skip trivially-short chunks
const MAX_LEN = Number(process.env.MAX_LEN ?? 8000); // ceiling: keep one model call bounded
const MAX_TOKENS = Number(process.env.MAX_TOKENS ?? 128);
const EXCERPT = 600;

type Domain = "photography" | "ai-tooling" | "alphapoint-work" | "misc";
const DOMAIN_ORDER: Domain[] = ["photography", "ai-tooling", "alphapoint-work", "misc"];

// Keyword classifiers. Priority order (first match wins): photography is the
// most lexically distinctive, then explicit AlphaPoint/work signals, then the
// (corpus-dominant) AI-tooling vocabulary, else misc. Matched case-insensitively
// against the conv title + the chunk's first ~2k chars of text.
const PHOTO = /\b(lumix|s5ii|s5iix|sigma|anamorphic|l-?mount|sankor|canon|nikon|aperture|bokeh|bafflin|focal length|full[- ]frame|\d{2,3}mm|f\/\d|davinci resolve|camera|lens(es)?|cinemascope|isco)\b/i;
const WORK = /\b(wor-\d+|alphapoint|jira|confluence|firebase|next\.?js|sprint|backlog|stand-?up|ticket|pull request|merge request|deploy(ment)?|staging|production incident)\b/i;
const AI = /\b(mlx|lora|orpo|gemma|qwen|minicpm|quantiz|fine-?tun|adapter|tokeniz|kernel|optiq|embedding|llm|inference|checkpoint|safetensor|pytorch|tensor|gradient|logit|sdpa|attention|transformer|bun:ffi|metal kernel)\b/i;

function classify(title: string, textHead: string): Domain {
  const hay = `${title}\n${textHead}`;
  if (PHOTO.test(hay)) return "photography";
  if (WORK.test(hay)) return "alphapoint-work";
  if (AI.test(hay)) return "ai-tooling";
  return "misc";
}

interface Cand {
  chunkId: string;
  conv: string;
  title: string;
  text: string;
  len: number;
  domain: Domain;
}

const store = new MemoryStore();

const chunkCount = (store.db.query("SELECT COUNT(*) AS n FROM chunks").get() as { n: number }).n;
const convCount = (
  store.db.query("SELECT COUNT(DISTINCT conv) AS n FROM chunks").get() as { n: number }
).n;

// All chunks with their conversation title, ordered for determinism.
const rows = store.db
  .query(
    `SELECT c.id AS id, c.conv AS conv, COALESCE(co.title, '') AS title
       FROM chunks c LEFT JOIN conversations co ON co.conv = c.conv
       ORDER BY c.id`,
  )
  .all() as { id: string; conv: string; title: string }[];

// Reassemble text, length-band filter, classify, and keep the LONGEST in-band
// chunk per conversation (ties → smallest id, since rows are id-sorted).
const bestPerConv = new Map<string, Cand>();
let scanned = 0;
let inBand = 0;
for (const r of rows) {
  scanned++;
  const text = store.chunkText(r.id);
  const len = text.length;
  if (len < MIN_LEN || len > MAX_LEN) continue;
  inBand++;
  const domain = classify(r.title, text.slice(0, 2000));
  const cand: Cand = { chunkId: r.id, conv: r.conv, title: r.title, text, len, domain };
  const prev = bestPerConv.get(r.conv);
  if (!prev || cand.len > prev.len) bestPerConv.set(r.conv, cand);
}

// Group the per-conv representatives by domain.
const byDomain = new Map<Domain, Cand[]>();
for (const c of bestPerConv.values())
  (byDomain.get(c.domain) ?? byDomain.set(c.domain, []).get(c.domain)!).push(c);

// Length-spread pick: sort by length, take k evenly-spaced indices (short→long).
function lengthSpread(list: Cand[], k: number): Cand[] {
  const sorted = [...list].sort((a, b) => (a.len !== b.len ? a.len - b.len : a.chunkId < b.chunkId ? -1 : 1));
  if (k >= sorted.length) return sorted;
  const out: Cand[] = [];
  for (let i = 0; i < k; i++) out.push(sorted[Math.floor((i * sorted.length) / k)]!);
  return out;
}

// Even quota across the four domains (remainder to the earliest domains), then
// top-up any shortfall from domains with leftovers so we still reach TARGET.
const base = Math.floor(TARGET / DOMAIN_ORDER.length);
const rem = TARGET - base * DOMAIN_ORDER.length;
const quota = new Map<Domain, number>();
DOMAIN_ORDER.forEach((d, i) => quota.set(d, base + (i < rem ? 1 : 0)));

const chosen: Cand[] = [];
const chosenIds = new Set<string>();
for (const d of DOMAIN_ORDER) {
  const pick = lengthSpread(byDomain.get(d) ?? [], quota.get(d)!);
  for (const c of pick) if (!chosenIds.has(c.chunkId)) (chosenIds.add(c.chunkId), chosen.push(c));
}
// Top-up to TARGET from remaining candidates (length-spread within each domain).
for (let pass = 0; chosen.length < TARGET && pass < 8; pass++) {
  let added = false;
  for (const d of DOMAIN_ORDER) {
    if (chosen.length >= TARGET) break;
    const left = (byDomain.get(d) ?? []).filter((c) => !chosenIds.has(c.chunkId));
    const next = lengthSpread(left, 1)[0];
    if (next) {
      chosenIds.add(next.chunkId);
      chosen.push(next);
      added = true;
    }
  }
  if (!added) break;
}

// Stable final order: domain, then length, then id.
chosen.sort((a, b) => {
  const da = DOMAIN_ORDER.indexOf(a.domain) - DOMAIN_ORDER.indexOf(b.domain);
  if (da !== 0) return da;
  if (a.len !== b.len) return a.len - b.len;
  return a.chunkId < b.chunkId ? -1 : 1;
});

const domainCounts: Record<string, number> = {};
for (const c of chosen) domainCounts[c.domain] = (domainCounts[c.domain] ?? 0) + 1;

console.log(`memory.sqlite (live COUNT): ${chunkCount} chunks over ${convCount} conversations.`);
console.log(
  `pool: ${inBand} in-band chunks [${MIN_LEN}..${MAX_LEN} chars] of ${scanned} scanned → ` +
    `${bestPerConv.size} per-conv representatives.`,
);
console.log(
  `domain pool sizes: ` +
    DOMAIN_ORDER.map((d) => `${d}:${(byDomain.get(d) ?? []).length}`).join("  "),
);
console.log(
  `selected ${chosen.length} chunks — per domain ` +
    DOMAIN_ORDER.map((d) => `${d}:${domainCounts[d] ?? 0}`).join("  "),
);
console.log("selection (domain · len · conv · title):");
for (const c of chosen)
  console.log(`  [${c.domain}] ${String(c.len).padStart(5)}c  ${c.chunkId}  "${c.title.slice(0, 56)}"`);

// ---- run extraction (single base-model load via callLocal mount cache) ------
const policy = loadMetaPolicy(["Entities"]);

interface Entry {
  chunkId: string;
  conv: string;
  convTitle: string;
  domain: Domain;
  textLen: number;
  textExcerpt: string;
  extracted: string[]; // canonical names the model named
  extractedDetail: { name: string; surface: string; stem: string }[];
}

const entries: Entry[] = [];
let totalPreds = 0;
for (let i = 0; i < chosen.length; i++) {
  const c = chosen[i]!;
  const ents = await extractEntityNames(c.text, policy, { maxTokens: MAX_TOKENS });
  totalPreds += ents.length;
  entries.push({
    chunkId: c.chunkId,
    conv: c.conv,
    convTitle: c.title,
    domain: c.domain,
    textLen: c.len,
    textExcerpt: c.text.slice(0, EXCERPT),
    extracted: ents.map((e) => e.name),
    extractedDetail: ents.map((e) => ({ name: e.name, surface: e.surface, stem: e.stem })),
  });
  if ((i + 1) % 5 === 0 || i + 1 === chosen.length)
    console.log(`  extracted ${i + 1}/${chosen.length}`);
}
store.close();

const avgPreds = entries.length === 0 ? 0 : totalPreds / entries.length;
const artifact = {
  generatedAt: new Date().toISOString(),
  source: "mlx-bun memory.sqlite (own ingested corpus — NOT Lucien bucket gold)",
  model: "base Gemma-4-e4b + Meta/Entities.md (no memory-entity adapter)",
  corpus: { chunks: chunkCount, conversations: convCount },
  selection: {
    lengthBand: [MIN_LEN, MAX_LEN] as [number, number],
    maxTokens: MAX_TOKENS,
    excerptChars: EXCERPT,
    poolInBand: inBand,
    perConvRepresentatives: bestPerConv.size,
    domainPoolSizes: Object.fromEntries(DOMAIN_ORDER.map((d) => [d, (byDomain.get(d) ?? []).length])),
  },
  sampleSize: entries.length,
  avgPredsPerChunk: avgPreds,
  domainCounts,
  entries,
};

mkdirSync(REPORT_DIR, { recursive: true });
await Bun.write(REPORT, JSON.stringify(artifact, null, 2));
console.log(`\nartifact → ${REPORT}`);
console.log(
  `sampleSize ${entries.length}  avgPredsPerChunk ${avgPreds.toFixed(2)}  ` +
    `domains [${Object.keys(domainCounts).join(", ")}]`,
);

// ---- a few examples to eyeball ---------------------------------------------
console.log("\nexamples:");
for (const d of DOMAIN_ORDER) {
  const ex = entries.find((e) => e.domain === d);
  if (!ex) continue;
  console.log(`\n[${d}] ${ex.chunkId} — "${ex.convTitle.slice(0, 60)}"`);
  console.log(`  excerpt: ${ex.textExcerpt.slice(0, 180).replace(/\s+/g, " ")}…`);
  console.log(`  extracted: ${ex.extracted.length ? ex.extracted.join(" | ") : "(none)"}`);
}

process.exit(0);
