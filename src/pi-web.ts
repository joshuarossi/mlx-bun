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

import { mkdirSync, rmSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import type { ServerWebSocket, WebSocketHandler } from "bun";
import {
  createAgentSession,
  DefaultResourceLoader,
  SessionManager,
  type AgentSession,
  type AgentSessionEvent,
  type ExtensionAPI,
  type SessionEntry,
  type SessionInfo,
  type ToolCallEvent,
} from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import { createWebTools, WEB_TOOL_NAMES } from "./web-tools";
import { materializeBundledSkills } from "./web/skills";
import { buildPiProvider, DEFAULT_CONTEXT_WINDOW, PI_LOCAL_MODEL_ID } from "./pi-provider";

/**
 * Full toolset the web agent is offered. The built-in coding tools plus our
 * outward-facing web tools (web_search/web_fetch/weather). NOTE: pi treats
 * this list as an allowlist (createAgentSession `tools`), so a custom tool's
 * name MUST appear here or it gets filtered out before the model ever sees it.
 */
const ALL_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls", ...WEB_TOOL_NAMES];
/**
 * Tools that never mutate the user's machine; auto-allowed without a browser
 * round-trip. The web tools make outbound network requests but change nothing
 * locally, so they're auto-allowed too (and remain usable in read-only mode).
 */
const READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls", ...WEB_TOOL_NAMES]);
/** Tools that require explicit per-call browser approval. */
const GATED_TOOLS = new Set(["bash", "edit", "write"]);

/** Auto-deny a pending approval after this long with no browser decision. */
const APPROVAL_TIMEOUT_MS = 120_000;

/**
 * System prompt for the web chat assistant.
 *
 * This fully REPLACES pi's default coding-agent prompt (it flows to
 * buildSystemPrompt's `customPrompt` via DefaultResourceLoader.systemPrompt).
 * Replacing rather than appending drops two things we don't want in an
 * end-user chat: the "operating inside pi, a coding agent harness" framing
 * and pi's block of internal documentation paths. pi still auto-appends the
 * current date and working directory, so we don't repeat them here.
 *
 * Goal: a helpful, eager assistant that actually uses its tools instead of
 * talking about them. The capability list is kept honest per `readOnly` so
 * the model never promises an action the approval gate will refuse.
 */
export function buildWebChatSystemPrompt(readOnly: boolean): string {
  const capabilities = readOnly
    ? `You have these tools (all used freely, no confirmation needed):
- web_search — search the web for current, real-world information
- web_fetch — fetch a URL and read the page or data behind it
- weather — get current conditions and a short forecast for any place
- read — open and read any file
- ls, find, grep — list directories and search the filesystem by name or content

This is a read-only session: you can look things up and inspect files, but cannot run commands or change anything on disk.`
    : `You have a real toolset — use it.

Used freely, no confirmation needed:
- web_search — search the web for current, real-world information (news, prices, docs, anything that changes or that you don't already know)
- web_fetch — fetch a URL and read the page or data behind it (great as a follow-up to web_search, or when the user gives you a link)
- weather — get current conditions and a short forecast for any place
- read, ls, find, grep — open files and search the filesystem

Asks the user for approval first (they stay in control):
- bash — run shell commands
- edit, write — modify existing files or create new ones

Prefer doing the work over describing it — run the search, fetch the page, propose the concrete command or edit and let the user approve it.`;

  return `You are a helpful, capable AI assistant. The model answering runs entirely on the user's own machine via mlx-bun, so the conversation stays local and private. You also have tools that reach the internet (web search, fetching pages, weather) — use them whenever the user needs current or real-world information.

Be an eager, proactive partner. When a request can be answered or a task moved forward by using your tools, use them right away instead of guessing or asking the user to do it for you. Take initiative: investigate, gather what you need, and follow through to a real result.

${capabilities}

When you don't know something — especially anything current, factual, or time-sensitive — look it up with web_search and web_fetch rather than speculating or relying on stale memory. If a request is genuinely ambiguous, ask one brief clarifying question; otherwise make a sensible choice and proceed. Be honest about what you did and what you found — including mistakes, dead ends, and things you couldn't do.

Keep your responses clear and to the point. Format with Markdown, cite links when you used the web, and show file paths and commands plainly so they're easy to read.`;
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
  | { type: "steer"; text: string; images?: ImageAttachment[] }
  | { type: "abort" }
  | { type: "approval"; callId: string; decision: ApprovalDecision }
  // Session management (recent-chats sidebar + new chat).
  | { type: "new_session" }
  | { type: "list_sessions" }
  | { type: "open_session"; path: string }
  | { type: "fork_session"; path: string }
  | { type: "delete_session"; path: string };

/** Server -> client frames. */
type ServerMessage =
  // `vision`: whether the loaded model can accept images (drives the UI's
  // image-attach affordance — false on e4b until the SigLIP sidecar lands).
  | { type: "ready"; model: string; vision: boolean }
  | { type: "turn_start" }
  | { type: "text_delta"; delta: string }
  | { type: "tool_start"; callId: string; tool: string; args: unknown }
  | { type: "tool_approval_request"; callId: string; tool: string; args: unknown }
  | { type: "tool_update"; callId: string; chunk: unknown }
  | { type: "tool_end"; callId: string; ok: boolean; result: unknown }
  | { type: "turn_end" }
  | { type: "queue_update"; steering: readonly string[]; followUp: readonly string[] }
  // Replay a session's transcript (rebuilds the thread); and the sidebar list.
  | { type: "history"; items: HistoryItem[] }
  | { type: "sessions"; items: SessionListItem[]; activePath?: string }
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
  tools: HistoryToolItem[];
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
      if (text.trim()) items.push({ role: "user", text, tools: [] });
    } else if (m.role === "assistant") {
      const parts = Array.isArray(m.content) ? (m.content as unknown[]) : [];
      const text = contentText(parts);
      const tools: HistoryToolItem[] = parts
        .filter((p): p is { type: string; id?: unknown; name?: unknown; arguments?: unknown } =>
          !!p && (p as { type?: string }).type === "toolCall")
        .map((p) => ({ callId: String(p.id ?? ""), name: String(p.name ?? "tool"), args: p.arguments, result: "" }));
      if (text.trim() || tools.length > 0) items.push({ role: "assistant", text, tools });
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
    case "turn_end":
      return [{ type: "turn_end" }];
    case "message_update": {
      const ame = event.assistantMessageEvent;
      if (ame.type === "text_delta" || ame.type === "thinking_delta") {
        // Stream both ordinary text and thinking as text_delta; the
        // browser renders a single growing assistant bubble.
        return [{ type: "text_delta", delta: ame.delta }];
      }
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

/**
 * One browser connection's pi agent. Owns the AgentSession, the event
 * subscription, and the pending tool-approval handshakes.
 */
class PiWebSession {
  private session?: AgentSession;
  /** SessionManager backing the active AgentSession (disk-persisted). */
  private sessionManager?: SessionManager;
  private unsubscribe?: () => void;
  private disposed = false;

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
    private readonly opts: { port: number | (() => number); modelId: string; contextWindow: number; readOnly: boolean; vision: boolean },
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
    this.provider = buildPiProvider(baseUrl, { contextWindow: this.opts.contextWindow });
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
    await this.activate(SessionManager.create(this.cwd, this.sessionDir));
    if (this.disposed) return;

    this.send({ type: "ready", model: this.opts.modelId, vision: this.opts.vision });
    this.sendHistory();
    await this.sendSessions();
  }

  /** Build a fresh AgentSession bound to `sm`. A new resource loader per
   *  build keeps the approval-gate extension cleanly scoped to this session. */
  private async buildAgentSession(sm: SessionManager): Promise<AgentSession> {
    const provider = this.provider;
    if (!provider) throw new Error("provider not initialized");

    // Inline extension carries the pre-execution approval gate. Registered
    // via DefaultResourceLoader.extensionFactories so it loads in-process
    // with no file on disk and no global ~/.pi extension discovery.
    const resourceLoader = new DefaultResourceLoader({
      cwd: this.cwd,
      agentDir: this.agentDir,
      // Skip user/project resource discovery: the web agent is fully
      // self-contained and must not inherit the user's pi extensions or
      // context files. noContextFiles also keeps a stray CLAUDE.md /
      // AGENTS.md in the launch directory out of the chat.
      noExtensions: true,
      noSkills: true,
      noPromptTemplates: true,
      noThemes: true,
      noContextFiles: true,
      // Our curated skills only (not the user's). materializeBundledSkills is
      // memoized, so calling it per build just returns the path. See web/skills.ts.
      additionalSkillPaths: [materializeBundledSkills()],
      // Replace pi's default coding-agent prompt with our own helpful,
      // eager-assistant persona (see buildWebChatSystemPrompt).
      systemPrompt: buildWebChatSystemPrompt(this.opts.readOnly),
      extensionFactories: [(pi) => this.installApprovalGate(pi)],
    });
    await resourceLoader.reload();

    const { session } = await createAgentSession({
      cwd: this.cwd,
      agentDir: this.agentDir,
      model: provider.model,
      modelRegistry: provider.modelRegistry,
      authStorage: provider.authStorage,
      resourceLoader,
      tools: ALL_TOOLS,
      customTools: createWebTools(),
      sessionManager: sm,
    });
    return session;
  }

  /** Tear down the active session (keeps the socket + provider invariants). */
  private teardownActive(): void {
    for (const settle of this.pendingApprovals.values()) settle("deny");
    this.pendingApprovals.clear();
    for (const timer of this.approvalTimers.values()) clearTimeout(timer);
    this.approvalTimers.clear();
    this.unsubscribe?.();
    this.unsubscribe = undefined;
    try {
      this.session?.dispose();
    } catch {
      // Never let a dispose error escape teardown.
    }
    this.session = undefined;
    this.sessionManager = undefined;
  }

  /** Swap the active session to `sm`: abort any current turn, build the new
   *  session, then dispose the old and subscribe the new. Build-before-tear
   *  so a build failure leaves the current session intact. */
  private async activate(sm: SessionManager): Promise<void> {
    try {
      await this.session?.abort();
    } catch {
      // Old turn may already be done; ignore.
    }
    const session = await this.buildAgentSession(sm);
    if (this.disposed) {
      session.dispose();
      return;
    }
    this.teardownActive();
    this.session = session;
    this.sessionManager = sm;
    this.unsubscribe = session.subscribe((event) => this.onSessionEvent(event));
    this.sendContextUsage();
  }

  /** Replay the active session's transcript to the browser (rebuilds thread). */
  private sendHistory(): void {
    const entries = this.sessionManager?.getEntries() ?? [];
    this.send({ type: "history", items: serializeHistory(entries) });
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
    await this.activate(SessionManager.create(this.cwd, this.sessionDir));
    this.sendHistory();
    await this.sendSessions();
  }

  /** Resume an existing chat by file path. */
  private async openSession(path: string): Promise<void> {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    await this.activate(SessionManager.open(path, this.sessionDir));
    this.sendHistory();
    await this.sendSessions();
  }

  /** Branch a new chat from an existing one (original stays untouched). */
  private async forkSession(path: string): Promise<void> {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    await this.activate(SessionManager.forkFrom(path, this.cwd, this.sessionDir));
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

  /** Register the tool_call approval gate on the inline extension. */
  private installApprovalGate(pi: ExtensionAPI): void {
    pi.on("tool_call", async (event: ToolCallEvent) => {
      const tool = event.toolName;

      // Read-only tools never need approval.
      if (READ_ONLY_TOOLS.has(tool)) return undefined;

      // Anything mutating is denied outright in read-only mode.
      if (this.opts.readOnly && GATED_TOOLS.has(tool)) {
        return { block: true, reason: "Read-only session: mutating tools are disabled." };
      }

      // Non-gated, non-read-only tools (shouldn't happen with ALL_TOOLS,
      // but be safe): allow.
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
      // Both a new prompt and an explicit steer go through session.prompt() so
      // that pi's own *atomic* isStreaming check (agent-session prompt(): it
      // re-checks at call time) decides how to route — never our own external
      // read, which can be stale in the instant a turn ends. That stale read
      // was the bug: a message arriving right as a turn finished was sent with
      // streamingBehavior "steer", injected into the already-ending turn, and
      // nothing consumed it (a hang). With this routing, an idle session always
      // runs a normal turn (streamingBehavior is ignored when not streaming),
      // so a message can't be lost at the turn boundary.
      case "prompt":
        // New user message → its own turn. "followUp" = if a turn is still
        // streaming, queue this as the NEXT turn; if idle, a normal prompt.
        await session.prompt(msg.text, { streamingBehavior: "followUp", images: toPiImages(msg.images) });
        return;
      case "steer":
        // Mid-turn steer (user typed while it streamed). "steer" injects into
        // the live turn; if that turn just ended (same race), pi falls back to
        // a normal prompt instead of dropping the message.
        await session.prompt(msg.text, { streamingBehavior: "steer", images: toPiImages(msg.images) });
        return;
      case "abort":
        await session.abort();
        return;
      case "approval":
        this.resolveApproval(msg.callId, msg.decision);
        return;
    }
  }

  /** Tear down the session and reject any in-flight approvals. */
  dispose(): void {
    this.disposed = true;
    this.teardownActive();
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
 */
export function makePiWsHandler(opts: {
  port: number | (() => number);
  modelId?: string;
  contextWindow?: number;
  readOnly?: boolean;
  /** Whether the loaded model can accept images (server's ctx.vision != null). */
  vision?: boolean;
}): WebSocketHandler<PiWsData> {
  const resolved = {
    port: opts.port,
    modelId: opts.modelId ?? PI_LOCAL_MODEL_ID,
    contextWindow: opts.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
    readOnly: opts.readOnly ?? false,
    vision: opts.vision ?? false,
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
