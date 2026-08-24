// Phase 16 (web half): pure event-mapping for src/pi-web.ts. Tests only
// mapEventToFrames — the side-effect-free translator from pi
// AgentSessionEvents to the browser WS protocol. No live AgentSession,
// no server, no model (those run in integration once routes are wired).

import { beforeEach, describe, expect, it } from "bun:test";
import type { AgentSessionEvent, SessionEntry, SessionInfo } from "@earendil-works/pi-coding-agent";
import {
  ambientContextLine,
  APP_AWARE_TOOL_NAMES,
  APP_ROUTE_IDS,
  applyEditedArgs,
  applySetSampling,
  buildWebChatSystemPrompt,
  composeSampling,
  consumeForRequest,
  createAppAwareTools,
  decideBeforeToolCall,
  deepestLeafFrom,
  findLastUserMessageEntry,
  initialLoopHygieneState,
  initialSamplingScopeState,
  injectAdapter,
  injectSampling,
  injectSystemPrompt,
  isAppRouteId,
  LOOP_HYGIENE,
  mapEventToFrames,
  recordToolCallOutcome,
  resolveAppRoute,
  serializeHistory,
  toolCallSignature,
  toolResultText,
  toSessionListItems,
  userMessageSiblings,
  webChatToolAllowlist,
  type AppUiContext,
  type ServerMessage,
} from "../../src/pi-web";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../../src/memory/tools";
import { clearLaneRegistry, recordLane } from "../../src/serve/lane-registry";
import { parseAdapterSpec } from "../../src/lora";

// Cast helper: the real AgentSessionEvent union is large; we only build
// the fields mapEventToFrames reads, so narrow via `as`.
const ev = (e: unknown) => e as AgentSessionEvent;

describe("injectAdapter (before_provider_request hook body)", () => {
  it("returns undefined when nothing is selected → Pi keeps the payload (base model)", () => {
    expect(injectAdapter({ model: "x", messages: [] }, null)).toBeUndefined();
    expect(injectAdapter({ model: "x" }, "")).toBeUndefined();
  });

  it("injects the adapter field when one is selected, preserving the rest", () => {
    const out = injectAdapter({ model: "x", messages: [{ role: "user" }], temperature: 0 }, "chunk");
    expect(out).toEqual({ model: "x", messages: [{ role: "user" }], temperature: 0, adapter: "chunk" });
  });

  it("overrides a stale adapter field with the current selection", () => {
    expect(injectAdapter({ model: "x", adapter: "old" }, "new")).toEqual({ model: "x", adapter: "new" });
  });

  it("does not mutate the input payload", () => {
    const p: Record<string, unknown> = { model: "x" };
    injectAdapter(p, "chunk");
    expect(p).toEqual({ model: "x" });
  });

  // Adapter routing table (plan §5.6/§9 Phase 2): the table's "stack a+b"
  // action sends `{ type: "set_adapter", id: "a+b" }` — the same frame shape
  // as a single-select, since `set_adapter`'s `id` is already `string | null`
  // with no format restriction. This proves the composite id survives
  // injectAdapter verbatim onto the wire (the pi-web half of the chain) and
  // that src/lora.ts's own parser (parseAdapterSpec — the first step of
  // AdapterManager.resolveSpec, the server-side half) splits it back into
  // the two ids in order. resolveSpec itself additionally requires both ids
  // to already be mounted (real, shape-validated adapter weights against a
  // real base model) before it accepts the spec — that full HTTP round-trip
  // is what tests/lora.test.ts's "per-request selection over HTTP" test
  // exercises (MLX_BUN_TEST_LORA=1-gated, needs e4b weights). Together these
  // two tests are the end-to-end proof with no untested link in between:
  // nothing in the set_adapter frame, injectAdapter, or parseAdapterSpec
  // rejects or mangles a composite id.
  it("stacking: a composite 'a+b' selection is injected as one wire field and parses back to both ids in order", () => {
    const out = injectAdapter({ model: "x", messages: [] }, "sft+dpo");
    expect(out).toEqual({ model: "x", messages: [], adapter: "sft+dpo" });
    expect(parseAdapterSpec((out as { adapter: string }).adapter)).toEqual(["sft", "dpo"]);
  });
});

describe("injectSampling (before_provider_request hook body)", () => {
  it("returns undefined when nothing is overridden → server uses mode-aware defaults", () => {
    expect(injectSampling({ model: "x" }, undefined)).toBeUndefined();
    expect(injectSampling({ model: "x" }, {})).toBeUndefined();
    expect(injectSampling({ model: "x" }, { temperature: null, top_p: null, top_k: null })).toBeUndefined();
  });

  it("injects only the set numeric fields, preserving the rest", () => {
    const out = injectSampling({ model: "x", messages: [] }, { temperature: 0.3, top_p: null, top_k: 40 });
    expect(out).toEqual({ model: "x", messages: [], temperature: 0.3, top_k: 40 });
  });

  it("treats explicit 0 as a real override (not a falsy skip)", () => {
    expect(injectSampling({ model: "x" }, { temperature: 0 })).toEqual({ model: "x", temperature: 0 });
  });

  it("ignores non-finite values", () => {
    expect(injectSampling({ model: "x" }, { temperature: NaN, top_p: Infinity })).toBeUndefined();
  });

  it("does not mutate the input payload", () => {
    const p: Record<string, unknown> = { model: "x" };
    injectSampling(p, { temperature: 0.5 });
    expect(p).toEqual({ model: "x" });
  });

  // web-ui-pass-plan.md #8: the full mlx_lm.server sampler extension set, not
  // just temperature/top_p/top_k.
  it("injects every extended sampling field (min_p/XTC/penalties/seed)", () => {
    const out = injectSampling(
      { model: "x" },
      {
        min_p: 0.05,
        xtc_probability: 0.5,
        xtc_threshold: 0.1,
        repetition_penalty: 1.1,
        repetition_context_size: 40,
        presence_penalty: 0.2,
        frequency_penalty: 0.3,
        seed: 1234,
      },
    );
    expect(out).toEqual({
      model: "x",
      min_p: 0.05,
      xtc_probability: 0.5,
      xtc_threshold: 0.1,
      repetition_penalty: 1.1,
      repetition_context_size: 40,
      presence_penalty: 0.2,
      frequency_penalty: 0.3,
      seed: 1234,
    });
  });

  it("treats null on any extended field as clearing that override (not injected)", () => {
    expect(
      injectSampling(
        { model: "x" },
        {
          min_p: null, xtc_probability: null, xtc_threshold: null,
          repetition_penalty: null, repetition_context_size: null,
          presence_penalty: null, frequency_penalty: null, seed: null,
        },
      ),
    ).toBeUndefined();
  });

  it("mixes base and extended fields independently", () => {
    const out = injectSampling(
      { model: "x" },
      { temperature: null, top_p: 0.9, min_p: 0.05, seed: null },
    );
    expect(out).toEqual({ model: "x", top_p: 0.9, min_p: 0.05 });
  });

  it("treats explicit 0 on an extended field as a real override", () => {
    expect(injectSampling({ model: "x" }, { repetition_penalty: 0, seed: 0 })).toEqual({
      model: "x", repetition_penalty: 0, seed: 0,
    });
  });
});

// Per-message sampling scope (plan §9 Phase 3, beat matrix Axis 4): the
// next_turn one-shot override composed OVER the session-level overrides,
// consumed after exactly one outgoing provider request. See the "Per-
// message sampling scope" block comment above composeSampling in
// src/pi-web.ts for the full design and lifecycle rationale.
describe("composeSampling (next_turn OVER session precedence)", () => {
  it("returns session unchanged when no next_turn override is armed", () => {
    const session = { temperature: 0.7, top_p: 0.9 };
    expect(composeSampling(session, undefined)).toBe(session);
  });

  it("next_turn's set fields win over session's for the same field", () => {
    const session = { temperature: 0.7, top_p: 0.9, seed: 1 };
    const nextTurn = { temperature: 1.2 };
    expect(composeSampling(session, nextTurn)).toEqual({ temperature: 1.2, top_p: 0.9, seed: 1 });
  });

  it("fields next_turn leaves null/unset fall back to session's value", () => {
    const session = { temperature: 0.7, min_p: 0.05 };
    const nextTurn = { temperature: null, min_p: undefined, top_k: null };
    expect(composeSampling(session, nextTurn)).toEqual({ temperature: 0.7, min_p: 0.05 });
  });

  it("next_turn can introduce a field session never set", () => {
    const session = { temperature: 0.7 };
    const nextTurn = { seed: 42 };
    expect(composeSampling(session, nextTurn)).toEqual({ temperature: 0.7, seed: 42 });
  });

  it("an empty next_turn override composes to exactly the session values", () => {
    const session = { temperature: 0.7, top_p: 0.9 };
    expect(composeSampling(session, {})).toEqual(session);
  });
});

describe("sampling scope lifecycle: set -> one turn -> cleared", () => {
  it("scope omitted/'session' sets the session-level override; nextTurn starts unarmed", () => {
    let state = initialSamplingScopeState();
    expect(state.nextTurn).toBeUndefined();
    state = applySetSampling(state, { temperature: 0.5 }, undefined);
    expect(state).toEqual({ session: { temperature: 0.5 }, nextTurn: undefined });
    state = applySetSampling(state, { temperature: 0.8 }, "session");
    expect(state).toEqual({ session: { temperature: 0.8 }, nextTurn: undefined });
  });

  it("scope 'next_turn' arms the one-shot override WITHOUT touching the session value", () => {
    let state = initialSamplingScopeState();
    state = applySetSampling(state, { temperature: 0.5 }, "session");
    state = applySetSampling(state, { temperature: 1.4, seed: 99 }, "next_turn");
    expect(state.session).toEqual({ temperature: 0.5 });
    expect(state.nextTurn).toEqual({ temperature: 1.4, seed: 99 });
  });

  it("consumeForRequest composes next_turn over session for exactly one request, then clears it", () => {
    let state = initialSamplingScopeState();
    state = applySetSampling(state, { temperature: 0.5, top_p: 0.9 }, "session");
    state = applySetSampling(state, { temperature: 1.4 }, "next_turn");

    // Turn 1 (the very next outgoing provider request): composed override applies.
    const turn1 = consumeForRequest(state);
    expect(turn1.effective).toEqual({ temperature: 1.4, top_p: 0.9 });
    state = turn1.nextState;
    expect(state.nextTurn).toBeUndefined();

    // Turn 2 (e.g. a subsequent tool-loop turn of the SAME prompt, or the
    // next user message entirely): the one-shot is gone, only session
    // remains.
    const turn2 = consumeForRequest(state);
    expect(turn2.effective).toEqual({ temperature: 0.5, top_p: 0.9 });
  });

  it("a plain session-scope set_sampling sent right after arming next_turn does not retroactively clear it before consumption", () => {
    // Order matters: arm next_turn, THEN update session — the composed
    // request should still prefer next_turn's value for the overlapping
    // field, and session's NEW value for the field next_turn didn't set.
    let state = initialSamplingScopeState();
    state = applySetSampling(state, { temperature: 0.5 }, "session");
    state = applySetSampling(state, { temperature: 1.4 }, "next_turn");
    state = applySetSampling(state, { temperature: 0.5, top_k: 40 }, "session");
    const { effective, nextState } = consumeForRequest(state);
    expect(effective).toEqual({ temperature: 1.4, top_k: 40 });
    expect(nextState.nextTurn).toBeUndefined();
    expect(nextState.session).toEqual({ temperature: 0.5, top_k: 40 });
  });

  it("consuming with nothing armed is a harmless no-op clear", () => {
    const state = { session: { temperature: 0.5 }, nextTurn: undefined };
    const { effective, nextState } = consumeForRequest(state);
    expect(effective).toEqual({ temperature: 0.5 });
    expect(nextState).toEqual({ session: { temperature: 0.5 }, nextTurn: undefined });
  });
});

// Loop hygiene (plan §9 Phase 3, beat matrix Axis 7): dedup, retry budget,
// tool-turn cap. Pure decision functions extracted from the tool_call /
// tool_result / turn_start extension hooks (installLoopHygieneHooks in
// src/pi-web.ts) so they're testable without a live AgentSession.
describe("loop hygiene: decideBeforeToolCall / recordToolCallOutcome", () => {
  it("toolCallSignature is stable across argument key order", () => {
    expect(toolCallSignature("read", { path: "a", limit: 10 }))
      .toBe(toolCallSignature("read", { limit: 10, path: "a" }));
  });

  it("toolCallSignature differs for different tool names or argument values", () => {
    expect(toolCallSignature("read", { path: "a" })).not.toBe(toolCallSignature("read", { path: "b" }));
    expect(toolCallSignature("read", { path: "a" })).not.toBe(toolCallSignature("grep", { path: "a" }));
  });

  it("allows a call through when under the turn cap and nothing to dedup", () => {
    const state = initialLoopHygieneState();
    expect(decideBeforeToolCall(state, "read", { path: "a" })).toBeUndefined();
  });

  it("blocks a call once the turn cap is reached, regardless of what's being called", () => {
    const state = initialLoopHygieneState();
    state.turnIndex = LOOP_HYGIENE.MAX_TOOL_TURNS;
    const block = decideBeforeToolCall(state, "read", { path: "a" });
    expect(block).toBeDefined();
    expect(block!.reason).toMatch(/tool-turn limit/i);
  });

  it("blocks an exact repeat of the last successful call (dedup) and surfaces its cached result", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "read", { path: "a" }, { isError: false, resultText: "file contents" });
    const block = decideBeforeToolCall(state, "read", { path: "a" });
    expect(block).toBeDefined();
    expect(block!.reason).toContain("file contents");
  });

  it("does NOT dedup a call with different arguments even if the tool name matches", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "read", { path: "a" }, { isError: false, resultText: "file contents" });
    expect(decideBeforeToolCall(state, "read", { path: "b" })).toBeUndefined();
  });

  it("a NEW successful call replaces the dedup cache (only the LAST success is remembered)", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "read", { path: "a" }, { isError: false, resultText: "A" });
    recordToolCallOutcome(state, "read", { path: "b" }, { isError: false, resultText: "B" });
    // Repeating "a" is no longer deduped (it's not the LAST success).
    expect(decideBeforeToolCall(state, "read", { path: "a" })).toBeUndefined();
    // Repeating "b" IS deduped.
    const block = decideBeforeToolCall(state, "read", { path: "b" });
    expect(block?.reason).toContain("B");
  });

  it("does not nudge before the failure budget is reached", () => {
    const state = initialLoopHygieneState();
    const nudge1 = recordToolCallOutcome(state, "bash", { command: "false" }, { isError: true, resultText: "exit 1" });
    const nudge2 = recordToolCallOutcome(state, "bash", { command: "false" }, { isError: true, resultText: "exit 1" });
    expect(nudge1).toBeUndefined();
    expect(nudge2).toBeUndefined();
  });

  it("nudges once the consecutive-failure budget (3) is reached for the same call signature", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "bash", { command: "false" }, { isError: true, resultText: "exit 1" });
    recordToolCallOutcome(state, "bash", { command: "false" }, { isError: true, resultText: "exit 1" });
    const nudge = recordToolCallOutcome(state, "bash", { command: "false" }, { isError: true, resultText: "exit 1" });
    expect(nudge).toBeDefined();
    expect(nudge).toMatch(/failed 3 times/i);
  });

  it("a success resets the failure streak for that signature", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "bash", { command: "flaky" }, { isError: true, resultText: "exit 1" });
    recordToolCallOutcome(state, "bash", { command: "flaky" }, { isError: true, resultText: "exit 1" });
    recordToolCallOutcome(state, "bash", { command: "flaky" }, { isError: false, resultText: "ok" });
    // Streak reset — two more failures shouldn't trip the budget yet.
    recordToolCallOutcome(state, "bash", { command: "flaky" }, { isError: true, resultText: "exit 1" });
    const nudge = recordToolCallOutcome(state, "bash", { command: "flaky" }, { isError: true, resultText: "exit 1" });
    expect(nudge).toBeUndefined();
  });

  it("failure streaks are tracked independently per call signature", () => {
    const state = initialLoopHygieneState();
    recordToolCallOutcome(state, "bash", { command: "a" }, { isError: true, resultText: "x" });
    recordToolCallOutcome(state, "bash", { command: "a" }, { isError: true, resultText: "x" });
    // A different signature's failures don't contribute to "a"'s streak.
    recordToolCallOutcome(state, "bash", { command: "b" }, { isError: true, resultText: "x" });
    const nudge = recordToolCallOutcome(state, "bash", { command: "a" }, { isError: true, resultText: "x" });
    expect(nudge).toMatch(/failed 3 times/i);
  });
});

describe("toolResultText", () => {
  it("flattens TextContent[] to plain text", () => {
    expect(toolResultText([{ type: "text", text: "hello" }])).toBe("hello");
  });

  it("joins multiple text parts", () => {
    expect(toolResultText([{ type: "text", text: "a" }, { type: "text", text: "b" }])).toBe("ab");
  });

  it("passes through a plain string", () => {
    expect(toolResultText("already text")).toBe("already text");
  });

  it("ignores non-text parts (e.g. images) and returns empty for non-array/string", () => {
    expect(toolResultText([{ type: "image", data: "x" }])).toBe("");
    expect(toolResultText(undefined)).toBe("");
    expect(toolResultText(42)).toBe("");
  });
});

// Per-chat system prompt (plan §9 Phase 2, beat matrix Axis 4): the
// before_agent_start hook body. Layers the user's custom text onto (never
// replacing) the built-in surface prompt pi hands in as event.systemPrompt
// on every turn — see pi-web.ts's installSystemPromptHook.
describe("injectSystemPrompt (before_agent_start hook body)", () => {
  const base = "You are mlx-bun's built-in assistant.";

  it("returns undefined when no custom prompt is set → pi's base prompt is left alone", () => {
    expect(injectSystemPrompt(base, null)).toBeUndefined();
    expect(injectSystemPrompt(base, undefined)).toBeUndefined();
  });

  it("returns undefined for an empty or whitespace-only custom prompt (treated as cleared)", () => {
    expect(injectSystemPrompt(base, "")).toBeUndefined();
    expect(injectSystemPrompt(base, "   \n\t  ")).toBeUndefined();
  });

  it("layers the custom text ONTO the base prompt — never drops the built-in surface", () => {
    const out = injectSystemPrompt(base, "Answer only in French.");
    expect(out).toContain(base);
    expect(out).toContain("Answer only in French.");
    // The base prompt must appear before the custom text (layered on top,
    // not prepended-over — the built-in identity/tool guidance still leads).
    expect(out!.indexOf(base)).toBeLessThan(out!.indexOf("Answer only in French."));
  });

  it("trims surrounding whitespace from the custom prompt before layering", () => {
    const out = injectSystemPrompt(base, "  Be terse.  ");
    expect(out).toContain("Be terse.");
    expect(out).not.toContain("  Be terse.  ");
  });

  it("is layered as user-set, not confused with the base surface prompt", () => {
    const out = injectSystemPrompt(base, "Custom instruction here.");
    expect(out).toMatch(/user has set a custom instruction/i);
  });
});

describe("applyEditedArgs (approval-card editable-arguments mutation, plan §5.4/§6.5)", () => {
  it("is a no-op when nothing was edited (the common 'approved as proposed' case)", () => {
    const input = { command: "ls -la" };
    applyEditedArgs(input, undefined);
    expect(input).toEqual({ command: "ls -la" });
  });

  it("mutates the SAME object in place (pi's tool_call contract: mutate event.input, no return channel)", () => {
    const input: Record<string, unknown> = { command: "rm -rf /tmp/x" };
    const ref = input;
    applyEditedArgs(input, { command: "rm -rf /tmp/y" });
    expect(ref).toBe(input); // identity preserved — same object pi holds a reference to
    expect(input).toEqual({ command: "rm -rf /tmp/y" });
  });

  it("removes keys present in the original but absent from the edit (delete-then-assign, not a shallow merge)", () => {
    const input: Record<string, unknown> = { file_path: "/tmp/a.txt", content: "old", extra_stale_key: 1 };
    applyEditedArgs(input, { file_path: "/tmp/a.txt", content: "new" });
    expect(input).toEqual({ file_path: "/tmp/a.txt", content: "new" });
    expect("extra_stale_key" in input).toBe(false);
  });

  it("can add a key that wasn't in the original proposal", () => {
    const input: Record<string, unknown> = { command: "ls" };
    applyEditedArgs(input, { command: "ls", cwd: "/tmp" });
    expect(input).toEqual({ command: "ls", cwd: "/tmp" });
  });
});

describe("mapEventToFrames", () => {
  beforeEach(() => {
    clearLaneRegistry();
  });

  it("maps turn_start / turn_end to bare frames", () => {
    expect(mapEventToFrames(ev({ type: "turn_start" }))).toEqual([{ type: "turn_start" }]);
    expect(mapEventToFrames(ev({ type: "turn_end" }))).toEqual([{ type: "turn_end" }]);
  });

  it("surfaces a turn that ended in error (stopReason 'error') as an error frame, not a silent empty turn", () => {
    // The Qwen3.5/MiniCPM5 'no messages' bug: a 400'd model request completes the
    // turn with stopReason 'error' WITHOUT throwing, so the browser otherwise sees
    // nothing. The mapper must emit a visible error frame ahead of turn_end.
    const frames = mapEventToFrames(
      ev({ type: "turn_end", message: { stopReason: "error", errorMessage: "Unexpected message role." } }),
    );
    expect(frames).toEqual([
      { type: "error", message: "Unexpected message role." },
      { type: "turn_end" },
    ]);
  });

  it("falls back to a generic error message when errorMessage is absent", () => {
    const frames = mapEventToFrames(ev({ type: "turn_end", message: { stopReason: "error" } }));
    expect(frames).toEqual([
      { type: "error", message: "the model request failed" },
      { type: "turn_end" },
    ]);
  });

  // docs/design/web-chat-redesign.md §2.3 caveat / risk #5: the lane badge must
  // be server-driven, correlated via the lane registry keyed by the
  // AssistantMessage's responseId — never inferred client-side.
  describe("turn_end lane correlation (risk #5: server-driven, never guessed)", () => {
    it("attaches the recorded lane when the message's responseId is known to the registry", () => {
      recordLane("chatcmpl-abc123", "batched");
      const frames = mapEventToFrames(
        ev({ type: "turn_end", message: { responseId: "chatcmpl-abc123" } }),
      );
      expect(frames).toEqual([{ type: "turn_end", lane: "batched" }]);
    });

    it("omits lane when no responseId is present on the message (never guesses)", () => {
      const frames = mapEventToFrames(ev({ type: "turn_end", message: {} }));
      expect(frames).toEqual([{ type: "turn_end" }]);
    });

    it("omits lane when the responseId is present but unknown to the registry", () => {
      const frames = mapEventToFrames(
        ev({ type: "turn_end", message: { responseId: "chatcmpl-never-recorded" } }),
      );
      expect(frames).toEqual([{ type: "turn_end" }]);
    });

    it("carries the lane alongside the error frame on an errored turn", () => {
      recordLane("chatcmpl-err1", "serial+spec");
      const frames = mapEventToFrames(
        ev({
          type: "turn_end",
          message: { stopReason: "error", errorMessage: "boom", responseId: "chatcmpl-err1" },
        }),
      );
      expect(frames).toEqual([
        { type: "error", message: "boom" },
        { type: "turn_end", lane: "serial+spec" },
      ]);
    });

    it("distinguishes serial / serial+spec / batched lanes by id", () => {
      recordLane("a", "serial");
      recordLane("b", "serial+spec");
      recordLane("c", "batched");
      expect(mapEventToFrames(ev({ type: "turn_end", message: { responseId: "a" } })))
        .toEqual([{ type: "turn_end", lane: "serial" }]);
      expect(mapEventToFrames(ev({ type: "turn_end", message: { responseId: "b" } })))
        .toEqual([{ type: "turn_end", lane: "serial+spec" }]);
      expect(mapEventToFrames(ev({ type: "turn_end", message: { responseId: "c" } })))
        .toEqual([{ type: "turn_end", lane: "batched" }]);
    });
  });

  it("maps text_delta assistant events to text_delta frames", () => {
    const frames = mapEventToFrames(
      ev({ type: "message_update", assistantMessageEvent: { type: "text_delta", delta: "hi" } }),
    );
    expect(frames).toEqual([{ type: "text_delta", delta: "hi" }]);
  });

  it("maps thinking_delta to separate thinking_delta frames", () => {
    const frames = mapEventToFrames(
      ev({ type: "message_update", assistantMessageEvent: { type: "thinking_delta", delta: "hmm" } }),
    );
    expect(frames).toEqual([{ type: "thinking_delta", delta: "hmm" }]);
  });

  it("ignores non-delta assistant message events", () => {
    const frames = mapEventToFrames(
      ev({ type: "message_update", assistantMessageEvent: { type: "toolcall_delta", delta: "{" } }),
    );
    expect(frames).toEqual([]);
  });

  it("maps tool_execution_start to tool_start", () => {
    const frames = mapEventToFrames(
      ev({ type: "tool_execution_start", toolCallId: "c1", toolName: "bash", args: { command: "ls" } }),
    );
    expect(frames).toEqual([
      { type: "tool_start", callId: "c1", tool: "bash", args: { command: "ls" } },
    ]);
  });

  it("maps tool_execution_update to tool_update", () => {
    const frames = mapEventToFrames(
      ev({ type: "tool_execution_update", toolCallId: "c1", toolName: "bash", args: {}, partialResult: "line" }),
    );
    expect(frames).toEqual([{ type: "tool_update", callId: "c1", chunk: "line" }]);
  });

  it("maps tool_execution_end to tool_end with ok = !isError", () => {
    expect(
      mapEventToFrames(
        ev({ type: "tool_execution_end", toolCallId: "c1", toolName: "bash", result: "done", isError: false }),
      ),
    ).toEqual([{ type: "tool_end", callId: "c1", ok: true, result: "done" }]);

    expect(
      mapEventToFrames(
        ev({ type: "tool_execution_end", toolCallId: "c2", toolName: "edit", result: "boom", isError: true }),
      ),
    ).toEqual([{ type: "tool_end", callId: "c2", ok: false, result: "boom" }]);
  });

  it("maps queue_update with steering and followUp arrays", () => {
    const frames = mapEventToFrames(
      ev({ type: "queue_update", steering: ["a"], followUp: ["b", "c"] }),
    );
    expect(frames).toEqual([{ type: "queue_update", steering: ["a"], followUp: ["b", "c"] }]);
  });

  it("returns [] for events with no browser representation", () => {
    expect(mapEventToFrames(ev({ type: "agent_start" }))).toEqual([]);
    expect(mapEventToFrames(ev({ type: "message_start", message: {} }))).toEqual([]);
    expect(mapEventToFrames(ev({ type: "model_select", model: {}, previousModel: undefined, source: "set" }))).toEqual([]);
  });
});

describe("buildWebChatSystemPrompt", () => {
  it("frames a local mlx-bun assistant (not pi's coding-agent default)", () => {
    const prompt = buildWebChatSystemPrompt(false);
    expect(prompt).toContain("mlx-bun");
    expect(prompt).toMatch(/locally|local machine|own .*Mac/i);
    // Must NOT carry over pi's default framing or internal-doc noise.
    expect(prompt).not.toMatch(/operating inside pi/i);
    expect(prompt).not.toMatch(/pi documentation/i);
  });

  it("stays concise and directs the model to answer, not greet (the small-model fix)", () => {
    const prompt = buildWebChatSystemPrompt(false);
    // The bloated welcome prompt was ~2.5k chars and drowned a 1B model; the
    // welcome blurb + tool guidance (now including the app-aware assistant's
    // one-line steer, plan §6.6) keeps it well under that — budget bumped
    // from 1300 to 1700 for the new capability line, still <70% of the
    // original bloated prompt.
    expect(prompt.length).toBeLessThan(1700);
    expect(prompt).toMatch(/answer directly/i);
    // Explicitly counteract the "Hello! How can I assist you today?" failure.
    expect(prompt).toMatch(/don'?t open with a (generic )?greeting|just answer/i);
  });

  it("carries a short mlx-bun blurb so it can answer product questions from knowledge", () => {
    const prompt = buildWebChatSystemPrompt(false);
    expect(prompt).toMatch(/mlx-bun serve/i);
    expect(prompt).toMatch(/answer questions about mlx-bun directly/i);
  });

  it("names ONLY the two welcome tools (read + web_search), not the wider toolset", () => {
    const prompt = buildWebChatSystemPrompt(false);
    expect(prompt).toContain("web_search");
    expect(prompt).toContain("read");
    // The tools we deliberately don't expose must not be named.
    expect(prompt).not.toContain("web_fetch");
    expect(prompt).not.toContain("weather");
    for (const tool of ["grep", "find", "ls", "bash", "edit", "write"]) {
      expect(prompt).not.toMatch(new RegExp(`\\b${tool}\\b`));
    }
  });

  it("tells the model it has NO tools when none are wired (no false tool promises)", () => {
    const prompt = buildWebChatSystemPrompt(false, undefined, { hasTools: false });
    expect(prompt).toMatch(/no tools in this session|answer from your own knowledge/i);
    expect(prompt).not.toMatch(/web_search/);
  });

  it("names the served model when one is provided", () => {
    const prompt = buildWebChatSystemPrompt(false, { modelId: "cpm5" });
    expect(prompt).toContain("cpm5");
  });
});

describe("webChatToolAllowlist", () => {
  it("is exactly the two welcome tools plus the app-aware tools when memory is off", () => {
    // App-aware assistant (plan §6.6): get_current_app_context/navigate_app/
    // spotlight_ui ride along unconditionally, same as WELCOME_TOOLS — they
    // never mutate the machine, so they're never gated behind memory or
    // codingTools state.
    expect(webChatToolAllowlist(false)).toEqual([
      "read", "web_search", "get_current_app_context", "navigate_app", "spotlight_ui",
    ]);
  });

  it("includes every memory + reference tool when memory is enabled", () => {
    // The surface's memoryHint and the bundled memory skill instruct the
    // model to call these; pi treats `tools` as an allowlist, so leaving
    // them out made every memory call fail in the web chat.
    const allow = webChatToolAllowlist(true);
    expect(allow).toContain("read");
    expect(allow).toContain("web_search");
    for (const t of MEMORY_TOOL_NAMES) expect(allow).toContain(t);
    for (const t of REFERENCE_TOOL_NAMES) expect(allow).toContain(t);
  });

  it("always includes the app-aware assistant tools (read-only, never gated)", () => {
    for (const codingTools of [false, true]) {
      for (const memory of [false, true]) {
        const allow = webChatToolAllowlist(memory, codingTools);
        expect(allow).toContain("get_current_app_context");
        expect(allow).toContain("navigate_app");
        expect(allow).toContain("spotlight_ui");
      }
    }
  });

  it("never widens beyond read-only tools by default (no bash/edit/write/web_fetch)", () => {
    for (const t of ["bash", "edit", "write", "web_fetch", "weather", "grep", "find", "ls"]) {
      expect(webChatToolAllowlist(true)).not.toContain(t);
      expect(webChatToolAllowlist(true, false)).not.toContain(t);
    }
  });

  it("adds bash/edit/write/grep/find/ls ONLY when codingTools is explicitly true (plan §5.4/§6.5 opt-in toggle)", () => {
    const allow = webChatToolAllowlist(true, true);
    for (const t of ["bash", "edit", "write", "grep", "find", "ls", "read", "web_search"]) {
      expect(allow).toContain(t);
    }
    // Still never exposes web_fetch/weather — those stay out regardless of
    // codingTools (a 1B model over-calling a wide toolset, per WELCOME_TOOLS'
    // own module comment).
    expect(allow).not.toContain("web_fetch");
    expect(allow).not.toContain("weather");
  });

  it("codingTools works independently of memoryEnabled", () => {
    const allow = webChatToolAllowlist(false, true);
    expect(allow).toEqual([
      "read", "web_search", "get_current_app_context", "navigate_app", "spotlight_ui",
      "grep", "find", "ls", "bash", "edit", "write",
    ]);
  });
});

// Build a SessionMessageEntry-shaped fixture (only the fields serializeHistory reads).
const mEntry = (id: string, role: string, content: unknown, extra: Record<string, unknown> = {}) =>
  ({ type: "message", id, parentId: null, timestamp: "t", message: { role, content, ...extra } }) as unknown as SessionEntry;

describe("serializeHistory", () => {
  it("flattens user/assistant text and merges tool results by callId", () => {
    const entries: SessionEntry[] = [
      mEntry("1", "user", "hello"),
      mEntry("2", "assistant", [
        { type: "text", text: "hi! searching" },
        { type: "toolCall", id: "c1", name: "web_search", arguments: { query: "mlx" } },
      ]),
      mEntry("3", "toolResult", [{ type: "text", text: "top result" }], { toolCallId: "c1", toolName: "web_search" }),
      mEntry("4", "assistant", [{ type: "text", text: "found it" }]),
      { type: "model_change", id: "5", parentId: null, timestamp: "t", provider: "x", modelId: "y" } as unknown as SessionEntry,
    ];
    expect(serializeHistory(entries)).toEqual([
      { role: "user", text: "hello", tools: [], entryId: "1" },
      { role: "assistant", text: "hi! searching", tools: [{ callId: "c1", name: "web_search", args: { query: "mlx" }, result: "top result" }] },
      { role: "assistant", text: "found it", tools: [] },
    ]);
  });

  it("accepts string content and drops empty / non-message entries", () => {
    const entries: SessionEntry[] = [mEntry("1", "user", ""), mEntry("2", "user", "  real  ")];
    expect(serializeHistory(entries)).toEqual([{ role: "user", text: "  real  ", tools: [], entryId: "2" }]);
  });

  it("keeps an assistant message that is only tool calls (no text)", () => {
    const entries: SessionEntry[] = [
      mEntry("1", "assistant", [{ type: "toolCall", id: "c9", name: "weather", arguments: { location: "NYC" } }]),
    ];
    const items = serializeHistory(entries);
    expect(items).toHaveLength(1);
    expect(items[0]?.text).toBe("");
    expect(items[0]?.tools[0]).toEqual({ callId: "c9", name: "weather", args: { location: "NYC" }, result: "" });
  });

  it("keeps assistant thinking separate from final text", () => {
    const entries: SessionEntry[] = [
      mEntry("1", "assistant", [
        { type: "thinking", thinking: "working it out" },
        { type: "text", text: "answer" },
      ]),
    ];
    expect(serializeHistory(entries)).toEqual([
      { role: "assistant", text: "answer", thinking: "working it out", tools: [] },
    ]);
  });
});

// Message actions (plan §5.2): regenerate / edit-and-resend-as-sibling.
// Both features are built on findLastUserMessageEntry (locate the resend
// target + its original content) and userMessageSiblings (the `< i/n >`
// toggle's data). deepestLeafFrom is the pure "walk to a branch's own tip"
// helper used by switch_sibling in PiWebSession (src/pi-web.ts).
describe("findLastUserMessageEntry", () => {
  it("returns undefined for entries with no user message", () => {
    const entries: SessionEntry[] = [mEntry("1", "assistant", [{ type: "text", text: "hi" }])];
    expect(findLastUserMessageEntry(entries)).toBeUndefined();
  });

  it("finds the LAST user message (not the first), extracting text and parentId", () => {
    const entries: SessionEntry[] = [
      { ...mEntry("1", "user", "first"), parentId: null } as SessionEntry,
      { ...mEntry("2", "assistant", [{ type: "text", text: "reply 1" }]), parentId: "1" } as SessionEntry,
      { ...mEntry("3", "user", "second"), parentId: "2" } as SessionEntry,
    ];
    expect(findLastUserMessageEntry(entries)).toEqual({ id: "3", parentId: "2", text: "second", images: [] });
  });

  it("extracts both text and images from a content-parts array", () => {
    const entries: SessionEntry[] = [
      {
        ...mEntry("1", "user", [
          { type: "text", text: "look at this" },
          { type: "image", data: "AAAA", mimeType: "image/png" },
        ]),
        parentId: null,
      } as SessionEntry,
    ];
    expect(findLastUserMessageEntry(entries)).toEqual({
      id: "1", parentId: null, text: "look at this",
      images: [{ type: "image", data: "AAAA", mimeType: "image/png" }],
    });
  });
});

describe("userMessageSiblings", () => {
  it("returns undefined when the queried entryId doesn't exist", () => {
    const entries: SessionEntry[] = [{ ...mEntry("1", "user", "a"), parentId: null } as SessionEntry];
    expect(userMessageSiblings(entries, "missing")).toBeUndefined();
  });

  it("a message with no siblings reports index 1 of 1", () => {
    const entries: SessionEntry[] = [{ ...mEntry("1", "user", "a"), parentId: null } as SessionEntry];
    expect(userMessageSiblings(entries, "1")).toEqual({ parentId: null, siblingIds: ["1"], index: 1 });
  });

  it("groups siblings sharing the same parentId in append order, distinct from unrelated user messages", () => {
    const entries: SessionEntry[] = [
      { ...mEntry("root", "user", "turn 1"), parentId: null } as SessionEntry,
      { ...mEntry("a1", "assistant", [{ type: "text", text: "reply" }]), parentId: "root" } as SessionEntry,
      // Three edits of the SAME message (siblings under "a1"):
      { ...mEntry("edit1", "user", "second message v1"), parentId: "a1" } as SessionEntry,
      { ...mEntry("edit2", "user", "second message v2"), parentId: "a1" } as SessionEntry,
      { ...mEntry("edit3", "user", "second message v3"), parentId: "a1" } as SessionEntry,
    ];
    expect(userMessageSiblings(entries, "edit2")).toEqual({
      parentId: "a1", siblingIds: ["edit1", "edit2", "edit3"], index: 2,
    });
    // The root message (different parent) is its own singleton group.
    expect(userMessageSiblings(entries, "root")).toEqual({ parentId: null, siblingIds: ["root"], index: 1 });
  });
});

describe("deepestLeafFrom", () => {
  it("returns the starting id when it has no children (already a leaf)", () => {
    expect(deepestLeafFrom("a", () => [])).toBe("a");
  });

  it("walks down following the LAST child at each level", () => {
    const tree: Record<string, string[]> = {
      a: ["b1", "b2"], // b2 is the most-recently-appended child
      b2: ["c1"],
      c1: [],
    };
    const getChildren = (id: string) => (tree[id] ?? []).map((cid) => mEntry(cid, "assistant", "") as SessionEntry);
    expect(deepestLeafFrom("a", getChildren)).toBe("c1");
  });
});

describe("toSessionListItems", () => {
  it("titles rows, sorts newest-first, and flags forks", () => {
    const infos = [
      { path: "/s/a.jsonl", id: "a", cwd: "/x", created: new Date(1000), modified: new Date(1000), messageCount: 2, firstMessage: "older chat", allMessagesText: "" },
      { path: "/s/b.jsonl", id: "b", cwd: "/x", name: "Named", created: new Date(5000), modified: new Date(5000), messageCount: 4, firstMessage: "newer", allMessagesText: "", parentSessionPath: "/s/a.jsonl" },
    ] as unknown as SessionInfo[];
    const items = toSessionListItems(infos);
    expect(items[0]?.id).toBe("b"); // newest first
    expect(items[0]?.title).toBe("Named"); // explicit name wins over firstMessage
    expect(items[0]?.forked).toBe(true);
    expect(items[1]?.title).toBe("older chat");
    expect(items[1]?.forked).toBe(false);
  });
});

/* ════════════════════════════════════════════════════════════════════
   App-aware assistant (plan §6.6, §9 Phase 3, beat matrix Axis 12)
   ════════════════════════════════════════════════════════════════════ */

function fakeSnapshot(route: string): AppUiContext["snapshot"] {
  return {
    route,
    capturedAt: new Date(0).toISOString(),
    elements: [
      { ref: "ui-chat-0", tag: "textarea", label: "Message box", kind: "interactive", selector: '[data-ui-ref="ui-chat-0"]' },
    ],
  };
}

describe("isAppRouteId / resolveAppRoute (route catalog validation)", () => {
  it("accepts every catalog route id", () => {
    for (const r of APP_ROUTE_IDS) expect(isAppRouteId(r)).toBe(true);
  });

  it("rejects an unknown route", () => {
    expect(isAppRouteId("nonexistent")).toBe(false);
    expect(isAppRouteId("routes")).toBe(false); // the DAG diagram tab is deliberately excluded
  });

  it("resolves a bare route id", () => {
    expect(resolveAppRoute("quantize")).toBe("quantize");
  });

  it("resolves a #/route-style hash", () => {
    expect(resolveAppRoute("#/quantize")).toBe("quantize");
    expect(resolveAppRoute("#quantize")).toBe("quantize");
  });

  it("returns null for anything not in the catalog", () => {
    expect(resolveAppRoute("nonexistent")).toBeNull();
    expect(resolveAppRoute("")).toBeNull();
    expect(resolveAppRoute("#/nonexistent")).toBeNull();
  });
});

describe("ambientContextLine (the compact 'never answer blind' auto-prepend)", () => {
  it("returns null when there's no context yet", () => {
    expect(ambientContextLine(null)).toBeNull();
    expect(ambientContextLine(undefined)).toBeNull();
  });

  it("renders a bare route with no step", () => {
    expect(ambientContextLine({ route: "chat", snapshot: fakeSnapshot("chat") })).toBe("[user is on: Chat]");
  });

  it("renders a wizard step as 'label · step i/n'", () => {
    const ctx: AppUiContext = {
      route: "quantize",
      step: { index: 1, count: 4, label: "Configure" },
      snapshot: fakeSnapshot("quantize"),
    };
    expect(ambientContextLine(ctx)).toBe("[user is on: Quantize · step 2/4]");
  });

  it("prefers an open view over the route label", () => {
    const ctx: AppUiContext = { route: "chat", view: "memory-panel", snapshot: fakeSnapshot("chat") };
    expect(ambientContextLine(ctx)).toBe("[user is on: memory-panel]");
  });

  it("is never a snapshot dump — the elements array never appears in the line", () => {
    const ctx: AppUiContext = { route: "chat", snapshot: fakeSnapshot("chat") };
    const line = ambientContextLine(ctx);
    expect(line).not.toContain("ui-chat-0");
    expect(line).not.toContain("Message box");
  });
});

describe("createAppAwareTools: get_current_app_context / navigate_app / spotlight_ui", () => {
  function harness(initialContext: AppUiContext | null = null) {
    let context = initialContext;
    const sent: ServerMessage[] = [];
    const tools = createAppAwareTools(() => context, (m) => sent.push(m));
    const byName = Object.fromEntries(tools.map((t) => [t.name, t]));
    return {
      sent,
      setContext: (c: AppUiContext | null) => { context = c; },
      getCurrentAppContext: byName.get_current_app_context!,
      navigateApp: byName.navigate_app!,
      spotlightUi: byName.spotlight_ui!,
    };
  }

  it("registers exactly the three app-aware tool names", () => {
    const { getCurrentAppContext, navigateApp, spotlightUi } = harness();
    expect([getCurrentAppContext.name, navigateApp.name, spotlightUi.name]).toEqual([...APP_AWARE_TOOL_NAMES]);
  });

  describe("get_current_app_context", () => {
    it("reports no context received yet before the first push", async () => {
      const { getCurrentAppContext } = harness(null);
      const result = await getCurrentAppContext.execute("id1", {}, undefined, undefined, {} as never);
      expect((result.content[0] as { text: string }).text).toMatch(/no app context received yet/i);
    });

    it("returns the stored context verbatim once pushed", async () => {
      const ctx: AppUiContext = { route: "quantize", step: { index: 0, count: 4, label: "Source" }, snapshot: fakeSnapshot("quantize") };
      const { getCurrentAppContext } = harness(ctx);
      const result = await getCurrentAppContext.execute("id1", {}, undefined, undefined, {} as never);
      expect(result.details).toEqual({ context: ctx });
      expect((result.content[0] as { text: string }).text).toContain("quantize");
    });
  });

  describe("navigate_app -> ui_navigate frame", () => {
    it("maps a valid route param 1:1 to a ui_navigate frame", async () => {
      const { navigateApp, sent } = harness();
      const result = await navigateApp.execute("id1", { route: "finetune" }, undefined, undefined, {} as never);
      expect(sent).toEqual([{ type: "ui_navigate", route: "finetune" }]);
      expect((result as { isError?: boolean }).isError).toBeFalsy();
    });

    it("accepts the alternate `page` param name", async () => {
      const { navigateApp, sent } = harness();
      await navigateApp.execute("id1", { page: "dataset" }, undefined, undefined, {} as never);
      expect(sent).toEqual([{ type: "ui_navigate", route: "dataset" }]);
    });

    it("accepts a #/route-style hash", async () => {
      const { navigateApp, sent } = harness();
      await navigateApp.execute("id1", { route: "#/status" }, undefined, undefined, {} as never);
      expect(sent).toEqual([{ type: "ui_navigate", route: "status" }]);
    });

    it("rejects an unknown route as an error result, WITHOUT sending a frame", async () => {
      const { navigateApp, sent } = harness();
      const result = await navigateApp.execute("id1", { route: "nonexistent" }, undefined, undefined, {} as never);
      expect((result as { isError?: boolean }).isError).toBe(true);
      expect(sent).toEqual([]);
    });
  });

  describe("spotlight_ui -> ui_spotlight frame", () => {
    it("maps ref/label/selector/target/message 1:1 to a ui_spotlight frame", async () => {
      const { spotlightUi, sent } = harness();
      await spotlightUi.execute("id1", { ref: "ui-chat-0", message: "type here" }, undefined, undefined, {} as never);
      expect(sent).toEqual([{ type: "ui_spotlight", ref: "ui-chat-0", label: undefined, selector: undefined, target: undefined, route: undefined, message: "type here" }]);
    });

    it("resolves an optional route before sending", async () => {
      const { spotlightUi, sent } = harness();
      await spotlightUi.execute("id1", { target: "quantize-source", route: "quantize" }, undefined, undefined, {} as never);
      expect(sent).toEqual([{ type: "ui_spotlight", ref: undefined, label: undefined, selector: undefined, target: "quantize-source", route: "quantize", message: undefined }]);
    });

    it("rejects when no locator is provided at all", async () => {
      const { spotlightUi, sent } = harness();
      const result = await spotlightUi.execute("id1", {}, undefined, undefined, {} as never);
      expect((result as { isError?: boolean }).isError).toBe(true);
      expect(sent).toEqual([]);
    });

    it("rejects an unknown route, WITHOUT sending a frame", async () => {
      const { spotlightUi, sent } = harness();
      const result = await spotlightUi.execute("id1", { label: "Send", route: "nonexistent" }, undefined, undefined, {} as never);
      expect((result as { isError?: boolean }).isError).toBe(true);
      expect(sent).toEqual([]);
    });
  });
});
