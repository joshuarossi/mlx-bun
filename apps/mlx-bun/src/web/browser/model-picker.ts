// GENERATED-ADJACENT source module — part of the apps/mlx-bun/src/web/browser/*
// split. Built into apps/mlx-bun/dist/web/app.js by
// scripts/build-web.ts.
//
// Model picker: makes the nav model label
// (#nav-model) open a popover of every downloaded model from GET /library,
// each with its own fit verdict computed on THIS Mac (`assessment`, from
// packages/inference/src/execution/fit.ts). A row's Serve button asks the
// server to switch (POST /api/hub/serve): the model loads beside the running
// ones when it fits, otherwise the least recently used one is unloaded with
// its saved state, and switching back resumes that state. A host that serves
// one model (an embedded server) answers restart_required, and the row then
// shows the copy-able `mlx-bun serve <id>` command instead.

import { $, setModelPopClose, openHubFromModelPicker, pollIdentity, toast } from "./shell";
import { api } from "./api";
import { esc } from "./markdown";

export interface LibraryRow {
  repo_id: string;
  model_type: string;
  size_bytes: number;
  quant_bits: number | null;
  vision: boolean;
  supported: boolean;
  support_tier: "targeted" | "generic" | null;
  serving: boolean;
  /** Loaded now (the served model and any that fit beside it). Absent from a host that predates residency. */
  resident?: boolean;
  assessment: { fits: boolean; max_safe_context: number; predicted_decode_tps: number } | null;
}

function gb(n: number): string { return (n / 2 ** 30).toFixed(1) + " GB"; }

/** Three-tier verdict from the server's honest {fits, predicted_decode_tps}
 *  (packages/inference/src/execution/fit.ts) — LM Studio's green/yellow/red convention layered on our own
 *  per-machine numbers, not a second prediction model. green: fits with
 *  headroom (≥10 tok/s decode — comfortably interactive); yellow: fits but
 *  slow (<10 tok/s — usable, sluggish); red: doesn't fit the memory budget;
 *  null: no assessment (unreadable config). Exported so renderRow and any
 *  future caller share one threshold instead of two copies drifting apart. */
export function fitVerdict(a: LibraryRow["assessment"]): "green" | "yellow" | "red" | null {
  if (!a) return null;
  if (!a.fits) return "red";
  return a.predicted_decode_tps >= 10 ? "green" : "yellow";
}

function pickModel(models: LibraryRow[]): LibraryRow[] {
  // Supported models first (unsupported ones can still be listed so a user
  // understands "this exists on disk but mlx-bun can't serve it" rather
  // than it silently vanishing), each group sorted by repo id for a stable,
  // scannable order — /library itself has no ordering guarantee.
  return [...models].sort((a, b) => {
    if (a.serving !== b.serving) return a.serving ? -1 : 1;
    if (a.supported !== b.supported) return a.supported ? -1 : 1;
    return a.repo_id.localeCompare(b.repo_id);
  });
}

function renderRow(m: LibraryRow): string {
  const verdict = fitVerdict(m.assessment);
  const dot = verdict ? '<span class="mp-fit-dot ' + verdict + '" aria-hidden="true"></span>' : '<span class="mp-fit-dot" aria-hidden="true" style="background:var(--dimmer)"></span>';
  const name = m.repo_id.split("/").pop() || m.repo_id;
  const quant = m.quant_bits ? m.quant_bits + "-bit" : "unquantized";
  const metaBits = [gb(m.size_bytes), quant];
  if (m.vision) metaBits.push("vision");
  if (!m.supported) metaBits.push("unsupported model family");
  const tpsBit = m.assessment && m.assessment.fits
    ? m.assessment.predicted_decode_tps.toFixed(0) + " tok/s predicted"
    : m.assessment ? "doesn't fit this Mac's memory" : "fit unknown";
  const servingTag = m.serving ? '<div class="mp-serving-tag">● currently serving</div>'
    : m.resident ? '<div class="mp-serving-tag">○ loaded</div>' : "";
  const cmdRow = m.serving || !m.supported
    ? ""
    : '<div class="mp-cmd"><button type="button" class="mp-serve" data-repo="' + esc(m.repo_id) + '">Serve</button></div>';
  return (
    '<div class="mp-row' + (m.serving ? " serving" : "") + '">' +
      dot +
      '<div class="mp-main">' +
        '<div class="mp-name" title="' + esc(m.repo_id) + '">' + esc(name) + "</div>" +
        '<div class="mp-meta">' + esc(metaBits.join(" · ")) + " · " + esc(tpsBit) + "</div>" +
        servingTag + cmdRow +
      "</div>" +
    "</div>"
  );
}

/** Pure render of the popover body from a /library response. Exported for
 *  apps/mlx-bun/tests/web/browser.test.ts's esc() discipline check (repo ids are
 *  user-controlled HF strings — the same class of interpolation hazard
 *  finding #15 flagged for the adapter dropdown). */
export function renderModelPopBodyHtml(models: LibraryRow[]): string {
  const browseRow = '<button type="button" class="mp-browse-hub" id="model-pop-browse">Browse models…</button>';
  if (!models.length) {
    return '<div class="mp-empty">No models downloaded yet. Use <code>mlx-bun get &lt;repo-id&gt;</code> to fetch one, ' +
      "or browse Hugging Face below.</div>" + browseRow;
  }
  const rows = pickModel(models).map(renderRow).join("");
  return (
    rows +
    '<div class="mp-foot-note">Fit is predicted for THIS Mac, not a generic guess. ' +
    "Serving a model loads it beside the running ones when it fits; otherwise the least recently used one is unloaded " +
    "with its saved state, and switching back resumes it.</div>" +
    browseRow
  );
}

type ServeResp = { ok?: boolean; error?: string; restart_required?: boolean; command?: string };

/** Ask the server to make this model the served one. A host that cannot switch answers with the restart command, shown in place of the button. */
async function serveFromPicker(btn: HTMLButtonElement): Promise<void> {
  const repo = btn.dataset.repo || "";
  if (!repo) return;
  btn.disabled = true;
  btn.textContent = "Loading…";
  const d = await api<ServeResp>("/api/hub/serve", { method: "POST", body: { model: repo } })
    .catch((): ServeResp => ({ ok: false, error: "request failed" }));
  if (d.ok) {
    toast("Now serving " + repo, "ok");
    void pollIdentity();
    await refreshModelPop();
    return;
  }
  if (d.restart_required && d.command) {
    const cmd = d.command;
    const row = btn.parentElement;
    if (row) {
      row.innerHTML = '<code>' + esc(cmd) + '</code><button type="button" class="mp-copy" data-cmd="' + esc(cmd) + '">Copy</button>';
      row.querySelector<HTMLButtonElement>(".mp-copy")!.onclick = (ev) => {
        const copy = ev.currentTarget as HTMLButtonElement;
        if (navigator.clipboard) navigator.clipboard.writeText(cmd).then(() => {
          const prev = copy.textContent; copy.textContent = "Copied";
          setTimeout(() => { copy.textContent = prev; }, 1200);
        }).catch(() => {});
      };
    }
    return;
  }
  btn.disabled = false;
  btn.textContent = "Serve";
  toast("Couldn't switch models: " + (d.error || "unknown error"), "err");
}

async function refreshModelPop(): Promise<void> {
  const body = $("model-pop-body");
  if (!body) return;
  body.innerHTML = '<div class="mp-empty">Loading…</div>';
  try {
    const d = await api("/library");
    const models = ((d as { models?: LibraryRow[] }).models) || [];
    body.innerHTML = renderModelPopBodyHtml(models);
    body.querySelectorAll<HTMLButtonElement>(".mp-serve").forEach((btn) => {
      btn.onclick = () => { void serveFromPicker(btn); };
    });
    const browseBtn = body.querySelector<HTMLButtonElement>("#model-pop-browse");
    if (browseBtn) {
      browseBtn.onclick = () => {
        setModelPopOpen(false);
        if (openHubFromModelPicker) openHubFromModelPicker();
      };
    }
  } catch {
    body.innerHTML = '<div class="mp-empty">Could not reach the server.</div>';
  }
}

let modelPopOpen = false;
function setModelPopOpen(open: boolean): void {
  if (open === modelPopOpen) return;
  modelPopOpen = open;
  $("model-pop").classList.toggle("open", open);
  $("nav-model").setAttribute("aria-expanded", String(open));
  if (open) refreshModelPop();
}
export function closeModelPop(): void { setModelPopOpen(false); }
export function isModelPopOpen(): boolean { return modelPopOpen; }

/** Wire the nav model button + popover. Escape/click-away follow the same
 *  pattern as the sampling popover (setSamplingPopoverClose) — see
 *  shell.ts's closeTopOverlay, extended to check this popover too. */
export function initModelPicker(): void {
  const btn = $("nav-model");
  if (!btn) return;
  btn.onclick = (e) => { e.stopPropagation(); setModelPopOpen(!modelPopOpen); };
  $("model-pop").addEventListener("click", (e) => e.stopPropagation());
  document.addEventListener("click", () => setModelPopOpen(false));
  setModelPopClose(closeModelPop);
}
