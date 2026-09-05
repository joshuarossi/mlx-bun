import type { JobEvent } from "../../contracts/jobs";
export type { JobEvent } from "../../contracts/jobs";

/** Handlers passed to jobStream(); each key is an optional callback for the
 *  matching JobEvent variant, plus an `error` callback for the EventSource's
 *  own onerror (transport failure, not a `failed` protocol event). */
export interface JobStreamHandlers {
  started?: (e: Extract<JobEvent, { type: "started" }>) => void;
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
