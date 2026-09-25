import type { ImageContent } from "@earendil-works/pi-ai";
import type { SessionEntry, SessionInfo } from "@earendil-works/pi-coding-agent";
import type { ImageAttachment, HistoryToolItem, HistoryItem, SessionListItem } from "./protocol";

/** Flatten a content value (string | content-parts) to its text. */
function contentText(content: unknown): string {
  if (typeof content === "string") return content;
  if (Array.isArray(content)) {
    return content
      .filter((p): p is { type: string; text: string } =>
        !!p && (p as { type?: string }).type === "text" && typeof (p as { text?: unknown }).text === "string")
      .map((p) => p.text)
      .join("");
  }
  return "";
}

function contentThinking(content: unknown): string {
  if (!Array.isArray(content)) return "";
  return content
    .filter((p): p is { type: string; thinking: string } =>
      !!p && (p as { type?: string }).type === "thinking" && typeof (p as { thinking?: unknown }).thinking === "string")
    .map((p) => p.thinking)
    .join("");
}

/**
 * Turn a session's entries into a flat, browser-renderable transcript.
 *
 * Walks message entries in order: user/assistant text become items, the
 * assistant's toolCall parts become tool items, and each later toolResult
 * is merged back onto its tool by callId. Non-message entries (model
 * changes, compaction, thinking) are skipped. Pure so it's unit-tested
 * without a live session.
 */
export function serializeHistory(entries: readonly SessionEntry[]): HistoryItem[] {
  const items: HistoryItem[] = [];
  for (const entry of entries) {
    if (entry.type !== "message") continue;
    const m = (entry as { message?: unknown }).message as
      | { role?: string; content?: unknown; toolCallId?: string }
      | undefined;
    if (!m) continue;
    if (m.role === "user") {
      const text = contentText(m.content);
      if (text.trim()) items.push({ role: "user", text, tools: [], entryId: entry.id });
    } else if (m.role === "assistant") {
      const parts = Array.isArray(m.content) ? (m.content as unknown[]) : [];
      const text = contentText(parts);
      const thinking = contentThinking(parts);
      const tools: HistoryToolItem[] = parts
        .filter((p): p is { type: string; id?: unknown; name?: unknown; arguments?: unknown } =>
          !!p && (p as { type?: string }).type === "toolCall")
        .map((p) => ({ callId: String(p.id ?? ""), name: String(p.name ?? "tool"), args: p.arguments, result: "" }));
      if (text.trim() || thinking.trim() || tools.length > 0)
        items.push({ role: "assistant", text, ...(thinking.trim() ? { thinking } : {}), tools });
    } else if (m.role === "toolResult") {
      const callId = String(m.toolCallId ?? "");
      const result = contentText(m.content);
      for (let i = items.length - 1; i >= 0; i--) {
        const it = items[i];
        if (!it) continue;
        const tool = it.tools.find((t) => t.callId === callId);
        if (tool) {
          tool.result = result;
          break;
        }
      }
    }
  }
  return items;
}

/** Map browser image attachments to pi's ImageContent shape (or undefined). */
export function toPiImages(images?: ImageAttachment[]): ImageContent[] | undefined {
  if (!images || images.length === 0) return undefined;
  return images.map((i) => ({ type: "image", data: i.data, mimeType: i.mimeType }));
}

// ---- Message actions: regenerate / edit-and-resend (pure helpers) ----
//
// Both features reuse ONE pi SDK primitive: AgentSession.navigateTree(entryId)
// on a user-message entry moves the session's leaf pointer to that entry's
// PARENT (without deleting anything) and returns the message's own text in
// `editorText`. Calling session.prompt(...) right after appends a NEW child
// under that same parent — i.e. a sibling of the original message, in the
// SAME session file. This is exactly "regenerate" (re-send the identical
// content) and "edit-and-resend" (re-send edited content) without any
// file-level fork/session spam (plan §5.2's explicit constraint).
//
// navigateTree's own editorText is TEXT-ONLY (pi's editor-reopen use case
// doesn't carry images). We extract the full original `content` ourselves
// (text + images) from the entry directly so regenerate/edit-resend don't
// silently drop image attachments — a small improvement over what the SDK
// primitive alone would give us.

/** One user message entry as found by findLastUserMessageEntry/userMessageSiblings. */
export interface UserMessageEntryInfo {
  id: string;
  parentId: string | null;
  text: string;
  images: ImageContent[];
}

/** Extract {text, images} from a user message's raw `content` field
 *  (string | (TextContent|ImageContent)[]). Pure. */
function extractUserContent(content: unknown): { text: string; images: ImageContent[] } {
  if (typeof content === "string") return { text: content, images: [] };
  if (Array.isArray(content)) {
    const text = contentText(content);
    const images = (content as unknown[])
      .filter((p): p is { type: string; data: string; mimeType: string } =>
        !!p && (p as { type?: string }).type === "image" &&
        typeof (p as { data?: unknown }).data === "string" && typeof (p as { mimeType?: unknown }).mimeType === "string")
      .map((p) => ({ type: "image" as const, data: p.data, mimeType: p.mimeType }));
    return { text, images };
  }
  return { text: "", images: [] };
}

/** Find the LAST user-message entry in a session's entries (in append order).
 *  Used by both `regenerate` (re-send it as-is) and as the sibling group's
 *  anchor for `edit_resend` (always edits the last user message — plan §5.2
 *  scopes this to the last message, not any earlier one). Pure. */
export function findLastUserMessageEntry(entries: readonly SessionEntry[]): UserMessageEntryInfo | undefined {
  for (let i = entries.length - 1; i >= 0; i--) {
    const e = entries[i];
    if (!e || e.type !== "message") continue;
    const m = (e as { message?: { role?: string; content?: unknown } }).message;
    if (m?.role !== "user") continue;
    const { text, images } = extractUserContent(m.content);
    return { id: e.id, parentId: e.parentId, text, images };
  }
  return undefined;
}

/** Sibling group (edit history) for a user message: every user-message entry
 *  sharing the same parentId, in append order, plus the 1-based index of
 *  `entryId` within that group. Drives the browser's `< i/n >` toggle. Pure. */
export interface SiblingGroup {
  parentId: string | null;
  siblingIds: string[];
  index: number; // 1-based position of the queried entryId within siblingIds
}

export function userMessageSiblings(entries: readonly SessionEntry[], entryId: string): SiblingGroup | undefined {
  const target = entries.find((e) => e.id === entryId);
  if (!target) return undefined;
  const parentId = target.parentId;
  const siblingIds = entries
    .filter((e): e is SessionEntry & { type: "message" } =>
      e.type === "message" && e.parentId === parentId &&
      (e as { message?: { role?: string } }).message?.role === "user")
    .map((e) => e.id);
  const index = siblingIds.indexOf(entryId) + 1;
  if (index === 0) return undefined;
  return { parentId, siblingIds, index };
}

/** Walk DOWN from an entry to the deepest descendant, always following the
 *  MOST RECENTLY APPENDED child at each level (last in getChildren's
 *  insertion order) — i.e. "what would this branch show if it were the
 *  active leaf". Used by `switch_sibling` to resolve a sibling's own leaf
 *  (which may itself have further edits/regenerations under it) rather than
 *  just landing on the sibling's own root entry. Pure given a children-lookup
 *  function so it's unit-testable without a live SessionManager. */
export function deepestLeafFrom(fromId: string, getChildren: (parentId: string) => SessionEntry[]): string {
  let cur = fromId;
  for (;;) {
    const children = getChildren(cur);
    if (children.length === 0) return cur;
    cur = children[children.length - 1]!.id;
  }
}

/** Map pi's SessionInfo[] to sidebar rows, newest first. */
export function toSessionListItems(infos: readonly SessionInfo[]): SessionListItem[] {
  return infos
    .map((s) => ({
      path: s.path,
      id: s.id,
      title: ((s.name && s.name.trim()) || (s.firstMessage && s.firstMessage.trim()) || "New chat").slice(0, 80),
      modified: s.modified instanceof Date ? s.modified.getTime() : new Date(s.modified as unknown as string).getTime(),
      messageCount: s.messageCount,
      forked: !!s.parentSessionPath,
    }))
    .sort((a, b) => b.modified - a.modified);
}
