// Qwen3.5 / MiniCPM5 reasoning + role fixes (server.ts), all pure logic — no
// weights, no native, no live server. Guards the uncommitted thinking/web-UI
// work: the <think> splitter's `startInThinking` seed (primed-open prompts),
// promptEndsInOpenThink (detects that prime), and the developer→system remap
// that was making reasoning-model chat return no messages.

import { describe, expect, it } from "bun:test";

const { ThinkingTagSplitter, promptEndsInOpenThink, normalizeMessages } = await import("../src/server");

describe("ThinkingTagSplitter", () => {
  it("splits a normal <think>…</think> block into reasoning vs content", () => {
    const s = new ThinkingTagSplitter(true);
    s.push("<think>reason here</think>the answer");
    expect(s.reasoning).toBe("reason here");
    expect(s.content).toBe("the answer");
  });

  it("seeds startInThinking for primed-open prompts: model emits only the closing </think>", () => {
    // Qwen3.5/MiniCPM5 prime an OPEN <think> in the prompt, so generation begins
    // mid-reasoning with no opening tag — only a closing </think> appears.
    const s = new ThinkingTagSplitter(true, true);
    s.push("still reasoning here</think>final answer");
    expect(s.reasoning).toBe("still reasoning here");
    expect(s.content).toBe("final answer");
  });

  it("is streaming-safe when the closing tag is split across chunks", () => {
    const s = new ThinkingTagSplitter(true, true);
    s.push("think a");
    s.push("nd more</thi"); // partial closing tag must be held back, not emitted
    s.push("nk>visible");
    expect(s.reasoning).toBe("think and more");
    expect(s.content).toBe("visible");
  });

  it("regression: WITHOUT the seed, a primed-open model leaks all reasoning (and raw </think>) into content", () => {
    // This is the exact bug startInThinking fixes — inThinking starts false, so
    // the parser hunts an OPENING <think> that never comes and the closing tag is
    // treated as literal text. Everything lands in content; reasoning stays empty.
    const s = new ThinkingTagSplitter(true, false);
    s.push("leaked reasoning</think>answer");
    expect(s.content).toBe("leaked reasoning</think>answer");
    expect(s.reasoning).toBe("");
  });

  it("passes everything to content when thinking is disabled", () => {
    const s = new ThinkingTagSplitter(false, true);
    const out = s.push("<think>x</think>y");
    expect(out.content).toBe("<think>x</think>y");
    expect(out.reasoning).toBe("");
    expect(s.reasoning).toBe("");
  });
});

describe("promptEndsInOpenThink", () => {
  it("is true when the prompt primes an open <think> (thinking on)", () => {
    expect(promptEndsInOpenThink("<|user|>hi<|assistant|><think>")).toBe(true);
  });

  it("is false when thinking-off primes a closed empty block", () => {
    expect(promptEndsInOpenThink("<|assistant|><think>\n\n</think>")).toBe(false);
  });

  it("is false when the template has no <think> at all", () => {
    expect(promptEndsInOpenThink("<|user|>hi<|assistant|>")).toBe(false);
  });

  it("is true when an earlier block closed but the last one is open", () => {
    expect(promptEndsInOpenThink("<think>a</think> answered, now <think>")).toBe(true);
  });
});

describe("normalizeMessages — developer→system remap", () => {
  it("maps the reasoning-model 'developer' role to 'system'", () => {
    const out = normalizeMessages([{ role: "developer", content: "be terse" }]);
    expect(out[0]!.role).toBe("system");
    expect(out[0]!.content).toBe("be terse");
  });

  it("leaves ordinary roles untouched", () => {
    const out = normalizeMessages([
      { role: "system", content: "sys" },
      { role: "user", content: "hi" },
      { role: "assistant", content: "yo" },
    ]);
    expect(out.map((m) => m.role)).toEqual(["system", "user", "assistant"]);
  });
});

describe("normalizeMessages — content-parts flattening", () => {
  it("flattens an OpenAI text content-parts array to a plain string", () => {
    // pi (and OpenAI multimodal clients) ALWAYS send user content as a parts
    // array; a non-vision chat template renders nothing for an array, dropping
    // the user's turn. Flattening to a string is what makes it render.
    const out = normalizeMessages([
      { role: "user", content: [{ type: "text", text: "what's the weather in Tokyo?" }] },
    ]);
    expect(out[0]!.content).toBe("what's the weather in Tokyo?");
  });

  it("concatenates multiple text parts", () => {
    const out = normalizeMessages([
      { role: "user", content: [{ type: "text", text: "a" }, { type: "text", text: "b" }] },
    ]);
    expect(out[0]!.content).toBe("ab");
  });

  it("leaves string content untouched", () => {
    const out = normalizeMessages([{ role: "user", content: "plain string" }]);
    expect(out[0]!.content).toBe("plain string");
  });

  it("leaves arrays carrying an image part intact (the vision path needs them)", () => {
    const content = [
      { type: "image_url", image_url: { url: "data:image/png;base64,AAA" } },
      { type: "text", text: "describe this" },
    ];
    const out = normalizeMessages([{ role: "user", content }]);
    expect(Array.isArray(out[0]!.content)).toBe(true);
    expect(out[0]!.content).toEqual(content);
  });

  it("flattens the system/developer prompt array too (developer→system + flatten compose)", () => {
    const out = normalizeMessages([
      { role: "developer", content: [{ type: "text", text: "be terse" }] },
    ]);
    expect(out[0]!.role).toBe("system");
    expect(out[0]!.content).toBe("be terse");
  });
});
