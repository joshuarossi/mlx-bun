// A recorded event stream and a fake job service, shared by the module's tests.
import type { AppEvent, JobRecord, JobService, JobSubmission, StorageService } from "@mlx-bun/app-core";

/** One host's story: a chat model loads, serves three requests (one cache hit, one cancelled), samples, and a second model evicts it. */
export const RECORDED: readonly AppEvent[] = [
  { type: "model.load", at: 1_000, model: "org/chat", phase: "started" },
  { type: "model.load", at: 1_900, model: "org/chat", phase: "finished", ms: 900, weightsBytes: 400_000_000 },
  { type: "model.memory", at: 1_950, model: "org/chat", weightsBytes: 400_000_000, kvBytes: 0, prefixCacheBytes: 0 },
  { type: "scheduler.sample", at: 2_000, model: "org/chat", active: 0, capacity: 4, queued: 0, tokensPerSecond: 0 },
  { type: "request.finished", at: 2_500, model: "org/chat", requestId: "req-1", finish: "stop", promptTokens: 100, cachedPromptTokens: 0, completionTokens: 40,
    queueMs: 2, ttftMs: 120, prefillTokensPerSecond: 900, decodeTokensPerSecond: 210, totalMs: 320 },
  { type: "request.finished", at: 2_600, model: "org/chat", requestId: "req-2", finish: "length", promptTokens: 120, cachedPromptTokens: 100, completionTokens: 64,
    queueMs: 10, ttftMs: 40, prefillTokensPerSecond: 1_000, decodeTokensPerSecond: 190, totalMs: 400 },
  { type: "request.finished", at: 2_700, model: "org/chat", requestId: "req-3", finish: "cancelled", promptTokens: 80, cachedPromptTokens: 0, completionTokens: 0,
    queueMs: 50, ttftMs: null, prefillTokensPerSecond: null, decodeTokensPerSecond: null, totalMs: 60 },
  { type: "scheduler.sample", at: 3_000, model: "org/chat", active: 3, capacity: 4, queued: 2, tokensPerSecond: 512 },
  { type: "cache.sample", at: 3_000, model: "org/chat", cache: "kv", bytes: 30_000_000, capacityBytes: 1_000_000_000, hits: null, misses: null },
  { type: "cache.sample", at: 3_000, model: "org/chat", cache: "prefix", bytes: 5_000_000, capacityBytes: 8_000_000_000, hits: 3, misses: 1 },
  { type: "model.memory", at: 3_000, model: "org/chat", weightsBytes: 400_000_000, kvBytes: 30_000_000, prefixCacheBytes: 5_000_000 },
  { type: "model.unload", at: 4_000, model: "org/chat", reason: "evicted", drainMs: 200, flushed: true, flushMs: 300 },
  { type: "model.load", at: 4_100, model: "org/other", phase: "started" },
  { type: "model.load", at: 4_700, model: "org/other", phase: "finished", ms: 600, weightsBytes: 900_000_000, resumed: false },
  { type: "model.load", at: 5_000, model: "org/broken", phase: "failed", error: "no weights" },
];

export function fakeStorage(root: string): Pick<StorageService, "path"> {
  return { path: key => ({ history: `${root}/metrics/history`, bench: `${root}/metrics/bench` })[key] ?? (() => { throw new Error(`no entry ${key}`); })() };
}

/** Records submissions and lets a test finish or fail the job it made. */
export function fakeJobs(kinds = ["bench-serve"]): JobService & { submissions: JobSubmission[]; records: Map<string, JobRecord>; cancelled: string[] } {
  const records = new Map<string, JobRecord>(), submissions: JobSubmission[] = [], cancelled: string[] = [];
  return {
    submissions, records, cancelled,
    async submit(submission) {
      if (!kinds.includes(submission.kind)) throw new Error(`no runner for job kind ${submission.kind}`);
      submissions.push(submission);
      const record: JobRecord = { id: `job_${records.size + 1}`, kind: submission.kind, status: "running", progress: 0, message: null, outputPath: null, error: null,
        startedAt: "2026-09-29 12:00:00", endedAt: null };
      records.set(record.id, record);
      return record;
    },
    async get(id) { return records.get(id); },
    async list(filter) { return [...records.values()].filter(record => !filter?.kind || record.kind === filter.kind); },
    async cancel(id) { cancelled.push(id); const record = records.get(id); if (record) records.set(id, { ...record, status: "failed", error: "cancelled" }); },
    async *events() { /* unused */ },
  };
}
