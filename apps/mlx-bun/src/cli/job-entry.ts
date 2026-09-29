import { jobError, JobStore, nowIso } from "../jobs/db";
import { makeEmit } from "../jobs/events";
import { runtimeFlag, runtimeValue } from "@mlx-bun/inference/runtime/config";
import type { JobRunner } from "../jobs/protocol";

/** A job's runner and what to release after it: this app's own kinds, else the installed module that registered the kind. */
async function resolveRunner(kind: string): Promise<{ runner: JobRunner; release?(): Promise<void> }> {
  if (kind === "finetune") return { runner: (await import("../finetune/job")).createFinetuneRunner() };
  const [{ installedModules }, { loadModules }, { createHostServices }] = await Promise.all([
    import("../modules"), import("@mlx-bun/app-host"), import("@mlx-bun/app-services") ]);
  const [owner] = await installedModules(manifest => manifest.jobs?.some(job => job.kind === kind) ?? false);
  if (!owner) throw new Error(`no runner registered for kind "${kind}"`);
  // The child activates only the module that owns the kind, over the services a job needs; it submits no jobs of its own.
  const host = createHostServices({ log() {} });
  const loaded = await loadModules([owner], { services: { catalog: host.bindings.catalog, storage: host.bindings.storage,
    jobs: () => ({ submit: () => Promise.reject(new Error("a job child submits no jobs")), get: async () => undefined, list: async () => [],
      cancel: async () => {}, events: () => (async function* () {})() }) } });
  return { runner: loaded.jobs.get(kind)!.runner as unknown as JobRunner, release: async () => { try { await loaded.stop(); } finally { await host.whisper.close(); } } };
}

/** The job host spawns this child as the leader of its own process group
 * (jobs/runner.ts), which the terminal's signals no longer reach, and holds a
 * pipe on its stdin for the child's life. The pipe's end means the host is
 * gone: the child then stops itself and everything it started, as the host's
 * own shutdown would have (SIGTERM to the group). */
export function stopWithParent(stdin: ReadableStream<Uint8Array>): void {
  void (async () => {
    const reader = stdin.getReader();
    try { while (!(await reader.read()).done) { /* nothing is sent on this pipe */ } }
    catch { /* a broken pipe is the host's end too */ }
    try { process.kill(-process.pid, "SIGTERM"); }
    catch { process.kill(process.pid, "SIGTERM"); } // not a group leader
  })();
}

export async function runJobEntry(jobId = process.argv[2]): Promise<number> {
  if (!jobId) {
    console.error("usage: bun job-entry.ts <jobId>");
    return 2;
  }

  if (runtimeFlag("MLX_BUN_JOB_PARENT_PIPE", false)) stopWithParent(Bun.stdin.stream());

  // Own fresh connection — overrides come from env so a spawned child finds
  // the same DB/logs the parent used (tests set these to a tmp dir).
  const store = new JobStore(
    runtimeValue("MLX_BUN_JOBS_DB") || undefined,
    runtimeValue("MLX_BUN_JOBS_DIR") || undefined,
  );

  const row = store.get(jobId);
  if (!row) {
    console.error(`job ${jobId} not found`);
    store.close();
    return 2;
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
    return 1;
  }

  let release: (() => Promise<void>) | undefined;
  try {
    const resolved = await resolveRunner(row.kind);
    release = resolved.release;
    const result = await resolved.runner(emit, config);
    const out = result?.outputPath;
    if (out) store.setOutputPath(jobId, out);
    store.setProgress(jobId, 1);
    store.setStatus(jobId, "done", { endedAt: nowIso() });
    emit({ type: "done", ts: Date.now(), output_dir: out ?? row.output_path ?? undefined });
    store.close();
    await release?.().catch(() => {});
    return 0;
  } catch (e) {
    const error = jobError(e);
    store.setStatus(jobId, "failed", { error, endedAt: nowIso() });
    emit({ type: "failed", error, ts: Date.now() });
    store.close();
    await release?.().catch(() => {});
    return 1;
  }
}

// The process owner exits after durable terminal publication and store cleanup;
// producer-owned lingering handles must not retain the parent execution lease.
if (import.meta.main) process.exit(await runJobEntry());
