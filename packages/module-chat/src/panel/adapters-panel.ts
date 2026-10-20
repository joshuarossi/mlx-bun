// The adapter routing table behind the composer's adapters button: every adapter on disk with its three states
// (on disk, mounted, selected for this chat), base model, rank, size on disk and RAM cost once mounted, incompatible
// ones grayed with the reason. Actions: mount, select, unselect, and stack two mounted adapters as `a+b` (composite ids
// are supported end to end). The composer's quick select and this table fetch the same routes independently, but
// they never disagree about what is selected: each writes the selection through to the other.
import { $, errorOf, esc, trapFocus, type Api, type FocusTrap } from "@mlx-bun/web-kit";
import type { ClientMessage } from "../protocol";
import { toast } from "./host";
import { setPopoverClose } from "./popovers";

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

type Send = (frame: ClientMessage) => boolean;

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

/** Fetches both adapter routes and redraws the table, its actions wired against `send`. */
export async function refreshAdaptersPanel(state: AdaptersPanelState, send: Send, api: Api): Promise<void> {
  const [availD, mountedD] = await Promise.all([api.get("/v1/adapters/available"), api.get("/v1/adapters")]);
  state.available = ((availD as { adapters?: AvailableAdapterRow[] }).adapters) || [];
  const mountedList = ((mountedD as { adapters?: MountedAdapterRow[] }).adapters) || [];
  state.mounted = new Map(mountedList.map((a) => [a.id, a]));
  // Drop stack picks for adapters that vanished from disk (e.g. an
  // in-flight delete elsewhere).
  for (const id of [...state.stackPicks]) if (!state.available.some((a) => a.id === id)) state.stackPicks.delete(id);
  renderAdaptersBody(state, send, api);
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
 *  exist), then one section of rows. Exported so packages/module-chat/tests/panel.test.ts can
 *  exercise esc() discipline without a live DOM/network. */
export function renderAdaptersBodyHtml(state: AdaptersPanelState): string {
  if (!state.available.length) {
    return (
      '<div class="ad-empty empty"><h3>No adapters found on disk yet.</h3>' +
      "Fine-tune one under Developer tools, or put an adapter directory in " +
      "<code>~/.mlx-bun/adapters</code>.</div>"
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
        esc(picks.join(" + ")) + '</span><button type="button" id="ad-stack-apply" class="ad-actions-btn btn primary sm">Apply</button>' +
        '<button type="button" id="ad-stack-clear" class="ad-actions-btn btn sm">Clear</button></div>'
    : "";
  return (
    '<div class="ad-note">Every adapter on disk, mounted or not. Mounting loads it into memory (its RAM cost ' +
    "shows once mounted); selecting makes it answer this chat's next turns, which start a fresh KV cache segment. " +
    "Tick “stack” on two mounted adapters to compose them as <code>a+b</code>.</div>" +
    stackBar +
    '<div class="ad-sec-title">On disk (' + state.available.length + ")</div>" +
    rows
  );
}

function renderAdaptersBody(state: AdaptersPanelState, send: Send, api: Api): void {
  const body = $("adapters-body");
  if (!body) return;
  body.innerHTML = renderAdaptersBodyHtml(state);
  wireRowActions(state, send, api);
}

function wireRowActions(state: AdaptersPanelState, send: Send, api: Api): void {
  const body = $("adapters-body");
  if (!body) return;
  body.querySelectorAll<HTMLButtonElement>(".ad-mount").forEach((btn) => {
    btn.onclick = async () => {
      const id = btn.dataset.id!, path = btn.dataset.path!;
      btn.disabled = true; btn.textContent = "Mounting…";
      const r = await api.post("/v1/adapters", { id, path });
      if (r.error || r.ok === false) {
        toast("Could not mount " + id + ": " + errorOf(r, "mount failed"), "err");
        btn.disabled = false; btn.textContent = "Mount";
        return;
      }
      toast("Mounted " + id + ".", "ok");
      await refreshAdaptersPanel(state, send, api);
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
      toast("Adapter selected. New turns start a fresh KV cache segment.", "ok");
      renderAdaptersBody(state, send, api);
    };
  });
  body.querySelectorAll<HTMLButtonElement>(".ad-unselect").forEach((btn) => {
    btn.onclick = () => {
      state.selectedSpec = null;
      send({ type: "set_adapter", id: null });
      const sel = $("chat-adapter") as HTMLSelectElement | null;
      if (sel) sel.value = "";
      renderAdaptersBody(state, send, api);
    };
  });
  body.querySelectorAll<HTMLInputElement>(".ad-stack-pick").forEach((chk) => {
    chk.onchange = () => {
      const id = chk.dataset.id!;
      if (chk.checked) state.stackPicks.add(id); else state.stackPicks.delete(id);
      renderAdaptersBody(state, send, api);
    };
  });
  const apply = $("ad-stack-apply") as HTMLButtonElement | null;
  if (apply) apply.onclick = () => {
    if (state.stackPicks.size < 2) { toast("Tick at least two mounted adapters to stack them.", "err"); return; }
    const spec = [...state.stackPicks].join("+");
    state.selectedSpec = spec;
    send({ type: "set_adapter", id: spec });
    const sel = $("chat-adapter") as HTMLSelectElement | null;
    if (sel) sel.value = ""; // composite spec has no matching single <option>
    toast("Stacked " + spec + ". New turns start a fresh KV cache segment.", "ok");
    renderAdaptersBody(state, send, api);
  };
  const clear = $("ad-stack-clear") as HTMLButtonElement | null;
  if (clear) clear.onclick = () => { state.stackPicks.clear(); renderAdaptersBody(state, send, api); };
}

// Told when the sheet opens or closes (the assistant reports it as the current view).
let onToggle: (() => void) | undefined;

/** The sheet is open (the assistant's `adapters-panel` view). */
export function adaptersPanelOpen(): boolean {
  return !!$("adapters-overlay")?.classList.contains("open");
}

function openPanel(state: AdaptersPanelState, send: Send, api: Api): void {
  if (trap) trap.capture();
  $("adapters-overlay").classList.add("open");
  $("adapters-manage").setAttribute("aria-expanded", "true");
  $("adapters-close")?.focus();
  onToggle?.();
  void refreshAdaptersPanel(state, send, api);
}
export function closeAdaptersPanel(): void {
  const wasOpen = adaptersPanelOpen();
  $("adapters-overlay").classList.remove("open");
  $("adapters-manage").setAttribute("aria-expanded", "false");
  if (trap) trap.restore();
  if (wasOpen) onToggle?.();
}

/** Wires the adapters button and the table's close controls. Escape closes it through the host's sweep. `toggled` is
 * called after the sheet opens or closes. */
export function initAdaptersPanel(state: AdaptersPanelState, send: Send, api: Api, toggled?: () => void): void {
  onToggle = toggled;
  const btn = $("adapters-manage");
  if (!btn) return;
  trap = trapFocus($("adapters-panel"), () => $("adapters-overlay").classList.contains("open"));
  btn.onclick = () => openPanel(state, send, api);
  const close = $("adapters-close");
  if (close) close.onclick = closeAdaptersPanel;
  $("adapters-overlay").addEventListener("click", (e) => { if (e.target === $("adapters-overlay")) closeAdaptersPanel(); });
  setPopoverClose("adapters-overlay", closeAdaptersPanel);
}
