// Fakes shared by the module's tests: storage, a job service, the served model and
// catalog, and a process that behaves as `eval-serve.ts plan|run|compare` do.
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import type { compactResult } from "../src/evals";
import type { JobRecord, JobService, JobSubmission, ModelCatalog, ModelHost, StorageService } from "@mlx-bun/app-core";

export const STORAGE_KEYS = { history: "benchmarks/history", runs: "benchmarks/runs", plans: "benchmarks/plans", data: "benchmarks/data" } as const;

export function fakeStorage(root: string): Pick<StorageService, "path"> {
  // As the host's: an entry exists once asked for.
  return { path: key => {
    if (!(key in STORAGE_KEYS)) throw new Error(`no entry ${key}`);
    const path = join(root, STORAGE_KEYS[key as keyof typeof STORAGE_KEYS]);
    mkdirSync(path, { recursive: true });
    return path;
  } };
}

/** Records submissions and lets a test finish or fail the job it made. */
export function fakeJobs(kinds = ["eval-serve"]): JobService & { submissions: JobSubmission[]; records: Map<string, JobRecord>; cancelled: string[] } {
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

/** The served model is `org/served`; the catalog knows it and one other by id, and any directory that exists as itself. */
export const CATALOG = new Map([["org/served", "/models/served"], ["org/other", "/models/other"]]);
export const fakeModels: Pick<ModelHost, "defaultFor"> = { async defaultFor(operation) { return operation === "generate" ? "org/served" : undefined; } };
export const fakeCatalog: Pick<ModelCatalog, "find"> = {
  async find(query) {
    const directory = CATALOG.get(query);
    if (!directory) throw new Error(`no local model matches "${query}"`);
    return { id: query, kind: "model", directory, bytes: 1, operations: query === "org/embedder" ? ["embed"] : ["generate"] };
  },
};

/** A result.json as the runner writes it, cut to what the history reads. */
export function fakeResult(overrides: Partial<Parameters<typeof compactResult>[0]> = {}) {
  const result = {
    schema: 1, kind: "capability-eval-result", label: "run", startedAt: "2026-09-29T12:00:00.000Z", finishedAt: "2026-09-29T12:20:00.000Z",
    machine: { chip: "Apple M1 Max", memoryBytes: 34_359_738_368, loadAverage: "1", host: "box", os: "27.0.0", bun: "1.4.2" },
    plan: { path: "/p.json", sha256: "x", value: { enableThinking: false, model: { path: "/models/served", repo: "org/served", revision: "a".repeat(40) } } },
    tasks: [
      { task: "gsm8k-50", status: "complete" as const, datasets: [], settings: {}, score: { accuracy: 0.42, nCorrect: 21, nTotal: 50 }, outcomes: "1".repeat(21) + "0".repeat(29), errors: [], timing: { wallMs: 90_000 } },
      { task: "mmlu", status: "complete" as const, datasets: [], settings: {}, score: { accuracy: 0.5, nCorrect: 485, nTotal: 970 }, outcomes: "", errors: [], timing: { wallMs: 300_000 } },
      { task: "humaneval", status: "skipped" as const, reason: "verifier unavailable: docker not found", datasets: [], settings: {}, score: null, outcomes: "", errors: [], timing: { wallMs: 0 } },
    ],
    capability: { score: 50, components: { MMLU: 50 }, diskGb: 0.3, excluded: ["HumanEval: skipped (verifier unavailable: docker not found)"] },
  };
  return { ...result, ...overrides };
}

export interface FakeRun { code?: number; lines?: string[]; errors?: string[]; result?: unknown; hang?: boolean; stdout?: string }
export interface Call { argv: string[]; signals: string[] }
/** A spawn that records its argv and behaves like the runner's subcommands: `plan` writes `--out`, `run` prints lines and writes result.json into `--out`, others print `stdout`. */
export function fakeSpawn(behave: (subcommand: string) => FakeRun, calls: Call[]) {
  return ((argv: string[]) => {
    const call: Call = { argv, signals: [] };
    calls.push(call);
    const subcommand = argv[2] ?? "", run = behave(subcommand);
    const encode = (text: string) => new ReadableStream<Uint8Array>({ start(controller) { controller.enqueue(new TextEncoder().encode(text)); controller.close(); } });
    const exit = Promise.withResolvers<number>();
    const finish = () => {
      const out = argv[argv.indexOf("--out") + 1];
      if (subcommand === "plan" && out && run.code !== 1) { mkdirSync(dirname(out), { recursive: true }); writeFileSync(out, JSON.stringify({ schema: 1, kind: "capability-eval", tasks: ["gsm8k-50", "mmlu"] })); }
      if (subcommand === "run" && out && run.result) { mkdirSync(out, { recursive: true }); writeFileSync(join(out, "result.json"), JSON.stringify(run.result)); }
      exit.resolve(run.code ?? 0);
    };
    if (run.hang) { /* exits only when killed */ } else queueMicrotask(finish);
    return { stdout: encode(run.stdout ?? (run.lines ?? []).join("\n") + "\n"), stderr: encode((run.errors ?? []).join("\n")), exited: exit.promise, pid: 1,
      kill(signal: string) { call.signals.push(signal); exit.resolve(130); } };
  }) as unknown as typeof Bun.spawn;
}
