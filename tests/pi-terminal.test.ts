// Phase 16 P3/P4: `mlx-bun pi` embedded terminal. Tests the two pure pieces
// — the custom system prompt and the argv → run-mode parser. The live
// AgentSessionRuntime / InteractiveMode path needs a TTY + a running model,
// so it's exercised by manual verification + the binary asset smoke, not here.

import { describe, expect, it } from "bun:test";
import { buildTerminalSystemPrompt, parsePiArgs } from "../src/pi-terminal";

describe("buildTerminalSystemPrompt", () => {
  it("frames an mlx-bun terminal CODING agent, local and private", () => {
    const prompt = buildTerminalSystemPrompt();
    expect(prompt).toContain("mlx-bun");
    expect(prompt).toMatch(/coding agent/i);
    expect(prompt).toMatch(/terminal/i);
    expect(prompt).toMatch(/local/i);
    expect(prompt).toMatch(/private/i);
    // Must NOT carry pi's default framing or internal-doc noise (we replace,
    // not append, pi's coding-agent prompt).
    expect(prompt).not.toMatch(/operating inside pi/i);
    expect(prompt).not.toMatch(/pi documentation/i);
    // Environment metadata is context, not something to report unprompted.
    expect(prompt).toMatch(/do not report or summarize that metadata/i);
  });

  it("advertises the full coding toolset + web tools, and flags approval-gated actions", () => {
    const prompt = buildTerminalSystemPrompt();
    for (const tool of ["read", "ls", "find", "grep", "bash", "edit", "write", "web_search", "web_fetch", "weather"]) {
      expect(prompt).toContain(tool);
    }
    expect(prompt).toMatch(/approval/i);
  });

  it("routes conversation vs real-world questions appropriately", () => {
    const prompt = buildTerminalSystemPrompt();
    expect(prompt).toMatch(/ordinary social conversation/i);
    expect(prompt).toMatch(/answer naturally yourself/i);
    expect(prompt).toMatch(/real-world facts|current events|recommendations/i);
    expect(prompt).toMatch(/look it up with web_search\/web_fetch or weather/i);
    expect(prompt).toMatch(/Do not narrate tool policies or internal workflows/i);
  });

  it("names the served model when given a label, and degrades without one", () => {
    expect(buildTerminalSystemPrompt("gemma-4-12B-it-OptiQ-4bit")).toContain("gemma-4-12B-it-OptiQ-4bit");
    const generic = buildTerminalSystemPrompt();
    expect(generic).toMatch(/a local model/i);
    expect(generic).toContain("mlx-bun");
  });
});

describe("parsePiArgs", () => {
  const TTY = false; // stdin is a TTY (not piped)
  const PIPE = true; // stdin is piped
  /** Baseline result fields shared by most expectations. */
  const base = { verbose: false, ignored: [] as string[] };

  it("defaults to interactive with no args", () => {
    expect(parsePiArgs([], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: undefined, ...base });
  });

  it("treats trailing words as an interactive first-turn message", () => {
    expect(parsePiArgs(["hello", "there"], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: "hello there", ...base });
  });

  it("-p / --print → one-shot text print with the prompt", () => {
    expect(parsePiArgs(["-p", "summarize"], TTY)).toEqual({ mode: "print", printFormat: "text", message: "summarize", ...base });
    expect(parsePiArgs(["--print", "summarize", "this"], TTY)).toEqual({ mode: "print", printFormat: "text", message: "summarize this", ...base });
  });

  it("--mode json (and --json) → print json", () => {
    expect(parsePiArgs(["--mode", "json", "do", "x"], TTY)).toEqual({ mode: "print", printFormat: "json", message: "do x", ...base });
    expect(parsePiArgs(["--json", "-p", "q"], TTY)).toEqual({ mode: "print", printFormat: "json", message: "q", ...base });
  });

  it("--mode rpc → rpc (never reads stdin as a message)", () => {
    expect(parsePiArgs(["--mode", "rpc"], TTY)).toEqual({ mode: "rpc", printFormat: "text", message: undefined, ...base });
    // rpc wins even if stdin is piped (it's the JSONL channel).
    expect(parsePiArgs(["--mode", "rpc"], PIPE)).toEqual({ mode: "rpc", printFormat: "text", message: undefined, ...base });
  });

  it("piped stdin makes a bare invocation one-shot print (like pi's CLI)", () => {
    expect(parsePiArgs([], PIPE)).toEqual({ mode: "print", printFormat: "text", message: undefined, ...base });
    expect(parsePiArgs(["extra", "words"], PIPE)).toEqual({ mode: "print", printFormat: "text", message: "extra words", ...base });
  });

  it("--verbose is recognized (pi's verbose startup banner)", () => {
    expect(parsePiArgs(["--verbose"], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: undefined, verbose: true, ignored: [] });
    expect(parsePiArgs(["--verbose", "hi"], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: "hi", verbose: true, ignored: [] });
  });

  it("drops an unknown flag AND its value — never leaks the value as message text", () => {
    // `mlx-bun pi --resume abc123` used to start a chat with message "abc123".
    expect(parsePiArgs(["--resume", "abc123"], TTY)).toEqual({
      mode: "interactive", printFormat: "text", message: undefined, verbose: false, ignored: ["--resume abc123"],
    });
    // An unknown flag followed by a flag consumes only itself; known flags
    // after it still apply.
    expect(parsePiArgs(["--continue", "-p", "q"], TTY)).toEqual({
      mode: "print", printFormat: "text", message: "q", verbose: false, ignored: ["--continue"],
    });
    // A trailing unknown flag with nothing after it consumes only itself.
    expect(parsePiArgs(["--continue"], TTY)).toEqual({
      mode: "interactive", printFormat: "text", message: undefined, verbose: false, ignored: ["--continue"],
    });
  });
});
