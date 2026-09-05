/** Compiled self-exec smoke: no weights, GPU or persistent server. */
import { mkdtempSync, rmSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { JobStore } from "../../src/jobs/db";
import { submitSubprocess, closeSubprocessJobs, isGpuBusy } from "../../src/jobs/runner";
import { runJobEntry } from "../../src/jobs/job-entry";

if (process.argv[2] === "__job") await runJobEntry(process.argv[3]);
else {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-packaged-jobs-"));
  const store = new JobStore(join(dir, "jobs.db"), join(dir, "logs"));
  try {
    // This binary has no Bun executable or source-path fallback. The production
    // runner must re-exec it with the private job-entry protocol.
    const { jobId } = submitSubprocess(store, "noop", {});
    const deadline = Date.now() + 15_000;
    while ((isGpuBusy() || ["queued", "running"].includes(store.get(jobId)!.status)) && Date.now() < deadline)
      await Bun.sleep(20);
    const row = store.get(jobId)!;
    if (row.status !== "done" || row.progress !== 1) throw new Error(JSON.stringify(row));
    const events = readFileSync(row.log_path, "utf8").trim().split("\n").map((line) => JSON.parse(line).type);
    if (events.join(",") !== "started,stage,stage,done") throw new Error(`unexpected events: ${events}`);

    // Verify the real CLI's private entry as well as the submitter self-exec.
    const cli = process.argv[2];
    if (!cli) throw new Error("expected compiled mlx-bun path");
    const direct = store.create("noop", {});
    const proc = Bun.spawn([cli, "__job", direct.id], { stdout: "pipe", stderr: "pipe",
      env: { ...process.env, MLX_BUN_JOBS_DB: store.dbPath, MLX_BUN_JOBS_DIR: store.logsDir } });
    const timeout = setTimeout(() => proc.kill("SIGKILL"), 15_000);
    try {
      const stderr = await new Response(proc.stderr).text();
      if (await proc.exited !== 0 || store.get(direct.id)?.status !== "done") throw new Error(stderr);
    } finally { clearTimeout(timeout); }
    console.log("[jobs-smoke] OK: packaged self-exec, CLI dispatch and progress persistence");
  } finally {
    await closeSubprocessJobs(store);
    store.close();
    rmSync(dir, { recursive: true, force: true });
  }
}
