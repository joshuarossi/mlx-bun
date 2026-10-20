// The fine-tune wizard's state and orchestration: the five steps, dataset inspection, the hyperparameters, submission,
// the job's event stream with its loss chart, and the done step's merge, export and publish actions. Requests go
// through the kit's client; the job stream through the kit's event-stream client. Leaving the page closes the stream
// (the job keeps running on the server); returning while the job is unfinished reopens it, and the server replays the
// job's events from its first one, so the log and the chart restart with each connection.
import { $, byType, createApi, createDisposer, emitHostEvent, errorOf, HOST_EVENTS, listen, num, openEventStream, type EventStream } from "@mlx-bun/web-kit";
import type { JobEvent, PanelConnection } from "../protocol";
import { BASE, CONFIGURE, DATASET, DONE, METHOD_HINT, RUN, STEPS, chartSvg, datasetHtml, failureHtml, railStep, stepsHtml, writtenHtml, type LossPoint, type Method, type WizardStep } from "./view";

// The File System Access API's showDirectoryPicker() is not in every lib.dom yet; declare it loosely rather than widen
// the global Window type project-wide.
declare global {
  interface Window {
    showDirectoryPicker?: (opts?: { id?: string; mode?: string }) => Promise<{ name: string }>;
  }
}
interface FileWithRelPath extends File {
  webkitRelativePath: string;
}

export interface PanelController {
  /** Once, on the first connection: the first step. */
  init(): void;
  /** On every connection: binds the listeners and reopens the stream of an unfinished job. */
  enter(): void;
  /** On every disconnection: removes the listeners and closes the stream without cancelling the job. */
  leave(): void;
  /** The rail's current step, or null before the first step is shown. */
  currentStep(): WizardStep | null;
}

/** The server root a module base sits under (`https://host/prefix/api/train` is `https://host/prefix`). The wizard's
 * routes keep their shipped root paths (`/api/finetune/*`, `/api/model/resolve-folder`), so they resolve under the same
 * prefix as the module's base. */
const serverRoot = (apiBase: string): string => apiBase.replace(/\/api\/[^/]*\/?$/, "");
const LOG_LINES = 200;
const DEFAULT_LR: Readonly<Record<Method, number>> = { sft: 0.0002, dpo: 0.00005, orpo: 0.00001 };

export function createFinetuneController(root: ShadowRoot, connection: () => PanelConnection): PanelController {
  const part = <T extends HTMLElement = HTMLElement>(id: string): T => $(id, root) as T;
  const input = (id: string) => part<HTMLInputElement>(id);
  const api = () => createApi(serverRoot(connection().apiBase));
  const disposer = createDisposer();
  let active = false, step = BASE;
  let method: Method = "sft", lrTouched = false, rankTouched = false, datasetOk = false, adapterPath = "";
  let jobId: string | null = null, terminal = false, stream: EventStream | null = null, dropped = false, log: string[] = [];
  const trainPoints: LossPoint[] = [], validPoints: LossPoint[] = [];

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
    step = n;
    for (const card of root.querySelectorAll<HTMLElement>("[data-fstep]")) card.hidden = Number(card.dataset.fstep) !== n;
    part("f-steps").innerHTML = stepsHtml(STEPS, n, failed);
    // A host that describes the page (the chat assistant) re-reads the step; the event leaves the shadow root.
    emitHostEvent(HOST_EVENTS.panelChanged, undefined, root.host, { bubbles: true, composed: true });
  }

  // The base model's folder picker and drag and drop resolve by the folder's name on the server (no upload; the
  // Hugging Face cache's symlinked layout stays the server's), as the quantize wizard does.
  async function resolveBaseByName(name: string, relPath = ""): Promise<void> {
    if (!name && !relPath) return;
    const out = part("f-base-out");
    out.innerHTML = '<p class="muted"><span class="skeleton">Locating the folder on disk…</span></p>';
    const answer = await api().post("api/model/resolve-folder", { folder_name: name, rel_path: relPath });
    if (!answer.ok) { out.innerHTML = failureHtml("Could not find this folder.", errorOf(answer, "The server could not locate it on disk.")); return; }
    out.innerHTML = "";
    input("f-model").value = answer.path as string;
  }

  async function pickBaseFolder(): Promise<void> {
    if (window.showDirectoryPicker) {
      try { const handle = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" }); return resolveBaseByName(handle.name); }
      catch { return; } // cancelled or denied
    }
    part("f-folder").click(); // browsers without the File System Access API
  }

  function datasetChanged(): void {
    datasetOk = false;
    part<HTMLButtonElement>("f-next1").disabled = true;
    part("f-inspect-out").innerHTML = "";
  }

  async function inspectDataset(): Promise<void> {
    const path = input("f-data").value.trim();
    if (!path) { notify("Enter a dataset directory.", "err"); input("f-data").focus(); return; }
    const out = part("f-inspect-out"), button = part<HTMLButtonElement>("f-inspect");
    out.innerHTML = '<p class="muted"><span class="skeleton">Reading the dataset…</span></p>';
    button.disabled = true;
    const answer = await api().post("api/finetune/inspect-dataset", { path });
    button.disabled = false;
    datasetOk = answer.ok === true;
    part<HTMLButtonElement>("f-next1").disabled = !datasetOk;
    out.innerHTML = datasetHtml(answer);
  }

  function setMethod(next: Method): void {
    method = next;
    for (const button of part("f-method").querySelectorAll<HTMLButtonElement>("button")) {
      button.classList.toggle("on", button.dataset.v === next);
      button.setAttribute("aria-pressed", String(button.dataset.v === next));
    }
    part("f-dpo-extra").hidden = next !== "dpo";
    part("f-orpo-extra").hidden = next !== "orpo";
    part("f-method-hint").textContent = METHOD_HINT[next];
    if (!lrTouched) input("f-lr").value = String(DEFAULT_LR[next]);
    // ORPO's validated LoRA recipe uses rank 16 (8 for SFT and DPO); applied unless edited.
    if (!rankTouched) input("f-rank").value = String(next === "orpo" ? 16 : 8);
  }

  function hyperparameters(): Record<string, unknown> {
    const value = (id: string) => Number(input(id).value);
    const hp: Record<string, unknown> = {
      model_dir: input("f-model").value.trim(),
      data_dir: input("f-data").value.trim(),
      method,
      rank: value("f-rank"), scale: value("f-scale"), lora_dropout: value("f-dropout"),
      target_modules: input("f-modules").value.split(",").map(name => name.trim()).filter(Boolean),
      num_layers: value("f-layers"), iters: value("f-iters"), batch_size: value("f-batch"),
      learning_rate: value("f-lr"), max_seq_length: value("f-seq"),
    };
    if (method === "dpo") { hp.dpo_beta = value("f-beta"); hp.dpo_lr_schedule = part<HTMLSelectElement>("f-sched").value; }
    if (method === "orpo") {
      hp.orpo_lambda = value("f-orpo-lambda"); hp.orpo_lr_schedule = part<HTMLSelectElement>("f-orpo-sched").value;
      // The SFT scope only applies to ORPO's single loss (its SFT term needs a scope); the default matches the
      // control's, "full" (the paper's and TRL's chosen-answer loss).
      hp.sft_scope = part("f-orpo-scope").querySelector<HTMLElement>("button.on")?.dataset.v || "full";
    }
    return hp;
  }

  function progress(fraction: number | null | undefined, message?: string): void {
    if (fraction != null) {
      const percent = Math.round(fraction * 100);
      part("f-bar").style.width = percent + "%";
      part("f-pct").textContent = percent + "%";
      part("f-bar").parentElement!.setAttribute("aria-valuenow", String(percent));
    }
    if (message) part("f-msg").textContent = message;
  }

  function drawChart(): void { part("f-chart").innerHTML = chartSvg(trainPoints, validPoints); }

  /** Forgets what the stream built (the log and the chart): a new connection replays the job from its first event. */
  function clearReplay(): void {
    log = []; part("f-log").textContent = "";
    trainPoints.length = validPoints.length = 0;
    part("f-leg-val").hidden = true;
    drawChart();
  }

  function reconnecting(on: boolean): void { part("f-reconnect").hidden = !on; }

  async function submit(): Promise<void> {
    const button = part<HTMLButtonElement>("f-submit");
    button.disabled = true;
    part("f-submit-out").innerHTML = "";
    const answer = await api().post("api/finetune/submit", hyperparameters());
    button.disabled = false;
    if (!answer.ok) { part("f-submit-out").innerHTML = failureHtml("Could not start training.", errorOf(answer, "The server did not start the job.")); return; }
    adapterPath = (answer.adapter_path as string) || "";
    part("f-out").textContent = adapterPath;
    part("f-merge-out").innerHTML = part("f-exp-out").innerHTML = part("f-push-panel").innerHTML = "";
    clearReplay();
    for (const id of ["f-step", "f-loss", "f-curlr", "f-curtps"]) part(id).textContent = "—";
    part("f-bar").parentElement!.classList.remove("bad");
    part("f-fail").hidden = true;
    reconnecting(false);
    progress(0, "Starting…");
    show(RUN);
    attach(answer.job_id as string);
  }

  function attach(id: string): void {
    jobId = id; terminal = false;
    if (!active) return;
    stream?.close();
    clearReplay();
    dropped = false;
    reconnecting(false);
    const dispatch = byType<JobEvent>({
      log: (event) => {
        log.push(event.line);
        const box = part("f-log");
        box.textContent = log.slice(-LOG_LINES).join("\n");
        box.scrollTop = box.scrollHeight;
      },
      metric: (event) => {
        if (event.kind === "val") { validPoints.push({ step: event.step, loss: event.loss }); part("f-leg-val").hidden = false; }
        else {
          trainPoints.push({ step: event.step, loss: event.loss });
          part("f-step").textContent = num(event.step);
          part("f-loss").textContent = event.loss != null ? event.loss.toFixed(4) : "—";
          if (event.learning_rate != null) part("f-curlr").textContent = event.learning_rate.toExponential(2);
          if (event.tokens_per_sec != null) part("f-curtps").textContent = event.tokens_per_sec.toFixed(1);
          progress(event.progress, event.message);
        }
        drawChart();
      },
      stage: (event) => {
        progress(event.progress, event.message);
        if (event.stage === "done") { if (event.adapter_path) setAdapter(event.adapter_path); finish(); }
      },
      done: (event) => {
        const path = typeof event.adapter_path === "string" ? event.adapter_path : typeof event.output_dir === "string" ? event.output_dir : "";
        if (path) setAdapter(path);
        finish();
      },
      failed: (event) => fail(event.error || "The job reported no reason."),
    });
    stream = openEventStream<JobEvent>(api().url("api/jobs/" + encodeURIComponent(id) + "/stream"), {
      // A reconnection replays the job from its first event.
      open: () => { if (dropped) clearReplay(); dropped = false; reconnecting(false); },
      // The browser retries on its own; say so until the next event.
      error: () => { dropped = true; reconnecting(true); },
      message: (event) => { reconnecting(false); dispatch(event); },
      end: () => { if (!terminal) fail("The job's event stream ended before the job reported a result."); },
    });
  }

  function setAdapter(path: string): void { adapterPath = path; part("f-out").textContent = path; }

  function finish(): void {
    if (terminal) return;
    terminal = true;
    stream?.close(); stream = null;
    reconnecting(false);
    progress(1);
    if (!adapterPath) adapterPath = (part("f-out").textContent || "").trim();
    // The done step's actions start from this run's paths.
    input("f-merge-a").value = adapterPath;
    input("f-exp-base").value = input("f-model").value.trim();
    input("f-exp-adapter").value = adapterPath;
    show(DONE);
    connection().ui?.catalogChanged?.();
  }

  function fail(error: string): void {
    if (terminal) return;
    terminal = true;
    stream?.close(); stream = null;
    reconnecting(false);
    part("f-bar").parentElement!.classList.add("bad");
    part("f-msg").textContent = "Failed";
    part("f-fail-msg").textContent = error;
    part("f-fail").hidden = false;
    show(RUN, true);
  }

  async function mergeAdapters(): Promise<void> {
    const a = input("f-merge-a").value.trim(), b = input("f-merge-b").value.trim();
    const out = part("f-merge-out");
    if (!a || !b) { out.innerHTML = failureHtml("Enter both adapter paths.", ""); return; }
    out.innerHTML = '<p class="muted"><span class="skeleton">Merging…</span></p>';
    const button = part<HTMLButtonElement>("f-merge-go");
    button.disabled = true;
    const answer = await api().post("api/finetune/merge", { adapter_a: a, adapter_b: b });
    button.disabled = false;
    if (!answer.ok) { out.innerHTML = failureHtml("Could not merge.", errorOf(answer, "The server gave no reason.")); return; }
    out.innerHTML = writtenHtml("Merged into a new adapter:", String(answer.merged_path ?? ""), answer.stats);
    notify("Adapters merged", "ok");
  }

  async function exportModel(): Promise<void> {
    const base = input("f-exp-base").value.trim(), adapter = input("f-exp-adapter").value.trim();
    const out = part("f-exp-out");
    if (!base || !adapter) { out.innerHTML = failureHtml("Enter a base model and an adapter path.", ""); return; }
    out.innerHTML = '<p class="muted"><span class="skeleton">Exporting…</span></p>';
    const button = part<HTMLButtonElement>("f-exp-go");
    button.disabled = true;
    const answer = await api().post("api/finetune/export", { base_model: base, adapter_path: adapter });
    button.disabled = false;
    if (!answer.ok) { out.innerHTML = failureHtml("Could not export.", errorOf(answer, "The server gave no reason.")); return; }
    out.innerHTML = writtenHtml("Export manifest written:", String(answer.export_path ?? ""));
    notify("Model exported", "ok");
  }

  function publish(): void {
    const hook = connection().ui?.publish;
    if (hook) void hook(part("f-push-panel"), { kind: "finetune", source_path: adapterPath || (part("f-out").textContent || "").trim() });
    else notify("This host has no publishing interface.", "err");
  }

  function bind(): void {
    const on = (target: EventTarget, type: string, handler: (event: Event) => void) => disposer.add(listen(target, type, handler));
    on(part("f-next0"), "click", () => {
      if (!input("f-model").value.trim()) { notify("Enter a base model path.", "err"); input("f-model").focus(); return; }
      show(DATASET);
    });
    on(part("f-browse"), "click", () => { void pickBaseFolder(); });
    on(part("f-folder"), "change", (event) => {
      const picker = event.target as HTMLInputElement;
      const file = picker.files?.[0] as FileWithRelPath | undefined;
      picker.value = "";
      if (file) void resolveBaseByName((file.webkitRelativePath || file.name).split("/")[0]!, file.webkitRelativePath || "");
    });
    // A folder dragged onto the field: the directory entry's name, never its contents.
    const drop = part("f-drop");
    for (const type of ["dragenter", "dragover"]) on(drop, type, (event) => { event.preventDefault(); drop.classList.add("over"); });
    for (const type of ["dragleave", "drop"]) on(drop, type, (event) => {
      event.preventDefault();
      drop.classList.remove("over");
      const transfer = (event as DragEvent).dataTransfer;
      if (type !== "drop" || !transfer) return;
      for (const item of [...(transfer.items || [])]) {
        const entry = item.webkitGetAsEntry?.();
        if (entry?.isDirectory) { void resolveBaseByName(entry.name); return; }
      }
      const file = transfer.files?.[0] as FileWithRelPath | undefined;
      if (file) void resolveBaseByName((file.webkitRelativePath || file.name).split("/")[0]!);
    });
    on(part("f-inspect"), "click", () => { void inspectDataset(); });
    on(part("f-data"), "keydown", (event) => { if ((event as KeyboardEvent).key === "Enter") void inspectDataset(); });
    on(part("f-data"), "input", datasetChanged);
    on(part("f-next1"), "click", () => { if (datasetOk) show(CONFIGURE); });
    for (const button of part("f-method").querySelectorAll<HTMLButtonElement>("button")) on(button, "click", () => setMethod(button.dataset.v as Method));
    const scopes = [...part("f-orpo-scope").querySelectorAll<HTMLButtonElement>("button")];
    for (const button of scopes) on(button, "click", () => {
      for (const other of scopes) { other.classList.toggle("on", other === button); other.setAttribute("aria-pressed", String(other === button)); }
    });
    on(part("f-lr"), "input", () => { lrTouched = true; });
    on(part("f-rank"), "input", () => { rankTouched = true; });
    for (const back of root.querySelectorAll<HTMLElement>("[data-fback]")) on(back, "click", () => show(step - 1));
    on(part("f-submit"), "click", () => { void submit(); });
    on(part("f-retry"), "click", () => show(CONFIGURE));
    on(part("f-merge-go"), "click", () => { void mergeAdapters(); });
    on(part("f-exp-go"), "click", () => { void exportModel(); });
    on(part("f-push"), "click", publish);
    on(part("f-again"), "click", () => {
      part("f-base-out").innerHTML = part("f-inspect-out").innerHTML = "";
      part("f-merge-out").innerHTML = part("f-exp-out").innerHTML = part("f-push-panel").innerHTML = "";
      show(BASE);
    });
    disposer.add(() => { stream?.close(); stream = null; });
  }

  return {
    init() { show(BASE); },
    enter() {
      active = true;
      bind();
      if (jobId && !terminal) attach(jobId);
    },
    leave() {
      active = false;
      disposer.dispose();
    },
    currentStep: () => railStep(part("f-steps")),
  };
}
