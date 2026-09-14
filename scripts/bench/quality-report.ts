/** Portable export of existing quality_runs rows; never loads a model. */
import { Database } from "bun:sqlite";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";

export interface QualityRecord {
  id: number; ts: number; model_path: string; task: string; config_json: string; n_samples: number;
  commit_sha?: string | null; pct?: number | null; disk_gb?: number | null;
  kl_mean?: number | null; kl_median?: number | null; kl_p95?: number | null; kl_ref?: string | null;
  capability_score?: number | null; notes?: string | null; machine_state?: string | null;
}
export interface QualityReport {
  kind: "model-quality-ledger"; schemaVersion: 1; exportedAt: string; sourceDatabase: string;
  rows: QualityRecord[];
}
export interface LoadedQualityReport {
  kind: "quality"; path: string; sha256: string; bytes: number; report: QualityReport;
}
const object = (x: unknown): x is Record<string, unknown> => x !== null && typeof x === "object" && !Array.isArray(x);
export function validateQualityReport(value: unknown, path: string): QualityReport {
  if (!object(value) || value.kind !== "model-quality-ledger" || value.schemaVersion !== 1 || !Array.isArray(value.rows)
    || typeof value.exportedAt !== "string" || typeof value.sourceDatabase !== "string")
    throw Error(`${path}: expected model-quality-ledger schema 1 with rows[] and export provenance`);
  for (const [index,row] of value.rows.entries()) {
    if (!object(row)) throw Error(`${path}: row ${index} must be an object`);
    for (const field of ["id","ts","n_samples"])
      if (!Number.isSafeInteger(row[field]) || (row[field] as number) < 0) throw Error(`${path}: row ${index} needs nonnegative ${field}`);
    for (const field of ["model_path","task","config_json"])
      if (typeof row[field] !== "string") throw Error(`${path}: row ${index} needs ${field}`);
    for (const field of ["pct","disk_gb","kl_mean","kl_median","kl_p95","capability_score"])
      if (row[field] != null && (typeof row[field] !== "number" || !Number.isFinite(row[field])))
        throw Error(`${path}: row ${index} has invalid ${field}`);
  }
  return value as unknown as QualityReport;
}

export function exportQuality(database: string): QualityReport {
  // A read-only connection neither creates a missing DB nor migrates its schema.
  // One SELECT includes WAL-visible committed rows in a single read snapshot.
  const db = new Database(database, { readonly: true });
  try {
    return validateQualityReport({ kind: "model-quality-ledger", schemaVersion: 1,
      exportedAt: new Date().toISOString(), sourceDatabase: resolve(database),
      rows: db.query("SELECT * FROM quality_runs ORDER BY ts, id").all() }, database);
  } finally { db.close(); }
}

if (import.meta.main) {
  const args = process.argv.slice(2);
  if (args.length !== 4 || args[0] !== "--db" || args[2] !== "--out")
    throw Error("Usage: bun scripts/bench/quality-report.ts --db <evals.sqlite> --out <quality.json>");
  const report = exportQuality(args[1]!);
  mkdirSync(dirname(resolve(args[3]!)), { recursive: true });
  await Bun.write(args[3]!, JSON.stringify(report,null,2));
  console.log(JSON.stringify({out:args[3],rows:report.rows.length}));
}
