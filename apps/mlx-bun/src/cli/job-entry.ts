import { jobError, JobStore, nowIso } from "../jobs/db";
import { makeEmit } from "../jobs/events";
import { runtimeFlag, runtimeValue } from "@mlx-bun/inference/runtime/config";
import type { JobRunner } from "../jobs/protocol";

async function resolveRunner(kind: string): Promise<JobRunner> {
  if (kind === "quantize") return (await import("../quantize/job")).createQuantizeRunner();
  if (kind === "finetune") return (await import("../finetune/job")).createFinetuneRunner();
  throw new Error(`no runner registered for kind "${kind}"`);
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

  try {
    const runner = await resolveRunner(row.kind);
    const result = await runner(emit, config);
    const out = result?.outputPath;
    if (out) store.setOutputPath(jobId, out);
    store.setProgress(jobId, 1);
    store.setStatus(jobId, "done", { endedAt: nowIso() });
    emit({ type: "done", ts: Date.now(), output_dir: out ?? row.output_path ?? undefined });
    store.close();
    return 0;
  } catch (e) {
    const error = jobError(e);
    store.setStatus(jobId, "failed", { error, endedAt: nowIso() });
    emit({ type: "failed", error, ts: Date.now() });
    store.close();
    return 1;
  }
}

// The process owner exits after durable terminal publication and store cleanup;
// producer-owned lingering handles must not retain the parent execution lease.
if (import.meta.main) process.exit(await runJobEntry());
