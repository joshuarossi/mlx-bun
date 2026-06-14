// Public API for the background job system. The server imports from here:
// create/track jobs (JobStore), submit work (in-process or GPU-leased
// subprocess), gate inference on GPU jobs, and stream a job's log over SSE.

export { JobStore, DEFAULT_JOBS_DB, DEFAULT_JOBS_DIR, newJobId } from "./db";
export {
  registerRunner,
  getRunner,
  submitInProcess,
  submitSubprocess,
  makeEmit,
  isGpuBusy,
  currentGpuJob,
  drainQueue,
  JOB_ENTRY_PATH,
} from "./runner";
export type { SubmitResult, SubprocessOpts } from "./runner";
export { tailJob, streamJobResponse } from "./sse";
export type { TailOpts } from "./sse";

// Re-export the shared contract so consumers have one import site.
export type {
  JobEvent,
  Emit,
  JobRunner,
  JobKind,
  JobStatus,
  JobRow,
} from "./types";
