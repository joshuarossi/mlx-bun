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

// Fast tier: logprobs param validation is pure (mlx-lm's _validate calls:
// logprobs bool; top_logprobs int in [0, 11] or the -1 "unset" sentinel).
describe("validateLogprobsParams (mlx-lm validation)", async () => {
  const { validateLogprobsParams } = await import("../src/server");

  test("defaults (absent) are valid", () => {
    expect(validateLogprobsParams({})).toBeNull();
  });

  test("valid combinations pass", () => {
    expect(validateLogprobsParams({ logprobs: true })).toBeNull();
    expect(validateLogprobsParams({ logprobs: false, top_logprobs: 0 })).toBeNull();
    expect(validateLogprobsParams({ top_logprobs: 11 })).toBeNull();
    expect(validateLogprobsParams({ top_logprobs: -1 })).toBeNull(); // whitelist sentinel
  });

  test("mlx-lm's exact rejection messages", () => {
    expect(validateLogprobsParams({ logprobs: 3 })).toBe("logprobs must be of type bool");
    expect(validateLogprobsParams({ logprobs: "yes" })).toBe("logprobs must be of type bool");
    expect(validateLogprobsParams({ top_logprobs: 1.5 })).toBe("top_logprobs must be of type int");
    expect(validateLogprobsParams({ top_logprobs: "5" })).toBe("top_logprobs must be of type int");
    expect(validateLogprobsParams({ top_logprobs: -2 })).toBe("top_logprobs must be at least 0");
    // mlx-lm caps at 11 (server.py max_val=11), not OpenAI's 20
    expect(validateLogprobsParams({ top_logprobs: 12 })).toBe("top_logprobs must be at most 11");
    expect(validateLogprobsParams({ top_logprobs: 20 })).toBe("top_logprobs must be at most 11");
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

  // --- logprobs / top_logprobs (mlx_lm.server response block) ---------------
  // Reference shape (server.py generate_response L1317-1327): NOT OpenAI's —
  // entries carry token ids; the top-k form is dict(i[0], top_logprobs=i).
  // Stream chunks never carry logprobs in mlx-lm (its streaming
  // generate_response calls pass no token_logprobs/top_tokens) — mirrored.

  test("chat non-stream, logprobs only: {id, logprob} entries, finite ≤ 0", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Say hi." }],
        max_tokens: 8,
        temperature: 0,
        logprobs: true,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const lp = body.choices[0].logprobs;
    expect(Array.isArray(lp?.content)).toBe(true);
    expect(lp.content.length).toBeGreaterThan(0);
    expect(lp.content.length).toBeLessThanOrEqual(body.usage.completion_tokens);
    for (const e of lp.content) {
      expect(Number.isInteger(e.id)).toBe(true);
      expect(Number.isFinite(e.logprob)).toBe(true);
      expect(e.logprob).toBeLessThanOrEqual(0);
      // the logprobs-only form has no token strings / top lists (mlx-lm's elif branch)
      expect(e.token).toBeUndefined();
      expect(e.top_logprobs).toBeUndefined();
    }
  }, 120_000);

  test("chat non-stream, top_logprobs=5: top-k entries, chosen token is in its own top-k", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Say hi." }],
        max_tokens: 8,
        temperature: 0, // greedy: the sampled token IS the top-1 entry
        logprobs: true,
        top_logprobs: 5,
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    const lp = body.choices[0].logprobs;
    expect(Array.isArray(lp?.content)).toBe(true);
    expect(lp.content.length).toBeGreaterThan(0);
    for (const e of lp.content) {
      // entry = dict(top[0], top_logprobs=top) — id/token/logprob + the list
      expect(Number.isInteger(e.id)).toBe(true);
      expect(typeof e.token).toBe("string");
      expect(Number.isFinite(e.logprob)).toBe(true);
      expect(e.logprob).toBeLessThanOrEqual(0);
      expect(Array.isArray(e.top_logprobs)).toBe(true);
      expect(e.top_logprobs.length).toBeGreaterThan(0);
      expect(e.top_logprobs.length).toBeLessThanOrEqual(5);
      // sorted descending; entry mirrors the first element
      const lps = e.top_logprobs.map((t: any) => t.logprob);
      for (let i = 1; i < lps.length; i++) expect(lps[i - 1]).toBeGreaterThanOrEqual(lps[i]);
      expect(e.top_logprobs[0].id).toBe(e.id);
      expect(e.top_logprobs[0].logprob).toBe(e.logprob);
      // greedy ⇒ the chosen (emitted) token appears among its own top-k
      expect(e.top_logprobs.some((t: any) => t.id === e.id)).toBe(true);
      for (const t of e.top_logprobs) {
        expect(Number.isInteger(t.id)).toBe(true);
        expect(typeof t.token).toBe("string");
        expect(t.logprob).toBeLessThanOrEqual(0);
      }
    }
  }, 120_000);

  test("chat stream with logprobs: chunks carry NO logprobs (mirrors mlx_lm.server)", async () => {
    const res = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "Say hi." }],
        max_tokens: 8,
        temperature: 0,
        stream: true,
        logprobs: true,
        top_logprobs: 5,
      }),
    });
    expect(res.status).toBe(200);
    const { events, chunks } = sse(await res.text());
    expect(events.at(-1)).toBe("[DONE]");
    expect(chunks.length).toBeGreaterThan(0);
    for (const c of chunks) expect(c.choices?.[0]?.logprobs).toBeUndefined();
  }, 120_000);

  test("/v1/completions with logprobs: same mlx-lm block on the text object", async () => {
    const res = await fetch(`${base}/v1/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        prompt: "One two three",
        max_tokens: 6,
        temperature: 0,
        logprobs: true, // BOOL, as mlx_lm.server takes it (not OpenAI's legacy int)
      }),
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as any;
    expect(body.object).toBe("text_completion");
    const lp = body.choices[0].logprobs;
    expect(Array.isArray(lp?.content)).toBe(true);
    expect(lp.content.length).toBeGreaterThan(0);
    for (const e of lp.content) {
      expect(Number.isInteger(e.id)).toBe(true);
      expect(e.logprob).toBeLessThanOrEqual(0);
    }
  }, 120_000);

  test("out-of-range / mistyped logprobs params → 400 with mlx-lm's message", async () => {
    const cases: Array<[Record<string, unknown>, string]> = [
      [{ top_logprobs: 12 }, "top_logprobs must be at most 11"],
      [{ top_logprobs: -2 }, "top_logprobs must be at least 0"],
      [{ top_logprobs: 2.5 }, "top_logprobs must be of type int"],
      [{ logprobs: 3 }, "logprobs must be of type bool"],
    ];
    for (const [fields, msg] of cases) {
      const res = await fetch(`${base}/v1/chat/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          messages: [{ role: "user", content: "hi" }],
          max_tokens: 4,
          ...fields,
        }),
      });
      expect(res.status).toBe(400);
      const body = (await res.json()) as any;
      expect(body.error.message).toBe(msg);
      // same validation on /v1/completions
      const res2 = await fetch(`${base}/v1/completions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ prompt: "hi", max_tokens: 4, ...fields }),
      });
      expect(res2.status).toBe(400);
    }
    // -1 is mlx-lm's whitelisted "unset" sentinel → accepted
    const ok = await fetch(`${base}/v1/chat/completions`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        messages: [{ role: "user", content: "hi" }],
        max_tokens: 4,
        temperature: 0,
        top_logprobs: -1,
      }),
    });
    expect(ok.status).toBe(200);
    const okBody = (await ok.json()) as any;
    expect(okBody.choices[0].logprobs).toBeUndefined();
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
