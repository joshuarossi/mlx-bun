// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// FINE-TUNE CONTROLLER — 5-step wizard with live loss chart.
// Behavior-identical port of the original controllers.finetune IIFE.

import { api, jobStream } from "./api";
import type { ApiEnvelope } from "./protocol";
import { $, toast, num, pushToHub, controllers } from "./shell";
import { esc, renderSteps } from "./markdown";

const STEPS = ["Base", "Dataset", "Hyperparams", "Train", "Done"];

interface FileWithRelPath extends File {
  webkitRelativePath: string;
}

interface LossPoint { step: number; loss: number | null }

export function createFinetuneController() {
  let step = 0, method: "sft" | "dpo" | "orpo" = "sft", lrTouched = false, rankTouched = false, es: EventSource | null = null, log: string[] = [];
  let datasetOk = false, adapterPath = "";
  const trainPts: LossPoint[] = [], valPts: LossPoint[] = [];

  function show(n: number): void {
    step = n;
    document.querySelectorAll<HTMLElement>("[data-fstep]").forEach((d) => d.style.display = (+d.dataset.fstep! === n) ? "" : "none");
    renderSteps($("f-steps"), STEPS, n);
  }

  // OS folder picker for the base model — resolve by NAME server-side (no
  // upload, works with the HF cache's symlinked layout). Mirrors Quantize.
  async function resolveBaseByName(name: string, relPath?: string): Promise<void> {
    if (!name && !relPath) return;
    const d = await api("/api/model/resolve-folder", { method: "POST", body: { folder_name: name || "", rel_path: relPath || "" } })
      .catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    if (!d.ok) { toast((d.error as string) || "could not locate this folder", "err"); return; }
    ($("f-model") as HTMLInputElement).value = d.path as string;
  }
  async function pickBaseFolder(): Promise<void> {
    if (window.showDirectoryPicker) {
      try { const h = await window.showDirectoryPicker({ id: "mlx-models", mode: "read" }); return resolveBaseByName(h.name); }
      catch { return; }
    }
    $("f-folder").click();
  }

  async function inspectDataset(): Promise<void> {
    const path = ($("f-data") as HTMLInputElement).value.trim();
    if (!path) { toast("Enter a dataset directory.", "err"); return; }
    const out = $("f-inspect-out");
    out.innerHTML = '<div class="flash"><span class="shimmer">inspecting…</span></div>';
    const d = await api("/api/finetune/inspect-dataset", { method: "POST", body: { path } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    if (!d.ok) { out.innerHTML = '<div class="flash err">' + esc(d.error || "could not read dataset") + "</div>"; datasetOk = false; ($("f-next1") as HTMLButtonElement).disabled = true; return; }
    datasetOk = true; ($("f-next1") as HTMLButtonElement).disabled = false;
    out.innerHTML = '<div class="flash ok"><strong>' + num(d.n_train as number) + "</strong> train rows" +
      (d.n_valid ? " · <strong>" + num(d.n_valid as number) + "</strong> valid rows" : "") +
      (d.format ? " · format <strong>" + esc(d.format) + "</strong>" : "") + "</div>";
  }

  function setMethod(m: "sft" | "dpo" | "orpo"): void {
    method = m;
    $("f-method").querySelectorAll<HTMLButtonElement>("button").forEach((b) => b.classList.toggle("on", b.dataset.v === m));
    $("f-dpo-extra").style.display = m === "dpo" ? "" : "none";
    $("f-orpo-extra").style.display = m === "orpo" ? "" : "none";
    $("f-method-hint").textContent = m === "dpo"
      ? "Direct Preference Optimization — data is {prompt, chosen, rejected}."
      : m === "orpo"
        ? "Odds Ratio Preference Optimization (reference-free) — data is {prompt, chosen, rejected}."
        : "Supervised fine-tuning — data is messages or prompt+completion.";
    if (!lrTouched) ($("f-lr") as HTMLInputElement).value = String(m === "dpo" ? 0.00005 : m === "orpo" ? 0.00001 : 0.0002);
    // ORPO's validated LoRA recipe uses rank 16 (vs 8 for SFT); apply unless edited.
    if (!rankTouched) ($("f-rank") as HTMLInputElement).value = String(m === "orpo" ? 16 : 8);
  }

  function collectHP(): Record<string, unknown> {
    const modules = ($("f-modules") as HTMLInputElement).value.split(",").map((s) => s.trim()).filter(Boolean);
    const hp: Record<string, unknown> = {
      model_dir: ($("f-model") as HTMLInputElement).value.trim(),
      data_dir: ($("f-data") as HTMLInputElement).value.trim(),
      method,
      rank: +($("f-rank") as HTMLInputElement).value, scale: +($("f-scale") as HTMLInputElement).value, lora_dropout: +($("f-dropout") as HTMLInputElement).value,
      target_modules: modules, num_layers: +($("f-layers") as HTMLInputElement).value, iters: +($("f-iters") as HTMLInputElement).value,
      batch_size: +($("f-batch") as HTMLInputElement).value, learning_rate: +($("f-lr") as HTMLInputElement).value, max_seq_length: +($("f-seq") as HTMLInputElement).value,
    };
    if (method === "dpo") { hp.dpo_beta = +($("f-beta") as HTMLInputElement).value; hp.dpo_lr_schedule = ($("f-sched") as HTMLSelectElement).value; }
    if (method === "orpo") {
      hp.orpo_lambda = +($("f-orpo-lambda") as HTMLInputElement).value; hp.orpo_lr_schedule = ($("f-orpo-sched") as HTMLSelectElement).value;
      // web-ui-pass-plan.md #7: sft_scope only makes sense for ORPO's
      // monolithic loss (the SFT term needs a scope); default matches the
      // segmented control's default ("full", paper/TRL chosen-NLL).
      const scopeBtn = $("f-orpo-scope").querySelector("button.on") as HTMLElement | null;
      hp.sft_scope = (scopeBtn && scopeBtn.dataset.v) || "full";
    }
    return hp;
  }

  async function submit(): Promise<void> {
    const btn = $("f-submit") as HTMLButtonElement; btn.disabled = true;
    const d = await api("/api/finetune/submit", { method: "POST", body: collectHP() }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { toast((d.error as string) || "could not start training", "err"); return; }
    adapterPath = (d.adapter_path as string) || "";
    $("f-out").textContent = adapterPath;
    $("f-merge-out").innerHTML = $("f-exp-out").innerHTML = $("f-push-panel").innerHTML = "";
    trainPts.length = 0; valPts.length = 0; log = [];
    $("f-log").textContent = ""; $("f-bar").style.width = "0%"; $("f-pct").textContent = "0%"; $("f-msg").textContent = "Starting…";
    $("f-step").textContent = $("f-loss").textContent = $("f-curlr").textContent = $("f-curtps").textContent = "—";
    drawChart();
    show(3);
    attach(d.job_id as string);
  }

  function attach(jobId: string): void {
    if (es) es.close();
    es = jobStream(jobId, {
      log: (e) => { log.push(e.line); $("f-log").textContent = log.slice(-200).join("\n"); $("f-log").scrollTop = $("f-log").scrollHeight; },
      metric: (e) => {
        if (e.kind === "val") { valPts.push({ step: e.step, loss: e.loss }); $("f-leg-val").style.display = ""; }
        else {
          trainPts.push({ step: e.step, loss: e.loss });
          $("f-step").textContent = num(e.step);
          $("f-loss").textContent = e.loss != null ? e.loss.toFixed(4) : "—";
          if (e.learning_rate != null) $("f-curlr").textContent = e.learning_rate.toExponential(2);
          if (e.tokens_per_sec != null) $("f-curtps").textContent = e.tokens_per_sec.toFixed(1);
          if (e.progress != null) { const p = Math.round(e.progress * 100); $("f-bar").style.width = p + "%"; $("f-pct").textContent = p + "%"; }
          if (e.message) $("f-msg").textContent = e.message;
        }
        drawChart();
      },
      stage: (e) => {
        if (e.progress != null) { const p = Math.round(e.progress * 100); $("f-bar").style.width = p + "%"; $("f-pct").textContent = p + "%"; }
        if (e.message) $("f-msg").textContent = e.message;
        if (e.stage === "done") { if (e.adapter_path) { adapterPath = e.adapter_path; $("f-out").textContent = e.adapter_path; } finish(); }
      },
      done: () => finish(),
      failed: (e) => { $("f-msg").textContent = "Failed: " + (e.error || "unknown error"); toast(e.error || "training failed", "err"); es && es.close(); },
    });
  }
  function finish(): void {
    $("f-bar").style.width = "100%"; $("f-pct").textContent = "100%"; es && es.close();
    if (!adapterPath) adapterPath = ($("f-out").textContent || "").trim();
    const base = ($("f-model") as HTMLInputElement).value.trim();
    // prefill the done-step affordances from this run's paths
    ($("f-merge-a") as HTMLInputElement).value = adapterPath;
    ($("f-exp-base") as HTMLInputElement).value = base;
    ($("f-exp-adapter") as HTMLInputElement).value = adapterPath;
    show(4);
    // web-ui-pass-plan.md #15 staleness half: the new adapter is on disk now —
    // refresh the chat adapter chip immediately rather than waiting for the
    // user to navigate to Chat (enter() also refreshes, this just removes the
    // wait for the common case of finishing a run and going straight to try it).
    if (controllers.chat && controllers.chat.refreshAdapters) (controllers.chat.refreshAdapters as () => void)();
  }

  async function mergeAdapters(): Promise<void> {
    const a = ($("f-merge-a") as HTMLInputElement).value.trim(), b = ($("f-merge-b") as HTMLInputElement).value.trim();
    const out = $("f-merge-out");
    if (!a || !b) { out.innerHTML = '<div class="flash err">Enter both adapter paths.</div>'; return; }
    out.innerHTML = '<div class="flash"><span class="shimmer">merging…</span></div>';
    const btn = $("f-merge-go") as HTMLButtonElement; btn.disabled = true;
    const d = await api("/api/finetune/merge", { method: "POST", body: { adapter_a: a, adapter_b: b } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { out.innerHTML = '<div class="flash err">' + esc(d.error || "merge failed") + "</div>"; return; }
    const stats = d.stats && typeof d.stats === "object"
      ? Object.entries(d.stats as Record<string, unknown>).map(([k, v]) => esc(k) + " " + esc(v)).join(" · ")
      : (d.stats ? esc(d.stats) : "");
    out.innerHTML = '<div class="flash ok">Merged → <code>' + esc(d.merged_path || "") + "</code>" + (stats ? "<br>" + stats : "") + "</div>";
    toast("Adapters merged", "ok");
  }

  async function exportModel(): Promise<void> {
    const base = ($("f-exp-base") as HTMLInputElement).value.trim(), adapter = ($("f-exp-adapter") as HTMLInputElement).value.trim();
    const out = $("f-exp-out");
    if (!base || !adapter) { out.innerHTML = '<div class="flash err">Enter a base model and adapter path.</div>'; return; }
    out.innerHTML = '<div class="flash"><span class="shimmer">exporting…</span></div>';
    const btn = $("f-exp-go") as HTMLButtonElement; btn.disabled = true;
    const d = await api("/api/finetune/export", { method: "POST", body: { base_model: base, adapter_path: adapter } }).catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    btn.disabled = false;
    if (!d.ok) { out.innerHTML = '<div class="flash err">' + esc(d.error || "export failed") + "</div>"; return; }
    out.innerHTML = '<div class="flash ok">Exported → <code>' + esc(d.export_path || "") + "</code></div>";
    toast("Model exported", "ok");
  }

  /* inline SVG line plot — themed green (train) / blue (val) */
  function drawChart(): void {
    const svg = $("f-chart");
    const W = 600, H = 200, padL = 8, padR = 8, padT = 12, padB = 12;
    const all = trainPts.concat(valPts);
    if (!all.length) { svg.innerHTML = '<text x="300" y="104" text-anchor="middle" fill="var(--dimmer)" font-size="13">waiting for the first metric…</text>'; return; }
    const losses = all.map((p) => p.loss).filter((x): x is number => x != null && isFinite(x));
    let minL = Math.min(...losses), maxL = Math.max(...losses);
    if (minL === maxL) { minL -= 0.5; maxL += 0.5; }
    const range = maxL - minL || 1;
    const maxStep = Math.max(...all.map((p) => p.step || 0), 1);
    const xOf = (s: number) => padL + (s / maxStep) * (W - padL - padR);
    const yOf = (l: number) => padT + (1 - (l - minL) / range) * (H - padT - padB);
    const path = (pts: LossPoint[], color: string, fillId: string): string => {
      if (!pts.length) return "";
      const d = pts.map((p, i) => (i ? "L" : "M") + xOf(p.step).toFixed(1) + " " + yOf(p.loss ?? 0).toFixed(1)).join(" ");
      let out = '<path d="' + d + '" fill="none" stroke="' + color + '" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>';
      // soft area fill under the curve
      const area = d + " L" + xOf(pts[pts.length - 1]!.step).toFixed(1) + " " + (H - padB) + " L" + xOf(pts[0]!.step).toFixed(1) + " " + (H - padB) + " Z";
      out = '<path d="' + area + '" fill="url(#' + fillId + ')" opacity="0.18"/>' + out;
      return out;
    };
    // gridlines
    let grid = "";
    for (let i = 1; i < 4; i++) { const y = padT + (i / 4) * (H - padT - padB); grid += '<line x1="0" y1="' + y.toFixed(1) + '" x2="' + W + '" y2="' + y.toFixed(1) + '" stroke="rgba(255,255,255,.06)" stroke-width="1"/>'; }
    svg.innerHTML =
      '<defs>' +
      '<linearGradient id="gf-train" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#30d158"/><stop offset="1" stop-color="#30d158" stop-opacity="0"/></linearGradient>' +
      '<linearGradient id="gf-val" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0a84ff"/><stop offset="1" stop-color="#0a84ff" stop-opacity="0"/></linearGradient>' +
      '</defs>' + grid +
      path(valPts, "#0a84ff", "gf-val") +
      path(trainPts, "#30d158", "gf-train");
  }

  return {
    init() {
      show(0);
      ($("f-next0") as HTMLButtonElement).onclick = () => { if (!($("f-model") as HTMLInputElement).value.trim()) { toast("Enter a base model path.", "err"); return; } show(1); };
      // OS folder dialog for the base model (native; resolves by name, no upload)
      ($("f-browse") as HTMLButtonElement).onclick = pickBaseFolder;
      $("f-folder").addEventListener("change", (e) => {
        const input = e.target as HTMLInputElement;
        const f = input.files![0] as FileWithRelPath; input.value = "";
        if (f) resolveBaseByName((f.webkitRelativePath || f.name).split("/")[0]!, f.webkitRelativePath || "");
      });
      {
        const drop = $("f-drop");
        const hi = (on: boolean) => { drop.style.outline = on ? "2px dashed var(--blue)" : ""; drop.style.outlineOffset = on ? "4px" : ""; };
        ["dragenter", "dragover"].forEach((ev) => drop.addEventListener(ev, (e) => { e.preventDefault(); hi(true); }));
        ["dragleave", "drop"].forEach((ev) => drop.addEventListener(ev, (e) => {
          e.preventDefault(); hi(false);
          const de = e as DragEvent;
          if (ev !== "drop" || !de.dataTransfer) return;
          for (const it of [...(de.dataTransfer.items || [])]) {
            const en = it.webkitGetAsEntry && it.webkitGetAsEntry();
            if (en && en.isDirectory) return void resolveBaseByName(en.name);
          }
          const f = de.dataTransfer.files && de.dataTransfer.files[0] as FileWithRelPath | undefined;
          if (f) resolveBaseByName((f.webkitRelativePath || f.name).split("/")[0]!);
        }));
      }
      ($("f-inspect") as HTMLButtonElement).onclick = inspectDataset;
      $("f-data").addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter") inspectDataset(); });
      $("f-data").addEventListener("input", () => { datasetOk = false; ($("f-next1") as HTMLButtonElement).disabled = true; $("f-inspect-out").innerHTML = ""; });
      ($("f-next1") as HTMLButtonElement).onclick = () => { if (datasetOk) show(2); };
      $("f-method").querySelectorAll<HTMLButtonElement>("button").forEach((b) => b.onclick = () => setMethod(b.dataset.v as "sft" | "dpo" | "orpo"));
      $("f-orpo-scope").querySelectorAll<HTMLButtonElement>("button").forEach((b) => b.onclick = () =>
        $("f-orpo-scope").querySelectorAll("button").forEach((x) => x.classList.toggle("on", x === b)));
      $("f-lr").addEventListener("input", () => { lrTouched = true; });
      $("f-rank").addEventListener("input", () => { rankTouched = true; });
      document.querySelectorAll<HTMLButtonElement>("#s-finetune [data-fback]").forEach((b) => b.onclick = () => show(step - 1));
      ($("f-submit") as HTMLButtonElement).onclick = submit;
      ($("f-merge-go") as HTMLButtonElement).onclick = mergeAdapters;
      ($("f-exp-go") as HTMLButtonElement).onclick = exportModel;
      ($("f-push") as HTMLButtonElement).onclick = () => pushToHub($("f-push-panel"), { kind: "finetune", source_path: adapterPath || ($("f-out").textContent || "").trim() });
      ($("f-again") as HTMLButtonElement).onclick = () => {
        $("f-inspect-out").innerHTML = "";
        $("f-merge-out").innerHTML = $("f-exp-out").innerHTML = $("f-push-panel").innerHTML = "";
        show(0);
      };
    },
  };
}
