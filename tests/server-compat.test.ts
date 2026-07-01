// mlx_lm.server surface compatibility (slow tier): /health, /v1/completions
// (raw text completion, non-stream + stream + stop), /v1/models registry
// listing, the new request sampling fields (min_p / xtc / logit_bias /
// penalties), and the `serve --adapter` default-adapter wiring
// (ServerOptions.defaultAdapter — the CLI flag sets exactly this field).
//
// One ephemeral server on the smallest cached model (MiniCPM5-1B); skipped
// when the snapshot isn't downloaded. Never downloads anything.

import { afterAll, describe, expect, test } from "bun:test";
import { SNAPSHOT_MINICPM5, snapshotMiniCPM5Available } from "./paths";

const haveWeights = await snapshotMiniCPM5Available();
const MODEL_ID = "minicpm5-1b-compat";

// Fast tier: logit_bias wire coercion is pure (mlx-lm's {int(k): float(v)}).
describe("parseLogitBias (wire coercion)", async () => {
  const { parseLogitBias } = await import("../src/server");

  test("string JSON keys coerce to int keys", () => {
    expect(parseLogitBias({ "42": -5, "7": 1.5 })).toEqual({ 42: -5, 7: 1.5 });
  });

  test("absent / empty → undefined", () => {
    expect(parseLogitBias(undefined)).toBeUndefined();
    expect(parseLogitBias(null)).toBeUndefined();
    expect(parseLogitBias({})).toBeUndefined();
  });

  test("non-numeric key or value throws mlx-lm's error", () => {
    expect(() => parseLogitBias({ abc: 1 })).toThrow("logit_bias must be a dict of int to float");
    expect(() => parseLogitBias({ "1": "x" as unknown as number }))
      .toThrow("logit_bias must be a dict of int to float");
    // non-integer token id is invalid too
    expect(() => parseLogitBias({ "1.5": 1 })).toThrow("logit_bias must be a dict of int to float");
  });
});

describe.skipIf(!haveWeights)("mlx_lm.server surface compat", async () => {
  if (!haveWeights) return;
  const { createServer, loadContext } = await import("../src/server");
  const ctx = await loadContext(SNAPSHOT_MINICPM5, MODEL_ID);
  const server = createServer(ctx, 0);
  const base = `http://localhost:${server.port}`;
  afterAll(() => server.stop(true));

  const sse = (text: string) => {
    const events = text.split("\n\n").filter((l) => l.startsWith("data: "))
      .map((l) => l.slice(6));
    return { events, chunks: events.filter((e) => e !== "[DONE]").map((e) => JSON.parse(e)) };
  };

  // --- GET /health -------------------------------------------------------

  test("GET /health returns mlx_lm.server's exact body", async () => {
    const res = await fetch(`${base}/health`);
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("application/json");
    // byte-for-byte what mlx_lm.server writes (note the space)
    expect(await res.text()).toBe('{"status": "ok"}');
  });

  // --- GET /v1/models ----------------------------------------------------

  test("GET /v1/models: served model first, mlx-lm list shape", async () => {
    const res = await fetch(`${base}/v1/models`);
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("list");
    expect(Array.isArray(body.data)).toBe(true);
    expect(body.data.length).toBeGreaterThanOrEqual(1);
    expect(body.data[0].id).toBe(MODEL_ID);
    for (const m of body.data) {
      expect(typeof m.id).toBe("string");
      expect(m.object).toBe("model");
      expect(typeof m.created).toBe("number");
    }
  });

  test("GET /v1/models/<id> filters to that id (same list shape)", async () => {
    const res = await fetch(`${base}/v1/models/${encodeURIComponent(MODEL_ID)}`);
    const body = (await res.json()) as any;
    expect(body.object).toBe("list");
    expect(body.data.length).toBe(1);
    expect(body.data[0].id).toBe(MODEL_ID);

    const miss = (await (await fetch(`${base}/v1/models/no-such-model`)).json()) as any;
    expect(miss.data.length).toBe(0);
  });

  // --- POST /v1/completions (raw text completion) -------------------------

  test("non-streaming text completion: OpenAI text_completion shape", async () => {
    const res = await fetch(`${base}/v1/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        prompt: "The numbers one two three four",
        max_tokens: 8,
        temperature: 0,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("text_completion");
    expect(body.id).toStartWith("cmpl-");
    expect(body.model).toBe(MODEL_ID);
    expect(body.choices[0].index).toBe(0);
    expect(typeof body.choices[0].text).toBe("string");
    expect(body.choices[0].text.length).toBeGreaterThan(0);
    expect(["stop", "length"]).toContain(body.choices[0].finish_reason);
    expect(body.usage.prompt_tokens).toBeGreaterThan(0);
    expect(body.usage.completion_tokens).toBeGreaterThan(0);
    expect(body.usage.total_tokens).toBe(body.usage.prompt_tokens + body.usage.completion_tokens);
    // no chat template: raw prompt only (a chat render would add many tokens)
    expect(body.usage.prompt_tokens).toBeLessThan(16);
  }, 120_000);

  test("streaming text completion (SSE): text deltas + finish + [DONE]", async () => {
    const res = await fetch(`${base}/v1/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        prompt: "One two three",
        max_tokens: 12,
        temperature: 0,
        stream: true,
      }),
    });
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/event-stream");
    const { events, chunks } = sse(await res.text());
    expect(events.at(-1)).toBe("[DONE]");
    for (const c of chunks) expect(c.object).toBe("text_completion");
    const text = chunks.map((c: any) => c.choices?.[0]?.text ?? "").join("");
    expect(text.length).toBeGreaterThan(0);
    const final = chunks.at(-1) as any;
    expect(["stop", "length"]).toContain(final.choices[0].finish_reason);
    expect(final.usage.completion_tokens).toBeGreaterThan(0);
  }, 120_000);

  test("text completion stop sequence halts and is excluded", async () => {
    const res = await fetch(`${base}/v1/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        prompt: "Count: 1 2 3 4",
        max_tokens: 64,
        temperature: 0,
        stop: "7",
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.choices[0].text).not.toContain("7");
    expect(body.choices[0].finish_reason).toBe("stop");
    expect(body.usage.completion_tokens).toBeLessThan(64);
  }, 120_000);

  test("missing / non-string prompt → 400 (token arrays rejected, like mlx-lm)", async () => {
    for (const payload of [{}, { prompt: [1, 2, 3] }]) {
      const res = await fetch(`${base}/v1/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(payload),
      });
      expect(res.status).toBe(400);
    }
  });

  // --- new sampling fields on chat ----------------------------------------

  test("chat with min_p + xtc + logit_bias + penalties → 200, sane output", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Reply with a short greeting." }],
        max_tokens: 16,
        temperature: 0.7,
        seed: 7,
        min_p: 0.05,
        xtc_probability: 0.2,
        xtc_threshold: 0.1,
        logit_bias: { "5": -2.0 },
        presence_penalty: 0.4,
        frequency_penalty: 0.2,
        presence_context_size: 30,
        frequency_context_size: 30,
        repetition_context_size: 30,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("chat.completion");
    const content = body.choices[0].message.content as string;
    expect(typeof content).toBe("string");
    expect(content.length).toBeGreaterThan(0);
    // still coherent text, not replacement garbage
    expect(content).not.toContain("�");
  }, 120_000);

  test("invalid logit_bias → 400 with mlx-lm's coercion error", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "hi" }],
        max_tokens: 4,
        logit_bias: { notAnId: 1 },
      }),
    });
    expect(res.status).toBe(400);
    const body = (await res.json()) as any;
    expect(body.error.message).toContain("logit_bias must be a dict of int to float");
  });

  test("min_p on /v1/completions accepted too", async () => {
    const res = await fetch(`${base}/v1/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        prompt: "Hello",
        max_tokens: 6,
        temperature: 0.7,
        seed: 3,
        min_p: 0.1,
        logit_bias: { "5": 1.0 },
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("text_completion");
    expect(body.choices[0].text.length).toBeGreaterThan(0);
  }, 120_000);

  // --- serve --adapter wiring (ServerOptions.defaultAdapter) ---------------
  // The CLI flag mounts the adapter then sets serverOptions.defaultAdapter;
  // here we verify the server side: the default flows into every generation's
  // adapter resolution, and a request's explicit `adapter` (incl. "none")
  // overrides it. Using an unmounted id makes the wiring observable without
  // needing a real adapter on disk: resolveSpec must fail loudly (400).

  test("defaultAdapter is applied when the request sends no adapter", async () => {
    const withDefault = createServer(ctx, 0, { defaultAdapter: "phantom-adapter" });
    try {
      const dBase = `http://localhost:${withDefault.port}`;
      // no adapter field → default kicks in → unknown id → 400
      const res = await fetch(`${dBase}/v1/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ prompt: "Hello", max_tokens: 4, temperature: 0 }),
      });
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.error.message).toContain("phantom-adapter");

      // explicit "none" overrides the default → base model serves fine
      const none = await fetch(`${dBase}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "Say hi." }],
          max_tokens: 4,
          temperature: 0,
          adapter: "none",
        }),
      });
      expect(none.status).toBe(200);
    } finally {
      withDefault.stop(true);
    }
  }, 120_000);
});
