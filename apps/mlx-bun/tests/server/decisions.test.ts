import { expect, test } from "bun:test";
import { gzipSync, zstdCompressSync } from "node:zlib";
import { decisionAnswer, decisionCandidates, decisionConfidence, decisionMessages, parseJevDecision, parseOpenAiDecision } from "../../src/server/decision-wire";
import { createDecisionRoutes } from "../../src/server/decision-routes";
import { readDecisionBody } from "../../src/server/decision-body";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { ModelBinding } from "../../src/engine/model-binding";
import { decisionExampleRequests, runDecisionExample } from "../../scripts/decision-example";

const encode = (text: string) => [...new TextEncoder().encode(text)];
const tokenizer = { encode, eosTokenId: 0 };
const context = { modelId: "local/test", tokenizer, model: { config: { eosTokenIds: [0] } }, genDefaults: {} } as unknown as LoadedModelContext;
function post(path: string, body: unknown, signal?: AbortSignal) {
  return new Request(`http://local${path}`, { method: "POST", body: JSON.stringify(body), signal });
}
function fixture(options: { contextLimit?: number; fail?: boolean; unsupported?: boolean; abort?: AbortController } = {}) {
  const calls: Parameters<NonNullable<ModelBinding["decide"]>>[0][] = [];
  let scheduled = 0, running = false, disposed = 0, adapterEnters = 0, adapterRestores = 0;
  const routes = createDecisionRoutes({ context,
    binding: {
      ...(!options.unsupported ? { decide: async (input: Parameters<NonNullable<ModelBinding["decide"]>>[0]) => {
        calls.push(input);
        await input.execute!(async () => { expect(running).toBe(true); if (options.fail) throw new Error("scoring failed"); });
        options.abort?.abort();
        return input.candidates.length === 2 ? [0.1, 0.9] : [0.1, 0.7, 0.2];
      } } : {}),
      gateway: { bindAdapterContext: () => ({ key: "test", enter: () => { adapterEnters++; return () => { adapterRestores++; }; } }) } as unknown as ModelBinding["gateway"],
    },
    gateway: { runExclusive: async () => { throw new Error("must use the scheduler work queue"); },
      runPreparation: async (work, signal) => { signal?.throwIfAborted(); scheduled++; running = true; try { return await work(); } finally { running = false; } } },
  }, { contextLimit: options.contextLimit ?? 10000,
    buildPrompt: async (body, _tools, ownership) => {
      expect(body.reasoning_effort).toBe("none");
      expect(body.chat_template_kwargs?.enable_thinking).toBe(false);
      ownership.own({ dispose() { disposed++; } });
      return { promptIds: [8, 9], vision: undefined, diffusionPixels: null, startInThinking: false, probeStableLen: false };
    } });
  return { routes, calls, stats: () => ({ scheduled, disposed, adapterEnters, adapterRestores }) };
}

test("provider requests normalize to identical model inputs, with IDs excluded from inference", () => {
  const bodies = decisionExampleRequests();
  const a = parseOpenAiDecision(bodies.openai), b = parseJevDecision(bodies.jev);
  expect(a.input).toEqual(b.input);
  for (let i = 0; i < a.questions.length; i++) {
    expect(decisionMessages(a.input, a.questions[i]!)).toEqual(decisionMessages(b.input, b.questions[i]!));
    expect(decisionCandidates(tokenizer, a.questions[i]!, 0)).toEqual(decisionCandidates(tokenizer, b.questions[i]!, 0));
  }
  const renamed = structuredClone(a.questions[1]!); renamed.name = "another identifier";
  expect(decisionMessages(a.input, renamed)).toEqual(decisionMessages(a.input, a.questions[1]!));
});

test("full supplied answer sequences are preserved, including string/boolean collisions and terminators", () => {
  const q = parseOpenAiDecision({ model: "m", input: "x", questions: [{ type: "choice", instructions: "q",
    choices: [{ value: "true" }, { value: true }, { value: "a multi-token supplied answer" }, { value: "" }] }] }).questions[0]!;
  const tokens = decisionCandidates(tokenizer, q, 0);
  expect(tokens).toEqual(['"true"', 'true', '"a multi-token supplied answer"', '""'].map(value => [...encode(value), 0]));
  expect(new Set(tokens.map(tokens => JSON.stringify(tokens))).size).toBe(4);
  expect(decisionAnswer(q, [0.1, 0.7, 0.1, 0.1], false).choice).toBe(true);
});

test("choice and ordered-score confidence follow the documented Jev formulas", () => {
  expect(decisionConfidence([0.6, 0.3, 0.1], false)).toBeCloseTo(0.4);
  expect(decisionConfidence([1 / 3, 1 / 3, 1 / 3], false)).toBe(0);
  expect(decisionConfidence([0, 0.5, 0.5], true)).toBeCloseTo(0.25);
  expect(decisionConfidence([0.5, 0, 0.5], true)).toBe(0);
});

test("both wire protocols run scheduled scoring, echo the served model, and report zero generated tokens", async () => {
  const f = fixture(), bodies = decisionExampleRequests();
  const a = await (await f.routes.handle(post("/v1/decisions", bodies.openai)))!.json();
  const b = await (await f.routes.handle(post("/v1/systemone", bodies.jev)))!.json();
  expect(a.model).toBe("local/test"); expect(b.model).toBe(a.model);
  expect(a.answers[0]).toEqual({ type: "predicate", name: "refund", probability: 0.9 });
  expect(b.answers.refund).toEqual({ type: "noul", noul: 0.9 });
  expect(a.answers[1].choice).toBe(b.answers.department.choice);
  expect(b.answers.department.probabilities).toEqual({ "billing and refunds": 0.1, "technical support": 0.7, "sales inquiries": 0.2 });
  expect(a.answers[2].score).toBeCloseTo(1.1); expect(b.answers.severity.score).toBeCloseTo(1.1);
  expect(a.usage.output_tokens).toBe(0); expect(b.usage.output_tokens).toBe(0);
  expect(a.usage.total_tokens).toBe(a.usage.input_tokens); expect(a.usage.input_tokens).toBe(b.usage.input_tokens);
  expect(f.calls).toHaveLength(6);
  expect(f.stats()).toEqual({ scheduled: 6, disposed: 6, adapterEnters: 6, adapterRestores: 6 });
});

test("bad schemas fail before scoring, and unsupported bindings are explicit", async () => {
  const f = fixture();
  for (const body of [null, {}, { model: "m", input: "x", questions: [] },
    { model: "m", input: "x", questions: [{ type: "choice", instructions: "q", choices: [{ value: "x" }, { value: "x" }] }] }])
    expect((await f.routes.handle(post("/v1/decisions", body)))!.status).toBe(400);
  expect((await f.routes.handle(post("/v1/systemone", { model: "m", state: "x", questions: { q: { type: "score", instructions: "q", criteria: ["x"] } } })))!.status).toBe(422);
  expect(f.calls).toHaveLength(0);
  const no = fixture({ unsupported: true });
  expect((await no.routes.handle(post("/v1/decisions", decisionExampleRequests().openai)))!.status).toBe(501);
});

test("context rejection and cancellation release preparation and adapter scopes", async () => {
  const f = fixture({ contextLimit: 2 });
  expect((await f.routes.handle(post("/v1/decisions", decisionExampleRequests().openai)))!.status).toBe(400);
  expect(f.calls).toHaveLength(0); expect(f.stats().disposed).toBe(1);
  const abort = new AbortController(), cancelled = fixture({ abort });
  expect((await cancelled.routes.handle(post("/v1/decisions", decisionExampleRequests().openai, abort.signal)))!.status).toBe(499);
  expect(cancelled.calls).toHaveLength(1);
  expect(cancelled.stats()).toEqual({ scheduled: 1, disposed: 1, adapterEnters: 1, adapterRestores: 1 });
});

test("Jev gzip/zstd and multipart bodies parse without changing routing fields", async () => {
  const body = decisionExampleRequests().jev;
  for (const [encoding, compress] of [["gzip", gzipSync], ["zstd", zstdCompressSync]] as const) {
    const request = new Request("http://local/v1/systemone", { method: "POST", headers: { "content-encoding": encoding }, body: compress(JSON.stringify(body)) });
    expect(await readDecisionBody(request)).toEqual(body);
  }
  const form = new FormData();
  form.set("request", JSON.stringify({ ...body, assets: { photo: { part: "upload" } } }));
  form.set("upload", new File([new Uint8Array([1, 2, 3])], "x.png", { type: "image/png" }));
  const parsed = await readDecisionBody(new Request("http://local/v1/systemone", { method: "POST", body: form })) as any;
  expect(parsed.assets.photo).toEqual({ format: "png", data_base64: "AQID" });
});

test("Jev structured criteria and referenced images survive normalization, and unused images fail", () => {
  const body = { model: "m", state: { camera: "photo" }, assets: { photo: { format: "png", data_base64: "AQID" } },
    questions: { check: { type: "noul", instructions: { question: "Is there a dog?" }, criteria: { true: ["Dog present"], false: "No dog" } } } };
  const parsed = parseJevDecision(body);
  expect(JSON.stringify(parsed.input)).toContain("data:image/png;base64,AQID");
  expect(parsed.questions[0]!.options[1]!.description).toBe('["Dog present"]');
  expect(() => parseJevDecision({ ...body, state: "no reference" })).toThrow("every image asset");
});

test("the runnable example exercises both decision APIs and generation", async () => {
  const f = fixture();
  const send = (async (url: URL | string, init: RequestInit) => {
    const request = new Request(url, init);
    if (new URL(request.url).pathname === "/v1/chat/completions") return Response.json({ model: "local/test", choices: [] });
    return (await f.routes.handle(request))!;
  }) as typeof fetch;
  const result = await runDecisionExample("http://local", "local", send);
  expect(result.openai.answers).toHaveLength(3); expect(Object.keys(result.jev.answers)).toHaveLength(3);
  expect(result.generation.model).toBe("local/test");
});
