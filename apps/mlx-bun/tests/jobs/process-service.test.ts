// The `jobs` core service's `process` runners on this app's job host: a real
// child process per job, the host's execution lease around it, the submitter's
// scratch directory as the child's TMPDIR, and cancellation that waits until
// the child's process group is gone. (Task runners and their lease are covered
// by service.test.ts and the datasets lifecycle tests.)
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import type { JobRunner } from "@mlx-bun/app-core";
import { JobStore } from "../../src/jobs/db";
import { createJobHost } from "../../src/jobs/host";
import { createJobService } from "../../src/jobs/service";

const dbModule = resolve(import.meta.dir, "../../src/jobs/db.ts");
const roots: string[] = [], hosts: ReturnType<typeof createJobHost>[] = [];
afterEach(async () => {
  for (const host of hosts.splice(0)) await host.close().catch(() => {});
  for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true });
});
const alive = (pid: number) => { try { process.kill(pid, 0); return true; } catch { return false; } };
async function until(check: () => boolean, ms = 8_000) {
  const end = Date.now() + ms;
  while (!check()) { if (Date.now() > end) throw new Error("timed out"); await Bun.sleep(10); }
}
const noop: JobRunner = async () => {};

/** A service over a real host whose children run `child` (a script body given the job id). */
function setup(child: string) {
  const root = mkdtempSync(join(tmpdir(), "mlx-job-service-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  const entry = join(root, "child.ts");
  // The child opens the same job store the host handed it, like the real job entry does.
  writeFileSync(entry, `
    const { JobStore } = require(${JSON.stringify(dbModule)});
    const fs = require("node:fs");
    const store = new JobStore(process.env.MLX_BUN_JOBS_DB, process.env.MLX_BUN_JOBS_DIR);
    const row = store.get(process.argv[2]), config = JSON.parse(row.config_json);
    ${child}`);
  const leases: string[] = [];
  const host = createJobHost({ entry, createStore: () => store, graceMs: 200, acquire: async () => {
    leases.push("acquire"); return { dispose() { leases.push("release"); } };
  } });
  hosts.push(host);
  const service = createJobService(host);
  service.serve(new Map([
    ["make", { spec: { kind: "make", isolation: "process" as const, gpu: "exclusive" as const }, runner: noop }],
    ["lite", { spec: { kind: "lite", isolation: "process" as const, gpu: "none" as const }, runner: noop }],
  ]));
  return { root, store, service, leases };
}

test("a process job runs as a child of the host under its lease, with the scratch directory as its TMPDIR and the config it was given", async () => {
  const { root, store, service, leases } = setup(`
    fs.writeFileSync(config.report, JSON.stringify({ tmpdir: process.env.TMPDIR, config: config.value }));
    fs.appendFileSync(row.log_path, JSON.stringify({ type: "stage", stage: "working", message: "half" }) + "\\n");
    store.setOutputPath(row.id, config.report); store.setStatus(row.id, "done", { endedAt: "2026-09-29 00:00:00" }); store.close();`);
  const report = join(root, "report.json"), scratch = join(root, "scratch");
  const job = await service.submit({ kind: "make", config: { report, value: 7 }, outputPath: report, scratchDir: scratch });
  expect(job).toMatchObject({ kind: "make", status: "queued", outputPath: report });
  const seen: string[] = [];
  for await (const event of service.events(job.id)) seen.push(event.type === "stage" ? `stage:${event.message}` : event.type);
  expect(seen).toContain("stage:half");
  expect(JSON.parse(readFileSync(report, "utf8"))).toEqual({ tmpdir: scratch, config: 7 });
  expect(await service.get(job.id)).toMatchObject({ status: "done", outputPath: report });
  await service.cancel(job.id); // the finished job's process group is joined and the lease released
  expect(leases).toEqual(["acquire", "release"]);
  expect(store.get(job.id)!.kind).toBe("make");
}, 20_000);

test("cancelling an active process job stops its child, waits until it is gone, releases the lease and records the cancellation", async () => {
  const { root, store, service, leases } = setup(`
    fs.writeFileSync(config.pidFile, String(process.pid));
    process.on("SIGTERM", () => {}); // ignores SIGTERM: the host escalates
    setInterval(() => {}, 1000);`);
  const pidFile = join(root, "pid");
  const job = await service.submit({ kind: "make", config: { pidFile } });
  await until(() => { try { return readFileSync(pidFile, "utf8").length > 0; } catch { return false; } });
  const pid = Number(readFileSync(pidFile, "utf8"));
  expect(alive(pid)).toBe(true);
  await service.cancel(job.id);
  expect(alive(pid)).toBe(false); // resolved only once the process was gone
  expect(leases).toEqual(["acquire", "release"]);
  expect(store.get(job.id)).toMatchObject({ status: "failed", error: "job cancelled" });
  await service.cancel(job.id); await service.cancel("job_unknown"); // nothing left to stop
}, 20_000);

test("a queued process job behind another one's lease is cancelled without ever spawning", async () => {
  const { root, store, service } = setup(`
    fs.writeFileSync(config.pidFile, String(process.pid)); setInterval(() => {}, 1000);`);
  const first = join(root, "first.pid"), second = join(root, "second.pid");
  const running = await service.submit({ kind: "make", config: { pidFile: first } });
  const queued = await service.submit({ kind: "make", config: { pidFile: second } });
  await until(() => { try { return readFileSync(first, "utf8").length > 0; } catch { return false; } });
  expect(store.get(queued.id)!.status).toBe("queued");
  await service.cancel(queued.id);
  expect(store.get(queued.id)).toMatchObject({ status: "failed", error: "job cancelled" });
  await service.cancel(running.id);
  await Bun.sleep(100);
  expect(() => readFileSync(second, "utf8")).toThrow(); // the cancelled job never started
}, 20_000);

test("a process job without the exclusive lease is refused rather than run without it", async () => {
  const { service, store } = setup("store.close();");
  await expect(service.submit({ kind: "lite", config: {} })).rejects.toThrow("only with the exclusive GPU lease");
  expect(store.recent(10)).toEqual([]);
});
