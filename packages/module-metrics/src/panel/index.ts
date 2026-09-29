// `<mlx-metrics-panel>`: the module's web panel as one self-contained custom
// element. It imports only its data protocol (types), draws into its own
// shadow root and reaches the backend only through `connection`, so any host
// (the web shell, a native webview) mounts it the same way: create the element, set `connection`, append it.
import type {
  BenchHistoryEntry, BenchJob, BenchProfile, Distribution, MetricsSnapshot, ModelMetrics, PanelConnection,
} from "../protocol";

const TAG = "mlx-metrics-panel";

const STYLE = `
:host { display: block; color: var(--text, CanvasText); font: 14px/1.45 system-ui, sans-serif; }
section { margin: 0 0 18px; }
h3 { margin: 0 0 6px; font-size: 13px; letter-spacing: .04em; text-transform: uppercase; color: var(--dim, GrayText); }
.tiles { display: flex; flex-wrap: wrap; gap: 10px; }
.tile { min-width: 120px; padding: 8px 12px; border: 1px solid var(--line, #8884); border-radius: 8px; }
.tile b { display: block; font-size: 22px; font-variant-numeric: tabular-nums; }
.tile span { color: var(--dim, GrayText); font-size: 12px; }
table { border-collapse: collapse; width: 100%; font-variant-numeric: tabular-nums; }
th, td { text-align: left; padding: 3px 10px 3px 0; border-bottom: 1px solid var(--line, #8883); white-space: nowrap; }
th { font-weight: 600; color: var(--dim, GrayText); font-size: 12px; }
td.num, th.num { text-align: right; }
.bar { height: 6px; border-radius: 3px; background: var(--line, #8883); overflow: hidden; margin-top: 3px; }
.bar i { display: block; height: 100%; background: var(--blue, #3b82f6); }
.bad { color: var(--red, #dc2626); } .good { color: var(--green, #16a34a); }
svg { width: 100%; height: 56px; display: block; }
polyline { fill: none; stroke: var(--blue, #3b82f6); stroke-width: 1.5; vector-effect: non-scaling-stroke; }
button, select { font: inherit; }
.note { color: var(--dim, GrayText); font-size: 12px; }
.row { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
`;

const bytes = (value: number | null | undefined): string => {
  if (value === null || value === undefined) return "—";
  if (value >= 2 ** 30) return `${(value / 2 ** 30).toFixed(2)} GB`;
  if (value >= 2 ** 20) return `${(value / 2 ** 20).toFixed(0)} MB`;
  return `${(value / 1024).toFixed(0)} KB`;
};
const ms = (value: number | null | undefined): string => value === null || value === undefined ? "—" : value >= 1000 ? `${(value / 1000).toFixed(2)} s` : `${value.toFixed(0)} ms`;
const rate = (value: number | null | undefined): string => value === null || value === undefined ? "—" : `${value.toFixed(value < 10 ? 2 : 1)} tok/s`;
const percent = (value: number | null | undefined): string => value === null || value === undefined ? "—" : `${(value * 100).toFixed(0)}%`;

type Child = Node | string | null | undefined | false;
function h<K extends keyof HTMLElementTagNameMap>(tag: K, attributes: Record<string, string> = {}, ...children: Child[]): HTMLElementTagNameMap[K] {
  const element = document.createElement(tag);
  for (const [name, value] of Object.entries(attributes)) element.setAttribute(name, value);
  for (const child of children) if (child) element.append(child);
  return element;
}
const svgNs = "http://www.w3.org/2000/svg";

function tile(value: string, label: string): HTMLElement { return h("div", { class: "tile" }, h("b", {}, value), h("span", {}, label)); }
function meter(fraction: number | null): HTMLElement {
  const fill = h("i");
  fill.style.width = `${Math.max(0, Math.min(1, fraction ?? 0)) * 100}%`;
  return h("div", { class: "bar" }, fill);
}
function table(head: readonly string[], rows: readonly (readonly (string | Node)[])[]): HTMLElement {
  return h("table", {}, h("thead", {}, h("tr", {}, ...head.map((name, index) => h("th", index ? { class: "num" } : {}, name)))),
    h("tbody", {}, ...rows.map(row => h("tr", {}, ...row.map((cell, index) => h("td", index ? { class: "num" } : {}, cell))))));
}
const dist = (value: Distribution | null, format: (n: number) => string): [string, string, string] =>
  value ? [format(value.p50), format(value.p95), format(value.max)] : ["—", "—", "—"];

function spark(series: MetricsSnapshot["series"]): SVGElement {
  const svg = document.createElementNS(svgNs, "svg");
  svg.setAttribute("viewBox", "0 0 100 40"); svg.setAttribute("preserveAspectRatio", "none");
  const peak = Math.max(1, ...series.map(point => point.tokensPerSecond));
  const line = document.createElementNS(svgNs, "polyline");
  line.setAttribute("points", series.map((point, index) => `${series.length > 1 ? (100 * index) / (series.length - 1) : 0},${38 - (36 * point.tokensPerSecond) / peak}`).join(" "));
  svg.append(line);
  return svg;
}

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class MetricsPanel extends Base {
  #connection: PanelConnection | undefined;
  #shadow: ShadowRoot;
  /** The live sections redraw on every snapshot; the benchmark section only when its data changes, so an open menu survives. */
  #status = h("p", { class: "note" });
  #live = h("div");
  #bench = h("div");
  #stream: EventSource | undefined;
  #timer: ReturnType<typeof setInterval> | undefined;
  #snapshot: MetricsSnapshot | undefined;
  #history: readonly BenchHistoryEntry[] = [];
  #profiles: readonly BenchProfile[] = [];
  #jobs: readonly BenchJob[] = [];
  #error = "";
  #chosen = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    this.#shadow.append(h("style", {}, STYLE), this.#status, this.#live, this.#bench);
  }

  get connection(): PanelConnection | undefined { return this.#connection; }
  set connection(value: PanelConnection | undefined) {
    this.#connection = value;
    if (this.isConnected) { this.#stop(); this.#start(); }
  }

  connectedCallback() { if (this.#connection) this.#start(); else this.#render(); }
  disconnectedCallback() { this.#stop(); }

  #start() {
    const connection = this.#connection!;
    this.#stream = new EventSource(connection.eventsUrl);
    this.#stream.addEventListener("snapshot", event => {
      try { this.#snapshot = JSON.parse((event as MessageEvent<string>).data) as MetricsSnapshot; this.#error = ""; }
      catch { this.#error = "unreadable snapshot"; }
      this.#render();
    });
    this.#stream.addEventListener("error", () => { this.#error = "stream interrupted; retrying"; this.#render(); });
    void this.refreshBench();
    this.#timer = setInterval(() => { if (this.#jobs.some(job => job.status === "queued" || job.status === "running")) void this.refreshBench(); }, 5000);
    this.#render();
    this.#renderBench();
  }

  #stop() {
    this.#stream?.close(); this.#stream = undefined;
    if (this.#timer !== undefined) clearInterval(this.#timer);
    this.#timer = undefined;
  }

  /** Reloads profiles, recent jobs and the run history. */
  async refreshBench(): Promise<void> {
    const base = this.#connection?.apiBase;
    if (base === undefined) return;
    try {
      const [history, profiles, jobs] = await Promise.all(["/history", "/bench/profiles", "/bench"].map(path => fetch(base + path).then(response => response.json())));
      this.#history = history.runs ?? []; this.#profiles = profiles.profiles ?? []; this.#jobs = jobs.jobs ?? [];
    } catch { /* the live view still works without the benchmark section */ }
    this.#renderBench();
  }

  async #launch() {
    const base = this.#connection!.apiBase;
    const profile = this.#chosen || this.#profiles[0]?.name;
    if (!profile) return;
    const response = await fetch(`${base}/bench`, { method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify({ profile }) });
    this.#error = response.ok ? "" : ((await response.json().catch(() => null))?.error?.message ?? `could not start the run (${response.status})`);
    this.#renderStatus();
    await this.refreshBench();
  }

  #models(models: readonly ModelMetrics[]) {
    return table(["model", "state", "load", "unload", "swap", "weights", "KV", "prefix cache"], models.map(model => [
      model.model, h("span", model.state === "failed" ? { class: "bad" } : {}, model.state), ms(model.lastLoadMs), ms(model.lastUnloadMs), ms(model.lastSwapMs),
      bytes(model.weightsBytes), bytes(model.kvBytes), bytes(model.prefixCacheBytes)]));
  }

  #render() {
    const snapshot = this.#snapshot;
    const root = h("div");
    this.#renderStatus();
    if (!snapshot) { this.#live.replaceChildren(); return; }

    const scheduler = snapshot.schedulers[0], last = snapshot.series.at(-1);
    root.append(h("section", {}, h("h3", {}, "Serving"),
      h("div", { class: "tiles" },
        tile(rate(last?.tokensPerSecond ?? scheduler?.tokensPerSecond ?? 0), "throughput"),
        tile(scheduler ? `${scheduler.active} / ${scheduler.capacity}` : "—", "batch rows"),
        tile(scheduler ? String(scheduler.queued) : "—", "queued"),
        tile(String(snapshot.requests.finished), "requests finished")),
      spark(snapshot.series)));

    root.append(h("section", {}, h("h3", {}, "Models"), snapshot.models.length ? this.#models(snapshot.models) : h("p", { class: "note" }, "No model has loaded since this server started.")));

    const cacheRows: Child[] = [];
    for (const cache of snapshot.caches) {
      if (cache.prefix) cacheRows.push(h("div", { class: "cache" }, `${cache.model} · prefix cache ${bytes(cache.prefix.bytes)}${cache.prefix.capacityBytes ? ` of ${bytes(cache.prefix.capacityBytes)}` : ""} · hit rate ${percent(cache.prefix.hitRate)} (${cache.prefix.hits} of ${cache.prefix.hits + cache.prefix.misses} lookups)`,
        meter(cache.prefix.capacityBytes ? cache.prefix.bytes / cache.prefix.capacityBytes : null)));
      if (cache.kv) cacheRows.push(h("div", { class: "cache" }, `${cache.model} · batch KV ${bytes(cache.kv.bytes)}${cache.kv.capacityBytes ? ` of ${bytes(cache.kv.capacityBytes)}` : ""}`,
        meter(cache.kv.capacityBytes ? cache.kv.bytes / cache.kv.capacityBytes : null)));
    }
    root.append(h("section", {}, h("h3", {}, "Caches"), ...cacheRows,
      h("p", { class: "note" }, `Prompt tokens served from cache over the last ${snapshot.requests.window.count} requests: ${percent(snapshot.requests.window.cachedPromptShare)}`)));

    const w = snapshot.requests.window;
    const row = (label: string, value: Distribution | null, format: (n: number) => string) => [label, ...dist(value, format)];
    root.append(h("section", {}, h("h3", {}, `Request timings · last ${w.count}`), table(["", "p50", "p95", "max"], [
      row("queue wait", w.queueMs, ms), row("time to first token", w.ttftMs, ms), row("prefill", w.prefillTokensPerSecond, rate),
      row("decode", w.decodeTokensPerSecond, rate), row("total", w.totalMs, ms)])));

    this.#live.replaceChildren(root);
  }

  #renderStatus() {
    this.#status.className = this.#error ? "note bad" : "note";
    this.#status.textContent = this.#error || (this.#snapshot ? "" : this.#connection ? "Waiting for the first snapshot…" : "No connection set.");
  }

  #renderBench() {
    const root = h("div");
    const running = this.#jobs.find(job => job.status === "queued" || job.status === "running");
    const select = h("select", {}, ...this.#profiles.map(profile => h("option", { value: profile.name }, `${profile.name}${profile.scope ? ` (${profile.scope})` : ""}`)));
    select.addEventListener("change", () => { this.#chosen = select.value; });
    if (this.#chosen) select.value = this.#chosen;
    const run = h("button", {}, "Run benchmark");
    run.addEventListener("click", () => { void this.#launch(); });
    if (running || !this.#profiles.length) run.setAttribute("disabled", "");
    root.append(h("section", {}, h("h3", {}, "Benchmark"),
      this.#profiles.length ? h("div", { class: "row" }, select, run, running ? h("span", { class: "note" }, `${running.status}: ${running.message ?? ""}`) : null)
        : h("p", { class: "note" }, "No plans yet. Create one with scripts/bench-serve.ts plan and save it under the module's bench/plans directory."),
      h("p", { class: "note" }, "A run takes the GPU exclusively until it ends."),
      this.#history.length ? table(["run", "when", "result", "cells", "best decode"], this.#history.slice(0, 8).map(entry => [
        entry.profile, entry.startedAt.replace("T", " ").slice(0, 16), h("span", { class: entry.complete ? "good" : "bad" }, entry.complete ? "complete" : "incomplete"),
        String(entry.cells.filter(cell => cell.status === "measured").length), rate(Math.max(0, ...entry.cells.map(cell => cell.decodeTokensPerSecond ?? 0)) || null)]))
        : h("p", { class: "note" }, "No finished runs yet.")));
    this.#bench.replaceChildren(root);
  }
}

if (typeof customElements !== "undefined" && !customElements.get(TAG)) customElements.define(TAG, MetricsPanel);

export { MetricsPanel };
