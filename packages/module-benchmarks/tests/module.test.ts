// The module as a host loads it: a valid manifest over jobs, storage, modelHost
// and catalog; its routes and its runner mounted from the manifest; the run,
// history, comparison and job routes through the job service and the runner.
import { afterEach, beforeEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelHost } from "@mlx-bun/app-core";
import { checkManifests, loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createStorage } from "@mlx-bun/app-services";
import benchmarks, { createBenchmarksModule, type BenchmarksModuleOptions } from "../src/index";
import { manifest } from "../src/manifest";
import type { EvalHistoryEntry } from "../src/protocol";
import { compactResult } from "../src/evals";
import { fakeCatalog, fakeJobs, fakeModels, fakeResult, fakeSpawn, type Call } from "./support";

let home: string;
beforeEach(() => { home = mkdtempSync(join(tmpdir(), "benchmarks-module-")); });
afterEach(() => { rmSync(home, { recursive: true, force: true }); });

async function host(options: BenchmarksModuleOptions = {}) {
  const jobs = fakeJobs();
  const loaded = await loadModules([createBenchmarksModule({ bun: "/usr/bin/bun", ...options })], { services: { storage: createStorage(() => home), jobs: () => jobs,
    modelHost: () => fakeModels as ModelHost, catalog: () => ({ ...fakeCatalog }) as never } });
  const routes = createModuleRoutes(loaded.routes);
  return { jobs, loaded, send: async (path: string, init?: RequestInit) => (await routes.handle(new Request(`http://x/api/benchmarks${path}`, init)))! };
}
const json = async (response: Response | Promise<Response>) => (await response).json() as Promise<Record<string, any>>;

test("the manifest is valid for a host that implements jobs, storage, modelHost and catalog, and needs nothing else", () => {
  expect(benchmarks.requires).toEqual(["jobs", "storage", "modelHost", "catalog"]);
  const provided = ["jobs", "storage", "modelHost", "catalog"] as const;
  expect(checkManifests([benchmarks], { provided })).toEqual([]);
  expect(checkManifests([benchmarks], { provided: ["jobs", "storage", "modelHost"] })).toEqual(['module "benchmarks": requires "catalog", which this host does not implement']);
  expect(benchmarks.jobs).toEqual([{ kind: "eval-serve", isolation: "task", gpu: "exclusive" }]);
  expect(benchmarks.storage?.map(entry => entry.path)).toEqual(["benchmarks/history", "benchmarks/runs", "benchmarks/plans", "benchmarks/data"]);
  expect(benchmarks.panel).toEqual({ tag: "mlx-benchmarks-panel", entry: "@mlx-bun/module-benchmarks/panel", title: "Benchmarks", path: "/benchmarks" });
});

test("it mounts every declared route under /api/benchmarks and the eval-serve runner", async () => {
  const { loaded } = await host();
  try {
    expect(loaded.routes.map(route => `${route.spec.method} ${route.path}`)).toEqual(manifest.routes.map(route => `${route.method} /api/benchmarks${route.path}`));
    expect([...loaded.jobs.keys()]).toEqual(["eval-serve"]);
  } finally { await loaded.stop(); }
});

test("a run starts through the job service with only what a request may choose, and is listed, read and cancelled by id", async () => {
  const { send, jobs, loaded } = await host();
  try {
    const post = (body: unknown) => send("/runs", { method: "POST", body: typeof body === "string" ? body : JSON.stringify(body) });
    expect((await post("not json")).status).toBe(400);
    expect((await post([])).status).toBe(400);
    for (const bad of [{ tasks: "../x" }, { tasks: 3 }, { model: 7 }, { enableThinking: "yes" }, { model: "org/none" }]) expect((await post(bad)).status).toBe(400);
    expect((await json(post({ model: "org/none" }))).error.message).toContain('no local model matches "org/none"');
    expect(jobs.submissions).toEqual([]);

    const started = await post({ tasks: ["gsm8k-50", "mmlu"], model: "org/other", enableThinking: true, plan: "/etc/passwd", data: "/etc", command: ["rm"] });
    expect(started.status).toBe(202);
    const job = await started.json() as { id: string; status: string };
    // A plan, a data directory or a command from a request never reach the job.
    expect(jobs.submissions).toEqual([{ kind: "eval-serve", config: { tasks: "gsm8k-50,mmlu", model: "org/other", enableThinking: true } }]);
    expect(job.status).toBe("running");
    expect((await post({})).status).toBe(202);
    expect(jobs.submissions[1]).toEqual({ kind: "eval-serve", config: { tasks: "smoketest" } });

    expect((await json(send("/jobs"))).jobs).toHaveLength(2);
    expect((await send(`/jobs/${job.id}`)).status).toBe(200);
    expect((await send("/jobs/job_nope")).status).toBe(404);
    expect((await send(`/jobs/${job.id}`, { method: "DELETE" })).status).toBe(200);
    expect(jobs.cancelled).toEqual([job.id]);
    // Another module's job is not this one's.
    jobs.records.set("job_x", { ...jobs.records.get(job.id)!, id: "job_x", kind: "bench-serve" });
    expect((await send("/jobs/job_x")).status).toBe(404);
    expect((await send("/jobs/job_x", { method: "DELETE" })).status).toBe(404);
  } finally { await loaded.stop(); }
});

function seed(id: string, accuracy: number): EvalHistoryEntry {
  const directory = join(home, "benchmarks/runs", id);
  mkdirSync(directory, { recursive: true });
  writeFileSync(join(directory, "result.json"), "{}");
  const entry = compactResult(fakeResult({ startedAt: id === "a" ? "2026-09-28T12:00:00.000Z" : "2026-09-29T12:00:00.000Z", tasks: [{ task: "gsm8k-50", status: "complete", score: { accuracy, nCorrect: accuracy * 50, nTotal: 50 }, timing: { wallMs: 1 } }] }),
    { id, exitCode: 0, problems: [], runDirectory: directory, startedAt: "", finishedAt: null, durationMs: 1 });
  mkdirSync(join(home, "benchmarks/history"), { recursive: true });
  writeFileSync(join(home, "benchmarks/history", `${id}.json`), JSON.stringify(entry));
  return entry;
}

test("history lists finished runs, a run is read by id, and two are compared through the runner", async () => {
  const calls: Call[] = [];
  const { send, loaded } = await host({ spawn: fakeSpawn(() => ({ stdout: "# report\n" }), calls), root: home, script: join(home, "eval-serve.ts") });
  try {
    writeFileSync(join(home, "eval-serve.ts"), "//");
    expect((await json(send("/runs"))).runs).toEqual([]);
    seed("a", 0.4); seed("b", 0.5);
    expect((await json(send("/runs"))).runs.map((run: EvalHistoryEntry) => run.id)).toEqual(["b", "a"]);
    expect((await json(send("/runs?limit=1"))).runs).toHaveLength(1);
    expect((await json(send("/runs/a"))).tasks[0]).toMatchObject({ task: "gsm8k-50", accuracy: 0.4 });
    expect((await send("/runs/nothing")).status).toBe(404);

    expect((await send("/compare?base=a")).status).toBe(400);
    expect((await send("/compare?base=a&candidate=nothing")).status).toBe(404);
    const compared = await json(send("/compare?base=a&candidate=b"));
    expect(compared).toMatchObject({ base: "a", candidate: "b", comparable: true, markdown: "# report\n", tasks: [{ task: "gsm8k-50", base: 0.4, candidate: 0.5 }] });
    expect(calls[0]!.argv.slice(2)).toEqual(["compare", join(home, "benchmarks/runs/a/result.json"), join(home, "benchmarks/runs/b/result.json")]);
  } finally { await loaded.stop(); }
});

test("the task list is the runner's own; without a checkout it answers 503 and says why", async () => {
  const withRunner = await host({ spawn: fakeSpawn(() => ({ stdout: JSON.stringify({ tasks: [{ id: "mmlu", component: "MMLU", sets: ["capability", "all"], needsVerifier: false,
    datasets: [{ name: "mmlu_optiq_frozen", rows: 969, sha256: "x", source: "s", present: true }] }] }) }), []), root: home, script: join(home, "eval-serve.ts") });
  try {
    writeFileSync(join(home, "eval-serve.ts"), "//");
    const body = await json(withRunner.send("/tasks"));
    expect(body.dataDirectory).toBe(join(home, "benchmarks/data"));
    expect(body.tasks[0]).toMatchObject({ id: "mmlu", datasets: [{ name: "mmlu_optiq_frozen", present: true }] });
  } finally { await withRunner.loaded.stop(); }
  const without = await host({ script: join(home, "missing/eval-serve.ts") });
  try {
    const response = await without.send("/tasks");
    expect(response.status).toBe(503);
    expect(((await response.json()) as { error: { message: string } }).error.message).toContain("needs a source checkout");
  } finally { await without.loaded.stop(); }
});
