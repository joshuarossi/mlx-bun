// Gold-entity vocabulary miner for "The Dreaming".
//
// Mines a frozen entity vocabulary from the local Dreaming oracle vault so
// downstream synthesis/eval can score entity recall against a stable gold set.
// Sources, in priority order:
//   1. Article titles    — ~/Dreaming/articles/*.md filename stems (_ -> space).
//      Each file yields exactly ONE title-derived entry (sourceTitle set).
//   2. Bolded lead phrases — **X** appearing in the first sentence of the lead
//      paragraph; attached as aliases of that article's entry.
//   3. Bucket names      — ~/Dreaming/Meta/Buckets.md list items / sub-headings;
//      emitted as standalone entries (no sourceTitle).
//
// Surfaces are normalized (casefold, whitespace-collapse, strip leading
// article) and alias variants are collapsed by a squeeze key so e.g.
// "S5IIX" / "S5 IIX" land as a single alias.
//
// builtFromSha freezes the oracle: `git -C ~/Dreaming rev-parse HEAD`. Output is
// fully deterministic — re-running over the same SHA is byte-identical.
//
//   bun scripts/memory/mine-gold-entities.ts        # writes goldens/entities.json
//
// Pure file I/O — no model, no GPU.

import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const HOME = process.env.HOME ?? "";
const DREAMING = join(HOME, "Dreaming");
const ARTICLES_DIR = join(DREAMING, "articles");
const BUCKETS_FILE = join(DREAMING, "Meta", "Buckets.md");
const OUT_FILE = join(import.meta.dir, "..", "..", "goldens", "entities.json");

interface Entity {
  name: string;
  aliases: string[];
  sourceTitle?: string;
}

interface GoldEntities {
  entities: Entity[];
  builtFromSha: string;
}

/** casefold + whitespace-collapse + strip a single leading article. */
function normalize(s: string): string {
  const t = s.toLowerCase().replace(/\s+/g, " ").trim();
  return t.replace(/^(?:the|a|an)\s+/, "").trim();
}

/** Strip inline markdown noise from a captured surface form (wiki-links,
 *  emphasis, code spans, footnote refs) so the bare entity text remains. */
function stripMarkdown(s: string): string {
  return s
    .replace(/\[\[[^\]|]*\|([^\]]+)\]\]/g, "$1") // [[Target|Label]] -> Label
    .replace(/\[\[([^\]]+)\]\]/g, "$1") // [[Target]] -> Target
    .replace(/\[\^[^\]]*\]/g, "") // [^1] footnote refs
    .replace(/[`*_]/g, "")
    .trim();
}

/** Squeeze key for collapsing alias spelling/spacing variants. */
function squeeze(s: string): string {
  return s.toLowerCase().replace(/[^a-z0-9]/g, "");
}

/** First sentence of the lead paragraph (first text block below the H1). */
function leadFirstSentence(body: string): string {
  const lines = body.split("\n");
  let i = 0;
  // Skip the H1 and any blank lines preceding the lead.
  while (i < lines.length && ((lines[i] ?? "").trim() === "" || (lines[i] ?? "").startsWith("#"))) i++;
  const para: string[] = [];
  while (i < lines.length && (lines[i] ?? "").trim() !== "") {
    para.push(lines[i] ?? "");
    i++;
  }
  const text = para.join(" ").trim();
  // Split on the first sentence terminator followed by whitespace.
  const m = text.match(/^.*?[.!?](?=\s|$)/);
  return m ? m[0] : text;
}

/** All **bolded** surfaces inside a sentence, markdown-stripped. */
function boldPhrases(sentence: string): string[] {
  const out: string[] = [];
  for (const m of sentence.matchAll(/\*\*([^*]+)\*\*/g)) {
    const phrase = stripMarkdown(m[1] ?? "");
    if (phrase) out.push(phrase);
  }
  return out;
}

/** Collapse alias variants by squeeze key, drop any equal to the entry name,
 *  and return a deterministically-sorted list. */
function collapseAliases(name: string, candidates: string[]): string[] {
  const nameKey = squeeze(name);
  const bySqueeze = new Map<string, string>();
  for (const raw of candidates) {
    const alias = normalize(raw);
    if (!alias) continue;
    const key = squeeze(alias);
    if (!key || key === nameKey) continue;
    const existing = bySqueeze.get(key);
    // Prefer the lexicographically smallest surface for a stable canonical form.
    if (existing === undefined || alias < existing) bySqueeze.set(key, alias);
  }
  return [...bySqueeze.values()].sort();
}

function mineTitleEntities(): Entity[] {
  const files = readdirSync(ARTICLES_DIR)
    .filter((f) => f.endsWith(".md"))
    .sort();
  const entities: Entity[] = [];
  for (const file of files) {
    const titleSurface = basename(file, ".md").replace(/_/g, " ");
    const name = normalize(titleSurface);
    if (!name) continue; // defensive: never emit an empty name
    const body = readFileSync(join(ARTICLES_DIR, file), "utf8");
    const aliases = collapseAliases(name, boldPhrases(leadFirstSentence(body)));
    entities.push({ name, aliases, sourceTitle: file });
  }
  return entities;
}

/** Bucket names from Meta/Buckets.md: markdown list items and sub-headings
 *  (the top-level "# Buckets" title and prose are skipped). Currently the file
 *  is a placeholder, so this typically yields nothing. */
function mineBucketEntities(known: Set<string>): Entity[] {
  if (!existsSync(BUCKETS_FILE)) return [];
  const seen = new Set<string>();
  const out: Entity[] = [];
  for (const line of readFileSync(BUCKETS_FILE, "utf8").split("\n")) {
    const trimmed = line.trim();
    let surface = "";
    const list = trimmed.match(/^[-*+]\s+(.+)$/);
    const heading = trimmed.match(/^#{2,}\s+(.+)$/);
    if (list) surface = stripMarkdown(list[1] ?? "");
    else if (heading) surface = stripMarkdown(heading[1] ?? "");
    if (!surface) continue;
    const name = normalize(surface);
    const key = squeeze(name);
    if (!name || !key || known.has(key) || seen.has(key)) continue;
    seen.add(key);
    out.push({ name, aliases: [] });
  }
  return out;
}

function oracleSha(): string {
  return execFileSync("git", ["-C", DREAMING, "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
}

function main(): void {
  const titleEntities = mineTitleEntities();
  const knownKeys = new Set(titleEntities.map((e) => squeeze(e.name)));
  const bucketEntities = mineBucketEntities(knownKeys);

  // Title entries first (sorted by source file), then bucket entries (by name).
  titleEntities.sort((a, b) => (a.sourceTitle ?? "").localeCompare(b.sourceTitle ?? ""));
  bucketEntities.sort((a, b) => a.name.localeCompare(b.name));

  const gold: GoldEntities = {
    entities: [...titleEntities, ...bucketEntities],
    builtFromSha: oracleSha(),
  };

  mkdirSync(dirname(OUT_FILE), { recursive: true });
  writeFileSync(OUT_FILE, JSON.stringify(gold, null, 2) + "\n");

  const titleCount = gold.entities.filter((e) => e.sourceTitle).length;
  console.log(
    `Wrote ${gold.entities.length} entities (${titleCount} title-derived, ` +
      `${bucketEntities.length} bucket-derived) to ${OUT_FILE} @ ${gold.builtFromSha}`,
  );
}

main();
