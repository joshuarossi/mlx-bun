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
