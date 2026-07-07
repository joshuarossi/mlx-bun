// Phase 16 (web half): pure event-mapping for src/pi-web.ts. Tests only
// mapEventToFrames — the side-effect-free translator from pi
// AgentSessionEvents to the browser WS protocol. No live AgentSession,
// no server, no model (those run in integration once routes are wired).

import { beforeEach, describe, expect, it } from "bun:test";
import type { AgentSessionEvent, SessionEntry, SessionInfo } from "@earendil-works/pi-coding-agent";
import {
  buildWebChatSystemPrompt,
  deepestLeafFrom,
  findLastUserMessageEntry,
  injectAdapter,
  injectSampling,
  mapEventToFrames,
  serializeHistory,
  toSessionListItems,
  userMessageSiblings,
  webChatToolAllowlist,
} from "../src/pi-web";
import { MEMORY_TOOL_NAMES, REFERENCE_TOOL_NAMES } from "../src/memory/tools";
import { clearLaneRegistry, recordLane } from "../src/serve/lane-registry";

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
    // welcome blurb + two-tool guidance keeps it well under that.
    expect(prompt.length).toBeLessThan(1300);
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
  it("is exactly the two welcome tools when memory is off", () => {
    expect(webChatToolAllowlist(false)).toEqual(["read", "web_search"]);
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

  it("never widens beyond read-only tools (no bash/edit/write/web_fetch)", () => {
    for (const t of ["bash", "edit", "write", "web_fetch", "weather", "grep", "find", "ls"]) {
      expect(webChatToolAllowlist(true)).not.toContain(t);
    }
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
