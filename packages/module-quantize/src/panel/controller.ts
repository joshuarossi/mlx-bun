// The quantize wizard's state and orchestration: the four steps, inspection, submission and the job's event stream.
// Requests go through the kit's client; the job stream through the kit's event-stream client. Leaving the page closes
// the stream (the job keeps running on the server); returning while the job is unfinished reopens it, and the server
// replays the job's events from its first one, so the log restarts with each connection.
import { $, byType, createApi, createDisposer, errorOf, listen, openEventStream, type EventStream } from "@mlx-bun/web-kit";
import type { JobEvent, PanelConnection } from "../protocol";
import { BITS_HINT, CONFIGURE, DONE, RUN, SOURCE, STEPS, failureHtml, inspectionHtml, stepsHtml } from "./view";

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
}

/** The server root a module base sits under (`https://host/prefix/api/quantize` is `https://host/prefix`). The wizard's
 * routes keep their shipped root paths, so they resolve under the same prefix as the module's base. */
const serverRoot = (apiBase: string): string => apiBase.replace(/\/api\/[^/]*\/?$/, "");
const LOG_LINES = 200;

export function createQuantizeController(root: ShadowRoot, connection: () => PanelConnection): PanelController {
  const part = <T extends HTMLElement = HTMLElement>(id: string): T => $(id, root) as T;
  const api = () => createApi(serverRoot(connection().apiBase));
  const disposer = createDisposer();
  let active = false, step = SOURCE;
  let bits = 4, groupSize = 64, mode: "uniform" | "mixed" = "uniform", bpw = 5;
  let jobId: string | null = null, terminal = false, stream: EventStream | null = null, dropped = false, log: string[] = [];

  const modelId = () => part<HTMLInputElement>("q-model").value.trim();

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
    for (const card of root.querySelectorAll<HTMLElement>("[data-qstep]")) card.hidden = Number(card.dataset.qstep) !== n;
    part("q-steps").innerHTML = stepsHtml(STEPS, n, failed);
  }

  // The folder picker and drag and drop: the browser cannot reveal an absolute path and the Hugging Face cache keeps
  // snapshots as symlinks over a blob store, so nothing is read. Only the folder's name (which encodes the repository
  // id) goes to the server, which finds the snapshot it owns.
  async function resolveByName(name: string, relPath = ""): Promise<void> {
    if (!name && !relPath) return;
    const out = part("q-inspect-out");
    part("q-continue").hidden = true;
    out.innerHTML = '<p class="muted"><span class="skeleton">Locating the folder on disk…</span></p>';
    const answer = await api().post("api/quantize/resolve-folder", { folder_name: name, rel_path: relPath });
    if (!answer.ok) { out.innerHTML = failureHtml("Could not find this folder.", errorOf(answer, "The server could not locate it on disk.")); return; }
    part<HTMLInputElement>("q-model").value = answer.path as string;
    await inspect();
  }

  async function pickFolder(): Promise<void> {
    // The native folder dialog, without the browser's "upload N files" prompt; only the folder's name is read.
    if (window.showDirectoryPicker) {
      try { const handle = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" }); return resolveByName(handle.name); }
      catch { return; } // cancelled or denied
    }
    part("q-folder").click(); // browsers without the File System Access API
  }

  async function inspect(): Promise<void> {
    const id = modelId();
    if (!id) { notify("Enter a model id or path first.", "err"); part("q-model").focus(); return; }
    const out = part("q-inspect-out"), button = part<HTMLButtonElement>("q-inspect");
    part("q-continue").hidden = true;
    out.innerHTML = '<p class="muted"><span class="skeleton">Inspecting the model…</span></p>';
    button.disabled = true;
    const answer = await api().post("api/quantize/inspect", { model_id: id });
    button.disabled = false;
    out.innerHTML = inspectionHtml(answer, id);
    part("q-continue").hidden = !(answer.ok && answer.support === true);
  }

  function progress(fraction: number | null | undefined, message?: string): void {
    if (fraction != null) {
      const percent = Math.round(fraction * 100);
      part("q-bar").style.width = percent + "%";
      part("q-pct").textContent = percent + "%";
      part("q-bar").parentElement!.setAttribute("aria-valuenow", String(percent));
    }
    if (message) part("q-msg").textContent = message;
  }

  function clearLog(): void { log = []; part("q-log").textContent = ""; }

  function reconnecting(on: boolean): void { part("q-reconnect").hidden = !on; }

  async function submit(): Promise<void> {
    const body: Record<string, unknown> = { model_id: modelId(), bits, group_size: groupSize };
    if (mode === "mixed") { body.target_bpw = bpw; body.candidate_bits = [4, 8]; }
    const button = part<HTMLButtonElement>("q-submit");
    button.disabled = true;
    part("q-submit-out").innerHTML = "";
    const answer = await api().post("api/quantize/submit", body);
    button.disabled = false;
    if (!answer.ok) { part("q-submit-out").innerHTML = failureHtml("Could not start quantizing.", errorOf(answer, "The server did not start the job.")); return; }
    part("q-push-panel").innerHTML = "";
    part("q-out").textContent = (answer.output_dir as string) || "";
    clearLog();
    part("q-bar").parentElement!.classList.remove("bad");
    part("q-fail").hidden = true;
    reconnecting(false);
    progress(0, "Starting…");
    show(RUN);
    attach(answer.job_id as string);
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
        const box = part("q-log");
        box.textContent = log.slice(-LOG_LINES).join("\n");
        box.scrollTop = box.scrollHeight;
      },
      stage: (event) => {
        progress(event.progress, event.message);
        if (event.stage === "done") { if (event.output_dir) part("q-out").textContent = event.output_dir; finish(); }
      },
      done: (event) => { if (typeof event.output_dir === "string" && event.output_dir) part("q-out").textContent = event.output_dir; finish(); },
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
    connection().ui?.catalogChanged?.();
  }

  function fail(error: string): void {
    if (terminal) return;
    terminal = true;
    stream?.close(); stream = null;
    reconnecting(false);
    part("q-bar").parentElement!.classList.add("bad");
    part("q-msg").textContent = "Failed";
    part("q-fail-msg").textContent = error;
    part("q-fail").hidden = false;
    show(RUN, true);
  }

  function publish(): void {
    const hook = connection().ui?.publish;
    if (hook) void hook(part("q-push-panel"), { kind: "quantize", job_id: jobId || undefined });
    else notify("This host has no publishing interface.", "err");
  }

  function bind(): void {
    const on = (target: EventTarget, type: string, handler: (event: Event) => void) => disposer.add(listen(target, type, handler));
    const seg = (id: string, pick: (value: string) => void) => {
      const buttons = [...part(id).querySelectorAll<HTMLButtonElement>("button")];
      for (const button of buttons) on(button, "click", () => {
        for (const other of buttons) { other.classList.toggle("on", other === button); other.setAttribute("aria-pressed", String(other === button)); }
        pick(button.dataset.v ?? "");
      });
    };
    on(part("q-inspect"), "click", () => { void inspect(); });
    on(part("q-model"), "keydown", (event) => { if ((event as KeyboardEvent).key === "Enter") void inspect(); });
    on(part("q-browse"), "click", () => { void pickFolder(); });
    on(part("q-folder"), "change", (event) => {
      const input = event.target as HTMLInputElement;
      const file = input.files?.[0] as FileWithRelPath | undefined;
      input.value = "";
      if (file) void resolveByName((file.webkitRelativePath || file.name).split("/")[0]!, file.webkitRelativePath || "");
    });
    // A folder dragged onto the field: the directory entry's name, never its contents.
    const drop = part("q-drop");
    for (const type of ["dragenter", "dragover"]) on(drop, type, (event) => { event.preventDefault(); drop.classList.add("over"); });
    for (const type of ["dragleave", "drop"]) on(drop, type, (event) => {
      event.preventDefault();
      drop.classList.remove("over");
      const transfer = (event as DragEvent).dataTransfer;
      if (type !== "drop" || !transfer) return;
      for (const item of [...(transfer.items || [])]) {
        const entry = item.webkitGetAsEntry?.();
        if (entry?.isDirectory) { void resolveByName(entry.name); return; }
      }
      const file = transfer.files?.[0] as FileWithRelPath | undefined;
      if (file) void resolveByName((file.webkitRelativePath || file.name).split("/")[0]!);
    });
    on(part("q-continue"), "click", () => show(CONFIGURE));
    seg("q-bits", (value) => { bits = Number(value); part("q-bits-hint").textContent = BITS_HINT[value] ?? ""; });
    seg("q-gs", (value) => { groupSize = Number(value); });
    seg("q-mode", (value) => { mode = value === "mixed" ? "mixed" : "uniform"; part("q-bpw-field").hidden = mode !== "mixed"; });
    on(part("q-bpw"), "input", (event) => { bpw = Number((event.target as HTMLInputElement).value); part("q-bpw-val").textContent = bpw.toFixed(1); });
    for (const back of root.querySelectorAll<HTMLElement>("[data-qback]")) on(back, "click", () => show(step - 1));
    on(part("q-submit"), "click", () => { void submit(); });
    on(part("q-retry"), "click", () => show(CONFIGURE));
    on(part("q-push"), "click", publish);
    on(part("q-again"), "click", () => { part("q-inspect-out").innerHTML = ""; part("q-push-panel").innerHTML = ""; part("q-continue").hidden = true; show(SOURCE); });
    disposer.add(() => { stream?.close(); stream = null; });
  }

  return {
    init() { show(SOURCE); },
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
