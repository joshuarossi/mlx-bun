// The module as a host loads it: a valid manifest over events, storage and
// jobs; events published to the host's bus reach the snapshot route and the
// stream; the bench job and its routes work through the job service.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { AppEvent } from "@mlx-bun/app-core";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createEventHub, createModuleRoutes, createStorage } from "@mlx-bun/app-services";
import metrics, { createMetricsModule } from "../src/index";
import { manifest } from "../src/manifest";
import type { MetricsSnapshot } from "../src/protocol";
import { fakeJobs, RECORDED } from "./support";

let home: string;
beforeEach(() => { home = mkdtempSync(join(tmpdir(), "metrics-module-")); });
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

const settle = () => new Promise(resolve => setTimeout(resolve, 5));

async function host(options: Parameters<typeof createMetricsModule>[0] = {}) {
  const events = createEventHub(), jobs = fakeJobs();
  const loaded = await loadModules([createMetricsModule(options)], { services: { events: scope => events.scoped(scope), storage: createStorage(() => home), jobs: () => jobs } });
  return { events, jobs, loaded, routes: createModuleRoutes(loaded.routes) };
}

test("the manifest is valid for a host that implements events, storage and jobs, and needs nothing else", () => {
  expect(metrics.requires).toEqual(["events", "storage", "jobs"]);
  expect(checkManifests([metrics], { provided: ["events", "storage", "jobs"] })).toEqual([]);
  expect(checkManifests([metrics], { provided: ["events", "storage"] })).toEqual(['module "metrics": requires "jobs", which this host does not implement']);
  expect(metrics.jobs).toEqual([{ kind: "bench-serve", isolation: "task", gpu: "exclusive" }]);
  expect(metrics.storage?.map(entry => entry.path)).toEqual(["metrics/history", "metrics/bench"]);
  expect(metrics.panel).toEqual({ tag: "mlx-metrics-panel", entry: "@mlx-bun/module-metrics/panel", title: "Metrics", path: "/metrics" });
});

test("it mounts every declared route under /api/metrics and the bench-serve runner, and reports its counters", async () => {
  const { loaded } = await host();
  try {
    expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual(manifest.routes.map(route => `${route.method} /api/metrics${route.path}`));
    expect([...loaded.jobs.keys()]).toEqual(["bench-serve"]);
    expect(loaded.status("metrics")).toEqual({ requests: 0, streams: 0 });
  } finally { await loaded.stop(); }
});

test("events published to the bus arrive in the snapshot route, in order and without the publisher waiting", async () => {
  const { events, routes, loaded } = await host();
  try {
    for (const event of RECORDED) events.publish(event);
    const before = await (await routes.handle(new Request("http://x/api/metrics/snapshot")))!.json() as MetricsSnapshot;
    expect(before.requests.finished).toBe(0);
    await settle();
    const snapshot = await (await routes.handle(new Request("http://x/api/metrics/snapshot")))!.json() as MetricsSnapshot;
    expect(snapshot.requests.finished).toBe(3);
    expect(snapshot.models.map(model => model.model)).toEqual(["org/chat", "org/other", "org/broken"]);
    expect(loaded.status("metrics")).toMatchObject({ requests: 3 });
  } finally { await loaded.stop(); }
});

test("events another module publishes, and core events this module does not reduce, leave the snapshot alone", async () => {
  const { events, routes, loaded } = await host();
  try {
    events.publish({ type: "catalog.changed", at: 1 } as AppEvent);
    events.scoped({ moduleId: "transcription" }).publish({ type: "transcription.finished", at: 2 });
    await settle();
    const snapshot = await (await routes.handle(new Request("http://x/api/metrics/snapshot")))!.json() as MetricsSnapshot;
    expect(snapshot.models).toEqual([]);
    expect(snapshot.requests.finished).toBe(0);
  } finally { await loaded.stop(); }
});

test("an open stream ends when the host stops the module", async () => {
  const { routes, loaded } = await host();
  const response = (await routes.handle(new Request("http://x/api/metrics/stream")))!;
  const reader = response.body!.getReader();
  await reader.read();
  await loaded.stop();
  let done = false;
  for (let reads = 0; reads < 5 && !done; reads++) done = (await reader.read()).done;
  expect(done).toBe(true);
});

test("a bench job starts through the job service with the profile or plan named, and is listed, read and cancelled by id", async () => {
  const { routes, jobs, loaded } = await host();
  try {
    mkdirSync(join(home, "metrics/bench/plans"), { recursive: true });
    writeFileSync(join(home, "metrics/bench/plans/quick.json"), JSON.stringify({ profile: "scoped", models: [{ id: "qwen" }], cells: [] }));
    const send = (path: string, init?: RequestInit) => routes.handle(new Request(`http://x/api/metrics${path}`, init))!;
    const profiles = await (await send("/bench/profiles"))!.json() as { profiles: { name: string }[] };
    expect(profiles.profiles.map(profile => profile.name)).toEqual(["quick"]);

    const bad = await send("/bench", { method: "POST", body: JSON.stringify({ profile: "nope" }) });
    expect(bad!.status).toBe(400);
    expect(((await bad!.json()) as { error: { message: string } }).error.message).toContain('no profile "nope"');
    expect((await send("/bench", { method: "POST", body: "not json" }))!.status).toBe(400);
    // A request never names a plan file: an absolute path is not a profile.
    const plan = await send("/bench", { method: "POST", body: JSON.stringify({ plan: join(home, "metrics/bench/plans/quick.json") }) });
    expect(plan!.status).toBe(400);
    expect(((await plan!.json()) as { error: { message: string } }).error.message).toContain("name a profile");
    expect(jobs.submissions).toEqual([]);

    const started = await send("/bench", { method: "POST", body: JSON.stringify({ profile: "quick" }) });
    expect(started!.status).toBe(202);
    const job = await started!.json() as { id: string; status: string };
    expect(jobs.submissions).toEqual([{ kind: "bench-serve", config: { profile: "quick" } }]);
    expect(job.status).toBe("running");
    expect((await (await send("/bench"))!.json() as { jobs: unknown[] }).jobs).toHaveLength(1);
    expect((await send(`/bench/${job.id}`))!.status).toBe(200);
    expect((await send("/bench/job_nope"))!.status).toBe(404);
    expect((await send(`/bench/${job.id}`, { method: "DELETE" }))!.status).toBe(200);
    expect(jobs.cancelled).toEqual([job.id]);
    expect((await send("/history/nothing"))!.status).toBe(404);
    expect(await (await send("/history"))!.json()).toEqual({ runs: [] });
  } finally { await loaded.stop(); }
});
