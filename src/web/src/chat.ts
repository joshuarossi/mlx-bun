// GENERATED-ADJACENT source module — part of the src/web/src/* split (plan
// §7/§9 Phase 2). Built into src/web/app.js by scripts/build-web.ts.
//
// The chat controller: WS wiring, thread render, streaming, tool cards,
// approval card, queue bar. This is the orchestrator for composer.ts and
// sessions.ts — it owns the WebSocket and the per-turn mutable state
// (curAssistant, lastUserMsgEl, etc.) that both of those modules act on via
// explicit function calls rather than shared closures (a deliberate change
// from the original single-IIFE app.html: the split's whole point is
// typed, checkable seams between these concerns).
//
// Typed WS contract (plan §9 Phase 2 item 2): ClientMessage/ServerMessage
// and the history/session shapes are imported TYPE-ONLY from ../../pi-web
// so this module (and the whole bundle) contains zero server code — the
// bundler errors on bun:ffi if a value import ever sneaks in here, which is
// the intended guard (see scripts/build-web.ts).

import type {
  ClientMessage, HistoryItem, ReadyGenDefaults, ServerMessage, SessionListItem,
} from "../../pi-web";
import type { Lane } from "../../serve/lane-registry";
import {
  $, el, toast, currentRoute, closeDrawer,
  storedCodingToolsPreference, renderCodingToolsState, renderToolApprovals,
} from "./shell";
import { esc, mdToHtml, highlightIn, linkifyCitations, makeFrameScheduler, renderBlocksIncremental, wireCanvasToggle, captureCanvasViewStates, restoreCanvasViewStates, type BlockState } from "./markdown";
import {
  ComposerState, addFiles, buildMessageText, clearAttachments, clearOneShotArmed, initMentionPicker,
  initSampling, initSystemPrompt, onSelectAdapter, refreshAdapters as composerRefreshAdapters, refreshSamplingRecs,
  renderAttachments, renderContext, renderLane, renderQueue, updateAttachHint,
  updateThinkingToggle, type ContextFrame,
} from "./composer";
import {
  addMsgActions, newSiblingInfo, newSidebarState, renderSessions, renderSiblingToggle,
  switchSiblingTarget, applySessSearch, type SidebarState, type SiblingInfo,
} from "./sessions";
import { AdaptersPanelState, initAdaptersPanel, refreshAdaptersPanel } from "./adapters-panel";
import { initMemoryPanel, isMemoryToolName, memoryToolChip, type MemChipHandle } from "./memory-panel";
import { api } from "./api";
import type { ApiEnvelope } from "./protocol";
import type { Citation } from "./rag";
import { buildAppContext, resolveSpotlightTarget, showSpotlight, type UiSnapshot } from "./assistant";
import { isRouteId } from "./ui-catalog";

/* ────────────────────────────────────────────────────────────────────
   Chat-with-files RAG v1 — Sources panel (plan §9 Phase 3, beat matrix
   Axis 5). Pure HTML builder so tests/web-app.test.ts can exercise the
   esc() discipline directly, same reasoning as renderAdapterOptionsHtml
   etc. in composer.ts.
   ──────────────────────────────────────────────────────────────────── */

/** Pure: builds the collapsed "Sources · K" summary line + expandable list
 *  of [n] filename + snippet for a turn's citations. Snippets are
 *  truncated (a citation's chunk can be ~1200 chars — the panel is a
 *  pointer back to the source, not a document viewer). */
export function renderSourcesHtml(citations: Citation[]): string {
  if (!citations.length) return "";
  const rows = citations.map((c) => {
    const snippet = c.text.length > 240 ? c.text.slice(0, 240).trim() + "…" : c.text.trim();
    return '<div class="src-row" data-cite-row="' + c.n + '">' +
      '<span class="src-n">[' + c.n + "]</span>" +
      '<span class="src-meta"><span class="src-file">' + esc(c.fileName) + '</span>' +
      '<span class="src-range">chars ' + c.start + "–" + c.end + "</span></span>" +
      '<div class="src-snippet">' + esc(snippet) + "</div></div>";
  }).join("");
  return '<details class="sources"><summary>Sources · ' + citations.length + "</summary>" +
    '<div class="src-list">' + rows + "</div></details>";
}

/* ────────────────────────────────────────────────────────────────────
   Tool arg formatting helpers (shared by streaming + replayed history)
   ──────────────────────────────────────────────────────────────────── */

function argSummary(args: unknown): string {
  if (!args) return "";
  if (typeof args === "string") return args.slice(0, 120);
  const a = args as Record<string, unknown>;
  if (a.command || a.cmd) return String(a.command || a.cmd).slice(0, 120);
  if (a.file_path || a.path) return String(a.file_path || a.path).slice(0, 120);
  if (a.query || a.url || a.location) return String(a.query || a.url || a.location).slice(0, 120);
  const s = JSON.stringify(args); return s.length > 120 ? s.slice(0, 117) + "…" : s;
}
function prettyArgs(args: unknown): string {
  if (args == null) return "";
  if (typeof args === "string") return args;
  try { return JSON.stringify(args, null, 2); } catch { return String(args); }
}
function diffView(args: unknown): string {
  // Best-effort diff-ish view for edit/write tools.
  if (!args) return "";
  const a = args as Record<string, unknown>;
  if (a.old_string != null || a.new_string != null) {
    const o = String(a.old_string ?? "").split("\n").map((l) => '<span class="diffdel">- ' + esc(l) + "</span>").join("\n");
    const n = String(a.new_string ?? "").split("\n").map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join("\n");
    return (a.file_path ? esc(a.file_path) + "\n\n" : "") + o + (o && n ? "\n" : "") + n;
  }
  if (a.content != null) {
    return (a.file_path ? esc(a.file_path) + "\n\n" : "") +
      String(a.content).split("\n").map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join("\n");
  }
  return esc(prettyArgs(args));
}

/* ────────────────────────────────────────────────────────────────────
   Per-assistant-message streaming state
   ──────────────────────────────────────────────────────────────────── */

// Two distinct card kinds share one map (curAssistant.tools): the generic
// "wrench" tool card and the memory provenance chip (plan §5.4.2 — the
// single highest-leverage rendering change: a citation, not a shell
// command). Dispatch on `.kind` at each lifecycle point (toolCard/
// toolUpdate/toolEnd) rather than keeping two parallel maps, since a card's
// kind is fixed at tool_start and every later frame (tool_update/tool_end)
// only carries the callId to look it up by.
interface WrenchCardState {
  kind: "wrench";
  wrap: HTMLElement;
  res: HTMLElement;
  resBlk: HTMLElement;
  label: HTMLElement;
  chunks: string;
}
interface MemChipCardState {
  kind: "memchip";
  wrap: HTMLElement;
  handle: MemChipHandle;
  chunks: string;
}
type ToolCardState = WrenchCardState | MemChipCardState;

interface AssistantMsgState {
  m: HTMLElement;
  bubble: HTMLElement;
  thinkBox: HTMLDetailsElement;
  thinkBody: HTMLElement;
  textNode: HTMLElement;
  cursor: HTMLElement;
  meta: HTMLElement;
  tools: Map<string, ToolCardState>;
  text: string;
  thinking: string;
  t0: number;
  tFirst: number;
  tokens: number;
  blockState: BlockState;
  scheduleText: () => void;
  scheduleThinking: () => void;
  // Chat-with-files RAG v1 (plan §9 Phase 3, beat matrix Axis 5): the
  // citation list retrieved for the prompt that started THIS turn, if any
  // (composer.ts's buildMessageText only returns a non-empty list when
  // retrieval mode fired). Empty for the common case — no Sources panel,
  // no [n] linkification, zero visual change from before this feature.
  citations: Citation[];
}

export function createChatController() {
  let ws: WebSocket | null = null, connected = false, reconnectTimer: ReturnType<typeof setTimeout> | undefined, manualClose = false;
  let curAssistant: AssistantMsgState | null = null;
  let turnActive = false;
  // App-aware assistant (plan §6.6): the last uiSnapshot pushed to the
  // server, kept client-side too so spotlight_ui's ref resolution
  // (resolveSpotlightTarget) doesn't need a round-trip — the browser
  // already has the freshest snapshot it just sent.
  let lastSnapshot: UiSnapshot | null = null;
  // Citations retrieved for the prompt currently in flight (set in submit(),
  // just before send()) — startAssistant() picks this up when turn_start
  // arrives and attaches it to the new AssistantMsgState, then clears it so
  // a later turn with no attachments doesn't inherit a stale citation set.
  let pendingCitations: Citation[] = [];
  // This connection's active session path (from `sessions` frames). Each
  // connect gets a fresh server session; on a transient reconnect we re-open
  // our own session so a blip doesn't strand us on a blank one.
  let currentSessionPath: string | null = null, pendingResumePath: string | null = null;
  const thread = () => $("chat-thread");
  const composer = new ComposerState();
  const sidebar: SidebarState = newSidebarState();
  const adaptersPanel = new AdaptersPanelState();

  function wsUrl(): string {
    const proto = location.protocol === "https:" ? "wss:" : "ws:";
    return proto + "//" + location.host + "/ws/chat";
  }

  function connect(): void {
    manualClose = false;
    // Remember our session across this (re)connect: if we were already in a
    // session, re-open it once the new connection is ready (the server starts
    // each connection on a fresh session by default).
    pendingResumePath = currentSessionPath;
    try { ws = new WebSocket(wsUrl()); } catch { scheduleReconnect(); return; }
    ws.onopen = () => { connected = true; setChatStatus("connected"); };
    ws.onclose = () => { connected = false; setChatStatus("disconnected"); if (!manualClose) scheduleReconnect(); };
    ws.onerror = () => { setChatStatus("error"); };
    ws.onmessage = (ev) => { let m: ServerMessage; try { m = JSON.parse(ev.data); } catch { return; } handle(m); };
  }
  function scheduleReconnect(): void {
    clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(() => { if (currentRoute() === "chat") connect(); }, 2200);
  }
  function send(obj: ClientMessage): boolean {
    if (ws && ws.readyState === 1) { ws.send(JSON.stringify(obj)); return true; }
    return false;
  }

  /* ── App-aware assistant (plan §6.6, §9 Phase 3, beat matrix Axis 12) ──
     "See": push a structured context frame on every route change and every
     wizard-step change. Never on a timer — only these two triggers, so the
     server's ambient one-liner always reflects a real, user-caused state
     change. */

  /** Which non-route overlay (if any) is currently open, layered on top of
   *  whatever route is active underneath — same "where is the user, really"
   *  question navigate_app/spotlight_ui need answered. Checked in a fixed
   *  order; the first open one wins (only one of these opens at a time in
   *  practice — each is closed by shell.ts's closeTopOverlay sweep before
   *  another opens). */
  function currentView(): string | null {
    if ($("mem-overlay")?.classList.contains("open")) return "memory-panel";
    if ($("hub-overlay")?.classList.contains("open")) return "hub-panel";
    if ($("adapters-overlay")?.classList.contains("open")) return "adapters-panel";
    return null;
  }

  function pushAppContext(): void {
    const route = currentRoute();
    if (!isRouteId(route)) return; // "routes" (DAG diagram) isn't a useful assistant destination
    const ctx = buildAppContext(route, currentView());
    lastSnapshot = ctx.snapshot;
    send({ type: "context", context: ctx });
  }

  /** MutationObserver on the three wizard step-indicator containers: their
   *  innerHTML is fully rewritten by markdown.ts's renderSteps() on every
   *  show(n) call in quantize.ts/finetune.ts/dataset.ts, so a childList+
   *  subtree observer fires exactly on step change — no callback hook
   *  needed in those three controllers (outside this wave's file scope). */
  function watchWizardSteps(): void {
    const mo = new MutationObserver(() => pushAppContext());
    for (const id of ["q-steps", "f-steps", "d-steps"]) {
      const el = $(id);
      if (el) mo.observe(el, { childList: true, subtree: true });
    }
  }

  function setChatStatus(s: "connected" | "disconnected" | "error"): void {
    const line = $("chat-status-line");
    // The "#" hint lives HERE, not in the composer placeholder — a long
    // placeholder wraps + clips at phone widths (the 2026-07-06 jank class).
    // This status line ellipsizes gracefully instead (.chat-hint CSS).
    if (s === "connected") line.textContent = "connected · type to send · Shift+Enter for newline · # attaches files or recalls memory";
    else if (s === "disconnected") line.textContent = "reconnecting to agent…";
    else if (s === "error") line.textContent = "connection error — retrying";
  }

  /* — message actions: copy / regenerate / edit-and-resend (plan §5.2) —
   *  Only the LAST assistant message gets "regenerate" and only the LAST
   *  user message gets "edit" + the sibling `< i/n >` toggle. Both "last"
   *  pointers are tracked module-side and re-derived whenever a `history`
   *  frame rebuilds #chat-thread wholesale (see renderHistory/endTurn below).
   *  Regenerate/edit-resend re-prompt on a new sibling branch WITHOUT a
   *  `history` frame (resendFrom in pi-web.ts), so their click handlers below
   *  drop the stale lastAssistantMsgEl (and, for edit, update the surviving
   *  user bubble's text) themselves before the new reply streams in. */
  let lastUserMsgEl: HTMLElement | null = null;   // the <div class="msg user"> for the last user message
  let lastUserEntryId: string | null = null; // its session entryId (from history/siblings frames)
  let siblingInfo: SiblingInfo = newSiblingInfo();
  let lastAssistantMsgEl: HTMLElement | null = null; // the <div class="msg assistant"> eligible for regenerate
  // Citations for the reply currently sitting in lastAssistantMsgEl (kept in
  // lockstep with it — set alongside it in endTurn, cleared alongside it
  // everywhere it's nulled). Regenerate/edit-resend re-prompt the SAME
  // underlying (possibly RAG'd) user turn without going through submit()/
  // buildMessageText, so pendingCitations would otherwise be the stale `[]`
  // left over from consumption at the prior startAssistant() call — see the
  // pendingCitations declaration below. Re-seeding from here means a
  // citation-bearing turn keeps its Sources panel across regenerate/edit.
  let lastAssistantCitations: Citation[] = [];

  function doRegenerate(): void {
    if (turnActive) return;
    if (!send({ type: "regenerate" })) { toast("Not connected to the agent yet.", "err"); return; }
    // The server re-prompts on a new sibling branch — it does not send a
    // `history` frame for this (see resendFrom in pi-web.ts), so the old
    // reply would otherwise linger above the new one as it streams in.
    // Drop it now; startAssistant() appends the fresh reply right after.
    if (lastAssistantMsgEl) { lastAssistantMsgEl.remove(); lastAssistantMsgEl = null; }
    pendingCitations = lastAssistantCitations;
  }

  function switchSiblingDir(delta: number): void {
    const target = switchSiblingTarget(siblingInfo, delta);
    if (!target) return;
    send({ type: "switch_sibling", entryId: target });
  }

  /** Turn the last user message bubble into an inline editor. Cancel restores
   *  the original text view; Send fires edit_resend, updates the surviving
   *  user bubble to the edited text in place, and drops the stale assistant
   *  reply — the server re-prompts on a new sibling branch without sending a
   *  `history` frame (see resendFrom in pi-web.ts), so the old reply/text
   *  would otherwise linger next to the new one as it streams in. */
  function startEditLast(m: HTMLElement): void {
    if (turnActive) return;
    const bubble = m.querySelector(".bubble") as HTMLElement;
    const textEl = bubble.querySelector(".msg-text") as HTMLElement | null;
    if (!textEl) return;
    const original = textEl.textContent || "";
    const box = document.createElement("textarea");
    box.className = "msg-edit-box";
    box.value = original;
    const actions = el("div", "msg-edit-actions", null);
    const cancelBtn = el("button", "btn ghost sm", actions);
    cancelBtn.type = "button"; cancelBtn.textContent = "Cancel";
    const sendBtn = el("button", "btn primary sm", actions);
    sendBtn.type = "button"; sendBtn.textContent = "Send";
    textEl.replaceWith(box);
    box.after(actions);
    box.focus(); box.setSelectionRange(box.value.length, box.value.length);
    const restore = () => { box.replaceWith(textEl); actions.remove(); };
    const doSend = () => {
      const text = box.value.trim();
      if (!text) return;
      if (!send({ type: "edit_resend", text })) { toast("Not connected to the agent yet.", "err"); return; }
      textEl.textContent = text;
      box.replaceWith(textEl); actions.remove();
      if (lastAssistantMsgEl) { lastAssistantMsgEl.remove(); lastAssistantMsgEl = null; }
      pendingCitations = lastAssistantCitations;
    };
    cancelBtn.onclick = restore;
    sendBtn.onclick = doSend;
    box.addEventListener("keydown", (e) => {
      if (e.key === "Escape") { e.preventDefault(); restore(); }
      else if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); doSend(); }
    });
  }

  /* — message + tool DOM construction — */
  function addUserMsg(text: string, atts: { kind: string; data?: string; mimeType?: string; name: string }[] | null, opts: { isLast?: boolean; entryId?: string }): void {
    const m = el("div", "msg user", thread());
    el("div", "who", m).textContent = "you";
    const bubble = el("div", "bubble", m);
    if (atts && atts.length) {
      const wrap = el("div", "msg-atts", bubble);
      for (const a of atts) {
        if (a.kind === "image") {
          const im = el("img", "msg-att-img", wrap);
          im.src = "data:" + a.mimeType + ";base64," + a.data; im.alt = a.name;
        } else {
          el("span", "msg-att-file", wrap).textContent = "📎 " + a.name;
        }
      }
    }
    if (text) el("div", "msg-text", bubble).textContent = text;
    if (opts.isLast) {
      lastUserMsgEl = m;
      lastUserEntryId = opts.entryId || null;
      addMsgActions(m, text, { edit: true }, { onEdit: startEditLast });
      renderSiblingToggle(lastUserMsgEl, lastUserEntryId, siblingInfo, switchSiblingDir);
    }
    stick(true);
  }
  function startAssistant(): void {
    $("chat-hello").style.display = "none";
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    const thinkBox = el("details", "thinkbox", bubble);
    thinkBox.open = false; // collapsed by default; the reasoning stays tucked behind "Thinking" — click to expand
    el("summary", "", thinkBox).textContent = "Thinking";
    const thinkBody = el("div", "thinkbody", thinkBox);
    thinkBox.style.display = "none";
    const textNode = el("span", "atext", bubble);
    const cursor = el("span", "cursor", bubble);
    const meta = el("div", "meta", m);
    curAssistant = {
      m, bubble, thinkBox, thinkBody, textNode, cursor, meta, tools: new Map(),
      text: "", thinking: "", t0: performance.now(), tFirst: 0, tokens: 0,
      // Block-memoization state (see renderBlocksIncremental) for the main
      // markdown text stream, plus a shared rAF scheduler so a burst of
      // deltas within one frame (e.g. spec-decode emitting several tokens
      // back-to-back) collapses into a single re-render instead of one per
      // token. The thinking channel is plain text (no markdown — see
      // appendThinkingDelta), so it only needs the textContent set
      // throttled, not block splitting; it gets its own scheduler since
      // both channels can stream concurrently (interleaved thinking/text).
      blockState: { blocks: [] },
      scheduleText: () => {},
      scheduleThinking: () => {},
      citations: pendingCitations,
    };
    // Consumed — a later turn with no RAG'd attachments must not inherit
    // this turn's citation set (see the pendingCitations declaration above).
    pendingCitations = [];
    curAssistant.scheduleText = makeFrameScheduler(
      () => renderBlocksIncremental(curAssistant!.textNode, curAssistant!.text, curAssistant!.blockState),
      atBottom, stick);
    curAssistant.scheduleThinking = makeFrameScheduler(
      () => { curAssistant!.thinkBody.textContent = curAssistant!.thinking; },
      atBottom, stick);
    stick(true);
  }
  function ensureAssistant(): void { if (!curAssistant) startAssistant(); }

  function appendDelta(delta: string): void {
    ensureAssistant();
    const a = curAssistant!;
    if (!a.tFirst) a.tFirst = performance.now();
    a.tokens++;
    a.text += delta;
    // Block-memoized + rAF-throttled render (see renderBlocksIncremental):
    // only the live tail block re-parses per delta; completed blocks are
    // never touched again. A final full mdToHtml pass runs at turn-end
    // (finishStreaming) to guarantee the streamed result is byte-identical
    // to a non-streaming render. Autoscroll is handled INSIDE the scheduler
    // (its shouldStick/doStick args) — not here — because the render itself
    // is rAF-deferred: checking atBottom() synchronously at this point would
    // measure scrollHeight from before the queued render grows it, which
    // desyncs autoscroll once several deltas land within one frame.
    a.scheduleText();
    updateTps();
  }
  function appendThinkingDelta(delta: string): void {
    ensureAssistant();
    const a = curAssistant!;
    if (!a.tFirst) a.tFirst = performance.now();
    a.tokens++;
    a.thinking += delta;
    a.thinkBox.style.display = a.thinking.trim() ? "" : "none";
    // Plain text (no markdown here), but still rAF-throttled: a long
    // thinking trace can otherwise do one textContent-set per token.
    // Autoscroll: see the comment in appendDelta above — handled inside the
    // scheduler, not with a synchronous atBottom() check here.
    a.scheduleThinking();
    updateTps();
  }

  /* tool card lifecycle — dispatches to the memory provenance chip (plan
   *  §5.4.2) for memory_ and reference_ tool calls, the generic wrench card
   *  for everything else. Both kinds live in the same a.tools map (see
   *  ToolCardState above). */
  function toolCard(callId: string, tool: string, args: unknown): ToolCardState {
    ensureAssistant();
    const a = curAssistant!;
    let t = a.tools.get(callId);
    if (t) return t;
    if (isMemoryToolName(tool || "")) {
      const handle = memoryToolChip(a.bubble, tool, args);
      t = { kind: "memchip", wrap: handle.wrap, handle, chunks: "" };
      a.tools.set(callId, t);
      stick();
      return t;
    }
    const wrap = el("div", "tool running open", a.bubble);
    wrap.innerHTML =
      '<div class="thead"><div class="ticon">⚙</div>' +
      '<span class="tname">' + esc(tool || "tool") + '</span>' +
      '<span class="targs">' + esc(argSummary(args)) + '</span>' +
      '<span class="tstat"><span class="sdot"></span><span class="slabel">running</span></span>' +
      '<span class="caret">›</span></div>' +
      '<div class="tbody">' +
        '<div class="blk"><div class="blbl">arguments</div><pre class="aargs">' + esc(prettyArgs(args)) + '</pre></div>' +
        '<div class="blk tresult" style="display:none"><div class="blbl">result</div><pre class="ares"></pre></div>' +
      '</div>';
    wrap.querySelector(".thead")!.addEventListener("click", () => wrap.classList.toggle("open"));
    t = {
      kind: "wrench", wrap,
      res: wrap.querySelector(".ares") as HTMLElement,
      resBlk: wrap.querySelector(".tresult") as HTMLElement,
      label: wrap.querySelector(".slabel") as HTMLElement,
      chunks: "",
    };
    a.tools.set(callId, t);
    stick();
    return t;
  }
  function toolUpdate(callId: string, chunk: string): void {
    const t = curAssistant && curAssistant.tools.get(callId);
    if (!t) return;
    t.chunks += chunk;
    if (t.kind === "memchip") { t.handle.setResult(t.chunks); if (atBottom()) stick(); return; }
    t.resBlk.style.display = "";
    t.res.textContent = t.chunks.slice(-8000);
    if (atBottom()) stick();
  }
  function toolEnd(callId: string, ok: boolean, result: unknown): void {
    const t = curAssistant && curAssistant.tools.get(callId);
    if (!t) return;
    if (t.kind === "memchip") {
      t.wrap.classList.toggle("fail", !ok);
      t.handle.setResult(result != null ? result : t.chunks);
      return;
    }
    t.wrap.classList.remove("running");
    t.wrap.classList.add(ok ? "ok" : "fail");
    t.label.textContent = ok ? "done" : "failed";
    const body = result != null ? (typeof result === "string" ? result : JSON.stringify(result, null, 2)) : t.chunks;
    if (body) { t.resBlk.style.display = ""; t.res.textContent = String(body).slice(-12000); }
    if (!ok) t.wrap.classList.add("open");
  }

  /* approval dialog (plan §5.4/§6.5: editable arguments + durable "always
   *  allow this tool", on top of the existing running/ok/fail visual
   *  language). The diff view (edit/write) stays as a read-only visual aid
   *  ABOVE the editable textarea — losing the diff would make large
   *  file-content proposals unreadable as raw JSON — but the textarea,
   *  pre-filled with the proposed args as JSON, is what actually gets sent:
   *  editing it and clicking Allow re-parses it and ships the edited object
   *  as `editedArgs`, which pi-web.ts mutates onto the SDK's ToolCallEvent.input
   *  in place (the SDK's documented tool_call mutation contract). */
  function approvalCard(callId: string, tool: string, args: unknown): void {
    ensureAssistant();
    const a = curAssistant!;
    const wrap = el("div", "approval", a.bubble);
    const isBash = /bash|shell|exec|run/i.test(tool || "");
    const isEdit = /edit|write|patch|create/i.test(tool || "");
    const diffHtml = isEdit ? '<pre class="a-diff">' + diffView(args) + '</pre>' : "";
    const argsJson = prettyArgs(args);
    wrap.innerHTML =
      '<div class="ahead"><div class="ai">⚠</div><div class="at">Approval required</div>' +
      '<div class="as">' + esc(tool || "tool") + '</div></div>' +
      '<div class="abody">' + diffHtml +
        '<div class="blbl" style="margin-bottom:7px">' +
          (isBash ? "command (edit before approving if you like)" : isEdit ? "proposed change — arguments below, editable" : "arguments — editable before approving") +
        '</div>' +
        '<textarea class="a-args" spellcheck="false">' + esc(argsJson) + '</textarea>' +
        '<div class="a-argerr" style="display:none"></div>' +
      '</div>' +
      '<label class="chk a-always"><input type="checkbox" class="a-always-cb">Always allow ' + esc(tool || "this tool") + ' (skip this card next time)</label>' +
      '<div class="actions">' +
        '<button class="btn ghost sm a-deny">Deny</button>' +
        '<button class="btn primary sm a-allow">Allow</button></div>';
    const textarea = wrap.querySelector(".a-args") as HTMLTextAreaElement;
    const errEl = wrap.querySelector(".a-argerr") as HTMLElement;
    const alwaysCb = wrap.querySelector(".a-always-cb") as HTMLInputElement;
    const resolve = (decision: "allow" | "deny") => {
      let editedArgs: Record<string, unknown> | undefined;
      if (decision === "allow") {
        const raw = textarea.value.trim();
        if (raw && raw !== argsJson.trim()) {
          try {
            const parsed = JSON.parse(raw);
            if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
              editedArgs = parsed as Record<string, unknown>;
            } else {
              errEl.textContent = "Arguments must be a JSON object — sending the original instead.";
              errEl.style.display = "";
            }
          } catch {
            errEl.textContent = "Could not parse the edited arguments as JSON — sending the original instead.";
            errEl.style.display = "";
          }
        }
      }
      send({ type: "approval", callId, decision, editedArgs, alwaysAllow: decision === "allow" && alwaysCb.checked });
      wrap.querySelector(".actions")!.remove();
      wrap.querySelector(".a-always")?.remove();
      const r = el("div", "resolved " + (decision === "allow" ? "allow" : "deny"), wrap);
      r.textContent = decision === "allow" ? (editedArgs ? "✓ allowed (edited)" : "✓ allowed") : "✕ denied";
    };
    (wrap.querySelector(".a-allow") as HTMLButtonElement).onclick = () => resolve("allow");
    (wrap.querySelector(".a-deny") as HTMLButtonElement).onclick = () => resolve("deny");
    stick(true);
  }

  function showAgentError(message: string): void {
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    bubble.innerHTML = '<strong style="color:var(--red)">Agent error</strong><br>' + esc(message || "unknown error");
    stick(true);
  }

  /** Chat-with-files RAG v1 (plan §9 Phase 3, beat matrix Axis 5): append a
   *  collapsed "Sources · K" panel under the bubble and linkify any [n]
   *  markers the model actually used in its reply. Only ever called with a
   *  non-empty citation list (finishStreaming guards this) — an ordinary
   *  reply with no attachments gets neither the panel nor any [n]
   *  rewriting, so a message that happens to contain literal "[1]" text
   *  never gets a false citation link. */
  function attachSourcesPanel(a: AssistantMsgState): void {
    const validNs = new Set(a.citations.map((c) => c.n));
    a.textNode.innerHTML = linkifyCitations(a.textNode.innerHTML, validNs);
    const panel = el("div", "", null);
    panel.innerHTML = renderSourcesHtml(a.citations);
    const detailsEl = panel.firstElementChild as HTMLElement | null;
    if (!detailsEl) return;
    a.bubble.appendChild(detailsEl);
    // Clicking a [n] marker in the rendered text expands the panel (if
    // collapsed) and scrolls/highlights the matching source row.
    a.textNode.querySelectorAll<HTMLElement>(".cite-mark").forEach((btn) => {
      btn.addEventListener("click", () => {
        const n = btn.dataset.cite;
        (detailsEl as HTMLDetailsElement).open = true;
        const row = detailsEl.querySelector<HTMLElement>('.src-row[data-cite-row="' + n + '"]');
        if (row) {
          row.scrollIntoView({ block: "nearest", behavior: "smooth" });
          row.classList.add("pulse");
          setTimeout(() => row.classList.remove("pulse"), 1000);
        }
      });
    });
  }

  /** Turn-end finalization for the streamed text channel: replace the
   *  block-memoized incremental render with ONE full non-memoized
   *  mdToHtml(fullText) pass. This is the acceptance test for block
   *  memoization — whatever the incremental path did while streaming,
   *  the final DOM must match exactly what a plain, non-streaming
   *  render of the same text would have produced. Cheap (happens once
   *  per turn, not per token) and removes any residual "done" block
   *  wrappers so the settled message's markup matches replayed history
   *  (renderAssistantStatic / renderHistory), which also call mdToHtml
   *  directly on the full string. */
  function finishStreaming(a: AssistantMsgState | null): void {
    if (!a) return;
    // Preserve any Canvas Preview toggle the user made mid-stream (Principle
    // 9: this full non-memoized re-render must not throw away user
    // interaction state) — mdCodeBlock always emits qualifying fences back
    // in their default Source view, so without this a live Preview click
    // silently reverts the instant the turn finalizes.
    const previewIdx = captureCanvasViewStates(a.textNode);
    a.textNode.innerHTML = mdToHtml(a.text);
    restoreCanvasViewStates(a.textNode, previewIdx);
    highlightIn(a.textNode);
    a.thinkBody.textContent = a.thinking;
    if (a.citations.length) attachSourcesPanel(a);
  }

  /** Demote the previously-"last" assistant message: only ONE message ever
   *  shows Regenerate (plan §5.2 scopes it to the last assistant turn). */
  function clearRegenerateAffordance(): void {
    if (!lastAssistantMsgEl) return;
    const row = lastAssistantMsgEl.querySelector(".msg-actions");
    const btn = row && [...row.querySelectorAll(".maction")].find((b) => b.textContent === "Regenerate");
    if (btn) btn.remove();
  }

  function endTurn(): void {
    turnActive = false;
    if (curAssistant) {
      finishStreaming(curAssistant);
      curAssistant.cursor.remove();
      if (!curAssistant.text && !curAssistant.thinking && curAssistant.tools.size === 0) {
        curAssistant.m.remove();
      } else {
        // A settled assistant reply becomes the new regenerate target.
        // Works after abort/stop too — a partial reply still gets the
        // action row, and the server resolves regenerate from the session's
        // last user message regardless of whether this reply finished.
        clearRegenerateAffordance();
        addMsgActions(curAssistant.m, curAssistant.text, { regenerate: true }, { onRegenerate: doRegenerate });
        lastAssistantMsgEl = curAssistant.m;
        lastAssistantCitations = curAssistant.citations;
      }
    }
    curAssistant = null;
    ($("chat-send") as HTMLButtonElement).disabled = false;
    $("chat-stop").style.display = "none";
    renderQueue({});
  }

  // Perf strip (plan §5.2/§6.4): tok/s + TTFT update live during streaming;
  // context-fill is driven separately by the `context` frame (renderContext).
  // All client-computed from data the composer already has — the lane badge
  // is the only server-driven field (see renderLane / the turn_end handler).
  function updateTps(): void {
    const a = curAssistant; if (!a) return;
    const secs = (performance.now() - (a.tFirst || a.t0)) / 1000;
    if (a.tokens > 1 && secs > 0) {
      const tps = $("pf-tps"); if (tps) tps.innerHTML = "<b style='color:var(--green)'>" + (a.tokens / secs).toFixed(1) + " tok/s</b>";
    }
    if (a.tFirst) {
      const ttft = $("pf-ttft"); if (ttft) ttft.textContent = "TTFT " + Math.round(a.tFirst - a.t0) + "ms";
    }
  }
  function finalizeMeta(): void {
    const a = curAssistant; if (!a) return;
    const secs = (performance.now() - (a.tFirst || a.t0)) / 1000;
    if (a.tokens > 1 && secs > 0)
      a.meta.innerHTML = "<b>" + (a.tokens / secs).toFixed(1) + " tok/s</b> · " + a.tokens +
        " tokens · first token " + Math.round((a.tFirst - a.t0)) + "ms";
  }

  function newChat(): void {
    if (!send({ type: "new_session" })) { toast("Not connected to the agent yet.", "err"); return; }
    $("chat-box").focus();
    closeDrawer(); // a fresh chat is the natural "I'm done browsing" signal on mobile
  }

  /** Render a finished assistant turn from replayed history (no streaming).
   *  `opts.isLast` attaches the Regenerate action (plan §5.2: last turn only). */
  function renderAssistantStatic(item: HistoryItem, opts: { isLast?: boolean }): void {
    const m = el("div", "msg assistant", thread());
    el("div", "who", m).textContent = "local agent";
    const bubble = el("div", "bubble", m);
    if (item.thinking && item.thinking.trim()) {
      const tb = el("details", "thinkbox", bubble); tb.open = false;
      el("summary", "", tb).textContent = "Thinking";
      el("div", "thinkbody", tb).textContent = item.thinking;
    }
    if (item.text) { const tn = el("span", "atext", bubble); tn.innerHTML = mdToHtml(item.text); highlightIn(tn); }
    for (const t of (item.tools || [])) {
      if (isMemoryToolName(t.name || "")) {
        const handle = memoryToolChip(bubble, t.name, t.args);
        if (t.result) handle.setResult(t.result);
        continue;
      }
      const wrap = el("div", "tool ok", bubble);   // collapsed; click to expand
      wrap.innerHTML =
        '<div class="thead"><div class="ticon">⚙</div>' +
        '<span class="tname">' + esc(t.name || "tool") + '</span>' +
        '<span class="targs">' + esc(argSummary(t.args)) + '</span>' +
        '<span class="tstat"><span class="sdot"></span><span class="slabel">done</span></span>' +
        '<span class="caret">›</span></div>' +
        '<div class="tbody">' +
          '<div class="blk"><div class="blbl">arguments</div><pre class="aargs">' + esc(prettyArgs(t.args)) + '</pre></div>' +
          (t.result ? '<div class="blk tresult"><div class="blbl">result</div><pre class="ares">' + esc(String(t.result).slice(-12000)) + '</pre></div>' : '') +
        '</div>';
      wrap.querySelector(".thead")!.addEventListener("click", () => wrap.classList.toggle("open"));
    }
    if (item.text) {
      addMsgActions(m, item.text, { regenerate: !!opts.isLast }, { onRegenerate: doRegenerate });
      if (opts.isLast) {
        lastAssistantMsgEl = m;
        // History replay doesn't carry citations (HistoryItem has no
        // citations field — the server doesn't persist them across
        // reload), so there's nothing to restore here; this keeps
        // lastAssistantCitations honest (no stale carry-over from a
        // previous session) rather than claiming a citation set for a
        // reply that regenerate can't actually attribute one to.
        lastAssistantCitations = [];
      }
    }
  }

  /** Authoritative thread rebuild from a server `history` frame. */
  function renderHistory(items: HistoryItem[]): void {
    turnActive = false;
    curAssistant = null;
    ($("chat-send") as HTMLButtonElement).disabled = false;
    $("chat-stop").style.display = "none";
    renderQueue({});
    thread().innerHTML = "";
    lastUserMsgEl = null; lastAssistantMsgEl = null;
    if (!items || !items.length) { $("chat-hello").style.display = ""; return; }
    $("chat-hello").style.display = "none";
    const lastUserIdx = items.map((it) => it.role).lastIndexOf("user");
    const lastAssistantIdx = items.map((it) => it.role).lastIndexOf("assistant");
    items.forEach((it, i) => {
      if (it.role === "user") addUserMsg(it.text, null, { isLast: i === lastUserIdx, entryId: it.entryId });
      else renderAssistantStatic(it, { isLast: i === lastAssistantIdx });
    });
    stick(true);
  }

  /* — server -> client dispatch — */
  function handle(m: ServerMessage): void {
    switch (m.type) {
      case "ready":
        $("nav-model").textContent = m.model || ($("nav-model").textContent as string) || "no model";
        composer.visionCapable = !!m.vision; updateAttachHint(composer);
        composer.thinkingCapable = !!m.thinking; updateThinkingToggle(composer);
        // Per-model recommended sampling (generation_config.json, server-CLI
        // overrides applied) — replaces the old hardcoded SAMP_REC shape.
        composer.genDefaults = m.genDefaults || ({ temperature: null, topP: null, topK: null } as ReadyGenDefaults);
        refreshSamplingRecs(composer);
        if (composer.thinkingCapable) send({ type: "set_thinking", enabled: composer.thinkingOn });
        composerRefreshAdapters();
        // Restore this browser's codingTools preference (plan §5.4/§6.5).
        // Sent every `ready` (including reconnects): a fresh WS session
        // always starts codingToolsRequested=false server-side, so a
        // previously-on browser must re-assert it, and the coding_tools
        // frame that follows will report whether it's active yet or only
        // pending for the next new/opened chat.
        send({ type: "set_coding_tools", enabled: storedCodingToolsPreference() });
        // App-aware assistant (plan §6.6): a fresh WS session starts with no
        // stored context server-side (currentAppContext is null until the
        // first push) — every `ready` (initial connect AND reconnect) must
        // re-push so get_current_app_context / the ambient line are never
        // blind while a browser tab sits idle on a non-chat route.
        pushAppContext();
        // Reconnect: re-open the session we were in (fresh load has none).
        if (pendingResumePath) { send({ type: "open_session", path: pendingResumePath }); pendingResumePath = null; }
        break;
      case "coding_tools": renderCodingToolsState(m.active, m.pending); break;
      case "tool_approvals":
        renderToolApprovals(m.alwaysAllow, (tool) => forgetToolApproval(tool));
        break;
      case "history": renderHistory(m.items); break;
      case "sessions":
        currentSessionPath = m.activePath || null;
        renderSessions(sidebar, m.items, m.activePath, {
          onOpen: (path) => { send({ type: "open_session", path }); closeDrawer(); },
          onFork: (path) => send({ type: "fork_session", path }),
          onDelete: (path) => send({ type: "delete_session", path }),
        });
        break;
      case "context": renderContext(m as ContextFrame); break;
      // Sibling group for the last user message (edit-and-resend's `< i/n >`
      // toggle, plan §5.2) — see renderSiblingToggle/switchSiblingDir.
      case "siblings":
        siblingInfo = { entryId: m.entryId || null, index: m.index, count: m.count, siblingIds: m.siblingIds || [] };
        lastUserEntryId = siblingInfo.entryId;
        renderSiblingToggle(lastUserMsgEl, lastUserEntryId, siblingInfo, switchSiblingDir);
        break;
      case "turn_start": turnActive = true; startAssistant(); ($("chat-send") as HTMLButtonElement).disabled = true; $("chat-stop").style.display = "block"; break;
      case "text_delta": appendDelta(m.delta || ""); break;
      case "thinking_delta": appendThinkingDelta(m.delta || ""); break;
      case "tool_start": toolCard(m.callId, m.tool, m.args); break;
      case "tool_approval_request": approvalCard(m.callId, m.tool, m.args); break;
      case "tool_update": toolUpdate(m.callId, (m.chunk as string) || ""); break;
      case "tool_end": toolEnd(m.callId, m.ok, m.result); break;
      // clearOneShotArmed: a one-shot next_turn sampling override (if any
      // was armed) has now been consumed by the server for exactly this
      // turn — clear the local indicator in lockstep (plan §9 Phase 3 item 2).
      case "turn_end": finalizeMeta(); renderLane(m.lane as Lane | undefined); clearOneShotArmed(composer); endTurn(); break;
      case "queue_update": renderQueue(m); break;
      // A prompt/regenerate/edit_resend that fails before the server ever
      // reaches turn_start (no model selected, auth failure, etc.) never
      // sends turn_end, so this is also where a one-shot next_turn sampling
      // override must be cleared client-side — the server clears its own
      // copy on this same failure path (clearArmedOneShotOnFailedPrompt in
      // pi-web.ts), so the two stay in lockstep instead of the UI's "armed"
      // pill lingering after the override it referred to is already gone.
      case "error": showAgentError(m.message || "agent error"); toast(m.message || "agent error", "err"); clearOneShotArmed(composer); if (turnActive) endTurn(); break;
      // App-aware assistant (plan §6.6): navigate_app / spotlight_ui tool
      // calls arrive as these two frames. Navigation always routes through
      // location.hash (the SAME mechanism a nav-tab click uses — shell.ts's
      // hashchange listener does the actual section toggle), so it's
      // indistinguishable from the user clicking the tab themselves.
      case "ui_navigate":
        location.hash = `#/${m.route}`;
        break;
      // spotlight_ui: navigate first if the tool asked (route present), THEN
      // resolve+show — every route's section already lives in the DOM,
      // toggled by CSS (shell.ts's router()), so no waitForElement polling
      // is needed the way a client-side-routed app would require.
      case "ui_spotlight": {
        if (m.route) location.hash = `#/${m.route}`;
        const resolved = resolveSpotlightTarget(
          { ref: m.ref, label: m.label, selector: m.selector, target: m.target, message: m.message },
          lastSnapshot,
        );
        if (!resolved || !showSpotlight(resolved)) {
          toast("Couldn't find that on screen to point at.", "err");
        }
        break;
      }
    }
  }

  /* — composer submit — */
  function submit(): void {
    const box = $("chat-box") as HTMLTextAreaElement;
    const text = box.value.trim();
    // Client-side slash commands for session control (not sent to the model).
    const cmd = text.toLowerCase();
    if (cmd === "/reload" || cmd === "/new" || cmd === "/clear") {
      box.value = ""; box.style.height = "auto"; clearAttachments(composer); newChat();
      return;
    }
    if (!text && composer.attachments.length === 0) return;
    if (!connected) { toast("Not connected to the agent yet — reconnecting.", "err"); return; }
    const imgs = composer.attachments.filter((a) => a.kind === "image").map((a) => ({ data: a.data as string, mimeType: a.mimeType as string }));
    const combined = buildMessageText(composer, text);
    // entryId isn't known yet (assigned server-side); the next `siblings`
    // frame (sent on turn_end) backfills it via renderSiblingToggle's
    // entryId-mismatch check, same as a fresh page load's history replay.
    addUserMsg(text, composer.attachments as unknown as { kind: string; data?: string; mimeType?: string; name: string }[], { isLast: true });
    box.value = ""; box.style.height = "auto";
    // buildMessageText returns { text, citations } (RAG v1, plan §9 Phase 3
    // Axis 5): .text is the WS-outgoing prompt string (with the numbered
    // context block injected when retrieval mode fired); .citations stash
    // into pendingCitations so startAssistant() can attach them to the
    // AssistantMsgState this prompt's reply streams into once turn_start
    // arrives (empty array — the common case — is a no-op all the way
    // through: no Sources panel, no [n] linkification).
    pendingCitations = combined.citations;
    const frame: ClientMessage = imgs.length ? { type: "prompt", text: combined.text, images: imgs } : { type: "prompt", text: combined.text };
    // A composer submission is always a new user turn. If the model is still
    // streaming, the server passes it to pi with streamingBehavior:"followUp"
    // so it becomes the next turn instead of steering/mutating the current one.
    send(frame);
    clearAttachments(composer);
  }
  const scroll = () => $("chat-scroll");
  const atBottom = () => scroll().scrollHeight - scroll().scrollTop - scroll().clientHeight < 90;
  function stick(force?: boolean): void { if (force || atBottom()) scroll().scrollTop = scroll().scrollHeight; }

  /** Cmd/Ctrl+Shift+C (plan §7): reuses the exact per-message Copy button
   *  (addMsgActions) on the last assistant message rather than duplicating
   *  its clipboard logic — a synthetic click keeps the "Copied" flash
   *  feedback consistent with the mouse path. */
  function copyLastResponse(): void {
    if (!lastAssistantMsgEl) { toast("No response to copy yet.", "err"); return; }
    const btn = lastAssistantMsgEl.querySelector(".msg-actions .maction") as HTMLButtonElement | null;
    if (btn) btn.click();
  }

  /** Cross-controller call from shell.ts's settings toggle (plan §5.4/§6.5)
   *  — shell.ts owns the checkbox + localStorage mirror but no WebSocket, so
   *  it calls this via controllers.chat.setCodingTools, same pattern as
   *  newChat/copyLastResponse below. */
  function setCodingTools(enabled: boolean): void {
    send({ type: "set_coding_tools", enabled });
  }

  /** "Forget" a durable always-allow entry from the settings panel. REST,
   *  not a WS frame — src/tool-approvals.ts is a plain server-side file, no
   *  live session state to touch, matching the hf-token settings routes'
   *  own GET/POST-over-fetch pattern. Re-renders the list from the response
   *  rather than waiting on a tool_approvals WS frame (this connection's
   *  session may not be the one that granted it, and REST is instant). */
  async function forgetToolApproval(tool: string): Promise<void> {
    const d = await api("/api/settings/tool-approvals", { method: "DELETE", body: { tool } })
      .catch((): ApiEnvelope => ({ ok: false, error: "request failed" }));
    if (!d.ok) { toast(d.error || "could not forget that tool", "err"); return; }
    renderToolApprovals((d as { alwaysAllow?: string[] }).alwaysAllow || [], (t) => forgetToolApproval(t));
    toast("Forgot “" + tool + "” — it will ask again next time", "ok");
  }

  return {
    init() {
      ($("chat-send") as HTMLButtonElement).onclick = submit;
      ($("chat-new") as HTMLButtonElement).onclick = newChat;
      ($("chat-stop") as HTMLButtonElement).onclick = () => { send({ type: "abort" }); $("chat-stop").style.display = "none"; };
      const thinkToggle = () => { composer.thinkingOn = !composer.thinkingOn; updateThinkingToggle(composer); send({ type: "set_thinking", enabled: composer.thinkingOn }); };
      ($("chat-think") as HTMLButtonElement).onclick = thinkToggle;
      $("chat-think").addEventListener("keydown", (e) => { if ((e as KeyboardEvent).key === "Enter" || (e as KeyboardEvent).key === " ") { e.preventDefault(); thinkToggle(); } });
      const adapterSel = $("chat-adapter") as HTMLSelectElement | null;
      if (adapterSel) adapterSel.onchange = () => {
        // Keep the routing table's notion of "selected for this chat" in
        // sync with the quick <select> — one source of truth for what's
        // selected, read by both surfaces (plan §5.6: "keep them consistent").
        adaptersPanel.selectedSpec = adapterSel.value || null;
        adaptersPanel.stackPicks.clear();
        onSelectAdapter(adapterSel, send as (obj: unknown) => boolean);
      };
      initAdaptersPanel(adaptersPanel, send as (obj: unknown) => boolean);
      initSampling(composer, send as (obj: unknown) => boolean);
      initSystemPrompt(composer, send as (obj: unknown) => boolean);
      composerRefreshAdapters();
      const sessSearch = $("chat-sess-search");
      if (sessSearch) sessSearch.addEventListener("input", () => applySessSearch(sidebar));
      const box = $("chat-box") as HTMLTextAreaElement;
      // Mention-picker keydown (arrows/Enter/Escape) must see Enter BEFORE
      // the submit-on-Enter handler below — addEventListener preserves
      // registration order, and initMentionPicker's handler only
      // preventDefault()s when its popover is actually open, so a plain
      // Enter with no picker open falls through to submit() untouched.
      initMentionPicker(composer, box, {
        onFileSelected: (att) => {
          const chip = document.querySelector<HTMLElement>('.attach-chip[data-att-id="' + att.id + '"]');
          if (chip) { chip.scrollIntoView({ block: "nearest", behavior: "smooth" }); chip.classList.add("pulse"); setTimeout(() => chip.classList.remove("pulse"), 1000); }
        },
      });
      box.addEventListener("keydown", (e) => {
        if ($("chat-mention-pop").classList.contains("open")) return; // picker owns Enter/arrows/Escape while open
        if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); submit(); }
      });
      box.addEventListener("input", () => { box.style.height = "auto"; box.style.height = Math.min(box.scrollHeight, 200) + "px"; });
      // Delegated (not per-chip) so the personalized chips memory-panel.ts
      // inserts on top of these four static ones (plan §5.1) work with zero
      // extra wiring — #chat-hello-chips is stable even though its contents
      // change (static chips today, +2 personalized ones once the first
      // /api/memory/status + /v1/adapters/available round trip resolves).
      $("chat-hello-chips").addEventListener("click", (e) => {
        const chip = (e.target as HTMLElement).closest<HTMLElement>(".chip");
        if (!chip) return;
        ($("chat-box") as HTMLTextAreaElement).value = chip.dataset.q || "";
        submit();
      });
      initMemoryPanel();
      // Attachments: + button, file picker, clipboard paste, drag-and-drop.
      ($("chat-attach-btn") as HTMLButtonElement).onclick = () => ($("chat-file-input") as HTMLInputElement).click();
      $("chat-file-input").addEventListener("change", (e) => { addFiles(composer, [...(e.target as HTMLInputElement).files || []]); (e.target as HTMLInputElement).value = ""; });
      box.addEventListener("paste", (e) => {
        const items = e.clipboardData && e.clipboardData.items;
        if (!items) return;
        const files: File[] = [];
        for (const it of items) if (it.kind === "file") { const f = it.getAsFile(); if (f) files.push(f); }
        if (files.length) { e.preventDefault(); addFiles(composer, files); }
      });
      const composerEl = document.querySelector<HTMLElement>("#s-chat .composer");
      if (composerEl) {
        ["dragenter", "dragover"].forEach((ev) => composerEl.addEventListener(ev, (e) => { e.preventDefault(); composerEl.classList.add("dragover"); }));
        ["dragleave", "drop"].forEach((ev) => composerEl.addEventListener(ev, (e) => {
          e.preventDefault();
          const de = e as DragEvent;
          if (ev === "drop" && de.dataTransfer && de.dataTransfer.files.length) addFiles(composer, [...de.dataTransfer.files]);
          if (ev === "drop" || !composerEl.contains(de.relatedTarget as Node)) composerEl.classList.remove("dragover");
        }));
      }
      // Delegated copy buttons for rendered code blocks (the thread element
      // is stable even though its contents re-render on every token).
      thread().addEventListener("click", (e) => {
        const target = e.target as HTMLElement;
        const btn = target.closest && target.closest(".cbcopy");
        if (!btn) return;
        const code = btn.closest(".codeblock")?.querySelector("code");
        if (!code || !navigator.clipboard) return;
        navigator.clipboard.writeText(code.textContent || "").then(() => {
          btn.textContent = "Copied"; setTimeout(() => { btn.textContent = "Copy"; }, 1200);
        }).catch(() => {});
      });
      // Canvas v1 (plan §9 Phase 3): Preview|Source toggle for html/svg
      // fences, delegated the same way as the copy button above.
      wireCanvasToggle(thread());

      // App-aware assistant (plan §6.6): registered at document/window level
      // (not scoped to the chat route being active) since chat.ts owns the
      // one WebSocket for the whole app and must push context on every
      // route, regardless of which route the user navigates TO or FROM.
      // hashchange covers route changes; the MutationObserver covers wizard
      // step changes (quantize/finetune/dataset); a MutationObserver on each
      // overlay's `class` attribute covers view changes (memory/hub/adapters
      // panel open/close) without touching those three modules.
      window.addEventListener("hashchange", pushAppContext);
      watchWizardSteps();
      const overlayMo = new MutationObserver(() => pushAppContext());
      for (const id of ["mem-overlay", "hub-overlay", "adapters-overlay"]) {
        const el = $(id);
        if (el) overlayMo.observe(el, { attributes: true, attributeFilter: ["class"] });
      }
    },
    enter() {
      if (!ws || ws.readyState > 1) connect();
      $("chat-box").focus();
      // Refresh the adapter list on every chat enter (web-ui-pass-plan.md
      // #15's staleness half): a training job that completed while the user
      // was elsewhere, or a manual drop into the adapters directory, should
      // show up without needing a full page reload. Cheap (one GET) and the
      // list is short.
      composerRefreshAdapters();
    },
    leave() { /* keep WS warm; closing on every nav would drop in-flight turns */ },
    // Exposed so the finetune controller can refresh the chat adapter chip
    // immediately when a training job finishes, instead of waiting for the
    // user to navigate back to Chat (which would also refresh it via enter()).
    refreshAdapters: composerRefreshAdapters,
    // Exposed for the global keyboard-shortcut sweep (plan §7): Cmd/Ctrl+Shift+O
    // and Cmd/Ctrl+Shift+C, bound at document level so they work regardless
    // of which control has focus while on the chat route.
    newChat,
    copyLastResponse,
    // Exposed for shell.ts's settings modal (plan §5.4/§6.5) — it owns the
    // checkbox/list DOM and localStorage, but has no WebSocket of its own.
    setCodingTools,
    forgetToolApproval,
  };
}
