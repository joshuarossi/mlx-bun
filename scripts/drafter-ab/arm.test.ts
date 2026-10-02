// The A/B arm and the server it starts, against a fake OpenAI-compatible server
// (no model, no GPU): the counters come from `usage.speculation`, and an arm
// that did not speculate is refused rather than compared as zero acceptance.
import { afterEach, describe, expect, test } from "bun:test";
import { DEFAULT_PROMPTS, runArm, speculationOf } from "./arm";
import { serverArgv } from "../drafter-ab";

let server: ReturnType<typeof Bun.serve> | undefined;
afterEach(() => { server?.stop(true); server = undefined; });

const speculation = { drafted: 10, accepted: 6, targetCalls: 4, rounds: 4, draftedByPos: [4, 3, 3], acceptedByPos: [4, 2, 0] };
const respond = (usage: object) => Response.json({ choices: [{ message: { role: "assistant", content: "x" }, finish_reason: "stop" }], usage });

describe("runArm", () => {
  test("sends each prompt greedily and non-streaming, and reads the speculation counters", async () => {
    const requests: any[] = [];
    server = Bun.serve({ port: 0, async fetch(request) {
      requests.push({ path: new URL(request.url).pathname, body: await request.json() });
      return respond({ completion_tokens: 12, speculation });
    } });
    const results = await runArm({ base: `http://127.0.0.1:${server.port}`, model: "/m", prompts: ["a", "b"], maxTokens: 16 });
    expect(requests.map(r => r.path)).toEqual(["/v1/chat/completions", "/v1/chat/completions"]);
    expect(requests[0].body).toEqual({ model: "/m", messages: [{ role: "user", content: "a" }], temperature: 0, max_tokens: 16, stream: false });
    expect(results.map(r => r.prompt)).toEqual(["a", "b"]);
    expect(results[0]).toMatchObject({ generatedTokens: 12, drafted: 10, accepted: 6, targetCalls: 4, draftedByPos: [4, 3, 3], acceptedByPos: [4, 2, 0] });
    expect(results[0]!.wallMs).toBeGreaterThan(0);
  });

  test("refuses a response without usage.speculation, naming the prompt", async () => {
    server = Bun.serve({ port: 0, fetch: () => respond({ completion_tokens: 5 }) });
    await expect(runArm({ base: `http://127.0.0.1:${server.port}`, model: "/m", prompts: ["a"], maxTokens: 4 })).rejects.toThrow("prompt 1: the response has no usage.speculation");
  });

  test("a failing request names the status", async () => {
    server = Bun.serve({ port: 0, fetch: () => new Response("boom", { status: 500 }) });
    await expect(runArm({ base: `http://127.0.0.1:${server.port}`, model: "/m", prompts: ["a"], maxTokens: 4 })).rejects.toThrow("HTTP 500");
  });
});

describe("speculationOf", () => {
  test("a malformed counter is an error, not a zero", () => {
    expect(() => speculationOf("p", { usage: { completion_tokens: 1, speculation: { ...speculation, accepted: "6" } } }, 1)).toThrow("accepted");
    expect(() => speculationOf("p", { usage: { completion_tokens: 1, speculation: { ...speculation, draftedByPos: undefined } } }, 1)).toThrow("draftedByPos");
  });
});

test("the default prompt set holds at least the 32 the gate asks for, all distinct", () => {
  expect(DEFAULT_PROMPTS.length).toBeGreaterThanOrEqual(32);
  expect(new Set(DEFAULT_PROMPTS).size).toBe(DEFAULT_PROMPTS.length);
});

describe("serverArgv", () => {
  test("mounts the drafter on the target, pins thinking off, and appends the caller's serve args", () => {
    expect(serverArgv({ command: ["bun", "/t/main.ts", "serve"], target: "/target", drafter: "/d", port: 9, numDraftTokens: 3, serveArgs: ["--kv-quant", "4"] }))
      .toEqual(["bun", "/t/main.ts", "serve", "/target", "--draft-model", "/d", "--host", "127.0.0.1", "--port", "9", "--thinking", "off", "--num-draft-tokens", "3", "--kv-quant", "4"]);
  });
});
