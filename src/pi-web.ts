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

import { homedir } from "node:os";
import { join } from "node:path";
import type { ServerWebSocket, WebSocketHandler } from "bun";
import {
  AuthStorage,
  createAgentSession,
  DefaultResourceLoader,
  getAgentDir,
  ModelRegistry,
  SessionManager,
  type AgentSession,
  type AgentSessionEvent,
  type ExtensionAPI,
  type ToolCallEvent,
} from "@earendil-works/pi-coding-agent";

// `Model` is not re-exported from the package index; derive it from the
// registry's `find()` return type so we avoid importing the transitive
// @earendil-works/pi-ai package directly.
type PiModel = NonNullable<ReturnType<ModelRegistry["find"]>>;

// Provider/model constants — kept byte-for-byte aligned with harness-pi.ts
// so the web path and the subprocess path register the same provider.
const PI_PROVIDER_ID = "mlx-bun";
const PI_LOCAL_MODEL_ID = "local";
const PI_API_KEY = "sk-mlx-bun-local";
const PI_API = "openai-completions" as const;

/** Full coding toolset — the user explicitly wants all tools available. */
const ALL_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];
/** Tools that never mutate; auto-allowed without a browser round-trip. */
const READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls"]);
/** Tools that require explicit per-call browser approval. */
const GATED_TOOLS = new Set(["bash", "edit", "write"]);

/** Auto-deny a pending approval after this long with no browser decision. */
const APPROVAL_TIMEOUT_MS = 120_000;

const DEFAULT_CONTEXT_WINDOW = 32_768;
const DEFAULT_MAX_TOKENS = 8_192;

/** Per-connection data the server attaches at upgrade time. */
export interface PiWsData {
  sessionId: string;
}

type PiWs = ServerWebSocket<PiWsData>;

// ---- WS protocol message shapes --------------------------------------

/** Decision a browser returns for a gated tool call. */
type ApprovalDecision = "allow" | "deny";

/** Client -> server frames. */
type ClientMessage =
  | { type: "prompt"; text: string }
  | { type: "steer"; text: string }
  | { type: "abort" }
  | { type: "approval"; callId: string; decision: ApprovalDecision };

/** Server -> client frames. */
type ServerMessage =
  | { type: "ready"; model: string }
  | { type: "turn_start" }
  | { type: "text_delta"; delta: string }
  | { type: "tool_start"; callId: string; tool: string; args: unknown }
  | { type: "tool_approval_request"; callId: string; tool: string; args: unknown }
  | { type: "tool_update"; callId: string; chunk: unknown }
  | { type: "tool_end"; callId: string; ok: boolean; result: unknown }
  | { type: "turn_end" }
  | { type: "queue_update"; steering: readonly string[]; followUp: readonly string[] }
  | { type: "error"; message: string };

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
  private unsubscribe?: () => void;
  private disposed = false;

  /** callId -> resolve(decision). Pending browser approvals in flight. */
  private readonly pendingApprovals = new Map<string, (decision: ApprovalDecision) => void>();
  /** callId -> timer handle, so we can clear on resolve/dispose. */
  private readonly approvalTimers = new Map<string, ReturnType<typeof setTimeout>>();

  constructor(
    private readonly ws: PiWs,
    private readonly opts: { port: number | (() => number); modelId: string; contextWindow: number; readOnly: boolean },
  ) {}

  /** Build the pi AgentSession and start streaming events to the browser. */
  async start(): Promise<void> {
    // Resolve the port lazily: the WS handler is constructed before
    // Bun.serve() binds, so an ephemeral (0) port is only known at the
    // first connection. createServer passes `() => server.port`.
    const port = typeof this.opts.port === "function" ? this.opts.port() : this.opts.port;
    const baseUrl = `http://127.0.0.1:${port}/v1`;

    // In-memory auth + registry: no models.json, no disk cross-talk. The
    // runtime key satisfies pi's auth check for our zero-cost local key.
    const authStorage = AuthStorage.inMemory();
    authStorage.setRuntimeApiKey(PI_PROVIDER_ID, PI_API_KEY);

    const modelRegistry = ModelRegistry.inMemory(authStorage);
    modelRegistry.registerProvider(PI_PROVIDER_ID, {
      baseUrl,
      apiKey: PI_API_KEY,
      api: PI_API,
      models: [
        {
          id: PI_LOCAL_MODEL_ID,
          name: "mlx-bun (local)",
          api: PI_API,
          reasoning: false,
          input: ["text"],
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
          contextWindow: this.opts.contextWindow,
          maxTokens: DEFAULT_MAX_TOKENS,
        },
      ],
    });

    const model: PiModel | undefined = modelRegistry.find(PI_PROVIDER_ID, PI_LOCAL_MODEL_ID);
    if (!model) throw new Error("failed to register mlx-bun/local model");

    const cwd = process.cwd();
    const agentDir = join(homedir(), ".mlx-bun", "pi-sessions");

    // Inline extension carries the pre-execution approval gate. Registered
    // via DefaultResourceLoader.extensionFactories so it loads in-process
    // with no file on disk and no global ~/.pi extension discovery.
    const resourceLoader = new DefaultResourceLoader({
      cwd,
      agentDir,
      // Skip user/project resource discovery: the web agent is fully
      // self-contained and must not inherit the user's pi extensions,
      // skills, or context files.
      noExtensions: true,
      noSkills: true,
      noPromptTemplates: true,
      noThemes: true,
      noContextFiles: true,
      extensionFactories: [(pi) => this.installApprovalGate(pi)],
    });
    await resourceLoader.reload();

    const { session } = await createAgentSession({
      cwd,
      agentDir,
      model,
      modelRegistry,
      authStorage,
      resourceLoader,
      tools: ALL_TOOLS,
      sessionManager: SessionManager.inMemory(cwd),
    });

    if (this.disposed) {
      // Connection closed while we were building; tear down immediately.
      session.dispose();
      return;
    }

    this.session = session;
    this.unsubscribe = session.subscribe((event) => this.onSessionEvent(event));

    this.send({ type: "ready", model: this.opts.modelId });
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
  }

  /** Handle one parsed client frame. */
  async handle(msg: ClientMessage): Promise<void> {
    const session = this.session;
    if (!session) {
      this.send({ type: "error", message: "session not ready" });
      return;
    }

    switch (msg.type) {
      case "prompt":
        // One in-flight prompt per session: when already streaming, queue
        // as a steering message (pi enforces this via isStreaming).
        if (session.isStreaming) {
          await session.prompt(msg.text, { streamingBehavior: "steer" });
        } else {
          await session.prompt(msg.text);
        }
        return;
      case "steer":
        await session.steer(msg.text);
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
    // Deny anything still waiting so blocked tool handlers unwind.
    for (const settle of this.pendingApprovals.values()) settle("deny");
    this.pendingApprovals.clear();
    for (const timer of this.approvalTimers.values()) clearTimeout(timer);
    this.approvalTimers.clear();

    this.unsubscribe?.();
    this.unsubscribe = undefined;
    try {
      this.session?.dispose();
    } catch {
      // Never let a dispose error escape shutdown.
    }
    this.session = undefined;
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
}): WebSocketHandler<PiWsData> {
  const resolved = {
    port: opts.port,
    modelId: opts.modelId ?? PI_LOCAL_MODEL_ID,
    contextWindow: opts.contextWindow ?? DEFAULT_CONTEXT_WINDOW,
    readOnly: opts.readOnly ?? false,
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
