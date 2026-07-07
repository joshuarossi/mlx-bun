// Shared frontend-only protocol shapes that don't already live on the
// server side as exported types. The WS contract itself (ClientMessage /
// ServerMessage / HistoryItem / SessionListItem / ReadyGenDefaults) is
// imported type-only from ../../pi-web — see chat.ts. This file only holds
// shapes with no server-side export to anchor to (e.g. the SSE job-stream
// events, which live as a doc-comment in app.html today, not a type).
//
// Pointer comment for the server side: src/web/src/protocol.ts mirrors the
// SSE line protocol documented at the jobStream() call site (api.ts) —
// keep the two adjacent if the job event shape changes server-side
// (scripts/ that emit `data:` lines for /api/jobs/:id/stream).

/** One line of the /api/jobs/:id/stream SSE protocol (JSON per `data:` line). */
export type JobEvent =
  | { type: "log"; line: string }
  | {
      type: "stage";
      stage: string;
      progress?: number;
      message?: string;
      output_dir?: string;
      adapter_path?: string;
      // Dataset-generation-specific row counts (present on the dataset
      // builder's job stream only; absent/ignored for quantize/finetune).
      n_train?: number;
      n_valid?: number;
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
    }
  | { type: "done"; n_train?: number; n_valid?: number }
  | { type: "failed"; error?: string };

/** Handlers passed to jobStream(); each key is an optional callback for the
 *  matching JobEvent variant, plus an `error` callback for the EventSource's
 *  own onerror (transport failure, not a `failed` protocol event). */
export interface JobStreamHandlers {
  log?: (e: Extract<JobEvent, { type: "log" }>) => void;
  stage?: (e: Extract<JobEvent, { type: "stage" }>) => void;
  metric?: (e: Extract<JobEvent, { type: "metric" }>) => void;
  done?: (e: Extract<JobEvent, { type: "done" }>) => void;
  failed?: (e: Extract<JobEvent, { type: "failed" }>) => void;
  error?: () => void;
}

/** Generic envelope every /api/* JSON endpoint returns on success or
 *  failure (api() in api.ts unwraps {error:{message}} to a plain string —
 *  see the doc-comment there). Individual endpoints add their own fields
 *  on top via intersection at the call site; this is just the shared base. */
export interface ApiEnvelope {
  ok?: boolean;
  error?: string;
  message?: string;
  [key: string]: unknown;
}
