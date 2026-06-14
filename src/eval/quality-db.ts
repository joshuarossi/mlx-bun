// Quality-eval DB — the capability/KL counterpart to evaldb.ts (which is
// throughput-only: prefill_tps/decode_tps/peak_bytes). Lives in the SAME
// sqlite file (~/.cache/mlx-bun/evals.sqlite) as a separate `quality_runs`
// table so the throughput head-to-head and the quality gate sit together.
//
// One row = one (model, config) measured on one task (or the aggregate
// "capability" / "kl" rows). `config_json` records the perf levers that
// were active (compile / fused-decode / perf-kernel) so a row is
// self-describing: which arm of the head-to-head produced this number.

import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";
import { DEFAULT_EVAL_DB } from "../evaldb";

const SCHEMA = `
CREATE TABLE IF NOT EXISTS quality_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  model_path TEXT NOT NULL,
  commit_sha TEXT,
  task TEXT NOT NULL,            -- 'kl' | 'gsm8k' | 'mmlu' | ... | 'capability'
  config_json TEXT NOT NULL,     -- {compile,fusedDecode,perfKernel,...} active levers
  n_samples INTEGER NOT NULL,
  -- task accuracy (percent 0-100); null for kl-only rows
  pct REAL,
  -- KL drift block (null for task rows)
  kl_mean REAL,
  kl_median REAL,
  kl_p95 REAL,
  kl_ref TEXT,                   -- 'self:<FLAG>' | model path/id of the reference
  -- aggregate capability score (null except on 'capability' rows)
  capability_score REAL,
  disk_gb REAL,
  notes TEXT,
  machine_state TEXT
);
`;

export interface QualityRun {
  modelPath: string;
  commitSha?: string | null;
  task: string;
  /** Active perf levers when this number was produced. */
  config: Record<string, string | boolean | number | null>;
  nSamples: number;
  pct?: number | null;
  klMean?: number | null;
  klMedian?: number | null;
  klP95?: number | null;
  klRef?: string | null;
  capabilityScore?: number | null;
  diskGb?: number | null;
  notes?: string | null;
  machineState?: string | null;
}

export class QualityDB {
  readonly db: Database;

  constructor(dbPath: string = DEFAULT_EVAL_DB) {
    if (dbPath !== ":memory:") {
      try { mkdirSync(dbPath.slice(0, dbPath.lastIndexOf("/")), { recursive: true }); } catch {}
    }
    this.db = new Database(dbPath);
    this.db.exec(SCHEMA);
  }

  record(run: QualityRun): void {
    this.db.prepare(`
      INSERT INTO quality_runs (ts, model_path, commit_sha, task, config_json,
        n_samples, pct, kl_mean, kl_median, kl_p95, kl_ref,
        capability_score, disk_gb, notes, machine_state)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      Date.now(), run.modelPath, run.commitSha ?? null, run.task,
      JSON.stringify(run.config), run.nSamples,
      run.pct ?? null, run.klMean ?? null, run.klMedian ?? null, run.klP95 ?? null,
      run.klRef ?? null, run.capabilityScore ?? null, run.diskGb ?? null,
      run.notes ?? null, run.machineState ?? null,
    );
  }

  recent(limit = 20): Record<string, unknown>[] {
    return this.db
      .query("SELECT * FROM quality_runs ORDER BY ts DESC LIMIT ?")
      .all(limit) as Record<string, unknown>[];
  }

  close(): void {
    this.db.close();
  }
}
