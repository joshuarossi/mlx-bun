// Opt-in with real weights: Gemma2 grammar-constrained and adapter requests on
// the shared scheduler. Runs only with MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_APP_TEST_GEMMA2_MODEL naming a cached gemma2 snapshot (for example
// mlx-community/gemma-2-2b-it-4bit); loads the model natively on the GPU.
// The LoRA adapter is generated here with deterministic nonzero weights and
// written to a temporary directory; nothing is committed.
//   B1: the continuous gateway equals direct generation exactly — tokens, the
//       complete logits of every forward call, and every layer's KV after it.
//   B2/B4: rows really execute together (the forward batch dimension reaches
//       the row count), adapter contexts partition groups, equivalent group
//       shapes reproduce each other, and a cancelled row leaves its peers as an
//       equivalent run where that row stops at the same step.
//   HTTP: grammar and adapter chat completions answer 200 through the server
//       (streamed and not), and a client that leaves mid-stream releases its row.
// This is preservation against direct execution in the same tree, not an
// external-oracle claim; the comparison against main runs outside the repo.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { GenerateOptions } from "@mlx-bun/inference/generation";
import type { Cache } from "@mlx-bun/inference/contracts/mlx";
import type { RequestShape } from "../../src/engine/completion";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_APP_TEST_GEMMA2_MODEL;

type Trace = { calls: string[]; batches: { rows: number; adapters: string }[]; firstLogits?: Float32Array };

async function setup(dir: string) {
  const { configureRuntime } = await import("@mlx-bun/inference/runtime/config");
  // Both paths split the prompt tail and skip compiled decode, so they issue
  // the same forward calls; the scheduler reads this snapshot at bind time.
  const restoreRuntime = configureRuntime({ MLX_BUN_PREFILL_TAIL_SPLIT: "1", MLX_BUN_COMPILED_DECODE: "0" });
  const ops = await import("@mlx-bun/mlx/ops");
  const { Dtype } = await import("@mlx-bun/mlx");
  const { loadContext } = await import("../../src/engine/model-host");
  const { modelServingBinding } = await import("../../src/engine/model-serving");
  const { GenerationGateway } = await import("../../src/engine/generation-gateway");
  const { createRequestPrep } = await import("../../src/server/request-prep");
  const { generate } = await import("@mlx-bun/inference/generation");
  const { writeShardedSafetensors } = await import("@mlx-bun/inference/artifacts");
  const { UniversalDenseModel } = await import("@mlx-bun/inference/models/universal");
  const ctx = await loadContext(dir);
  const model = ctx.model as unknown as InstanceType<typeof UniversalDenseModel>;
  expect(model).toBeInstanceOf(UniversalDenseModel);
  expect(model.config.modelType).toBe("gemma2");
  expect(model.args.attnLogitSoftcap).not.toBeNull();

  // Record every forward call: complete logits and each layer's KV afterwards.
  const sha = (value: MlxArray) => { using flat = ops.contiguous(value); return new Bun.CryptoHasher("sha256").update(flat.rawBytes()).digest("hex"); };
  type Readable = { captureDonorRows?(): { keys: MlxArray; values: MlxArray }; temporalView?(): [MlxArray, MlxArray] };
  const kv = (caches: Cache[]) => caches.map(cache => {
    const readable = cache as unknown as Readable;
    const pair = readable.captureDonorRows ? (({ keys, values }) => [keys, values] as const)(readable.captureDonorRows())
      : readable.temporalView?.();
    // Row wrappers used while a joiner prefills expose no readable view; their
    // class and length still pin the call sequence of equivalent runs.
    if (!pair) return `${cache.constructor.name}@${cache.offset}`;
    try { return `${sha(pair[0])}/${sha(pair[1])}`; } finally { pair[0].dispose(); pair[1].dispose(); }
  }).join(" ");
  // Every graph step records the KV after it; every logits projection (both
  // paths project through logitsFromHidden) records the complete logits.
  let trace: Trace | null = null;
  const forward = model.forward.bind(model), hidden = model.forwardHidden.bind(model);
  const project = model.logitsFromHidden.bind(model);
  const step = (kind: string, input: unknown, out: MlxArray, caches: Cache[]) => {
    if (!trace) return;
    const rows = Array.isArray(input) ? 1 : (input as MlxArray).shape[0]!;
    trace.batches.push({ rows, adapters: model.loraState.active.join("+") });
    trace.calls.push(`${kind} ${out.shape.join("x")} kv ${kv(caches)}`);
  };
  model.forward = (tokens, caches) => { const out = forward(tokens, caches); step("forward", tokens, out, caches); return out; };
  model.forwardHidden = (ids, caches) => { const out = hidden(ids, caches); step("hidden", ids, out, caches); return out; };
  model.logitsFromHidden = (h) => {
    const out = project(h);
    if (trace) {
      if (!trace.firstLogits) { using wide = out.astype(Dtype.float32); trace.firstLogits = wide.toFloat32(); }
      trace.batches.push({ rows: out.shape[0]!, adapters: model.loraState.active.join("+") });
      trace.calls.push(`logits ${out.shape.join("x")} ${sha(out)} adapters ${model.loraState.active.join("+")}`);
    }
    return out;
  };

  // A deterministic nonzero LoRA over every attention q/v projection.
  const adapterDir = mkdtempSync(join(tmpdir(), "mlx-bun-gemma2-lora-"));
  const tensors: { name: string; array: MlxArray }[] = [];
  for (const [path, linear] of model.loraTargets()) {
    if (!/self_attn\.(q|v)_proj$/.test(path)) continue;
    const rank = 4, seed = tensors.length;
    const values = (count: number, amplitude: number, offset: number) =>
      Float32Array.from({ length: count }, (_, i) => Math.sin(i * 0.37 + offset + seed) * amplitude);
    const { MlxArray } = await import("@mlx-bun/mlx/array");
    using a = MlxArray.fromFloat32(values(linear.inFeatures * rank, 0.05, 1), [linear.inFeatures, rank]);
    using b = MlxArray.fromFloat32(values(rank * linear.outFeatures, 0.05, 2), [rank, linear.outFeatures]);
    tensors.push({ name: `${path}.lora_a`, array: a.astype(Dtype.bfloat16) }, { name: `${path}.lora_b`, array: b.astype(Dtype.bfloat16) });
  }
  expect(tensors.length).toBeGreaterThan(0);
  writeShardedSafetensors(adapterDir, tensors);
  for (const { array } of tensors) array.dispose();
  renameSync(join(adapterDir, "model.safetensors"), join(adapterDir, "adapters.safetensors"));
  writeFileSync(join(adapterDir, "adapter_config.json"), JSON.stringify({
    fine_tune_type: "lora", lora_parameters: { rank: 4, scale: 2.0, dropout: 0.0 } }));
  await ctx.adapters.mount("generated-lora", adapterDir);

  const prep = createRequestPrep({ ctx, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined });
  const binding = await modelServingBinding(ctx);
  // One gateway per scenario, closed before the next: an idle scheduler still
  // holding an adapter context must not overlap a direct generation that
  // shares the model's adapter state (serving never runs both on one model).
  const withGateway = async <T>(capacity: number, run: (gateway: InstanceType<typeof GenerationGateway>) => Promise<T>) => {
    const gateway = new GenerationGateway(binding.gateway, capacity);
    try { return await run(gateway); } finally { await gateway.close(); }
  };
  const prompt = (text: string) => prep.promptIdsFor({ messages: [{ role: "user", content: text }] } as never, null).ids;
  const grammar = async (body: Record<string, unknown>) => {
    const compiled = await prep.compileGrammarForRequest({ messages: [], ...body } as never);
    if (!compiled.controller) throw new Error(`grammar did not compile: ${compiled.degradeHint}`);
    return compiled.controller;
  };
  const shape = (options: GenerateOptions): RequestShape => ({ hasVision: false, hasAdapters: !!options.adapters?.length,
    hasRepetitionPenalty: false, userSeed: false, kvQuant: false, turboQuant: false, hasLogitsExtras: false,
    hasGrammar: !!options.grammar, wantsLogprobs: false, hasDraft: false });
  const traced = async <T>(run: () => Promise<T>) => {
    trace = { calls: [], batches: [] };
    try { const value = await run(); return { value, trace: trace! }; } finally { trace = null; }
  };
  return {
    ctx, prompt, grammar, withGateway, adapterDir,
    direct: (ids: number[], options: GenerateOptions) => traced(async () => {
      const tokens: number[] = [];
      for await (const token of generate(model as never, ids, options)) tokens.push(token.token);
      return tokens;
    }),
    continuous: (g: InstanceType<typeof GenerationGateway>, ids: number[], options: GenerateOptions, signal?: AbortSignal,
      onToken?: (token: number, emitted: number) => void | boolean) => {
      const tokens: number[] = [];
      const request = shape(options);
      // A consumer returning false stops its row after that token.
      return g.run(ids, options, token => { tokens.push(token); return onToken?.(token, tokens.length); }, undefined,
        request, g.place(request, options), signal).then(() => tokens);
    },
    traced,
    decode: (tokens: number[]) => ctx.tokenizer.decode(tokens),
    async close() {
      ctx.dispose(); rmSync(adapterDir, { recursive: true, force: true }); restoreRuntime();
    },
  };
}

const schema = { type: "object", properties: { city: { type: "string", maxLength: 16 }, rating: { enum: [1, 2, 3, 4, 5] } },
  required: ["city", "rating"], additionalProperties: false };
const jsonSchema = { response_format: { type: "json_schema", json_schema: { name: "review", schema } } };
/** The schema, checked in full: exactly these keys, a bounded city string, a rating from the enum. */
function expectReview(text: string) {
  const value = JSON.parse(text) as Record<string, unknown>;
  expect(Object.keys(value).toSorted()).toEqual(["city", "rating"]);
  expect(typeof value.city).toBe("string");
  expect((value.city as string).length).toBeLessThanOrEqual(16);
  expect([1, 2, 3, 4, 5]).toContain(value.rating as number);
}

describe.skipIf(!native || !modelDir)("Gemma2 grammar and adapters on the shared scheduler", () => {
  let env: Awaited<ReturnType<typeof setup>>;
  beforeAll(async () => { env = await setup(modelDir!); }, 600_000);
  afterAll(async () => { await env?.close(); });

  test("B1 continuous execution equals direct generation exactly for grammar, a nonzero adapter and both", async () => {
    const ids = env.prompt("Name a city you like and rate it from 1 to 5 as JSON.");
    const cases: [string, () => Promise<GenerateOptions>][] = [
      ["json schema", async () => ({ maxTokens: 80, temperature: 0, grammar: await env.grammar(jsonSchema) })],
      ["ebnf", async () => ({ maxTokens: 16, temperature: 0, grammar: await env.grammar({ guided_grammar: 'root ::= ("yes" | "no") ", " [a-z] [a-z] [a-z]*' }) })],
      ["choice", async () => ({ maxTokens: 8, temperature: 0, grammar: await env.grammar({ guided_choice: ["Paris", "Lisbon", "Kyoto"] }) })],
      ["adapter", async () => ({ maxTokens: 24, temperature: 0, adapters: ["generated-lora"] })],
      ["json schema and adapter", async () => ({ maxTokens: 80, temperature: 0, adapters: ["generated-lora"], grammar: await env.grammar(jsonSchema) })],
    ];
    for (const [name, options] of cases) {
      const direct = await env.direct(ids, await options());
      const shared = await env.withGateway(1, async gateway => env.traced(async () => env.continuous(gateway, ids, await options())));
      expect(shared.value, `${name} tokens`).toEqual(direct.value);
      // The scheduler pipelines one decode step ahead and discards it when the
      // row finishes; every call direct generation made is matched exactly.
      const extra = shared.trace.calls.slice(direct.trace.calls.length);
      expect(extra.filter(call => !call.startsWith("logits")).length, `${name} lookahead steps`).toBeLessThanOrEqual(1);
      expect(extra.filter(call => call.startsWith("logits")).length, `${name} lookahead logits`).toBeLessThanOrEqual(1);
      expect(shared.trace.calls.slice(0, direct.trace.calls.length), `${name} logits and KV`).toEqual(direct.trace.calls);
      expect(shared.trace.batches.every(batch => batch.rows === 1)).toBe(true);
      const text = env.decode(direct.value);
      if (name.startsWith("json schema")) expectReview(text);
      if (name === "ebnf") expect(text).toMatch(/^(yes|no), [a-z]{2,}$/);
      if (name === "choice") expect(["Paris", "Lisbon", "Kyoto"]).toContain(text);
    }
    // The generated adapter measurably changes the model, not a zero or no-op delta.
    const plain = await env.direct(ids, { maxTokens: 1, temperature: 0 });
    const adapted = await env.direct(ids, { maxTokens: 1, temperature: 0, adapters: ["generated-lora"] });
    let maxAbs = 0;
    for (let i = 0; i < plain.trace.firstLogits!.length; i++)
      maxAbs = Math.max(maxAbs, Math.abs(plain.trace.firstLogits![i]! - adapted.trace.firstLogits![i]!));
    expect(maxAbs).toBeGreaterThan(0.5);
    expect(adapted.trace.batches.some(batch => batch.adapters === "generated-lora")).toBe(true);
  }, 900_000);

  test("B2/B4 rows execute together, adapter contexts partition groups, and cancellation leaves equivalent peers", async () => {
    const prompts = ["Name a city you like and rate it from 1 to 5 as JSON.", "Name a European city and rate it from 1 to 5 as JSON.",
      "Name an Asian city and rate it from 1 to 5 as JSON.", "Name a coastal city and rate it from 1 to 5 as JSON."].map(env.prompt);
    const grammarRows = (count: number, abortRow?: number, stopRow?: number, stopAt = 0) => env.withGateway(4, gateway => {
      const abort = new AbortController();
      return env.traced(() => Promise.allSettled(prompts.slice(0, count).map(async (ids, row) =>
        env.continuous(gateway, ids, { maxTokens: row === stopRow ? stopAt : 120, temperature: 0, grammar: await env.grammar(jsonSchema) },
          row === abortRow ? abort.signal : undefined,
          (_, emitted) => { if (row === abortRow && emitted === 3) abort.abort(new Error("client left")); }))));
    });
    for (const count of [2, 4]) {
      const first = await grammarRows(count), second = await grammarRows(count);
      // The group really ran the rows together; an equivalent group reproduces it exactly.
      expect(Math.max(...first.trace.batches.map(batch => batch.rows))).toBe(count);
      expect(second.value).toEqual(first.value);
      expect(second.trace.calls).toEqual(first.trace.calls);
      for (const result of first.value) {
        expect(result.status).toBe("fulfilled");
        expectReview(env.decode((result as PromiseFulfilledResult<number[]>).value));
      }
    }
    // Cancel row 2 after its third token. The scheduler has already dispatched
    // the next pipelined step, so the row leaves one step later than a
    // length stop at three would: the equivalent group stops row 2 after four.
    // Its peers' tokens, logits and KV then match that group exactly.
    const cancelled = await grammarRows(4, 2), stopped = await grammarRows(4, undefined, 2, 4);
    expect(cancelled.value[2]).toMatchObject({ status: "rejected", reason: { message: "client left" } });
    expect(Math.max(...cancelled.trace.batches.map(batch => batch.rows))).toBe(4);
    for (const row of [0, 1, 3]) expect(cancelled.value[row]).toEqual(stopped.value[row]!);
    expect(cancelled.trace.calls).toEqual(stopped.trace.calls);

    // Adapter rows share one context and batch together. A mixed submission is
    // partitioned by context: each context's forward calls (logits and KV) and
    // batch sizes equal the adapter-only or plain-only run of the same shape.
    const rows = (adapterRows: number[], plainRows: number[]) => env.withGateway(4, gateway => env.traced(() => Promise.all([
      ...adapterRows.map(row => env.continuous(gateway, prompts[row]!, { maxTokens: 16, temperature: 0, adapters: ["generated-lora"] })),
      ...plainRows.map(row => env.continuous(gateway, prompts[row]!, { maxTokens: 16, temperature: 0 })),
    ])));
    const adapterOnly = await rows([0, 1], []), plainOnly = await rows([], [2, 3]), mixed = await rows([0, 1], [2, 3]);
    const context = (run: typeof mixed, adapters: string) => ({
      calls: run.trace.calls.filter((_, index) => run.trace.batches[index]!.adapters === adapters),
      rows: run.trace.batches.filter(batch => batch.adapters === adapters).map(batch => batch.rows),
    });
    expect(Math.max(...adapterOnly.trace.batches.map(batch => batch.rows))).toBe(2);
    expect(Math.max(...plainOnly.trace.batches.map(batch => batch.rows))).toBe(2);
    expect(new Set(mixed.trace.batches.map(batch => batch.adapters))).toEqual(new Set(["generated-lora", ""]));
    expect(context(mixed, "generated-lora")).toEqual(context(adapterOnly, "generated-lora"));
    expect(context(mixed, "")).toEqual(context(plainOnly, ""));
    expect(mixed.value.slice(0, 2)).toEqual(adapterOnly.value);
    expect(mixed.value.slice(2)).toEqual(plainOnly.value);
    expect(adapterOnly.value).not.toEqual(plainOnly.value);
  }, 900_000);

  test("plain fill runs inside its adapter context: four-row groups, joins and replacement, partition from base rows, a same-context cancellation control, no leak", async () => {
    const { FillSession } = await import("@mlx-bun/inference/generation/fill");
    const eos = env.ctx.model.config.eosTokenIds;
    const lists = ["red apples, green pears, warm bread, a blue kite", "seven paper boats, an old clock, a quiet train, fresh snow",
      "two owls, a tall pine, a stone bridge, a cold river", "a brass bell, a wool coat, a clay pot, a paper map",
      "a green door, a copper kettle, a linen shirt, a salt marsh"];
    const prompts = lists.map(list => env.prompt(`Here is a list: ${list}. Copy the list exactly, then copy it a second time.`));
    const base = await env.direct(prompts[2]!, { maxTokens: 16, temperature: 0 });
    // Joins and cancellations fire on observed fill state: when a row's fill
    // has accepted its first echo span.
    type Row = { prompt: number; adapter: boolean; joinOnEcho?: number; afterFinish?: number; stopAt?: number; cancelOnEcho?: boolean };
    type Outcome = { tokens: number[]; status: string; echo: number; engagedAt?: number; cancelledAt?: number };
    // One gateway per scenario; every row runs echo fill over its own prompt.
    const scenario = (spec: Row[]) => env.withGateway(4, gateway => env.traced(async () => {
      const outcomes: Outcome[] = spec.map(() => ({ tokens: [], status: "pending", echo: 0 }));
      const sessions: InstanceType<typeof FillSession>[] = [], order: string[] = [], started: Promise<void>[] = [];
      const start = (index: number): Promise<void> => {
        const row = spec[index]!, abort = new AbortController(), outcome = outcomes[index]!;
        const session = sessions[index] = new FillSession({ rows: [], eos,
          echo: { k: 4, maxSpan: 8, maxCandidates: 24, indexMax: 131072 } }, prompts[row.prompt]!);
        const options: GenerateOptions = { maxTokens: 48, temperature: 0, fill: session,
          ...(row.adapter ? { adapters: ["generated-lora"] } : {}) };
        order.push(`submit:${index}`);
        return env.continuous(gateway, prompts[row.prompt]!, options, abort.signal, (token, emitted) => {
          outcome.tokens.push(token); order.push(`token:${index}`);
          if (outcome.engagedAt === undefined && session.stats.echo > 0) {
            outcome.engagedAt = emitted;
            spec.forEach((other, joiner) => { if (other.joinOnEcho === index) started.push(start(joiner)); });
            if (row.cancelOnEcho) { outcome.cancelledAt = emitted; abort.abort(new Error("client left")); }
          }
          return row.stopAt === emitted ? false : undefined;
        }).then(() => { outcome.status = "done"; }, (error: Error) => { outcome.status = error.message; })
          .then(() => {
            outcome.echo = session.stats.echo; order.push(`finish:${index}`);
            spec.forEach((other, next) => { if (other.afterFinish === index) started.push(start(next)); });
          });
      };
      spec.forEach((row, index) => { if (row.joinOnEcho === undefined && row.afterFinish === undefined) started.push(start(index)); });
      for (let seen = -1; seen !== started.length;) { seen = started.length; await Promise.all([...started]); }
      return { outcomes, order };
    }));
    const context = (run: Awaited<ReturnType<typeof scenario>>, adapters: string) => ({
      calls: run.trace.calls.filter((_, index) => run.trace.batches[index]!.adapters === adapters),
      rows: run.trace.batches.filter(batch => batch.adapters === adapters).map(batch => batch.rows),
    });
    const tokens = (run: Awaited<ReturnType<typeof scenario>>) => run.value.outcomes.map(outcome => outcome.tokens);
    const done = (run: Awaited<ReturnType<typeof scenario>>) =>
      expect(run.value.outcomes.map(outcome => outcome.status)).toEqual(run.value.outcomes.map(() => "done"));
    const adapter = (prompt: number, extra: Partial<Row> = {}): Row => ({ prompt, adapter: true, ...extra });
    const plain = (prompt: number): Row => ({ prompt, adapter: false });

    // Four adapter fill rows share one context and one batch; fill engages.
    const four = await scenario([0, 1, 2, 3].map(prompt => adapter(prompt)));
    done(four);
    expect(Math.max(...context(four, "generated-lora").rows)).toBe(4);
    expect(four.value.outcomes.some(outcome => outcome.echo > 0)).toBe(true);
    // A mixed submission partitions by context and reproduces each context alone.
    const adapterPair = await scenario([adapter(0), adapter(1)]), plainPair = await scenario([plain(2), plain(3)]);
    const mixed = await scenario([adapter(0), adapter(1), plain(2), plain(3)]);
    for (const run of [adapterPair, plainPair, mixed]) done(run);
    for (const adapted of [true, false])
      expect(mixed.value.outcomes.filter((_, index) => index < 2 === adapted).some(outcome => outcome.echo > 0)).toBe(true);
    expect(new Set(mixed.trace.batches.map(batch => batch.adapters))).toEqual(new Set(["generated-lora", ""]));
    expect(context(mixed, "generated-lora")).toEqual(context(adapterPair, "generated-lora"));
    expect(context(mixed, "")).toEqual(context(plainPair, ""));
    expect(tokens(mixed)).toEqual([...tokens(adapterPair), ...tokens(plainPair)]);
    // The adapter changes fill output for the same prompts (both runs complete first).
    const adaptedPair = await scenario([adapter(2), adapter(3)]);
    done(adaptedPair);
    expect(tokens(adaptedPair)).not.toEqual(tokens(plainPair));
    // A late join once row 0's fill has accepted an echo span, while row 0 is
    // still active, and a replacement after row 0 finishes, in one context.
    const joined = await scenario([adapter(0), adapter(1, { joinOnEcho: 0 }), adapter(4, { afterFinish: 0 })]);
    const engaged = joined.value.outcomes[0]!.engagedAt;
    if (engaged === undefined) throw new Error("row 0's fill never accepted an echo span; the join did not run");
    done(joined);
    const order = joined.value.order;
    expect(engaged).toBeLessThan(joined.value.outcomes[0]!.tokens.length);
    expect(order.indexOf("submit:1")).toBeGreaterThan(order.indexOf("submit:0"));
    expect(order.indexOf("submit:1")).toBeLessThan(order.indexOf("finish:0"));
    // Row 0 still emits after the joiner's first decoded token: they overlapped in the context's group.
    const joinerDecoded = order.indexOf("token:1", order.indexOf("token:1") + 1);
    expect(joinerDecoded).toBeGreaterThan(-1);
    expect(order.lastIndexOf("token:0")).toBeGreaterThan(joinerDecoded);
    expect(order.indexOf("submit:2")).toBeGreaterThan(order.indexOf("finish:0"));
    expect(Math.max(...context(joined, "generated-lora").rows)).toBeGreaterThanOrEqual(2);
    expect(joined.value.outcomes.slice(1).some(outcome => outcome.echo > 0)).toBe(true);
    // Cancelling row 1 as soon as its fill accepts an echo span, and stopping it
    // at that same emitted count, both remove it before the next forward: its
    // peers in the same context must match that control in tokens and every
    // recorded call.
    const cancelled = await scenario([adapter(0), adapter(1, { cancelOnEcho: true }), adapter(2), adapter(3)]);
    const at = cancelled.value.outcomes[1]!.cancelledAt;
    if (at === undefined) throw new Error("row 1's fill never accepted an echo span; the cancellation case did not run");
    const stopped = await scenario([adapter(0), adapter(1, { stopAt: at }), adapter(2), adapter(3)]);
    expect(cancelled.value.outcomes[1]).toMatchObject({ status: "client left" });
    expect(cancelled.value.outcomes[1]!.tokens).toHaveLength(at);
    expect(cancelled.value.outcomes[1]!.tokens).toEqual(stopped.value.outcomes[1]!.tokens);
    done(stopped);
    expect(stopped.value.outcomes[1]!.tokens).toHaveLength(at);
    expect(Math.max(...context(cancelled, "generated-lora").rows)).toBe(4);
    for (const survivor of [0, 2, 3]) {
      expect(cancelled.value.outcomes[survivor]).toMatchObject({ status: "done" });
      expect(cancelled.value.outcomes[survivor]!.tokens).toEqual(stopped.value.outcomes[survivor]!.tokens);
    }
    expect(context(cancelled, "generated-lora")).toEqual(context(stopped, "generated-lora"));
    // Nothing leaks: adapter state is clear and base generation is unchanged.
    expect(env.ctx.model.loraState!.active).toEqual([]);
    expect((await env.direct(prompts[2]!, { maxTokens: 16, temperature: 0 })).value).toEqual(base.value);
  }, 900_000);

  test("HTTP grammar and adapter completions answer 200, streamed and not, and an abandoned stream releases its row", async () => {
    const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
    const { scanSnapshot } = await import("@mlx-bun/hub/registry");
    const record = await scanSnapshot(modelDir!, "test-gemma2");
    if (!record) throw new Error("Gemma2 path has no loadable checkpoint");
    const root = mkdtempSync(join(tmpdir(), "mlx-bun-gemma2-http-"));
    const options = parseServeOptions({ values: { port: "0", "no-open": true, thinking: "off" }, positionals: [] });
    options.chatPaths = { cwd: root, agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, "jobs.sqlite"), jobsLogs: join(root, "jobs"), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    let app: Awaited<ReturnType<typeof startModelServer>> | undefined;
    try {
      // Observe each chat request's server-side signal through the existing route hook.
      const served: { aborted: boolean }[] = [];
      app = await startModelServer(record, options, { routes: group => ({ async handle(request) {
        if (request.method === "POST" && new URL(request.url).pathname === "/v1/chat/completions") {
          const entry = { aborted: false };
          served.push(entry);
          request.signal.addEventListener("abort", () => { entry.aborted = true; }, { once: true });
        }
        return group.handle(request);
      } }) });
      const base = `http://127.0.0.1:${app.port}`;
      const post = (path: string, body: unknown, signal?: AbortSignal) => fetch(base + path, { method: "POST", signal,
        headers: { "content-type": "application/json" }, body: JSON.stringify(body) });
      const mounted = await post("/v1/adapters", { id: "generated-lora", path: env.adapterDir });
      expect(mounted.status).toBe(200);
      const request = { messages: [{ role: "user", content: "Name a city you like and rate it from 1 to 5 as JSON." }],
        temperature: 0, max_tokens: 120, ...jsonSchema };
      for (const body of [request, { ...request, adapter: "generated-lora" }]) {
        const plain = await post("/v1/chat/completions", body);
        expect(plain.status).toBe(200);
        expectReview((await plain.json()).choices[0].message.content);
        const streamed = await post("/v1/chat/completions", { ...body, stream: true });
        expect(streamed.status).toBe(200);
        let text = "";
        for (const line of (await streamed.text()).split("\n")) {
          if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
          text += JSON.parse(line.slice(6)).choices[0]?.delta?.content ?? "";
        }
        expectReview(text);
      }
      // Leave a grammar-and-adapter stream mid-way, after generated content and before any terminal frame:
      // the cancellation reaches the server, the admitted row drains, and the
      // next request is served.
      const until = async (label: string, check: () => Promise<boolean> | boolean) => {
        const deadline = Date.now() + 30_000;
        while (!(await check())) { if (Date.now() > deadline) throw new Error(`timed out waiting for ${label}`); await Bun.sleep(50); }
      };
      const abort = new AbortController();
      // Grammar-constrained with the adapter: the schema needs a long story, so
      // the request cannot finish naturally before the client leaves.
      const story = { type: "object", properties: { story: { type: "string", minLength: 300, maxLength: 600 } },
        required: ["story"], additionalProperties: false };
      const response = await post("/v1/chat/completions", { messages: [{ role: "user", content: "Write a long story about a lighthouse keeper as JSON." }],
        temperature: 0, max_tokens: 400, stream: true, adapter: "generated-lora",
        response_format: { type: "json_schema", json_schema: { name: "story", schema: story } } }, abort.signal);
      expect(response.status).toBe(200);
      const leaving = served.at(-1)!;
      const reader = response.body!.getReader(), decoder = new TextDecoder();
      let buffered = "", content = "", terminal = false;
      while (!content) {
        const { value, done } = await reader.read();
        if (done) throw new Error("the stream ended before any generated content");
        buffered += decoder.decode(value, { stream: true });
        for (let newline = buffered.indexOf("\n"); newline >= 0; newline = buffered.indexOf("\n")) {
          const line = buffered.slice(0, newline); buffered = buffered.slice(newline + 1);
          if (!line.startsWith("data: ")) continue;
          if (line === "data: [DONE]") { terminal = true; continue; }
          const choice = JSON.parse(line.slice(6)).choices[0];
          if (choice?.finish_reason) terminal = true;
          content += choice?.delta?.content ?? "";
        }
      }
      expect(terminal).toBe(false);
      expect(leaving.aborted).toBe(false);
      abort.abort(new Error("client left"));
      await reader.cancel().catch(() => undefined);
      await until("the server to observe the cancellation", () => leaving.aborted);
      await until("the admitted row to drain", async () => {
        const { batch } = await (await fetch(base + "/stats")).json();
        return batch.active_rows === 0 && batch.pending_rows === 0;
      });
      const later = await post("/v1/chat/completions", request);
      expect(later.status).toBe(200);
      expectReview((await later.json()).choices[0].message.content);
    } finally {
      await app?.close();
      rmSync(root, { recursive: true, force: true });
    }
  }, 900_000);
});
