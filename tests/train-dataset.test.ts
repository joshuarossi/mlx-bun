// FAST: dataset parsing/batching (no model, no tokenizer download).
//
// Uses a deterministic stub tokenizer (split on spaces → one id per token,
// stable per word) and a stub chat template (concatenate roles). Asserts:
//   - the 3 SFT formats produce correct ids + promptLen boundaries
//   - the DPO encoder produces chosen/rejected ids + response masks
//   - batch iterators yield B=1 batches and respect maxSeqLen truncation

import { describe, expect, test } from "bun:test";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { LoadedTokenizer } from "../src/tokenizer";
import type { ChatTemplate, ChatMessage } from "../src/chat-template";
import {
  encodeSftRow, sftRowFormat, loadSftDataset, iterateSftBatches,
  encodeDpoRow, tokenizePair, loadDpoDataset, iterateDpoBatches,
  probeFormat,
} from "../src/train/dataset";

// --- stubs ----------------------------------------------------------------

// Deterministic word→id: each distinct token maps to a stable integer.
const vocab = new Map<string, number>();
function tokenId(w: string): number {
  let id = vocab.get(w);
  if (id === undefined) {
    id = vocab.size + 1;
    vocab.set(w, id);
  }
  return id;
}
const stubTok: LoadedTokenizer = {
  encode: (text: string) => text.split(/\s+/).filter(Boolean).map(tokenId),
  decode: (ids: number[]) => ids.join(" "),
  bosTokenId: null,
  eosTokenId: null,
};

// Stub template: "<role>: <content>" per message joined by spaces; a trailing
// "assistant:" when addGenerationPrompt is set (so the boundary render ends
// exactly where the assistant response begins).
const stubTmpl = {
  render(messages: ChatMessage[], options: { addGenerationPrompt?: boolean } = {}): string {
    const parts = messages.map((m) => `${m.role}: ${m.content ?? ""}`);
    if (options.addGenerationPrompt) parts.push("assistant:");
    return parts.join(" ");
  },
} as unknown as ChatTemplate;

// --- SFT format detection -------------------------------------------------

describe("SFT row format", () => {
  test("detects each shape", () => {
    expect(sftRowFormat({ messages: [] })).toBe("messages");
    expect(sftRowFormat({ prompt: "p", completion: "c" })).toBe("prompt-completion");
    expect(sftRowFormat({ text: "hello" })).toBe("text");
    expect(() => sftRowFormat({ foo: 1 })).toThrow();
  });
});

describe("encodeSftRow", () => {
  test("prompt-completion boundary", () => {
    const ex = encodeSftRow({ prompt: "the quick brown", completion: " fox jumps" }, stubTok, stubTmpl);
    const promptIds = stubTok.encode("the quick brown");
    // full = "the quick brown fox jumps" → 5 tokens; promptLen = 3.
    expect(ex.ids.length).toBe(5);
    expect(ex.promptLen).toBe(promptIds.length);
    // response region is ids[promptLen:]
    expect(ex.ids.slice(ex.promptLen)).toEqual(stubTok.encode("fox jumps"));
  });

  test("text format has promptLen 0", () => {
    const ex = encodeSftRow({ text: "alpha beta gamma" }, stubTok, stubTmpl);
    expect(ex.promptLen).toBe(0);
    expect(ex.ids.length).toBe(3);
  });

  test("messages boundary excludes the assistant response", () => {
    const messages: ChatMessage[] = [
      { role: "user", content: "hello there" },
      { role: "assistant", content: "general kenobi" },
    ];
    const ex = encodeSftRow({ messages }, stubTok, stubTmpl);
    // prompt render: "user: hello there assistant:" ; full render:
    // "user: hello there assistant: general kenobi"
    const promptIds = stubTok.encode("user: hello there assistant:");
    const fullIds = stubTok.encode("user: hello there assistant: general kenobi");
    expect(ex.ids).toEqual(fullIds);
    expect(ex.promptLen).toBe(promptIds.length);
    // the supervised region is the assistant content.
    expect(ex.ids.slice(ex.promptLen)).toEqual(stubTok.encode("general kenobi"));
  });
});

describe("iterateSftBatches", () => {
  test("yields B=1 batches and truncates to maxSeqLen", () => {
    const examples = [
      { ids: [1, 2, 3, 4, 5], promptLen: 2 },
      { ids: [6, 7], promptLen: 1 },
    ];
    const it = iterateSftBatches(examples, 1, 3, 0, false);
    const batches = [...it];
    expect(batches.length).toBe(2);
    for (const b of batches) {
      expect(b.ids.length).toBe(1);
      expect(b.ids[0]!.length).toBeLessThanOrEqual(3);
    }
    // the long example got truncated to 3 tokens with the boundary clamped.
    const long = batches.find((b) => b.ids[0]!.length === 3)!;
    expect(long.promptLens[0]!).toBeLessThanOrEqual(2);
  });

  test("rejects batch_size > 1", () => {
    expect(() => [...iterateSftBatches([{ ids: [1, 2], promptLen: 0 }], 2, 10, 0, false)]).toThrow();
  });
});

// --- DPO ------------------------------------------------------------------

describe("tokenizePair", () => {
  test("prompt boundary + left-truncation preserving response", () => {
    const { ids, promptLen } = tokenizePair("a b c", " d e", stubTok, 100);
    expect(ids.length).toBe(5);
    expect(promptLen).toBe(3);

    // maxLength shorter than full → left-truncate, response preserved.
    const t2 = tokenizePair("a b c d", " e f", stubTok, 4);
    expect(t2.ids.length).toBe(4);
    // response (last 2 tokens) survives at the tail.
    expect(t2.ids.slice(-2)).toEqual(stubTok.encode("e f"));
  });
});

describe("encodeDpoRow", () => {
  test("masks are 0 over prompt, 1 over response", () => {
    const ex = encodeDpoRow(
      { prompt: "q1 q2", chosen: " good answer", rejected: " bad" },
      stubTok, stubTmpl, 100,
    );
    const promptLen = stubTok.encode("q1 q2").length;
    // chosen mask: prompt zeros then ones.
    expect(ex.chosenMask.slice(0, promptLen).every((m) => m === 0)).toBe(true);
    expect(ex.chosenMask.slice(promptLen).every((m) => m === 1)).toBe(true);
    expect(ex.chosenMask.length).toBe(ex.chosenIds.length);
    expect(ex.rejectedMask.length).toBe(ex.rejectedIds.length);
    // rejected response region length matches " bad".
    expect(ex.rejectedMask.filter((m) => m === 1).length).toBe(stubTok.encode("bad").length);
  });

  test("chat-message prompt renders through the template", () => {
    const ex = encodeDpoRow(
      { prompt: [{ role: "user", content: "hi" }], chosen: " yes", rejected: " no" },
      stubTok, stubTmpl, 100,
    );
    expect(ex.chosenIds.length).toBeGreaterThan(0);
    expect(ex.rejectedIds.length).toBeGreaterThan(0);
  });
});

describe("iterateDpoBatches", () => {
  test("yields B=1 batches", () => {
    const examples = [
      { chosenIds: [1, 2], rejectedIds: [3], chosenMask: [0, 1], rejectedMask: [1] },
      { chosenIds: [4], rejectedIds: [5, 6], chosenMask: [1], rejectedMask: [0, 1] },
    ];
    const batches = [...iterateDpoBatches(examples, 1, 0, false)];
    expect(batches.length).toBe(2);
    for (const b of batches) {
      expect(b.chosenIds.length).toBe(1);
      expect(b.rejectedIds.length).toBe(1);
    }
  });
});

// --- format probe + file loading ------------------------------------------

describe("probeFormat", () => {
  test("identifies dpo / sft shapes", () => {
    expect(probeFormat({ chosen: "a", rejected: "b", prompt: "p" })).toBe("dpo");
    expect(probeFormat({ messages: [] })).toBe("messages");
    expect(probeFormat({ prompt: "p", completion: "c" })).toBe("prompt-completion");
    expect(probeFormat({ text: "t" })).toBe("text");
    expect(probeFormat({ x: 1 })).toBe("unknown");
  });
});

describe("loadSftDataset / loadDpoDataset", () => {
  test("parses jsonl files", async () => {
    const dir = mkdtempSync(join(tmpdir(), "train-ds-"));
    writeFileSync(
      join(dir, "sft.jsonl"),
      [
        JSON.stringify({ text: "one two three" }),
        "",
        JSON.stringify({ prompt: "p", completion: " q" }),
      ].join("\n") + "\n",
    );
    const sft = await loadSftDataset(join(dir, "sft.jsonl"), stubTok, stubTmpl);
    expect(sft.length).toBe(2);

    writeFileSync(
      join(dir, "dpo.jsonl"),
      JSON.stringify({ prompt: "a b", chosen: " c", rejected: " d" }) + "\n",
    );
    const dpo = await loadDpoDataset(join(dir, "dpo.jsonl"), stubTok, stubTmpl, 100);
    expect(dpo.length).toBe(1);
    expect(dpo[0]!.chosenMask.some((m) => m === 1)).toBe(true);
  });
});
