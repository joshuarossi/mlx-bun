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
    // pi auto-appends the date + cwd, so we must not repeat them.
    expect(prompt).not.toMatch(/today's date|current date|working directory/i);
  });

  it("advertises the full coding toolset + web tools, and flags approval-gated actions", () => {
    const prompt = buildTerminalSystemPrompt();
    for (const tool of ["read", "ls", "find", "grep", "bash", "edit", "write", "web_search", "web_fetch", "weather"]) {
      expect(prompt).toContain(tool);
    }
    expect(prompt).toMatch(/approval/i);
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

  it("defaults to interactive with no args", () => {
    expect(parsePiArgs([], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: undefined });
  });

  it("treats trailing words as an interactive first-turn message", () => {
    expect(parsePiArgs(["hello", "there"], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: "hello there" });
  });

  it("-p / --print → one-shot text print with the prompt", () => {
    expect(parsePiArgs(["-p", "summarize"], TTY)).toEqual({ mode: "print", printFormat: "text", message: "summarize" });
    expect(parsePiArgs(["--print", "summarize", "this"], TTY)).toEqual({ mode: "print", printFormat: "text", message: "summarize this" });
  });

  it("--mode json (and --json) → print json", () => {
    expect(parsePiArgs(["--mode", "json", "do", "x"], TTY)).toEqual({ mode: "print", printFormat: "json", message: "do x" });
    expect(parsePiArgs(["--json", "-p", "q"], TTY)).toEqual({ mode: "print", printFormat: "json", message: "q" });
  });

  it("--mode rpc → rpc (never reads stdin as a message)", () => {
    expect(parsePiArgs(["--mode", "rpc"], TTY)).toEqual({ mode: "rpc", printFormat: "text", message: undefined });
    // rpc wins even if stdin is piped (it's the JSONL channel).
    expect(parsePiArgs(["--mode", "rpc"], PIPE)).toEqual({ mode: "rpc", printFormat: "text", message: undefined });
  });

  it("piped stdin makes a bare invocation one-shot print (like pi's CLI)", () => {
    expect(parsePiArgs([], PIPE)).toEqual({ mode: "print", printFormat: "text", message: undefined });
    expect(parsePiArgs(["extra", "words"], PIPE)).toEqual({ mode: "print", printFormat: "text", message: "extra words" });
  });

  it("ignores unknown flags (full pi surface lives in the user's own pi)", () => {
    // --continue is a pi flag the built-in agent doesn't implement; it must
    // not be swallowed into the message text, and the run stays interactive.
    expect(parsePiArgs(["--continue", "hi"], TTY)).toEqual({ mode: "interactive", printFormat: "text", message: "hi" });
  });
});
