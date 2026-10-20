// `<mlx-metrics-panel>`: the module's web panel as one self-contained custom element. It imports only its data protocol
// (types), its own render and style files and the web kit, draws into its own shadow root and reaches the backend only
// through `connection`, so any host (the web shell, a native webview) mounts it the same way: create the element, set
// `connection`, append it.
//
// Two parts: the live view follows the snapshot stream (`eventsUrl`) and redraws on every snapshot; the benchmark card
// lists the bench-serve plans, the running job and the history (`bench/profiles`, `bench`, `history`), polls while a run
// is going and redraws only when its data changes, so an open menu survives the stream. Leaving the page closes the
// stream and stops the poll.
import { BASE_CSS, createApi, createDisposer, errorOf, h, openEventStream, shadowStyles, type Api, type Disposer } from "@mlx-bun/web-kit";
import type { BenchHistoryEntry, BenchJob, BenchProfile, MetricsSnapshot, PanelConnection } from "../protocol";
import { benchHistoryTable, liveSections, section, waitingSections } from "./render";
import { STYLE } from "./style";

const TAG = "mlx-metrics-panel";
const POLL_MS = 5000;
const DROPPED = "The metrics stream dropped; reconnecting…";
const UNREADABLE = "A snapshot could not be read; showing the last good one.";

const isSnapshot = (data: unknown): data is MetricsSnapshot => {
  const value = data as Partial<MetricsSnapshot> | null;
  return !!value && typeof value === "object" && Array.isArray(value.series) && Array.isArray(value.models) && Array.isArray(value.caches) &&
    Array.isArray(value.schedulers) && !!value.requests && typeof value.requests === "object" && !!value.requests.window;
};
const active = (job: BenchJob) => job.status === "queued" || job.status === "running";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

class MetricsPanel extends Base {
  #connection: PanelConnection | undefined;
  #api: Api | undefined;
  #shadow: ShadowRoot;
  #notice = h("div", { class: "notice warn stream-notice", role: "status" });
  #live = h("div");
  #bench = h("div");
  /** Closes the stream and stops the poll; replaced on every start. */
  #disposer: Disposer | undefined;
  #snapshot: MetricsSnapshot | undefined;
  #history: readonly BenchHistoryEntry[] = [];
  #profiles: readonly BenchProfile[] = [];
  #jobs: readonly BenchJob[] = [];
  #streamProblem = "";
  /** Why the benchmark data could not load, and why the last run did not start; each clears when it next succeeds. */
  #loadProblem = "";
  #startProblem = "";
  #chosen = "";

  constructor() {
    super();
    this.#shadow = this.attachShadow({ mode: "open" });
    this.#shadow.append(shadowStyles(STYLE, BASE_CSS), this.#notice, this.#live, this.#bench);
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
    const disposer = createDisposer();
    this.#disposer = disposer;
    this.#api = createApi(connection.apiBase);
    const stream = openEventStream(connection.eventsUrl, {
      events: {
        snapshot: data => {
          if (isSnapshot(data)) { this.#snapshot = data; this.#streamProblem = ""; }
          else this.#streamProblem = UNREADABLE;
          this.#render();
        },
      },
      error: () => { this.#streamProblem = DROPPED; this.#renderNotice(); },
    }, { endEvent: null });
    disposer.add(() => stream.close());
    const timer = setInterval(() => { if (this.#jobs.some(active)) void this.refreshBench(); }, POLL_MS);
    disposer.add(() => clearInterval(timer));
    void this.refreshBench();
    this.#render();
    this.#renderBench();
  }

  #stop() {
    this.#disposer?.dispose();
    this.#disposer = undefined;
    this.#api = undefined;
  }

  /** Reloads the plans, the recent jobs and the run history. */
  async refreshBench(): Promise<void> {
    const api = this.#api;
    if (!api) return;
    const [history, profiles, jobs] = await Promise.all([
      api.get<{ runs?: BenchHistoryEntry[] }>("history"),
      api.get<{ profiles?: BenchProfile[] }>("bench/profiles"),
      api.get<{ jobs?: BenchJob[] }>("bench"),
    ]);
    if (api !== this.#api) return; // the connection changed or the panel left its page meanwhile
    if (history.ok !== false) this.#history = history.runs ?? [];
    if (profiles.ok !== false) this.#profiles = profiles.profiles ?? [];
    if (jobs.ok !== false) this.#jobs = jobs.jobs ?? [];
    const failed = [history, profiles, jobs].find(answer => answer.ok === false);
    this.#loadProblem = failed ? errorOf(failed) : "";
    this.#renderBench();
  }

  async #launch(button: HTMLButtonElement) {
    const api = this.#api;
    const profile = this.#chosen || this.#profiles[0]?.name;
    if (!api || !profile) return;
    button.disabled = true;
    const answer = await api.post("bench", { profile });
    this.#startProblem = answer.ok === false ? errorOf(answer, "the server refused the run") : "";
    await this.refreshBench();
    this.#renderBench();
  }

  #renderNotice() {
    this.#notice.textContent = this.#streamProblem;
  }

  #render() {
    this.#renderNotice();
    const snapshot = this.#snapshot;
    this.#live.replaceChildren(snapshot ? liveSections(snapshot) : waitingSections(!!this.#connection));
  }

  #renderBench() {
    const running = this.#jobs.find(active);
    const card = h("div", { class: "card bench" });
    if (this.#profiles.length) {
      const select = h("select", { class: "select", "aria-label": "Benchmark plan" },
        ...this.#profiles.map(profile => h("option", { value: profile.name }, `${profile.name}${profile.scope ? ` (${profile.scope})` : ""}`)));
      if (this.#chosen) select.value = this.#chosen;
      select.addEventListener("change", () => { this.#chosen = select.value; });
      const run = h("button", { class: "btn primary", type: "button", disabled: !!running }, "Run benchmark");
      run.addEventListener("click", () => { void this.#launch(run); });
      card.append(h("div", { class: "row bench-controls" }, select, run,
        running ? h("span", { class: "tag accent bench-job", title: running.message ?? undefined },
          h("span", { class: "dot accent" }), h("span", { class: "text" }, `${running.status}: ${running.message ?? ""}`)) : null));
      card.append(h("p", { class: "card-note" }, "A run takes the GPU exclusively until it ends."));
    } else {
      card.append(h("p", { class: "card-note" }, "No benchmark plans yet. Create one with ", h("code", {}, "scripts/bench-serve.ts plan"),
        " and save it as a JSON file in ", h("code", {}, "~/.mlx-bun/metrics/bench/plans"), "."));
    }
    if (this.#startProblem) card.append(h("div", { class: "notice bad", role: "alert" }, h("span", {}, h("b", {}, "The run did not start: "), this.#startProblem)));
    if (this.#loadProblem) {
      const retry = h("button", { class: "btn sm", type: "button" }, "Retry");
      retry.addEventListener("click", () => { void this.refreshBench(); });
      card.append(h("div", { class: "notice bad", role: "alert" },
        h("span", {}, h("b", {}, "Could not load the benchmark plans and history: "), this.#loadProblem), h("span", { class: "actions" }, retry)));
    }
    card.append(h("div", { class: "bench-history" }, h("div", { class: "subhead" }, "Recent runs"),
      this.#history.length ? benchHistoryTable(this.#history) : h("p", { class: "card-note" }, "No finished runs yet.")));
    this.#bench.replaceChildren(section("Benchmark", null, card));
  }
}

if (typeof customElements !== "undefined" && !customElements.get(TAG)) customElements.define(TAG, MetricsPanel);

export { MetricsPanel };
