// Tool-path chat template parity (goldens/tools-template.json): tool
// declarations, assistant tool_calls, and tool-response round-trips must
// render identically to the oracle's apply_chat_template.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const goldenFile = Bun.file("goldens/tools-template.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("tool template parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    cases: { messages: any[]; tools: any[]; rendered: string }[];
  };
  const { ChatTemplate } = await import("../src/chat-template");
  const template = await ChatTemplate.load(SNAPSHOT);

  golden.cases.forEach((c, i) => {
    test(`case ${i}: roles [${c.messages.map((m) => m.role).join(",")}]`, () => {
      expect(template.render(c.messages, { tools: c.tools })).toBe(c.rendered);
    });
  });
});
