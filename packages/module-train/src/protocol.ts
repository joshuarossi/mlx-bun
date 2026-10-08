/** Browser data and optional host presentation hooks. No backend imports. */
export interface PanelConnection {
  readonly apiBase: string;
  readonly eventsUrl: string;
  readonly ui?: {
    notify?(message: string, kind?: "ok" | "err"): void;
    publish?(container: HTMLElement, source: { kind: "quantize" | "finetune" | "dataset"; job_id?: string; source_path?: string }): void | Promise<void>;
    modelId?(): string | undefined;
    catalogChanged?(): void;
  };
}
export interface ApiEnvelope { ok?: boolean; error?: string; message?: string; [key: string]: unknown }
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

export interface JobStreamHandlers {
  started?: (e: Extract<JobEvent, { type: "started" }>) => void;
  log?: (e: Extract<JobEvent, { type: "log" }>) => void;
  stage?: (e: Extract<JobEvent, { type: "stage" }>) => void;
  metric?: (e: Extract<JobEvent, { type: "metric" }>) => void;
  done?: (e: Extract<JobEvent, { type: "done" }>) => void;
  failed?: (e: Extract<JobEvent, { type: "failed" }>) => void;
  error?: () => void;
}

