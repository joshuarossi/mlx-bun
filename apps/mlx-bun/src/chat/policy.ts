import { createHash } from "node:crypto";
import { APP_ROUTE_IDS } from "./protocol";
import type { AppRouteId, AppUiContext, SamplingOverrides } from "./protocol";
import { PI_LOCAL_MODEL_ID } from "./provider";
import { WEB_TOOL_NAMES } from "./web-tools";

export const APP_AWARE_TOOL_NAMES = ["get_current_app_context", "navigate_app", "spotlight_ui"] as const;
export const READ_ONLY_TOOLS = new Set(["read", "grep", "find", "ls", ...WEB_TOOL_NAMES, ...APP_AWARE_TOOL_NAMES]);
/** Tools that require explicit per-call browser approval. */
export const GATED_TOOLS = new Set(["bash", "edit", "write"]);

/** Built-in mutation names cannot be reclassified by an injected surface.
 * Unknown tools require approval rather than inheriting read-only privileges. */
export function toolApprovalClass(tool: string, injectedReadOnly: ReadonlySet<string>): "read-only" | "approval" {
  if (GATED_TOOLS.has(tool)) return "approval";
  return READ_ONLY_TOOLS.has(tool) || injectedReadOnly.has(tool) ? "read-only" : "approval";
}


/**
 * The welcome assistant's tool allowlist: exactly `read` (a local file the user
 * points to) and `web_search` (current/external facts). Both are in
 * READ_ONLY_TOOLS, so neither triggers the approval gate. Kept to two because a
 * 1B model over-calls a larger toolset; widen this list (not the system prompt)
 * to grant more.
 */
export const WELCOME_TOOLS = ["read", "web_search"] as const;

/** The session exposes welcome/app tools and any injected read-only memory tools.
 * Coding tools are opt-in; the caller also applies the server's read-only setting. */
export function webChatToolAllowlist(memoryToolNames: readonly string[] = [], codingTools = false): string[] {
  return [
    ...WELCOME_TOOLS,
    ...APP_AWARE_TOOL_NAMES,
    ...memoryToolNames,
    ...(codingTools ? ["grep", "find", "ls", ...GATED_TOOLS] : []),
  ];
}

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

/** Stable key for deduplication and retry accounting, independent of object key order. */
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

/** Validate assistant navigation against the shared browser/server route IDs. */
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
