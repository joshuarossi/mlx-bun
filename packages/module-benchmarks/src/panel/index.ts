// `<mlx-benchmarks-panel>`: the module's web panel as one self-contained custom element. It imports only its data
// protocol (types), its own style file and the web kit, draws into its own shadow root and reaches the backend only
// through `connection`, so any host (the web shell, a native webview) mounts it the same way: create the element, set
// `connection`, append it.
//
// Three cards over the module's routes: Evaluate (the tasks from `tasks`, the model, Run, and the running job from
// `jobs`), History (`runs`, with per-task accuracy) and Compare (`compare`, the runner's paired report). It polls while
// a run is going and stops when its page is left; it does not read the events URL.
import { BASE_CSS, createApi, createDisposer, errorOf, h, percent, shadowStyles, type Api, type Child, type Disposer } from "@mlx-bun/web-kit";
import type { BenchmarkComparison, BenchmarkJob, BenchmarkTask, BenchmarkTasks, EvalHistoryEntry, PanelConnection } from "../protocol";
import { STYLE } from "./style";

const TAG = "mlx-benchmarks-panel";
const POLL_MS = 5000;

const accuracy = (value: number | null | undefined): string => percent(value, 2);
const delta = (value: number | null): string => value === null ? "—" : `${value >= 0 ? "+" : ""}${(value * 100).toFixed(2)} pts`;
const active = (job: BenchmarkJob) => job.status === "queued" || job.status === "running";
const runnable = (task: BenchmarkTask) => task.datasets.every(dataset => dataset.present);

function section(title: string, count: string | null, ...children: Child[]): HTMLElement {
  return h("section", { class: "section" }, h("h3", { class: "section-title" }, title, count ? h("span", { class: "count" }, count) : null), ...children);
}

/** A table whose first `textColumns` columns read left and the rest are right-aligned numbers. */
function table(head: readonly string[], rows: readonly (readonly Child[])[], textColumns = 1): HTMLElement {
  const cls = (index: number) => index < textColumns ? (index === 0 ? "name" : undefined) : "num";
  return h("div", { class: "table-wrap" }, h("table", { class: "table" },
    h("thead", {}, h("tr", {}, ...head.map((name, index) => h("th", { class: index < textColumns ? undefined : "num", scope: "col" }, name)))),
    h("tbody", {}, ...rows.map(row => h("tr", {}, ...row.map((cell, index) => h("td", { class: cls(index) }, cell)))))));
}

const failure = (lead: string, message: string, ...actions: HTMLElement[]) =>
  h("div", { class: "notice bad", role: "alert" }, h("span", {}, h("b", {}, lead), " ", message), actions.length ? h("span", { class: "actions" }, ...actions) : null);

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class BenchmarksPanel extends Base {
  #connection: PanelConnection | undefined;
  #api: Api | undefined;
  #shadow: ShadowRoot;
  #root = h("div");
  /** Stops the poll; replaced on every start. */
  #disposer: Disposer | undefined;
  #tasks: BenchmarkTasks | undefined;
  #history: readonly EvalHistoryEntry[] = [];
  #jobs: readonly BenchmarkJob[] = [];
  #comparison: BenchmarkComparison | undefined;
  /** Why the last load failed, why the last start and the last comparison were refused; each clears when it next succeeds. */
  #loadProblem = "";
  #startProblem = "";
  #compareProblem = "";
  /** What the user has chosen; kept across redraws. */
  #chosen = new Set<string>();
  #model = "";
  #base = "";
  #candidate = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    this.#shadow.append(shadowStyles(STYLE, BASE_CSS), this.#root);
  }

  get connection(): PanelConnection | undefined { return this.#connection; }
  set connection(value: PanelConnection | undefined) {
    this.#connection = value;
    if (this.isConnected) { this.#stop(); this.#start(); }
  }

  connectedCallback() { if (this.#connection) this.#start(); else this.#render(); }
  disconnectedCallback() { this.#stop(); }

  #start() {
    const connection = this.#connection;
    if (!connection) { this.#render(); return; }
    this.#api = createApi(connection.apiBase);
    const disposer = createDisposer();
    this.#disposer = disposer;
    const timer = setInterval(() => { if (this.#jobs.some(active)) void this.refresh(); }, POLL_MS);
    disposer.add(() => clearInterval(timer));
    void this.refresh();
    this.#render();
  }

  #stop() {
    this.#disposer?.dispose();
    this.#disposer = undefined;
    this.#api = undefined;
  }

  /** Reloads the tasks, recent jobs and the run history. */
  async refresh(): Promise<void> {
    const api = this.#api;
    if (!api) return;
    const [tasks, history, jobs] = await Promise.all([
      api.get<Partial<BenchmarkTasks>>("tasks"),
      api.get<{ runs?: EvalHistoryEntry[] }>("runs"),
      api.get<{ jobs?: BenchmarkJob[] }>("jobs"),
    ]);
    if (api !== this.#api) return; // the connection changed or the panel left its page meanwhile
    const failed = [tasks, history, jobs].find(answer => answer.ok === false);
    if (failed) this.#loadProblem = errorOf(failed);
    else {
      this.#tasks = { tasks: tasks.tasks ?? [], dataDirectory: tasks.dataDirectory ?? "" };
      this.#history = history.runs ?? [];
      this.#jobs = jobs.jobs ?? [];
      this.#loadProblem = "";
    }
    this.#render();
  }

  async #launch() {
    const api = this.#api;
    const tasks = [...this.#chosen];
    if (!api || !tasks.length) return;
    const answer = await api.post("runs", { tasks, ...(this.#model ? { model: this.#model } : {}) });
    this.#startProblem = answer.ok === false ? errorOf(answer, "the server refused the run") : "";
    await this.refresh();
  }

  async #compare() {
    const api = this.#api;
    if (!api || !this.#base || !this.#candidate) return;
    const answer = await api.get<BenchmarkComparison>(`compare?base=${encodeURIComponent(this.#base)}&candidate=${encodeURIComponent(this.#candidate)}`);
    this.#compareProblem = answer.ok === false ? errorOf(answer, "the runner could not compare them") : "";
    this.#comparison = answer.ok === false ? undefined : answer;
    this.#render();
  }

  #render() {
    const root = h("div");
    if (this.#loadProblem) {
      const retry = h("button", { class: "btn sm", type: "button" }, "Retry");
      retry.addEventListener("click", () => { void this.refresh(); });
      root.append(h("div", { class: "load-notice" }, failure("Could not load the benchmarks:", this.#loadProblem, retry)));
    } else if (!this.#connection) root.append(h("p", { class: "card-note load-notice" }, "Not connected to a server yet."));
    root.append(this.#evaluate(), this.#historySection());
    if (this.#history.length > 1) root.append(this.#compareSection());
    this.#root.replaceWith(root);
    this.#root = root;
  }

  #evaluate(): HTMLElement {
    const running = this.#jobs.find(active);
    const tasks = this.#tasks?.tasks ?? [];
    const directory = this.#tasks?.dataDirectory || "the module's data directory";
    const run = h("button", { class: "btn primary", type: "button" }, "Run");
    const sync = () => { run.disabled = !!running || !tasks.length || !this.#chosen.size; };
    run.addEventListener("click", () => { void this.#launch(); });

    let list: HTMLElement;
    if (!this.#tasks) {
      list = h("div", { class: "tasks loading", "aria-hidden": "true" }, h("span", { class: "skeleton" }), h("span", { class: "skeleton" }), h("span", { class: "skeleton" }));
    } else if (!tasks.length) {
      list = h("p", { class: "card-note" }, "The runner lists no tasks yet.");
    } else {
      list = h("div", { class: "tasks", role: "group", "aria-label": "Tasks to evaluate" }, ...tasks.map(task => {
        const box = h("input", { type: "checkbox", disabled: !runnable(task) });
        box.checked = this.#chosen.has(task.id) && runnable(task);
        box.addEventListener("change", () => { if (box.checked) this.#chosen.add(task.id); else this.#chosen.delete(task.id); sync(); });
        const missing = task.datasets.filter(dataset => !dataset.present).map(dataset => dataset.name);
        const reason = missing.length ? `Dataset missing: ${missing.join(", ")}` : task.needsVerifier ? "Needs the Docker verifier" : "";
        return h("label", { class: missing.length ? "check task unavailable" : "check task",
          title: missing.length ? `missing in ${this.#tasks?.dataDirectory}: ${missing.join(", ")}` : task.needsVerifier ? "needs the Docker verifier" : undefined },
        box, h("span", { class: "task-main" }, h("span", { class: "task-name" }, task.id), reason ? h("span", { class: "hint" }, reason) : null));
      }));
    }
    sync();

    const model = h("input", { class: "input", type: "text", id: "model", placeholder: "The served model", autocomplete: "off", spellcheck: "false" });
    model.value = this.#model;
    model.addEventListener("input", () => { this.#model = model.value; });

    let job: HTMLElement | null = null;
    if (running) {
      const fill = h("i");
      const fraction = Math.max(0, Math.min(1, running.progress));
      fill.style.width = `${fraction * 100}%`;
      job = h("div", { class: "job", role: "status" },
        h("div", { class: "progress", role: "progressbar", "aria-label": "Evaluation progress", "aria-valuemin": 0, "aria-valuemax": 100, "aria-valuenow": Math.round(fraction * 100) }, fill),
        h("div", { class: "progress-meta" }, h("span", {}, running.message ?? "Starting…"), h("span", {}, `${running.status} ${(fraction * 100).toFixed(0)}%`)));
    }

    return section("Evaluate", null, h("div", { class: "card evaluate" },
      list,
      h("div", { class: "field run-field" }, h("label", { for: "model" }, "Model"),
        h("div", { class: "row" }, model, run),
        h("span", { class: "hint" }, "A local model id or a search; leave it empty to evaluate the served model.")),
      job,
      this.#startProblem ? failure("The run did not start:", this.#startProblem) : null,
      h("p", { class: "card-note" }, `A run takes the GPU exclusively until it ends. Datasets must already be in ${directory}; nothing is downloaded.`)));
  }

  #historySection(): HTMLElement {
    if (!this.#history.length) return section("History", null, h("div", { class: "empty" }, this.#tasks ? "No finished runs yet." : "Loading the run history…"));
    const names = [...new Set(this.#history.flatMap(entry => entry.tasks.map(task => task.task)))];
    return section("History", String(this.#history.length), h("div", { class: "card table-card" },
      table(["run", "when", "model", "result", ...names], this.#history.slice(0, 10).map(entry => [
        entry.id, entry.startedAt.replace("T", " ").slice(0, 16), entry.model.repo ?? entry.model.path.split("/").at(-1) ?? "",
        h("span", { class: entry.complete ? "tag ok" : "tag bad", title: entry.problems.join("; ") || undefined }, entry.complete ? "complete" : "incomplete"),
        ...names.map(name => accuracy(entry.tasks.find(task => task.task === name)?.accuracy))]), 4)));
  }

  #compareSection(): HTMLElement {
    const button = h("button", { class: "btn", type: "button" }, "Compare");
    const sync = () => { button.disabled = !this.#base || !this.#candidate; };
    const pick = (id: string, label: string, current: string, apply: (value: string) => void) => {
      const select = h("select", { class: "select", id }, h("option", { value: "" }, "Choose a run"),
        ...this.#history.map(entry => h("option", { value: entry.id }, entry.label && entry.label !== entry.id ? `${entry.id} · ${entry.label}` : entry.id)));
      select.value = current;
      select.addEventListener("change", () => { apply(select.value); sync(); });
      return h("div", { class: "field" }, h("label", { for: id }, label), select);
    };
    button.addEventListener("click", () => { void this.#compare(); });
    sync();
    const result = this.#comparison;
    return section("Compare", null, h("div", { class: "card" },
      h("div", { class: "compare-row" }, pick("base", "Base run", this.#base, value => { this.#base = value; }),
        pick("candidate", "Candidate run", this.#candidate, value => { this.#candidate = value; }), button),
      this.#compareProblem ? failure("Could not compare these runs:", this.#compareProblem) : null,
      result ? h("div", { class: "compare-result" },
        h("div", { class: result.comparable ? "notice ok" : "notice warn", role: "status" }, result.comparable
          ? "Complete and comparable: no differences flagged."
          : "Differences or problems flagged; the runner's report follows."),
        table(["task", "base", "candidate", "difference"], result.tasks.map(task => [task.task, accuracy(task.base), accuracy(task.candidate), delta(task.delta)])),
        h("pre", { class: "log" }, result.markdown)) : null));
  }
}

if (typeof customElements !== "undefined" && !customElements.get(TAG)) customElements.define(TAG, BenchmarksPanel);

export { BenchmarksPanel };
