// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// QUANTIZE CONTROLLER — 4-step wizard. Behavior-identical port of the
// original controllers.quantize IIFE in app.html.

import { api, jobStream } from "./api";
import type { ApiEnvelope } from "./protocol";
import { $, el, toast, pushToHub, controllers } from "./shell";
import { esc, renderSteps } from "./markdown";

const STEPS = ["Source", "Configure", "Run", "Done"];

// The File System Access API's showDirectoryPicker() isn't in lib.dom yet
// in all TS configs; declare it loosely rather than widen the global Window
// type project-wide.
declare global {
  interface Window {
    showDirectoryPicker?: (opts?: { id?: string; mode?: string }) => Promise<{ name: string }>;
  }
}
interface FileWithRelPath extends File {
  webkitRelativePath: string;
}

export function createQuantizeController() {
  let step = 0, bits = 4, gs = 64, mode: "uniform" | "mixed" = "uniform", bpw = 5, jobId: string | null = null, es: EventSource | null = null, log: string[] = [];

  function show(n: number): void {
    step = n;
    document.querySelectorAll<HTMLElement>("[data-qstep]").forEach((d) => d.style.display = (+d.dataset.qstep! === n) ? "" : "none");
    renderSteps($("q-steps"), STEPS, n);
  }
  function seg(container: HTMLElement, onPick: (v: string, b: HTMLButtonElement) => void): void {
    container.querySelectorAll<HTMLButtonElement>("button").forEach((b) =>
      b.addEventListener("click", () => {
        container.querySelectorAll("button").forEach((x) => x.classList.remove("on"));
        b.classList.add("on"); onPick(b.dataset.v || "", b);
      }));
  }

  // --- OS folder picker / drag-drop -> real on-disk snapshot path ---
  // The browser can't reveal an absolute path, and the HF cache uses symlinked
  // snapshots over a blobs/ store — so we DON'T read any files. We only take the
  // picked folder's NAME (which encodes the repo id) and let the server
  // reconstruct the snapshot path it owns. No upload, no "config.json" hunt.
  async function resolveByName(name: string, relPath?: string): Promise<void> {
    if (!name && !relPath) return;
    const out = $("q-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">locating on disk…</span></div>';
    const d = await api("/api/quantize/resolve-folder", { method: "POST", body: { folder_name: name || "", rel_path: relPath || "" } })
      .catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    if (!d.ok) { out.innerHTML = '<div class="flash err">' + esc(d.error || "could not locate this folder on the server") + "</div>"; return; }
    ($("q-model") as HTMLInputElement).value = d.path as string;
    inspect();
  }
  async function pickFolder(): Promise<void> {
    // Native OS folder dialog with no "upload N files" prompt; we only read the
    // folder's .name, never its contents.
    if (window.showDirectoryPicker) {
      try {
        const handle = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" });
        return resolveByName(handle.name);
      } catch { return; } // user cancelled / denied
    }
    $("q-folder").click(); // fallback for browsers without the File System Access API
  }

  async function inspect(): Promise<void> {
    const id = ($("q-model") as HTMLInputElement).value.trim();
    if (!id) { toast("Enter a model id or path first.", "err"); return; }
    const out = $("q-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">inspecting…</span></div>';
    const btn = $("q-inspect") as HTMLButtonElement; btn.disabled = true;
    const d = await api("/api/quantize/inspect", { method: "POST", body: { model_id: id } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { out.innerHTML = '<div class="flash err">' + esc(d.error || "could not inspect this model") + "</div>"; return; }
    // inspectModel returns support: boolean (src/quantize/job.ts); size_gb
    // can be 0 when a direct path bypasses the registry — hide it then.
    const supported = d.support === true;
    const cls = supported ? "ok" : "err";
    out.innerHTML =
      '<div class="flash ' + cls + '"><strong>' + esc(d.arch || d.model_id || id) + "</strong>" +
      (d.size_gb ? " · " + (+d.size_gb).toFixed(2) + " GB" : "") +
      " · " + (supported ? "supported" : "not quantizable") + "</div>" +
      '<div class="btnrow"><button class="btn primary" id="q-continue">Continue</button></div>';
    ($("q-continue") as HTMLButtonElement).onclick = () => show(1);
  }

  async function submit(): Promise<void> {
    const id = ($("q-model") as HTMLInputElement).value.trim();
    const btn = $("q-submit") as HTMLButtonElement; btn.disabled = true;
    const body: Record<string, unknown> = { model_id: id, bits, group_size: gs };
    if (mode === "mixed") { body.target_bpw = bpw; body.candidate_bits = [4, 8]; }
    const d = await api("/api/quantize/submit", { method: "POST", body })
      .catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { toast((d.error as string) || "could not start quantize", "err"); return; }
    jobId = (d.job_id as string) || null;
    $("q-push-panel").innerHTML = "";
    $("q-out").textContent = (d.output_dir as string) || "";
    log = []; $("q-log").textContent = ""; $("q-bar").style.width = "0%"; $("q-pct").textContent = "0%"; $("q-msg").textContent = "Starting…";
    show(2);
    attach(jobId!);
  }

  function attach(id: string): void {
    if (es) es.close();
    es = jobStream(id, {
      log: (e) => { log.push(e.line); $("q-log").textContent = log.slice(-200).join("\n"); $("q-log").scrollTop = $("q-log").scrollHeight; },
      stage: (e) => {
        if (e.progress != null) { const p = Math.round(e.progress * 100); $("q-bar").style.width = p + "%"; $("q-pct").textContent = p + "%"; }
        if (e.message) $("q-msg").textContent = e.message;
        if (e.stage === "done") { if (e.output_dir) $("q-out").textContent = e.output_dir; finish(); }
      },
      done: () => finish(),
      failed: (e) => { $("q-msg").textContent = "Failed: " + (e.error || "unknown error"); toast(e.error || "quantize failed", "err"); es && es.close(); },
    });
  }
  function finish(): void {
    $("q-bar").style.width = "100%"; $("q-pct").textContent = "100%"; es && es.close(); show(3);
    // web-ui-pass-plan.md #3: the server invalidates its /library cache the
    // instant this job completes (server.ts onComplete) — pull the fresh
    // list right away instead of waiting for Status's own 15s poll.
    if (controllers.status && controllers.status.refreshLibrary) (controllers.status.refreshLibrary as () => void)();
  }

  return {
    init() {
      show(0);
      ($("q-inspect") as HTMLButtonElement).onclick = inspect;
      $("q-model").addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") inspect(); });
      // OS folder dialog (native; resolves by folder name, no upload)
      ($("q-browse") as HTMLButtonElement).onclick = pickFolder;
      $("q-folder").addEventListener("change", (e) => {
        const input = e.target as HTMLInputElement;
        const f = input.files![0] as FileWithRelPath; input.value = "";
        if (f) resolveByName((f.webkitRelativePath || f.name).split("/")[0]!, f.webkitRelativePath || "");
      });
      // drag a folder onto the box — use the directory entry's NAME (no read)
      const drop = $("q-drop");
      const hi = (on: boolean) => { drop.style.outline = on ? "2px dashed var(--blue)" : ""; drop.style.outlineOffset = on ? "4px" : ""; };
      ["dragenter", "dragover"].forEach((ev) => drop.addEventListener(ev, (e) => { e.preventDefault(); hi(true); }));
      ["dragleave", "drop"].forEach((ev) => drop.addEventListener(ev, (e) => {
        e.preventDefault(); hi(false);
        const de = e as DragEvent;
        if (ev !== "drop" || !de.dataTransfer) return;
        for (const it of [...(de.dataTransfer.items || [])]) {
          const en = it.webkitGetAsEntry && it.webkitGetAsEntry();
          if (en && en.isDirectory) return void resolveByName(en.name);
        }
        const f = de.dataTransfer.files && de.dataTransfer.files[0] as FileWithRelPath | undefined;
        if (f) resolveByName((f.webkitRelativePath || f.name).split("/")[0]!);
      }));
      seg($("q-bits"), (v) => { bits = +v; $("q-bits-hint").textContent = v === "4"
        ? "4-bit · ~4× smaller than bf16 · the recommended default for local serving."
        : "8-bit · ~2× smaller than bf16 · highest fidelity quant."; });
      seg($("q-gs"), (v) => { gs = +v; });
      seg($("q-mode"), (v) => { mode = v as "uniform" | "mixed"; $("q-bpw-field").style.display = v === "mixed" ? "" : "none"; });
      $("q-bpw").addEventListener("input", (e) => { bpw = +(e.target as HTMLInputElement).value; $("q-bpw-val").textContent = bpw.toFixed(1); });
      document.querySelectorAll<HTMLButtonElement>("#s-quantize [data-qback]").forEach((b) => b.onclick = () => show(step - 1));
      ($("q-submit") as HTMLButtonElement).onclick = submit;
      ($("q-push") as HTMLButtonElement).onclick = () => pushToHub($("q-push-panel"), { kind: "quantize", job_id: jobId || undefined });
      ($("q-again") as HTMLButtonElement).onclick = () => { $("q-inspect-out").innerHTML = ""; $("q-push-panel").innerHTML = ""; show(0); };
    },
  };
}
