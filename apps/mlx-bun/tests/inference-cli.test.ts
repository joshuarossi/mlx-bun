import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelRecord } from "@mlx-bun/hub/registry";
import type { LoadedModelContext } from "../src/engine/model-host";
import { loadContextTemplate, requireChatTemplate } from "../src/engine/model-host";
import { UnsupportedExecutionError } from "../src/engine/completion";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import { commandInvocation, help, parseCommand } from "../src/cli/args";
import { generateOptions, resolveInferenceModel, runInference, type InferenceDependencies, type OneShotEngine } from "../src/cli/inference";
import { createRequestPrep } from "../src/server/request-prep";
import { textPrompt } from "../src/server/text-prompt";

const parse = (...args: string[]) => parseCommand("generate", args);
const model = { path: "/model", repoId: "example/model" };
function harness(template = true) {
  const events: string[] = [], encoded: unknown[][] = [], rendered: unknown[][] = [], decoded: unknown[][] = [], writes: string[] = [];
  const selections: unknown[][] = [], runs: Parameters<OneShotEngine["completion"]["run"]>[] = [], schemes: unknown[] = [], embeds: unknown[][] = [];
  let placed = 0, closed = 0;
  const context = {
    modelId: model.repoId, model: { config: { eosTokenIds: [0], modelType: "qwen3", text: {} } },
    kvConfig: null, genDefaults: { temperature: 0.9, topP: 0.95, topK: 50, repetitionPenalty: 1.1 },
    tokenizer: {
      encode: (...args: unknown[]) => { encoded.push(args); return [7, 8]; },
      decode: (...args: unknown[]) => { decoded.push(args); return "<think>reason</think>answer"; }, bosTokenId: null,
    },
    template: template ? { render: (...args: unknown[]) => { rendered.push(args); return "<bos>templated"; } } : null,
    dispose() { events.push("dispose"); },
  } as unknown as LoadedModelContext;
  const engine: OneShotEngine = {
    context, completion: {
      place(shape) { placed++; return { shape, mechanism: "continuous", execution: { method: "autoregressive", mechanism: "continuous",
        pagedKv: false, promptCache: false, checkpoint: false, fill: false, compiledDecode: false, grammarJump: false, reasons: [] } }; },
      async run(...args) { runs.push(args); await args[2](1); await args[2](2);
        return { promptTokens: 2, cachedTokens: 0, generatedTokens: 2, prefillTps: 0, decodeTps: 0, prefillMs: 0, decodeMs: 0, cacheTokens: [7, 8, 1, 2] }; },
    }, binding: { embed(texts, instruction) { embeds.push([texts, instruction]); return texts.map(text => ({ vector: Float32Array.from([1, 2]), tokens: text.length })); } },
    gateway: { async runExclusive(work, _trace, signal) { signal?.throwIfAborted(); events.push("exclusive"); return work(); } },
    async close() { closed++; events.push("close"); context.dispose(); },
  };
  const dependencies: InferenceDependencies = {
    resolve: async (...args) => { selections.push(args); return model; },
    load: async (selected, maxTokens) => { expect(selected).toBe(model); events.push(`load:${maxTokens}`); return context; },
    engine: async (loaded, scheme) => { expect(loaded).toBe(context); schemes.push(scheme.generationOptions); return engine; },
    write: text => { writes.push(text); }, stdin: async () => " first \n\n second\r\n", stdinIsTTY: () => false,
  };
  return { dependencies, context, engine, events, encoded, decoded, rendered, writes, selections, runs, schemes, embeds,
    placed: () => placed, closed: () => closed };
}

test("generate options preserve main's greedy recipe and explicit overrides", () => {
  expect(generateOptions(parse("model", "prompt"))).toEqual({ prompt: "prompt", raw: false, kvQuant: undefined,
    options: { maxTokens: 256, temperature: 0, topP: 0, topK: 0 } });
  expect(generateOptions(parse("model", "positional", "--prompt", "chosen", "--temp", "0.8", "--temperature", "0",
    "--top-p", "0.9", "--top-k", "20", "--seed", "0", "--max-tokens", "5", "--kv-quant", "4", "--raw")))
    .toEqual({ prompt: "chosen", raw: true, kvQuant: 4, options: { maxTokens: 5, temperature: 0, topP: 0.9, topK: 20, seed: 0 } });
  expect(commandInvocation(["gen", "m", "prompt"])).toEqual({ command: "generate", args: ["m", "prompt"] });
  expect(help("gen")).toBe(help("generate"));
  for (const args of [["--compiled-decode", "on"], ["--serial"], ["--l1"]]) expect(() => parse(...args)).toThrow();
});

test("bad input is rejected before selecting or loading a model", async () => {
  for (const args of [[], ["--prompt", "x", "--max-tokens", "0"], ["--prompt", "x", "--seed", "1.5"],
    ["--prompt", "x", "--temperature", "NaN"], ["--prompt", "x", "--kv-quant", "3"]]) {
    const run = harness(); await expect(runInference("generate", parse(...args), run.dependencies)).rejects.toThrow();
    expect(run.selections).toEqual([]); expect(run.events).toEqual([]);
  }
  const run = harness();
  await expect(runInference("embed", parseCommand("embed", []), { ...run.dependencies, stdinIsTTY: () => true })).rejects.toThrow("usage:");
  expect(run.selections).toEqual([]);
});

test("templated generation preserves one prompt, explicit special-token policy, raw output, and lifecycle", async () => {
  const run = harness();
  await runInference("generate", parse("chosen", "hi", "--query", "ignored"), run.dependencies);
  expect(run.selections).toEqual([["generate", "chosen"]]);
  expect(run.rendered).toEqual([[[{ role: "user", content: "hi" }], { addGenerationPrompt: true, enableThinking: false }]]);
  expect(run.encoded).toEqual([["<bos>templated", false]]);
  expect(run.decoded).toEqual([[[1, 2], true]]); expect(run.writes).toEqual(["<think>reason</think>answer\n"]);
  expect(run.runs[0]![1]).toEqual({ maxTokens: 256, temperature: 0, topP: 0, topK: 0, stopSequences: [], seedWasExplicit: false });
  expect(run.runs[0]![5].mechanism).toBe("continuous"); expect(run.placed()).toBe(1); expect(run.closed()).toBe(1);
  expect(run.events).toEqual(["load:256", "close", "dispose"]);
});

for (const template of [true, false]) test(`raw generation and missing-template fallback use tokenizer specials (${template})`, async () => {
  const run = harness(template);
  run.context.tokenizer.decode = () => "answer\n";
  await runInference("generate", parse("--query", "chosen", "--prompt", "hi", ...(template ? ["--raw"] : [])), run.dependencies);
  expect(run.selections).toEqual([["generate", "chosen"]]); expect(run.rendered).toEqual([]);
  expect(run.encoded).toEqual([["hi", true]]); expect(run.writes).toEqual(["answer\n"]);
});

test("the existing eval thinking and KV environment policy stays local to the one-shot command", async () => {
  const run = harness(); run.context.kvConfig = [{ layerIdx: 0, bits: 4, groupSize: 64 }];
  const restore = configureRuntime({ MLX_BUN_EVAL_THINK: "1", MLX_BUN_EVAL_KV_QUANT: "1" });
  try {
    await runInference("generate", parse("--prompt", "hi"), run.dependencies);
    expect(run.rendered[0]![1]).toEqual({ addGenerationPrompt: true, enableThinking: true });
    expect(run.schemes).toEqual([{ kvConfig: run.context.kvConfig, quantizedKvStart: 0 }]);
    const explicit = harness(); await runInference("generate", parse("--prompt", "hi", "--kv-quant", "off"), explicit.dependencies);
    expect(explicit.schemes).toEqual([{}]);
  } finally { restore(); }
});

for (const json of [false, true]) test(`embeddings accept stdin lines without a chat template and preserve output format (${json})`, async () => {
  const run = harness(false);
  await runInference("embed", parseCommand("embed", ["--instruct", "query", ...(json ? ["--json"] : [])]), run.dependencies);
  expect(run.embeds).toEqual([[["first", "second"], "query"]]); expect(run.events).toContain("exclusive");
  if (json) expect(JSON.parse(run.writes.join(""))).toEqual({ object: "list", model: "example/model", data: [
    { object: "embedding", index: 0, embedding: [1, 2] }, { object: "embedding", index: 1, embedding: [1, 2] },
  ], usage: { prompt_tokens: 11, total_tokens: 11 } });
  else expect(run.writes).toEqual(["[1,2]\n", "[1,2]\n"]);
  expect(run.closed()).toBe(1); expect(run.runs).toEqual([]);
});

test("explicit embedding text wins over stdin and positional text", async () => {
  const run = harness(false);
  await runInference("embed", parseCommand("embed", ["chosen", "positional", "--text", "explicit"]),
    { ...run.dependencies, stdin: async () => { throw new Error("must not read"); } });
  expect(run.embeds).toEqual([[["explicit"], undefined]]); expect(run.selections).toEqual([["embed", "chosen"]]);
});

test("unsupported shared execution and embed capabilities fail clearly and close the engine", async () => {
  const run = harness();
  run.engine.completion.place = () => { throw new UnsupportedExecutionError("diffusion", "denoising", ["method-requires-serial"]); };
  await expect(runInference("generate", parse("--prompt", "hi"), run.dependencies)).rejects.toThrow("does not support shared execution");
  expect(run.runs).toEqual([]); expect(run.writes).toEqual([]); expect(run.closed()).toBe(1);
  const unsupported = harness(false); unsupported.engine.binding = {};
  await expect(runInference("embed", parseCommand("embed", ["--text", "hi"]), unsupported.dependencies)).rejects.toThrow("not an embedding model");
  expect(unsupported.closed()).toBe(1);
});

test("cancellation joins generation before closing and emits no partial output", async () => {
  const run = harness(), abort = new AbortController(), entered = Promise.withResolvers<void>();
  run.engine.completion.run = async (...args) => {
    entered.resolve();
    await new Promise<void>((_, reject) => args[6]!.addEventListener("abort", () => { run.events.push("cancelled"); reject(args[6]!.reason); }, { once: true }));
    throw new Error("unreachable");
  };
  const pending = runInference("generate", parse("--prompt", "hi"), run.dependencies, abort.signal);
  await entered.promise; abort.abort(new Error("cancelled"));
  await expect(pending).rejects.toThrow("cancelled"); expect(run.events.slice(-3)).toEqual(["cancelled", "close", "dispose"]);
  expect(run.writes).toEqual([]);
});

test("missing templates remain a server error while optional one-shot loading returns null", async () => {
  const load = async () => { throw new Error("no chat template found"); };
  expect(await loadContextTemplate("/unused", false, load)).toBeNull();
  await expect(loadContextTemplate("/unused", true, load)).rejects.toThrow("no chat template found");
  const run = harness(false);
  expect(() => requireChatTemplate(run.context)).toThrow("has no chat template");
  expect(() => createRequestPrep({ ctx: run.context, serverOptions: {}, kvScheme: {}, defaultGeneratedTokens: undefined })).toThrow("has no chat template");
});

test("shared text prompt keeps HTTP duplicate-BOS correction separate from CLI no-specials encoding", () => {
  const run = harness(); run.context.tokenizer = { ...run.context.tokenizer, bosTokenId: 1 };
  run.context.tokenizer.encode = (_text, specials) => specials === false ? [1, 7] : [1, 1, 7];
  const messages = [{ role: "user" as const, content: "hi" }];
  expect(textPrompt(run.context.template!, run.context.tokenizer, messages, {}).ids).toEqual([1, 7]);
  expect(textPrompt(run.context.template!, run.context.tokenizer, messages, {}, false).ids).toEqual([1, 7]);
});

test("model selection keeps local paths local and closes registry on success or failure", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-cli-model-"));
  try {
    writeFileSync(join(dir, "config.json"), "{}");
    expect((await resolveInferenceModel("generate", dir, () => { throw new Error("must not open registry"); })).path).toBe(dir);
  } finally { rmSync(dir, { recursive: true, force: true }); }
  let scanned = 0, closed = 0;
  const embedding = { ...model, modelType: "qwen3" } as ModelRecord;
  const registry = () => ({ list: () => scanned ? [embedding] : [], scan: async () => { scanned++; return 1; },
    resolve: (query: string) => { if (query === "bad") throw new Error("missing"); return embedding; }, close: () => { closed++; } });
  expect(await resolveInferenceModel("embed", "", registry)).toBe(embedding); expect(scanned).toBe(1); expect(closed).toBe(1);
  await expect(resolveInferenceModel("generate", "bad", registry)).rejects.toThrow("missing"); expect(closed).toBe(2);
  await expect(resolveInferenceModel("embed", "", () => ({ ...registry(), list: () => [] }))).rejects.toThrow("no embedding model downloaded");
  expect(closed).toBe(3);
});


test("generation and cleanup failures are both retained", async () => {
  const run = harness(), primary = new Error("generation broke"), cleanup = new Error("close broke");
  run.engine.completion.run = async () => { throw primary; };
  run.engine.close = async () => { throw cleanup; };
  try { await runInference("generate", parse("--prompt", "hi"), run.dependencies); throw new Error("expected failure"); }
  catch (error) { expect(error).toBeInstanceOf(AggregateError); expect((error as AggregateError).errors).toEqual([primary, cleanup]); }
});

test("production CLI composition requests optional templates and a continuous engine of capacity one", async () => {
  const app = new URL("../", import.meta.url).pathname;
  const script = `
    import { mock } from "bun:test";
    import { strict as assert } from "node:assert";
    const app = ${JSON.stringify(app)};
    let loaded = 0, opened = 0, closed = 0, output = "";
    const context = { modelId: "test", model: { config: {} }, template: null, kvConfig: null,
      tokenizer: { encode: (text, special) => { assert.equal(text, "hello"); assert.equal(special, true); return [1]; },
        decode: (ids, special) => { assert.deepEqual(ids, [2]); assert.equal(special, true); return "answer"; } } };
    mock.module(app + "src/engine/model-host.ts", () => ({ loadContext: async (path, id, options) => {
      loaded++; assert.equal(path, "/unused"); assert.equal(id, "test");
      assert.deepEqual(options, { requireChatTemplate: false, glm: { enableMtp: false, maxGenerationTokens: loaded === 1 ? 256 : undefined } });
      return context;
    } }));
    mock.module(app + "src/engine/index.ts", () => ({ createAppEngine: async (supplied, options) => {
      opened++; assert.equal(supplied, context); assert.equal(options.capacity, 1); assert.equal(options.gateway.kvScheme.kind, "bf16");
      return { context, binding: { embed: (texts) => { assert.deepEqual(texts, ["alpha", "beta"]); return texts.map(text => ({ vector: Float32Array.from([text.length]), tokens: text.length })); } }, gateway: { runExclusive: async work => work() }, completion: {
        place: shape => ({ shape, mechanism: "continuous" }),
        run: async (ids, options, token, vision, shape, placement) => { assert.deepEqual(ids, [1]); assert.equal(placement.mechanism, "continuous"); await token(2); },
      }, close: async () => { closed++; } };
    } }));
    const { runInference } = await import(app + "src/cli/inference.ts");
    await runInference("generate", { positionals: [], values: { prompt: "hello" } }, {
      resolve: async () => ({ path: "/unused", repoId: "test" }), write: text => { output += text; },
    });
    await runInference("embed", { positionals: [], values: {} }, {
      resolve: async () => ({ path: "/unused", repoId: "test" }), write: text => { output += text; },
    });
    assert.equal(output, "answer\\n[5]\\n[4]\\n"); assert.equal(loaded, 2); assert.equal(opened, 2); assert.equal(closed, 2);
  `;
  const child = Bun.spawn([process.execPath, "--eval", script], { stdin: "pipe", stdout: "pipe", stderr: "pipe",
    env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent" } });
  child.stdin.write(" alpha \n\n"); child.stdin.write(" beta\r\n"); child.stdin.end();
  const [code, stderr] = await Promise.all([child.exited, new Response(child.stderr).text()]);
  expect(stderr).toBe(""); expect(code).toBe(0);
});


test("cancellation during loading releases the context before creating execution", async () => {
  const run = harness(), abort = new AbortController();
  await expect(runInference("generate", parse("--prompt", "hi"), { ...run.dependencies,
    load: async () => { abort.abort(new Error("cancelled during load")); return run.context; },
    engine: async () => { throw new Error("must not create engine"); },
  }, abort.signal)).rejects.toThrow("cancelled during load");
  expect(run.events).toEqual(["dispose"]); expect(run.writes).toEqual([]);
});
