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

