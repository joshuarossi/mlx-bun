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
      output_dir?: string;
      adapter_path?: string;
      n_train?: number;
      n_valid?: number;
      [k: string]: unknown;
    }
  | {
      type: "metric";
      kind: "train" | "val";
      step: number;
      loss: number;
      learning_rate?: number;
      tokens_per_sec?: number;
      progress?: number;
      message?: string;
      [k: string]: unknown; // grad_norm, learning_rate, tokens_per_sec, accuracy, margin, progress, message
    }
  | { type: "done"; ts: number; output_dir?: string; summary?: unknown; n_train?: number; n_valid?: number; [k: string]: unknown }
  | { type: "failed"; error: string; ts: number };

/** Sink a job calls to report progress. Implementations append to the log
 *  file and (for stage/metric events carrying `progress`/`message`) update
 *  the SQLite row. Logging failures must not kill a job; the task owner may
 * throw cancellation when a runner reports progress after shutdown. */
export type Emit = (e: JobEvent) => void;

/** The unit of work. Returns an optional output path recorded on the row.
 *  Receives the parsed `config` from the submit request. In-process runners
 * receive a shutdown signal and must pass it to cancellable I/O. */
export type JobRunner = (
  emit: Emit,
  config: Record<string, unknown>,
  signal?: AbortSignal,
) => Promise<{ outputPath?: string } | void>;

/** Job kinds in the system. */
export type JobKind = "quantize" | "finetune" | "dataset";

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
