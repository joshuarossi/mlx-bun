// The `jobs` core service over this app's job host and store: what a module's
// job runners run on. A module submits by kind and the loaded module's runner
// spec decides how it runs, recorded in the same job store (and streamed by
// the same `/api/jobs` routes) as every other job: a `task` runs in this
// process; a `process` runs as a child that stops with its parent, under the
// host's execution lease (the child activates the module itself,
// `cli/job-entry.ts`).
import type { JobEmit, JobEvent, JobRecord, JobRunner, JobRunnerSpec, JobService } from "@mlx-bun/app-core";
import type { DisposableResource } from "@mlx-bun/inference/contracts/portable";
import type { JobStore } from "./db";
import type { JobRow, JobRunner as AppJobRunner } from "./protocol";
import { tailJob } from "./sse";

/** The runners of the loaded modules, keyed by job kind (`LoadedModules.jobs`). */
export type JobRunners = ReadonlyMap<string, { readonly spec: JobRunnerSpec; readonly runner: JobRunner }>;

/** The part of the job host the service drives. */
export interface JobTasks {
  ensureStore(): JobStore;
  submitTask(kind: string, config: Record<string, unknown>, runner: AppJobRunner, outputPath?: string): { jobId: string };
  cancelTask(jobId: string): Promise<void>;
  /** Queue a child process for the kind under the host's execution lease. */
  submit(kind: string, config: Record<string, unknown>, outputPath?: string, scratchDir?: string): { jobId: string };
  cancelProcess(jobId: string): Promise<void>;
}

export interface AppJobService extends JobService {
  /** Serve the job kinds of the loaded modules; before this, every submission is rejected. */
  serve(runners: JobRunners): void;
}

const recordOf = (row: JobRow): JobRecord => ({ id: row.id, kind: row.kind, status: row.status, progress: row.progress, message: row.message,
  outputPath: row.output_path, error: row.error, startedAt: row.started_at, endedAt: row.ended_at });

export interface JobServiceOptions {
  /** The engine's execution lease: a runner that declared `gpu: "exclusive"` holds it for its whole run, so no model generates meanwhile. */
  acquire?(signal: AbortSignal): Promise<DisposableResource>;
}

export function createJobService(host: JobTasks, options: JobServiceOptions = {}): AppJobService {
  let runners: JobRunners = new Map();
  const store = () => host.ensureStore();
  return {
    serve(served) { runners = served; },
    async submit(submission) {
      const registered = runners.get(submission.kind);
      if (!registered) throw new Error(`no installed module runs job kind "${submission.kind}"`);
      const { isolation, gpu } = registered.spec;
      if (isolation === "process") {
        // The host's children run under its execution lease, so no model generates meanwhile.
        if (gpu !== "exclusive") throw new Error(`job kind "${submission.kind}": this host runs process jobs only with the exclusive GPU lease`);
        const { jobId } = host.submit(submission.kind, { ...submission.config }, submission.outputPath, submission.scratchDir);
        return recordOf(store().get(jobId)!);
      }
      // The module's runner speaks the contract's event type; the store records every event the same way.
      const exclusive = registered.spec.gpu === "exclusive" && options.acquire;
      const run: AppJobRunner = async (emit, config, signal) => {
        const stop = signal ?? new AbortController().signal;
        if (!exclusive) return registered.runner(emit as JobEmit, config, stop);
        emit({ type: "stage", stage: "waiting", progress: 0, message: "waiting for in-flight generation to drain" });
        const lease = await exclusive(stop);
        try { return await registered.runner(emit as JobEmit, config, stop); } finally { lease.dispose(); }
      };
      const { jobId } = host.submitTask(submission.kind, { ...submission.config }, run, submission.outputPath);
      return recordOf(store().get(jobId)!);
    },
    async get(id) { const row = store().get(id); return row ? recordOf(row) : undefined; },
    async list(filter) {
      // The store's newest-first window; a status filter applies within it.
      return store().recent(1000, filter?.kind).filter(row => !filter?.status || row.status === filter.status).map(recordOf);
    },
    async cancel(id) { await Promise.all([host.cancelTask(id), host.cancelProcess(id)]); },
    events(id, signal) { return tailJob(store(), id, { follow: true, ...(signal ? { signal } : {}) }) as AsyncIterable<JobEvent>; },
  };
}
