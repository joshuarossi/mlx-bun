import { describe, expect, test } from "bun:test";
import { applyGrammarDegrade } from "../../src/serve/chat-request";

describe("guided output graceful degradation", () => {
  test("every guided form injects string content and preserves a warning", () => {
    const requests = [
      { guided_grammar: "root ::= \"ok\"" },
      { guided_regex: "^ok$" },
      { guided_choice: ["yes", "no"] },
      { structured_outputs: { type: "object", properties: { ok: { type: "boolean" } } } },
      { response_format: { type: "json_object" } },
      {
        response_format: {
          type: "json_schema",
          json_schema: { name: "answer", schema: { type: "object" } },
        },
      },
    ];

    for (const request of requests) {
      const degraded = applyGrammarDegrade(
        { messages: [{ role: "user", content: "answer" }], ...request },
        "compiler unavailable",
      );
      const system = degraded.body.messages[0]!;
      expect(system.role).toBe("system");
      expect(typeof system.content).toBe("string");
      expect((system.content as string).length).toBeGreaterThan(0);
      expect(degraded.warning).toContain("grammar not enforced");
      expect(degraded.warning).toContain("falling back to prompt injection");
    }
  });
});
