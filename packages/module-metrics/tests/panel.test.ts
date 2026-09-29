// The web panel as a browser would run it: a custom element that takes a
// connection, draws the streamed snapshot into its shadow root, and starts and
// lists benchmark runs through the module's routes. happy-dom stands in for
// the browser; EventSource and fetch are fakes recording what the panel asks.
import { afterEach, beforeAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
import { createMetricsStore } from "../src/store";
import type { BenchHistoryEntry, MetricsSnapshot } from "../src/protocol";
import { RECORDED } from "./support";

class FakeEventSource {
  static instances: FakeEventSource[] = [];
  listeners = new Map<string, ((event: unknown) => void)[]>();
  closed = false;
  constructor(readonly url: string) { FakeEventSource.instances.push(this); }
  addEventListener(type: string, listener: (event: unknown) => void) { this.listeners.set(type, [...this.listeners.get(type) ?? [], listener]); }
  close() { this.closed = true; }
  emit(type: string, data?: string) { for (const listener of this.listeners.get(type) ?? []) listener({ data }); }
}

const requests: { url: string; init?: RequestInit }[] = [];
let benchJobs: object[] = [], history: BenchHistoryEntry[] = [], startResponse: { ok: boolean; body: unknown } = { ok: true, body: {} };
const fakeFetch = (async (url: string, init?: RequestInit) => {
  requests.push({ url, init });
  const json = (body: unknown, ok = true) => ({ ok, status: ok ? 200 : 400, json: async () => body });
  if (init?.method === "POST") return json(startResponse.body, startResponse.ok);
  if (url.endsWith("/history")) return json({ runs: history });
  if (url.endsWith("/bench/profiles")) return json({ profiles: [{ name: "quick", path: "/p/quick.json", scope: "scoped", models: ["qwen"] }] });
  if (url.endsWith("/bench")) return json({ jobs: benchJobs });
  throw new Error(`unexpected ${url}`);
}) as unknown as typeof fetch;

let window: GlobalWindow;
beforeAll(async () => {
  window = new GlobalWindow({ url: "http://localhost/" });
  Object.assign(globalThis, { window, document: window.document, HTMLElement: window.HTMLElement, customElements: window.customElements,
    EventSource: FakeEventSource, fetch: fakeFetch, MessageEvent: window.MessageEvent, Node: window.Node });
  await import("../src/panel");
});
afterEach(() => { document.body.replaceChildren(); FakeEventSource.instances.length = 0; requests.length = 0; benchJobs = []; history = []; startResponse = { ok: true, body: {} }; });

const snapshot = (): MetricsSnapshot => { const store = createMetricsStore({ now: () => 5_000 }); for (const event of RECORDED) store.apply(event); return store.snapshot(); };
const mount = () => {
  const panel = document.createElement("mlx-metrics-panel") as HTMLElement & { connection?: { apiBase: string; eventsUrl: string } };
  panel.connection = { apiBase: "/api/metrics", eventsUrl: "/api/metrics/stream" };
  document.body.append(panel);
  return panel;
};
const settle = () => new Promise(resolve => setTimeout(resolve, 5));
const shadowText = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll("p, h3, .tile, tr, .cache, .row")].map(node => node.textContent).join("\n");
/** Table rows as their cells joined by " | ", tiles as "value label". */
const cells = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll("tr")].map(row => [...row.querySelectorAll("th, td")].map(cell => cell.textContent).join(" | "));
const tiles = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll(".tile")].map(tile => [...tile.children].map(child => child.textContent).join(" "));

test("the element registers under the manifest's tag and connects the stream named by its connection", () => {
  expect(customElements.get("mlx-metrics-panel")).toBeDefined();
  mount();
  expect(FakeEventSource.instances.map(source => source.url)).toEqual(["/api/metrics/stream"]);
  expect(requests.map(request => request.url).sort()).toEqual(["/api/metrics/bench", "/api/metrics/bench/profiles", "/api/metrics/history"]);
});

test("a streamed snapshot renders throughput, batch occupancy, queue, models, caches and request timings", async () => {
  const panel = mount();
  expect(shadowText(panel)).toContain("Waiting for the first snapshot");
  FakeEventSource.instances[0]!.emit("snapshot", JSON.stringify(snapshot()));
  // The last throughput sample; the scheduler left with its model, so no batch reading; the request counter.
  expect(tiles(panel)).toEqual(["512.0 tok/s throughput", "— batch rows", "— queued", "3 requests finished"]);
  const rows = cells(panel);
  expect(rows).toContain("org/chat | unloaded | 900 ms | 500 ms | — | 381 MB | 0 KB | 0 KB");
  expect(rows).toContain("org/other | resident | 600 ms | — | 1.10 s | 858 MB | 0 KB | 0 KB");
  expect(rows).toContain("org/broken | failed | — | — | — | 0 KB | 0 KB | 0 KB");
  expect(rows).toContain(" | p50 | p95 | max");
  expect(rows).toContain("queue wait | 10 ms | 50 ms | 50 ms");
  expect(rows).toContain("time to first token | 40 ms | 120 ms | 120 ms");
  expect(rows).toContain("prefill | 900.0 tok/s | 1000.0 tok/s | 1000.0 tok/s");
  expect(rows).toContain("decode | 190.0 tok/s | 210.0 tok/s | 210.0 tok/s");
  expect(rows).toContain("total | 320 ms | 400 ms | 400 ms");
  expect(shadowText(panel)).toContain("Prompt tokens served from cache over the last 3 requests: 33%");
  expect(panel.shadowRoot!.querySelector("svg polyline")!.getAttribute("points")).toContain(",");
});

test("cache usage renders with hit rate and capacity while the model is resident", async () => {
  const store = createMetricsStore({ now: () => 5_000 });
  for (const event of RECORDED.slice(0, 11)) store.apply(event);
  const panel = mount();
  FakeEventSource.instances[0]!.emit("snapshot", JSON.stringify(store.snapshot()));
  const text = shadowText(panel);
  expect(text).toContain("org/chat · prefix cache 5 MB of 7.45 GB · hit rate 75% (3 of 4 lookups)");
  expect(text).toContain("org/chat · batch KV 29 MB of 954 MB");
  expect(tiles(panel).slice(1, 3)).toEqual(["3 / 4 batch rows", "2 queued"]);
  expect(panel.shadowRoot!.querySelectorAll(".bar i").length).toBe(2);
});

test("text from the server is drawn as text, never as markup", async () => {
  const hostile = snapshot() as unknown as { models: { model: string }[] };
  const panel = mount();
  FakeEventSource.instances[0]!.emit("snapshot", JSON.stringify({ ...hostile, models: [{ ...hostile.models[0], model: "<img src=x onerror=alert(1)>" }] }));
  expect(panel.shadowRoot!.querySelector("img")).toBeNull();
  expect(shadowText(panel)).toContain("<img src=x onerror=alert(1)>");
});

test("a broken frame or a dropped stream is reported without discarding the last good snapshot", () => {
  const panel = mount(), source = FakeEventSource.instances[0]!;
  source.emit("snapshot", JSON.stringify(snapshot()));
  source.emit("snapshot", "{nope");
  expect(shadowText(panel)).toContain("unreadable snapshot");
  expect(shadowText(panel)).toContain("Models");
  source.emit("error");
  expect(shadowText(panel)).toContain("stream interrupted; retrying");
  source.emit("snapshot", JSON.stringify(snapshot()));
  expect(shadowText(panel)).not.toContain("stream interrupted");
});

test("the benchmark section lists profiles and history, and Run posts the chosen profile", async () => {
  history = [{ id: "r1", profile: "quick", scope: "scoped", startedAt: "2026-09-29T12:00:00.000Z", finishedAt: null, durationMs: 1, complete: true, exitCode: 0, problems: [],
    machine: null, runDirectory: "/r", cells: [{ key: "a", model: "qwen", kind: "tree", status: "measured", decodeTokensPerSecond: 205, ttftColdMs: 1, prefill1kTokensPerSecond: 1,
      contextPrefillTokensPerSecond: 1, aggregateTokensPerSecond: 1, coldStartMs: 1, peakRssMB: 1 }] }];
  const panel = mount();
  await settle();
  const text = shadowText(panel);
  expect(text).toContain("quick (scoped)");
  expect(text).toContain("2026-09-29 12:00");
  expect(text).toContain("complete");
  expect(text).toContain("205.0 tok/s");
  const run = [...panel.shadowRoot!.querySelectorAll("button")].find(button => button.textContent === "Run benchmark")!;
  requests.length = 0;
  run.click();
  await settle();
  const post = requests.find(request => request.init?.method === "POST")!;
  expect(post.url).toBe("/api/metrics/bench");
  expect(JSON.parse(post.init!.body as string)).toEqual({ profile: "quick" });
});

test("a running job disables Run and shows its progress; a refused start shows the server's message", async () => {
  benchJobs = [{ id: "job_1", status: "running", progress: 0.5, message: "cell 2/4: qwen/candidate/default", error: null, startedAt: "x", endedAt: null }];
  const panel = mount();
  await settle();
  const run = [...panel.shadowRoot!.querySelectorAll("button")].find(button => button.textContent === "Run benchmark")!;
  expect(run.hasAttribute("disabled")).toBe(true);
  expect(shadowText(panel)).toContain("running: cell 2/4: qwen/candidate/default");
  benchJobs = [];
  startResponse = { ok: false, body: { error: { message: "no such profile" } } };
  await (panel as unknown as { refreshBench(): Promise<void> }).refreshBench();
  [...panel.shadowRoot!.querySelectorAll("button")].find(button => button.textContent === "Run benchmark")!.click();
  await settle();
  expect(shadowText(panel)).toContain("no such profile");
});

test("removing the element closes the stream, and changing the connection reconnects", () => {
  const panel = mount();
  const first = FakeEventSource.instances[0]!;
  panel.connection = { apiBase: "/other/api/metrics", eventsUrl: "/other/api/metrics/stream" };
  expect(first.closed).toBe(true);
  expect(FakeEventSource.instances.map(source => source.url)).toEqual(["/api/metrics/stream", "/other/api/metrics/stream"]);
  panel.remove();
  expect(FakeEventSource.instances[1]!.closed).toBe(true);
});

test("the entry imports without a DOM, defining nothing", async () => {
  const child = Bun.spawnSync([process.execPath, "-e", 'const m = await import("@mlx-bun/module-metrics/panel"); if (typeof customElements !== "undefined" || typeof m.MetricsPanel !== "function") throw new Error("unexpected")'],
    { cwd: import.meta.dir, stdout: "pipe", stderr: "pipe" });
  expect(child.stderr.toString()).toBe("");
  expect(child.exitCode).toBe(0);
});
