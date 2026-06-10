// Chat template parity with the oracle's apply_chat_template
// (goldens/chat-template.json): identical rendered strings, and identical
// token ids when fed through our tokenizer.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const goldenFile = Bun.file("goldens/chat-template.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("chat template oracle parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    cases: { messages: { role: string; content: string }[]; rendered: string; ids: number[] }[];
  };

  const { ChatTemplate } = await import("../src/chat-template");
  const { loadTokenizer } = await import("../src/tokenizer");
  const template = await ChatTemplate.load(SNAPSHOT);
  const tok = await loadTokenizer(SNAPSHOT);

  for (const c of golden.cases) {
    const label = c.messages.map((m) => m.role).join(",");
    test(`render parity: [${label}]`, () => {
      expect(template.render(c.messages)).toBe(c.rendered);
    });
    test(`token ids parity: [${label}]`, () => {
      // oracle encoded with add_special_tokens=False; our encode() adds
      // specials, so compare via the rendered string's raw encoding minus
      // any auto-added BOS — the template already includes bos_token.
      const rendered = template.render(c.messages);
      const ids = tok.encode(rendered);
      // Gemma's tokenizer.json post-processor prepends BOS; rendered text
      // also starts with <bos>. Drop a duplicated leading BOS if present.
      const fixed = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
      expect(fixed).toEqual(c.ids);
    });
  }
});
