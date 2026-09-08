import { describe, expect, test } from "bun:test";
import { respondStream } from "../../src/serve/http";
import type { CompletionStreamProtocol } from "../../src/serve/completion-sink";

describe("HTTP completion streaming", () => {
  test("emits SSE comments while completion events are buffered", async () => {
    let finish!: (value: unknown) => void;
    const stage = {
      run: () => new Promise((resolve) => { finish = resolve; }),
    } as any;
    const protocol: CompletionStreamProtocol = {
      start: () => [],
      addEvents: () => [],
      finish: () => [],
      error: () => [],
    };
    const response = respondStream(
      stage, { warnings: [] } as any, protocol,
      new AbortController().signal, undefined, 5,
    );
    const reader = response.body!.getReader();

    const first = await reader.read();
    expect(new TextDecoder().decode(first.value)).toBe(": keep-alive\n\n");

    finish({
      finishReason: "stop",
      usage: {
        promptTokens: 0,
        cachedTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
      },
    });
    await reader.cancel();
  });
});
