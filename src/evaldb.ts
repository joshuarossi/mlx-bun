// Eval DB: every benchmark run recorded with model + config + commit
// (bun:sqlite). The fit calculator's predictions are validated against
// the measured peaks recorded here.

import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";

export const DEFAULT_EVAL_DB = `${process.env.HOME}/.cache/mlx-bun/evals.sqlite`;

const SCHEMA = `
CREATE TABLE IF NOT EXISTS runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  model_path TEXT NOT NULL,
  commit_sha TEXT,
  prompt_tokens INTEGER NOT NULL,
  cached_tokens INTEGER NOT NULL DEFAULT 0,
  generated_tokens INTEGER NOT NULL,
  prefill_tps REAL NOT NULL,
  decode_tps REAL NOT NULL,
  peak_bytes INTEGER NOT NULL,
  predicted_peak_bytes INTEGER,
  predicted_decode_tps REAL,
  notes TEXT
);

-- Phase 18 P1 — parallel-load harness. ONE row per configuration point
-- (a concurrency level or an arrival-rate target), not per request: the
-- single-stream runs table can't hold p50/p95 distributions or a
-- concurrency axis. Same additive-migration discipline as runs (these
-- are real measurements, never dropped). stack + machine_state mirror the
-- runs columns so cross-stack load rows read the same way.
CREATE TABLE IF NOT EXISTS load_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  model_id TEXT NOT NULL,
  base_url TEXT NOT NULL,
  stack TEXT NOT NULL DEFAULT 'mlx-bun',
  commit_sha TEXT,
  mode TEXT NOT NULL,              -- 'closed-loop' | 'open-loop'
  concurrency INTEGER NOT NULL,    -- in-flight cap (closed) or requester count (open)
  target_rpm REAL,                 -- open-loop arrival target per requester (null = closed)
  max_tokens INTEGER NOT NULL,
  requests_ok INTEGER NOT NULL,
  requests_err INTEGER NOT NULL,
  duration_s REAL NOT NULL,        -- wall time of the measured window
  ttft_p50_ms REAL NOT NULL,
  ttft_p95_ms REAL NOT NULL,
  e2e_p50_ms REAL NOT NULL,
  e2e_p95_ms REAL NOT NULL,
  e2e_p99_ms REAL NOT NULL,
  agg_tps REAL NOT NULL,           -- generated tokens/s summed across streams
  per_req_tps REAL NOT NULL,       -- median per-stream decode tok/s
  achieved_rpm REAL NOT NULL,      -- completed requests/min over the window
  peak_bytes INTEGER,              -- from /stats if exposed, else null
  notes TEXT,
  machine_state TEXT
);
`;

export interface EvalRun {
  modelPath: string;
  commitSha?: string | null;
  promptTokens: number;
  cachedTokens?: number;
  generatedTokens: number;
  prefillTps: number;
  decodeTps: number;
  peakBytes: number;
  predictedPeakBytes?: number | null;
  predictedDecodeTps?: number | null;
  notes?: string | null;
  /** Which engine produced the number: mlx-bun (default) | mlx-lm | optiq. */
  stack?: string;
  /** JSON snapshot of preflight machine state (swap, free %, thermal). */
  machineState?: string | null;
}

/** One configuration point of a parallel-load sweep (Phase 18 P1). */
export interface LoadRun {
  modelId: string;
  baseUrl: string;
  stack?: string;
  commitSha?: string | null;
  /** 'closed-loop' (fixed in-flight) or 'open-loop' (target arrival rate). */
  mode: "closed-loop" | "open-loop";
  /** In-flight cap (closed-loop) or requester count (open-loop). */
  concurrency: number;
  /** Per-requester target rpm (open-loop only; null for closed-loop). */
  targetRpm?: number | null;
  maxTokens: number;
  requestsOk: number;
  requestsErr: number;
  durationS: number;
  ttftP50Ms: number;
  ttftP95Ms: number;
  e2eP50Ms: number;
  e2eP95Ms: number;
  e2eP99Ms: number;
  /** Generated tokens/s summed across all streams in the window. */
  aggTps: number;
  /** Median per-stream decode tok/s. */
  perReqTps: number;
  /** Completed requests per minute over the measured window. */
  achievedRpm: number;
  /** Peak resident bytes sampled from /stats, if the server exposes it. */
  peakBytes?: number | null;
  notes?: string | null;
  machineState?: string | null;
}

export class EvalDB {
  readonly db: Database;

  constructor(dbPath: string = DEFAULT_EVAL_DB) {
    if (dbPath !== ":memory:") {
      try { mkdirSync(dbPath.slice(0, dbPath.lastIndexOf("/")), { recursive: true }); } catch {}
    }
    this.db = new Database(dbPath);
    this.db.exec(SCHEMA);
    // Additive migrations — eval rows are real data, never dropped
    // (unlike the registry, which is a rebuildable cache).
    const cols = (this.db.query("PRAGMA table_info(runs)").all() as { name: string }[])
      .map((c) => c.name);
    if (!cols.includes("stack"))
      this.db.exec("ALTER TABLE runs ADD COLUMN stack TEXT NOT NULL DEFAULT 'mlx-bun'");
    if (!cols.includes("machine_state"))
      this.db.exec("ALTER TABLE runs ADD COLUMN machine_state TEXT");
  }

  record(run: EvalRun): void {
    this.db.prepare(`
      INSERT INTO runs (ts, model_path, commit_sha, prompt_tokens, cached_tokens,
        generated_tokens, prefill_tps, decode_tps, peak_bytes,
        predicted_peak_bytes, predicted_decode_tps, notes, stack, machine_state)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      Date.now(), run.modelPath, run.commitSha ?? null,
      run.promptTokens, run.cachedTokens ?? 0, run.generatedTokens,
      run.prefillTps, run.decodeTps, run.peakBytes,
      run.predictedPeakBytes ?? null, run.predictedDecodeTps ?? null,
      run.notes ?? null, run.stack ?? "mlx-bun", run.machineState ?? null,
    );
  }

  /** Record one parallel-load configuration point (Phase 18 P1). */
  recordLoad(run: LoadRun): void {
    this.db.prepare(`
      INSERT INTO load_runs (ts, model_id, base_url, stack, commit_sha, mode,
        concurrency, target_rpm, max_tokens, requests_ok, requests_err,
        duration_s, ttft_p50_ms, ttft_p95_ms, e2e_p50_ms, e2e_p95_ms, e2e_p99_ms,
        agg_tps, per_req_tps, achieved_rpm, peak_bytes, notes, machine_state)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      Date.now(), run.modelId, run.baseUrl, run.stack ?? "mlx-bun",
      run.commitSha ?? null, run.mode, run.concurrency, run.targetRpm ?? null,
      run.maxTokens, run.requestsOk, run.requestsErr, run.durationS,
      run.ttftP50Ms, run.ttftP95Ms, run.e2eP50Ms, run.e2eP95Ms, run.e2eP99Ms,
      run.aggTps, run.perReqTps, run.achievedRpm, run.peakBytes ?? null,
      run.notes ?? null, run.machineState ?? null,
    );
  }

  recentLoad(limit = 20): Record<string, unknown>[] {
    return this.db
      .query("SELECT * FROM load_runs ORDER BY ts DESC LIMIT ?")
      .all(limit) as Record<string, unknown>[];
  }

  /** Latest mlx-bun measurement for a model snapshot (status page:
   *  measured numbers beat predictions when available). */
  latestFor(modelPath: string): { decodeTps: number; ts: number; notes: string | null } | null {
    const r = this.db
      .query("SELECT decode_tps, ts, notes FROM runs WHERE model_path = ? AND stack = 'mlx-bun' ORDER BY ts DESC LIMIT 1")
      .get(modelPath) as { decode_tps: number; ts: number; notes: string | null } | null;
    return r ? { decodeTps: r.decode_tps, ts: r.ts, notes: r.notes } : null;
  }

  recent(limit = 20): Record<string, unknown>[] {
    return this.db
      .query("SELECT * FROM runs ORDER BY ts DESC LIMIT ?")
      .all(limit) as Record<string, unknown>[];
  }

  close(): void {
    this.db.close();
  }
}

export function gitCommit(): string | null {
  try {
    const r = Bun.spawnSync(["git", "rev-parse", "--short", "HEAD"], {
      cwd: import.meta.dir,
    });
    return r.exitCode === 0 ? r.stdout.toString().trim() : null;
  } catch {
    return null;
  }
}
