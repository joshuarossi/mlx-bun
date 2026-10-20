// The streaming turn: one assistant message as its frames arrive. Text and thinking deltas render through
// `markdown.ts`'s block memoization, coalesced to one render per animation frame; tool calls draw as compact rows
// (or the host's own card, such as memory's provenance chip); an approval request draws as an editable notice;
// the turn settles with one full `mdToHtml` pass (the streamed DOM then equals a one-shot render, with any Canvas
// Preview the reader opened kept), a Sources panel when the prompt carried retrieved excerpts, and a meta line.
// `endTurn` always leaves the composer usable, whatever ended the turn: Send enabled, Stop hidden, no cursor, no queue.
import { el, esc, ms, rate } from "@mlx-bun/web-kit";
import type { ClientMessage } from "../protocol";
import type { ChatHost, ToolCardHandle } from "./host";
import { ICON } from "./icons";
import {
  captureCanvasViewStates, highlightIn, linkifyCitations, makeFrameScheduler, mdToHtml, renderBlocksIncremental,
  restoreCanvasViewStates, type BlockState,
} from "./markdown";
import { renderPerf, renderQueue, setStreaming } from "./composer";
import type { Citation } from "./rag";

/** The thread's scroll column: a render keeps the reader pinned to the bottom only when they were already there. */
export interface Scroller {
  atBottom(): boolean;
  stick(force?: boolean): void;
}

export function createScroller(scroll: () => HTMLElement | null): Scroller {
  const atBottom = () => { const s = scroll(); return !s || s.scrollHeight - s.scrollTop - s.clientHeight < 90; };
  return {
    atBottom,
    stick(force) { const s = scroll(); if (s && (force || atBottom())) s.scrollTop = s.scrollHeight; },
  };
}

/* Tool arguments as a card shows them, shared with replayed history. */

export function argSummary(args: unknown): string {
  if (!args) return "";
  if (typeof args === "string") return args.slice(0, 120);
  const a = args as Record<string, unknown>;
  if (a.command || a.cmd) return String(a.command || a.cmd).slice(0, 120);
  if (a.file_path || a.path) return String(a.file_path || a.path).slice(0, 120);
  if (a.query || a.url || a.location) return String(a.query || a.url || a.location).slice(0, 120);
  const s = JSON.stringify(args); return s.length > 120 ? s.slice(0, 117) + "…" : s;
}

export function prettyArgs(args: unknown): string {
  if (args == null) return "";
  if (typeof args === "string") return args;
  try { return JSON.stringify(args, null, 2); } catch { return String(args); }
}

/** A read-only diff view of an edit or write tool's arguments, above the editable JSON in the approval card. */
function diffView(args: unknown): string {
  if (!args) return "";
  const a = args as Record<string, unknown>;
  if (a.old_string != null || a.new_string != null) {
    const removed = String(a.old_string ?? "").split("\n").map((l) => '<span class="diffdel">- ' + esc(l) + "</span>").join("\n");
    const added = String(a.new_string ?? "").split("\n").map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join("\n");
    return (a.file_path ? esc(a.file_path) + "\n\n" : "") + removed + (removed && added ? "\n" : "") + added;
  }
  if (a.content != null) {
    return (a.file_path ? esc(a.file_path) + "\n\n" : "") + String(a.content).split("\n").map((l) => '<span class="diffadd">+ ' + esc(l) + "</span>").join("\n");
  }
  return esc(prettyArgs(args));
}

const TOOL_STATE = { running: "Running", ok: "Done", fail: "Failed" } as const;
export type ToolState = keyof typeof TOOL_STATE;

/** A tool call's card: one compact row (name, what it ran on, its state) that expands to the arguments and result. */
export function toolCard(parent: HTMLElement, name: string, args: unknown, state: ToolState, result?: string): HTMLElement {
  const wrap = el("div", "tool " + state, parent);
  wrap.innerHTML =
    '<button type="button" class="thead" aria-expanded="false">' +
      '<span class="ticon">' + ICON.tool + "</span>" +
      '<span class="tname">' + esc(name || "tool") + "</span>" +
      '<span class="targs">' + esc(argSummary(args)) + "</span>" +
      '<span class="tstat tag"><span class="slabel">' + TOOL_STATE[state] + "</span></span>" +
      '<span class="caret">' + ICON.chevron + "</span></button>" +
    '<div class="tbody">' +
      '<div class="blk"><div class="blbl">Arguments</div><pre class="aargs">' + esc(prettyArgs(args)) + "</pre></div>" +
      '<div class="blk tresult"' + (result ? "" : ' style="display:none"') + '><div class="blbl">Result</div><pre class="ares">' + esc(result ?? "") + "</pre></div>" +
    "</div>";
  const head = wrap.querySelector<HTMLButtonElement>(".thead")!;
  head.addEventListener("click", () => setToolOpen(wrap, !wrap.classList.contains("open")));
  return wrap;
}

function setToolOpen(wrap: HTMLElement, open: boolean): void {
  wrap.classList.toggle("open", open);
  wrap.querySelector(".thead")?.setAttribute("aria-expanded", String(open));
}

/** The Sources panel for a turn whose prompt carried retrieved excerpts: a collapsed "Sources · K" line that expands to
 * each excerpt's file, range and a short snippet (the panel points back to the source; it is not a viewer). */
export function renderSourcesHtml(citations: Citation[]): string {
  if (!citations.length) return "";
  const rows = citations.map((c) => {
    const snippet = c.text.length > 240 ? c.text.slice(0, 240).trim() + "…" : c.text.trim();
    return '<div class="src-row" data-cite-row="' + c.n + '">' +
      '<span class="src-n">[' + c.n + "]</span>" +
      '<span class="src-meta"><span class="src-file">' + esc(c.fileName) + "</span>" +
      '<span class="src-range">chars ' + c.start + "–" + c.end + "</span></span>" +
      '<div class="src-snippet">' + esc(snippet) + "</div></div>";
  }).join("");
  return '<details class="sources"><summary>Sources · ' + citations.length + "</summary>" +
    '<div class="src-list">' + rows + "</div></details>";
}

/** A tool call drawn by the panel, or by the host in its place: both are keyed by call id for the later frames. */
type ToolEntry =
  | { kind: "card"; wrap: HTMLElement; res: HTMLElement; resBlk: HTMLElement; label: HTMLElement; chunks: string }
  | { kind: "host"; wrap: HTMLElement; handle: ToolCardHandle; chunks: string };

/** One assistant message while it streams. */
export interface AssistantTurn {
  readonly m: HTMLElement;
  readonly bubble: HTMLElement;
  readonly thinkBox: HTMLDetailsElement;
  readonly thinkBody: HTMLElement;
  readonly textNode: HTMLElement;
  readonly cursor: HTMLElement;
  readonly meta: HTMLElement;
  readonly tools: Map<string, ToolEntry>;
  readonly scroller: Scroller;
  /** The excerpts the prompt carried (empty for an ordinary prompt: no Sources panel, no `[n]` links). */
  readonly citations: Citation[];
  text: string;
  thinking: string;
  t0: number;
  tFirst: number;
  tokens: number;
  settled: boolean;
  blockState: BlockState;
  scheduleText(): void;
  scheduleThinking(): void;
}

/** The message shell an assistant reply renders into (also used by replayed history). */
export function assistantShell(thread: HTMLElement): { m: HTMLElement; bubble: HTMLElement } {
  const m = el("div", "msg assistant", thread);
  el("div", "who sr-only", m).textContent = "Assistant";
  return { m, bubble: el("div", "bubble", m) };
}

/** The collapsed "Thinking" disclosure (also used by replayed history). */
export function thinkingBox(bubble: HTMLElement): { box: HTMLDetailsElement; body: HTMLElement } {
  const box = el("details", "thinkbox", bubble);
  box.open = false;
  el("summary", "", box).innerHTML = ICON.chevron + "<span>Thinking</span>";
  return { box, body: el("div", "thinkbody", box) };
}

export function startTurn(thread: HTMLElement, citations: Citation[], scroller: Scroller): AssistantTurn {
  const { m, bubble } = assistantShell(thread);
  const { box: thinkBox, body: thinkBody } = thinkingBox(bubble);
  thinkBox.classList.add("live");
  thinkBox.style.display = "none";
  const textNode = el("div", "atext", bubble);
  const cursor = el("span", "cursor", bubble);
  cursor.setAttribute("aria-hidden", "true");
  const meta = el("div", "meta", m);
  const turn: AssistantTurn = {
    m, bubble, thinkBox, thinkBody, textNode, cursor, meta, tools: new Map(), scroller, citations,
    text: "", thinking: "", t0: performance.now(), tFirst: 0, tokens: 0, settled: false,
    blockState: { blocks: [] },
    scheduleText: () => {},
    scheduleThinking: () => {},
  };
  // One render per animation frame per channel, so a burst of deltas costs one reflow; the scheduler samples whether
  // the reader is at the bottom right before it renders, so the pin decision matches the height it acts on.
  turn.scheduleText = makeFrameScheduler(() => { if (!turn.settled) renderBlocksIncremental(turn.textNode, turn.text, turn.blockState); }, scroller.atBottom, scroller.stick);
  turn.scheduleThinking = makeFrameScheduler(() => { if (!turn.settled) turn.thinkBody.textContent = turn.thinking; }, scroller.atBottom, scroller.stick);
  scroller.stick(true);
  return turn;
}

function countToken(turn: AssistantTurn): void {
  if (!turn.tFirst) turn.tFirst = performance.now();
  turn.tokens++;
  const secs = (performance.now() - turn.tFirst) / 1000;
  renderPerf({ ttftMs: turn.tFirst - turn.t0, ...(turn.tokens > 1 && secs > 0 ? { tps: turn.tokens / secs } : {}) });
}

export function appendText(turn: AssistantTurn, delta: string): void {
  countToken(turn);
  turn.thinkBox.classList.remove("live"); // the answer has begun: the thinking is done
  turn.text += delta;
  turn.scheduleText();
}

/** Thinking is plain text (no markdown), still rendered at most once per frame. */
export function appendThinking(turn: AssistantTurn, delta: string): void {
  countToken(turn);
  turn.thinking += delta;
  turn.thinkBox.style.display = turn.thinking.trim() ? "" : "none";
  turn.scheduleThinking();
}

export function startTool(turn: AssistantTurn, callId: string, tool: string, args: unknown, host: ChatHost | undefined): void {
  if (turn.tools.has(callId)) return;
  const custom = host?.toolCard?.(turn.bubble, tool, args);
  if (custom) turn.tools.set(callId, { kind: "host", wrap: custom.wrap, handle: custom, chunks: "" });
  else {
    const wrap = toolCard(turn.bubble, tool, args, "running");
    turn.tools.set(callId, { kind: "card", wrap, res: wrap.querySelector(".ares")!, resBlk: wrap.querySelector(".tresult")!, label: wrap.querySelector(".slabel")!, chunks: "" });
  }
  turn.scroller.stick();
}

export function updateTool(turn: AssistantTurn, callId: string, chunk: string): void {
  const entry = turn.tools.get(callId);
  if (!entry) return;
  entry.chunks += chunk;
  if (entry.kind === "host") entry.handle.setResult(entry.chunks);
  else { entry.resBlk.style.display = ""; entry.res.textContent = entry.chunks.slice(-8000); }
  if (turn.scroller.atBottom()) turn.scroller.stick();
}

export function endTool(turn: AssistantTurn, callId: string, ok: boolean, result: unknown): void {
  const entry = turn.tools.get(callId);
  if (!entry) return;
  if (entry.kind === "host") {
    entry.wrap.classList.toggle("fail", !ok);
    entry.handle.setResult(result != null ? result : entry.chunks);
    return;
  }
  entry.wrap.classList.remove("running");
  entry.wrap.classList.add(ok ? "ok" : "fail");
  entry.label.textContent = ok ? TOOL_STATE.ok : TOOL_STATE.fail;
  const body = result != null ? (typeof result === "string" ? result : JSON.stringify(result, null, 2)) : entry.chunks;
  if (body) { entry.resBlk.style.display = ""; entry.res.textContent = String(body).slice(-12000); }
  if (!ok) setToolOpen(entry.wrap, true);
}

/** The approval card: the proposed arguments in an editable box (a diff above it for edits and writes), and
 * "always allow" for this tool. Allowing with edited arguments sends them as `editedArgs`; arguments that do not
 * parse as a JSON object fall back to the original, and the card says so. */
export function showApproval(turn: AssistantTurn, callId: string, tool: string, args: unknown, send: (frame: ClientMessage) => boolean): void {
  const wrap = el("div", "approval notice warn", turn.bubble);
  const name = tool || "tool";
  const isBash = /bash|shell|exec|run/i.test(name);
  const isEdit = /edit|write|patch|create/i.test(name);
  const argsJson = prettyArgs(args);
  wrap.setAttribute("role", "group");
  wrap.setAttribute("aria-label", "Approval needed for " + name);
  wrap.innerHTML =
    '<div class="ahead"><span class="ai">' + ICON.warning + '</span><b class="at">Approval needed</b><code class="as">' + esc(name) + "</code></div>" +
    '<div class="abody">' + (isEdit ? '<pre class="a-diff">' + diffView(args) + "</pre>" : "") +
      '<label class="blbl" for="a-args-' + esc(callId) + '">' +
        (isBash ? "The command. Edit it before you allow it, if you like." : isEdit ? "The proposed change, as editable arguments." : "The arguments. Edit them before you allow the call, if you like.") +
      "</label>" +
      '<textarea class="a-args textarea mono" id="a-args-' + esc(callId) + '" spellcheck="false">' + esc(argsJson) + "</textarea>" +
      '<div class="a-argerr" style="display:none"></div>' +
    "</div>" +
    '<label class="check a-always"><input type="checkbox" class="a-always-cb">Always allow ' + esc(name) + " without asking</label>" +
    '<div class="actions"><button type="button" class="btn sm a-deny">Deny</button><button type="button" class="btn primary sm a-allow">Allow</button></div>';
  const textarea = wrap.querySelector<HTMLTextAreaElement>(".a-args")!;
  const error = wrap.querySelector<HTMLElement>(".a-argerr")!;
  const always = wrap.querySelector<HTMLInputElement>(".a-always-cb")!;
  const resolve = (decision: "allow" | "deny") => {
    let editedArgs: Record<string, unknown> | undefined;
    if (decision === "allow") {
      const raw = textarea.value.trim();
      if (raw && raw !== argsJson.trim()) {
        try {
          const parsed = JSON.parse(raw);
          if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) editedArgs = parsed as Record<string, unknown>;
          else { error.textContent = "The edited arguments are not a JSON object, so the original ones were sent."; error.style.display = ""; }
        } catch {
          error.textContent = "The edited arguments are not valid JSON, so the original ones were sent.";
          error.style.display = "";
        }
      }
    }
    send({ type: "approval", callId, decision, editedArgs, alwaysAllow: decision === "allow" && always.checked });
    wrap.querySelector(".actions")!.remove();
    wrap.querySelector(".a-always")?.remove();
    textarea.readOnly = true;
    const resolved = el("div", "resolved " + decision, wrap);
    resolved.innerHTML = (decision === "allow" ? ICON.check : ICON.deny) + "<span></span>";
    resolved.querySelector("span")!.textContent = decision === "allow" ? (editedArgs ? "Allowed with your edits" : "Allowed") : "Denied";
  };
  wrap.querySelector<HTMLButtonElement>(".a-allow")!.onclick = () => resolve("allow");
  wrap.querySelector<HTMLButtonElement>(".a-deny")!.onclick = () => resolve("deny");
  turn.scroller.stick(true);
}

/** Expands the Sources panel and links the `[n]` markers the reply actually used (only numbers this turn cited). */
function attachSources(turn: AssistantTurn): void {
  turn.textNode.innerHTML = linkifyCitations(turn.textNode.innerHTML, new Set(turn.citations.map((c) => c.n)));
  const holder = el("div", "", null);
  holder.innerHTML = renderSourcesHtml(turn.citations);
  const details = holder.firstElementChild as HTMLDetailsElement | null;
  if (!details) return;
  turn.bubble.appendChild(details);
  turn.textNode.querySelectorAll<HTMLElement>(".cite-mark").forEach((mark) => {
    mark.addEventListener("click", () => {
      details.open = true;
      const row = details.querySelector<HTMLElement>('.src-row[data-cite-row="' + mark.dataset.cite + '"]');
      if (!row) return;
      row.scrollIntoView({ block: "nearest", behavior: "smooth" });
      row.classList.add("pulse");
      setTimeout(() => row.classList.remove("pulse"), 1000);
    });
  });
}

/** The ground-truth pass: one full `mdToHtml` of the whole text replaces the incremental render, so the settled DOM
 * equals a one-shot render (and replayed history), with any Canvas Preview the reader opened mid-stream kept. */
export function settleTurn(turn: AssistantTurn): void {
  if (turn.settled) return;
  turn.settled = true;
  const previewIdx = captureCanvasViewStates(turn.textNode);
  turn.textNode.innerHTML = mdToHtml(turn.text);
  restoreCanvasViewStates(turn.textNode, previewIdx);
  highlightIn(turn.textNode);
  turn.thinkBody.textContent = turn.thinking;
  turn.thinkBox.classList.remove("live");
  if (turn.citations.length) attachSources(turn);
}

/** The settled reply's meta line: decode rate, tokens and time to first token. */
export function finishMeta(turn: AssistantTurn): void {
  const secs = (performance.now() - (turn.tFirst || turn.t0)) / 1000;
  if (turn.tokens > 1 && secs > 0) turn.meta.textContent = `${rate(turn.tokens / secs)} · ${turn.tokens} tokens · first token ${ms(turn.tFirst - turn.t0)}`;
}

/** Ends the turn whatever ended it (its end, Stop, an error, a dropped connection). The reply settles, an empty one is
 * removed, and the composer is usable again even if settling fails. `note` is shown in the meta line (why the reply is
 * partial). Returns whether the reply stayed in the thread. */
export function endTurn(turn: AssistantTurn | null, note?: string): boolean {
  let kept = false;
  try {
    if (turn) {
      settleTurn(turn);
      kept = !!(turn.text || turn.thinking || turn.tools.size || turn.bubble.querySelector(".approval"));
      if (!kept) turn.m.remove();
      else if (note) { const span = el("span", "meta-note", turn.meta); span.textContent = (turn.meta.textContent ? " · " : "") + note; }
    }
  } finally {
    turn?.cursor.remove();
    setStreaming(false);
    renderQueue({});
  }
  return kept;
}

/** An error from the agent, as its own message in the thread, saying what to do next. */
export function showAgentError(thread: HTMLElement, message: string, scroller: Scroller): void {
  const { bubble } = assistantShell(thread);
  bubble.classList.add("agent-error");
  bubble.innerHTML = '<div class="notice bad"><span class="ai">' + ICON.warning + '</span><div><b>The agent stopped with an error.</b> <span class="err-text"></span>' +
    '<div class="err-hint">Send your message again, or start a new chat if it keeps failing.</div></div></div>';
  bubble.querySelector(".err-text")!.textContent = message || "Unknown error.";
  scroller.stick(true);
}
