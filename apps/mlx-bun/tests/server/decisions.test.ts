import { expect, test } from "bun:test";
import { gzipSync, zstdCompressSync } from "node:zlib";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { ChatTemplate } from "@mlx-bun/inference/input";
import { fetchMediaBytes } from "@mlx-bun/inference/input/media-fetch";
import { createPreparationExecutor } from "../../src/engine/preparation";
import type { ModelPromptBuilder } from "../../src/server/prompt-contracts";
import { decisionAnswer, decisionCandidates, decisionConfidence, decisionMessages, parseJevDecision, parseOpenAiDecision } from "../../src/server/decision-wire";
import { createDecisionRoutes } from "../../src/server/decision-routes";
import { readDecisionBody } from "../../src/server/decision-body";
import type { LoadedModelContext } from "../../src/engine/model-host";
import type { ModelBinding } from "../../src/engine/model-binding";
import { decisionExampleModel, decisionExampleRequests, runDecisionExample } from "../../scripts/decision-example";

const encode = (text: string) => [...new TextEncoder().encode(text)];
const tokenizer = { encode, decode: (ids: number[]) => new TextDecoder().decode(new Uint8Array(ids)), eosTokenId: 0 };
const context = { modelId: "local/test", tokenizer, model: { config: { eosTokenIds: [0] } }, genDefaults: {} } as unknown as LoadedModelContext;
function post(path: string, body: unknown, signal?: AbortSignal) {
  return new Request(`http://local${path}`, { method: "POST", body: JSON.stringify(body), signal });
}
function fixture(options: { contextLimit?: number; fail?: boolean; unsupported?: boolean; abort?: AbortController;
  context?: LoadedModelContext; buildPrompt?: ModelPromptBuilder;
  decide?: NonNullable<ModelBinding["decide"]> } = {}) {
  const calls: Parameters<NonNullable<ModelBinding["decide"]>>[0][] = [];
  let scheduled = 0, running = false, disposed = 0, adapterEnters = 0, adapterRestores = 0;
  const preparation = createPreparationExecutor(async (work, signal) => {
    signal?.throwIfAborted(); scheduled++; running = true;
    try { return await work(); } finally { running = false; }
  }, 1);
  const routes = createDecisionRoutes({ context: options.context ?? context,
    binding: {
      ...(!options.unsupported ? { decide: async (input: Parameters<NonNullable<ModelBinding["decide"]>>[0]) => {
        calls.push(input);
        if (options.decide) return options.decide(input);
        await input.execute!(async () => { expect(running).toBe(true); if (options.fail) throw new Error("scoring failed"); });
        options.abort?.abort();
        return input.candidates.length === 2 ? [0.1, 0.9] : [0.1, 0.7, 0.2];
      } } : {}),
      gateway: { bindAdapterContext: () => ({ key: "test", enter: () => { adapterEnters++; return () => { adapterRestores++; }; } }) } as unknown as ModelBinding["gateway"],
    },
    preparation,
  }, { contextLimit: options.contextLimit ?? 10000,
    buildPrompt: options.buildPrompt ?? (async (body, _tools, ownership) => {
      expect(body.reasoning_effort).toBe("none");
      expect(body.chat_template_kwargs?.enable_thinking).toBe(false);
      ownership.own({ dispose() { disposed++; } });
      return { promptIds: [8, 9], vision: undefined, diffusionPixels: null, startInThinking: false, probeStableLen: false };
    }) });
  return { routes, calls, preparation, stats: () => ({ scheduled, disposed, adapterEnters, adapterRestores }) };
}

async function withTemplate(source: string, work: (template: ChatTemplate) => Promise<void>) {
  const directory = mkdtempSync(join(tmpdir(), "mlx-decision-template-"));
  try {
    writeFileSync(join(directory, "tokenizer_config.json"), JSON.stringify({ chat_template: source, eos_token: "\0" }));
    await work(await ChatTemplate.load(directory));
  } finally { rmSync(directory, { recursive: true, force: true }); }
}
const turn = () => new Promise<void>(resolve => setImmediate(resolve));
const emptyPrompt = { promptIds: [8, 9], vision: undefined, diffusionPixels: null, startInThinking: false, probeStableLen: false };

test("both protocols render through an alternation-enforcing template, including multiple input messages", async () => {
  await withTemplate(`{% for message in messages %}{% if (message.role == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate') }}{% endif %}{{ message.content }}{% if message.role == 'assistant' %}{{ eos_token }}{% endif %}{% endfor %}`, async template => {
    const f = fixture({ context: { ...context, template }, buildPrompt: async (body, _, __, prep) => {
      expect(body.messages).toHaveLength(1);
      expect(body.messages[0]!.content).toContain("first");
      expect(body.messages[0]!.content).toContain("second");
      return { ...emptyPrompt, promptIds: prep.promptIdsFor(body, null).ids };
    } });
    const a = post("/v1/decisions", { model: "local/test", input: [{ role: "user", content: "first" }, { role: "user", content: "second" }],
      questions: [{ type: "predicate", instructions: "q" }] });
    const b = post("/v1/systemone", { model: "local/test", state: ["first", "second"], questions: { q: { type: "noul", instructions: "q" } } });
    for (const request of [a, b]) expect((await f.routes.handle(request))!.status).toBe(200);
  });
});

test("merging decision input preserves text and media order, including question images", () => {
  const parsed = parseOpenAiDecision({ model: "m", input: [
    { role: "user", content: [{ type: "input_text", text: "before" }, { type: "input_image", image_url: "photo" }] },
    { role: "user", content: "after" },
  ], questions: [{ type: "predicate", instructions: "q" }] });
  parsed.questions[0]!.images = [{ reference: "question", url: "question-photo" }];
  const messages = decisionMessages(parsed.input, parsed.questions[0]!);
  expect(messages).toHaveLength(1);
  const parts = messages[0]!.content as Record<string, unknown>[];
  expect(parts.slice(0, 4)).toEqual([{ type: "text", text: "before" }, { type: "image_url", image_url: { url: "photo" } },
    { type: "text", text: "\n\n" }, { type: "text", text: "after" }]);
  expect(parts.at(-1)).toEqual({ type: "image_url", image_url: { url: "question-photo" } });
});

test("scoring uses the template turn end rather than generic EOS and excludes post-stop layout", async () => {
  await withTemplate(`{% for message in messages %}{{ message.content }}<turn|>\n{% endfor %}`, async template => {
    const f = fixture({ context: { ...context, template, model: { config: { eosTokenIds: [0, 106] } },
      tokenizer: { ...tokenizer, encode: (text: string) => text.split(/(<eos>|<turn\|>)/).flatMap(piece =>
        piece === "<turn|>" ? [106] : piece === "<eos>" ? [0] : encode(piece)),
      decode: (ids: number[]) => ids.map(id => id === 106 ? "<turn|>" : "<eos>").join("") },
    } as unknown as LoadedModelContext });
    expect((await f.routes.handle(post("/v1/decisions", { model: "m", input: "x", questions: [{ type: "predicate", instructions: "q" }] })))!.status).toBe(200);
    expect(f.calls[0]!.candidates).toEqual([[...encode("false"), 106], [...encode("true"), 106]]);
  });
});

test("answer and template ending are tokenized together at whitespace boundaries", () => {
  const q = parseJevDecision({ model: "m", state: "x", questions: { q: { type: "choice", criteria: { yes: null } } } }).questions[0]!;
  const merged = { encode: (text: string) => text === '"yes"\n<end>' ? [100, 101] : encode(text) };
  expect(decisionCandidates(merged, q, "\n<end>")).toEqual([[100, 101]]);
});

test("bad media returns a client error and releases prepared resources and reservations", async () => {
  let released = 0;
  const f = fixture({ buildPrompt: async (_body, _tools, ownership) => {
    ownership.own({ dispose() { released++; } });
    await fetchMediaBytes("data:image/png,abc", "image");
    throw new Error("unreachable");
  } });
  const body = { model: "m", input: [{ role: "user", content: [{ type: "input_image", image_url: "data:image/png,abc" }] }],
    questions: [{ type: "predicate", instructions: "q" }] };
  for (let i = 0; i < 2; i++) {
    const response = (await f.routes.handle(post("/v1/decisions", body)))!;
    expect(response.status).toBe(400);
    expect((await response.json()).error.message).toContain("data: URL must be base64");
  }
  expect(released).toBe(2); expect(f.calls).toHaveLength(0);
});

test("decision admission bounds retained preparations, returns 429 on overflow, and cancels queued requests", async () => {
  const entered = Promise.withResolvers<void>(), finish = Promise.withResolvers<void>();
  let built = 0;
  const f = fixture({ buildPrompt: async () => { built++; return emptyPrompt; },
    decide: async () => { entered.resolve(); await finish.promise; return [0.5, 0.5]; } });
  const request = (signal?: AbortSignal) => f.routes.handle(post("/v1/decisions", { model: "m", input: "x",
    questions: [{ type: "predicate", instructions: "q" }] }, signal));
  const active = request(); await entered.promise;
  const controllers = Array.from({ length: 64 }, () => new AbortController());
  const queued = controllers.map(c => request(c.signal));
  try {
    await turn();
    expect(built).toBe(1);
    expect((await request())!.status).toBe(429);
    controllers[0]!.abort(); expect((await queued[0])!.status).toBe(499);
    const replacement = new AbortController(), waiting = request(replacement.signal);
    await turn(); expect(built).toBe(1);
    replacement.abort(); expect((await waiting)!.status).toBe(499);
  } finally {
    controllers.forEach(c => c.abort()); finish.resolve();
    await Promise.all([active, ...queued]); f.preparation.close();
  }
});

test("an image decision holds the shared media reservation through scoring and releases it on failure", async () => {
  const entered = Promise.withResolvers<void>(), finish = Promise.withResolvers<void>();
  const f = fixture({ decide: async () => { entered.resolve(); await finish.promise; throw new Error("scoring failed"); } });
  // This stands in for a chat request borrowing the very same engine media pool.
  const before = await f.preparation.reserve!("media");
  const request = f.routes.handle(post("/v1/systemone", { model: "m", state: "photo", assets: { photo: { format: "png", data_base64: "AQID" } },
    questions: { q: { type: "noul", instructions: "q" } } }));
  let scoring = false; entered.promise.then(() => { scoring = true; });
  await turn(); expect(scoring).toBe(false);
  before.dispose(); await entered.promise;
  const abort = new AbortController(); let admitted = false;
  const next = f.preparation.reserve!("media", abort.signal).then(lease => { admitted = true; lease.dispose(); });
  try {
    await turn(); expect(admitted).toBe(false);
    finish.resolve(); expect((await request)!.status).toBe(500);
    await next; expect(admitted).toBe(true);
  } finally { finish.resolve(); abort.abort(); f.preparation.close(); }
});

test("provider requests normalize to identical model inputs, with IDs excluded from inference", () => {
  const bodies = decisionExampleRequests();
  const a = parseOpenAiDecision(bodies.openai), b = parseJevDecision(bodies.jev);
  expect(a.input).toEqual(b.input);
  for (let i = 0; i < a.questions.length; i++) {
    expect(decisionMessages(a.input, a.questions[i]!)).toEqual(decisionMessages(b.input, b.questions[i]!));
    expect(decisionCandidates(tokenizer, a.questions[i]!, "\0")).toEqual(decisionCandidates(tokenizer, b.questions[i]!, "\0"));
  }
  const renamed = structuredClone(a.questions[1]!); renamed.name = "another identifier";
  expect(decisionMessages(a.input, renamed)).toEqual(decisionMessages(a.input, a.questions[1]!));
});

test("full supplied answer sequences are preserved, including string/boolean collisions and terminators", () => {
  const q = parseOpenAiDecision({ model: "m", input: "x", questions: [{ type: "choice", instructions: "q",
    choices: [{ value: "true" }, { value: true }, { value: "a multi-token supplied answer" }, { value: "" }] }] }).questions[0]!;
  const tokens = decisionCandidates(tokenizer, q, "\0");
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
  const models: string[] = [];
  const send = (async (url: URL | string, init: RequestInit) => {
    const request = new Request(url, init);
    models.push((await request.clone().json() as { model: string }).model);
    if (new URL(request.url).pathname === "/v1/chat/completions") return Response.json({ model: "local/test", choices: [] });
    return (await f.routes.handle(request))!;
  }) as typeof fetch;
  const result = await runDecisionExample("http://local", "local/test", send);
  expect(result.openai.answers).toHaveLength(3); expect(Object.keys(result.jev.answers)).toHaveLength(3);
  expect(result.generation.model).toBe("local/test");
  expect(models).toEqual(["local/test", "local/test", "local/test"]);
  models.length = 0;
  await runDecisionExample("http://local", undefined, send);
  expect(models).toEqual([decisionExampleModel, decisionExampleModel, decisionExampleModel]);
  expect(decisionExampleModel).toBe("mlx-community/gemma-4-e4b-it-OptiQ-4bit");
});
