// The datasets module on this app's job host and store: the job rows, logs and
// shutdown order of a real in-process task. The module's own behavior (routes,
// templates, generators, the verifier) is tested in packages/module-datasets.
import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import type { JobRunner } from "@mlx-bun/app-core";
import { loadModules } from "@mlx-bun/app-host";
import { createModuleRoutes, createStorage } from "@mlx-bun/app-services";
import { createDatasetsModule, createPythonVerifier, type DatasetsModuleOptions, type SpawnDocker } from "@mlx-bun/module-datasets";
import { JobStore } from "../../src/jobs/db";
import { createJobHost } from "../../src/jobs/host";
import { createJobService } from "../../src/jobs/service";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const fetcher = (fn: (input: string | URL | Request, init?: RequestInit) => Promise<Response>) => fn as typeof fetch;
const wait = async (check: () => boolean) => { for (let i = 0; !check(); i++) {
  if (i > 100) throw new Error("condition did not settle"); await Bun.sleep(5);
} };

/** A served model whose `generate` is `answer`: what the model host lends the module. */
const modelHost = (answer: typeof fetch) => ({
  async defaultFor() { return "served"; },
  async acquire() { return { model: {}, loadMs: 0, release() {}, operations: { generate: (request: Request) => answer(request) } }; },
}) as never;

/** The module over the app's real job host and store, with storage under a temporary root. */
async function setup(options: DatasetsModuleOptions = {}, answer: typeof fetch = fetcher(async () => { throw new Error("no model request expected"); })) {
  const root = mkdtempSync(join(tmpdir(), "mlx-dataset-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  let leases = 0;
  const host = createJobHost({ createStore: () => store, entry: "unused", acquire: async () => {
    leases++; throw new Error("dataset must not acquire a GPU lease");
  } });
  const jobs = createJobService(host);
  const loaded = await loadModules([createDatasetsModule(options)], { services: { jobs: () => jobs, storage: createStorage(() => root), modelHost: () => modelHost(answer) } });
  jobs.serve(loaded.jobs);
  const routes = createModuleRoutes(loaded.routes);
  const submit = async (body: unknown) => (await routes.handle(new Request("http://local/api/dataset/submit", { method: "POST", body: JSON.stringify(body) })))!.json();
  return { root, store, host, jobs, loaded, submit, leases: () => leases };
}
const IMAGE = `python@sha256:${"0".repeat(64)}`;
const fence = (code: string) => "```python\n" + code + "\n```";

test("dataset HTTP submission writes the existing split through an in-process job row without a GPU lease", async () => {
  const { root, store, host, loaded, submit, leases } = await setup();
  try {
    const result = await submit({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: hello\nA: world" } });
    await wait(() => store.get(result.job_id)?.status === "done");
    expect(result.ok).toBe(true);
    expect(result.output_dir.startsWith(join(root, "datasets"))).toBe(true);
    const row = store.get(result.job_id)!;
    expect(row.kind).toBe("dataset");
    expect(JSON.parse(row.config_json)).toEqual({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: hello\nA: world" }, output_dir: result.output_dir, model_name: "local" });
    expect(row.output_path).toBe(result.output_dir);
    const train = readFileSync(join(result.output_dir, "train.jsonl"), "utf8");
    expect(JSON.parse(train)).toEqual({ messages: [{ role: "user", content: "hello" }, { role: "assistant", content: "world" }] });
    expect(leases()).toBe(0);
    expect(readFileSync(row.log_path, "utf8")).toContain('"type":"done"');
  } finally { await loaded.stop(); await host.close(); }
});

test("the jobs service lists, reads and streams module jobs, and rejects kinds and isolations it does not run", async () => {
  const { host, loaded, jobs, submit, store } = await setup();
  try {
    const result = await submit({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: a\nA: b" } });
    const events: string[] = [];
    for await (const event of jobs.events(result.job_id)) events.push(event.type);
    expect(events[0]).toBe("started");
    expect(events.at(-1)).toBe("done");
    expect(await jobs.get(result.job_id)).toMatchObject({ id: result.job_id, kind: "dataset", status: "done", progress: 1, outputPath: result.output_dir, error: null });
    expect((await jobs.list({ kind: "dataset", status: "done" })).map(job => job.id)).toEqual([result.job_id]);
    expect(await jobs.list({ status: "failed" })).toEqual([]);
    await expect(jobs.submit({ kind: "unknown", config: {} })).rejects.toThrow('no installed module runs job kind "unknown"');
    jobs.serve(new Map([["process.kind", { spec: { kind: "process.kind", isolation: "process", gpu: "none" }, runner: (async () => {}) as JobRunner }]]));
    await expect(jobs.submit({ kind: "process.kind", config: {} })).rejects.toThrow("runs as a process");
    expect(store.recent(10).map(row => row.kind)).toEqual(["dataset"]);
  } finally { await loaded.stop(); await host.close(); }
});

test("cancelling a running task job ends it failed and stops its runner", async () => {
  const { host, loaded, jobs, store } = await setup();
  try {
    let stopped: unknown;
    jobs.serve(new Map([["wait", { spec: { kind: "wait", isolation: "task", gpu: "none" }, runner: ((_emit, _config, signal) =>
      new Promise((_, reject) => signal.addEventListener("abort", () => { stopped = signal.reason; reject(signal.reason); }, { once: true }))) as JobRunner }]]));
    const job = await jobs.submit({ kind: "wait", config: {} });
    await wait(() => store.get(job.id)?.status === "running");
    await jobs.cancel(job.id);
    await wait(() => store.get(job.id)?.status === "failed");
    expect(String(stopped)).toContain("job cancelled");
    expect(store.get(job.id)!.error).toBe("Error: job cancelled");
    await jobs.cancel(job.id); await jobs.cancel("job_unknown");
  } finally { await loaded.stop(); await host.close(); }
});

test("shutdown during verification kills the docker CLI and removes the container before closing job storage", async () => {
  const events: string[] = [];
  const spawn: SpawnDocker = args => {
    const command = args[0]!, hang = command === "start";
    events.push(`spawn ${command}`);
    let finish!: (code: number | null) => void;
    const exited = new Promise<number | null>(resolve => { finish = resolve; });
    const controllers: ReadableStreamDefaultController<Uint8Array>[] = [];
    const stream = () => new ReadableStream<Uint8Array>({ start(controller) { controllers.push(controller); if (!hang) controller.close(); } });
    if (!hang) finish(0);
    return { stdout: stream(), stderr: stream(), exited,
      kill() { events.push(`kill ${command}`); for (const controller of controllers) controller.close(); finish(null); } };
  };
  const { root, host, store, loaded, submit } = await setup({ verifyPython: createPythonVerifier({ image: IMAGE, spawn }) },
    fetcher(async () => Response.json({ choices: [{ message: { content: fence("while True:\n    pass") } }] })));
  const close = store.close.bind(store);
  store.close = () => { events.push("store closed"); close(); };
  const { job_id: jobId, output_dir: output } = await submit({ template_id: "verified_code", inputs: { specs: "loops" } });
  await wait(() => events.includes("spawn start"));
  await loaded.stop();
  await host.close();
  expect(events).toEqual(["spawn ps", "spawn create", "spawn start", "kill start", "spawn rm", "store closed"]);
  expect(existsSync(join(output, "train.jsonl"))).toBe(false);
  const reopened = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  try { expect(reopened.get(jobId)?.status).toBe("failed"); } finally { reopened.close(); }
});

test("shutdown aborts an active model request and joins task cleanup before closing SQLite", async () => {
  let entered = false, settled = false, closed = false;
  const { root, host, store, loaded, submit } = await setup({}, fetcher(async (input) => {
    const signal = (input as Request).signal;
    entered = true;
    try { await new Promise<void>((_, reject) => signal.addEventListener("abort", () => reject(signal.reason), { once: true })); }
    finally { await Bun.sleep(5); expect(closed).toBe(false); settled = true; }
    return Response.json({});
  }));
  const close = store.close.bind(store);
  store.close = () => { expect(settled).toBe(true); closed = true; close(); };
  const { job_id: jobId } = await submit({ template_id: "style_transfer", inputs: { reference_samples: "ref", raw_text: "text" } });
  await wait(() => entered);
  await loaded.stop();
  await host.close();
  expect(closed).toBe(true);
  const reopened = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  try { expect(reopened.get(jobId)?.status).toBe("failed"); } finally { reopened.close(); }
});

test("shutdown joins the current code-completion file read without reading more files or writing a dataset", async () => {
  const { root, host, store, loaded, submit } = await setup();
  const source = mkdtempSync(join(tmpdir(), "mlx-dataset-src-")); roots.push(source);
  writeFileSync(join(source, "a.py"), "def first():\n    return 'some useful training content'\n");
  writeFileSync(join(source, "b.py"), "def second():\n    return 'more useful training content'\n");
  const originalFile = Bun.file;
  let releaseRead!: () => void;
  const readGate = new Promise<void>(resolve => { releaseRead = resolve; });
  let reads = 0, readSettled = false, closed = false;
  const originalClose = store.close.bind(store);
  store.close = () => { expect(readSettled).toBe(true); closed = true; originalClose(); };
  const file = spyOn(Bun, "file").mockImplementation(((path: string) => {
    if (path === join(source, "a.py") || path === join(source, "b.py")) return {
      async text() {
        reads++;
        await readGate;
        expect(closed).toBe(false);
        readSettled = true;
        return readFileSync(path, "utf8");
      },
    };
    return originalFile(path);
  }) as typeof Bun.file);
  try {
    const { job_id: jobId, output_dir: output } = await submit({ template_id: "code_completion", inputs: { src_dir: source } });
    await wait(() => reads === 1);
    await loaded.stop();
    const closing = host.close();
    expect(closed).toBe(false);
    releaseRead();
    await closing;
    expect(reads).toBe(1);
    expect(closed).toBe(true);
    expect(existsSync(join(output, "train.jsonl"))).toBe(false);
    expect(existsSync(join(output, "valid.jsonl"))).toBe(false);
    const reopened = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
    try { expect(reopened.get(jobId)?.status).toBe("failed"); } finally { reopened.close(); }
  } finally {
    releaseRead();
    try { await host.close(); } finally { file.mockRestore(); }
  }
});
