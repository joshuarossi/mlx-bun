// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// Adapter routing table (plan §5.6, §9 Phase 2): the deep surface behind
// the composer's ⚙ button beside #chat-adapter. Shows every on-disk
// adapter with its three states (available / loaded+mounted /
// selected-for-this-chat), base model, rank, size on disk, and RAM cost
// when mounted (GET /v1/adapters now reports `ram_bytes` — see
// docs/reference/server-api.md), with compatible-graying and a why-not
// tooltip. Actions: mount, select, unselect, and stack two compatible
// adapters as "a+b" — resolveSpec/injectAdapter already support composite
// ids end to end (proved in tests/pi-web.test.ts's stacking test; the
// shape-validated mount is proved against real weights in the
// MLX_BUN_TEST_LORA=1-gated tests/lora.test.ts).
//
// Single source of SELECTION state, not a single fetch: composer.ts's quick
// <select> and this table each hit /v1/adapters(+/available) independently
// (same endpoints, same shapes) rather than sharing one in-memory cache —
// but chat.ts keeps them from disagreeing about what's SELECTED by writing
// through both on every change (adapterSel.onchange syncs
// adaptersPanel.selectedSpec; this table's actions sync #chat-adapter's
// value back). What must never drift is which adapter(s) are active for
// the chat, not which HTTP call fetched the list.

import { $, toast, trapFocus, setAdaptersPanelClose, type FocusTrap } from "./shell";
import { api } from "./api";
import { esc } from "./markdown";

/** Shape returned by GET /v1/adapters/available (on-disk, unfiltered). */
export interface AvailableAdapterRow {
  id: string;
  path: string;
  rank: number | null;
  scale: number;
  base_model: string | null;
  mounted: boolean;
  compatible: boolean;
}

/** Shape returned by GET /v1/adapters (mounted only, with RAM cost). */
export interface MountedAdapterRow {
  id: string;
  path: string;
  rank: number | null;
  scale: number;
  size_bytes: number;
  mounted_layers: number;
  ram_bytes: number;
}

function fmtBytes(n: number | null | undefined): string {
  if (n == null) return "—";
  if (n >= 2 ** 20) return (n / 2 ** 20).toFixed(1) + " MB";
  if (n >= 2 ** 10) return (n / 2 ** 10).toFixed(1) + " KB";
  return n + " B";
}

/** Send callback type shared with the rest of chat.ts's WS wiring. */
type Send = (obj: unknown) => boolean;

export class AdaptersPanelState {
  available: AvailableAdapterRow[] = [];
  mounted: Map<string, MountedAdapterRow> = new Map();
  /** The composer's current single-select value ("" = none), kept in sync
   *  so the table can show which one/ones are "selected for this chat". */
  selectedSpec: string | null = null;
  /** Multi-select scratch state for the "stack" flow — ids the user has
   *  ticked in the table before hitting "apply stack". Cleared on apply. */
  stackPicks: Set<string> = new Set();
}

let trap: FocusTrap | null = null;

/** Fetch both adapter endpoints once and refresh every dependent view: the
 *  table body (if open, with its actions re-wired against `send`) and the
 *  composer's quick <select> (renderAdapterOptionsHtml, imported from
 *  composer.ts — one source of truth, not a second fetch). `send` is
 *  required (not optional) so a refresh never silently leaves the table's
 *  mount/select/stack buttons wired to a no-op. */
export async function refreshAdaptersPanel(state: AdaptersPanelState, send: Send): Promise<void> {
  const [availD, mountedD] = await Promise.all([
    api("/v1/adapters/available").catch(() => ({ ok: false } as const)),
    api("/v1/adapters").catch(() => ({ ok: false } as const)),
  ]);
  state.available = ((availD as { adapters?: AvailableAdapterRow[] }).adapters) || [];
  const mountedList = ((mountedD as { adapters?: MountedAdapterRow[] }).adapters) || [];
  state.mounted = new Map(mountedList.map((a) => [a.id, a]));
  // Drop stack picks for adapters that vanished from disk (e.g. an
  // in-flight delete elsewhere).
  for (const id of [...state.stackPicks]) if (!state.available.some((a) => a.id === id)) state.stackPicks.delete(id);
  renderAdaptersBody(state, send);
}

/** Parse the composer's currently-selected spec ("" | "id" | "a+b") into
 *  the set of ids it names, for the table's per-row "selected" badge. */
function selectedIds(state: AdaptersPanelState): Set<string> {
  const spec = state.selectedSpec;
  if (!spec) return new Set();
  return new Set(spec.split("+").map((s) => s.trim()).filter(Boolean));
}

/** Render one adapter row: id/badges, base-model/rank/size/RAM meta line,
 *  incompatible-why note, and the mount/select/unselect/stack actions.
 *  Pure enough to unit-test (no fetch inside), takes callbacks for the
 *  actions so the DOM wiring lives in one place (initAdaptersPanel). */
export function renderAdapterRow(
  a: AvailableAdapterRow,
  opts: {
    mountedInfo: MountedAdapterRow | undefined;
    isSelected: boolean;
    stackPicked: boolean;
    stackModeOn: boolean;
  },
): string {
  const { mountedInfo, isSelected, stackPicked, stackModeOn } = opts;
  const rowClasses = ["ad-row"];
  if (!a.compatible) rowClasses.push("incompatible");
  if (isSelected) rowClasses.push("selected");
  const badges: string[] = [];
  if (mountedInfo) badges.push('<span class="ad-badge mounted">mounted</span>');
  if (isSelected) badges.push('<span class="ad-badge selected">selected</span>');
  const meta: string[] = [];
  if (a.base_model) meta.push("base <b>" + esc(a.base_model.split("/").pop()) + "</b>");
  if (a.rank) meta.push("rank <b>" + esc(a.rank) + "</b>");
  meta.push("disk <b>" + esc(fmtBytes(mountedInfo ? mountedInfo.size_bytes : null) === "—" ? "—" : fmtBytes(mountedInfo ? mountedInfo.size_bytes : null)) + "</b>");
  if (mountedInfo) meta.push("RAM <b>" + esc(fmtBytes(mountedInfo.ram_bytes)) + "</b>");
  const why = !a.compatible
    ? '<div class="ad-why">' + (a.base_model
        ? "trained for " + esc(a.base_model) + ", not the currently-served model"
        : "not compatible with the currently-served model") + "</div>"
    : "";
  const actions: string[] = [];
  if (a.compatible) {
    if (stackModeOn) {
      actions.push(
        '<label class="ad-stack-chk"><input type="checkbox" class="ad-stack-pick" data-id="' + esc(a.id) + '"' +
        (stackPicked ? " checked" : "") + (!mountedInfo ? " disabled title=\"mount first to stack it\"" : "") + '> stack</label>',
      );
    }
    if (!mountedInfo) {
      actions.push('<button type="button" class="ad-mount" data-id="' + esc(a.id) + '" data-path="' + esc(a.path) + '">Mount</button>');
    } else if (!isSelected) {
      actions.push('<button type="button" class="ad-select primary" data-id="' + esc(a.id) + '">Select</button>');
    } else {
      actions.push('<button type="button" class="ad-unselect" data-id="' + esc(a.id) + '">Unselect</button>');
    }
  }
  return (
    '<div class="' + rowClasses.join(" ") + '" data-adapter-row="' + esc(a.id) + '">' +
      '<div class="ad-row-main">' +
        '<div class="ad-row-head"><span class="ad-row-id" title="' + esc(a.id) + '">' + esc(a.id) + "</span>" + badges.join("") + "</div>" +
        '<div class="ad-meta">' + meta.join(" · ") + "</div>" +
        why +
      "</div>" +
      '<div class="ad-actions">' + actions.join("") + "</div>" +
    "</div>"
  );
}

/** Full table body: a stack-mode toggle + composed-spec bar (when picks
 *  exist), then one section of rows. Exported so tests/web-app.test.ts can
 *  exercise esc() discipline without a live DOM/network. */
export function renderAdaptersBodyHtml(state: AdaptersPanelState): string {
  if (!state.available.length) {
    return (
      '<div class="ad-empty">No adapters found on disk yet.<br>' +
      "Fine-tune one in the Developer tab, or drop an adapter directory into " +
      "<code>~/.cache/mlx-bun/adapters</code>.</div>"
    );
  }
  const selected = selectedIds(state);
  const stackModeOn = state.stackPicks.size > 0 || selected.size > 1;
  const rows = state.available.map((a) => renderAdapterRow(a, {
    mountedInfo: state.mounted.get(a.id),
    isSelected: selected.has(a.id),
    stackPicked: state.stackPicks.has(a.id),
    stackModeOn,
  })).join("");
  const picks = [...state.stackPicks];
  const stackBar = picks.length
    ? '<div class="ad-stack-bar"><span class="lbl">Stack:</span><span class="expr">' +
        esc(picks.join(" + ")) + '</span><button type="button" id="ad-stack-apply" class="ad-actions-btn">Apply</button>' +
        '<button type="button" id="ad-stack-clear" class="ad-actions-btn">Clear</button></div>'
    : "";
  return (
    '<div class="ad-note">Every adapter found on disk, mounted or not. Mounting loads it into ' +
    "memory (RAM cost shown once mounted); selecting makes it active for this chat's next turn " +
    "(a fresh KV segment). Tick two mounted adapters' “stack” boxes to compose them as " +
    '<code>a+b</code> — the server already supports it end to end.</div>' +
    stackBar +
    '<div class="ad-sec-title">On disk (' + state.available.length + ")</div>" +
    rows
  );
}

function renderAdaptersBody(state: AdaptersPanelState, send: Send): void {
  const body = $("adapters-body");
  if (!body) return;
  body.innerHTML = renderAdaptersBodyHtml(state);
  wireRowActions(state, send);
}

function wireRowActions(state: AdaptersPanelState, send: Send): void {
  const body = $("adapters-body");
  if (!body) return;
  body.querySelectorAll<HTMLButtonElement>(".ad-mount").forEach((btn) => {
    btn.onclick = async () => {
      const id = btn.dataset.id!, path = btn.dataset.path!;
      btn.disabled = true; btn.textContent = "Mounting…";
      const r = await api("/v1/adapters", { method: "POST", body: { id, path } });
      if (r && (r.error || r.ok === false)) {
        toast("adapter: " + (r.error || "mount failed"), "err");
        btn.disabled = false; btn.textContent = "Mount";
        return;
      }
      toast("mounted " + id, "ok");
      await refreshAdaptersPanel(state, send);
    };
  });
  body.querySelectorAll<HTMLButtonElement>(".ad-select").forEach((btn) => {
    btn.onclick = () => {
      const id = btn.dataset.id!;
      state.selectedSpec = id;
      state.stackPicks.clear();
      send({ type: "set_adapter", id });
      const sel = $("chat-adapter") as HTMLSelectElement | null;
      if (sel && [...sel.options].some((o) => o.value === id)) sel.value = id;
      toast("adapter selected — new turns start a fresh KV segment", "ok");
      renderAdaptersBody(state, send);
    };
  });
  body.querySelectorAll<HTMLButtonElement>(".ad-unselect").forEach((btn) => {
    btn.onclick = () => {
      state.selectedSpec = null;
      send({ type: "set_adapter", id: null });
      const sel = $("chat-adapter") as HTMLSelectElement | null;
      if (sel) sel.value = "";
      renderAdaptersBody(state, send);
    };
  });
  body.querySelectorAll<HTMLInputElement>(".ad-stack-pick").forEach((chk) => {
    chk.onchange = () => {
      const id = chk.dataset.id!;
      if (chk.checked) state.stackPicks.add(id); else state.stackPicks.delete(id);
      renderAdaptersBody(state, send);
    };
  });
  const apply = $("ad-stack-apply") as HTMLButtonElement | null;
  if (apply) apply.onclick = () => {
    if (state.stackPicks.size < 2) { toast("stack needs at least two ticked adapters", "err"); return; }
    const spec = [...state.stackPicks].join("+");
    state.selectedSpec = spec;
    send({ type: "set_adapter", id: spec });
    const sel = $("chat-adapter") as HTMLSelectElement | null;
    if (sel) sel.value = ""; // composite spec has no matching single <option>
    toast("stacked " + spec + " — new turns start a fresh KV segment", "ok");
    renderAdaptersBody(state, send);
  };
  const clear = $("ad-stack-clear") as HTMLButtonElement | null;
  if (clear) clear.onclick = () => { state.stackPicks.clear(); renderAdaptersBody(state, send); };
}

function openPanel(state: AdaptersPanelState, send: Send): void {
  const ov = $("adapters-overlay");
  ov.classList.add("open");
  $("adapters-manage").setAttribute("aria-expanded", "true");
  if (trap) trap.capture();
  refreshAdaptersPanel(state, send);
}
export function closeAdaptersPanel(): void {
  $("adapters-overlay").classList.remove("open");
  $("adapters-manage").setAttribute("aria-expanded", "false");
  if (trap) trap.restore();
}

/** Wire the ⚙ button + overlay close affordances. Escape is handled by the
 *  global closeTopOverlay sweep in shell.ts (one mechanism, not a bespoke
 *  listener per overlay — same pattern as the HF modal / sampling popover). */
export function initAdaptersPanel(state: AdaptersPanelState, send: Send): void {
  const btn = $("adapters-manage");
  if (!btn) return;
  trap = trapFocus($("adapters-panel"), () => $("adapters-overlay").classList.contains("open"));
  btn.onclick = () => openPanel(state, send);
  const close = $("adapters-close");
  if (close) close.onclick = closeAdaptersPanel;
  $("adapters-overlay").addEventListener("click", (e) => { if (e.target === $("adapters-overlay")) closeAdaptersPanel(); });
  setAdaptersPanelClose(closeAdaptersPanel);
}
