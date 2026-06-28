// Shared lexical/gold plumbing for The Dreaming's P4 routing instruments
// (scripts/memory/eval-name-recall.ts + eval-route.ts).
//
// The "router" The Dreaming ships is a deterministic NAME/CATEGORY lookup, never
// a vector index. This module supplies the pieces both P4 instruments must share
// bit-for-bit so their numbers are directly comparable:
//   - the entity alias vocabulary (goldens/entities.json, P0-T5),
//   - the Lucien gold reinterpreted as entity edges (chunk_buckets → entities),
//   - the trigram + token-overlap lexical shortlister that stands in for the
//     deterministic candidate stage.
//
// Pure CPU/IO — NO model, NO embeddings. Reads lucien.db read-only.

import { Database } from "bun:sqlite";

export const LUCIEN_DB = "/Users/joshrossi/Code/lucien/.lucien/lucien.db";

// Bucket-member-count bins (a gold entity's Lucien membership). The <5 tail
// (bins "1" + "2-4") is the expected weak spot for lexical recall.
export const BIN_ORDER = ["1", "2-4", "5-20", "21-100", "100+"] as const;
export type Bin = (typeof BIN_ORDER)[number];
export function binOf(n: number): Bin {
  return n === 1 ? "1" : n <= 4 ? "2-4" : n <= 20 ? "5-20" : n <= 100 ? "21-100" : "100+";
}

/** casefold + whitespace-collapse + strip ONE leading article. Matches
 *  scripts/memory/mine-gold-entities.ts so bucket names and gold surfaces
 *  normalize identically. */
export function normalize(s: string): string {
  const t = s.toLowerCase().replace(/\s+/g, " ").trim();
  return t.replace(/^(?:the|a|an)\s+/, "").trim();
}

/** Lucien bucket names are underscore-cased title stems (MCP_Protocol_and_Servers);
 *  bring them onto the same axis as the gold surfaces before matching. */
export function bucketNorm(name: string): string {
  return normalize(name.replace(/_/g, " "));
}

const STOP = new Set(["the", "a", "an", "and", "or", "of", "to", "for", "in", "on", "with", "is", "as"]);

/** Content tokens of a normalized string (drop stopwords + single chars). */
export function tokens(norm: string): Set<string> {
  return new Set(norm.split(/[^a-z0-9]+/).filter((t) => t.length > 1 && !STOP.has(t)));
}

/** Character trigrams of a normalized string (spaces collapsed to one). */
export function trigrams(norm: string): Set<string> {
  const s = `  ${norm.replace(/\s+/g, " ")}  `;
  const out = new Set<string>();
  for (let i = 0; i + 3 <= s.length; i++) out.add(s.slice(i, i + 3));
  return out;
}

/** Overlap coefficient |A∩B| / min(|A|,|B|) — credits an entity name being
 *  CONTAINED in a long label rather than penalizing the length mismatch a
 *  Jaccard would. */
export function overlap(a: Set<string>, b: Set<string>): number {
  const m = Math.min(a.size, b.size);
  if (m === 0) return 0;
  const [small, big] = a.size <= b.size ? [a, b] : [b, a];
  let inter = 0;
  for (const x of small) if (big.has(x)) inter++;
  return inter / m;
}

export interface Entity {
  name: string; // canonical (normalized) name
  surfaceTri: Set<string>[]; // per-surface (name + aliases) trigram sets
  surfaceTok: Set<string>[]; // per-surface token sets
}

export interface EntityRaw {
  name: string;
  aliases: string[];
  sourceTitle?: string;
}

/** Build the ranked-lexical entity index + the surface→canonical lookup that
 *  resolves bucket names (and exact alias hits) to gold entities. */
export class EntityIndex {
  readonly entities: Entity[] = [];
  readonly surfaceToName = new Map<string, string>(); // normalized surface → canonical name

  constructor(raws: EntityRaw[]) {
    for (const r of raws) {
      const name = normalize(r.name);
      if (!name) continue;
      const surfaces = [name, ...r.aliases.map(normalize).filter(Boolean)];
      const st = r.sourceTitle?.replace(/\.md$/, "");
      if (st) surfaces.push(normalize(st.replace(/_/g, " ")));
      const uniq = [...new Set(surfaces)];
      for (const s of uniq) if (!this.surfaceToName.has(s)) this.surfaceToName.set(s, name);
      this.entities.push({
        name,
        surfaceTri: uniq.map((s) => trigrams(s)),
        surfaceTok: uniq.map((s) => tokens(s)),
      });
    }
  }

  /** Lexical score of `label` against one entity = max over its surfaces of
   *  (trigram-overlap + token-overlap). */
  private score(labTri: Set<string>, labTok: Set<string>, e: Entity): number {
    let best = 0;
    for (let i = 0; i < e.surfaceTri.length; i++) {
      const s = overlap(labTri, e.surfaceTri[i]!) + overlap(labTok, e.surfaceTok[i]!);
      if (s > best) best = s;
    }
    return best;
  }

  /** Entities ranked by lexical score against `label`, descending. Ties break by
   *  name for determinism. */
  rank(label: string): { name: string; score: number }[] {
    const norm = normalize(label);
    const labTri = trigrams(norm);
    const labTok = tokens(norm);
    return this.entities
      .map((e) => ({ name: e.name, score: this.score(labTri, labTok, e) }))
      .sort((a, b) => (b.score !== a.score ? b.score - a.score : a.name < b.name ? -1 : 1));
  }

  topK(label: string, k: number): { name: string; score: number }[] {
    return this.rank(label).slice(0, k);
  }
}

export async function loadEntities(path: string): Promise<EntityRaw[]> {
  const j = (await Bun.file(path).json()) as { entities: EntityRaw[] };
  return j.entities;
}

export interface GoldCorpus {
  /** chunk id → label text. */
  label: Map<number, string>;
  /** chunk id → set of canonical gold entity names. */
  goldByChunk: Map<number, Set<string>>;
  /** canonical entity name → its Lucien bucket member count (for size bins). */
  entitySize: Map<string, number>;
  /** flat gold edges with the bin of the producing bucket. */
  edges: { chunkId: number; entity: string; bin: Bin }[];
  counts: {
    buckets: number;
    labeledChunks: number;
    rawEdges: number;
    validEdges: number;
    matchedBuckets: number;
    chunksWithGold: number;
  };
}

/** Read lucien.db and reinterpret each chunk's gold buckets as the entities it
 *  is about, alias-matched through `idx`. ALWAYS live COUNT(*) — never the
 *  8809/7316/2063 literals. */
export function loadGoldCorpus(idx: EntityIndex, dbPath = LUCIEN_DB): GoldCorpus {
  const db = new Database(dbPath, { readonly: true });
  const buckets = db.query("SELECT name FROM buckets").all() as { name: string }[];
  const chunks = db
    .query("SELECT id, label FROM chunks WHERE label IS NOT NULL AND label != ''")
    .all() as { id: number; label: string }[];
  const rawEdges = db.query("SELECT chunk_id, bucket_name FROM chunk_buckets").all() as {
    chunk_id: number;
    bucket_name: string;
  }[];
  db.close();

  const label = new Map(chunks.map((c) => [c.id, c.label]));
  // Per-bucket member count (live) and bucket → canonical entity resolution.
  const bucketCount = new Map<string, number>();
  for (const e of rawEdges) bucketCount.set(e.bucket_name, (bucketCount.get(e.bucket_name) ?? 0) + 1);
  const bucketEntity = new Map<string, string>();
  for (const b of buckets) {
    const ent = idx.surfaceToName.get(bucketNorm(b.name));
    if (ent) bucketEntity.set(b.name, ent);
  }
  // An entity may be the target of several buckets; size = sum of those members.
  const entitySize = new Map<string, number>();
  for (const [bn, ent] of bucketEntity) {
    entitySize.set(ent, (entitySize.get(ent) ?? 0) + (bucketCount.get(bn) ?? 0));
  }

  const goldByChunk = new Map<number, Set<string>>();
  const edges: { chunkId: number; entity: string; bin: Bin }[] = [];
  let validEdges = 0;
  for (const e of rawEdges) {
    if (!label.has(e.chunk_id)) continue;
    const ent = bucketEntity.get(e.bucket_name);
    if (!ent) continue;
    validEdges++;
    let set = goldByChunk.get(e.chunk_id);
    if (!set) goldByChunk.set(e.chunk_id, (set = new Set()));
    set.add(ent);
    edges.push({ chunkId: e.chunk_id, entity: ent, bin: binOf(entitySize.get(ent)!) });
  }

  return {
    label,
    goldByChunk,
    entitySize,
    edges,
    counts: {
      buckets: buckets.length,
      labeledChunks: chunks.length,
      rawEdges: rawEdges.length,
      validEdges,
      matchedBuckets: bucketEntity.size,
      chunksWithGold: goldByChunk.size,
    },
  };
}

/** The bin a chunk belongs to for stratification = the bin of its LARGEST gold
 *  entity (matches the bucket-cohesion instrument's stratifier). */
export function chunkBin(gold: Set<string>, entitySize: Map<string, number>): Bin {
  let max = 0;
  for (const g of gold) max = Math.max(max, entitySize.get(g) ?? 0);
  return binOf(max);
}
