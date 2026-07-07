// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// DATASET CONTROLLER — template-driven builder. Behavior-identical port of
// the original controllers.dataset IIFE in app.html.

import { api, jobStream } from "./api";
import type { ApiEnvelope } from "./protocol";
import { $, toast, num, pushToHub, activeModelId } from "./shell";
import { esc, renderSteps } from "./markdown";

const STEPS = ["Template", "Inputs", "Generate", "Done"];

interface DatasetField {
  name: string;
  label?: string;
  type?: "textarea" | "number" | "text";
  hint?: string;
  default?: unknown;
  required?: boolean;
}
interface DatasetTemplate {
  id: string;
  label?: string;
  description?: string;
  needs_llm?: boolean;
  output_format?: string;
  fields?: DatasetField[];
}

export function createDatasetController() {
  let step = 0, templates: DatasetTemplate[] = [], selected: DatasetTemplate | null = null, jobId: string | null = null, es: EventSource | null = null, log: string[] = [];

  function show(n: number): void {
    step = n;
    document.querySelectorAll<HTMLElement>("[data-dstep]").forEach((d) => d.style.display = (+d.dataset.dstep! === n) ? "" : "none");
    renderSteps($("d-steps"), STEPS, n);
  }

  async function loadTemplates(): Promise<void> {
    const grid = $("d-templates");
    grid.innerHTML = Array.from({ length: 4 }, () => '<div class="card" style="height:130px"><div class="shimmer" style="height:18px;width:50%;margin-bottom:12px"></div><div class="shimmer" style="height:13px;width:90%;margin-bottom:6px"></div><div class="shimmer" style="height:13px;width:70%"></div></div>').join("");
    const d = await api("/api/dataset/templates").catch(() => ({ templates: null }));
    templates = (d as { templates?: DatasetTemplate[] }).templates || [];
    if (!templates.length) { grid.innerHTML = '<div class="empty" style="grid-column:1/-1"><h3>No templates available</h3><p>The server didn\'t return any dataset templates. Make sure the server is running.</p></div>'; return; }
    // non-LLM templates first
    const ordered = templates.slice().sort((a, b) => (a.needs_llm ? 1 : 0) - (b.needs_llm ? 1 : 0));
    grid.innerHTML = ordered.map((t) =>
      '<div class="card" data-tid="' + esc(t.id) + '" style="cursor:pointer;display:flex;flex-direction:column;gap:8px">' +
        '<div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">' +
          '<h3 style="margin:0;font-size:16px;font-weight:700;letter-spacing:-.01em;color:var(--ink);text-transform:none">' + esc(t.label || t.id) + "</h3>" +
          (t.needs_llm ? '<span class="pill warn" style="padding:3px 9px;font-size:11px"><span class="dot"></span>uses local model</span>' : "") +
          (t.output_format ? '<span class="soon" style="color:var(--dim)">' + esc(t.output_format) + "</span>" : "") +
        "</div>" +
        '<p style="color:var(--dim);font-size:13.5px;line-height:1.5;margin:0">' + esc(t.description || "") + "</p>" +
      "</div>").join("");
    grid.querySelectorAll<HTMLElement>("[data-tid]").forEach((c) =>
      c.onclick = () => selectTemplate(templates.find((t) => t.id === c.dataset.tid)!));
  }

  function selectTemplate(t: DatasetTemplate): void {
    selected = t;
    $("d-form-title").textContent = t.label || t.id;
    $("d-form-desc").textContent = t.description || "";
    const form = $("d-form");
    form.innerHTML = (t.fields || []).map((f) => {
      const lbl = esc(f.label || f.name) + (f.required ? " *" : "");
      const ph = f.hint ? ' placeholder="' + esc(f.hint) + '"' : "";
      const dv = f.default != null ? f.default : "";
      let ctrl: string;
      if (f.type === "textarea") ctrl = '<textarea data-fld="' + esc(f.name) + '"' + ph + ">" + esc(dv) + "</textarea>";
      else if (f.type === "number") ctrl = '<input type="number" data-fld="' + esc(f.name) + '" value="' + esc(dv) + '"' + ph + ">";
      else ctrl = '<input type="text" data-fld="' + esc(f.name) + '" value="' + esc(dv) + '"' + ph + ">";
      return '<div class="field"><label>' + lbl + "</label>" + ctrl + (f.hint ? '<div class="hint">' + esc(f.hint) + "</div>" : "") + "</div>";
    }).join("");
    show(1);
  }

  async function submit(): Promise<void> {
    if (!selected) return;
    const inputs: Record<string, unknown> = {};
    $("d-form").querySelectorAll<HTMLInputElement | HTMLTextAreaElement>("[data-fld]").forEach((i) => {
      inputs[i.dataset.fld!] = i.type === "number" ? (i.value === "" ? null : +i.value) : i.value;
    });
    const body: Record<string, unknown> = { template_id: selected.id, inputs };
    if (selected.needs_llm && activeModelId) body.model_name = activeModelId;
    const btn = $("d-submit") as HTMLButtonElement; btn.disabled = true;
    const d = await api("/api/dataset/submit", { method: "POST", body }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { toast((d.error as string) || "could not start generation", "err"); return; }
    jobId = (d.job_id as string) || null;
    $("d-push-panel").innerHTML = "";
    $("d-out").textContent = (d.output_dir as string) || "";
    log = []; $("d-log").textContent = ""; $("d-bar").style.width = "0%"; $("d-pct").textContent = "0%"; $("d-msg").textContent = "Starting…";
    $("d-ntrain").textContent = $("d-nvalid").textContent = "—";
    show(2);
    attach(jobId!);
  }

  function attach(id: string): void {
    if (es) es.close();
    es = jobStream(id, {
      log: (e) => { log.push(e.line); $("d-log").textContent = log.slice(-200).join("\n"); $("d-log").scrollTop = $("d-log").scrollHeight; },
      stage: (e) => {
        if (e.progress != null) { const p = Math.round(e.progress * 100); $("d-bar").style.width = p + "%"; $("d-pct").textContent = p + "%"; }
        if (e.message) $("d-msg").textContent = e.message;
        if (e.n_train != null) $("d-ntrain").textContent = num(e.n_train);
        if (e.n_valid != null) $("d-nvalid").textContent = num(e.n_valid);
        if (e.stage === "done") { if (e.output_dir) $("d-out").textContent = e.output_dir; finish(e); }
      },
      done: (e) => finish(e),
      failed: (e) => { $("d-msg").textContent = "Failed: " + (e.error || "unknown error"); toast(e.error || "generation failed", "err"); es && es.close(); },
    });
  }
  function finish(e?: { n_train?: number; n_valid?: number }): void {
    $("d-bar").style.width = "100%"; $("d-pct").textContent = "100%"; es && es.close();
    if (e && e.n_train != null) $("d-ntrain").textContent = num(e.n_train);
    if (e && e.n_valid != null) $("d-nvalid").textContent = num(e.n_valid);
    show(3);
  }

  return {
    init() {
      show(0);
      loadTemplates();
      document.querySelectorAll<HTMLButtonElement>("#s-dataset [data-dback]").forEach((b) => b.onclick = () => show(0));
      ($("d-submit") as HTMLButtonElement).onclick = submit;
      ($("d-push") as HTMLButtonElement).onclick = () => pushToHub($("d-push-panel"), { kind: "dataset", job_id: jobId || undefined });
      ($("d-again") as HTMLButtonElement).onclick = () => { selected = null; $("d-push-panel").innerHTML = ""; show(0); };
    },
  };
}
