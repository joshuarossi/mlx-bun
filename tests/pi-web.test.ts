// Phase 16 (web half): pure event-mapping for src/pi-web.ts. Tests only
// mapEventToFrames — the side-effect-free translator from pi
// AgentSessionEvents to the browser WS protocol. No live AgentSession,
// no server, no model (those run in integration once routes are wired).

import { describe, expect, it } from "bun:test";
import type { AgentSessionEvent, SessionEntry, SessionInfo } from "@earendil-works/pi-coding-agent";
import {
  buildWebChatSystemPrompt,
  injectAdapter,
  mapEventToFrames,
  serializeHistory,
  toSessionListItems,
} from "../src/pi-web";

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

describe("mapEventToFrames", () => {
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
  it("frames a helpful, local, eager assistant (not pi's coding-agent default)", () => {
    const prompt = buildWebChatSystemPrompt(false);
    expect(prompt).toContain("helpful");
    expect(prompt).toMatch(/eager|proactive/i);
    expect(prompt).toContain("mlx-bun");
    // Must NOT carry over pi's default framing or internal-doc noise.
    expect(prompt).not.toMatch(/operating inside pi/i);
    expect(prompt).not.toMatch(/pi documentation/i);
  });

  it("advertises the full toolset, including approval-gated actions, in normal mode", () => {
    const prompt = buildWebChatSystemPrompt(false);
    for (const tool of ["read", "grep", "find", "ls", "bash", "edit", "write"]) {
      expect(prompt).toContain(tool);
    }
    expect(prompt).toMatch(/approval/i);
  });

  it("advertises the web-facing tools in both modes", () => {
    for (const readOnly of [false, true]) {
      const prompt = buildWebChatSystemPrompt(readOnly);
      for (const tool of ["web_search", "web_fetch", "weather"]) {
        expect(prompt).toContain(tool);
      }
    }
  });

  it("describes only non-mutating capabilities in read-only mode", () => {
    const prompt = buildWebChatSystemPrompt(true);
    expect(prompt).toMatch(/read-only/i);
    expect(prompt).toContain("read");
    expect(prompt).toContain("grep");
    expect(prompt).toContain("web_search");
    // No promise of mutating actions the gate would refuse.
    expect(prompt).not.toMatch(/\bedit\b/);
    expect(prompt).not.toMatch(/\bwrite\b/);
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
      { role: "user", text: "hello", tools: [] },
      { role: "assistant", text: "hi! searching", tools: [{ callId: "c1", name: "web_search", args: { query: "mlx" }, result: "top result" }] },
      { role: "assistant", text: "found it", tools: [] },
    ]);
  });

  it("accepts string content and drops empty / non-message entries", () => {
    const entries: SessionEntry[] = [mEntry("1", "user", ""), mEntry("2", "user", "  real  ")];
    expect(serializeHistory(entries)).toEqual([{ role: "user", text: "  real  ", tools: [] }]);
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
