// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// Recent-chats sidebar (list/search/fork/delete), the last-user-message
// sibling `< i/n >` toggle (edit-and-resend branching, plan §5.2), and the
// per-message action row (copy/regenerate/edit). Extracted from the
// original monolithic controllers.chat closure in app.html — behavior
// identical, but state that used to be closed-over local variables is now
// passed explicitly (SidebarState/SiblingState) so this module has no
// hidden coupling to chat.ts beyond what's passed in.

import type { SessionListItem } from "../../pi-web";
import { $, el } from "./shell";

/* ────────────────────────────────────────────────────────────────────
   Sidebar (session list + search)
   ──────────────────────────────────────────────────────────────────── */

export interface SidebarCallbacks {
  onOpen(path: string): void;
  onFork(path: string): void;
  onDelete(path: string): void;
}

/** Mutable box so renderSessions/applySessSearch share the last-rendered
 *  item list without a module-level global (kept per chat-controller
 *  instance — there's only ever one, but this avoids reintroducing a
 *  bare module-level `let` for state that's really the controller's). */
export interface SidebarState {
  lastSessionItems: SessionListItem[];
}

export function newSidebarState(): SidebarState {
  return { lastSessionItems: [] };
}

function relTime(ms: number | undefined): string {
  if (!ms) return "";
  const s = (Date.now() - ms) / 1000;
  if (s < 60) return "just now";
  if (s < 3600) return Math.floor(s / 60) + "m ago";
  if (s < 86400) return Math.floor(s / 3600) + "h ago";
  if (s < 604800) return Math.floor(s / 86400) + "d ago";
  try { return new Date(ms).toLocaleDateString(); } catch { return ""; }
}

// Local esc() to avoid importing markdown.ts's whole surface just for
// escaping — identical logic.
function esc(s: unknown): string {
  return String(s ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" } as Record<string, string>)[c]!);
}

export function renderSessions(state: SidebarState, items: SessionListItem[] | undefined, activePath: string | undefined, cb: SidebarCallbacks): void {
  state.lastSessionItems = items || [];
  const box = $("chat-sessions");
  if (!items || !items.length) { box.innerHTML = '<div class="sessempty">No saved chats yet. Your conversations are saved locally here.</div>'; return; }
  box.innerHTML = "";
  for (const s of items) {
    const row = el("div", "sess" + (s.path === activePath ? " active" : ""), box);
    row.dataset.title = (s.title || "New chat").toLowerCase();
    row.innerHTML =
      '<div class="stitle">' + esc(s.title || "New chat") + '</div>' +
      '<div class="smeta"><span>' + esc(relTime(s.modified)) + '</span>' +
        (s.messageCount ? '<span>· ' + s.messageCount + ' msg' + (s.messageCount === 1 ? '' : 's') + '</span>' : '') +
        (s.forked ? '<span>· forked</span>' : '') + '</div>' +
      '<button class="sbtn sfork" title="New chat from here">⑂</button>' +
      '<button class="sbtn sdel" title="Delete chat">✕</button>';
    row.addEventListener("click", () => { cb.onOpen(s.path); });
    row.querySelector(".sfork")!.addEventListener("click", (e) => { e.stopPropagation(); cb.onFork(s.path); });
    row.querySelector(".sdel")!.addEventListener("click", (e) => { e.stopPropagation(); cb.onDelete(s.path); });
  }
  applySessSearch(state);
}

/** Client-side substring filter over session titles (no server round
 *  trip). Re-applied after every re-render since #chat-sessions is
 *  rebuilt wholesale on each `sessions` frame. */
export function applySessSearch(state: SidebarState): void {
  const input = $("chat-sess-search") as HTMLInputElement | null;
  const q = input ? input.value.trim().toLowerCase() : "";
  const rows = $("chat-sessions").querySelectorAll<HTMLElement>(".sess");
  let anyVisible = false;
  rows.forEach((row) => {
    const match = !q || (row.dataset.title || "").includes(q);
    row.classList.toggle("sess-hidden", !match);
    if (match) anyVisible = true;
  });
  let empty = $("chat-sessions").querySelector(".sess-search-empty");
  if (q && !anyVisible && state.lastSessionItems.length) {
    if (!empty) { empty = el("div", "sessempty sess-search-empty", $("chat-sessions")); }
    empty.textContent = "No chats match “" + q + "”.";
  } else if (empty) {
    empty.remove();
  }
}

/* ────────────────────────────────────────────────────────────────────
   Message actions (copy / regenerate / edit) + sibling toggle
   ──────────────────────────────────────────────────────────────────── */

export interface SiblingInfo {
  entryId: string | null;
  index: number;
  count: number;
  siblingIds: string[];
}

export function newSiblingInfo(): SiblingInfo {
  return { entryId: null, index: 0, count: 0, siblingIds: [] };
}

export interface MsgActionOpts {
  regenerate?: boolean;
  edit?: boolean;
}

/** Append a hover/focus action row to a message element. `text` is the
 *  RAW SOURCE (markdown for assistant, plain for user) — never innerHTML —
 *  so Copy puts back exactly what the model said / the user typed.
 *  `onRegenerate`/`onEdit` are the click handlers (owned by chat.ts, which
 *  knows about the WS connection and turnActive state this module doesn't). */
export function addMsgActions(
  m: HTMLElement,
  text: string,
  opts: MsgActionOpts,
  handlers: { onRegenerate?: () => void; onEdit?: (m: HTMLElement) => void },
): HTMLElement {
  const row = el("div", "msg-actions", m);
  const copyBtn = el("button", "maction", row);
  copyBtn.type = "button"; copyBtn.textContent = "Copy";
  copyBtn.addEventListener("click", () => {
    if (!navigator.clipboard) return;
    navigator.clipboard.writeText(text || "").then(() => {
      copyBtn.textContent = "Copied"; setTimeout(() => { copyBtn.textContent = "Copy"; }, 1200);
    }).catch(() => {});
  });
  if (opts.regenerate) {
    const btn = el("button", "maction", row);
    btn.type = "button"; btn.textContent = "Regenerate";
    btn.title = "Re-run this reply (keeps the old one on disk as a branch)";
    btn.addEventListener("click", () => { handlers.onRegenerate && handlers.onRegenerate(); });
  }
  if (opts.edit) {
    const btn = el("button", "maction", row);
    btn.type = "button"; btn.textContent = "Edit";
    btn.title = "Edit and resend — keeps the original as a numbered branch";
    btn.addEventListener("click", () => { handlers.onEdit && handlers.onEdit(m); });
  }
  return row;
}

/** Render (or clear) the `< i/n >` sibling toggle above the last user
 *  message. Rebuilt whenever a `siblings` frame arrives or the thread is
 *  rebuilt. Hidden entirely when count <= 1 (the common no-edits case). */
export function renderSiblingToggle(
  lastUserMsgEl: HTMLElement | null,
  lastUserEntryId: string | null,
  siblingInfo: SiblingInfo,
  onSwitch: (delta: number) => void,
): void {
  if (!lastUserMsgEl) return;
  let box = lastUserMsgEl.querySelector(".sib-toggle") as HTMLElement | null;
  if (siblingInfo.count <= 1 || siblingInfo.entryId !== lastUserEntryId) {
    if (box) box.remove();
    return;
  }
  if (!box) {
    box = el("div", "sib-toggle", null);
    lastUserMsgEl.insertBefore(box, lastUserMsgEl.firstChild);
  }
  const { index, count } = siblingInfo;
  box.innerHTML =
    '<button class="sib-prev" type="button" ' + (index <= 1 ? "disabled" : "") + '>&lt;</button>' +
    '<span>' + index + '/' + count + '</span>' +
    '<button class="sib-next" type="button" ' + (index >= count ? "disabled" : "") + '>&gt;</button>';
  box.querySelector(".sib-prev")!.addEventListener("click", () => onSwitch(-1));
  box.querySelector(".sib-next")!.addEventListener("click", () => onSwitch(1));
}

/** Resolve the sibling target id for a +-1 direction move from siblingInfo,
 *  or null if there's no such neighbor (caller should no-op). Pure — split
 *  out from the button wiring above so it's independently testable. */
export function switchSiblingTarget(siblingInfo: SiblingInfo, delta: number): string | null {
  const ids = siblingInfo.siblingIds || [];
  return ids[siblingInfo.index - 1 + delta] ?? null;
}
