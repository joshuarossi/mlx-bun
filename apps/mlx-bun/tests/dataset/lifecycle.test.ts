import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { createJobHost } from "../../src/jobs/host";
import { JobStore } from "../../src/jobs/db";
import { createDatasetRunner } from "../../src/dataset/job";
import { makeLlmClient } from "../../src/dataset/llm";
import { genHfDatasetImport } from "../../src/dataset/generators";
import { createDatasetRoutes } from "../../src/server/dataset-routes";
import { generate } from "../../src/dataset/registry";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });
function setup() {
  const root = mkdtempSync(join(tmpdir(), "mlx-dataset-")); roots.push(root);
  const store = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  let leases = 0;
  const host = createJobHost({ createStore: () => store, entry: "unused", acquire: async () => {
    leases++; throw new Error("dataset must not acquire a GPU lease");
  } });
  return { root, store, host, leases: () => leases };
}
const fetcher = (fn: (input: string | URL | Request, init?: RequestInit) => Promise<Response>) => fn as typeof fetch;
const wait = async (check: () => boolean) => { for (let i = 0; !check(); i++) {
  if (i > 100) throw new Error("condition did not settle"); await Bun.sleep(5);
} };

test("dataset HTTP submission writes the existing split through an in-process job without a GPU lease", async () => {
  const { root, store, host, leases } = setup();
  const routes = createDatasetRoutes({ outputRoot: root, serverPort: () => 9876,
    submit: (config, output) => host.submitTask("dataset", config, createDatasetRunner(), output) });
  try {
    const response = await routes.handle(new Request("http://local/api/dataset/submit", { method: "POST",
      body: JSON.stringify({ template_id: "sft_qa_pairs", inputs: { pairs_text: "Q: hello\nA: world" } }) }));
    const result = await response!.json();
    await wait(() => store.get(result.job_id)?.status === "done");
    expect(result.ok).toBe(true);
    const row = store.get(result.job_id)!;
    expect(JSON.parse(row.config_json).api_url).toBe("http://127.0.0.1:9876");
    const train = readFileSync(join(result.output_dir, "train.jsonl"), "utf8");
    expect(JSON.parse(train)).toEqual({ messages: [{ role: "user", content: "hello" }, { role: "assistant", content: "world" }] });
    expect(readFileSync(join(result.output_dir, "valid.jsonl"), "utf8")).toBe(train);
    expect(leases()).toBe(0);
    expect(readFileSync(row.log_path, "utf8")).toContain('"type":"done"');
  } finally { await host.close(); }
});

test("templates retain verified-code fields but clearly disable execution before submitting a job", async () => {
  let submitted = false;
  const routes = createDatasetRoutes({ serverPort: () => 1, submit: () => { submitted = true; throw Error("unexpected"); } });
  const templates = await (await routes.handle(new Request("http://local/api/dataset/templates")))!.json();
  expect(templates.templates).toHaveLength(13);
  expect(templates.templates.find((t: any) => t.id === "verified_code").description).toContain("Unavailable");
  for (const [id, status] of [["verified_code", 501], ["constructor", 400], ["missing", 400]] as const) {
    expect((await routes.handle(new Request("http://local/api/dataset/submit", { method: "POST", body: JSON.stringify({ template_id: id }) })))!.status).toBe(status);
  }
  expect(submitted).toBe(false);
  await expect(generate("verified_code", {}, "/unused", () => {})).rejects.toThrow("unavailable");
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

test("shutdown aborts an active loopback fetch and joins task cleanup before closing SQLite", async () => {
  const { root, host, store } = setup();
  let entered = false, settled = false, closed = false;
  const close = store.close.bind(store);
  store.close = () => { expect(settled).toBe(true); closed = true; close(); };
  const runner = createDatasetRunner({ fetch: fetcher(async (_url, init) => {
    entered = true;
    try { await new Promise<void>((_, reject) => init!.signal!.addEventListener("abort", () => reject(init!.signal!.reason), { once: true })); }
    finally { await Bun.sleep(5); expect(closed).toBe(false); settled = true; }
    return Response.json({});
  }) });
  const { jobId } = host.submitTask("dataset", { template_id: "style_transfer", inputs: { reference_samples: "ref", raw_text: "text" },
    output_dir: join(root, "out"), api_url: "http://unused" }, runner);
  await wait(() => entered);
  await host.close();
  expect(closed).toBe(true);
  const reopened = new JobStore(join(root, "jobs.sqlite"), join(root, "logs"));
  try { expect(reopened.get(jobId)?.status).toBe("failed"); } finally { reopened.close(); }
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
