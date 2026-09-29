// The `jobs` core service over this app's job host and store: what a module's
// job runners run on. A module submits by kind; the runner the loaded module
// declared for it runs as an in-process task, recorded in the same job store
// (and streamed by the same `/api/jobs` routes) as every other job.
import type { JobEmit, JobEvent, JobRecord, JobRunner, JobRunnerSpec, JobService } from "@mlx-bun/app-core";
import type { JobStore } from "./db";
import type { JobRow, JobRunner as AppJobRunner } from "./protocol";
import { tailJob } from "./sse";

/** The runners of the loaded modules, keyed by job kind (`LoadedModules.jobs`). */
export type JobRunners = ReadonlyMap<string, { readonly spec: JobRunnerSpec; readonly runner: JobRunner }>;

/** The part of the job host the service drives. */
export interface JobTasks {
  ensureStore(): JobStore;
  submitTask(kind: string, config: Record<string, unknown>, runner: AppJobRunner, outputPath?: string): { jobId: string };
  cancelTask(jobId: string): void;
}

export interface AppJobService extends JobService {
  /** Serve the job kinds of the loaded modules; before this, every submission is rejected. */
  serve(runners: JobRunners): void;
}

const recordOf = (row: JobRow): JobRecord => ({ id: row.id, kind: row.kind, status: row.status, progress: row.progress, message: row.message,
  outputPath: row.output_path, error: row.error, startedAt: row.started_at, endedAt: row.ended_at });

export function createJobService(host: JobTasks): AppJobService {
  let runners: JobRunners = new Map();
  const store = () => host.ensureStore();
  return {
    serve(served) { runners = served; },
    async submit(submission) {
      const registered = runners.get(submission.kind);
      if (!registered) throw new Error(`no installed module runs job kind "${submission.kind}"`);
      if (registered.spec.isolation !== "task") throw new Error(`job kind "${submission.kind}" runs as a ${registered.spec.isolation}; this host runs task jobs only`);
      // The module's runner speaks the contract's event type; the store records every event the same way.
      const run: AppJobRunner = (emit, config, signal) => registered.runner(emit as JobEmit, config, signal ?? new AbortController().signal);
      const { jobId } = host.submitTask(submission.kind, { ...submission.config }, run, submission.outputPath);
      return recordOf(store().get(jobId)!);
    },
    async get(id) { const row = store().get(id); return row ? recordOf(row) : undefined; },
    async list(filter) {
      // The store's newest-first window; a status filter applies within it.
      return store().recent(1000, filter?.kind).filter(row => !filter?.status || row.status === filter.status).map(recordOf);
    },
    async cancel(id) { host.cancelTask(id); },
    events(id, signal) { return tailJob(store(), id, { follow: true, ...(signal ? { signal } : {}) }) as AsyncIterable<JobEvent>; },
  };
}
