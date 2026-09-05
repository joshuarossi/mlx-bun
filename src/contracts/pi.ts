/** Shared browser/server protocol. Data only; no SDK, DOM, or native imports. */
export type Lane = "serial" | "serial+spec" | "batched";
export const APP_ROUTE_IDS = ["chat", "quantize", "finetune", "dataset", "status"] as const;

export type ApprovalDecision = "allow" | "deny";

export interface ImageAttachment {
  data: string;
  mimeType: string;
}

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

export interface WizardStep {
  index: number;
  count: number;
  label: string;
}

export interface AppUiContext {
  route: string;
  view?: string;
  step?: WizardStep;
  snapshot: UiSnapshot;
}

export type AppRouteId = (typeof APP_ROUTE_IDS)[number];

export interface ReadyGenDefaults {
  temperature: number | null;
  topP: number | null;
  topK: number | null;
}

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

export interface HistoryToolItem {
  callId: string;
  name: string;
  args: unknown;
  /** Tool result text, filled from the matching toolResult message. */
  result: string;
}

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

export interface SessionListItem {
  path: string;
  id: string;
  title: string;
  /** Last-modified epoch ms (newest first). */
  modified: number;
  messageCount: number;
  forked: boolean;
}

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
