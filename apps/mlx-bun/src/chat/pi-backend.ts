import { defaultSessionDir } from "./session-files";
import { mkdirSync, rmSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { runtimeValue } from "@mlx-bun/inference/runtime/config";
import { createAgentSessionFromServices, createAgentSessionRuntime, createAgentSessionServices, SessionManager,
  type AgentSession, type AgentSessionEvent, type AgentSessionRuntime, type CreateAgentSessionRuntimeFactory,
  type ExtensionAPI, type SessionInfo, type ToolCallEvent } from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import type { ApprovalDecision, ClientMessage, AppUiContext, ReadyGenDefaults, ServerMessage, SamplingOverrides } from "./protocol";
import type { ChatBackend, ChatBackendFactory, SendFrame } from "./backend";
import { buildPiAgentSurface, type MemorySurface } from "./surface";
import { buildPiProvider, DEFAULT_CONTEXT_WINDOW, PI_LOCAL_MODEL_ID } from "./provider";
import { isToolAlwaysAllowed, setToolAlwaysAllowed, listAlwaysAllowedTools } from "./tool-approvals";
import { initialSamplingScopeState, initialLoopHygieneState, buildWebChatSystemPrompt, WELCOME_TOOLS,
  WEB_CHAT_PROMPT_VERSION, webChatPromptFingerprint, webChatToolAllowlist, consumeForRequest,
  injectAdapter, injectSampling, injectSystemPrompt, ambientContextLine, decideBeforeToolCall,
  recordToolCallOutcome, toolResultText, toolApprovalClass, applyEditedArgs,
  applySetSampling, type SamplingScopeState, type LoopHygieneState } from "./policy";
import { serializeHistory, findLastUserMessageEntry, userMessageSiblings, toSessionListItems,
  deepestLeafFrom, toPiImages } from "./history";
import { createAppAwareTools } from "./app-tools";
import { mapEventToFrames } from "./events";

const APPROVAL_TIMEOUT_MS = 120_000;

class PiBackend implements ChatBackend {
  private runtime?: AgentSessionRuntime;
  private session?: AgentSession;
  /** SessionManager backing the active AgentSession (disk-persisted). */
  private sessionManager?: SessionManager;
  private unsubscribe?: () => void;
  private disposed = false;
  private disposal?: Promise<void>;
  private readonly runtimeChanges = new Set<Promise<unknown>>();
  /** Active LoRA adapter id for this connection (null = none/base model).
   *  Read by the before_provider_request hook; set via the set_adapter msg. */
  private selectedAdapter: string | null = null;
  /** Session-level + one-shot-next-turn sampling overrides for this
   *  connection (set via set_sampling; scope "session"/omitted mutates
   *  .session, scope "next_turn" arms .nextTurn). Read and consumed by
   *  the before_provider_request hook via consumeForRequest — see the
   *  "Per-message sampling scope" block comment above composeSampling for
   *  the full lifecycle. Wrapped in SamplingScopeState (not two loose
   *  fields) so the exact same applySetSampling/consumeForRequest pure
   *  functions run here and in tests/chat-policy.test.ts. */
  private samplingScope: SamplingScopeState = initialSamplingScopeState();
  /** User's custom system-prompt text for this connection (set via
   *  set_system_prompt), null = none. Read by the before_agent_start hook
   *  and layered onto the built-in surface prompt on the NEXT turn — see
   *  installSystemPromptHook/injectSystemPrompt. */
  private systemPrompt: string | null = null;
  /** Requested codingTools state (set via set_coding_tools), read fresh by
   *  createRuntimeFactory every time the SDK invokes it. Starts false — the
   *  toggle in settings defaults OFF, and a connection that never sends
   *  set_coding_tools must never get bash/edit/write. */
  private codingToolsRequested = false;
  /** What the CURRENT (already-built) session's tool surface actually
   *  contains — set only inside createRuntimeFactory, so it always reflects
   *  reality rather than the latest request. Read by the `coding_tools`
   *  ServerMessage and by installApprovalGate (whether GATED_TOOLS is even
   *  reachable this session, informational only — the allowlist itself is
   *  the real enforcement). */
  private codingToolsActive = false;

  /** Last `context` ClientMessage the browser pushed (route/view/step/
   *  snapshot, plan §6.6) — null before the first one arrives (a non-
   *  browser WS client, or the race before chat.ts's first push). Read by
   *  get_current_app_context's tool and by installAppContextHook's
   *  ambient-line injection. Set wholesale (not merged) on every "context"
   *  ClientMessage — the browser always sends the full current picture. */
  private currentAppContext: AppUiContext | null = null;

  /** Dedup/retry-budget/turn-cap bookkeeping (see LOOP_HYGIENE above).
   *  Reset at the start of every new agent turn (turn_start with
   *  turnIndex 0) so a dedup hit or failure streak from a PREVIOUS user
   *  message never bleeds into the next one. */
  private loopHygiene: LoopHygieneState = initialLoopHygieneState();

  /** Per-connection invariants, built once in start() and reused across
   *  session switches (new chat / resume / fork). */
  private provider?: ReturnType<typeof buildPiProvider>;
  private readonly cwd: string;
  private readonly agentDir: string;
  /** Where web-chat session files live (pi's own JSONL format). Shared by
   *  create/continueRecent/open/fork/list/delete so they all see one set.
   *  This is the durable transcript store the nightly memory pipeline reads. */
  private readonly sessionDir: string;

  /** callId -> resolve(decision). Pending browser approvals in flight. */
  private readonly pendingApprovals = new Map<string, (decision: ApprovalDecision, editedArgs?: Record<string, unknown>, alwaysAllow?: boolean) => void>();
  /** callId -> timer handle, so we can clear on resolve/dispose. */
  private readonly approvalTimers = new Map<string, ReturnType<typeof setTimeout>>();

  constructor(
    private readonly emit: SendFrame,
    private readonly opts: {
      paths: Required<Pick<PiBackendPaths, "cwd" | "agentDir" | "sessionDir">> & PiBackendPaths;
      port: number | (() => number); modelId: string; contextWindow: number; readOnly: boolean;
      vision: boolean; audio: boolean; thinking: boolean; genDefaults: ReadyGenDefaults;
      transcription: () => Promise<boolean>;
      memory?: () => Promise<MemorySurface | undefined>;
      downloadsSnapshot?: () => readonly { state: string; repoId: string }[];
    },
  ) {
    this.cwd = opts.paths.cwd;
    this.agentDir = opts.paths.agentDir;
    this.sessionDir = opts.paths.sessionDir;
  }

  /** Build the provider, resume the most recent chat, and start streaming. */
  async start(): Promise<void> {
    if (this.disposed) return;
    // Resolve the port lazily: the WS handler is constructed before
    // Bun.serve() binds, so an ephemeral (0) port is only known at the
    // first connection. createServer passes `() => server.port`.
    const port = typeof this.opts.port === "function" ? this.opts.port() : this.opts.port;
    const baseUrl = `http://127.0.0.1:${port}/v1`;

    // In-memory provider wiring is reused across this connection's session swaps.
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

    let transcription = false;
    try { transcription = await this.opts.transcription(); } catch { /* no whisper → no mic button */ }
    this.send({
      type: "ready", model: this.opts.modelId, vision: this.opts.vision, audio: this.opts.audio,
      thinking: this.opts.thinking, genDefaults: this.opts.genDefaults, transcription,
    });
    this.sendCodingToolsState();
    this.sendToolApprovals();
    this.sendHistory();
    await this.sendSessions();
  }

  /** Runtime factory used for initial session creation and SDK-managed replacements. */
  private createRuntimeFactory(): CreateAgentSessionRuntimeFactory {
    return async ({ cwd, sessionManager, sessionStartEvent }) => {
      const provider = this.provider;
      if (!provider) throw new Error("provider not initialized");

      // Definitions come from this domain and the optional memory owner.
      // The allowlist below controls which definitions the session can invoke.
      const surface = await buildPiAgentSurface(await this.opts.memory?.());
      // Snapshot what THIS session is actually being built with — read fresh
      // here (not at set_coding_tools time) so `coding_tools`'s `active`
      // field is always true reality, never a stale request.
      this.codingToolsActive = this.codingToolsRequested;
      const webPrompt = buildWebChatSystemPrompt(this.opts.readOnly, {
        modelId: this.opts.modelId,
        downloadingModel: (this.opts.downloadsSnapshot?.() ?? []).find(
          (d) => d.state === "active" && d.repoId !== this.opts.modelId,
        )?.repoId ?? null,
      }, { hasTools: WELCOME_TOOLS.length > 0 }) + surface.memoryHint;
      if (runtimeValue("MLX_BUN_PI_DEBUG")) {
        console.error(`[pi-web] prompt ${WEB_CHAT_PROMPT_VERSION} sha=${webChatPromptFingerprint(webPrompt)} memory=${surface.memoryEnabled ? "on" : "off"} codingTools=${this.codingToolsActive ? "on" : "off"}`);
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
            // Loop hygiene runs FIRST: a deduped/turn-capped call is
            // blocked before the approval gate ever sees it (see
            // installLoopHygieneHooks's doc comment).
            (pi) => this.installLoopHygieneHooks(pi),
            (pi) => this.installApprovalGate(pi, new Set(surface.readOnlyToolNames)),
            (pi) => this.installAdapterHook(pi),
            (pi) => this.installSystemPromptHook(pi),
            (pi) => this.installAppContextHook(pi),
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
          // must be callable (webChatToolAllowlist). codingTools is further
          // ANDed with !readOnly here: a read-only server (--read-only) never
          // advertises bash/edit/write even if the browser opted in, since
          // installApprovalGate would deny every one of them anyway — no
          // point offering (and prompting the model to attempt) a tool that
          // can only ever fail.
          tools: webChatToolAllowlist(surface.memoryToolNames, this.codingToolsActive && !this.opts.readOnly),
          // App-aware assistant tools (plan §6.6) are PER-CONNECTION (close
          // over this.currentAppContext + this.send), unlike surface.customTools
          // which is a stateless singleton shared across every session — see
          // createAppAwareTools' doc comment.
          customTools: [...surface.customTools, ...createAppAwareTools(() => this.currentAppContext, (m) => this.send(m))],
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
    if (this.disposed) return;
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
    try {
      await this.bindRuntimeSession();
    } finally {
      if (previous) await previous.dispose();
    }
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

  /** Start a fresh chat (old one stays on disk, resumable from the sidebar).
   *  Re-invokes createRuntimeFactory (either directly via replaceRuntime, or
   *  through AgentSessionRuntime.newSession()'s own internal call to the
   *  SAME factory) — so this is the earliest point a codingTools toggle
   *  flipped mid-session actually takes effect (see set_coding_tools). */
  private async newSession(): Promise<void> {
    if (!this.runtime) {
      await this.replaceRuntime(SessionManager.create(this.cwd, this.sessionDir));
    } else {
      const runtime = this.runtime;
      const change = runtime.newSession();
      this.runtimeChanges.add(change);
      try { await change; } finally { this.runtimeChanges.delete(change); }
    }
    this.sendCodingToolsState();
    this.sendHistory();
    await this.sendSessions();
  }

  /** Resume an existing chat by file path. Same "factory re-runs, codingTools
   *  becomes active if pending" note as newSession above. */
  private async openSession(path: string): Promise<void> {
    if (!this.isUnderSessionDir(path)) {
      this.send({ type: "error", message: "invalid session path" });
      return;
    }
    if (!this.runtime) await this.replaceRuntime(SessionManager.open(path, this.sessionDir));
    else {
      const runtime = this.runtime;
      const change = runtime.switchSession(path);
      this.runtimeChanges.add(change);
      try { await change; } finally { this.runtimeChanges.delete(change); }
    }
    this.sendCodingToolsState();
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
    this.sendCodingToolsState();
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

  /** Clear an armed one-shot next_turn sampling override after a prompt()
   *  call throws before ever reaching before_provider_request (the hook
   *  that normally consumes it via consumeForRequest — see the
   *  "Per-message sampling scope" comment above composeSampling). Reuses
   *  that same pure helper so the clearing logic has exactly one
   *  implementation; discards its `effective` composition since there's no
   *  outgoing request to apply it to. A no-op when nothing was armed. */
  private clearArmedOneShotOnFailedPrompt(): void {
    this.samplingScope = consumeForRequest(this.samplingScope).nextState;
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
    try {
      await session.prompt(text, images.length ? { images } : {});
    } catch (err) {
      // Same pre-flight-failure guard as the "prompt" case above: prompt()
      // can throw before before_provider_request ever fires (no model
      // selected, auth failure), which is the only place a one-shot
      // next_turn sampling override normally gets consumed. Without this,
      // an override armed right before a failed regenerate/edit-resend
      // would silently ride along on a later, unrelated successful turn.
      this.clearArmedOneShotOnFailedPrompt();
      throw err;
    }
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
   *  adapter and the effective sampling overrides into every provider
   *  request (Pi-native adapter control, mirrors the CLI extension).
   *  Default none = no injection (base model). */
  private installAdapterHook(pi: ExtensionAPI): void {
    pi.on("before_provider_request", (event) => {
      let payload = event.payload as Record<string, unknown>;
      // Layer both injections: adapter selection, then sampling overrides.
      // Each returns undefined when it has nothing to change, so we keep the
      // prior payload in that case.
      payload = injectAdapter(payload, this.selectedAdapter) ?? payload;
      // Compose next_turn OVER session, then CONSUME the one-shot override
      // immediately — this is the very first outgoing provider request
      // since it was armed (before_provider_request fires once per model
      // call), so clearing it here guarantees it rides on exactly one
      // request and never leaks into a second tool-loop turn of the same
      // prompt, let alone the next user message.
      const { effective, nextState } = consumeForRequest(this.samplingScope);
      this.samplingScope = nextState;
      payload = injectSampling(payload, effective) ?? payload;
      return payload;
    });
  }

  /** Register the before_agent_start hook that layers the user's custom
   *  system prompt onto the built-in surface prompt. This fires fresh inside
   *  EVERY session.prompt() call (pi passes the freshly-built base prompt
   *  each time, see agent-session.js's emitBeforeAgentStart call site), so a
   *  set_system_prompt sent mid-session takes effect starting with the very
   *  next turn — there is no "only at session creation" limitation here, and
   *  the UI copy should say so plainly (it applies going forward, not
   *  retroactively to already-sent turns). Returning undefined leaves pi's
   *  base prompt (identity + memoryHint) untouched. */
  private installSystemPromptHook(pi: ExtensionAPI): void {
    pi.on("before_agent_start", (event) => {
      const merged = injectSystemPrompt(event.systemPrompt, this.systemPrompt);
      return merged !== undefined ? { systemPrompt: merged } : undefined;
    });
  }

  /** Register the before_agent_start hook that auto-prepends the compact
   *  one-line ambient context (plan §6.6 "never answer blind") to every
   *  turn's system prompt — the SAME layering mechanism
   *  installSystemPromptHook uses for the user's custom prompt (pi's
   *  BeforeAgentStartEventResult can only replace systemPrompt, chained
   *  across multiple extensions — there's no channel to rewrite the raw
   *  user prompt text itself). Fires fresh on every session.prompt() call,
   *  so it always reflects the LATEST context push, never a stale one from
   *  session-creation time. Returns undefined (no-op) when nothing has
   *  been pushed yet — a non-browser WS client, or the race before chat.ts's
   *  first `context` frame lands, must never inject a made-up location. */
  private installAppContextHook(pi: ExtensionAPI): void {
    pi.on("before_agent_start", (event) => {
      const line = ambientContextLine(this.currentAppContext);
      if (!line) return undefined;
      return { systemPrompt: `${event.systemPrompt}\n\n${line}` };
    });
  }

  /**
   * Register the tool_call approval gate on the inline extension.
   *
   * Approval-fatigue defaults (web-chat-redesign.md §5.4 matrix — verified
   * here, not just asserted): READ_ONLY_TOOLS NEVER prompt, checked first
   * and unconditionally — no config, always-allow list, or codingTools
   * state can make a read-only tool gated, and no combination of state can
   * make a GATED_TOOLS member skip the card except the durable
   * tool-approvals config (isToolAlwaysAllowed) or read-only-mode's
   * outright denial. This keeps the fatigue budget spent only on tools
   * that actually mutate the machine.
   */
  /**
   * Register loop-hygiene bookkeeping: turnIndex tracking (turn_start),
   * the before-execution dedup/turn-cap block (tool_call), and the
   * after-execution failure-streak nudge (tool_result). Registered FIRST
   * among the tool_call handlers (see extensionFactories order in
   * createRuntimeFactory) so a deduped or turn-capped call never even
   * reaches the approval gate — no point prompting the user to approve
   * a call we're about to skip. See the LOOP_HYGIENE block comment above
   * for what the SDK already does vs. what this closes.
   */
  private installLoopHygieneHooks(pi: ExtensionAPI): void {
    pi.on("turn_start", (event) => {
      this.loopHygiene.turnIndex = event.turnIndex;
      // A fresh user prompt always restarts at turnIndex 0 (AgentSession
      // resets _turnIndex on agent_start, before the first turn_start) —
      // treat that as "new tool loop" and clear dedup/failure state so a
      // previous message's history never suppresses/nudges this one.
      if (event.turnIndex === 0) this.loopHygiene = initialLoopHygieneState();
    });

    pi.on("tool_call", (event: ToolCallEvent) => {
      const block = decideBeforeToolCall(this.loopHygiene, event.toolName, event.input);
      if (block && runtimeValue("MLX_BUN_PI_DEBUG")) {
        console.error(`[pi-web] loop-hygiene blocked ${event.toolName}: ${block.reason.split("\n")[0]}`);
      }
      return block ? { block: true, reason: block.reason } : undefined;
    });

    pi.on("tool_result", (event) => {
      const nudge = recordToolCallOutcome(this.loopHygiene, event.toolName, event.input, {
        isError: event.isError,
        resultText: toolResultText(event.content),
      });
      if (!nudge) return undefined;
      // Append the course-correction nudge to the existing error content
      // rather than replacing it, so the model still sees the real
      // failure reason plus the "stop repeating this" instruction.
      const existingText = toolResultText(event.content);
      return {
        content: [{ type: "text", text: existingText + nudge }],
        isError: event.isError,
      };
    });
  }

  private installApprovalGate(pi: ExtensionAPI, readOnlyTools: ReadonlySet<string>): void {
    pi.on("tool_call", async (event: ToolCallEvent) => {
      const tool = event.toolName;
      if (runtimeValue("MLX_BUN_PI_DEBUG")) {
        console.error(`[pi-web] tool_call ${tool} args=${JSON.stringify(event.input)}`);
      }

      // Read-only tools never need approval.
      if (toolApprovalClass(tool, readOnlyTools) === "read-only") return undefined;

      // Read-only sessions reject mutations and unclassified tools before
      // consulting durable approvals. Injected names are scoped to this runtime.
      if (this.opts.readOnly) {
        return { block: true, reason: "Read-only session: only read-only tools are allowed." };
      }

      // Durable "always allow this tool" (risk #6): a prior approval card on
      // THIS machine checked the box, persisting to ~/.mlx-bun/tool-
      // approvals.json (chat/tool-approvals.ts). Skip the round-trip entirely
      // — no card, no wait, matching every session and every browser tab.
      if (isToolAlwaysAllowed(tool, this.opts.paths.toolApprovalsFile)) return undefined;

      const decision = await this.requestApproval(event);
      if (decision.decision === "deny") {
        return { block: true, reason: "Denied by user." };
      }
      // Editable arguments (LM Studio's pattern): the SDK's documented
      // mutation contract is "mutate event.input in place before returning"
      // — there is no return-value channel for modified args (ToolCallEventResult
      // is `{block?, reason?}` only). event.input is asserted as a mutable
      // Record here since ToolCallEvent's per-tool variants type it as their
      // specific input shape, but the mutation contract is untyped-record at
      // the wire level (this mirrors how pi's own bundled permission-gate
      // example extension does it).
      applyEditedArgs(event.input as Record<string, unknown>, decision.editedArgs);
      if (decision.alwaysAllow) {
        setToolAlwaysAllowed(tool, this.opts.paths.toolApprovalsFile);
        this.sendToolApprovals();
      }
      return undefined; // allow
    });
  }

  /**
   * Ask the browser to approve a gated tool call and await its decision.
   * Auto-denies after APPROVAL_TIMEOUT_MS or if the connection drops.
   */
  private requestApproval(event: ToolCallEvent): Promise<{ decision: ApprovalDecision; editedArgs?: Record<string, unknown>; alwaysAllow?: boolean }> {
    const callId = event.toolCallId;
    return new Promise((resolve) => {
      const settle = (decision: ApprovalDecision, editedArgs?: Record<string, unknown>, alwaysAllow?: boolean) => {
        const timer = this.approvalTimers.get(callId);
        if (timer) clearTimeout(timer);
        this.approvalTimers.delete(callId);
        this.pendingApprovals.delete(callId);
        resolve({ decision, editedArgs, alwaysAllow });
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
  resolveApproval(callId: string, decision: ApprovalDecision, editedArgs?: Record<string, unknown>, alwaysAllow?: boolean): void {
    const settle = this.pendingApprovals.get(callId);
    if (settle) settle(decision, editedArgs, alwaysAllow);
  }

  /** Push the effective-vs-pending codingTools state (sent on ready and
   *  after every set_coding_tools). */
  private sendCodingToolsState(): void {
    this.send({ type: "coding_tools", active: this.codingToolsActive, pending: this.codingToolsRequested });
  }

  /** Push the full durable always-allow set (sent on ready and after any
   *  change), so the settings panel can list/forget approvals without a
   *  separate REST round-trip. */
  private sendToolApprovals(): void {
    this.send({ type: "tool_approvals", alwaysAllow: listAlwaysAllowedTools(this.opts.paths.toolApprovalsFile) });
  }

  private onSessionEvent(event: AgentSessionEvent): void {
    if (runtimeValue("MLX_BUN_PI_DEBUG")) {
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
    if (this.disposed) return;
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
      case "set_coding_tools":
        // Record the request; doesn't touch the ALREADY-BUILT session's tool
        // surface (pi bakes tools/customTools in at createAgentSessionServices
        // time — there is no live "add a tool to this running session" hook).
        // Applied by createRuntimeFactory the next time the SDK calls it:
        // new_session, open_session, fork_session, or a reconnect's initial
        // start(). sendCodingToolsState reports both active (this session)
        // and pending (the request just recorded) so the UI can be honest
        // about "applies to your next new chat" rather than implying it's
        // live now.
        this.codingToolsRequested = !!msg.enabled;
        this.sendCodingToolsState();
        return;
      case "context":
        // App-aware assistant (plan §6.6): stored wholesale, no session
        // required — chat.ts pushes this on route/step change, which can
        // race the very first `ready` frame on initial connect. Read by
        // get_current_app_context (live) and installAppContextHook (the
        // ambient one-liner auto-prepended to the NEXT turn).
        this.currentAppContext = msg.context;
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
        if (runtimeValue("MLX_BUN_PI_DEBUG")) {
          console.error(`[pi-web] prompt text=${JSON.stringify(msg.text.slice(0, 500))} images=${msg.images?.length ?? 0} streaming=${session.isStreaming} adapter=${this.selectedAdapter ?? "base"}`);
        }
        const images = toPiImages(msg.images);
        // Guard a one-shot next_turn override against prompt() throwing
        // BEFORE it ever issues a provider request (no model selected, auth
        // failure, etc.) — the normal consumer, installAdapterHook's
        // before_provider_request hook, never fires in that case, so
        // without this the armed override would silently survive to land
        // on some later, unrelated successful turn instead of this one.
        // sendError (the WS layer's outer catch) still reports the error;
        // this only prevents the override from outliving its intended turn.
        try {
          if (session.isStreaming) await session.prompt(msg.text, { streamingBehavior: "followUp", images });
          else await session.prompt(msg.text, { images });
        } catch (err) {
          this.clearArmedOneShotOnFailedPrompt();
          throw err;
        }
        return;
      }
      case "abort":
        await session.abort();
        return;
      case "approval":
        this.resolveApproval(msg.callId, msg.decision, msg.editedArgs, msg.alwaysAllow);
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
      case "set_sampling": {
        // The full mlx_lm.server sampler extension set (min_p/XTC/penalty
        // families/seed), not just temperature/top_p/top_k
        // (web-ui-pass-plan.md #8), for either scope.
        const overrides: SamplingOverrides = {
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
        // scope "next_turn": one-shot, armed via applySetSampling and
        // consumed by installAdapterHook's before_provider_request handler
        // on the very next outgoing provider request — never touches the
        // session-level value, so a later plain set_sampling (scope
        // "session" or omitted) still sees whatever was there before this
        // message. scope "session"/omitted: today's behavior, persists on
        // the connection until changed; a null/undefined field clears the
        // override so the server's mode-aware default applies again.
        this.samplingScope = applySetSampling(this.samplingScope, overrides, msg.scope);
        return;
      }
      case "set_system_prompt":
        // Store verbatim (including whitespace-only/empty -> effectively
        // cleared by injectSystemPrompt's trim+empty check); applied by the
        // before_agent_start hook starting with the next turn.
        this.systemPrompt = msg.text;
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
  dispose(): Promise<void> {
    return this.disposal ??= (async () => {
      this.disposed = true;
      const runtime = this.runtime;
      const session = runtime?.session ?? this.session;
      this.runtime = undefined;
      const errors: unknown[] = [];
      try { this.teardownBindings(); } catch (error) { errors.push(error); }
      // SDK runtime.dispose requests cancellation through synchronous session
      // disposal; only session.abort waits for the active agent turn to stop.
      try { await session?.abort(); } catch (error) { errors.push(error); }
      // SDK replacements can publish a new session after cancellation. Join
      // them before releasing the captured runtime so its latest session closes.
      await Promise.allSettled([...this.runtimeChanges]);
      try { await runtime?.dispose(); } catch (error) { errors.push(error); }
      if (errors.length === 1) throw errors[0];
      if (errors.length) throw new AggregateError(errors, "Pi cleanup failed");
    })();
  }

  /** Send a frame, swallowing errors on a closed socket. */
  private send(msg: ServerMessage): void {
    if (this.disposed) return;
    try {
      this.emit(msg);
    } catch {
      // Socket closed mid-send; nothing actionable.
    }
  }
}

/** App-owned persistence locations; omitted paths retain the installed app defaults. */
export interface PiBackendPaths {
  cwd?: string;
  agentDir?: string;
  sessionDir?: string;
  toolApprovalsFile?: string;
}

export interface PiBackendOptions {
  paths?: PiBackendPaths;
  /** Resolved on connection so a server binding port zero can report its actual port. */
  port: number | (() => number);
  modelId?: string;
  contextWindow?: number;
  readOnly?: boolean;
  vision?: boolean;
  audio?: boolean;
  thinking?: boolean;
  genDefaults?: ReadyGenDefaults;
  transcription?: () => Promise<boolean>;
  /** The app memory owner supplies its tools and skill paths; absent means disabled. */
  memory?: () => Promise<MemorySurface | undefined>;
  downloadsSnapshot?: () => readonly { state: string; repoId: string }[];
}

/** Creates isolated chat sessions over the application's loopback HTTP API. */
export function createPiBackend(options: PiBackendOptions): ChatBackendFactory {
  const resolved = {
    ...options,
    paths: {
      cwd: options.paths?.cwd ?? process.cwd(),
      agentDir: options.paths?.agentDir ?? join(homedir(), ".mlx-bun", "pi-sessions"),
      sessionDir: options.paths?.sessionDir ?? defaultSessionDir(),
      toolApprovalsFile: options.paths?.toolApprovalsFile,
    },
    modelId: options.modelId ?? PI_LOCAL_MODEL_ID,
    contextWindow: options.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
    readOnly: options.readOnly ?? false,
    vision: options.vision ?? false,
    audio: options.audio ?? false,
    thinking: options.thinking ?? false,
    genDefaults: options.genDefaults ?? { temperature: null, topP: null, topK: null },
    transcription: options.transcription ?? (async () => false),
  };
  return (send) => new PiBackend(send, resolved);
}
