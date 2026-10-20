// The chat controller. It owns the per-turn state (the streaming reply, the last user message and reply that carry
// Edit and Regenerate, the sibling branches, the citations a prompt's excerpts carry to its reply), dispatches the
// server's frames to the parts that draw them, and wires the controls. It draws nothing itself and touches the
// backend only through the socket session (`session.ts`) and the API client it is handed:
//   session.ts      the socket: connect, status, reconnect, resume the open chat
//   turn.ts         the streaming reply, its tool cards, approval card, Sources panel and meta line
//   history.ts      the replayed thread and the message actions
//   sessions.ts     the recent-chats sidebar, search and export
//   composer/       the message box, attachments, `#` picker, popovers, adapter select, status and perf line
//   app-context.ts  the app-aware assistant's context pushes, navigation and spotlight
import { $, createDisposer, errorOf, listen, type Api } from "@mlx-bun/web-kit";
import type { ClientMessage, HistoryItem, ServerMessage } from "../protocol";
import { AdaptersPanelState, initAdaptersPanel } from "./adapters-panel";
import { createAppContext, type AppContext } from "./app-context";
import {
  ComposerState, buildMessageText, clearAttachments, clearOneShotArmed, initAttachments, initMentionPicker, initSampling,
  initSystemPrompt, onSelectAdapter, refreshAdapters, refreshSamplingRecs, renderContext, renderQueue, setStreaming,
  showStopping, updateAttachHint, updateThinkingToggle, type Attachment,
} from "./composer";
import {
  addMsgActions, addUserMessage, dropRegenerate, newSiblingInfo, renderHistory, renderSiblingToggle, startEdit,
  switchSiblingTarget, type SiblingInfo,
} from "./history";
import { toast, type ChatHost } from "./host";
import { wireCanvasToggle } from "./markdown";
import type { Citation } from "./rag";
import { createChatSession, statusCopy, type SocketStatus } from "./session";
import { createSidebar, type Sidebar } from "./sessions";
import { helloNoteText, helloSubHtml, type ServedModel } from "./template";
import {
  appendText, appendThinking, createScroller, endTool, endTurn, finishMeta, showAgentError, showApproval, startTool,
  startTurn, updateTool, type AssistantTurn,
} from "./turn";
import { initVoiceInput } from "./voice";

/** What the controller needs from its element and host. */
export interface ChatPort {
  readonly host: ChatHost | undefined;
  /** The panel element the markup lives in. */
  readonly element: HTMLElement;
  /** The JSON client over the module's connection; the routes it reads are root paths on that origin. */
  readonly api: Api;
  /** The chat page is the one showing (a dropped connection reconnects only then). */
  isActive(): boolean;
  /** Closes the narrow-screen recent-chats drawer. */
  closeDrawer(): void;
}

export interface ChatController {
  /** Wires the controls once the markup exists. */
  init(): void;
  /** The chat page is shown: connect if the socket is down, focus the composer, refresh the adapters. */
  enter(): void;
  /** The chat page is hidden: the socket stays open (closing it would drop a turn in flight). */
  leave(): void;
  /** The panel left the document: close the socket and drop every page-level listener. */
  dispose(): void;
  newChat(): void;
  copyLastResponse(): void;
  setCodingTools(enabled: boolean): void;
  refreshAdapters(): void;
  recentChats(): { title: string; path: string }[];
  openSession(path: string): boolean;
  exportActiveChat(format: "md" | "json"): Promise<void>;
}

const NOT_CONNECTED = "Not connected to the model server yet. Reconnecting…";

export function createChatController(port: ChatPort): ChatController {
  const disposer = createDisposer();
  const composer = new ComposerState();
  const adapters = new AdaptersPanelState();
  const scroller = createScroller(() => $("chat-scroll"));
  const thread = () => $("chat-thread");

  // The streaming reply, if any, and whether a turn is in flight (a model change waits for none).
  let turn: AssistantTurn | null = null;
  let turnActive = false;
  // Excerpts retrieved for the prompt in flight, handed to its reply when `turn_start` arrives.
  let pendingCitations: Citation[] = [];
  // The last user message (Edit, the sibling toggle) and reply (Regenerate, its citations for a re-run).
  let lastUser: { el: HTMLElement; entryId: string | null } | null = null;
  let siblings: SiblingInfo = newSiblingInfo();
  let lastAssistant: HTMLElement | null = null;
  let lastAssistantCitations: Citation[] = [];
  let served: ServedModel | null = null;
  let sidebar: Sidebar | undefined;
  let appContext: AppContext | undefined;

  const session = createChatSession({
    onFrame: handle,
    onStatus: showStatus,
    isActive: () => port.isActive(),
    busy: () => turnActive,
  });
  disposer.add(() => session.close());
  const send = (frame: ClientMessage): boolean => session.send(frame);

  function showStatus(status: SocketStatus): void {
    const copy = statusCopy(status);
    const line = $("chat-status-line"), dot = $("chat-conn-dot");
    if (line) line.textContent = copy.text;
    if (dot) dot.className = "dot" + (copy.tone ? " " + copy.tone : "");
    // The server session behind a dropped socket is gone: settle what streamed so far and free the composer. The
    // next connection reopens the chat, and its history shows what the server kept.
    if (status !== "closed") return;
    if (turnActive) finishTurn("The connection dropped before the reply finished.");
    pendingCitations = []; // a prompt the server never started must not lend its excerpts to the next one
  }

  function showServed(next: ServedModel): void {
    served = next;
    const sub = $("chat-hello-sub"), note = $("chat-hello-note");
    if (sub) sub.innerHTML = helloSubHtml(next);
    const text = helloNoteText(next);
    if (note) { note.hidden = !text; note.textContent = text ?? ""; }
  }

  function hideHello(): void { $("chat-hello").style.display = "none"; }

  /* ── the turn ── */

  function beginTurn(): AssistantTurn {
    hideHello();
    turnActive = true;
    setStreaming(true);
    turn = startTurn(thread(), pendingCitations, scroller);
    pendingCitations = []; // a later prompt without excerpts must not inherit these
    return turn;
  }
  const currentTurn = (): AssistantTurn => turn ?? beginTurn();

  /** Ends the turn (its end, an error, a dropped connection); a reply that stayed becomes the one Regenerate re-runs. */
  function finishTurn(note?: string): void {
    const ending = turn;
    turn = null;
    turnActive = false;
    if (ending) finishMeta(ending);
    if (!endTurn(ending, note) || !ending) return;
    // A partial reply (stopped, failed, cut off) still gets its actions: the server regenerates from the last user
    // message whether or not the reply finished.
    dropRegenerate(lastAssistant);
    addMsgActions(ending.m, ending.text, { regenerate: true }, { onRegenerate: regenerate });
    lastAssistant = ending.m;
    lastAssistantCitations = ending.citations;
  }

  /* ── message actions ── */

  function regenerate(): void {
    if (turnActive) return;
    if (!send({ type: "regenerate" })) { toast(NOT_CONNECTED, "err"); return; }
    // The server re-prompts on a new branch without a `history` frame: the old reply goes now, and the new one keeps
    // the old one's Sources.
    lastAssistant?.remove();
    lastAssistant = null;
    pendingCitations = lastAssistantCitations;
  }

  function editLast(m: HTMLElement): void {
    if (turnActive) return;
    startEdit(m, (text) => {
      if (!send({ type: "edit_resend", text })) { toast(NOT_CONNECTED, "err"); return false; }
      lastAssistant?.remove();
      lastAssistant = null;
      pendingCitations = lastAssistantCitations;
      return true;
    });
  }

  function switchSibling(delta: number): void {
    const target = switchSiblingTarget(siblings, delta);
    if (target) send({ type: "switch_sibling", entryId: target });
  }

  /** The user's message as sent: the newest one carries Edit and the branch toggle, so the previous one drops them. */
  function showUserMessage(text: string, attachments: readonly Attachment[]): void {
    hideHello();
    if (lastUser) {
      lastUser.el.querySelector('.msg-actions .maction[data-action="edit"]')?.remove();
      lastUser.el.querySelector(".sib-toggle")?.remove();
    }
    const m = addUserMessage(thread(), text, attachments);
    // Its entry id is assigned server-side; the `siblings` frame after the turn fills it in.
    lastUser = { el: m, entryId: null };
    addMsgActions(m, text, { edit: true }, { onEdit: editLast });
    renderSiblingToggle(m, null, siblings, switchSibling);
    scroller.stick(true);
  }

  /** The authoritative rebuild from a `history` frame: whatever was streaming is over. */
  function showHistory(items: readonly HistoryItem[]): void {
    turn = null;
    turnActive = false;
    setStreaming(false);
    renderQueue({});
    thread().innerHTML = "";
    lastUser = null;
    lastAssistant = null;
    lastAssistantCitations = []; // history does not carry citations, so a regenerate cannot attribute any
    $("chat-hello").style.display = items.length ? "none" : "";
    if (!items.length) return;
    const ends = renderHistory(thread(), items, port.host, siblings, { onRegenerate: regenerate, onEdit: editLast, onSwitchSibling: switchSibling });
    lastUser = ends.lastUser;
    lastAssistant = ends.lastAssistant;
    scroller.stick(true);
  }

  /* ── the server's frames ── */

  function onReady(frame: Extract<ServerMessage, { type: "ready" }>): void {
    showServed({ model: frame.model || served?.model || null, online: true, download: served?.download ?? null });
    composer.visionCapable = !!frame.vision;
    composer.transcriptionCapable = !!frame.transcription;
    updateAttachHint(composer);
    composer.thinkingCapable = !!frame.thinking;
    updateThinkingToggle(composer);
    // The model's recommended sampling (its generation config with the server's overrides applied).
    composer.genDefaults = frame.genDefaults || { temperature: null, topP: null, topK: null };
    refreshSamplingRecs(composer);
    if (composer.thinkingCapable) send({ type: "set_thinking", enabled: composer.thinkingOn });
    void refreshAdapters(port.api);
    // Every connection starts a fresh server session with file-changing tools off, so this browser's wish is
    // re-asserted on every `ready`; the `coding_tools` reply says whether it applies now or from the next chat.
    send({ type: "set_coding_tools", enabled: port.host?.settings?.codingToolsPreference() ?? false });
    // A fresh session also starts without the page's context.
    appContext?.push();
  }

  function handle(frame: ServerMessage): void {
    switch (frame.type) {
      case "ready": onReady(frame); break;
      case "coding_tools": port.host?.settings?.codingTools(frame.active, frame.pending); break;
      case "tool_approvals": port.host?.settings?.approvals(frame.alwaysAllow, (tool) => { void forgetToolApproval(tool); }); break;
      case "history": showHistory(frame.items); break;
      case "sessions": sidebar?.render(frame.items, frame.activePath); break;
      case "context": renderContext(frame); break;
      case "siblings":
        siblings = { entryId: frame.entryId || null, index: frame.index, count: frame.count, siblingIds: frame.siblingIds || [] };
        if (lastUser) {
          lastUser.entryId = siblings.entryId;
          renderSiblingToggle(lastUser.el, lastUser.entryId, siblings, switchSibling);
        }
        break;
      case "turn_start": beginTurn(); break;
      case "text_delta": appendText(currentTurn(), frame.delta || ""); break;
      case "thinking_delta": appendThinking(currentTurn(), frame.delta || ""); break;
      case "tool_start": startTool(currentTurn(), frame.callId, frame.tool, frame.args, port.host); break;
      case "tool_approval_request": showApproval(currentTurn(), frame.callId, frame.tool, frame.args, send); break;
      case "tool_update": if (turn) updateTool(turn, frame.callId, (frame.chunk as string) || ""); break;
      case "tool_end": if (turn) endTool(turn, frame.callId, frame.ok, frame.result); break;
      // A next-message sampling override was used by exactly this turn.
      case "turn_end": clearOneShotArmed(composer); finishTurn(); break;
      case "queue_update": renderQueue(frame); break;
      // A prompt that fails before `turn_start` never gets a `turn_end`, so the one-shot override clears here too (the
      // server clears its own copy on the same path).
      case "error":
        showAgentError(thread(), frame.message || "", scroller);
        toast(frame.message || "The agent stopped with an error.", "err");
        clearOneShotArmed(composer);
        if (turnActive) finishTurn();
        break;
      case "ui_navigate":
      case "ui_spotlight": appContext?.handle(frame); break;
    }
  }

  /* ── the composer ── */

  function resizeBox(box: HTMLTextAreaElement): void {
    box.style.height = "auto";
    box.style.height = Math.min(box.scrollHeight, 200) + "px";
  }

  function submit(): void {
    const box = $("chat-box") as HTMLTextAreaElement;
    const text = box.value.trim();
    // Session control, never sent to the model.
    const command = text.toLowerCase();
    if (command === "/reload" || command === "/new" || command === "/clear") {
      box.value = ""; resizeBox(box); clearAttachments(composer); newChat();
      return;
    }
    if (!text && !composer.attachments.length) return;
    if (!session.connected) { toast(NOT_CONNECTED, "err"); return; }
    const images = composer.attachments.filter((a) => a.kind === "image").map((a) => ({ data: a.data as string, mimeType: a.mimeType as string }));
    const built = buildMessageText(composer, text);
    showUserMessage(text, composer.attachments);
    box.value = ""; resizeBox(box);
    pendingCitations = built.citations;
    // Sent while a reply streams, it becomes the next turn (the server queues it as a follow-up).
    send(images.length ? { type: "prompt", text: built.text, images } : { type: "prompt", text: built.text });
    clearAttachments(composer);
  }

  function newChat(): void {
    if (!send({ type: "new_session" })) { toast(NOT_CONNECTED, "err"); return; }
    $("chat-box").focus();
    port.closeDrawer(); // a fresh chat is the natural end of browsing on a narrow screen
  }

  /** Forgets an always-allow entry (a REST call: the list is a file, not session state) and redraws the list. */
  async function forgetToolApproval(tool: string): Promise<void> {
    const answer = await port.api.del<{ alwaysAllow?: string[] }>("/api/settings/tool-approvals", { tool });
    if (!answer.ok) { toast(`Could not forget “${tool}”: ${errorOf(answer)}.`, "err"); return; }
    port.host?.settings?.approvals(answer.alwaysAllow || [], (next) => { void forgetToolApproval(next); });
    toast(`Forgot “${tool}”. It will ask again next time.`, "ok");
  }

  function pulseChip(attachment: Attachment): void {
    const chip = document.querySelector<HTMLElement>('.attach-chip[data-att-id="' + attachment.id + '"]');
    if (!chip) return;
    chip.scrollIntoView({ block: "nearest", behavior: "smooth" });
    chip.classList.add("pulse");
    setTimeout(() => chip.classList.remove("pulse"), 1000);
  }

  /** Copy on a rendered code block (delegated: the thread re-renders on every token). */
  function copyCode(event: Event): void {
    const button = (event.target as HTMLElement).closest?.<HTMLElement>(".cbcopy");
    const code = button?.closest(".codeblock")?.querySelector("code");
    if (!button || !code || !navigator.clipboard) return;
    navigator.clipboard.writeText(code.textContent || "").then(() => {
      button.textContent = "Copied";
      setTimeout(() => { button.textContent = "Copy"; }, 1200);
    }).catch(() => {});
  }

  return {
    init() {
      const box = $("chat-box") as HTMLTextAreaElement;
      ($("chat-send") as HTMLButtonElement).onclick = submit;
      ($("chat-new") as HTMLButtonElement).onclick = newChat;
      ($("chat-stop") as HTMLButtonElement).onclick = () => { send({ type: "abort" }); showStopping(); };
      ($("chat-think") as HTMLButtonElement).onclick = () => {
        composer.thinkingOn = !composer.thinkingOn;
        updateThinkingToggle(composer);
        send({ type: "set_thinking", enabled: composer.thinkingOn });
      };
      const select = $("chat-adapter") as HTMLSelectElement;
      // The routing table and the quick select share one notion of what this chat has selected.
      select.onchange = () => { adapters.selectedSpec = select.value || null; adapters.stackPicks.clear(); void onSelectAdapter(select, send, port.api); };
      initAdaptersPanel(adapters, send, port.api);
      initSampling(composer, send, disposer);
      initSystemPrompt(composer, send, disposer);
      sidebar = createSidebar(port.api, {
        onOpen: (path) => { send({ type: "open_session", path }); port.closeDrawer(); },
        onFork: (path) => send({ type: "fork_session", path }),
        onDelete: (path) => send({ type: "delete_session", path }),
      }, disposer);
      $("chat-sess-search").addEventListener("input", () => sidebar?.applySearch());
      // The picker's keydown runs first and claims Enter, Tab, the arrows and Escape only while it is open.
      initMentionPicker(composer, box, port.api, { onFileSelected: pulseChip });
      box.addEventListener("keydown", (event) => {
        if ($("chat-mention-pop").classList.contains("open")) return;
        if (event.key === "Enter" && !event.shiftKey && !event.isComposing) { event.preventDefault(); submit(); }
      });
      box.addEventListener("input", () => resizeBox(box));
      // Delegated, so the chips memory inserts beside these work with no wiring of their own.
      $("chat-hello-chips").addEventListener("click", (event) => {
        const chip = (event.target as HTMLElement).closest<HTMLElement>(".chip");
        if (!chip) return;
        box.value = chip.dataset.q || "";
        submit();
      });
      initAttachments(composer, box);
      initVoiceInput($("chat-mic-btn") as HTMLButtonElement, box, port.api);
      thread().addEventListener("click", copyCode);
      wireCanvasToggle(thread());
      appContext = createAppContext(send, disposer);
      disposer.add(listen(window, "mlx-server-status", (event) => { const detail = (event as CustomEvent<ServedModel>).detail; if (detail) showServed(detail); }));
      void refreshAdapters(port.api);
      port.host?.mounted?.(port.element);
    },
    enter() {
      session.connect();
      $("chat-box").focus();
      // A training job that finished while the page was hidden, or an adapter dropped on disk, shows up at once.
      void refreshAdapters(port.api);
    },
    leave() { /* the socket stays open: closing it would drop a turn in flight */ },
    dispose() { disposer.dispose(); },
    newChat,
    copyLastResponse() {
      if (!lastAssistant) { toast("There is no reply to copy yet.", "err"); return; }
      lastAssistant.querySelector<HTMLButtonElement>('.msg-actions .maction[data-action="copy"]')?.click();
    },
    setCodingTools(enabled) { send({ type: "set_coding_tools", enabled }); },
    refreshAdapters() { void refreshAdapters(port.api); },
    recentChats: () => sidebar?.recentChats() ?? [],
    openSession: (path) => sidebar?.openByPath(path) ?? false,
    async exportActiveChat(format) {
      const row = document.querySelector<HTMLElement>("#chat-sessions .sess.active");
      if (row?.dataset.path) await sidebar?.exportChat(row.dataset.path, row.querySelector(".stitle")?.textContent || "chat", format);
    },
  };
}
