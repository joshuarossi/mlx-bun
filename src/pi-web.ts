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
  defineTool,
  SessionManager,
  type AgentSession,
  type AgentSessionEvent,
  type AgentSessionRuntime,
  type CreateAgentSessionRuntimeFactory,
  type ExtensionAPI,
  type SessionEntry,
  type SessionInfo,
  type ToolCallEvent,
  type ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import type { ImageContent } from "@earendil-works/pi-ai";
import { Type } from "typebox";
import { WEB_TOOL_NAMES } from "./web-tools";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "./memory/tools";
import { buildPiAgentSurface } from "./pi-session";
import { buildPiProvider, DEFAULT_CONTEXT_WINDOW, PI_LOCAL_MODEL_ID } from "./pi-provider";
import { downloadsSnapshot } from "./download";
import { getLane, type Lane } from "./serve/lane-registry";
import { isToolAlwaysAllowed, setToolAlwaysAllowed, listAlwaysAllowedTools } from "./tool-approvals";

/**
 * Tools that never mutate the user's machine; auto-allowed without a browser
 * round-trip. The web tools make outbound network requests but change nothing
 * locally, so they're auto-allowed too (and remain usable in read-only mode).
 * The app-aware assistant's three tools (get_current_app_context/
 * navigate_app/spotlight_ui, plan §6.6) join this set for the same reason:
 * navigation and spotlighting are reversible UI actions on the user's OWN
 * open browser tab, never a machine mutation — see createAppAwareTools'
 * doc comment below for the full classification rationale.
 */
export const APP_AWARE_TOOL_NAMES = ["get_current_app_context", "navigate_app", "spotlight_ui"] as const;
const READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls", ...WEB_TOOL_NAMES, ...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES, ...APP_AWARE_TOOL_NAMES]);
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
 * memory/reference read tools whenever the surface has memory enabled, plus
 * — opt-in only (plan §5.4/§6.5/§9 Phase 2's "let the agent touch files on
 * this machine" toggle, default OFF) — the three GATED_TOOLS (bash/edit/
 * write) and the read-only grep/find/ls that make them useful. The system
 * prompt (surface.memoryHint) and the bundled memory skill instruct the
 * model to call memory_resolve/memory_read/… — pi treats `tools` as an
 * allowlist, so leaving them out makes every such call fail. All additions
 * except the coding tools are in READ_ONLY_TOOLS (no approval round-trip);
 * bash/edit/write ARE gated — this is precisely what makes the
 * already-built approval card fire for the first time once codingTools is
 * on (previously dead code: nothing in the default surface could ever
 * reach GATED_TOOLS). APP_AWARE_TOOL_NAMES ride along unconditionally
 * (like WELCOME_TOOLS) — they're read-only-on-the-machine regardless of
 * memory/codingTools/read-only-server state (see APP_AWARE_TOOL_NAMES'
 * doc comment).
 */
export function webChatToolAllowlist(memoryEnabled: boolean, codingTools = false): string[] {
  return [
    ...WELCOME_TOOLS,
    ...APP_AWARE_TOOL_NAMES,
    ...(memoryEnabled ? [...MEMORY_TOOL_NAMES, ...REFERENCE_TOOL_NAMES] : []),
    ...(codingTools ? ["grep", "find", "ls", ...GATED_TOOLS] : []),
  ];
}

/** Auto-deny a pending approval after this long with no browser decision. */
const APPROVAL_TIMEOUT_MS = 120_000;

// ---- Loop hygiene (beat matrix Axis 7 "Tool-loop hygiene" row) --------
//
// What the pi SDK already provides (investigated in
// node_modules/@earendil-works/pi-agent-core/dist/agent-loop.js and
// pi-coding-agent/dist/core/agent-session.js before adding any of this):
//   - Malformed tool-call ARGS: pi-ai's `parseJsonWithRepair`/
//     `parseStreamingJson` (dist/utils/json-parse.js) already repairs
//     invalid backslash escapes/control chars and tolerates truncated
//     streaming JSON; `validateToolArguments` (utils/validation.js)
//     coerces JSON-Schema primitive types. Neither touches OUR OWN
//     format-specific tool-call text parsers (gemma4 `call:name{...}`,
//     the OpenAI/Qwen/MiniCPM5 decoded-text shapes) — that repair layer
//     is added in src/tool-call.ts instead (see RepairKind there).
//   - Repeated identical calls: NOT deduped anywhere in the SDK. Every
//     tool_call the model emits executes, full stop.
//   - Failed-call retries: NOT budgeted. A tool error becomes a
//     toolResult with isError:true and the loop just continues; nothing
//     nudges the model to stop repeating a failing call.
//   - Max turns / loop cap: NOT implemented by AgentSession at all (only
//     agent-loop.js's raw runAgentLoop is hook-driven via
//     config.shouldStopAfterTurn, which AgentSession never wires up or
//     exposes to extensions). There is no cap, so a small model that
//     keeps calling tools can loop until the user manually stops it.
// All three gaps are closed here using the ONE mechanism AgentSession
// does expose to extensions: pi.on("tool_call", ...) (before execution,
// can only `block`) and pi.on("tool_result", ...) (after execution, can
// reshape the result) — see installLoopHygieneHooks below. Turn-index
// bookkeeping rides pi.on("turn_start"/"turn_end") (AgentSession's own
// _turnIndex, which resets to 0 once per agent_start i.e. once per
// session.prompt() call — see agent-session.js's _emitExtensionEvent).
//
// KNOWN SDK LIMITATION (documented, not silently worked around): a
// `tool_call` handler's block path (ToolCallEventResult) can only
// produce an ERROR toolResult (agent-loop.js's createErrorToolResult —
// there is no "block but still succeed" return shape). So "dedup: skip
// re-execution, return cached result" cannot literally inject a
// non-error result without running the tool again — the closest honest
// equivalent is blocking the repeat with the PRIOR call's actual result
// text inlined into the (error-flagged) block reason, so the model
// still sees the real answer instead of a bare "blocked" message and
// can move on, rather than getting a second identical error with no
// information gain.

/** Consecutive-identical-successful-call dedup, retry budget, and
 *  tool-turn cap. Mutable per-connection (reset at prompt time) so re-
 *  export as a class keeps all three concerns in one bookkeeping object
 *  that's trivial to unit test via its pure decision methods. */
export const LOOP_HYGIENE = {
  /** After this many consecutive FAILED calls with the same signature
   *  (name + JSON-stable args), the nudge text asks the model to change
   *  approach instead of repeating verbatim. optiq Lab's documented
   *  budget (beat matrix Axis 7) is 3. */
  MAX_CONSECUTIVE_FAILURES: 3,
  /** Cap on AgentSession's turnIndex (one assistant-response round, per
   *  agent-session.js's _turnIndex) within a single user prompt before
   *  every further tool call is blocked with a force-finish nudge.
   *  optiq Lab's documented cap (beat matrix Axis 7) is 25. */
  MAX_TOOL_TURNS: 25,
} as const;

/** Stable key for "the same call" — used by both the dedup check and the
 *  failure-streak counter. JSON.stringify on a plain object from parsed
 *  tool-call args is key-order-dependent; that's fine here since we're
 *  comparing the SDK's own re-delivered `event.input` (same object shape
 *  each time for a literal repeat, which is the only case that matters —
 *  semantically-equal-but-differently-ordered args are not "identical"
 *  for dedup purposes, only byte-identical repeats are). Exported for
 *  unit testing. */
export function toolCallSignature(toolName: string, args: unknown): string {
  return `${toolName}:${stableStringify(args)}`;
}

/** Deterministic (key-sorted) JSON.stringify so argument key order never
 *  causes two semantically-identical calls to hash differently. */
function stableStringify(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(",")}]`;
  if (value && typeof value === "object") {
    const keys = Object.keys(value as Record<string, unknown>).sort();
    return `{${keys.map((k) => `${JSON.stringify(k)}:${stableStringify((value as Record<string, unknown>)[k])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

/** Pure decision for the tool_call (before) hook: given the current loop
 *  state and the incoming call's signature, decide whether to block it
 *  outright (dedup or turn-cap) and, if so, why. Returns undefined when
 *  the call should proceed to normal execution. Exported + pure so the
 *  three policies (dedup / turn cap / [failure budget is a tool_result-
 *  side concern, see nextFailureNudge]) are unit-testable without a live
 *  AgentSession. */
export interface LoopHygieneState {
  /** Signature + result text of the last call that completed successfully
   *  (undefined if none yet this prompt). */
  lastSuccess?: { signature: string; resultText: string };
  /** Consecutive failure count keyed by call signature. */
  failureStreaks: Map<string, number>;
  /** Current AgentSession turnIndex (updated on every turn_start). */
  turnIndex: number;
}

export function initialLoopHygieneState(): LoopHygieneState {
  return { lastSuccess: undefined, failureStreaks: new Map(), turnIndex: 0 };
}

export interface LoopHygieneBlock {
  reason: string;
}

/** Decide whether to block a tool call BEFORE it runs. Checked in this
 *  order: turn cap first (a model that's been looping for 25 rounds gets
 *  force-finish treatment regardless of what it's calling next), then
 *  consecutive-identical-successful-call dedup. */
export function decideBeforeToolCall(
  state: LoopHygieneState,
  toolName: string,
  args: unknown,
): LoopHygieneBlock | undefined {
  if (state.turnIndex >= LOOP_HYGIENE.MAX_TOOL_TURNS) {
    return {
      reason:
        `Tool-turn limit (${LOOP_HYGIENE.MAX_TOOL_TURNS}) reached for this message. ` +
        "Stop calling tools now and answer the user directly with what you have so far.",
    };
  }
  const signature = toolCallSignature(toolName, args);
  if (state.lastSuccess && state.lastSuccess.signature === signature) {
    return {
      reason:
        "This exact tool call already ran and succeeded; skipping re-execution. " +
        `Its result was:\n\n${state.lastSuccess.resultText}\n\n` +
        "Use that result instead of calling it again.",
    };
  }
  return undefined;
}

/** Update loop-hygiene bookkeeping AFTER a call executes (or was
 *  immediately blocked/errored) and, on repeated failure, return nudge
 *  text to append to the error the model sees. `resultText` is the
 *  flattened text content of the tool's result (used to seed
 *  `lastSuccess` for the dedup check above). Exported + pure. */
export function recordToolCallOutcome(
  state: LoopHygieneState,
  toolName: string,
  args: unknown,
  outcome: { isError: boolean; resultText: string },
): string | undefined {
  const signature = toolCallSignature(toolName, args);
  if (outcome.isError) {
    const streak = (state.failureStreaks.get(signature) ?? 0) + 1;
    state.failureStreaks.set(signature, streak);
    if (streak >= LOOP_HYGIENE.MAX_CONSECUTIVE_FAILURES) {
      return (
        `\n\n(This exact call has now failed ${streak} times in a row. ` +
        "Stop repeating it verbatim — try a different tool, different arguments, " +
        "or explain to the user what's blocking you.)"
      );
    }
    return undefined;
  }
  state.failureStreaks.delete(signature);
  state.lastSuccess = { signature, resultText: outcome.resultText };
  return undefined;
}

/** Flatten a tool result's content (TextContent[] shape) to plain text for
 *  dedup-cache display and diagnostics. Mirrors contentText's tolerance
 *  for non-array/string shapes. Exported for unit testing. */
export function toolResultText(content: unknown): string {
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
export const WEB_CHAT_PROMPT_VERSION = "2026-07-07-app-aware-v1";

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
  // App-aware assistant (plan §6.6): tell the model these tools exist and
  // when to reach for them instead of describing the UI blind — "when the
  // user asks where/how in the app, navigate or spotlight instead of
  // describing blind" is the literal steer the task calls for. Included
  // whenever the session has tools at all (these three are always in the
  // allowlist alongside WELCOME_TOOLS — see webChatToolAllowlist).
  const appAwareLine = hasTools
    ? ` You can see and act on the app: \`navigate_app\` switches the view, \`spotlight_ui\` highlights a control (use \`get_current_app_context\` first for its ref). When asked where/how in the app, navigate or spotlight instead of describing it blind.`
    : "";
  const toolsLine = hasTools
    ? ` Answer directly from your own knowledge whenever you can. Only call a tool when you truly need information you don't have: \`web_search\` for current or external facts (news, current events, prices, latest docs), \`read\` for a specific local file the user points you to. Never use a tool for general questions, explanations, math, or writing — just answer. When a tool returns results, pull the answer out of the result text and state it directly — never tell the user to go open the links or check the sources themselves; reading them is your job.${appAwareLine}`
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

/** Decision a browser returns for a gated tool call. `editedArgs`, when
 *  present on an "allow", replaces the tool's proposed input before it runs
 *  (LM Studio's editable-args pattern — plan §5.4/§6.5). `alwaysAllow` marks
 *  the decision as "and remember this tool" — handled by resolveApproval,
 *  which persists it to the durable tool-approvals config (src/tool-
 *  approvals.ts) before settling the pending promise. */
export type ApprovalDecision = "allow" | "deny";

/** An image attachment from the browser: base64 (no data: prefix) + mime. */
export interface ImageAttachment {
  data: string;
  mimeType: string;
}

/** Client -> server frames. Exported type-only for the web frontend
 *  (src/web/src/*.ts import it via `import type` — see tsconfig.web.json
 *  and scripts/build-web.ts) so the WS contract is checked at compile time
 *  on both ends instead of drifting between server TS and untyped inline
 *  browser JS (the observed Phase-0 bug class). */
export type ClientMessage =
  | { type: "prompt"; text: string; images?: ImageAttachment[] }
  | { type: "abort" }
  // `editedArgs`: when the user edited the proposed arguments in the
  // approval card's textarea before approving, the (re-parsed) JSON object
  // to substitute for the tool's original input — mutated onto the pi SDK's
  // ToolCallEvent.input in place (the SDK's documented mutation contract;
  // see installApprovalGate). Ignored on "deny". `alwaysAllow`: persist this
  // tool to the durable always-allow config (src/tool-approvals.ts) so
  // future calls to the SAME TOOL NAME skip the card entirely, on this and
  // every other session.
  | { type: "approval"; callId: string; decision: ApprovalDecision; editedArgs?: Record<string, unknown>; alwaysAllow?: boolean }
  // Toggle the model's reasoning channel on/off (only meaningful when the
  // model supports thinking — ready.thinking). Maps to Pi's session thinking
  // level: "medium" (on) ↔ "off". Pi sends it as enable_thinking to the server.
  | { type: "set_thinking"; enabled: boolean }
  // Opt-in toggle (plan §5.4/§6.5/§9 Phase 2, default OFF): "let the agent
  // touch files on this machine". Persisted per-browser by the client
  // (localStorage `mlxbun.codingTools`); the ALLOWLIST decision is enforced
  // here, server-side. buildPiAgentSurface's tool list is fixed for the
  // life of an AgentSession (pi's DefaultResourceLoader config is baked in
  // at createAgentSessionServices time), so this can't rewire an
  // in-progress session — it takes effect starting with the next
  // new_session/open_session/fork_session (createRuntimeFactory reads
  // this.codingToolsRequested fresh every time the SDK calls it, including
  // from AgentSessionRuntime.newSession()'s internal re-invocation). The
  // `coding_tools` ServerMessage below reports the honest current-vs-pending
  // state so the UI can say so instead of implying it applies immediately.
  | { type: "set_coding_tools"; enabled: boolean }
  // Select the active LoRA adapter for subsequent turns (null = none/base).
  // app.html mounts it (POST /v1/adapters) before sending this; the
  // before_provider_request hook injects it into the provider payload.
  | { type: "set_adapter"; id: string | null }
  // Per-request sampling overrides. Each field is optional; null/undefined
  // means "leave it to the server default" (the mode-aware recommended
  // value resolved in toOptions). A present numeric value is injected into
  // the provider payload and always wins. The before_provider_request hook
  // injects whatever is set here.
  //
  // `scope` (plan §9 Phase 3 / beat matrix Axis 4 "per-message sampling
  // scope"): "session" (default, omitting the field means this too) persists
  // the override on the connection until changed — today's behavior,
  // unchanged. "next_turn" stores a ONE-SHOT override applied to exactly
  // the next prompt's injection, then cleared automatically — it never
  // touches the session-level values (a later plain set_sampling with
  // scope:"session" or omitted still sees whatever was there before this
  // message). Composition when both are present: next_turn's SET fields
  // win over session's for that one request; anything next_turn leaves
  // null/unset falls back to the session-level override for that field
  // (composeSampling — session-level itself falls back to the server's
  // mode-aware default per injectSampling's existing contract).
  | {
      type: "set_sampling";
      scope?: "session" | "next_turn";
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
  // Per-session USER system prompt, layered ON TOP OF (not replacing) the
  // built-in surface prompt (buildWebChatSystemPrompt + memoryHint). null
  // clears it. Applied by the before_agent_start hook on the NEXT turn (pi
  // calls it fresh inside every session.prompt(), so this is a true
  // per-turn injection, not a session-creation-only setting — see
  // installSystemPromptHook). Presets v1 (composer.ts) send this alongside
  // set_sampling to apply a saved bundle.
  | { type: "set_system_prompt"; text: string | null }
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
  | { type: "switch_sibling"; entryId: string }
  // App-aware assistant (plan §6.6, §9 Phase 3, beat matrix Axis 12): pushed
  // by chat.ts on every route change AND on wizard-step change (quantize/
  // finetune/dataset), never on a timer. `context` is opaque here (the
  // browser's AppContext shape, src/web/src/assistant.ts) — stored verbatim
  // as the connection's currentAppContext and returned by the
  // get_current_app_context tool, plus mined for the compact one-line
  // ambient context auto-prepended to the NEXT prompt (see
  // installAppContextHook / ambientContextLine). This is a DIFFERENT frame
  // from the server->client `context` ServerMessage (context-window usage,
  // above) — same name, opposite direction, disambiguated by which type
  // union it's a member of; the two are never in scope at the same call
  // site (ClientMessage here vs. ServerMessage below).
  | { type: "context"; context: AppUiContext };

// ---- App-aware assistant (plan §6.6, §9 Phase 3, beat matrix Axis 12) --
//
// Mirrors src/web/src/assistant.ts's browser-side types (which are the
// source of truth for shape — this server-side copy is intentionally loose
// (mostly `unknown`/optional) since the server never constructs a
// UiSnapshot itself, only stores and forwards what the browser sends. Kept
// here (not imported) because src/web/src/assistant.ts is bundled into the
// browser and importing it here would pull browser code into the server
// build — the inverse of the type-only ClientMessage/ServerMessage import
// direction the frontend uses for pi-web.ts.

/** One element in a captured DOM snapshot — see assistant.ts's
 *  UiSnapshotElement for the authoritative shape/doc. */
export interface UiSnapshotElement {
  ref: string;
  tag: string;
  label: string;
  kind: "interactive" | "region";
  role?: string;
  selector: string;
  spotlightId?: string;
}

export interface UiSnapshot {
  route: string;
  capturedAt: string;
  elements: UiSnapshotElement[];
}

/** The wizard-step process-state fields (§6.6 "carries process state, not
 *  just elements") — present only on routes with a step wizard. */
export interface WizardStep {
  index: number;
  count: number;
  label: string;
}

/** The full context payload pushed by chat.ts on route/step change — see
 *  assistant.ts's buildAppContext. Stored verbatim per-connection. */
export interface AppUiContext {
  route: string;
  view?: string;
  step?: WizardStep;
  snapshot: UiSnapshot;
}

/** Route catalog mirror (src/web/src/ui-catalog.ts's ROUTE_IDS) for
 *  server-side validation of navigate_app's route/page param BEFORE it
 *  ever reaches the browser — an unknown route is rejected here as a tool
 *  error rather than sent as a `ui_navigate` frame the router can't match.
 *  Keep in sync with ui-catalog.ts's ROUTE_IDS by hand (no shared-JSON
 *  import between the server and browser bundles — see that file's
 *  top-of-file comment for why). */
export const APP_ROUTE_IDS = ["chat", "quantize", "finetune", "dataset", "status"] as const;
export type AppRouteId = (typeof APP_ROUTE_IDS)[number];

export function isAppRouteId(v: string): v is AppRouteId {
  return (APP_ROUTE_IDS as readonly string[]).includes(v);
}

/** Resolve a free-form route/page string the way navigate_app's tool
 *  describes its param to the model: either a bare route id ("quantize")
 *  or a "#/quantize"-style hash. Returns null for anything else. */
export function resolveAppRoute(routeOrPage: string): AppRouteId | null {
  const bare = routeOrPage.trim().replace(/^#\/?/, "");
  return isAppRouteId(bare) ? bare : null;
}

/** Compact one-line ambient context (§6.6 "never answer blind") mined from
 *  the stored AppUiContext — e.g. "[user is on: Quantize · step 2/4]".
 *  Never a snapshot dump; this is the ONLY thing auto-attached to every
 *  turn (the full snapshot stays on-demand via get_current_app_context).
 *  Returns null when there's no context yet (nothing pushed this
 *  connection — e.g. a non-browser WS client, or the very first frame
 *  race before chat.ts's first context push lands). Pure + exported for
 *  unit testing; mirrors assistant.ts's ambientLine so the two stay in
 *  lockstep even though the server never imports the browser module. */
const APP_ROUTE_LABELS: Record<AppRouteId, string> = {
  chat: "Chat", quantize: "Quantize", finetune: "Fine-tune", dataset: "Build Dataset", status: "Status",
};

export function ambientContextLine(ctx: AppUiContext | null | undefined): string | null {
  if (!ctx || !ctx.route) return null;
  const place = ctx.view ?? APP_ROUTE_LABELS[ctx.route as AppRouteId] ?? ctx.route;
  const stepPart = ctx.step ? ` · step ${ctx.step.index + 1}/${ctx.step.count}` : "";
  return `[user is on: ${place}${stepPart}]`;
}

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

/** Server -> client frames. Exported type-only — see ClientMessage above. */
export type ServerMessage =
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
  // Effective vs. pending codingTools state (set_coding_tools above).
  // `active` is what the CURRENT session actually built with (gates
  // whether the approval card can ever fire); `pending` is the browser's
  // most recent request, which only takes effect on the next
  // new/opened/forked session — surfaced so the settings copy can say
  // "will apply to your next new chat" instead of lying about immediacy.
  | { type: "coding_tools"; active: boolean; pending: boolean }
  // Full always-allow set for THIS machine (src/tool-approvals.ts), sent on
  // `ready` and after any change, so the settings panel can list/forget
  // durable per-tool approvals without a separate REST round-trip.
  | { type: "tool_approvals"; alwaysAllow: string[] }
  // App-aware assistant (plan §6.6): the navigate_app / spotlight_ui tools'
  // side-channel notifications, mapped 1:1 from the tool call's params —
  // never guessed or re-derived, so chat.ts's router/spotlight get exactly
  // what the model asked for. `route` here is always a validated
  // AppRouteId (isAppRouteId already ran server-side before this frame is
  // ever sent — see navigate_app's execute). ui_spotlight's fields mirror
  // SpotlightRequest 1:1 (assistant.ts resolves ref/label/selector/target
  // client-side, in that precedence order, against its last snapshot).
  | { type: "ui_navigate"; route: AppRouteId }
  | { type: "ui_spotlight"; ref?: string; label?: string; selector?: string; target?: string; message?: string; route?: AppRouteId }
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

// ---- Per-message sampling scope (beat matrix Axis 4 / plan §9 Phase 3) --
//
// set_sampling's optional `scope` field: "session" (default, today's
// behavior — persists on the connection until changed) or "next_turn" (a
// one-shot override for exactly the next prompt, then cleared). The
// composition rule is "next_turn OVER session": a next_turn field that's
// a real number wins over the session-level value for that SAME field;
// a next_turn field left null/undefined falls through to the session
// override (which itself falls through to the server default per
// injectSampling's existing null-means-unset contract). This mirrors
// optiq Lab's per-message temp/max-tokens/thinking granularity cited in
// the beat matrix, layered onto (not replacing) Phase 1's session-level
// overrides.
//
// Lifecycle: armed by the set_sampling handler when scope is "next_turn"
// (stored separately from the session-level `sampling` field so a
// one-shot override never permanently clobbers the session default it's
// laid over). Consumed at the FIRST before_provider_request of the very
// next prompt — before_agent_start fires exactly once per session.prompt()
// call (see agent-session.js's prompt() body), which is the natural
// "one prompt" boundary, but the actual sampling injection happens in
// before_provider_request (fired once per model call, i.e. once per
// tool-loop turn) — so the override is consumed (cleared) the first time
// before_provider_request fires after being armed, guaranteeing it rides
// on exactly the next outgoing provider request and never leaks into a
// second turn within the same prompt, let alone the next user message.

/** Compose the effective sampling overrides for one outgoing provider
 *  request: every field in `nextTurn` that's a real number wins; anything
 *  left null/undefined in `nextTurn` falls back to `session`'s value for
 *  that field. Pure + exported for unit testing. When `nextTurn` is
 *  undefined (no one-shot override armed), returns `session` unchanged. */
export function composeSampling(
  session: SamplingOverrides,
  nextTurn: SamplingOverrides | undefined,
): SamplingOverrides {
  if (!nextTurn) return session;
  const out: SamplingOverrides = { ...session };
  for (const field of SAMPLING_FIELDS) {
    const v = nextTurn[field];
    if (typeof v === "number" && Number.isFinite(v)) out[field] = v;
  }
  return out;
}

/** Pure state machine for the arm/consume lifecycle above, factored out of
 *  PiWebSession so "set → one turn → cleared" is unit-testable without a
 *  live session. `applySetSampling` is the set_sampling handler body;
 *  `consumeForRequest` is the before_provider_request handler body — both
 *  mutate and return a NEW state object (no hidden mutation) so tests can
 *  assert on each step's output directly. */
export interface SamplingScopeState {
  session: SamplingOverrides;
  nextTurn: SamplingOverrides | undefined;
}

export function initialSamplingScopeState(): SamplingScopeState {
  return { session: {}, nextTurn: undefined };
}

/** Apply a set_sampling message to scope state: scope "next_turn" arms the
 *  one-shot override (leaving `session` untouched); scope "session" or
 *  omitted replaces the session-level override (today's behavior). Pure. */
export function applySetSampling(
  state: SamplingScopeState,
  overrides: SamplingOverrides,
  scope: "session" | "next_turn" | undefined,
): SamplingScopeState {
  return scope === "next_turn"
    ? { session: state.session, nextTurn: overrides }
    : { session: overrides, nextTurn: state.nextTurn };
}

/** Compute the effective overrides for ONE outgoing provider request and
 *  return the post-consumption state (nextTurn always cleared, whether or
 *  not one was armed — consuming "nothing armed" is a no-op clear). Pure. */
export function consumeForRequest(
  state: SamplingScopeState,
): { effective: SamplingOverrides; nextState: SamplingScopeState } {
  return {
    effective: composeSampling(state.session, state.nextTurn),
    nextState: { session: state.session, nextTurn: undefined },
  };
}

/**
 * Layer the user's custom system prompt onto (not replacing) the built-in
 * surface prompt for one turn. Called from the `before_agent_start` hook
 * body with `event.systemPrompt` (the fully-assembled base: identity +
 * memoryHint) and the connection's stored override. Returns undefined when
 * there's nothing to layer (null/empty override), so the hook can leave
 * pi's base prompt alone — mirrors injectAdapter/injectSampling's "undefined
 * means unchanged" contract. Pure + exported for unit testing.
 */
export function injectSystemPrompt(base: string, custom: string | null | undefined): string | undefined {
  const trimmed = custom?.trim();
  if (!trimmed) return undefined;
  return `${base}\n\n---\n\nThe user has set a custom instruction for this chat. Follow it alongside (not instead of) the guidance above:\n\n${trimmed}`;
}

/**
 * Apply the browser's edited tool arguments onto pi's mutable
 * ToolCallEvent.input IN PLACE, per the SDK's documented tool_call
 * mutation contract (installApprovalGate's own doc comment quotes it: no
 * return-value channel exists for modified args). A no-op when
 * `editedArgs` is undefined (the common "approved as proposed" case).
 * Replaces the input's keys wholesale (delete-then-assign) rather than a
 * shallow merge, so a key the user removed from the textarea actually
 * disappears from the call instead of lingering from the original
 * proposal. Pure enough to unit test the mutation shape without a live
 * ExtensionAPI/ToolCallEvent — takes any mutable record, not the SDK type.
 */
export function applyEditedArgs(input: Record<string, unknown>, editedArgs: Record<string, unknown> | undefined): void {
  if (!editedArgs) return;
  for (const key of Object.keys(input)) delete input[key];
  Object.assign(input, editedArgs);
}

// ---- App-aware assistant tools (plan §6.6, §9 Phase 3, beat matrix ----
// Axis 12): get_current_app_context / navigate_app / spotlight_ui.
//
// Same shape as PortfolioManager's createPortfolioTools(getAppContext,
// clientId, notify) — the reference implementation this ports (read in
// full: server/src/agent/portfolio-tools.ts). Built here (not in
// pi-session.ts's shared buildPiAgentSurface) because these three tools are
// PER-CONNECTION: they close over this session's currentAppContext getter
// and its `notify` (send) function, whereas buildPiAgentSurface's tools are
// stateless singletons shared across every session. Read-only/navigate
// class (no approval gate, see APP_AWARE_TOOL_NAMES above): navigation and
// spotlighting are reversible UI actions, not machine mutations — exactly
// the same "auto-allow" reasoning READ_ONLY_TOOLS already applies to
// memory/web tools. approval-gated ui_act (fill a form, start a job) is
// explicitly Phase 5 per §6.6's scope guard, not implemented here.

function appAwareTextResult(text: string, details: unknown = {}): { content: [{ type: "text"; text: string }]; details: unknown } {
  return { content: [{ type: "text", text }], details };
}

/** Build the three app-aware tools for one connection. `getContext` reads
 *  the connection's currentAppContext (last `context` ClientMessage, or
 *  null before the first one arrives); `notify` sends a ServerMessage
 *  (ui_navigate/ui_spotlight) to that same browser tab. Pure enough to
 *  unit test the tool -> frame mapping via a fake notify collecting sent
 *  frames (tests/pi-web.test.ts). */
export function createAppAwareTools(
  getContext: () => AppUiContext | null,
  notify: (msg: ServerMessage) => void,
): ToolDefinition[] {
  const getCurrentAppContext = defineTool({
    name: "get_current_app_context",
    label: "Get Current App Context",
    description:
      "Returns the current web-app UI context: route, view, wizard step (if on one), and a uiSnapshot of visible interactive elements (ref, label, selector, spotlightId). Call this before spotlight_ui to pick the correct ref, label, or target — do not guess selectors blind.",
    parameters: Type.Object({}),
    execute: async () => {
      const ctx = getContext();
      if (!ctx) {
        return appAwareTextResult(
          "No app context received yet — the browser hasn't reported its current view. Ask the user what page they're on, or proceed without UI tools.",
        );
      }
      return appAwareTextResult(JSON.stringify(ctx, null, 2), { context: ctx });
    },
  });

  const navigateApp = defineTool({
    name: "navigate_app",
    label: "Navigate App",
    description:
      "Navigate the user's browser to a different page in the app. Use when they ask to be taken somewhere (e.g. \"take me to Quantize\", \"open the fine-tune wizard\"). Pass route or page as one of: chat, quantize, finetune, dataset, status (or \"#/quantize\"-style). Reversible and never needs approval. Does not highlight a specific control — use spotlight_ui separately for that.",
    parameters: Type.Object({
      route: Type.Optional(Type.String({ description: "chat | quantize | finetune | dataset | status (or #/quantize)" })),
      page: Type.Optional(Type.String({ description: "Same as route — alternate param name" })),
    }),
    execute: async (_id, params) => {
      const resolved = resolveAppRoute(params.route ?? params.page ?? "");
      if (!resolved) {
        return {
          ...appAwareTextResult(`Unknown route. Valid routes: ${APP_ROUTE_IDS.join(", ")}.`),
          isError: true,
        };
      }
      notify({ type: "ui_navigate", route: resolved });
      return appAwareTextResult(
        `Navigating the user to ${resolved}. They can see the page now — use spotlight_ui if you need to point at a specific control.`,
        { route: resolved },
      );
    },
  });

  const spotlightUi = defineTool({
    name: "spotlight_ui",
    label: "Spotlight UI",
    description:
      "Highlight a visible UI control with a brief, auto-dismissing spotlight (never blocks the user — they can keep working through it). Call get_current_app_context first and prefer ref from its uiSnapshot.elements; or pass label (visible text, e.g. \"Source model\"); or selector; or target (a curated catalog id, e.g. hub-browse, quantize-source). Optional route navigates there first. Optional message is a short hint shown in the popover.",
    parameters: Type.Object({
      ref: Type.Optional(Type.String({ description: "Element ref from uiSnapshot.elements[].ref (preferred)" })),
      label: Type.Optional(Type.String({ description: "Visible label/text to match, e.g. Source model, New chat" })),
      selector: Type.Optional(Type.String({ description: "CSS selector, when ref/label are unknown" })),
      target: Type.Optional(Type.String({ description: "Curated catalog id, e.g. hub-browse, quantize-source, sampling-pill" })),
      route: Type.Optional(Type.String({ description: "Navigate to this route first (chat, quantize, finetune, dataset, status)" })),
      message: Type.Optional(Type.String({ description: "Short hint shown in the spotlight popover" })),
    }),
    execute: async (_id, params) => {
      const hasLocator = !!params.ref?.trim() || !!params.label?.trim() || !!params.selector?.trim() || !!params.target?.trim();
      if (!hasLocator) {
        return { ...appAwareTextResult("Provide at least one of: ref (from uiSnapshot), label, selector, or target."), isError: true };
      }
      let route: AppRouteId | undefined;
      if (params.route) {
        route = resolveAppRoute(params.route) ?? undefined;
        if (!route) {
          return { ...appAwareTextResult(`Unknown route "${params.route}". Valid routes: ${APP_ROUTE_IDS.join(", ")}.`), isError: true };
        }
      }
      notify({
        type: "ui_spotlight",
        ref: params.ref, label: params.label, selector: params.selector, target: params.target,
        route, message: params.message,
      });
      const desc = params.ref ?? params.label ?? params.selector ?? params.target ?? "element";
      return appAwareTextResult(
        `Highlighting ${desc}${params.message ? `: ${params.message}` : ""}. The spotlight fades on its own in a few seconds.`,
        { ...params, route },
      );
    },
  });

  return [getCurrentAppContext, navigateApp, spotlightUi];
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
  /** Session-level + one-shot-next-turn sampling overrides for this
   *  connection (set via set_sampling; scope "session"/omitted mutates
   *  .session, scope "next_turn" arms .nextTurn). Read and consumed by
   *  the before_provider_request hook via consumeForRequest — see the
   *  "Per-message sampling scope" block comment above composeSampling for
   *  the full lifecycle. Wrapped in SamplingScopeState (not two loose
   *  fields) so the exact same applySetSampling/consumeForRequest pure
   *  functions run here and in tests/pi-web.test.ts. */
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
  private readonly cwd = process.cwd();
  private readonly agentDir = join(homedir(), ".mlx-bun", "pi-sessions");
  /** Where web-chat session files live (pi's own JSONL format). Shared by
   *  create/continueRecent/open/fork/list/delete so they all see one set.
   *  This is the durable transcript store the nightly memory pipeline reads. */
  private readonly sessionDir = join(homedir(), ".mlx-bun", "sessions");

  /** callId -> resolve(decision). Pending browser approvals in flight. */
  private readonly pendingApprovals = new Map<string, (decision: ApprovalDecision, editedArgs?: Record<string, unknown>, alwaysAllow?: boolean) => void>();
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

      // Welcome-assistant tool surface: exactly two read-only tools —
      // `web_search` (current/external facts) and `read` (a local file the user
      // points to) — UNLESS the user opted into codingTools (settings toggle,
      // default OFF), in which case bash/edit/write/grep/find/ls join the
      // allowlist too. We deliberately do NOT expose web_fetch/weather: a 1B
      // model over-calls a big toolset. With thinking ON (the web chat
      // default) it uses these appropriately; build the web tools (for the
      // web_search definition) then restrict the allowlist below.
      //
      // codingTools:false here is NOT the coding-tools gate (that lives in
      // webChatToolAllowlist below, which is the array pi actually receives
      // as `tools:` — see the comment at that call site). buildPiAgentSurface's
      // own codingTools flag only affects surface.tools, which pi-web.ts never
      // reads; kept false so surface.tools (unused here) doesn't silently
      // imply a wider allowlist than webChatToolAllowlist actually grants.
      const surface = await buildPiAgentSurface({ webTools: true, codingTools: false });
      // Snapshot what THIS session is actually being built with — read fresh
      // here (not at set_coding_tools time) so `coding_tools`'s `active`
      // field is always true reality, never a stale request.
      this.codingToolsActive = this.codingToolsRequested;
      const webPrompt = buildWebChatSystemPrompt(this.opts.readOnly, {
        modelId: this.opts.modelId,
        downloadingModel: downloadsSnapshot().find(
          (d) => d.state === "active" && d.repoId !== this.opts.modelId,
        )?.repoId ?? null,
      }, { hasTools: WELCOME_TOOLS.length > 0 }) + surface.memoryHint;
      if (process.env.MLX_BUN_PI_DEBUG) {
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
            (pi) => this.installApprovalGate(pi),
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
          tools: webChatToolAllowlist(surface.memoryEnabled, this.codingToolsActive && !this.opts.readOnly),
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

  /** Start a fresh chat (old one stays on disk, resumable from the sidebar).
   *  Re-invokes createRuntimeFactory (either directly via replaceRuntime, or
   *  through AgentSessionRuntime.newSession()'s own internal call to the
   *  SAME factory) — so this is the earliest point a codingTools toggle
   *  flipped mid-session actually takes effect (see set_coding_tools). */
  private async newSession(): Promise<void> {
    if (!this.runtime) {
      await this.replaceRuntime(SessionManager.create(this.cwd, this.sessionDir));
    } else {
      await this.runtime.newSession();
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
    else await this.runtime.switchSession(path);
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
      if (block && process.env.MLX_BUN_PI_DEBUG) {
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

  private installApprovalGate(pi: ExtensionAPI): void {
    pi.on("tool_call", async (event: ToolCallEvent) => {
      const tool = event.toolName;
      if (process.env.MLX_BUN_PI_DEBUG) {
        console.error(`[pi-web] tool_call ${tool} args=${JSON.stringify(event.input)}`);
      }

      // Read-only tools never need approval.
      if (READ_ONLY_TOOLS.has(tool)) return undefined;

      // Anything mutating is denied outright in read-only mode — before the
      // durable always-allow list is even consulted, since --read-only is a
      // server operator's hard constraint, not a per-tool user preference.
      if (this.opts.readOnly && GATED_TOOLS.has(tool)) {
        return { block: true, reason: "Read-only session: mutating tools are disabled." };
      }

      // Non-gated, non-read-only tools (shouldn't happen with the shared pi
      // surface, but be safe): allow.
      if (!GATED_TOOLS.has(tool)) return undefined;

      // Durable "always allow this tool" (risk #6): a prior approval card on
      // THIS machine checked the box, persisting to ~/.mlx-bun/tool-
      // approvals.json (src/tool-approvals.ts). Skip the round-trip entirely
      // — no card, no wait, matching every session and every browser tab.
      if (isToolAlwaysAllowed(tool)) return undefined;

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
        setToolAlwaysAllowed(tool);
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
    this.send({ type: "tool_approvals", alwaysAllow: listAlwaysAllowedTools() });
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
        if (process.env.MLX_BUN_PI_DEBUG) {
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
