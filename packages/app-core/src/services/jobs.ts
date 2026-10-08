/** A single streamed job event, recorded one per line and re-emitted as SSE. */
export type JobEvent =
  | { type: "started"; ts: number }
  | { type: "log"; line: string }
  | { type: "stage"; stage: string; progress?: number; message?: string; [field: string]: unknown }
  | { type: "metric"; kind: string; step: number; progress?: number; message?: string; [field: string]: unknown }
  | { type: "done"; ts: number; [field: string]: unknown }
  | { type: "failed"; error: string; ts: number };

export type JobStatus = "queued" | "running" | "done" | "failed" | "zombie";

export interface JobRecord {
  readonly id: string;
  /** A kind a module registered through its manifest. */
  readonly kind: string;
  readonly status: JobStatus;
  readonly progress: number;
  readonly message: string | null;
  readonly outputPath: string | null;
  readonly error: string | null;
  readonly startedAt: string;
  readonly endedAt: string | null;
}

export interface JobSubmission {
  readonly kind: string;
  readonly config: Readonly<Record<string, unknown>>;
  readonly outputPath?: string;
  /** A directory the submitter owns for the job's temporary files: a `process` job's `TMPDIR`. The submitter removes it after the job ends. */
  readonly scratchDir?: string;
}

/** Sink a runner calls to report progress. Failing to record must not kill the job. */
export type JobEmit = (event: JobEvent) => void;

/** The unit of work a module registers per job kind. Honor `signal` in every cancellable wait. */
export type JobRunner = (emit: JobEmit, config: Readonly<Record<string, unknown>>, signal: AbortSignal) =>
  Promise<{ readonly outputPath?: string } | void>;

/** Persisted job state and job lifetimes. A `gpu: "exclusive"` job holds the
 * execution lease, so no model generates while it runs. */
export interface JobService {
  /** Rejects a kind no installed module registered. */
  submit(submission: JobSubmission): Promise<JobRecord>;
  get(id: string): Promise<JobRecord | undefined>;
  list(filter?: { readonly kind?: string; readonly status?: JobStatus }): Promise<readonly JobRecord[]>;
  /** Stops a queued or running job and resolves once it has ended and its process, if any, is gone; on a finished job, once its process is gone. */
  cancel(id: string): Promise<void>;
  /** Replays recorded events, then follows until the job ends. */
  events(id: string, signal?: AbortSignal): AsyncIterable<JobEvent>;
}
