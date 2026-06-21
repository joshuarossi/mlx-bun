// mlx-bun memory — synthesis bookkeeping store (bun:sqlite).
//
// ⚠️ M1 STUB schema-wise the tables are real, but no stage writes them yet.
// The read path (vault.ts / tools.ts) does NOT touch this — it's only used by
// the synthesis pipeline (pipeline.ts), which is itself stubbed.
//
// Reuses mlx-bun's existing per-domain sqlite pattern (cf. JobStore in
// src/jobs/db.ts, EvalDB in src/evaldb.ts): a small class over bun:sqlite with
// WAL + schema-in-constructor + an additive migrate() hook, living under
// ~/.cache/mlx-bun/ alongside jobs.sqlite / evals.sqlite / registry.sqlite. It's
// derived state — rebuildable from the pi transcripts + the vault articles — so
// it belongs in the rebuildable cache, NOT in the (precious, git-tracked) vault.
//
// The schema mirrors lucien's incremental design: per-source watermarks (don't
// re-ingest), chunked_at > updated_at (re-chunk only changed convs), and a
// synthesized-chunk ledger (never fold the same chunk into an article twice).

import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";

export const DEFAULT_MEMORY_DB = `${process.env.HOME}/.cache/mlx-bun/memory.sqlite`;

export interface ConversationRow {
  /** Stable conv id: first 8 hex of the session UUID (the conv:HASH citation). */
  conv: string;
  source: string; // "pi-web" | "pi-terminal"
  title: string;
  /** Full normalized transcript JSON ({role, content}[]). */
  transcript: string;
  updated_at: number;
  chunked_at: number | null;
}

export interface ChunkRow {
  id: string;
  conv: string;
  ordinal: number;
  text: string;
  bucket: string | null;
}

export interface BucketRow {
  name: string;
  article: string; // target article stem
  description: string;
}

const SCHEMA = `
CREATE TABLE IF NOT EXISTS conversations (
  conv       TEXT PRIMARY KEY,
  source     TEXT NOT NULL,
  title      TEXT NOT NULL DEFAULT '',
  transcript TEXT NOT NULL,
  updated_at INTEGER NOT NULL,
  chunked_at INTEGER
);
CREATE TABLE IF NOT EXISTS chunks (
  id      TEXT PRIMARY KEY,
  conv    TEXT NOT NULL REFERENCES conversations(conv),
  ordinal INTEGER NOT NULL,
  text    TEXT NOT NULL,
  bucket  TEXT
);
CREATE INDEX IF NOT EXISTS idx_chunks_conv ON chunks(conv);
CREATE TABLE IF NOT EXISTS buckets (
  name        TEXT PRIMARY KEY,
  article     TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT ''
);
-- Per-source ingest watermark: only process what's new since last run.
CREATE TABLE IF NOT EXISTS watermarks (
  source     TEXT PRIMARY KEY,
  cursor     TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
-- Idempotency ledger: a (bucket, chunk) pair is folded into an article once.
CREATE TABLE IF NOT EXISTS synthesized_bucket_chunks (
  bucket   TEXT NOT NULL,
  chunk_id TEXT NOT NULL,
  PRIMARY KEY (bucket, chunk_id)
);
`;

/**
 * Synthesis bookkeeping DB. Same shape as JobStore/EvalDB: open in the
 * constructor (WAL on, schema ensured, additive migrate), expose `db`, and a
 * `close()`. Only the synthesis pipeline constructs one — opening it is what
 * *creates* memory.sqlite, so the read path never does. Stage queries land in
 * M1; the tables they expect already exist here.
 */
export class MemoryStore {
  readonly db: Database;
  readonly dbPath: string;

  constructor(dbPath: string = DEFAULT_MEMORY_DB) {
    if (dbPath !== ":memory:") {
      try { mkdirSync(dbPath.slice(0, dbPath.lastIndexOf("/")), { recursive: true }); } catch {}
    }
    this.dbPath = dbPath;
    this.db = new Database(dbPath);
    this.db.exec("PRAGMA journal_mode = WAL");
    this.db.exec(SCHEMA);
    this.migrate();
  }

  /** Additive-only migrations (mirrors JobStore.migrate). Re-opening is a no-op. */
  private migrate(): void {
    // No columns to add today; the hook stays so future fields are additive.
  }

  close(): void {
    this.db.close();
  }
}
