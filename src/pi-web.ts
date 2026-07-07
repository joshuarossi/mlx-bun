// mlx-bun pi-web — server-side embed of the pi agent SDK that bridges a
// browser WebSocket to an in-process AgentSession driving mlx-bun's own
// local model (Phase 16, web half).
//
// Each browser WS gets its own PiWebSession: an in-memory pi AgentSession
// configured with the full coding toolset, pointed at our loopback /v1 so
// model calls serialize through the server's generation queue. Session
// events are translated to the WS protocol below; tool calls that mutate
// (bash/edit/write) are gated through the browser via a pre-execution
// approval handshake.
//
// PROVIDER WIRING mirrors src/harness-pi.ts exactly (the subprocess path):
// provider id "mlx-bun", apiKey "sk-mlx-bun-local", model id "local",
// api "openai-completions", baseUrl "http://127.0.0.1:<port>/v1". The
// context window comes from the server (ctx.model.config.text
// .maxPositionEmbeddings, surfaced via /v1/models -> context_window).
//
// APPROVAL GATE: implemented for real (NOT the documented fallback). The
// pre-execution gate is the inline extension `pi.on("tool_call", ...)`
// handler, wired into createAgentSession via DefaultResourceLoader's
// `extensionFactories`. The handler is async, so it awaits the browser's
// allow/deny decision before the tool runs and returns { block: true,
// reason } to deny. Read-only tools (read/grep/find/ls) auto-allow.
// tool_execution_* events still drive the tool cards (start/update/end).

import { createHash } from "node:crypto";
import { mkdirSync, rmSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import type { ServerWebSocket, WebSocketHandler } from "bun";
import {
  createAgentSessionFromServices,
  createAgentSessionRuntime,
  createAgentSessionServices,
  SessionManager,
  type AgentSession,
  type AgentSessionEvent,
  type AgentSessionRuntime,
  type CreateAgentSessionRuntimeFactory,
  type ExtensionAPI,
  type SessionEntry,
  type SessionInfo,
  type ToolCallEvent,
} from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import { WEB_TOOL_NAMES } from "./web-tools";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "./memory/tools";
import { buildPiAgentSurface } from "./pi-session";
import { buildPiProvider, DEFAULT_CONTEXT_WINDOW, PI_LOCAL_MODEL_ID } from "./pi-provider";
import { downloadsSnapshot } from "./download";
import { getLane, type Lane } from "./serve/lane-registry";

/**
 * Tools that never mutate the user's machine; auto-allowed without a browser
 * round-trip. The web tools make outbound network requests but change nothing
 * locally, so they're auto-allowed too (and remain usable in read-only mode).
 */
const READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls", ...WEB_TOOL_NAMES, ...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES]);
/** Tools that require explicit per-call browser approval. */
const GATED_TOOLS = new Set(["bash", "edit", "write"]);

/**
 * The welcome assistant's tool allowlist: exactly `read` (a local file the user
 * points to) and `web_search` (current/external facts). Both are in
 * READ_ONLY_TOOLS, so neither triggers the approval gate. Kept to two because a
 * 1B model over-calls a larger toolset; widen this list (not the system prompt)
 * to grant more.
 */
const WELCOME_TOOLS = ["read", "web_search"] as const;

/**
 * The web chat session's tool allowlist: the two welcome tools, plus the
 * memory/reference read tools whenever the surface has memory enabled. The
 * system prompt (surface.memoryHint) and the bundled memory skill instruct
 * the model to call memory_resolve/memory_read/… — pi treats `tools` as an
 * allowlist, so leaving them out makes every such call fail. All additions
 * are in READ_ONLY_TOOLS (no approval round-trip).
 */
export function webChatToolAllowlist(memoryEnabled: boolean): string[] {
  return [
    ...WELCOME_TOOLS,
    ...(memoryEnabled ? [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES] : []),
  ];
}

/** Auto-deny a pending approval after this long with no browser decision. */
const APPROVAL_TIMEOUT_MS = 120_000;

/**
 * System prompt for the web chat assistant.
 *
 * This fully REPLACES pi's default coding-agent prompt (it flows to
 * buildSystemPrompt's `customPrompt` via DefaultResourceLoader.systemPrompt),
 * dropping pi's "operating inside a coding-agent harness" framing and its block
 * of internal documentation paths. pi still auto-appends the current date and
 * working directory, so we don't repeat them here.
 *
 * Deliberately SHORT. The default served model is a ~1B local model; a long,
 * "make the user feel welcome / here is everything mlx-bun does" prompt made it
 * fixate on greeting and ignore the user's actual message (verified against the
 * live server: the same model answers correctly with a short prompt and drowns
 * with the long one). So: state identity + privacy in one breath, then tell it
 * plainly to answer what was asked and not to greet or recite capabilities.
 */
export const WEB_CHAT_PROMPT_VERSION = "2026-06-21-minimal-v1";

export function webChatPromptFingerprint(prompt: string): string {
  return createHash("sha256").update(prompt).digest("hex").slice(0, 12);
}

export function buildWebChatSystemPrompt(
  readOnly: boolean,
  about?: { modelId?: string; downloadingModel?: string | null },
  opts?: { hasTools?: boolean },
): string {
  const servedModel =
    about?.modelId && about.modelId !== PI_LOCAL_MODEL_ID ? about.modelId : null;
  const modelLine = servedModel ? ` You are running on the local model \`${servedModel}\`.` : "";

  // A concise mlx-bun blurb so the welcome assistant can answer product
  // questions from its own knowledge (no tool, no fragile cwd-relative reads).
  // Kept SHORT on purpose — the old multi-paragraph product wall drowned the 1B
  // model. The blurb + the two key commands cover "what is it / how do I start".
  const aboutLine = ` mlx-bun runs open LLMs locally with MLX + Bun: a built-in chat, an OpenAI/Anthropic-compatible API, model download and serving, quantization, LoRA fine-tuning, and adapters — all on-device and private. Key commands: \`mlx-bun serve <model>\` to serve one, \`mlx-bun get <repo-id>\` to download one. You already know this, so answer questions about mlx-bun directly.`;

  // The tool guidance MUST match the session's actual surface (read +
  // web_search), or the model promises actions it can't take. Naming exactly
  // those two — and telling it to answer from knowledge first — is what keeps a
  // small model from reaching for a tool on math/writing/general questions.
  const hasTools = opts?.hasTools ?? true;
  const toolsLine = hasTools
    ? ` Answer directly from your own knowledge whenever you can. Only call a tool when you truly need information you don't have: \`web_search\` for current or external facts (news, current events, prices, latest docs), \`read\` for a specific local file the user points you to. Never use a tool for general questions, explanations, math, or writing — just answer. When a tool returns results, pull the answer out of the result text and state it directly — never tell the user to go open the links or check the sources themselves; reading them is your job.`
    : ` You have no tools in this session, so answer from your own knowledge; if something needs current or external data you can't reach, say so briefly instead of pretending to look it up.`;

  return `You are mlx-bun's built-in assistant, running entirely on the user's own Apple-silicon Mac — nothing they type leaves the machine.${modelLine}${aboutLine}${toolsLine}

Respond to what the user actually said, concisely. Don't open with a generic greeting or recite your capabilities unless asked — just answer. If a request is genuinely ambiguous, ask one short clarifying question. Format with Markdown when it helps.`;
}

/** Per-connection data the server attaches at upgrade time. */
export interface PiWsData {
  sessionId: string;
}

type PiWs = ServerWebSocket<PiWsData>;

// ---- WS protocol message shapes --------------------------------------

/** Decision a browser returns for a gated tool call. */
type ApprovalDecision = "allow" | "deny";

/** An image attachment from the browser: base64 (no data: prefix) + mime. */
interface ImageAttachment {
  data: string;
  mimeType: string;
}

/** Client -> server frames. */
type ClientMessage =
  | { type: "prompt"; text: string; images?: ImageAttachment[] }
  | { type: "abort" }
  | { type: "approval"; callId: string; decision: ApprovalDecision }
  // Toggle the model's reasoning channel on/off (only meaningful when the
  // model supports thinking — ready.thinking). Maps to Pi's session thinking
  // level: "medium" (on) ↔ "off". Pi sends it as enable_thinking to the server.
  | { type: "set_thinking"; enabled: boolean }
  // Select the active LoRA adapter for subsequent turns (null = none/base).
  // app.html mounts it (POST /v1/adapters) before sending this; the
  // before_provider_request hook injects it into the provider payload.
  | { type: "set_adapter"; id: string | null }
  // Per-request sampling overrides for subsequent turns. Each field is
  // optional; null/undefined means "leave it to the server default"
  // (the mode-aware recommended value resolved in toOptions). A present
  // numeric value is injected into the provider payload and always wins.
  // The before_provider_request hook injects whatever is set here.
  | {
      type: "set_sampling";
      temperature?: number | null;
      top_p?: number | null;
      top_k?: number | null;
      min_p?: number | null;
      xtc_probability?: number | null;
      xtc_threshold?: number | null;
      repetition_penalty?: number | null;
      repetition_context_size?: number | null;
      presence_penalty?: number | null;
      frequency_penalty?: number | null;
      seed?: number | null;
    }
  // Session management (recent-chats sidebar + new chat).
  | { type: "new_session" }
  | { type: "list_sessions" }
  | { type: "open_session"; path: string }
  | { type: "fork_session"; path: string }
  | { type: "delete_session"; path: string }
  // Message actions (plan §5.2). All three navigate the session's leaf
  // pointer via AgentSession.navigateTree() then re-prompt — a sibling
  // branch in the SAME session file, never a new one (see the helpers above
  // findLastUserMessageEntry for the full rationale). Regenerate re-sends the
  // last user message's original content verbatim; edit_resend re-sends it
  // with edited text (images preserved); switch_sibling moves the active
  // leaf to a previously-created sibling (an earlier edit/regeneration)
  // without sending anything new.
  | { type: "regenerate" }
  | { type: "edit_resend"; text: string }
  | { type: "switch_sibling"; entryId: string };

/** Model-author recommended sampling (generation_config.json, server-CLI
 *  overrides applied) — sent once on `ready` so the sampling popover can show
 *  per-model defaults instead of one hardcoded shape (web-ui-pass-plan.md
 *  #14). A field is null when neither the model nor the server configured one
 *  (the built-in fallback in toOptions still applies server-side). */
export interface ReadyGenDefaults {
  temperature: number | null;
  topP: number | null;
  topK: number | null;
}

/** Server -> client frames. */
type ServerMessage =
  // `vision`: whether the loaded model can accept images (drives the UI's
  // image-attach affordance — false on e4b until the SigLIP sidecar lands).
  // `audio`: whether the loaded model can accept `input_audio` parts (audio
  // tower loaded or loadable). Discovery-only for now: pi's Model.input type
  // has no "audio" modality, so unlike `vision` this flag never feeds the
  // provider declaration — clients use it instead of probing for a 400.
  // `thinking`: whether the model has a switchable reasoning channel (drives
  // the UI's thinking on/off toggle; false hides it).
  | { type: "ready"; model: string; vision: boolean; audio: boolean; thinking: boolean; genDefaults: ReadyGenDefaults }
  | { type: "turn_start" }
  | { type: "text_delta"; delta: string }
  | { type: "thinking_delta"; delta: string }
  | { type: "tool_start"; callId: string; tool: string; args: unknown }
  | { type: "tool_approval_request"; callId: string; tool: string; args: unknown }
  | { type: "tool_update"; callId: string; chunk: unknown }
  | { type: "tool_end"; callId: string; ok: boolean; result: unknown }
  // `lane`: the serving lane the just-finished turn ran on (serial /
  // serial+spec / batched), correlated via the lane registry keyed by the
  // AssistantMessage's responseId (the pi SDK's own usage parsing drops
  // custom fields — see src/serve/lane-registry.ts). Absent when the turn
  // produced no assistant message with a responseId (e.g. an aborted turn
  // before any model call) — never guessed client-side (risk #5).
  | { type: "turn_end"; lane?: Lane }
  | { type: "queue_update"; steering: readonly string[]; followUp: readonly string[] }
  // Replay a session's transcript (rebuilds the thread); and the sidebar list.
  | { type: "history"; items: HistoryItem[] }
  | { type: "sessions"; items: SessionListItem[]; activePath?: string }
  // Sibling group for the LAST user message (edit-and-resend's `< i/n >`
  // toggle, plan §5.2). Sent after every history rebuild and after a
  // completed turn. `count` <= 1 means no toggle to show (the common case:
  // no edits/regenerations yet). `entryId` is the currently-active sibling's
  // id; `siblingIds` is the full ordered group so the client can resolve
  // "previous/next" locally and send switch_sibling with a concrete id
  // (never inferred/guessed — the server is the source of truth for order).
  | { type: "siblings"; entryId?: string; index: number; count: number; siblingIds: string[] }
  // Context-window usage indicator. tokens/percent are null right after a
  // compaction until the next assistant reply (pi can't estimate yet).
  | { type: "context"; tokens: number | null; contextWindow: number; percent: number | null }
  | { type: "error"; message: string };

// ---- Session serialization (pure, unit-tested) -----------------------

/** A finished tool call as rendered in replayed history. */
export interface HistoryToolItem {
  callId: string;
  name: string;
  args: unknown;
  /** Tool result text, filled from the matching toolResult message. */
  result: string;
}

/** One replayed transcript turn: a user or assistant message (assistant
 *  messages carry any tool calls they made, with results merged in). */
export interface HistoryItem {
  role: "user" | "assistant";
  text: string;
  /** Model reasoning/thinking, kept separate from the final answer. */
  thinking?: string;
  tools: HistoryToolItem[];
  /** Session entry id (user items only). Lets the browser correlate "the
   *  last user message" in the replayed thread with the `siblings` frame's
   *  entryId, so it knows which DOM node gets the edit/sibling-toggle UI
   *  (plan §5.2). Undefined for assistant items — they aren't fork targets. */
  entryId?: string;
}

/** A row in the recent-chats sidebar, derived from pi's SessionInfo. */
export interface SessionListItem {
  path: string;
  id: string;
  title: string;
  /** Last-modified epoch ms (newest first). */
  modified: number;
  messageCount: number;
  forked: boolean;
}

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
function toPiImages(images?: ImageAttachment[]): ImageContent[] | undefined {
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

// ---- Pure helper: event mapping (unit-tested) ------------------------

/**
 * Translate one pi AgentSessionEvent into zero or more WS frames.
 *
 * Pure and side-effect-free so it can be unit-tested without a live
 * session. The approval gate is handled separately (in the tool_call
 * extension handler), so the tool_execution_start event here simply
 * renders the tool card; it does not itself request approval.
 *
 * Returns [] for events that have no browser-facing representation.
 */
export function mapEventToFrames(event: AgentSessionEvent): ServerMessage[] {
  switch (event.type) {
    case "turn_start":
      return [{ type: "turn_start" }];
    case "turn_end": {
      // A turn can complete with stopReason "error" (e.g. the model request
      // 400'd) WITHOUT any error being thrown up to the WS message handler, so
      // it would otherwise vanish — the browser just sees an empty turn ("no
      // messages"). Surface it as an error frame so the UI can show it.
      const msg = (event as { message?: { stopReason?: string; errorMessage?: string; responseId?: string } }).message;
      // Lane correlation (docs/design/web-chat-redesign.md §2.3 caveat / risk
      // #5): the pi SDK's AssistantMessage.responseId is the chat-completion
      // response's own `id` (chatcmpl-…), which server.ts records against the
      // lane the moment it decides one. Looked up here — never inferred — so
      // a mismatch or absence just omits the field rather than guessing.
      const lane = msg?.responseId ? getLane(msg.responseId) : undefined;
      if (msg?.stopReason === "error") {
        return [
          { type: "error", message: msg.errorMessage || "the model request failed" },
          { type: "turn_end", ...(lane ? { lane } : {}) },
        ];
      }
      return [{ type: "turn_end", ...(lane ? { lane } : {}) }];
    }
    case "message_update": {
      const ame = event.assistantMessageEvent;
      if (ame.type === "text_delta") return [{ type: "text_delta", delta: ame.delta }];
      if (ame.type === "thinking_delta") return [{ type: "thinking_delta", delta: ame.delta }];
      return [];
    }
    case "tool_execution_start":
      return [
        {
          type: "tool_start",
          callId: event.toolCallId,
          tool: event.toolName,
          args: event.args,
        },
      ];
    case "tool_execution_update":
      return [
        {
          type: "tool_update",
          callId: event.toolCallId,
          chunk: event.partialResult,
        },
      ];
    case "tool_execution_end":
      return [
        {
          type: "tool_end",
          callId: event.toolCallId,
          ok: !event.isError,
          result: event.result,
        },
      ];
    case "queue_update":
      return [
        {
          type: "queue_update",
          steering: event.steering,
          followUp: event.followUp,
        },
      ];
    default:
      return [];
  }
}

// ---- Session pool ----------------------------------------------------

/** Live sessions keyed by their owning WebSocket. */
const sessions = new Map<PiWs, PiWebSession>();

/** Body of the `before_provider_request` hook: inject the selected LoRA adapter
 *  into the outgoing provider payload. null/empty selection → return undefined so
 *  Pi keeps the payload unchanged (base model); Pi replaces the payload only when a
 *  handler returns a value. Pure + exported for unit testing. */
export function injectAdapter(
  payload: Record<string, unknown>,
  selected: string | null,
): Record<string, unknown> | undefined {
  if (!selected) return undefined;
  return { ...payload, adapter: selected };
}

/** Per-request sampling overrides carried on the session and injected into the
 *  provider payload by the before_provider_request hook. Each field is either a
 *  user-set override or null/undefined ("use the server's mode-aware default").
 *  Field names match the server's ChatRequest wire names (not toOptions' camelCase)
 *  since these are injected directly into the outgoing chat-completions payload. */
export interface SamplingOverrides {
  temperature?: number | null;
  top_p?: number | null;
  top_k?: number | null;
  min_p?: number | null;
  xtc_probability?: number | null;
  xtc_threshold?: number | null;
  repetition_penalty?: number | null;
  repetition_context_size?: number | null;
  presence_penalty?: number | null;
  frequency_penalty?: number | null;
  seed?: number | null;
}

/** Every SamplingOverrides field name, in wire order — the single source of
 *  truth `injectSampling` and the `set_sampling` handler both walk, so a new
 *  field only needs adding here + the interface above. */
const SAMPLING_FIELDS = [
  "temperature", "top_p", "top_k", "min_p", "xtc_probability", "xtc_threshold",
  "repetition_penalty", "repetition_context_size", "presence_penalty",
  "frequency_penalty", "seed",
] as const satisfies readonly (keyof SamplingOverrides)[];

/** Inject the user's sampling overrides into the outgoing chat-completions
 *  payload (which reaches the server's toOptions, where an explicit
 *  request field always wins). Only finite numbers are injected; a
 *  null/undefined/unset field is left off so the server falls back to its
 *  mode-aware recommended default. Returns undefined when nothing is set so the
 *  hook can keep the payload unchanged. Pure + exported for unit testing. */
export function injectSampling(
  payload: Record<string, unknown>,
  s: SamplingOverrides | undefined,
): Record<string, unknown> | undefined {
  if (!s) return undefined;
  const out: Record<string, unknown> = { ...payload };
  let changed = false;
  for (const field of SAMPLING_FIELDS) {
    const v = s[field];
    if (typeof v === "number" && Number.isFinite(v)) {
      out[field] = v;
      changed = true;
    }
  }
  return changed ? out : undefined;
}

/**
 * One browser connection's pi agent. Owns the AgentSession, the event
 * subscription, and the pending tool-approval handshakes.
 */
class PiWebSession {
  private runtime?: AgentSessionRuntime;
  private session?: AgentSession;
  /** SessionManager backing the active AgentSession (disk-persisted). */
  private sessionManager?: SessionManager;
  private unsubscribe?: () => void;
  private disposed = false;
  /** Active LoRA adapter id for this connection (null = none/base model).
   *  Read by the before_provider_request hook; set via the set_adapter msg. */
  private selectedAdapter: string | null = null;
  /** Per-request sampling overrides for this connection (set via set_sampling).
   *  Read by the before_provider_request hook; unset fields fall back to the
   *  server's mode-aware recommended defaults. */
  private sampling: SamplingOverrides = {};

  /** Per-connection invariants, built once in start() and reused across
   *  session switches (new chat / resume / fork). */
  private provider?: ReturnType<typeof buildPiProvider>;
  private readonly cwd = process.cwd();
  private readonly agentDir = join(homedir(), ".mlx-bun", "pi-sessions");
  /** Where web-chat session files live (pi's own JSONL format). Shared by
   *  create/continueRecent/open/fork/list/delete so they all see one set.
   *  This is the durable transcript store the nightly memory pipeline reads. */
  private readonly sessionDir = join(homedir(), ".mlx-bun", "sessions");

  /** callId -> resolve(decision). Pending browser approvals in flight. */
  private readonly pendingApprovals = new Map<string, (decision: ApprovalDecision) => void>();
  /** callId -> timer handle, so we can clear on resolve/dispose. */
  private readonly approvalTimers = new Map<string, ReturnType<typeof setTimeout>>();

  constructor(
    private readonly ws: PiWs,
    private readonly opts: {
      port: number | (() => number); modelId: string; contextWindow: number; readOnly: boolean;
      vision: boolean; audio: boolean; thinking: boolean; genDefaults: ReadyGenDefaults;
    },
  ) {}

  /** Build the provider, resume the most recent chat, and start streaming. */
  async start(): Promise<void> {
    // Resolve the port lazily: the WS handler is constructed before
    // Bun.serve() binds, so an ephemeral (0) port is only known at the
    // first connection. createServer passes `() => server.port`.
    const port = typeof this.opts.port === "function" ? this.opts.port() : this.opts.port;
    const baseUrl = `http://127.0.0.1:${port}/v1`;

    // In-memory auth + registry shared with the terminal embed (pi-provider.ts
    // so the wiring can't drift); built once and reused across session swaps.
    this.provider = buildPiProvider(baseUrl, {
      contextWindow: this.opts.contextWindow,
      reasoning: this.opts.thinking,
      vision: this.opts.vision,
    });
    mkdirSync(this.sessionDir, { recursive: true });

    // Each connection starts its OWN fresh session. A prior continueRecent
    // here meant every new WebSocket (another browser tab, a reconnect, or an
    // external client) appended to the most-recent session — so tabs and even
    // test clients wrote into each other's chats. Isolation is the correct
    // model (and essential once concurrent slots land). Resuming a specific
    // chat is explicit via the sidebar (open_session); the frontend re-opens
    // its own session on a transient reconnect so a blip doesn't strand it on
    // a blank backend session. Sessions persist to disk in pi's own format —
    // the substrate for the recent-chats sidebar and the nightly memory pipeline.
    await this.replaceRuntime(SessionManager.create(this.cwd, this.sessionDir));
    if (this.disposed) return;

    this.send({
      type: "ready", model: this.opts.modelId, vision: this.opts.vision, audio: this.opts.audio,
      thinking: this.opts.thinking, genDefaults: this.opts.genDefaults,
    });
    this.sendHistory();
    await this.sendSessions();
  }

  /** Runtime factory used for initial session creation and SDK-managed replacements. */
  private createRuntimeFactory(): CreateAgentSessionRuntimeFactory {
    return async ({ cwd, sessionManager, sessionStartEvent }) => {
      const provider = this.provider;
      if (!provider) throw new Error("provider not initialized");

      // Welcome-assistant tool surface: exactly two read-only tools —
      // `web_search` (current/external facts) and `read` (a local file the user
      // points to). Both auto-allow (no approval round-trip). We deliberately
      // do NOT expose web_fetch/weather/bash/edit/write/grep/find/ls: a 1B model
      // over-calls a big toolset. With thinking ON (the web chat default) it
      // uses these two appropriately; build the web tools (for the web_search
      // definition) then restrict the allowlist to the two names below.
      const surface = await buildPiAgentSurface({ webTools: true, codingTools: false });
      const webPrompt = buildWebChatSystemPrompt(this.opts.readOnly, {
        modelId: this.opts.modelId,
        downloadingModel: downloadsSnapshot().find(
          (d) => d.state === "active" && d.repoId !== this.opts.modelId,
        )?.repoId ?? null,
      }, { hasTools: WELCOME_TOOLS.length > 0 }) + surface.memoryHint;
      if (process.env.MLX_BUN_PI_DEBUG) {
        console.error(`[pi-web] prompt ${WEB_CHAT_PROMPT_VERSION} sha=${webChatPromptFingerprint(webPrompt)} memory=${surface.memoryEnabled ? "on" : "off"}`);
      }
      const services = await createAgentSessionServices({
        cwd,
        agentDir: this.agentDir,
        authStorage: provider.authStorage,
        modelRegistry: provider.modelRegistry,
        resourceLoaderOptions: {
          noExtensions: true,
          noSkills: true,
          noPromptTemplates: true,
          noThemes: true,
          noContextFiles: true,
          additionalSkillPaths: surface.skillPaths,
          systemPrompt: webPrompt,
          extensionFactories: [
            (pi) => this.installApprovalGate(pi),
            (pi) => this.installAdapterHook(pi),
          ],
        },
      });

      return {
        ...(await createAgentSessionFromServices({
          services,
          sessionManager,
          sessionStartEvent,
          model: provider.model,
          // Allowlist (not surface.tools): `read` is a pi built-in enabled by
          // name; `web_search` is the custom tool from surface.customTools. pi
          // exposes only names in this list, so web_fetch/weather stay defined
          // but hidden. Memory/reference tools ride along when the surface has
          // memory enabled — the prompt + memory skill advertise them, so they
          // must be callable (webChatToolAllowlist).
          tools: webChatToolAllowlist(surface.memoryEnabled),
          customTools: surface.customTools,
        })),
        services,
        diagnostics: services.diagnostics,
      };
    };
  }

  /** Tear down UI/session bindings owned by this WebSocket. Runtime.dispose()
   *  owns the AgentSession itself; this method only detaches browser state. */
  private teardownBindings(): void {
    for (const settle of this.pendingApprovals.values()) settle("deny");
    this.pendingApprovals.clear();
    for (const timer of this.approvalTimers.values()) clearTimeout(timer);
    this.approvalTimers.clear();
    this.unsubscribe?.();
    this.unsubscribe = undefined;
    this.session = undefined;
    this.sessionManager = undefined;
  }

  /** Bind browser event plumbing to the current runtime.session. */
  private async bindRuntimeSession(): Promise<void> {
    const session = this.runtime?.session;
    if (!session) return;
    this.unsubscribe?.();
    this.session = session;
    this.sessionManager = session.sessionManager;
    await session.bindExtensions({ mode: "rpc" });
    this.unsubscribe = session.subscribe((event) => this.onSessionEvent(event));
    this.sendContextUsage();
  }

  /** Replace the whole pi runtime with a target SessionManager. Used for the
   *  initial session and for file-level fork, while open/new use runtime APIs. */
  private async replaceRuntime(sm: SessionManager): Promise<void> {
    try {
      await this.session?.abort();
    } catch {
      // Old turn may already be done; ignore.
    }
    const next = await createAgentSessionRuntime(this.createRuntimeFactory(), {
      cwd: this.cwd,
      agentDir: this.agentDir,
      sessionManager: sm,
    });
    next.setRebindSession(async () => this.bindRuntimeSession());
    if (this.disposed) {
      await next.dispose();
      return;
    }
    const previous = this.runtime;
    this.teardownBindings();
    this.runtime = next;
    await this.bindRuntimeSession();
    if (previous) await previous.dispose();
  }

  /** Replay the active session's transcript to the browser (rebuilds thread).
   *  Always followed by sendSiblings(): the sibling group for "the last user
   *  message" is a derived view of the same entries and goes stale under
   *  exactly the same conditions history does (new session, switch, fork). */
  private sendHistory(): void {
    const entries = this.sessionManager?.getEntries() ?? [];
    this.send({ type: "history", items: serializeHistory(entries) });
    this.sendSiblings();
  }

  /** Push the sibling-group info for the current last-user-message (drives
   *  the browser's `< i/n >` edit toggle). Called by sendHistory() and after
   *  each completed turn, since either can change which message is "last" or
   *  how many siblings it has. */
  private sendSiblings(): void {
    const entries = this.sessionManager?.getEntries() ?? [];
    const last = findLastUserMessageEntry(entries);
    if (!last) {
      this.send({ type: "siblings", index: 0, count: 0, siblingIds: [] });
      return;
    }
    const group = userMessageSiblings(entries, last.id);
    this.send({
      type: "siblings",
      entryId: last.id,
      index: group?.index ?? 1,
      count: group?.siblingIds.length ?? 1,
      siblingIds: group?.siblingIds ?? [last.id],
    });
  }

  /** Push current context-window usage to the browser (for the indicator). */
  private sendContextUsage(): void {
    const usage = this.session?.getContextUsage();
    if (usage) {
      this.send({ type: "context", tokens: usage.tokens, contextWindow: usage.contextWindow, percent: usage.percent });
    }
  }

  /** Send the recent-chats list (sidebar), marking the active session. */
  private async sendSessions(): Promise<void> {
    let infos: SessionInfo[] = [];
    try {
      infos = await SessionManager.list(this.cwd, this.sessionDir);
    } catch {
      infos = [];
    }
    this.send({
      type: "sessions",
      items: toSessionListItems(infos),
      activePath: this.sessionManager?.getSessionFile(),
    });
  }

  /** Guard: only operate on session files under our session dir. */
  private isUnderSessionDir(path: string): boolean {
    const root = resolve(this.sessionDir);
    const p = resolve(path);
    return p === root || p.startsWith(root + "/");
  }

  /** Start a fresh chat (old one stays on disk, resumable from the sidebar). */
  private async newSession(): Promise<void> {
    if (!this.runtime) {
      await this.replaceRuntime(SessionManager.create(this.cwd, this.sessionDir));
    } else {
      await this.runtime.newSession();
    }
    this.sendHistory();
    await this.sendSessions();
  }

  /** Resume an existing chat by file path. */
  private async openSession(path: string): Promise<void> {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    if (!this.runtime) await this.replaceRuntime(SessionManager.open(path, this.sessionDir));
    else await this.runtime.switchSession(path);
    this.sendHistory();
    await this.sendSessions();
  }

  /** Branch a new chat from an existing one (original stays untouched). */
  private async forkSession(path: string): Promise<void> {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    // File-level fork is not a runtime primitive, so create the target
    // SessionManager then replace the runtime through the same SDK factory.
    await this.replaceRuntime(SessionManager.forkFrom(path, this.cwd, this.sessionDir));
    this.sendHistory();
    await this.sendSessions();
  }

  /** Delete a session file; if it was active, start a fresh chat. */
  private deleteSession(path: string): void {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    const active = this.sessionManager?.getSessionFile();
    const wasActive = !!active && resolve(active) === resolve(path);
    try {
      rmSync(path, { force: true });
    } catch {
      // Already gone or unreadable; the refreshed list will reflect reality.
    }
    if (wasActive) void this.newSession();
    else void this.sendSessions();
  }

  /** Move the session leaf to `entryId`'s parent via navigateTree, then
   *  re-prompt with {text, images}. This is the shared mechanism behind
   *  regenerate and edit_resend: navigateTree does NOT delete the old
   *  message/reply (they stay on disk as a sibling branch), and pi resyncs
   *  agent.state.messages from the new leaf internally, so the next
   *  session.prompt() call appends cleanly. Returns false (and sends an
   *  error frame) if the entry can't be found or a turn is already
   *  streaming (mirrors prompt()'s own idle precondition — regenerate/edit
   *  are not queueable follow-ups, unlike a normal composer submit). */
  private async resendFrom(entryId: string, text: string, images: ImageContent[]): Promise<boolean> {
    const session = this.session;
    if (!session) {
      this.send({ type: "error", message: "session not ready" });
      return false;
    }
    if (session.isStreaming) {
      this.send({ type: "error", message: "wait for the current reply to finish first" });
      return false;
    }
    if (!text.trim()) {
      this.send({ type: "error", message: "message text can't be empty" });
      return false;
    }
    await session.navigateTree(entryId);
    await session.prompt(text, images.length ? { images } : {});
    return true;
  }

  /** Regenerate: re-send the last user message's ORIGINAL content verbatim
   *  as a new sibling branch. Works after abort/stop too — an aborted turn
   *  still leaves the triggering user message entry in place to find. */
  private async regenerate(): Promise<void> {
    const entries = this.sessionManager?.getEntries() ?? [];
    const last = findLastUserMessageEntry(entries);
    if (!last) {
      this.send({ type: "error", message: "no message to regenerate" });
      return;
    }
    await this.resendFrom(last.id, last.text, last.images);
  }

  /** Edit-and-resend: re-send the LAST user message with edited text (plan
   *  §5.2 scopes editing to the last message only — the `< i/n >` toggle is
   *  a linear sibling list, not a tree view). Original images are preserved
   *  since editing text shouldn't silently drop an attachment. */
  private async editResend(text: string): Promise<void> {
    const entries = this.sessionManager?.getEntries() ?? [];
    const last = findLastUserMessageEntry(entries);
    if (!last) {
      this.send({ type: "error", message: "no message to edit" });
      return;
    }
    await this.resendFrom(last.id, text, last.images);
  }

  /** Switch the active leaf to a previously-created sibling (an earlier
   *  edit/regeneration of the last user message) WITHOUT sending anything
   *  new — pure navigation. Walks down to that sibling's own deepest
   *  descendant (its assistant reply, if any) so the replayed history shows
   *  that branch's actual conversation, not just the bare user message. */
  private switchSibling(entryId: string): void {
    const sm = this.sessionManager;
    const session = this.session;
    if (!sm || !session) {
      this.send({ type: "error", message: "session not ready" });
      return;
    }
    if (session.isStreaming) {
      this.send({ type: "error", message: "wait for the current reply to finish first" });
      return;
    }
    const entry = sm.getEntry(entryId);
    if (!entry) {
      this.send({ type: "error", message: "message not found" });
      return;
    }
    const leaf = deepestLeafFrom(entryId, (parentId) => sm.getChildren(parentId));
    sm.branch(leaf);
    // Mirror what AgentSession.navigateTree() does internally after moving
    // the leaf: resync agent.state.messages from the new leaf's path so the
    // in-memory agent state and the persisted leaf pointer never diverge.
    session.agent.state.messages = sm.buildSessionContext().messages;
    this.sendHistory();
    this.sendContextUsage();
  }

  /** Register the before_provider_request hook that injects the selected LoRA
   *  adapter into every provider request (Pi-native adapter control, mirrors the
   *  CLI extension). Default none = no injection (base model). */
  private installAdapterHook(pi: ExtensionAPI): void {
    pi.on("before_provider_request", (event) => {
      let payload = event.payload as Record<string, unknown>;
      // Layer both injections: adapter selection, then sampling overrides.
      // Each returns undefined when it has nothing to change, so we keep the
      // prior payload in that case.
      payload = injectAdapter(payload, this.selectedAdapter) ?? payload;
      payload = injectSampling(payload, this.sampling) ?? payload;
      return payload;
    });
  }

  /** Register the tool_call approval gate on the inline extension. */
  private installApprovalGate(pi: ExtensionAPI): void {
    pi.on("tool_call", async (event: ToolCallEvent) => {
      const tool = event.toolName;
      if (process.env.MLX_BUN_PI_DEBUG) {
        console.error(`[pi-web] tool_call ${tool} args=${JSON.stringify(event.input)}`);
      }

      // Read-only tools never need approval.
      if (READ_ONLY_TOOLS.has(tool)) return undefined;

      // Anything mutating is denied outright in read-only mode.
      if (this.opts.readOnly && GATED_TOOLS.has(tool)) {
        return { block: true, reason: "Read-only session: mutating tools are disabled." };
      }

      // Non-gated, non-read-only tools (shouldn't happen with the shared pi
      // surface, but be safe): allow.
      if (!GATED_TOOLS.has(tool)) return undefined;

      const decision = await this.requestApproval(event);
      if (decision === "deny") {
        return { block: true, reason: "Denied by user." };
      }
      return undefined; // allow
    });
  }

  /**
   * Ask the browser to approve a gated tool call and await its decision.
   * Auto-denies after APPROVAL_TIMEOUT_MS or if the connection drops.
   */
  private requestApproval(event: ToolCallEvent): Promise<ApprovalDecision> {
    const callId = event.toolCallId;
    return new Promise<ApprovalDecision>((resolve) => {
      const settle = (decision: ApprovalDecision) => {
        const timer = this.approvalTimers.get(callId);
        if (timer) clearTimeout(timer);
        this.approvalTimers.delete(callId);
        this.pendingApprovals.delete(callId);
        resolve(decision);
      };

      this.pendingApprovals.set(callId, settle);
      const timer = setTimeout(() => settle("deny"), APPROVAL_TIMEOUT_MS);
      this.approvalTimers.set(callId, timer);

      this.send({
        type: "tool_approval_request",
        callId,
        tool: event.toolName,
        args: event.input,
      });
    });
  }

  /** Resolve a pending approval from a browser `approval` frame. */
  resolveApproval(callId: string, decision: ApprovalDecision): void {
    const settle = this.pendingApprovals.get(callId);
    if (settle) settle(decision);
  }

  private onSessionEvent(event: AgentSessionEvent): void {
    if (process.env.MLX_BUN_PI_DEBUG) {
      const extra = event.type === "message_update"
        ? `/${(event as { assistantMessageEvent?: { type?: string } }).assistantMessageEvent?.type}` : "";
      console.error(`[pi-event] ${event.type}${extra}`);
    }
    for (const frame of mapEventToFrames(event)) this.send(frame);
    // A completed turn is when pi flushes the session to disk (it defers
    // writing until the first assistant reply), so refresh the sidebar then:
    // a brand-new chat appears, and the active row's title/time update.
    // Also refresh the context-usage indicator (it grows each turn, and
    // drops sharply when auto-compaction fires).
    if (event.type === "turn_end") {
      void this.sendSessions();
      this.sendContextUsage();
      // A completed turn (including regenerate/edit_resend's re-prompt) can
      // change the last user message's sibling count/index.
      this.sendSiblings();
    }
  }

  /** Handle one parsed client frame. */
  async handle(msg: ClientMessage): Promise<void> {
    // Session-management frames don't require (and may replace) the active
    // session, so handle them before the readiness guard.
    switch (msg.type) {
      case "new_session":
        await this.newSession();
        return;
      case "list_sessions":
        await this.sendSessions();
        return;
      case "open_session":
        await this.openSession(msg.path);
        return;
      case "fork_session":
        await this.forkSession(msg.path);
        return;
      case "delete_session":
        this.deleteSession(msg.path);
        return;
    }

    const session = this.session;
    if (!session) {
      this.send({ type: "error", message: "session not ready" });
      return;
    }

    switch (msg.type) {
      // The whole chat is just this: hand the user's message to pi's
      // AgentSession and let pi run the turn (reply or tool calls, which pi
      // executes). The ONLY decision we make is the canonical idle-vs-streaming
      // branch from pi's own prompt() contract (core/agent-session.ts): an idle
      // session runs a normal turn; if a turn is already streaming (the user
      // typed again before it finished), the message is queued as a follow-up
      // so it becomes the next turn instead of being dropped. pi re-checks
      // isStreaming atomically inside prompt(), so this read can't strand a
      // message at the turn boundary.
      case "prompt": {
        if (process.env.MLX_BUN_PI_DEBUG) {
          console.error(`[pi-web] prompt text=${JSON.stringify(msg.text.slice(0, 500))} images=${msg.images?.length ?? 0} streaming=${session.isStreaming} adapter=${this.selectedAdapter ?? "base"}`);
        }
        const images = toPiImages(msg.images);
        if (session.isStreaming) await session.prompt(msg.text, { streamingBehavior: "followUp", images });
        else await session.prompt(msg.text, { images });
        return;
      }
      case "abort":
        await session.abort();
        return;
      case "approval":
        this.resolveApproval(msg.callId, msg.decision);
        return;
      case "set_thinking":
        // Pi clamps to the model's available levels; a no-op for models
        // without a switchable reasoning channel.
        session.setThinkingLevel(msg.enabled ? "medium" : "off");
        return;
      case "set_adapter":
        // Pi-native adapter control: record the selection; the
        // before_provider_request hook injects it into the outgoing payload.
        // app.html has already mounted it server-side (POST /v1/adapters).
        this.selectedAdapter = msg.id;
        return;
      case "set_sampling":
        // Record the per-request sampling overrides; the
        // before_provider_request hook injects any set fields into the
        // outgoing payload. A null/undefined field clears the override so the
        // server's mode-aware default applies again. The full mlx_lm.server
        // sampler extension set (min_p/XTC/penalty families/seed), not just
        // temperature/top_p/top_k (web-ui-pass-plan.md #8).
        this.sampling = {
          temperature: msg.temperature ?? null,
          top_p: msg.top_p ?? null,
          top_k: msg.top_k ?? null,
          min_p: msg.min_p ?? null,
          xtc_probability: msg.xtc_probability ?? null,
          xtc_threshold: msg.xtc_threshold ?? null,
          repetition_penalty: msg.repetition_penalty ?? null,
          repetition_context_size: msg.repetition_context_size ?? null,
          presence_penalty: msg.presence_penalty ?? null,
          frequency_penalty: msg.frequency_penalty ?? null,
          seed: msg.seed ?? null,
        };
        return;
      case "regenerate":
        await this.regenerate();
        return;
      case "edit_resend":
        await this.editResend(msg.text);
        return;
      case "switch_sibling":
        this.switchSibling(msg.entryId);
        return;
    }
  }

  /** Tear down the session and reject any in-flight approvals. */
  dispose(): void {
    this.disposed = true;
    this.teardownBindings();
    void this.runtime?.dispose();
    this.runtime = undefined;
  }

  /** Send a frame, swallowing errors on a closed socket. */
  private send(msg: ServerMessage): void {
    try {
      this.ws.send(JSON.stringify(msg));
    } catch {
      // Socket closed mid-send; nothing actionable.
    }
  }
}

// ---- Public handler factory ------------------------------------------

/**
 * Build a Bun WebSocket handler that bridges browser connections to
 * in-process pi AgentSessions driving mlx-bun's local model.
 *
 * @param opts.port           Port the mlx-bun server listens on; the pi
 *                            provider points at http://127.0.0.1:<port>/v1.
 * @param opts.modelId        Model id reported in the `ready` frame.
 *                            Default: "local".
 * @param opts.contextWindow  Context window advertised to pi. Default: 32768.
 *                            Source: ctx.model.config.text.maxPositionEmbeddings.
 * @param opts.readOnly       When true, bash/edit/write are denied outright.
 * @param opts.genDefaults    Model-author sampling defaults, sent once on `ready`.
 */
export function makePiWsHandler(opts: {
  port: number | (() => number);
  modelId?: string;
  contextWindow?: number;
  readOnly?: boolean;
  /** Whether the loaded model can accept images (server's ctx.vision != null). */
  vision?: boolean;
  /** Whether the loaded model can accept `input_audio` parts (server's audio
   *  tower loaded or loadable). Rides only the `ready` frame — pi's
   *  Model.input type has no "audio" modality to declare. */
  audio?: boolean;
  /** Whether the model has a switchable reasoning channel
   *  (server's ctx.template.supportsThinking). Drives the thinking toggle. */
  thinking?: boolean;
  /** Model-author sampling defaults (generation_config.json + server-CLI
   *  overrides), sent once on the `ready` frame. Default: all-null (the
   *  sampling popover falls back to its own hardcoded shape). */
  genDefaults?: ReadyGenDefaults;
}): WebSocketHandler<PiWsData> {
  const resolved = {
    port: opts.port,
    modelId: opts.modelId ?? PI_LOCAL_MODEL_ID,
    contextWindow: opts.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
    readOnly: opts.readOnly ?? false,
    vision: opts.vision ?? false,
    audio: opts.audio ?? false,
    thinking: opts.thinking ?? false,
    genDefaults: opts.genDefaults ?? { temperature: null, topP: null, topK: null },
  };

  return {
    async open(ws) {
      const session = new PiWebSession(ws, resolved);
      sessions.set(ws, session);
      try {
        await session.start();
      } catch (err) {
        // Model not reachable yet (or any build failure): report and let
        // the client retry. Keep the entry so close() still cleans up.
        sessions.delete(ws);
        session.dispose();
        sendError(ws, err);
      }
    },

    async message(ws, raw) {
      const session = sessions.get(ws);
      if (!session) {
        sendError(ws, "no active session");
        return;
      }
      let msg: ClientMessage;
      try {
        msg = JSON.parse(typeof raw === "string" ? raw : raw.toString("utf8")) as ClientMessage;
      } catch {
        sendError(ws, "invalid JSON");
        return;
      }
      try {
        await session.handle(msg);
      } catch (err) {
        sendError(ws, err);
      }
    },

    close(ws) {
      const session = sessions.get(ws);
      sessions.delete(ws);
      session?.dispose();
    },
  };
}

/** Dispose every live pi session. Call on server shutdown. */
export async function disposeAllPiSessions(): Promise<void> {
  for (const session of sessions.values()) {
    try {
      session.dispose();
    } catch {
      // Best-effort; keep disposing the rest.
    }
  }
  sessions.clear();
}

/** Send a best-effort `error` frame from any thrown value. */
function sendError(ws: PiWs, err: unknown): void {
  const message = err instanceof Error ? err.message : String(err);
  try {
    ws.send(JSON.stringify({ type: "error", message } satisfies ServerMessage));
  } catch {
    // Socket already gone.
  }
}
