// Job store: every background job (quantize / finetune / dataset) is a row
// here (bun:sqlite, WAL). The runner streams NDJSON events to a per-job log
// file and mirrors progress/message back onto the row so a status page can
// read state without tailing logs. Port of optiq lab db.py's `jobs` table.
//
// WAL is load-bearing: the SSE poller reads while the job (or its child
// process) writes — without WAL the reader and writer fight over the lock.

import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";
import { join } from "node:path";
import type { JobRow, JobStatus } from "./types";

export const DEFAULT_JOBS_DB = `${process.env.HOME}/.cache/mlx-bun/jobs.sqlite`;
export const DEFAULT_JOBS_DIR = `${process.env.HOME}/.cache/mlx-bun/jobs`;

const SCHEMA = `
CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,
  status TEXT NOT NULL,
  config_json TEXT NOT NULL,
  progress REAL NOT NULL DEFAULT 0,
  message TEXT,
  log_path TEXT NOT NULL,
  output_path TEXT,
  error TEXT,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  ended_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_jobs_status_started
  ON jobs(status, started_at DESC);
`;

/** A new job id: `job_` + 16 hex chars from a CSPRNG (matches optiq's
 *  `job_<uuid4 hex[:16]>` shape; collision-free enough for a local lab). */
export function newJobId(): string {
  const bytes = new Uint8Array(8);
  crypto.getRandomValues(bytes);
  let hex = "";
  for (const b of bytes) hex += b.toString(16).padStart(2, "0");
  return `job_${hex}`;
}

export class JobStore {
  readonly db: Database;
  readonly dbPath: string;
  readonly logsDir: string;

  constructor(dbPath: string = DEFAULT_JOBS_DB, logsDir: string = DEFAULT_JOBS_DIR) {
    if (dbPath !== ":memory:") {
      try { mkdirSync(dbPath.slice(0, dbPath.lastIndexOf("/")), { recursive: true }); } catch {}
    }
    try { mkdirSync(logsDir, { recursive: true }); } catch {}
    this.dbPath = dbPath;
    this.logsDir = logsDir;
    this.db = new Database(dbPath);
    this.db.exec("PRAGMA journal_mode = WAL");
    this.db.exec(SCHEMA);
    this.migrate();
  }

  /** Additive-only migration: job rows are real records (a finished
   *  quantize output is referenced by `output_path`), never dropped on
   *  schema drift — unlike the registry cache. Re-opening an existing DB
   *  is a no-op. */
  private migrate(): void {
    const cols = (this.db.query("PRAGMA table_info(jobs)").all() as { name: string }[])
      .map((c) => c.name);
    // No columns to add today; the hook stays so future fields are additive.
    void cols;
  }

  /** Create a queued job. `log_path` is computed under `logsDir`; the file
   *  is created so a tail started immediately sees an empty (not missing)
   *  file. */
  create(kind: string, config: Record<string, unknown>, outputPath?: string): JobRow {
    const id = newJobId();
    const logPath = join(this.logsDir, `${id}.log`);
    // touch the log so tailJob's first read finds an (empty) file
    try { Bun.write(logPath, ""); } catch {}
    this.db.prepare(`
      INSERT INTO jobs (id, kind, status, config_json, log_path, output_path)
      VALUES (?, ?, 'queued', ?, ?, ?)
    `).run(id, kind, JSON.stringify(config), logPath, outputPath ?? null);
    return this.get(id)!;
  }

  get(id: string): JobRow | null {
    return (this.db.query("SELECT * FROM jobs WHERE id = ?").get(id) as JobRow | null) ?? null;
  }

  recent(limit = 10, kind?: string): JobRow[] {
    if (kind) {
      return this.db
        .query("SELECT * FROM jobs WHERE kind = ? ORDER BY started_at DESC LIMIT ?")
        .all(kind, limit) as JobRow[];
    }
    return this.db
      .query("SELECT * FROM jobs ORDER BY started_at DESC LIMIT ?")
      .all(limit) as JobRow[];
  }

  setStatus(id: string, status: JobStatus, opts: { error?: string; endedAt?: string } = {}): void {
    const sets = ["status = ?"];
    const args: (string | null)[] = [status];
    if (opts.error !== undefined) { sets.push("error = ?"); args.push(opts.error); }
    if (opts.endedAt !== undefined) { sets.push("ended_at = ?"); args.push(opts.endedAt); }
    args.push(id);
    this.db.prepare(`UPDATE jobs SET ${sets.join(", ")} WHERE id = ?`).run(...args);
  }

  setProgress(id: string, progress: number, message?: string): void {
    if (message !== undefined) {
      this.db.prepare("UPDATE jobs SET progress = ?, message = ? WHERE id = ?")
        .run(progress, message, id);
    } else {
      this.db.prepare("UPDATE jobs SET progress = ? WHERE id = ?").run(progress, id);
    }
  }

  setOutputPath(id: string, p: string): void {
    this.db.prepare("UPDATE jobs SET output_path = ? WHERE id = ?").run(p, id);
  }

  /** Boot recovery: any job left 'queued'/'running' from a previous process
   *  lifetime is a zombie (its in-process task / child process died with us).
   *  The UI surfaces these for cleanup. */
  markZombies(): number {
    const r = this.db
      .prepare("UPDATE jobs SET status = 'zombie' WHERE status IN ('queued', 'running')")
      .run();
    return r.changes;
  }

  close(): void {
    this.db.close();
  }
}
