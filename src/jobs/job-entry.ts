// Child-process job entry: `bun job-entry.ts <jobId>`.
//
// Spawned by submitSubprocess so MLX/GPU state lives in its own address space
// and an uncatchable crash (segfault / process.exit) dies here without taking
// the server down. Port of optiq lab jobs.py `_job_main` — opens its OWN
// JobStore (a SQLite connection MUST NOT cross the process boundary), resolves
// the runner, runs it with a log-appending emit, sets terminal status, and
// exits 0 (done) / 1 (failed).

import { JobStore } from "./db";
import { getRunner, makeEmit } from "./runner";
import type { JobRunner } from "./types";

/** kind → module to dynamically import so it registers its runner. Real job
 *  kinds are built by parallel efforts; importing the module is expected to
 *  call `registerRunner(kind, ...)` at top level. Missing module ⇒ the job
 *  fails cleanly (see resolveRunner). */
const KIND_MODULES: Record<string, string> = {
  quantize: "../quantize/job.ts",
  finetune: "../train/job.ts",
};

/** Resolve a runner for `kind`. Test kinds (noop/crash) are pre-registered in
 *  runner.ts. Real kinds are lazily imported; a missing module is a clean
 *  failure, not a crash. */
async function resolveRunner(kind: string): Promise<JobRunner> {
  const existing = getRunner(kind);
  if (existing) return existing;

  const modPath = KIND_MODULES[kind];
  if (modPath) {
    try {
      await import(modPath);
    } catch (e) {
      throw new Error(
        `kind "${kind}": failed to load runner module ${modPath} ` +
          `(${e instanceof Error ? e.message : String(e)})`,
      );
    }
    const loaded = getRunner(kind);
    if (loaded) return loaded;
    throw new Error(`kind "${kind}": module ${modPath} did not register a runner`);
  }
  throw new Error(`no runner registered for kind "${kind}"`);
}

function nowIso(): string {
  return new Date().toISOString().replace("T", " ").slice(0, 19);
}

async function main(): Promise<void> {
  const jobId = process.argv[2];
  if (!jobId) {
    console.error("usage: bun job-entry.ts <jobId>");
    process.exit(2);
  }

  // Own fresh connection — overrides come from env so a spawned child finds
  // the same DB/logs the parent used (tests set these to a tmp dir).
  const store = new JobStore(
    process.env.MLX_BUN_JOBS_DB || undefined,
    process.env.MLX_BUN_JOBS_DIR || undefined,
  );

  const row = store.get(jobId);
  if (!row) {
    console.error(`job ${jobId} not found`);
    store.close();
    process.exit(2);
  }

  const emit = makeEmit(store, jobId, row.log_path);
  store.setStatus(jobId, "running");
  emit({ type: "started", ts: Date.now() });

  let config: Record<string, unknown>;
  try {
    config = JSON.parse(row.config_json) as Record<string, unknown>;
  } catch (e) {
    const error = `bad config_json: ${e instanceof Error ? e.message : String(e)}`;
    store.setStatus(jobId, "failed", { error, endedAt: nowIso() });
    emit({ type: "failed", error, ts: Date.now() });
    store.close();
    process.exit(1);
  }

  try {
    const runner = await resolveRunner(row.kind);
    const result = await runner(emit, config);
    const out = result?.outputPath;
    if (out) store.setOutputPath(jobId, out);
    store.setProgress(jobId, 1);
    store.setStatus(jobId, "done", { endedAt: nowIso() });
    emit({ type: "done", ts: Date.now(), output_dir: out ?? row.output_path ?? undefined });
    store.close();
    process.exit(0);
  } catch (e) {
    const error = e instanceof Error ? `${e.name}: ${e.message}` : String(e);
    store.setStatus(jobId, "failed", { error, endedAt: nowIso() });
    emit({ type: "failed", error, ts: Date.now() });
    store.close();
    process.exit(1);
  }
}

main();
