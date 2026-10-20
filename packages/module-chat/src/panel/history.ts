// The thread as the server replays it (a `history` frame rebuilds it wholesale) and the actions on its messages:
// Copy on every message, Regenerate on the last reply, Edit on the last user message, and the `< i/n >` toggle between
// the sibling branches that editing and regenerating create. Regenerate and edit re-prompt on a new branch without a
// `history` frame, so the controller drops the stale reply itself; these functions only draw.
import { el } from "@mlx-bun/web-kit";
import type { HistoryItem } from "../protocol";
import type { ChatHost } from "./host";
import { ICON } from "./icons";
import { highlightIn, mdToHtml } from "./markdown";
import { assistantShell, thinkingBox, toolCard } from "./turn";

export interface SiblingInfo {
  entryId: string | null;
  index: number;
  count: number;
  siblingIds: string[];
}

export function newSiblingInfo(): SiblingInfo {
  return { entryId: null, index: 0, count: 0, siblingIds: [] };
}

/** The sibling to move to (`delta` ±1), or null when there is none. */
export function switchSiblingTarget(info: SiblingInfo, delta: number): string | null {
  return (info.siblingIds || [])[info.index - 1 + delta] ?? null;
}

export interface MsgActionOpts {
  regenerate?: boolean;
  edit?: boolean;
}

function actionButton(row: HTMLElement, action: string, icon: string, label: string, title?: string): HTMLButtonElement {
  const button = el("button", "maction", row);
  button.type = "button";
  button.dataset.action = action;
  button.innerHTML = icon + "<span></span>";
  button.querySelector("span")!.textContent = label;
  if (title) button.title = title;
  return button;
}

/** Appends a message's action row. `text` is the raw source (markdown for a reply, plain text for the user), never
 * the rendered HTML, so Copy puts back exactly what was said. Copy is always the first action. */
export function addMsgActions(m: HTMLElement, text: string, opts: MsgActionOpts, handlers: { onRegenerate?(): void; onEdit?(m: HTMLElement): void }): HTMLElement {
  const row = el("div", "msg-actions", m);
  const copy = actionButton(row, "copy", ICON.copy, "Copy");
  copy.addEventListener("click", () => {
    if (!navigator.clipboard) return;
    navigator.clipboard.writeText(text || "").then(() => {
      copy.querySelector("span")!.textContent = "Copied";
      setTimeout(() => { copy.querySelector("span")!.textContent = "Copy"; }, 1200);
    }).catch(() => {});
  });
  if (opts.regenerate) actionButton(row, "regenerate", ICON.regenerate, "Regenerate", "Run this reply again (the old one stays on disk as a branch)")
    .addEventListener("click", () => handlers.onRegenerate?.());
  if (opts.edit) actionButton(row, "edit", ICON.edit, "Edit", "Edit and resend (the original stays as a numbered branch)")
    .addEventListener("click", () => handlers.onEdit?.(m));
  return row;
}

/** Only one reply offers Regenerate: the previous last one loses it when a newer reply settles. */
export function dropRegenerate(m: HTMLElement | null): void {
  m?.querySelector('.msg-actions .maction[data-action="regenerate"]')?.remove();
}

/** Draws (or clears) the `< i/n >` toggle on the last user message; hidden when there is one branch, or when the
 * frame describes another entry than the one shown. */
export function renderSiblingToggle(lastUser: HTMLElement | null, lastUserEntryId: string | null, info: SiblingInfo, onSwitch: (delta: number) => void): void {
  if (!lastUser) return;
  let box = lastUser.querySelector<HTMLElement>(".sib-toggle");
  if (info.count <= 1 || info.entryId !== lastUserEntryId) { box?.remove(); return; }
  if (!box) {
    box = el("div", "sib-toggle", null);
    box.setAttribute("role", "group");
    box.setAttribute("aria-label", "Branches of this message");
    lastUser.insertBefore(box, lastUser.firstChild);
  }
  const { index, count } = info;
  box.innerHTML =
    '<button class="sib-prev btn icon sm quiet" type="button" aria-label="Previous branch"' + (index <= 1 ? " disabled" : "") + ">" + ICON.chevron + "</button>" +
    '<span class="num">' + index + " / " + count + "</span>" +
    '<button class="sib-next btn icon sm quiet" type="button" aria-label="Next branch"' + (index >= count ? " disabled" : "") + ">" + ICON.chevron + "</button>";
  box.querySelector(".sib-prev")!.addEventListener("click", () => onSwitch(-1));
  box.querySelector(".sib-next")!.addEventListener("click", () => onSwitch(1));
}

export interface UserAttachment { kind: string; data?: string; mimeType?: string; name: string }

/** A user message: right-aligned text on a raised surface, with its attachments. */
export function addUserMessage(thread: HTMLElement, text: string, attachments: readonly UserAttachment[] | null): HTMLElement {
  const m = el("div", "msg user", thread);
  el("div", "who sr-only", m).textContent = "You";
  const bubble = el("div", "bubble", m);
  if (attachments?.length) {
    const wrap = el("div", "msg-atts", bubble);
    for (const attachment of attachments) {
      if (attachment.kind === "image") {
        const image = el("img", "msg-att-img", wrap);
        image.src = "data:" + attachment.mimeType + ";base64," + attachment.data;
        image.alt = attachment.name;
      } else {
        const file = el("span", "msg-att-file", wrap);
        file.innerHTML = ICON.file + "<span></span>";
        file.querySelector("span")!.textContent = attachment.name;
      }
    }
  }
  if (text) el("div", "msg-text", bubble).textContent = text;
  return m;
}

/** A finished reply from replayed history: thinking, the text, and its tool calls (the host's card where it draws one). */
export function addAssistantMessage(thread: HTMLElement, item: HistoryItem, host: ChatHost | undefined): HTMLElement {
  const { m, bubble } = assistantShell(thread);
  if (item.thinking && item.thinking.trim()) thinkingBox(bubble).body.textContent = item.thinking;
  if (item.text) { const text = el("div", "atext", bubble); text.innerHTML = mdToHtml(item.text); highlightIn(text); }
  for (const tool of item.tools || []) {
    const custom = host?.toolCard?.(bubble, tool.name, tool.args);
    if (custom) { if (tool.result) custom.setResult(tool.result); continue; }
    toolCard(bubble, tool.name, tool.args, "ok", tool.result ? String(tool.result).slice(-12000) : undefined);
  }
  return m;
}

export interface HistoryHandlers {
  onRegenerate(): void;
  onEdit(m: HTMLElement): void;
  onSwitchSibling(delta: number): void;
}

/** The last user message and reply of a rebuilt thread: the ones that carry Edit and Regenerate. */
export interface ThreadEnds {
  lastUser: { el: HTMLElement; entryId: string | null } | null;
  lastAssistant: HTMLElement | null;
}

/** Rebuilds the thread from a `history` frame (the caller clears it first). */
export function renderHistory(thread: HTMLElement, items: readonly HistoryItem[], host: ChatHost | undefined, siblings: SiblingInfo, handlers: HistoryHandlers): ThreadEnds {
  const ends: ThreadEnds = { lastUser: null, lastAssistant: null };
  const roles = items.map((item) => item.role);
  const lastUserIdx = roles.lastIndexOf("user"), lastAssistantIdx = roles.lastIndexOf("assistant");
  items.forEach((item, i) => {
    if (item.role === "user") {
      const m = addUserMessage(thread, item.text, null);
      if (i !== lastUserIdx) return;
      ends.lastUser = { el: m, entryId: item.entryId || null };
      addMsgActions(m, item.text, { edit: true }, { onEdit: handlers.onEdit });
      renderSiblingToggle(m, ends.lastUser.entryId, siblings, handlers.onSwitchSibling);
      return;
    }
    const m = addAssistantMessage(thread, item, host);
    if (!item.text) return;
    addMsgActions(m, item.text, { regenerate: i === lastAssistantIdx }, { onRegenerate: handlers.onRegenerate });
    if (i === lastAssistantIdx) ends.lastAssistant = m;
  });
  return ends;
}

/** Turns the last user message into an inline editor. Escape or Cancel restores it; Enter or Send calls `onSend`,
 * which returns false when the edit could not be sent (the editor stays open). */
export function startEdit(m: HTMLElement, onSend: (text: string) => boolean): void {
  const textEl = m.querySelector<HTMLElement>(".bubble .msg-text");
  if (!textEl) return;
  const box = document.createElement("textarea");
  box.className = "msg-edit-box textarea";
  box.value = textEl.textContent || "";
  box.setAttribute("aria-label", "Edit your message");
  const actions = el("div", "msg-edit-actions", null);
  const cancel = el("button", "btn sm quiet", actions);
  cancel.type = "button"; cancel.textContent = "Cancel";
  const send = el("button", "btn primary sm", actions);
  send.type = "button"; send.textContent = "Send";
  textEl.replaceWith(box);
  box.after(actions);
  box.focus(); box.setSelectionRange(box.value.length, box.value.length);
  const restore = () => { box.replaceWith(textEl); actions.remove(); };
  const submit = () => {
    const text = box.value.trim();
    if (!text || !onSend(text)) return;
    textEl.textContent = text;
    restore();
  };
  cancel.onclick = restore;
  send.onclick = submit;
  box.addEventListener("keydown", (event) => {
    if (event.key === "Escape") { event.preventDefault(); event.stopPropagation(); restore(); }
    else if (event.key === "Enter" && !event.shiftKey) { event.preventDefault(); submit(); }
  });
}
