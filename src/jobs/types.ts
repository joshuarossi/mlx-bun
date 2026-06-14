// Shared job-system contract. Both the job runner (src/jobs/*) and every
// job producer (src/dataset/*, src/quantize/*, src/train/*) speak this
// vocabulary. Mirrors the optiq lab SSE event grammar so the web wizards
// port over mechanically (started → log/stage/metric → done|failed).

/** A single streamed job event, serialized one-per-line into the job's
 *  NDJSON log and re-emitted to the browser as SSE `data:` frames. */
export type JobEvent =
  | { type: "started"; ts: number }
  | { type: "log"; line: string }
  | {
      type: "stage";
      stage: string;
      progress?: number; // 0..1
      message?: string;
      [k: string]: unknown;
    }
  | {
      type: "metric";
      kind: "train" | "val";
      step: number;
      loss: number;
      [k: string]: unknown; // grad_norm, learning_rate, tokens_per_sec, accuracy, margin, progress, message
    }
  | { type: "done"; ts: number; output_dir?: string; summary?: unknown; [k: string]: unknown }
  | { type: "failed"; error: string; ts: number };

/** Sink a job calls to report progress. Implementations append to the log
 *  file and (for stage/metric events carrying `progress`/`message`) update
 *  the SQLite row. Never throws — a logging failure must not kill a job. */
export type Emit = (e: JobEvent) => void;

/** The unit of work. Returns an optional output path recorded on the row.
 *  Receives the parsed `config` from the submit request. */
export type JobRunner = (
  emit: Emit,
  config: Record<string, unknown>,
) => Promise<{ outputPath?: string } | void>;

/** Job kinds in the system. */
export type JobKind = "quantize" | "finetune" | "dataset" | "noop" | "crash";

export type JobStatus = "queued" | "running" | "done" | "failed" | "zombie";

/** A persisted job row (shape returned by the HTTP `GET /api/jobs/:id`). */
export interface JobRow {
  id: string;
  kind: string;
  status: JobStatus;
  config_json: string;
  progress: number;
  message: string | null;
  log_path: string;
  output_path: string | null;
  error: string | null;
  started_at: string;
  ended_at: string | null;
}
