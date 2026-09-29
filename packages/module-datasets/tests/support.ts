// Stand-ins for the core services a host implements: a model host whose
// served model answers wire requests through a function, and an in-memory job
// service that runs a module's declared runners as tasks.
import { expect } from "bun:test";
import type { AcquireOptions, JobEvent, JobRecord, JobRunner, JobService, ModelHost, ModelLease, StorageService } from "@mlx-bun/app-core";

/** A model host serving one model whose `generate` is `answer`; `leases` counts acquires without a matching release. */
export function servedBy(answer: (url: string, init: RequestInit) => Promise<Response>, id = "served") {
  const state = { leases: 0, acquired: 0 };
  const models = {
    async defaultFor(operation: string) { return operation === "generate" ? id : undefined; },
    async acquire(requested: string, options?: AcquireOptions): Promise<ModelLease> {
      if (requested !== id) throw new Error(`unexpected model ${requested}`);
      expect(options?.need).toEqual(["generate"]);
      state.leases++; state.acquired++;
      let released = false;
      return { model: { id, role: "primary", state: "ready", operations: ["generate"], bytes: 0, pinned: true, leases: state.leases, lastUsedAt: 0 }, loadMs: 0,
        operations: { generate: async request => answer(request.url, { method: request.method, headers: request.headers, body: await request.text(), signal: request.signal }) },
        release() { if (!released) { released = true; state.leases--; } } };
    },
  // The module leases and never inspects residency; the rest of the contract is the host's.
  } as unknown as ModelHost;
  return { models, state };
}
export const storageAt = (root: string): StorageService => ({ path: key => { if (key !== "datasets") throw new Error(`undeclared entry ${key}`); return root; } });

interface Row { record: JobRecord; events: JobEvent[]; done: Promise<void> }

/** Runs submitted jobs as tasks and keeps their rows and events; `close()` aborts and joins them, as a host's shutdown does. */
export function memoryJobs(runners: () => ReadonlyMap<string, JobRunner>): JobService & { rows: Map<string, Row>; close(): Promise<void> } {
  const rows = new Map<string, Row>(), shutdown = new AbortController();
  let next = 0;
  return {
    rows,
    async submit(submission) {
      const runner = runners().get(submission.kind);
      if (!runner) throw new Error(`no runner for ${submission.kind}`);
      const record: { -readonly [K in keyof JobRecord]: JobRecord[K] } = { id: `job-${++next}`, kind: submission.kind, status: "running", progress: 0, message: null,
        outputPath: submission.outputPath ?? null, error: null, startedAt: "", endedAt: null };
      const row: Row = { record, events: [], done: Promise.resolve() };
      row.done = (async () => {
        try {
          const result = await runner(event => { row.events.push(event); }, submission.config, shutdown.signal);
          if (result?.outputPath) record.outputPath = result.outputPath;
          record.status = "done";
        } catch (error) { record.status = "failed"; record.error = String(error); }
      })();
      rows.set(record.id, row);
      return { ...record };
    },
    async get(id) { return rows.get(id)?.record; },
    async list() { return [...rows.values()].map(row => row.record); },
    async cancel() {},
    events() { throw new Error("unused"); },
    async close() { shutdown.abort(new Error("shutting down")); await Promise.all([...rows.values()].map(row => row.done)); },
  };
}
