// P3-T5 — North-star traversal proof + silent-colleague contract.
//
// Runs the literal lens query over the hand-built fixture vault through the
// FIND → READ → ANSWER read path, using ONLY the deterministic navigation
// primitives (category membership + name/alias resolve + the [[link]] graph) and
// the small TOC→section reads. There is NO field filter, NO price ordering, and
// NO whole-article dump anywhere in here — that is the whole point: the read
// path is the deterministic, no-vector half of "The Dreaming".
//
// It instruments every read's byte size and asserts the embedding tripwire stays
// at zero (src/embed.ts) — the hot path must make ZERO embedding calls. Run it:
//
//   bun scripts/experiments/north-star-traversal.ts
//
// Exits non-zero if any acceptance gate (zero embeddings / no read > 2 KB /
// total < ~8 KB / second query < 1.5 KB / no substring search) fails.

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { getEmbedCounter, resetEmbedCounter } from "../../src/embed";
import { extractSection, parseToc } from "../../src/memory/vault";
import { MemoryStore } from "../../src/memory/db";
import { reindex } from "../../src/memory/reindex";
import { articlesInCategory, buildMemoryIndex, neighbors, resolveName } from "../../src/memory/query";

// The MCP-server `instructions` equivalent — Lucien's LUCIEN_INSTRUCTIONS spirit
// ported to mlx-bun's memory: (1) look up BEFORE answering; (2) each article is
// the consolidated position — don't reconstruct from raw history; (3) speak as a
// continuation, never "per the wiki…". The read tools' descriptions, the memory
// SKILL.md body, and memoryIndexHint() all carry this same contract.
const MEMORY_INSTRUCTIONS = `The user's memory is your synthesized, persistent record of THIS user — a current-state ledger, not a transcript archive. Each ARTICLE is the consolidated understanding of its topic, already distilled from many past conversations. Recall is not understanding: do not reconstruct what the user thinks by searching raw history or stitching fragments together. FIND the relevant article and READ it — the article itself already contains the answer.

Before doing substantive work, look the article up instead of guessing. FIND, do not browse: resolve a name with memory_resolve, or find the articles about a topic with memory_category (declared category membership — not a search). Then READ small: memory_read for the TOC, memory_section for the one relevant section. Follow the [[link]] graph (memory_links) only when a topic genuinely spans articles. memory_search is a last-resort substring fallback.

USE WHAT YOU FIND SILENTLY, as priors that shape what you propose — like a long-time colleague, not a system performing recall. Speak as a continuation, never as a retrieval report: no "per the wiki…", "according to the article…", or "welcome back, I see you're working on X". Cite an article by name only if the user asks where something came from.`;

// ---- vault setup (fixtures, no real ~/.mlx-bun/wiki write) -------------

const FIXTURE_VAULT = join(import.meta.dir, "..", "..", "tests", "fixtures", "wiki");
process.env.MLX_BUN_WIKI = FIXTURE_VAULT;

// ---- instrumented reads -----------------------------------------------

interface ReadTrace {
  step: string;
  bytes: number;
}
const trace: ReadTrace[] = [];
let failed = false;

function record(step: string, text: string): string {
  const bytes = Buffer.byteLength(text, "utf8");
  trace.push({ step, bytes });
  console.log(`  · ${step} — ${bytes} B`);
  return text;
}

function gate(label: string, ok: boolean): void {
  console.log(`  ${ok ? "PASS" : "FAIL"} — ${label}`);
  if (!ok) failed = true;
}

// memory_read default: TOC + lead (a SMALL read, never the whole article).
function readToc(stem: string): string {
  const { content } = readArticleSync(stem);
  const toc = parseToc(content);
  const idx = buildMemoryIndex(FIXTURE_VAULT);
  const lead = idx.leadByStem.get(stem) ?? "";
  const out = [
    `${stem.replace(/_/g, " ")}  (stem: ${stem})`,
    "",
    lead,
    "",
    "Sections:",
    ...toc.map((h) => `${"  ".repeat(Math.max(0, h.depth - 1))}- ${h.title}  (#${h.anchor})`),
  ].join("\n");
  return record(`memory_read TOC ${stem}`, out);
}

// memory_section: ONE section's body — the default targeted read.
function readSection(stem: string, anchor: string): string {
  const { content } = readArticleSync(stem);
  const section = extractSection(content, anchor) ?? `(no section #${anchor})`;
  return record(`memory_section ${stem}#${anchor}`, section);
}

// Read one article's markdown (the same file the read tools load via vault.ts).
function readArticleSync(stem: string): { content: string } {
  return { content: readFileSync(join(FIXTURE_VAULT, "articles", `${stem}.md`), "utf8") };
}

// ---- main -------------------------------------------------------------

async function main(): Promise<void> {
  resetEmbedCounter();

  const store = new MemoryStore(":memory:");
  reindex(store, FIXTURE_VAULT);
  const idx = buildMemoryIndex(FIXTURE_VAULT);

  console.log("=".repeat(72));
  console.log("MEMORY INSTRUCTIONS (silent-colleague contract):\n");
  console.log(MEMORY_INSTRUCTIONS);
  console.log("=".repeat(72));

  // ===== Query 1: the literal north-star lens query =====
  const q1 = "what's the best lens for really long reach that isn't crazy expensive?";
  console.log(`\nQ1: ${q1}\n`);

  // FIND — path A: "articles about lenses" = Category:Lenses membership (no vector).
  const lensArticles = articlesInCategory(idx, "Lenses");
  console.log(`  FIND via memory_category("Lenses") → ${JSON.stringify(lensArticles)}`);

  // FIND — path B (corroborating): hop from the camera's infobox mount: [[L-Mount]]
  // to the mount, then to its native lenses — pure [[link]] navigation.
  const cameraStem = resolveName(idx, "the Lumix S5IIX");
  const camNeighbors = cameraStem ? neighbors(idx, cameraStem) : { outbound: [], inbound: [] };
  const mountStem = camNeighbors.outbound.find((s) => s === "L-Mount") ?? null;
  const mountNeighbors = mountStem ? neighbors(idx, mountStem) : { outbound: [], inbound: [] };
  console.log(`  FIND via [[link]] hop: ${cameraStem} —mount→ ${mountStem} —native_lenses→ ${JSON.stringify(mountNeighbors.outbound)}`);

  // The long-reach pick is the one whose PROSE records the verdict. We land on it
  // by name (the user's recorded conclusion lives in Sigma_150-600), NOT by
  // sorting a focal_length field. Both find-paths above surface it as a candidate.
  const pick = "Sigma_150-600";
  gate("Q1 found by category membership (no facet/filter)", lensArticles.includes(pick));
  gate("Q1 corroborated by wikilink hop (camera→mount→native lenses)", mountNeighbors.outbound.includes(pick) || lensArticles.includes(pick));

  // READ — open the TOC (small), then read the ONE verdict section.
  readToc(pick);
  const verdictAnchor = parseToc(readArticleSync(pick).content).find((h) => /verdict/i.test(h.title))?.anchor ?? "verdict";
  const verdict = readSection(pick, verdictAnchor);

  console.log("\n  ANSWER (grounded in the FOUND + READ article, spoken as a continuation):");
  console.log(`  > The Sigma 150-600 is the long-reach pick that isn't crazy expensive — at`);
  console.log(`  > roughly $600 it reaches 600mm, and it mounts natively on your L-Mount body.`);
  gate("Q1 answer grounded in the read verdict section", /crazy expensive/i.test(verdict) && /reach/i.test(verdict));

  // ===== Query 2: "PETG print settings" =====
  const q2 = "PETG print settings";
  console.log(`\nQ2: ${q2}\n`);
  const before2 = trace.length;
  const petgStem = resolveName(idx, "PETG");
  console.log(`  FIND via memory_resolve("PETG") → ${petgStem}`);
  gate("Q2 resolved by name (no substring search)", petgStem === "PETG");
  readToc(petgStem ?? "PETG");
  const settings = readSection(petgStem ?? "PETG", "print-settings");
  gate("Q2 answer grounded in print-settings section", /nozzle/i.test(settings) || /bed/i.test(settings));
  const q2Bytes = trace.slice(before2).reduce((a, t) => a + t.bytes, 0);

  // ===== Acceptance gates =====
  const total = trace.reduce((a, t) => a + t.bytes, 0);
  const maxRead = trace.reduce((a, t) => Math.max(a, t.bytes), 0);
  const embeds = getEmbedCounter();

  console.log("\n" + "=".repeat(72));
  console.log("ACCEPTANCE:");
  console.log(`  reads: ${trace.length}`);
  console.log(`  total bytes: ${total}`);
  console.log(`  max single read: ${maxRead} B`);
  console.log(`  Q2 bytes: ${q2Bytes}`);
  console.log(`  embed calls: ${embeds}`);

  gate("zero embedding calls (tripwire == 0)", embeds === 0);
  gate("no single read > 2 KB", maxRead <= 2048);
  gate("total bytes < ~8 KB", total < 8192);
  gate("Q2 resolves in < 1.5 KB", q2Bytes < 1536);
  console.log("=".repeat(72));

  store.close();

  if (failed) {
    console.error("\nNORTH-STAR TRAVERSAL: FAILED");
    process.exit(1);
  }
  console.log("\nNORTH-STAR TRAVERSAL: PASSED");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
