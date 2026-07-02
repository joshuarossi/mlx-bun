// Server integration (slow tier): ephemeral-port server inside the test
// process (dies with the test), real chat + streaming requests.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();

// Fast tier: StopMatcher is pure string logic — no weights needed.
describe("StopMatcher (decoded-text stop sequences)", async () => {
  const { StopMatcher } = await import("../src/server");

  test("no sequences: pass-through", () => {
    const m = new StopMatcher([]);
    expect(m.push("hello")).toBe("hello");
    expect(m.stopped).toBe(false);
  });

  test("cuts at the match and never emits the sequence", () => {
    const m = new StopMatcher(["STOP"]);
    expect(m.push("hello ")).toBe("hello ");
    expect(m.push("STOP world")).toBe("");
    expect(m.stopped).toBe(true);
    expect(m.push("more")).toBe(""); // post-stop text discarded
  });

  test("match spanning two pushes (token boundary) is held back", () => {
    const m = new StopMatcher(["3 4"]);
    expect(m.push("1 2 ")).toBe("1 2 ");
    expect(m.push("3")).toBe(""); // could start "3 4" — held
    expect(m.stopped).toBe(false);
    expect(m.push(" 4")).toBe(""); // completes the match; nothing leaks
    expect(m.stopped).toBe(true);
  });

  test("held prefix is released once disambiguated", () => {
    const m = new StopMatcher(["END!"]);
    expect(m.push("the EN")).toBe("the ");
    expect(m.push("D of it")).toBe("END of it");
    expect(m.stopped).toBe(false);
  });

  test("flush releases held text when generation ends without a match", () => {
    const m = new StopMatcher(["xyz"]);
    expect(m.push("abcx")).toBe("abc");
    expect(m.flush()).toBe("x");
  });

  test("multiple sequences: earliest occurrence wins", () => {
    const m = new StopMatcher(["bbb", "a"]);
    expect(m.push("xxabbb")).toBe("xx");
    expect(m.stopped).toBe(true);
  });
});

// Fast tier: default-seed entropy — pure logic, no weights needed.
describe("nextDefaultSeed (per-request default-seed entropy)", async () => {
  const { nextDefaultSeed } = await import("../src/server");

  test("same-millisecond calls yield distinct uint32 seeds", () => {
    // Regression for the batch-lane collision: two default-seed requests in
    // the same ms used to share Date.now() & 0xffffffff and sample
    // identically. All calls inside one ms must now differ.
    let seeds: number[] = [];
    for (let attempt = 0; attempt < 10 && seeds.length < 2; attempt++) {
      seeds = [];
      const t0 = Date.now();
      do {
        seeds.push(nextDefaultSeed());
      } while (Date.now() === t0 && seeds.length < 64);
      if (Date.now() !== t0) seeds.pop(); // last one may have crossed the boundary
    }
    expect(seeds.length).toBeGreaterThanOrEqual(2); // at least two landed in one ms
    expect(new Set(seeds).size).toBe(seeds.length);
    for (const s of seeds) {
      expect(Number.isInteger(s)).toBe(true);
      expect(s).toBeGreaterThanOrEqual(0);
      expect(s).toBeLessThanOrEqual(0xffffffff);
    }
  });
});

describe.skipIf(!haveWeights)("openai-compatible server", async () => {
  if (!haveWeights) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT, "gemma-4-12b-it-optiq");
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  test("GET /v1/models lists the model", async () => {
    const res = await fetch(`${base}/v1/models`);
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.data[0].id).toBe("gemma-4-12b-it-optiq");
  });

  test("non-streaming chat completion", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Reply with exactly the word: ping" }],
        max_tokens: 8,
        temperature: 0,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("chat.completion");
    expect(body.choices[0].message.role).toBe("assistant");
    expect(body.choices[0].message.content.toLowerCase()).toContain("ping");
    expect(body.usage.prompt_tokens).toBeGreaterThan(0);
    expect(body.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("streaming chat completion (SSE)", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Count from 1 to 5, digits only." }],
        max_tokens: 24,
        temperature: 0,
        stream: true,
      }),
    });
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    const text = await res.text();
    const events = text.split("\n\n").filter((l) => l.startsWith("data: "))
      .map((l) => l.slice(6));
    expect(events.at(-1)).toBe("[DONE]");
    const chunks = events.slice(0, -1).map((e) => JSON.parse(e));
    const content = chunks
      .flatMap((c: any) => c.choices?.[0]?.delta?.content ?? [])
      .join("");
    expect(content).toContain("1");
    const final = chunks.at(-1) as any;
    expect(final.choices[0].finish_reason).toBeTruthy();
    expect(final.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("second turn hits the prompt cache", async () => {
    const turn1 = [{ role: "user", content: "Pick a color and say only its name." }];
    const res1 = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: turn1, max_tokens: 16, temperature: 0 }),
    });
    const body1 = (await res1.json()) as any;
    // other tests may have seeded a few shared-prefix tokens (<bos><|turn>user…)
    expect(body1.usage.prompt_tokens_details.cached_tokens).toBeLessThan(
      body1.usage.prompt_tokens / 2,
    );

    const turn2 = [
      ...turn1,
      { role: "assistant", content: body1.choices[0].message.content },
      { role: "user", content: "Why that one?" },
    ];
    const res2 = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: turn2, max_tokens: 24, temperature: 0 }),
    });
    const body2 = (await res2.json()) as any;
    // Reuse extends to the last assistant turn's `<|turn>model\n` boundary;
    // the ~4 thought-channel prefill tokens after it never re-render and
    // re-prefill each turn. So expect nearly all of turn-1's prompt.
    expect(body2.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(
      body1.usage.prompt_tokens - 6,
    );
    expect(body2.usage.prompt_tokens_details.cached_tokens).toBeGreaterThan(8);

    const stats = (await (await fetch(`${base}/stats`)).json()) as any;
    expect(stats.prompt_cache.hits).toBeGreaterThanOrEqual(1);
    expect(stats.prompt_cache.bytes).toBeGreaterThan(0);
    expect(stats.prompt_cache.bytes).toBeLessThanOrEqual(stats.prompt_cache.max_bytes);
  }, 240_000);

  test("vision: image_url data: URL describes the image", async () => {
    const png = await Bun.file("tests/fixtures/grad-768.png").arrayBuffer();
    const dataUrl = `data:image/png;base64,${Buffer.from(png).toString("base64")}`;
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{
          role: "user",
          content: [
            { type: "image_url", image_url: { url: dataUrl } },
            { type: "text", text: "Describe this image in one short sentence." },
          ],
        }],
        max_tokens: 32,
        temperature: 0,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const content = body.choices[0].message.content.toLowerCase();
    expect(content).toMatch(/gradient|color/);
    // image soft tokens included in prompt accounting
    expect(body.usage.prompt_tokens).toBeGreaterThan(250);
  }, 240_000);

  // --- stop sequences ----------------------------------------------------

  const countingPrompt =
    "Output exactly this and nothing else: 1 2 3 4 5 6 7 8 9";

  test("stop: plain string halts mid-generation, excluded from content", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: countingPrompt }],
        max_tokens: 64,
        temperature: 0,
        stop: "5",
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const content = body.choices[0].message.content as string;
    expect(content).toContain("4");
    expect(content).not.toContain("5");
    expect(body.choices[0].finish_reason).toBe("stop");
    // halted early instead of running out the token budget
    expect(body.usage.completion_tokens).toBeLessThan(64);
  }, 120_000);

  test("stop: streaming, sequence spans two tokens, never leaks", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: countingPrompt }],
        max_tokens: 64,
        temperature: 0,
        stream: true,
        stop: ["6 7"], // "6" and " 7" decode from separate tokens
      }),
    });
    expect(res.status).toBe(200);
    const text = await res.text();
    const events = text.split("\n\n").filter((l) => l.startsWith("data: "))
      .map((l) => l.slice(6));
    expect(events.at(-1)).toBe("[DONE]");
    const chunks = events.slice(0, -1).map((e) => JSON.parse(e));
    const content = chunks
      .flatMap((c: any) => c.choices?.[0]?.delta?.content ?? [])
      .join("");
    expect(content).toContain("5");
    // hold-back: neither the whole sequence nor its leading "6" leaks
    expect(content).not.toContain("6");
    const final = chunks.at(-1) as any;
    expect(final.choices[0].finish_reason).toBe("stop");
    expect(final.usage.completion_tokens).toBeLessThan(64);
  }, 120_000);

  test("stop: array form, later entry fires", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: countingPrompt }],
        max_tokens: 64,
        temperature: 0,
        stop: ["zzz-never-appears", "4"],
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const content = body.choices[0].message.content as string;
    expect(content).toContain("3");
    expect(content).not.toContain("4");
    expect(body.choices[0].finish_reason).toBe("stop");
  }, 120_000);

  test("malformed request → 400", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ messages: [] }),
    });
    expect(res.status).toBe(400);
  });

  // --- memoryBudget admission control (Phase 5) -------------------------
  // The GPU OOM this prevents is uncatchable (Phase 6), so the contract
  // is rejection BEFORE generation: load refusal, startup refusal, and
  // per-request 400s, each with actionable messages.

  test("admission: over-budget request → 400, in-budget passes", async () => {
    const { fit, kvBytesAt, TRANSIENT_PER_TOKEN, DEFAULT_CHUNK } = await import("../src/fit");
    const { setMemoryLimit } = await import("../src/mlx/ffi");
    // budget sized for ~512 tokens of bf16 context on this model
    const budget =
      ctx.model.weightsBytes + DEFAULT_CHUNK * TRANSIENT_PER_TOKEN +
      kvBytesAt(ctx.model.config, 512);
    const report = fit(ctx.model.config, ctx.model.weightsBytes, 1,
      undefined, undefined, 0, budget);
    expect(report.maxSafeContext).toBeGreaterThan(0);
    expect(report.maxSafeContext).toBeLessThan(1024);

    // the budgeted server caps the process-global mlx allocator — capture
    // and restore so later suites keep the default
    const prevLimit = setMemoryLimit(budget);
    setMemoryLimit(prevLimit);
    const tight = createServer(ctx, 0, { memoryBudgetBytes: budget });
    try {
      const tightBase = `http://localhost:${tight.port}`;

      const stats = (await (await fetch(`${tightBase}/stats`)).json()) as any;
      expect(stats.admission.max_safe_context).toBe(report.maxSafeContext);
      expect(stats.admission.memory_budget_bytes).toBe(budget);

      const over = await fetch(`${tightBase}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "hi" }],
          max_tokens: 4096,
          temperature: 0,
        }),
      });
      expect(over.status).toBe(400);
      const overBody = (await over.json()) as any;
      expect(overBody.error.type).toBe("memory_admission");
      expect(overBody.error.message).toContain("max_tokens");

      const ok = await fetch(`${tightBase}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "Reply with exactly the word: ping" }],
          max_tokens: 8,
          temperature: 0,
        }),
      });
      expect(ok.status).toBe(200);
    } finally {
      tight.stop(true);
      setMemoryLimit(prevLimit);
    }
  }, 240_000);

  test("admission: budget below weights refuses to serve or load", async () => {
    expect(() => createServer(ctx, 0, { memoryBudgetBytes: 1e9 })).toThrow(/cannot serve/);
    await expect(loadContext(SNAPSHOT, undefined, { memoryBudgetBytes: 1e9 }))
      .rejects.toThrow(/does not fit the memory budget/);
  });
});
