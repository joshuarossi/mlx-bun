// P8-T3 / P8-T4 · summary-style SPLIT + series banner + MERGE signal + Talk-page
// triage — bounded GPU acceptance.
//
// Deterministic split MECHANICS need no model; the only GPU touches are (1) the
// e4b `editor` writing the 2–3 sentence parent summary (one cached load), and
// (2) the Qwen3-Embedding silhouette as the ONE sanctioned OFFLINE triage
// instrument — asserted to leave the read path's embed tripwire at 0. Both model
// stages degrade gracefully (deterministic summary fallback / fake-embed
// silhouette) when a snapshot is absent, so the structural gates always run.
//
//   bun scripts/memory/eval-wikify-split.ts
//
// Prints a METRICS line: {splitProducesChild, noFalseSplit, mergeSignal,
// talkPageWritten, readPathEmbed0}.

import { mkdirSync, mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { parseInfobox } from "../../src/memory/article";
import { MemoryStore } from "../../src/memory/db";
import { getEmbedCounter, resetEmbedCounter } from "../../src/embed";
import { callLocal } from "../../src/memory/model";
import { neighbors, buildMemoryIndex } from "../../src/memory/query";
import { reindex } from "../../src/memory/reindex";
import { extractSection, listArticles, parseToc } from "../../src/memory/vault";
import {
  applySplit,
  bodySectionSizes,
  buildStructureTalk,
  detectMergeCandidates,
  detectSplitCandidate,
  sectionCohesion,
  writeTalkPage,
  type EmbedFn,
} from "../../src/memory/wikify";

// ---- constructed fixtures --------------------------------------------------

function oversizedArticle(): string {
  const big = Array.from({ length: 28 }, (_, i) =>
    `The anamorphic rig detail number ${i} covers squeeze factor, desqueeze, and the taking-lens pairing in depth.`,
  ).join(" ");
  return [
    "# Camera Gear",
    "",
    "```info",
    "type: collection",
    "kind: thing",
    "```",
    "",
    "**Camera Gear** is the user's photography kit and how each piece is used.[^1]",
    "",
    "## Bodies",
    "",
    "The user shoots one full-frame body for everything.[^1]",
    "",
    "## Anamorphic Workflow",
    "",
    `${big} The user owns a dedicated anamorphic adapter and uses it for cinematic video, desqueezing in post.[^2]`,
    "",
    "## References",
    "",
    "[^1]: `conv:a1b2c3d4` (2024-01-01, Kit Notes)",
    "[^2]: `conv:deadbeef` (2024-02-02, Anamorphic Notes)",
    "",
  ].join("\n");
}

function cohesiveArticle(): string {
  return [
    "# Photography",
    "",
    "```info",
    "kind: domain",
    "```",
    "",
    "**Photography** is a craft the user practices daily.[^1]",
    "",
    "## History",
    "",
    "The user took up the craft years ago and keeps shooting regularly.[^1]",
    "",
    "## Approach",
    "",
    "The user favors available light and candid framing in everyday shooting.[^1]",
    "",
    "## Gear Philosophy",
    "",
    "The user keeps a small deliberate kit and never chases specs for their own sake.[^1]",
    "",
    "## References",
    "",
    "[^1]: `conv:a1b2c3d4` (2024-01-01, Craft Notes)",
    "",
  ].join("\n");
}

const STUB_A = "# Sankor 16C\n\n```info\nkind: thing\n```\n\n**Sankor 16C** is the user's anamorphic adapter, a single-focus projection lens used for cinematic video.\n";
const STUB_B = "# Sankor 16-C\n\n```info\nkind: thing\n```\n\n**Sankor 16-C** is an anamorphic projection adapter the user owns and uses for cinematic single-focus video.\n";

// ---- the optional real embedding backend (offline triage instrument) -------

async function loadRealEmbed(): Promise<EmbedFn | null> {
  try {
    const { Glob } = await import("bun");
    const { Weights } = await import("../../src/weights");
    const { loadModelConfig } = await import("../../src/config");
    const { createModel } = await import("../../src/model/factory");
    const { loadTokenizer } = await import("../../src/tokenizer");
    const { embedMany, isEmbeddingModel } = await import("../../src/embed");
    const hub = `${process.env.HOME}/.cache/huggingface/hub`;
    let dir: string | null = null;
    for await (const f of new Glob("models--mlx-community--Qwen3-Embedding-*/snapshots/*/config.json").scan({ cwd: hub, absolute: true })) {
      dir = f.replace(/\/config\.json$/, "");
      break;
    }
    if (!dir) return null;
    const model = createModel(await Weights.open(dir), await loadModelConfig(dir));
    if (!isEmbeddingModel(model)) return null;
    const tok = await loadTokenizer(dir);
    return (texts) => embedMany(model, tok, texts).map((r) => r.vector);
  } catch (err) {
    console.log(`(embedding model unavailable: ${(err as Error).message})`);
    return null;
  }
}

/** Deterministic fallback embed (token-hashed bag of words) so the silhouette
 *  runs even without the Qwen3-Embedding snapshot. */
const fakeEmbed: EmbedFn = (texts) =>
  texts.map((t) => {
    const v = new Float32Array(96);
    const hash = (s: string): number => {
      let h = 2166136261;
      for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619) >>> 0;
      return h % 96;
    };
    for (const w of t.toLowerCase().split(/[^a-z0-9]+/)) if (w.length > 2) v[hash(w)]! += 1;
    return v;
  });

// ---- run -------------------------------------------------------------------

async function main(): Promise<void> {
  const root = mkdtemp_();
  const dir = join(root, "articles");
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "Camera_Gear.md"), oversizedArticle());
  writeFileSync(join(dir, "Photography.md"), cohesiveArticle());
  writeFileSync(join(dir, "Sankor_16C.md"), STUB_A);
  writeFileSync(join(dir, "Sankor_16-C.md"), STUB_B);
  console.log(`# eval-wikify-split — working vault ${root}`);

  // --- T3.1 SPLIT (real e4b editor for the summary, one cached load) ---
  const realCall = (p: string, o?: { maxTokens?: number }) => callLocal("editor", { user: p }, o);
  const split = await applySplit({ stem: "Camera_Gear", root, call: realCall, commit: false });
  console.log(`split: status=${split.status} child=${split.childStem} anchor=${split.anchor}${split.reason ? ` reason="${split.reason}"` : ""}`);

  let splitProducesChild = false;
  if (split.status === "split" && split.childStem) {
    const store = new MemoryStore(":memory:");
    reindex(store, root);
    const child = await Bun.file(join(dir, `${split.childStem}.md`)).text();
    const parent = await Bun.file(join(dir, "Camera_Gear.md")).text();
    const hasInfobox = parseInfobox(child) != null;
    const movedCite = /\[\^\d+\]:/.test(child) && child.includes("anamorphic adapter");
    const mainEdge = store.db
      .query("SELECT 1 FROM links WHERE src_stem='Camera_Gear' AND dst_stem=? AND via='main'")
      .get(split.childStem) != null;
    const parentPointer = parent.includes(`*Main article: [[${split.childStem}]]*`);
    splitProducesChild = hasInfobox && movedCite && mainEdge && parentPointer;
    console.log(`  child infobox=${hasInfobox} movedCitedSection=${movedCite} parentMainPointer=${parentPointer} via=main=${mainEdge}`);
    console.log(`  parent summary section:\n` + indent(extractSection(parent, split.anchor!) ?? "(missing)"));
    store.db.close();
  }

  // --- T3.2 NO FALSE SPLIT on the cohesive article ---
  const noFalseSplit = detectSplitCandidate(cohesiveArticle()) == null;
  console.log(`no-false-split: cohesive article candidate=${detectSplitCandidate(cohesiveArticle())?.title ?? "none"} → ${noFalseSplit}`);
  console.log(`  cohesive section sizes: ${bodySectionSizes(cohesiveArticle()).map((s) => `${s.title}=${s.words}`).join(", ")}`);

  // --- T3.3 MERGE SIGNAL on the two near-duplicate stubs ---
  const merges = detectMergeCandidates([
    { stem: "Sankor_16C", content: STUB_A },
    { stem: "Sankor_16-C", content: STUB_B },
  ]);
  const mergeSignal = merges.length > 0;
  console.log(`merge-signal: ${merges.map((m) => `${m.a}~${m.b}@${m.jaccard.toFixed(2)}`).join(", ") || "none"} → ${mergeSignal}`);

  // --- T4 Talk page (split + merge triage) + read-path tripwire ---
  resetEmbedCounter();
  // A representative READ over the vault — must NOT embed.
  const stems = await listArticles(root);
  const store = new MemoryStore(":memory:");
  reindex(store, root);
  const idx = buildMemoryIndex(root);
  for (const stem of stems) {
    const md = await Bun.file(join(dir, `${stem}.md`)).text();
    parseToc(md);
    extractSection(md, "bodies");
    neighbors(idx, stem);
  }
  store.db.close();
  const readPathEmbed0 = getEmbedCounter() === 0;
  console.log(`read-path embed tripwire after a full read = ${getEmbedCounter()} → readPathEmbed0=${readPathEmbed0}`);

  // OFFLINE triage: the silhouette is the ONE sanctioned embedding use.
  const embed = (await loadRealEmbed()) ?? fakeEmbed;
  const usingReal = embed !== fakeEmbed;
  const before = getEmbedCounter();
  const cohesion = sectionCohesion(oversizedArticle(), embed);
  const triageEmbedded = getEmbedCounter() - before;
  console.log(`offline silhouette (${usingReal ? "Qwen3-Embedding" : "fake-embed"}): sections=${cohesion.sections} meanPairwise=${cohesion.meanPairwise.toFixed(3)} minPair=${cohesion.minPair.toFixed(3)} embedCalls=${usingReal ? triageEmbedded : "n/a"}`);

  const suggestions = buildStructureTalk({
    stem: "Camera_Gear",
    split: detectSplitCandidate(oversizedArticle()),
    cohesion,
    merges: detectMergeCandidates([
      { stem: "Camera_Gear", content: STUB_A },
      { stem: "Gear", content: STUB_A },
    ]),
  });
  const talkPath = await writeTalkPage({ stem: "Camera_Gear", suggestions, root });
  const talkPageWritten = talkPath != null;
  console.log(`talk page: ${talkPath ?? "(none)"} → talkPageWritten=${talkPageWritten}`);
  if (talkPath) console.log(indent(await Bun.file(talkPath).text()));
  console.log(`articles after triage (unchanged across articles): ${(await listArticles(root)).join(", ")}`);

  const metrics = { splitProducesChild, noFalseSplit, mergeSignal, talkPageWritten, readPathEmbed0 };
  console.log(`\nMETRICS ${JSON.stringify(metrics)}`);
}

function mkdtemp_(): string {
  return mkdtempSync(join(tmpdir(), "wikify-split-eval-"));
}

function indent(s: string): string {
  return s.split("\n").map((l) => `    ${l}`).join("\n");
}

await main();
