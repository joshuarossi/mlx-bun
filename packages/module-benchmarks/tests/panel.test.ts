// The web panel as a browser would run it: a custom element that takes a
// connection, lists the tasks and history through the module's routes, starts
// runs and shows a comparison. happy-dom stands in for the browser; fetch is a
// fake recording what the panel asks.
import { afterEach, beforeAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
import type { BenchmarkComparison, BenchmarkTasks, EvalHistoryEntry } from "../src/protocol";

const requests: { url: string; init?: RequestInit }[] = [];
const dataDirectory = "/home/.mlx-bun/benchmarks/data";
let tasks: BenchmarkTasks, jobs: object[] = [], history: EvalHistoryEntry[] = [], answers: { start: { ok: boolean; body: unknown }; compare: { ok: boolean; body: unknown } };
const reset = () => {
  tasks = { dataDirectory, tasks: [
    { id: "gsm8k-50", component: null, sets: ["smoketest", "all"], needsVerifier: false, datasets: [{ name: "gsm8k", rows: 1319, sha256: "x", source: "s", present: true }] },
    { id: "mmlu", component: "MMLU", sets: ["capability", "all"], needsVerifier: false, datasets: [{ name: "mmlu_optiq_frozen", rows: 969, sha256: "x", source: "s", present: true }] },
    { id: "ifeval", component: "IFEval", sets: ["capability", "all"], needsVerifier: false, datasets: [{ name: "ifeval_optiq_frozen", rows: 541, sha256: "x", source: "s", present: false }] }] };
  jobs = []; history = []; answers = { start: { ok: true, body: {} }, compare: { ok: true, body: {} } };
};
reset();
const fakeFetch = (async (url: string, init?: RequestInit) => {
  requests.push({ url, init });
  const json = (body: unknown, ok = true) => ({ ok, status: ok ? 200 : 400, json: async () => body });
  if (init?.method === "POST") return json(answers.start.body, answers.start.ok);
  if (url.includes("/compare")) return json(answers.compare.body, answers.compare.ok);
  if (url.endsWith("/tasks")) return json(tasks);
  if (url.endsWith("/runs")) return json({ runs: history });
  if (url.endsWith("/jobs")) return json({ jobs });
  throw new Error(`unexpected ${url}`);
}) as unknown as typeof fetch;

let window: GlobalWindow;
beforeAll(async () => {
  window = new GlobalWindow({ url: "http://localhost/" });
  Object.assign(globalThis, { window, document: window.document, HTMLElement: window.HTMLElement, customElements: window.customElements, fetch: fakeFetch, Node: window.Node });
  await import("../src/panel");
});
afterEach(() => { document.body.replaceChildren(); requests.length = 0; reset(); });

const entry = (id: string, accuracy: number, complete = true): EvalHistoryEntry => ({ id, label: id, startedAt: "2026-09-29T12:00:00.000Z", finishedAt: null, durationMs: 1, complete,
  exitCode: complete ? 0 : 1, problems: [], model: { path: "/m/qwen", repo: "mlx-community/Qwen2.5-0.5B-Instruct-4bit", revision: null }, enableThinking: false, machine: null,
  tasks: [{ task: "gsm8k-50", status: "complete", reason: null, accuracy, correct: accuracy * 50, total: 50, wallMs: 1 }], capability: null, runDirectory: "/r" });
const mount = () => {
  const panel = document.createElement("mlx-benchmarks-panel") as HTMLElement & { connection?: { apiBase: string; eventsUrl: string }; refresh(): Promise<void> };
  panel.connection = { apiBase: "/api/benchmarks", eventsUrl: "/api/benchmarks/stream" };
  document.body.append(panel);
  return panel;
};
/** happy-dom's events on its elements. */
const fire = (node: EventTarget, type: string) => node.dispatchEvent(new window.Event(type) as unknown as Event);
const settle = () => new Promise(resolve => setTimeout(resolve, 5));
const buttons = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll("button")];
const text = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll("p, h3, tr, .row, pre")].map(node => node.textContent).join("\n");
const rows = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll("tr")].map(row => [...row.querySelectorAll("th, td")].map(cell => cell.textContent).join(" | "));

test("the element registers under the manifest's tag and loads the tasks, history and jobs named by its connection", async () => {
  expect(customElements.get("mlx-benchmarks-panel")).toBeDefined();
  const panel = mount();
  await settle();
  expect(requests.map(request => request.url).sort()).toEqual(["/api/benchmarks/jobs", "/api/benchmarks/runs", "/api/benchmarks/tasks"]);
  expect(panel.shadowRoot!.querySelectorAll("input[type=checkbox]").length).toBe(3);
  expect(text(panel)).toContain(`Datasets must already be in ${dataDirectory}`);
});

test("a task whose dataset is missing cannot be chosen, and Run posts the chosen tasks and model", async () => {
  const panel = mount();
  await settle();
  const boxes = [...panel.shadowRoot!.querySelectorAll<HTMLInputElement>("input[type=checkbox]")];
  expect(boxes.map(box => box.hasAttribute("disabled"))).toEqual([false, false, true]);
  expect(panel.shadowRoot!.querySelectorAll("label")[2]!.getAttribute("title")).toBe(`missing in ${dataDirectory}: ifeval_optiq_frozen`);
  requests.length = 0;
  buttons(panel).find(button => button.textContent === "Run")!.click();
  await settle();
  expect(requests).toEqual([]);
  boxes[0]!.checked = true; fire(boxes[0]!, "change");
  boxes[1]!.checked = true; fire(boxes[1]!, "change");
  const model = panel.shadowRoot!.querySelector<HTMLInputElement>("input[type=text]")!;
  model.value = "org/other"; fire(model, "input");
  buttons(panel).find(button => button.textContent === "Run")!.click();
  await settle();
  const post = requests.find(request => request.init?.method === "POST")!;
  expect(post.url).toBe("/api/benchmarks/runs");
  expect(JSON.parse(post.init!.body as string)).toEqual({ tasks: ["gsm8k-50", "mmlu"], model: "org/other" });
});

test("history lists each run with its per-task accuracy; a running job disables Run and shows its progress; a refused start shows the server's message", async () => {
  history = [entry("r2", 0.5), entry("r1", 0.42, false)];
  jobs = [{ id: "job_1", status: "running", progress: 0.5, message: "mmlu 25/970", error: null, startedAt: "x", endedAt: null }];
  const panel = mount();
  await settle();
  expect(rows(panel)).toContain("run | when | model | result | gsm8k-50");
  expect(rows(panel)).toContain("r2 | 2026-09-29 12:00 | mlx-community/Qwen2.5-0.5B-Instruct-4bit | complete | 50.00%");
  expect(rows(panel)).toContain("r1 | 2026-09-29 12:00 | mlx-community/Qwen2.5-0.5B-Instruct-4bit | incomplete | 42.00%");
  expect(buttons(panel).find(button => button.textContent === "Run")!.hasAttribute("disabled")).toBe(true);
  expect(text(panel)).toContain("running 50%: mmlu 25/970");
  jobs = [];
  answers.start = { ok: false, body: { error: { message: "no local model matches \"org/none\"" } } };
  await panel.refresh();
  const box = panel.shadowRoot!.querySelector<HTMLInputElement>("input[type=checkbox]")!;
  box.checked = true; fire(box, "change");
  buttons(panel).find(button => button.textContent === "Run")!.click();
  await settle();
  expect(text(panel)).toContain('no local model matches "org/none"');
});

test("Compare asks for the two chosen runs and shows the accuracy differences and the runner's report", async () => {
  history = [entry("r2", 0.5), entry("r1", 0.4)];
  const comparison: BenchmarkComparison = { base: "r1", candidate: "r2", comparable: false, markdown: "# differs\n- gsm8k-50: 40.00% vs 50.00%",
    tasks: [{ task: "gsm8k-50", base: 0.4, candidate: 0.5, delta: 0.1 }, { task: "mmlu", base: null, candidate: 0.5, delta: null }] };
  answers.compare = { ok: true, body: comparison };
  const panel = mount();
  await settle();
  const [base, candidate] = [...panel.shadowRoot!.querySelectorAll<HTMLSelectElement>("select")];
  base!.value = "r1"; fire(base!, "change");
  candidate!.value = "r2"; fire(candidate!, "change");
  buttons(panel).find(button => button.textContent === "Compare")!.click();
  await settle();
  expect(requests.at(-1)!.url).toBe("/api/benchmarks/compare?base=r1&candidate=r2");
  expect(rows(panel)).toContain("task | base | candidate | difference");
  expect(rows(panel)).toContain("gsm8k-50 | 40.00% | 50.00% | +10.00 pts");
  expect(rows(panel)).toContain("mmlu | — | 50.00% | —");
  expect(text(panel)).toContain("Differences or problems flagged");
  expect(panel.shadowRoot!.querySelector("pre")!.textContent).toContain("gsm8k-50: 40.00% vs 50.00%");
});

test("text from the server is drawn as text, never as markup", async () => {
  history = [{ ...entry("<img src=x onerror=alert(1)>", 0.5) }];
  const panel = mount();
  await settle();
  expect(panel.shadowRoot!.querySelector("img")).toBeNull();
  expect(text(panel)).toContain("<img src=x onerror=alert(1)>");
});

test("a failing route is reported instead of an empty panel", async () => {
  const failing = (async () => ({ ok: false, status: 503, json: async () => ({ error: { message: "the evaluation runner needs a source checkout" } }) })) as unknown as typeof fetch;
  const before = globalThis.fetch;
  Object.assign(globalThis, { fetch: failing });
  try {
    const panel = mount();
    await settle();
    expect(text(panel)).toContain("the evaluation runner needs a source checkout");
  } finally { Object.assign(globalThis, { fetch: before }); }
});

test("the entry imports without a DOM, defining nothing", () => {
  const child = Bun.spawnSync([process.execPath, "-e", 'const m = await import("@mlx-bun/module-benchmarks/panel"); if (typeof customElements !== "undefined" || typeof m.BenchmarksPanel !== "function") throw new Error("unexpected")'],
    { cwd: import.meta.dir, stdout: "pipe", stderr: "pipe" });
  expect(child.stderr.toString()).toBe("");
  expect(child.exitCode).toBe(0);
});
