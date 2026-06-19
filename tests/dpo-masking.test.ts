// Prompt-masking regression for ORPO/DPO preference data — the gotcha on
// long-prompt / short-completion rows (e.g. a 13KB policy+transcript prompt and
// a ~100-char JSON completion). The NLL / odds-ratio MUST be computed on the
// completion only; the prompt must be masked (mask 0). Char-based stub
// tokenizer so this is model-free and exact.

import { describe, expect, test } from "bun:test";
import { encodeDpoRow } from "../src/train/dataset";
import type { LoadedTokenizer } from "../src/tokenizer";
import type { ChatTemplate } from "../src/chat-template";

// encode("PROMPT"+"RESP") === encode("PROMPT") ++ encode("RESP"), so isPrefix
// always holds and promptLen is exact — ideal for asserting the boundary.
const stubTok = {
  encode: (s: string) => [...s].map((c) => c.charCodeAt(0)),
  decode: (ids: number[]) => String.fromCharCode(...ids),
  eosTokenId: 0,
} as unknown as LoadedTokenizer;
const stubTmpl = {} as unknown as ChatTemplate; // unused for string prompts

const sum = (m: number[]) => m.reduce((a, b) => a + b, 0);

describe("ORPO prompt masking (completion-only NLL)", () => {
  test("normal fit: mask is 0 over the prompt, 1 over the completion", () => {
    const ex = encodeDpoRow({ prompt: "PROMPT", chosen: "RESP", rejected: "BAD!" }, stubTok, stubTmpl, 4096);
    expect(ex.chosenMask.length).toBe(10); // PROMPT(6)+RESP(4)
    expect(ex.chosenMask.slice(0, 6)).toEqual([0, 0, 0, 0, 0, 0]); // prompt masked
    expect(sum(ex.chosenMask)).toBe(4); // exactly the completion tokens
    expect(ex.chosenMask[0]).toBe(0); // boundary intact
  });

  test("HUGE prompt + tiny completion + truncation: still completion-only", () => {
    // 3000-token prompt, 30-token completion, window 1024 → prompt is truncated
    // from the LEFT but the boundary is preserved (promptLen = 1024-30 = 994).
    const ex = encodeDpoRow(
      { prompt: "P".repeat(3000), chosen: "R".repeat(30), rejected: "X".repeat(20) },
      stubTok, stubTmpl, 1024,
    );
    expect(ex.chosenMask.length).toBe(1024);
    expect(sum(ex.chosenMask)).toBe(30); // ONLY the 30 completion tokens count
    expect(ex.chosenMask[0]).toBe(0); // prompt tail still masked
    expect(ex.chosenMask[993]).toBe(0);
    expect(ex.chosenMask[994]).toBe(1); // completion begins here
    // rejected likewise (20-token completion)
    expect(sum(ex.rejectedMask)).toBe(20);
    expect(ex.rejectedMask[0]).toBe(0);
  });

  test("ONLY edge that loses the boundary: completion ≥ max_seq_length", () => {
    // A completion that fills the whole window → promptLen collapses to 0 and
    // the mask is all-1. This is the single case the loader warns about; it does
    // NOT occur for short completions (the case above).
    const ex = encodeDpoRow(
      { prompt: "P".repeat(100), chosen: "R".repeat(2000), rejected: "X".repeat(2000) },
      stubTok, stubTmpl, 1024,
    );
    expect(ex.chosenMask[0]).toBe(1); // boundary collapsed (no prompt masked)
    expect(sum(ex.chosenMask)).toBe(1024);
  });
});
