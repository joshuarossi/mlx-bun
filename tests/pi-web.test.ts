// Phase 16 (web half): pure event-mapping for src/pi-web.ts. Tests only
// mapEventToFrames — the side-effect-free translator from pi
// AgentSessionEvents to the browser WS protocol. No live AgentSession,
// no server, no model (those run in integration once routes are wired).

import { describe, expect, it } from "bun:test";
import type { AgentSessionEvent } from "@earendil-works/pi-coding-agent";
import { buildWebChatSystemPrompt, mapEventToFrames } from "../src/pi-web";

// Cast helper: the real AgentSessionEvent union is large; we only build
// the fields mapEventToFrames reads, so narrow via `as`.
const ev = (e: unknown) => e as AgentSessionEvent;

describe("mapEventToFrames", () => {
  it("maps turn_start / turn_end to bare frames", () => {
    expect(mapEventToFrames(ev({ type: "turn_start" }))).toEqual([{ type: "turn_start" }]);
    expect(mapEventToFrames(ev({ type: "turn_end" }))).toEqual([{ type: "turn_end" }]);
  });

  it("maps text_delta assistant events to text_delta frames", () => {
    const frames = mapEventToFrames(
      ev({ type: "message_update", assistantMessageEvent: { type: "text_delta", delta: "hi" } }),
    );
    expect(frames).toEqual([{ type: "text_delta", delta: "hi" }]);
  });

  it("maps thinking_delta to text_delta frames (single bubble)", () => {
    const frames = mapEventToFrames(
      ev({ type: "message_update", assistantMessageEvent: { type: "thinking_delta", delta: "hmm" } }),
    );
    expect(frames).toEqual([{ type: "text_delta", delta: "hmm" }]);
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
