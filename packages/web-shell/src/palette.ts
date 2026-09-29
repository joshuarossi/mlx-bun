// Command palette (Cmd/Ctrl+K): a filterable overlay of sections. The shell owns the chrome, keyboard navigation and
// the debounced remote lookups; the host supplies what is searchable as sections (commands, recorded chats, message
// hits). Built entirely with createElement and its own injected styles, and lazily on first open.
import { el, injectStyles } from "./dom";
import { trapFocus, type FocusTrap } from "./focus";
import type { Overlay } from "./overlays";

export interface PaletteRow {
  label: string;
  /** Right-aligned shortcut hint. */
  hint?: string;
  /** Second line under the label (a message hit). */
  snippet?: string;
  run(): void | Promise<void>;
}

/** One headed group of rows. */
export interface PaletteSection {
  title: string;
  /** The rows for the (trimmed) query, computed on every keystroke: an empty query lists what the section offers
   * unprompted; a section that only makes sense for a query returns none for "". */
  rows(query: string): PaletteRow[];
  /** Rows fetched after a short debounce, for queries of two or more characters; they follow this section's own rows. */
  remote?(query: string): Promise<PaletteRow[]>;
}

export interface PaletteAction {
  label: string;
  hint?: string;
  /** Hidden while false (a command that only makes sense on one page). */
  when?(): boolean;
  run(): void | Promise<void>;
}

export interface Palette extends Overlay {
  open(): void;
  toggle(): void;
}

/** Fuzzy-ish filter: every character of `query` (in order, case-insensitive) must appear as a subsequence of the
 * candidate. A simple subsequence test, the basic case of every Cmd+K palette. */
export function fuzzyMatch(query: string, candidate: string): boolean {
  const q = query.toLowerCase();
  const c = candidate.toLowerCase();
  if (!q) return true;
  let qi = 0;
  for (let ci = 0; ci < c.length && qi < q.length; ci++) {
    if (c[ci] === q[qi]) qi++;
  }
  return qi === q.length;
}

/** A section listing commands: the available ones whose label fuzzy-matches the query. */
export function actionSection(title: string, actions: () => readonly PaletteAction[]): PaletteSection {
  return {
    title,
    rows: (query) => actions()
      .filter((a) => !a.when || a.when())
      .filter((a) => fuzzyMatch(query, a.label))
      .map((a) => ({ label: a.label, hint: a.hint, run: () => a.run() })),
  };
}

const STYLE_ID = "mlxbun-palette-style";
const DEBOUNCE_MS = 200;

function injectPaletteStyles(): void {
  injectStyles(STYLE_ID, `
#palette-overlay{position:fixed;inset:0;z-index:900;display:none;
  align-items:flex-start;justify-content:center;padding-top:12vh;
  background:rgba(0,0,0,.45);backdrop-filter:blur(2px);}
#palette-overlay.open{display:flex;}
@media (prefers-reduced-motion:no-preference){
  #palette-overlay.open .palette-box{animation:palette-in .15s ease-out;}
}
@keyframes palette-in{from{opacity:0;transform:translateY(-6px) scale(.98);}to{opacity:1;transform:none;}}
.palette-box{width:min(560px,92vw);max-height:70vh;display:flex;flex-direction:column;
  background:var(--bg,#000);border:1px solid var(--hairline-strong,rgba(255,255,255,.28));
  border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.5);overflow:hidden;}
.palette-input-row{border-bottom:1px solid var(--hairline,rgba(255,255,255,.14));padding:4px 4px;}
#palette-input{width:100%;box-sizing:border-box;background:transparent;border:0;outline:0;
  color:var(--ink,#fff);font-size:15px;padding:12px 14px;}
#palette-input::placeholder{color:var(--dimmer,#515154);}
.palette-list{overflow-y:auto;flex:1;padding:6px;}
.palette-section-hdr{font-size:11px;color:var(--dim,#86868b);text-transform:uppercase;
  letter-spacing:.04em;padding:8px 10px 4px;}
.palette-row{display:flex;align-items:center;justify-content:space-between;gap:8px;
  padding:9px 10px;border-radius:8px;cursor:pointer;color:var(--ink,#fff);font-size:13.5px;}
.palette-row:hover,.palette-row.active{background:var(--card-hover,rgba(255,255,255,.08));}
.palette-row .prow-label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.palette-row .prow-snippet{color:var(--dim,#86868b);font-size:11.5px;overflow:hidden;
  text-overflow:ellipsis;white-space:nowrap;margin-top:1px;}
.palette-row .prow-main{min-width:0;flex:1;}
.palette-row .prow-hint{color:var(--dimmer,#515154);font-size:11px;font-family:var(--mono,monospace);
  flex:0 0 auto;}
.palette-empty{color:var(--dim,#86868b);font-size:13px;padding:16px 10px;text-align:center;}
.palette-row mark{background:rgba(255,214,10,.35);color:inherit;border-radius:2px;}
`);
}

function esc(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

interface Entry { section: number; row: PaletteRow }

/** The palette over the given sections, in display order. Nothing is built until the first `open()`. Escape closes it
 * through the shell's overlay set (add the returned palette to it); it registers no key handling of its own beyond
 * arrow keys and Enter inside its input. */
export function createPalette(options: { sections: readonly PaletteSection[] }): Palette {
  const { sections } = options;
  let overlay: HTMLElement | null = null;
  let input: HTMLInputElement | null = null;
  let listEl: HTMLElement | null = null;
  let trap: FocusTrap | null = null;
  let selectedIndex = 0;
  let entries: Entry[] = [];
  let searchSeq = 0;
  let debounceTimer: ReturnType<typeof setTimeout> | undefined;

  const isOpen = () => !!overlay && overlay.classList.contains("open");

  function close(): void {
    if (!overlay) return;
    overlay.classList.remove("open");
    if (trap) trap.restore();
  }

  function open(): void {
    ensureBuilt();
    if (!overlay || !input || !trap) return;
    trap.capture();
    overlay.classList.add("open");
    input.value = "";
    void refreshResults("");
    setTimeout(() => input && input.focus(), 20);
  }

  function ensureBuilt(): void {
    if (overlay) return;
    injectPaletteStyles();
    overlay = el("div", "", document.body);
    overlay.id = "palette-overlay";
    overlay.setAttribute("role", "dialog");
    overlay.setAttribute("aria-modal", "true");
    overlay.setAttribute("aria-label", "Command palette");

    const box = el("div", "palette-box", overlay);
    const inputRow = el("div", "palette-input-row", box);
    input = el("input", "", inputRow);
    input.id = "palette-input";
    input.type = "text";
    input.placeholder = "Type a command or search…";
    input.autocomplete = "off";
    input.spellcheck = false;
    listEl = el("div", "palette-list", box);
    listEl.setAttribute("role", "listbox");

    overlay.addEventListener("click", (e) => { if (e.target === overlay) close(); });
    input.addEventListener("input", () => {
      if (debounceTimer) clearTimeout(debounceTimer);
      const q = input!.value;
      debounceTimer = setTimeout(() => { void refreshResults(q); }, DEBOUNCE_MS);
    });
    input.addEventListener("keydown", onKeydown);

    trap = trapFocus(overlay, isOpen);
  }

  function onKeydown(e: KeyboardEvent): void {
    if (e.key === "ArrowDown") { e.preventDefault(); move(1); return; }
    if (e.key === "ArrowUp") { e.preventDefault(); move(-1); return; }
    if (e.key === "Enter") { e.preventDefault(); activate(selectedIndex); return; }
  }

  function move(delta: number): void {
    if (!entries.length) return;
    selectedIndex = (selectedIndex + delta + entries.length) % entries.length;
    renderRows();
    const activeEl = listEl?.querySelector(".palette-row.active");
    if (activeEl) activeEl.scrollIntoView({ block: "nearest" });
  }

  function activate(index: number): void {
    const entry = entries[index];
    if (!entry) return;
    close();
    void entry.row.run();
  }

  /** Every section's own rows, then the remote rows fetched so far, grouped by section in display order. */
  function assemble(local: readonly PaletteRow[][], remote: ReadonlyMap<number, PaletteRow[]>): Entry[] {
    return sections.flatMap((_, section) => [...local[section]!, ...remote.get(section) ?? []].map((row) => ({ section, row })));
  }

  async function refreshResults(query: string): Promise<void> {
    selectedIndex = 0;
    const q = query.trim();
    const local = sections.map((section) => section.rows(q));
    const remote = new Map<number, PaletteRow[]>();
    entries = assemble(local, remote);
    renderRows();

    if (!q || q.length < 2) return;
    const seq = ++searchSeq;
    await Promise.all(sections.map(async (section, index) => {
      if (!section.remote) return;
      const rows = await section.remote(q).catch((): PaletteRow[] => []);
      if (seq !== searchSeq) return; // superseded by a newer keystroke
      if (input && input.value.trim() !== q) return;
      if (!rows.length) return;
      remote.set(index, rows);
      entries = assemble(local, remote);
      renderRows();
    }));
  }

  function renderRows(): void {
    if (!listEl) return;
    if (!entries.length) {
      listEl.innerHTML = '<div class="palette-empty">No matching commands or chats.</div>';
      return;
    }
    listEl.innerHTML = "";
    let lastSection = -1;
    entries.forEach(({ section, row: entry }, i) => {
      if (section !== lastSection) { el("div", "palette-section-hdr", listEl!).textContent = sections[section]!.title; lastSection = section; }
      const row = el("div", "palette-row" + (i === selectedIndex ? " active" : ""), listEl!);
      row.setAttribute("role", "option");
      row.dataset.index = String(i);
      row.innerHTML =
        '<div class="prow-main"><div class="prow-label">' + esc(entry.label) + "</div>" +
        (entry.snippet !== undefined ? '<div class="prow-snippet">' + esc(entry.snippet) + "</div>" : "") + "</div>" +
        (entry.hint ? '<span class="prow-hint">' + esc(entry.hint) + "</span>" : "");
      row.addEventListener("click", () => activate(i));
      row.addEventListener("mousemove", () => { if (selectedIndex !== i) { selectedIndex = i; renderRows(); } });
    });
  }

  return { isOpen, close, open, toggle: () => isOpen() ? close() : open() };
}
