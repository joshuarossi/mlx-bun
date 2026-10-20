// The dataset wizard's state and orchestration: the four steps, the template grid, the chosen template's typed inputs,
// submission and the job's event stream. Requests go through the kit's client; the job stream through the kit's
// event-stream client. Leaving the page closes the stream (the job keeps running on the server); returning while the job
// is unfinished reopens it, and the server replays the job's events from its first one, so the log restarts with each
// connection.
import { $, byType, createApi, createDisposer, errorOf, listen, num, openEventStream, type EventStream } from "@mlx-bun/web-kit";
import type { JobEvent, PanelConnection } from "../protocol";
import {
  DONE, INPUTS, RUN, STEPS, TEMPLATE, TEMPLATES_EMPTY, TEMPLATES_LOADING, failureHtml, fieldsHtml, stepsHtml, templatesFailedHtml, templatesHtml,
  type DatasetTemplate,
} from "./view";

export interface PanelController {
  /** Once, on the first connection: the first step and the template grid. */
  init(): void;
  /** On every connection: binds the listeners and reopens the stream of an unfinished job. */
  enter(): void;
  /** On every disconnection: removes the listeners and closes the stream without cancelling the job. */
  leave(): void;
}

/** The server root a module base sits under (`https://host/prefix/api/datasets` is `https://host/prefix`). The wizard's
 * routes keep their shipped root paths (`/api/dataset/*`), so they resolve under the same prefix as the module's base. */
const serverRoot = (apiBase: string): string => apiBase.replace(/\/api\/[^/]*\/?$/, "");
const LOG_LINES = 200;

export function createDatasetController(root: ShadowRoot, connection: () => PanelConnection): PanelController {
  const part = <T extends HTMLElement = HTMLElement>(id: string): T => $(id, root) as T;
  const api = () => createApi(serverRoot(connection().apiBase));
  const disposer = createDisposer();
  let active = false, templates: DatasetTemplate[] = [], selected: DatasetTemplate | null = null;
  let jobId: string | null = null, terminal = false, stream: EventStream | null = null, dropped = false, log: string[] = [];

  /** The host's notification, or the panel's own status line in a host without one. */
  function notify(message: string, kind: "ok" | "err" = "ok"): void {
    const ui = connection().ui;
    if (ui?.notify) { ui.notify(message, kind); return; }
    const line = part("panel-message");
    line.textContent = message;
    line.className = "notice " + (kind === "err" ? "bad" : "ok");
    line.dataset.kind = kind;
  }

  function show(n: number, failed = false): void {
    for (const card of root.querySelectorAll<HTMLElement>("[data-dstep]")) card.hidden = Number(card.dataset.dstep) !== n;
    part("d-steps").innerHTML = stepsHtml(STEPS, n, failed);
  }

  async function loadTemplates(): Promise<void> {
    const grid = part("d-templates");
    grid.setAttribute("aria-busy", "true");
    grid.innerHTML = TEMPLATES_LOADING;
    const answer = await api().get<{ templates?: DatasetTemplate[] }>("api/dataset/templates");
    grid.removeAttribute("aria-busy");
    if (answer.ok === false) { templates = []; grid.innerHTML = templatesFailedHtml(errorOf(answer, "The server gave no reason.")); return; }
    templates = answer.templates ?? [];
    grid.innerHTML = templates.length ? templatesHtml(templates) : TEMPLATES_EMPTY;
  }

  function selectTemplate(template: DatasetTemplate): void {
    selected = template;
    part("d-form-title").textContent = template.label || template.id;
    part("d-form-desc").textContent = template.description || "";
    const note = part("d-model-note");
    const model = template.needs_llm ? connection().ui?.modelId?.() : undefined;
    note.hidden = !template.needs_llm;
    note.textContent = model ? `The served model, ${model}, writes the rows.` : "The model this server serves writes the rows.";
    part("d-form").innerHTML = fieldsHtml(template.fields ?? []);
    part("d-submit-out").innerHTML = "";
    show(INPUTS);
  }

  function progress(fraction: number | null | undefined, message?: string): void {
    if (fraction != null) {
      const percent = Math.round(fraction * 100);
      part("d-bar").style.width = percent + "%";
      part("d-pct").textContent = percent + "%";
      part("d-bar").parentElement!.setAttribute("aria-valuenow", String(percent));
    }
    if (message) part("d-msg").textContent = message;
  }

  function counts(event: { n_train?: unknown; n_valid?: unknown }): void {
    if (typeof event.n_train === "number") part("d-ntrain").textContent = num(event.n_train);
    if (typeof event.n_valid === "number") part("d-nvalid").textContent = num(event.n_valid);
  }

  function clearLog(): void { log = []; part("d-log").textContent = ""; }

  function reconnecting(on: boolean): void { part("d-reconnect").hidden = !on; }

  async function submit(): Promise<void> {
    if (!selected) return;
    const inputs: Record<string, unknown> = {};
    for (const field of part("d-form").querySelectorAll<HTMLInputElement | HTMLTextAreaElement>("[data-fld]")) {
      inputs[field.dataset.fld!] = field.type === "number" ? (field.value === "" ? null : Number(field.value)) : field.value;
    }
    const body: Record<string, unknown> = { template_id: selected.id, inputs };
    const modelId = connection().ui?.modelId?.();
    if (selected.needs_llm && modelId) body.model_name = modelId;
    const button = part<HTMLButtonElement>("d-submit");
    button.disabled = true;
    part("d-submit-out").innerHTML = "";
    const answer = await api().post("api/dataset/submit", body);
    button.disabled = false;
    if (!answer.ok) { part("d-submit-out").innerHTML = failureHtml("Could not start generating.", errorOf(answer, "The server did not start the job.")); return; }
    jobId = (answer.job_id as string) || null;
    part("d-push-panel").innerHTML = "";
    part("d-out").textContent = (answer.output_dir as string) || "";
    part("d-ntrain").textContent = part("d-nvalid").textContent = "—";
    clearLog();
    part("d-bar").parentElement!.classList.remove("bad");
    part("d-fail").hidden = true;
    reconnecting(false);
    progress(0, "Starting…");
    show(RUN);
    if (jobId) attach(jobId);
  }

  function attach(id: string): void {
    jobId = id; terminal = false;
    if (!active) return;
    stream?.close();
    clearLog();
    dropped = false;
    reconnecting(false);
    const dispatch = byType<JobEvent>({
      log: (event) => {
        log.push(event.line);
        const box = part("d-log");
        box.textContent = log.slice(-LOG_LINES).join("\n");
        box.scrollTop = box.scrollHeight;
      },
      stage: (event) => {
        progress(event.progress, event.message);
        counts(event);
        if (event.stage === "done") { if (event.output_dir) part("d-out").textContent = event.output_dir; finish(); }
      },
      done: (event) => {
        counts(event);
        if (typeof event.output_dir === "string" && event.output_dir) part("d-out").textContent = event.output_dir;
        finish();
      },
      failed: (event) => fail(event.error || "The job reported no reason."),
    });
    stream = openEventStream<JobEvent>(api().url("api/jobs/" + encodeURIComponent(id) + "/stream"), {
      // A reconnection replays the job from its first event.
      open: () => { if (dropped) clearLog(); dropped = false; reconnecting(false); },
      // The browser retries on its own; say so until the next event.
      error: () => { dropped = true; reconnecting(true); },
      message: (event) => { reconnecting(false); dispatch(event); },
      end: () => { if (!terminal) fail("The job's event stream ended before the job reported a result."); },
    });
  }

  function finish(): void {
    if (terminal) return;
    terminal = true;
    stream?.close(); stream = null;
    reconnecting(false);
    progress(1);
    show(DONE);
  }

  function fail(error: string): void {
    if (terminal) return;
    terminal = true;
    stream?.close(); stream = null;
    reconnecting(false);
    part("d-bar").parentElement!.classList.add("bad");
    part("d-msg").textContent = "Failed";
    part("d-fail-msg").textContent = error;
    part("d-fail").hidden = false;
    show(RUN, true);
  }

  function publish(): void {
    const hook = connection().ui?.publish;
    if (hook) void hook(part("d-push-panel"), { kind: "dataset", job_id: jobId || undefined });
    else notify("This host has no publishing interface.", "err");
  }

  function bind(): void {
    const on = (target: EventTarget, type: string, handler: (event: Event) => void) => disposer.add(listen(target, type, handler));
    // The grid's content is replaced as the templates load, so it listens once for its tiles and its reload button.
    on(part("d-templates"), "click", (event) => {
      const target = event.target as Element;
      if (target.closest("[data-reload]")) { void loadTemplates(); return; }
      const tile = target.closest<HTMLElement>("[data-tid]");
      const template = tile && templates.find(item => item.id === tile.dataset.tid);
      if (template) selectTemplate(template);
    });
    for (const back of root.querySelectorAll<HTMLElement>("[data-dback]")) on(back, "click", () => show(TEMPLATE));
    on(part("d-submit"), "click", () => { void submit(); });
    on(part("d-retry"), "click", () => show(INPUTS));
    on(part("d-push"), "click", publish);
    on(part("d-again"), "click", () => { selected = null; part("d-push-panel").innerHTML = ""; show(TEMPLATE); });
    disposer.add(() => { stream?.close(); stream = null; });
  }

  return {
    init() { show(TEMPLATE); void loadTemplates(); },
    enter() {
      active = true;
      bind();
      if (jobId && !terminal) attach(jobId);
    },
    leave() {
      active = false;
      disposer.dispose();
    },
  };
}
