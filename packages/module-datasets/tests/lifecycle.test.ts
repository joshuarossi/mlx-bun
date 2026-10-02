import { afterEach, expect, spyOn, test } from "bun:test";
import { existsSync, mkdtempSync, rmSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import type { JobRunner, ModelHost } from "@mlx-bun/app-core";
import { loadModules } from "@mlx-bun/app-host";
import { createDatasetsModule, generate, makeLlmClient, createPythonVerifier, type DatasetsModuleOptions, type SpawnDocker, type VerifyPython } from "../src";
import { genCodeCompletion, genHfDatasetImport } from "../src/generators";
import { memoryJobs, servedBy, storageAt } from "./support";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
const fetcher = (fn: (input: string | URL | Request, init?: RequestInit) => Promise<Response>) => fn as typeof fetch;
const wait = async (check: () => boolean) => { for (let i = 0; !check(); i++) {
  if (i > 100) throw new Error("condition did not settle"); await Bun.sleep(5);
} };
const noModel = servedBy(async () => { throw new Error("no model request expected"); });

/** The module activated over stand-in services: routes by shipped path, jobs in memory, storage in a temporary directory. */
async function setup(options: DatasetsModuleOptions = {}, served = noModel) {
  const root = mkdtempSync(join(tmpdir(), "mlx-dataset-")); roots.push(root);
  const jobs = memoryJobs(() => new Map([...loaded.jobs].map(([kind, job]) => [kind, job.runner as JobRunner])));
  const loaded = await loadModules([createDatasetsModule(options)], { services: { jobs: () => jobs, storage: () => storageAt(join(root, "datasets")), modelHost: () => served.models } });
  const call = async (method: string, path: string, body?: unknown) => {
    const route = loaded.routes.find(item => item.spec.method === method && item.path === path)!;
    return route.handler(new Request(`http://local${path}`, { method, ...(body === undefined ? {} : { body: JSON.stringify(body) }) }));
  };
  const submit = async (body: unknown) => (await call("POST", "/api/dataset/submit", body)).json();
  const close = async () => { await jobs.close(); await loaded.stop(); };
  return { root, jobs, loaded, call, submit, close, served };
}

test("dataset HTTP submission writes the existing split through a task job that leases no model for a non-LLM template", async () => {
  const { jobs, submit, close, served } = await setup();
  try {
    const result = await submit({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: hello\nA: world" } });
    await wait(() => jobs.rows.get(result.job_id)?.record.status === "done");
    expect(result.ok).toBe(true);
    const row = jobs.rows.get(result.job_id)!;
    expect(row.record.kind).toBe("dataset");
    const train = readFileSync(join(result.output_dir, "train.jsonl"), "utf8");
    expect(JSON.parse(train)).toEqual({ messages: [{ role: "user", content: "hello" }, { role: "assistant", content: "world" }] });
    expect(readFileSync(join(result.output_dir, "valid.jsonl"), "utf8")).toBe(train);
    expect(served.state.acquired).toBe(0);
    expect(row.events.map(event => event.type)).toContain("stage");
  } finally { await close(); }
});

test("templates list all thirteen templates; submission refuses only unknown ids", async () => {
  const { call, jobs, close } = await setup();
  try {
    const templates = await (await call("GET", "/api/dataset/templates")).json();
    expect(templates.templates).toHaveLength(13);
    expect(templates.templates.find((t: any) => t.id === "verified_code").description).toContain("isolated Docker container");
    for (const [id, status] of [["verified_code", 200], ["constructor", 400], ["missing", 400]] as const)
      expect((await call("POST", "/api/dataset/submit", { template_id: id })).status).toBe(status);
    expect([...jobs.rows.values()].map(row => row.record.kind)).toEqual(["dataset"]);
    const root = mkdtempSync(join(tmpdir(), "mlx-dataset-")); roots.push(root);
    await expect(generate("verified_code", { specs: "spec" }, join(root, "out"), () => {})).rejects.toThrow("requires a served model");
  } finally { await close(); }
});

const IMAGE = `python@sha256:${"0".repeat(64)}`;
const fence = (code: string) => "```python\n" + code + "\n```";
/** A served model answering each verified_code prompt with the reply its SPEC names. */
const chatWith = (replies: Record<string, string>) => servedBy(async (_url, init) => {
  const spec = JSON.parse(init.body as string).messages[0].content.match(/SPEC:\n(.*)\n/)[1];
  return Response.json({ choices: [{ message: { content: replies[spec] } }] });
});

test("verified_code runs over HTTP as a task job and keeps failed and unverifiable pairs, with one model lease released at the end", async () => {
  const code = { passes: "assert sum([1, 2]) == 3", fails: "assert sum([1, 2]) == 4", unverifiable: "assert len('abc') == 3" };
  const noDocker = createPythonVerifier({ image: IMAGE, spawn: () => { throw Object.assign(new Error("docker CLI not found on PATH"), { code: "ENOENT" }); } });
  const seen: Array<{ source: string; signal?: AbortSignal }> = [];
  const verifyPython: VerifyPython = async (source, signal) => {
    seen.push({ source, signal });
    if (source === code.passes) return { status: "verified" };
    if (source === code.fails) return { status: "failed", exitCode: 1, error: "AssertionError" };
    return noDocker(source, signal);
  };
  const served = chatWith({ passes: fence(code.passes), fails: fence(code.fails), empty: "", unverifiable: `Here you go:\n${fence(code.unverifiable)}\nDone.` });
  const { jobs, submit, close } = await setup({ verifyPython }, served);
  try {
    const result = await submit({ template_id: "verified_code", inputs: { specs: "passes\nfails\nempty\nunverifiable" } });
    await wait(() => jobs.rows.get(result.job_id)?.record.status === "done");
    const rows = ["train.jsonl", "valid.jsonl"].flatMap(file =>
      readFileSync(join(result.output_dir, file), "utf8").trim().split("\n").map(line => JSON.parse(line)));
    expect(rows.map(row => row.messages)).toEqual((["passes", "fails", "unverifiable"] as const).map(spec =>
      [{ role: "user", content: spec }, { role: "assistant", content: fence(code[spec]) }]));
    expect(rows.map(row => row.metadata)).toEqual([
      { verified: true, language: "python", verify_error: null },
      { verified: false, language: "python", verify_error: "AssertionError" },
      { verified: false, language: "python", verify_error: expect.stringMatching(/^unverified \(docker-missing\): the docker CLI was not found on PATH/) },
    ]);
    expect(seen.map(call => call.source)).toEqual([code.passes, code.fails, code.unverifiable]);
    expect(seen.every(call => call.signal instanceof AbortSignal && !call.signal.aborted)).toBe(true);
    expect(served.state).toEqual({ acquired: 1, leases: 0 });
    expect(jobs.rows.get(result.job_id)!.events.some(event => event.type === "stage" && String(event.message).includes("1/4 specs verified (unverified rows kept with verified=false)"))).toBe(true);
  } finally { await close(); }
});

test("a request names the model it sends, defaulting to local", async () => {
  const bodies: any[] = [];
  const served = servedBy(async (url, init) => { bodies.push({ url, ...JSON.parse(init.body as string) });
    return Response.json({ choices: [{ message: { content: '["one"]' } }] }); });
  const { jobs, submit, close } = await setup({}, served);
  try {
    const first = await submit({ template_id: "self_instruct", inputs: { seeds: "seed", variants_per_seed: 1 } });
    const second = await submit({ template_id: "self_instruct", model_name: "other", inputs: { seeds: "seed", variants_per_seed: 1 } });
    await wait(() => [first, second].every(job => jobs.rows.get(job.job_id)?.record.status === "done"));
    expect(bodies.map(body => [body.url, body.model]).toSorted()).toEqual([["http://model.local/v1/chat/completions", "local"], ["http://model.local/v1/chat/completions", "other"]]);
  } finally { await close(); }
});

test("simultaneous dataset submissions retain separate output files", async () => {
  const { jobs, submit, close } = await setup();
  const clock = spyOn(Date, "now").mockReturnValue(123456789);
  try {
    const results = await Promise.all(["first", "second"].map(answer => submit({ template_id: "sft_qa_pairs", inputs: { pairs_text: `Q: hello\nA: ${answer}` } })));
    await wait(() => results.every(result => jobs.rows.get(result.job_id)?.record.status === "done"));
    expect(results[0].output_dir).not.toBe(results[1].output_dir);
    for (const [i, answer] of ["first", "second"].entries()) {
      const row = JSON.parse(readFileSync(join(results[i].output_dir, "train.jsonl"), "utf8"));
      expect(row.messages[1].content).toBe(answer);
    }
  } finally { clock.mockRestore(); await close(); }
});

test("loopback client preserves defaults, tool payload and cancellation signal", async () => {
  const controller = new AbortController();
  const requests: any[] = [];
  const client = makeLlmClient("http://127.0.0.1:1234/", "local-model", { signal: controller.signal,
    fetch: fetcher(async (url, init) => { requests.push({ url, ...init, body: JSON.parse(init!.body as string) });
      return Response.json({ choices: [{ message: { content: "answer", tool_calls: [{ id: "one" }] } }] }); }) });
  expect(await client.chat([{ role: "user", content: "hi" }])).toBe("answer");
  expect(requests[0]).toMatchObject({ url: "http://127.0.0.1:1234/v1/chat/completions", signal: controller.signal,
    headers: { Authorization: "Bearer sk-mlx-bun-local" }, body: { model: "local-model", max_tokens: 512,
      temperature: .7, chat_template_kwargs: { enable_thinking: false } } });
  const tools = [{ type: "function", function: { name: "example" } }];
  expect((await client.chatRaw([], { tools, maxTokens: 42, temperature: .2, enableThinking: true })).choices[0].message.tool_calls).toHaveLength(1);
  expect(requests[1].body).toMatchObject({ tools, max_tokens: 42, temperature: .2, chat_template_kwargs: { enable_thinking: true } });
});

test("Hugging Face import preserves config discovery, row filtering and pagination", async () => {
  const urls: string[] = [];
  const rows = await genHfDatasetImport({ hf_id: "owner/data", min_chars: 3, label_column: "label", label_filter: "yes" }, () => {}, undefined,
    { fetch: fetcher(async url => { urls.push(String(url));
      if (urls.length === 1) return Response.json({ splits: [{ config: "config-a", split: "train" }] });
      return Response.json({ rows: urls.length === 2 ? [{ row: { text: "valid text", label: "yes" } }, { row: { text: "xx", label: "yes" } }, { row: { text: "other text", label: "no" } }] : [] }); }) });
  expect(rows).toEqual([{ text: "valid text" }]);
  expect(urls[1]).toContain("config=config-a&split=train&offset=0");
  expect(urls[2]).toContain("offset=3");
});

test("Hugging Face cancellation interrupts retry backoff without another request", async () => {
  const abort = new AbortController();
  let calls = 0;
  const pending = genHfDatasetImport({ hf_id: "owner/data", config: "default" }, () => {}, undefined,
    { signal: abort.signal, fetch: fetcher(async () => { calls++; return new Response("retry", { status: 503 }); }) });
  await Bun.sleep(10); abort.abort();
  await expect(pending).rejects.toThrow();
  expect(calls).toBe(1);
});

test("code-completion cancellation closes an active directory iterator before reading files", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-dataset-scan-")); roots.push(root);
  const abort = new AbortController();
  const reason = new Error("cancel scan");
  let closed = false, reachedTail = false;
  const scan = spyOn(Bun.Glob.prototype, "scan").mockImplementation(async function* () {
    try {
      yield "a.py";
      abort.abort(reason);
      yield "b.py";
      reachedTail = true;
    } finally { closed = true; }
  });
  try {
    await expect(genCodeCompletion({ src_dir: root }, undefined, undefined, { signal: abort.signal })).rejects.toBe(reason);
    expect(closed).toBe(true);
    expect(reachedTail).toBe(false);
  } finally { scan.mockRestore(); }
});

test("a host that serves no model fails an LLM template's job and leaves a non-LLM one untouched", async () => {
  const none = { models: { defaultFor: async () => undefined, acquire: async () => { throw new Error("unused"); } } as unknown as ModelHost, state: { leases: 0, acquired: 0 } };
  const { jobs, submit, close } = await setup({}, none);
  try {
    const llm = await submit({ template_id: "self_instruct", inputs: { seeds: "seed" } });
    await wait(() => jobs.rows.get(llm.job_id)?.record.status === "failed");
    expect(jobs.rows.get(llm.job_id)!.record.error).toContain("no model can generate");
  } finally { await close(); }
});

test("shutdown aborts an active model request and releases the lease", async () => {
  let entered = false;
  const served = servedBy((_url, init) => new Promise<Response>((_, reject) => { entered = true;
    init.signal!.addEventListener("abort", () => reject(init.signal!.reason), { once: true }); }));
  const { jobs, submit, close } = await setup({}, served);
  try {
    const result = await submit({ template_id: "style_transfer", inputs: { reference_samples: "ref", raw_text: "text" } });
    await wait(() => entered);
    expect(served.state.leases).toBe(1);
    await close();
    expect(jobs.rows.get(result.job_id)!.record.status).toBe("failed");
    expect(served.state.leases).toBe(0);
  } finally { await close(); }
});
