// Gemma 4 reasoning-channel split (fast tier, needs the gemma tokenizer).
//
// With thinking on, the model wraps chain-of-thought as
//   <|channel>thought\n…<channel|>[final answer]
// where <|channel> (100) / <channel|> (101) are SPECIAL TOKENS the content
// decoder strips — so ToolAwareStream splits reasoning at the TOKEN level.
// These tests drive the router with synthetic token streams (no generation):
// the gemma tokenizer encodes each segment, sentinels delimit the channel.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";
import { CHANNEL_END, CHANNEL_START } from "../src/tool-call";

const have = await snapshotAvailable();

describe.skipIf(!have)("gemma reasoning channel split", async () => {
  const { loadTokenizer } = await import("../src/tokenizer");
  const { ToolAwareStream } = await import("../src/server");
  const tok = await loadTokenizer(SNAPSHOT);

  /** Feed a token stream through the router, returning the split. */
  const run = (ids: number[]) => {
    const r = new ToolAwareStream(tok, "gemma-sentinel", null);
    let content = "";
    let reasoning = "";
    for (const id of ids) {
      content += r.push(id);
      reasoning += r.takeReasoning();
    }
    content += r.flush();
    reasoning += r.takeReasoning();
    return { content: content.trim(), reasoning: reasoning.trim() };
  };

  test("splits <|channel>thought…<channel|> reasoning from the answer", () => {
    const channel = tok.encode("thought\nLet me check: 91 = 7 * 13.");
    const answer = tok.encode("91 is not prime.");
    const { content, reasoning } = run([CHANNEL_START, ...channel, CHANNEL_END, ...answer]);
    expect(reasoning).toBe("Let me check: 91 = 7 * 13."); // "thought\n" name line stripped
    expect(content).toBe("91 is not prime.");
    // no marker text or channel name leaks into either side
    expect(reasoning).not.toContain("thought");
    expect(content).not.toContain("thought");
    expect(content).not.toContain("channel");
  });

  test("empty thought block leaks nothing (larger Gemma, thinking off)", () => {
    const empty = tok.encode("thought\n");
    const answer = tok.encode("Hello there.");
    const { content, reasoning } = run([CHANNEL_START, ...empty, CHANNEL_END, ...answer]);
    expect(reasoning).toBe("");
    expect(content).toBe("Hello there.");
  });

  test("no channel at all (E4B thinking off) is a pure passthrough", () => {
    const answer = tok.encode("Just a direct answer.");
    const { content, reasoning } = run([...answer]);
    expect(reasoning).toBe("");
    expect(content).toBe("Just a direct answer.");
  });

  test("truncated mid-thought surfaces the partial reasoning, no content", () => {
    const channel = tok.encode("thought\nstill working it out"); // no CHANNEL_END
    const { content, reasoning } = run([CHANNEL_START, ...channel]);
    expect(reasoning).toBe("still working it out");
    expect(content).toBe("");
  });
});
