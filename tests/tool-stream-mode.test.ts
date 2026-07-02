// Tool-stream router selection (fast tier, model-free).
//
// The token-id sentinel router (ids 48/49 = <|tool_call>/<tool_call|>,
// 100/101 = <|channel>/<channel|>) is Gemma-4-ONLY: on every other
// tokenizer those ids are ordinary low-id vocab entries, so routing a
// generic model through gemma-sentinel silently swallowed output into a
// phantom tool/reasoning segment (and generics never reached the
// buffered-text tool parser at all). selectToolStreamMode family-gates the
// sentinel path; these tests pin that gate and prove the non-sentinel
// modes treat 48/49/100/101 as plain text.

import { describe, expect, test } from "bun:test";
import { selectToolStreamMode, ToolAwareStream } from "../src/server";
import type { LoadedTokenizer } from "../src/tokenizer";
import { CHANNEL_END, CHANNEL_START, TOOL_CALL_END, TOOL_CALL_START } from "../src/tool-call";

describe("selectToolStreamMode", () => {
  test("gemma-4 family keeps the token-sentinel router, tools or not", () => {
    for (const t of ["gemma4", "gemma4_text", "gemma4_unified"]) {
      expect(selectToolStreamMode(t, true)).toBe("gemma-sentinel");
      expect(selectToolStreamMode(t, false)).toBe("gemma-sentinel");
    }
  });

  test("Tier-0 generics and non-gemma targets get buffered-text with tools, plain without", () => {
    // llama covers MiniCPM5 (its model_type is "llama"); qwen3_5 covers
    // Qwen3.5; the rest are universal-dense generics served today.
    for (const t of [
      "llama", "qwen2", "qwen3", "qwen3_5", "qwen3_5_text", "phi3", "olmo2",
      "glm4", "granite", "starcoder2", "smollm3", "gemma", "gemma2",
      "diffusion_gemma",
    ]) {
      expect(selectToolStreamMode(t, true)).toBe("buffered-text");
      expect(selectToolStreamMode(t, false)).toBe("plain");
    }
  });
});

// A tokenizer where the Gemma sentinel ids are ORDINARY vocab words — the
// situation for every non-gemma4 tokenizer (llama, qwen2, phi3, …).
const VOCAB: Record<number, string> = {
  [TOOL_CALL_START]: "alpha ",  // 48
  [TOOL_CALL_END]: "bravo ",    // 49
  [CHANNEL_START]: "charlie ",  // 100
  [CHANNEL_END]: "delta ",      // 101
  1: "hello ",
  2: "world",
};
const stubTokenizer: LoadedTokenizer = {
  encode: () => { throw new Error("not needed"); },
  decode: (ids) => ids.map((id) => VOCAB[id] ?? `<${id}>`).join(""),
  idToToken: (id) => VOCAB[id] ?? `<${id}>`,
  bosTokenId: null,
  eosTokenId: null,
};

describe("ToolAwareStream non-sentinel modes ignore gemma sentinel ids", () => {
  const run = (mode: "plain" | "buffered-text") => {
    const tools = mode === "buffered-text"
      ? [{ type: "function" as const, function: { name: "t", parameters: {} } }]
      : null;
    const r = new ToolAwareStream(stubTokenizer, mode, tools);
    let content = "";
    let reasoning = "";
    for (const id of [1, TOOL_CALL_START, CHANNEL_START, 2, CHANNEL_END, TOOL_CALL_END]) {
      content += r.push(id);
      reasoning += r.takeReasoning();
    }
    content += r.flush();
    reasoning += r.takeReasoning();
    return { r, content, reasoning };
  };

  test("plain mode streams ids 48/49/100/101 as ordinary text", () => {
    const { r, content, reasoning } = run("plain");
    expect(content).toBe("hello alpha charlie worlddelta bravo ");
    expect(reasoning).toBe("");
    expect(r.toolSegments).toEqual([]);
    expect(r.toolCalls()).toEqual([]);
  });

  test("buffered-text mode (tools present) keeps them as content too", () => {
    const { r, content, reasoning } = run("buffered-text");
    expect(content).toBe("hello alpha charlie worlddelta bravo ");
    expect(reasoning).toBe("");
    expect(r.toolSegments).toEqual([]); // token-level capture never engages
    expect(r.toolCalls()).toEqual([]); // and no phantom text tool call either
  });
});
