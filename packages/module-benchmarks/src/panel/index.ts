// `<mlx-benchmarks-panel>`: the module's web panel as one self-contained custom
// element. It imports only its data protocol (types), draws into its own
// shadow root and reaches the backend only through `connection`, so any host
// (the web shell, a native webview) mounts it the same way: create the element,
// set `connection`, append it.
import type { BenchmarkComparison, BenchmarkJob, BenchmarkTasks, EvalHistoryEntry, PanelConnection } from "../protocol";

const TAG = "mlx-benchmarks-panel";

const STYLE = `
:host { display: block; color: var(--text, CanvasText); font: 14px/1.45 system-ui, sans-serif; }
section { margin: 0 0 18px; }
h3 { margin: 0 0 6px; font-size: 13px; letter-spacing: .04em; text-transform: uppercase; color: var(--dim, GrayText); }
table { border-collapse: collapse; width: 100%; font-variant-numeric: tabular-nums; }
th, td { text-align: left; padding: 3px 10px 3px 0; border-bottom: 1px solid var(--line, #8883); white-space: nowrap; }
th { font-weight: 600; color: var(--dim, GrayText); font-size: 12px; }
td.num, th.num { text-align: right; }
.bad { color: var(--red, #dc2626); } .good { color: var(--green, #16a34a); }
button, select, input { font: inherit; }
.note { color: var(--dim, GrayText); font-size: 12px; }
.row { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin: 6px 0; }
label { display: inline-flex; gap: 4px; align-items: center; }
pre { max-height: 260px; overflow: auto; font-size: 12px; white-space: pre-wrap; }
`;

const percent = (value: number | null | undefined): string => value === null || value === undefined ? "—" : `${(value * 100).toFixed(2)}%`;
const delta = (value: number | null): string => value === null ? "—" : `${value >= 0 ? "+" : ""}${(value * 100).toFixed(2)} pts`;

type Child = Node | string | null | undefined | false;
function h<K extends keyof HTMLElementTagNameMap>(tag: K, attributes: Record<string, string> = {}, ...children: Child[]): HTMLElementTagNameMap[K] {
  const element = document.createElement(tag);
  for (const [name, value] of Object.entries(attributes)) element.setAttribute(name, value);
  for (const child of children) if (child) element.append(child);
  return element;
}
function table(head: readonly string[], rows: readonly (readonly (string | Node)[])[]): HTMLElement {
  return h("table", {}, h("thead", {}, h("tr", {}, ...head.map((name, index) => h("th", index ? { class: "num" } : {}, name)))),
    h("tbody", {}, ...rows.map(row => h("tr", {}, ...row.map((cell, index) => h("td", index ? { class: "num" } : {}, cell))))));
}

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class BenchmarksPanel extends Base {
  #connection: PanelConnection | undefined;
  #shadow: ShadowRoot;
  #root = h("div");
  #timer: ReturnType<typeof setInterval> | undefined;
  #tasks: BenchmarkTasks | undefined;
  #history: readonly EvalHistoryEntry[] = [];
  #jobs: readonly BenchmarkJob[] = [];
  #comparison: BenchmarkComparison | undefined;
  /** Why the last load failed, and why the last action (start, compare) was refused; each clears when it next succeeds. */
  #loadError = "";
  #actionError = "";
  /** What the user has chosen; kept across redraws. */
  #chosen = new Set<string>();
  #model = "";
  #base = "";
  #candidate = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    this.#shadow.append(h("style", {}, STYLE), this.#root);
  }

  get connection(): PanelConnection | undefined { return this.#connection; }
  set connection(value: PanelConnection | undefined) {
    this.#connection = value;
    if (this.isConnected) { this.#stop(); this.#start(); }
  }

  connectedCallback() { if (this.#connection) this.#start(); else this.#render(); }
  disconnectedCallback() { this.#stop(); }

  #start() {
    void this.refresh();
    this.#timer = setInterval(() => { if (this.#jobs.some(job => job.status === "queued" || job.status === "running")) void this.refresh(); }, 5000);
    this.#render();
  }

  #stop() {
    if (this.#timer !== undefined) clearInterval(this.#timer);
    this.#timer = undefined;
  }

  /** Reloads the tasks, recent jobs and the run history. */
  async refresh(): Promise<void> {
    const base = this.#connection?.apiBase;
    if (base === undefined) return;
    try {
      const [tasks, history, jobs] = await Promise.all(["/tasks", "/runs", "/jobs"].map(path => fetch(base + path).then(async response => {
        if (!response.ok) throw new Error(((await response.json().catch(() => null)) as { error?: { message?: string } } | null)?.error?.message ?? `${path} answered ${response.status}`);
        return response.json();
      })));
      this.#tasks = tasks; this.#history = history.runs ?? []; this.#jobs = jobs.jobs ?? []; this.#loadError = "";
    } catch (failure) { this.#loadError = failure instanceof Error ? failure.message : String(failure); }
    this.#render();
  }

  async #launch() {
    const base = this.#connection!.apiBase;
    const tasks = [...this.#chosen];
    if (!tasks.length) return;
    const response = await fetch(`${base}/runs`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ tasks, ...(this.#model ? { model: this.#model } : {}) }) });
    this.#actionError = response.ok ? "" : ((await response.json().catch(() => null))?.error?.message ?? `could not start the run (${response.status})`);
    await this.refresh();
  }

  async #compare() {
    if (!this.#base || !this.#candidate) return;
    const response = await fetch(`${this.#connection!.apiBase}/compare?base=${encodeURIComponent(this.#base)}&candidate=${encodeURIComponent(this.#candidate)}`);
    const body = await response.json().catch(() => null);
    this.#actionError = response.ok ? "" : (body?.error?.message ?? `could not compare (${response.status})`);
    this.#comparison = response.ok ? body : undefined;
    this.#render();
  }

  #render() {
    const root = h("div");
    const running = this.#jobs.find(job => job.status === "queued" || job.status === "running");
    const problem = this.#actionError || this.#loadError;
    root.append(h("p", { class: problem ? "note bad" : "note" }, problem || (this.#connection ? "" : "No connection set.")));

    const tasks = this.#tasks?.tasks ?? [];
    const runnable = (task: BenchmarkTasks["tasks"][number]) => task.datasets.every(dataset => dataset.present);
    const boxes = tasks.map(task => {
      const box = h("input", { type: "checkbox" });
      box.checked = this.#chosen.has(task.id);
      if (!runnable(task)) box.setAttribute("disabled", "");
      box.addEventListener("change", () => { if (box.checked) this.#chosen.add(task.id); else this.#chosen.delete(task.id); });
      const missing = task.datasets.filter(dataset => !dataset.present).map(dataset => dataset.name);
      return h("label", { title: missing.length ? `missing in ${this.#tasks?.dataDirectory}: ${missing.join(", ")}` : task.needsVerifier ? "needs the Docker verifier" : "" }, box, task.id);
    });
    const model = h("input", { type: "text", placeholder: "served model", size: "28" });
    model.value = this.#model;
    model.addEventListener("input", () => { this.#model = model.value; });
    const run = h("button", {}, "Run");
    run.addEventListener("click", () => { void this.#launch(); });
    if (running || !tasks.length) run.setAttribute("disabled", "");
    root.append(h("section", {}, h("h3", {}, "Evaluate"),
      tasks.length ? h("div", { class: "row" }, ...boxes) : h("p", { class: "note" }, "No task list yet."),
      h("div", { class: "row" }, model, run, running ? h("span", { class: "note" }, `${running.status} ${(running.progress * 100).toFixed(0)}%: ${running.message ?? ""}`) : null),
      h("p", { class: "note" }, `A run takes the GPU exclusively until it ends. Datasets must already be in ${this.#tasks?.dataDirectory ?? "the module's data directory"}; nothing is downloaded.`)));

    const names = [...new Set(this.#history.flatMap(entry => entry.tasks.map(task => task.task)))];
    root.append(h("section", {}, h("h3", {}, "History"),
      this.#history.length ? table(["run", "when", "model", "result", ...names], this.#history.slice(0, 10).map(entry => [
        entry.id, entry.startedAt.replace("T", " ").slice(0, 16), entry.model.repo ?? entry.model.path.split("/").at(-1) ?? "",
        h("span", { class: entry.complete ? "good" : "bad" }, entry.complete ? "complete" : "incomplete"),
        ...names.map(name => percent(entry.tasks.find(task => task.task === name)?.accuracy))]))
        : h("p", { class: "note" }, "No finished runs yet.")));

    if (this.#history.length > 1) {
      const pick = (current: string, apply: (id: string) => void) => {
        const select = h("select", {}, h("option", { value: "" }, "choose a run"), ...this.#history.map(entry => h("option", { value: entry.id }, entry.id)));
        select.value = current;
        select.addEventListener("change", () => apply(select.value));
        return select;
      };
      const compare = h("button", {}, "Compare");
      compare.addEventListener("click", () => { void this.#compare(); });
      const result = this.#comparison;
      root.append(h("section", {}, h("h3", {}, "Compare"),
        h("div", { class: "row" }, pick(this.#base, id => { this.#base = id; }), "against", pick(this.#candidate, id => { this.#candidate = id; }), compare),
        result ? h("div", {}, h("p", { class: result.comparable ? "note good" : "note bad" }, result.comparable ? "Complete and comparable: no differences flagged." : "Differences or problems flagged; the runner's report follows."),
          table(["task", "base", "candidate", "difference"], result.tasks.map(task => [task.task, percent(task.base), percent(task.candidate), delta(task.delta)])),
          h("pre", {}, result.markdown)) : null));
    }
    this.#root.replaceWith(root);
    this.#root = root;
  }
}

if (typeof customElements !== "undefined" && !customElements.get(TAG)) customElements.define(TAG, BenchmarksPanel);

export { BenchmarksPanel };
