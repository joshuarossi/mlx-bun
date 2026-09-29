// The job service's execution lease: a runner that declared `gpu: "exclusive"`
// runs only while it holds the engine's lease, releases it however it ends, and
// one that declared none never takes it. (Task runs, rows and cancel are covered
// by the datasets lifecycle tests.)
import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { JobRunnerSpec } from "@mlx-bun/app-core";
import { JobStore } from "../../src/jobs/db";
import { createJobHost } from "../../src/jobs/host";
import { createJobService } from "../../src/jobs/service";

const roots: string[] = [], hosts: ReturnType<typeof createJobHost>[] = [];
afterEach(async () => { for (const host of hosts.splice(0)) await host.close(); for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

function setup(gpu: JobRunnerSpec["gpu"], run: () => Promise<void>) {
  const root = mkdtempSync(join(tmpdir(), "mlx-job-service-")); roots.push(root);
  const host = createJobHost({ entry: "unused", acquire: async () => ({ dispose() {} }), createStore: () => new JobStore(join(root, "jobs.sqlite"), join(root, "logs")) });
  hosts.push(host);
  const leases: string[] = [];
  const service = createJobService(host, { acquire: async signal => { signal.throwIfAborted(); leases.push("acquired"); return { dispose() { leases.push("released"); } }; } });
  service.serve(new Map([["demo.run", { spec: { kind: "demo.run", isolation: "task", gpu }, runner: async () => { leases.push("running"); await run(); } }]]));
  return { service, leases };
}
const ended = async (service: ReturnType<typeof createJobService>, id: string) => {
  for (let i = 0; i < 400; i++) { const row = await service.get(id); if (row && row.status !== "running" && row.status !== "queued") return row; await Bun.sleep(5); }
  throw new Error("timed out");
};

test("an exclusive runner runs between acquiring and releasing the lease, and a failing one releases it too", async () => {
  const gate = Promise.withResolvers<void>();
  const held = setup("exclusive", () => gate.promise);
  const { id } = await held.service.submit({ kind: "demo.run", config: {} });
  for (let i = 0; i < 200 && !held.leases.includes("running"); i++) await Bun.sleep(5);
  expect(held.leases).toEqual(["acquired", "running"]);
  gate.resolve();
  expect((await ended(held.service, id)).status).toBe("done");
  expect(held.leases).toEqual(["acquired", "running", "released"]);

  const failing = setup("exclusive", async () => { throw new Error("boom"); });
  const failed = await ended(failing.service, (await failing.service.submit({ kind: "demo.run", config: {} })).id);
  expect(failed).toMatchObject({ status: "failed" });
  expect(failing.leases).toEqual(["acquired", "running", "released"]);
});

test("a cancel while waiting for the lease stops the job without running it", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-job-service-")); roots.push(root);
  const host = createJobHost({ entry: "unused", acquire: async () => ({ dispose() {} }), createStore: () => new JobStore(join(root, "jobs.sqlite"), join(root, "logs")) });
  hosts.push(host);
  let ran = false;
  const service = createJobService(host, { acquire: signal => new Promise((_, reject) => signal.addEventListener("abort", () => reject(signal.reason))) });
  service.serve(new Map([["demo.run", { spec: { kind: "demo.run", isolation: "task", gpu: "exclusive" }, runner: async () => { ran = true; } }]]));
  const { id } = await service.submit({ kind: "demo.run", config: {} });
  await Bun.sleep(20);
  await service.cancel(id);
  expect(await ended(service, id)).toMatchObject({ status: "failed", error: expect.stringContaining("cancelled") });
  expect(ran).toBe(false);
});

test("a runner that declared no GPU use never takes the lease", async () => {
  const shared = setup("none", async () => {});
  const row = await ended(shared.service, (await shared.service.submit({ kind: "demo.run", config: {} })).id);
  expect(row.status).toBe("done");
  expect(shared.leases).toEqual(["running"]);
});
