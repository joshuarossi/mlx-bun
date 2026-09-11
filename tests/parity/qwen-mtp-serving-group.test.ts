import { describe, expect, spyOn, test } from "bun:test";
import type { GenerateOptions } from "../../src/generate";

const enabled = Bun.env.MLX_BUN_TEST_BATCH_SPEC_REPLAY === "1";
const ngram = Bun.env.MLX_BUN_TEST_GROUP_NGRAM === "1";
const dflash = Bun.env.MLX_BUN_TEST_GROUP_DFLASH === "1";
const deepspec = Bun.env.MLX_BUN_TEST_GROUP_DEEPSPEC === "1";
const assistant = Bun.env.MLX_BUN_TEST_GROUP_ASSISTANT === "1";
const perLayer = Bun.env.MLX_BUN_TEST_ROTATING_KV_CONFIG === "1";
const start = Number(Bun.env.MLX_BUN_TEST_MTP_KV_START ?? 0);
const twoModel = Bun.env.MLX_BUN_TEST_GROUP_TWO_MODEL === "1";
describe.skipIf(!enabled)(`Speculative ${ngram ? "prompt lookup" : dflash ? "DSpark draft" : deepspec ? "DeepSpec draft" : assistant ? "assistant draft" : twoModel ? "standalone draft" : "MTP"} through the shared execution group`, async () => {
  if (!enabled) return;
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { QwenMtpProvider } = await import("../../src/spec/qwen-mtp-source");
  const { DflashProvider } = await import("../../src/spec/dflash-source");
  const { DeepspecProvider } = await import("../../src/spec/deepspec-source");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { TwoModelProvider } = await import("../../src/spec/two-model");
  const { NgramProvider } = await import("../../src/spec/ngram-source");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { clearCache } = await import("../../src/mlx/ffi");

  test(perLayer || start > 0 ? "B1/B4 delayed or per-layer drafting preserves seeded execution and serving features" : "B=1 preserves the existing producer and B=4 executes concurrent speculative rounds", async () => {
    using resources = new DisposableStack();
    const path = Bun.env.MLX_BUN_TEST_MTP_TARGET!, draftPath = Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
    const weights = await Weights.open(path); resources.defer(() => weights.dispose());
    const model = createModel(weights, await loadModelConfig(path));
    const provider = ngram ? new NgramProvider() : dflash ? await DflashProvider.load(draftPath) : deepspec ? await DeepspecProvider.load(draftPath) : assistant ? await AssistantProvider.load(draftPath) : twoModel ? await TwoModelProvider.load(draftPath) : await QwenMtpProvider.load(draftPath); resources.defer(() => provider.dispose());
    const bits = Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
    const depth = Number(Bun.env.MLX_BUN_TEST_MTP_DEPTH ?? 2);
    const turboQuant = Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? { kBits: 8, vBits: 3 } : undefined;
    const kvConfig = perLayer ? model.config.kvQuant : undefined;
    if (perLayer) expect(kvConfig?.length).toBeGreaterThan(0);
    const options: GenerateOptions = { temperature: 0, maxTokens: 24, eosTokenIds: [],
      ...(turboQuant ? { turboQuant, quantizedKvStart: start } : kvConfig ? { kvConfig, quantizedKvStart: start }
        : bits ? { kvBits: bits, kvGroupSize: 64, quantizedKvStart: start } : {}) };
    const prompt = [1, 2, 3, 4, 5, 6, 7];
    const reference: number[] = [];
    // Legacy serving does not support these affine combinations. Their exact
    // model-graph control lives in rotating-quantized-target.test.ts; here the
    // shared executor must repeat and exercise every request lifecycle feature.
    const old = !perLayer && start === 0
      ? await specServeRun(model, provider, depth, prompt, options, token => { reference.push(token); }) : undefined;
    clearCache();
    const bind = bindSpeculativeGroupRequests(model, provider, depth);
    const run = async (count: number) => {
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 4 });
      let maxRows = 0;
      const tokens = Array.from({ length: count }, () => [] as number[]);
      try {
        const stats = await Promise.all(tokens.map(output => group.submit({
          method: bind(options), promptIds: prompt, maxTokens: options.maxTokens!, eosTokenIds: [],
          sample() { throw new Error("method sampling must own this call"); },
          onToken(token) { output.push(token); maxRows = Math.max(maxRows, group.activeRows); },
        })));
        expect(group.activeRows + group.pendingRows).toBe(0);
        return { tokens, stats, maxRows };
      } finally { await group.close(); clearCache(); }
    };
    const single = await run(1);
    if (old) {
      expect(single.tokens[0]).toEqual(reference);
      expect(single.stats[0]!.generatedTokens).toBe(old.generatedTokens);
      expect(single.stats[0]!.spec?.drafted).toBe(old.spec?.drafted);
      expect(single.stats[0]!.spec?.accepted).toBe(old.spec?.accepted);
    } else {
      reference.push(...single.tokens[0]!);
      const repeated = await run(1);
      expect(repeated.tokens).toEqual(single.tokens);
      expect(repeated.stats.map(stat => stat.spec)).toEqual(single.stats.map(stat => stat.spec));
    }
    const batch = await run(4), repeat = await run(4);
    expect(batch.maxRows).toBe(4);
    expect(repeat.maxRows).toBe(4);
    expect(repeat.tokens).toEqual(batch.tokens);
    for (const stats of batch.stats) {
      expect(stats.generatedTokens).toBe(options.maxTokens!);
      expect(stats.finishReason).toBe("length");
      expect(stats.spec!.rounds).toBeGreaterThan(0);
      expect(stats.spec!.drafted).toBeLessThanOrEqual(stats.spec!.rounds! * depth);
      expect(stats.spec!.drafted).toBeGreaterThanOrEqual(ngram ? 0 : stats.spec!.rounds!);
    }
    console.error(JSON.stringify({ kvBits: bits, single: single.stats, batch: batch.stats, maxRows: batch.maxRows }));
    const retiring = new MlxBatchExecutionGroup(model, { maxBatch: 4 });
    const aborted = new AbortController(), seen = [0, 0, 0, 0];
    const afterJoin = [0, 0, 0, 0]; let fullCohort = !ngram && !twoModel && !assistant && !deepspec && !dflash;
    let retirementMaxRows = 0;
    try {
      const outcomes = await Promise.allSettled(seen.map((_, row) => retiring.submit({
        method: bind(options), promptIds: prompt, maxTokens: 24, eosTokenIds: [],
        ...(row === 2 ? { signal: aborted.signal } : {}),
        onToken() {
          retirementMaxRows = Math.max(retirementMaxRows, retiring.activeRows);
          seen[row]!++;
          // Tail-pending methods may start emitting before every admission.
          // Exercise these consumer exits after a real four-row cohort forms.
          if (retiring.activeRows === 4) fullCohort = true;
          if (fullCohort) afterJoin[row]!++;
          if (row === 0 && afterJoin[row] === 3) return false;
          if (row === 1 && afterJoin[row] === 4) throw new Error("consumer failed");
          if (row === 2 && afterJoin[row] === 5) aborted.abort(new Error("request cancelled"));
        },
      })));
      expect(retirementMaxRows).toBe(4);
      expect(outcomes[0]).toMatchObject({ status: "fulfilled", value: { generatedTokens: seen[0], finishReason: "stop" } });
      expect(outcomes[1]).toMatchObject({ status: "rejected", reason: { message: "consumer failed" } });
      expect(outcomes[2]).toMatchObject({ status: "rejected", reason: { message: "request cancelled" } });
      expect(outcomes[3]).toMatchObject({ status: "fulfilled", value: { generatedTokens: 24, finishReason: "length" } });
      expect(afterJoin.slice(0, 3)).toEqual([3, 4, 5]);
      if (!ngram && !twoModel && !assistant && !deepspec && !dflash) expect(seen).toEqual([3, 4, 5, 24]);
      expect(retiring.activeRows + retiring.pendingRows).toBe(0);
      const eos = await retiring.submit({ method: bind(options), promptIds: prompt, maxTokens: 24,
        eosTokenIds: [reference[0]!], onToken() { throw new Error("EOS reached the content sink"); } });
      expect(eos).toMatchObject({ generatedTokens: 1, finishReason: "stop" });
    } finally { await retiring.close(); clearCache(); }

    // A request arriving during decode must join existing target/draft state,
    // including unequal prompt lengths and different accepted-token offsets.
    const lateJoin = async () => {
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 4 });
      const output: number[][] = [[], []];
      let joiner: Promise<unknown> | undefined, maxRows = 0;
      try {
        const first = await group.submit({ method: bind(options), promptIds: prompt, maxTokens: 24,
          eosTokenIds: [], onToken(token) {
            output[0]!.push(token); maxRows = Math.max(maxRows, group.activeRows);
            if (output[0]!.length === 6) joiner = group.submit({ method: bind(options),
              promptIds: [...prompt, 8, 9, 10], maxTokens: 17, eosTokenIds: [],
              onToken(next) { output[1]!.push(next); maxRows = Math.max(maxRows, group.activeRows); },
            });
          } });
        await joiner;
        expect(first.generatedTokens).toBe(24);
        expect(output.map(tokens => tokens.length)).toEqual([24, 17]);
        expect(maxRows).toBe(2);
        expect(group.activeRows + group.pendingRows).toBe(0);
        return output;
      } finally { await group.close(); clearCache(); }
    };
    expect(await lateJoin()).toEqual(await lateJoin());

    // Submit while the first target chunk runs. The next chunk must contain
    // both prompts, before either request has emitted a token.
    const prefillJoin = async () => {
      const group = new MlxBatchExecutionGroup(model, { maxBatch: 4 });
      const chunked = { ...options, prefillChunkSize: 4 };
      const output: number[][] = [[], []], shapes: number[][] = [];
      let joiner: Promise<unknown> | undefined, submitted = false, sharedBeforeOutput = false;
      const original = model.forwardHidden.bind(model);
      const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
        if (ids.shape[1] === 4) {
          shapes.push([...ids.shape]);
          if (ids.shape[0] === 2 && output.every(tokens => !tokens.length)) sharedBeforeOutput = true;
          if (!submitted) {
            submitted = true;
            joiner = group.submit({ method: bind(chunked), promptIds: [...prompt, 8, 9, 10, 11, 12, 13],
              maxTokens: 8, eosTokenIds: [], onToken(token) { output[1]!.push(token); } });
          }
        }
        return original(ids, caches);
      });
      try {
        await group.submit({ method: bind(chunked), promptIds: [...prompt, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
          maxTokens: 8, eosTokenIds: [], onToken(token) { output[0]!.push(token); } });
        await joiner;
        expect(sharedBeforeOutput).toBe(true);
        expect(shapes.slice(0, 2)).toEqual([[1, 4], [2, 4]]);
        expect(output.map(tokens => tokens.length)).toEqual([8, 8]);
        expect(group.activeRows + group.pendingRows).toBe(0);
        return output;
      } finally { probe.mockRestore(); await group.close(); clearCache(); }
    };
    expect(await prefillJoin()).toEqual(await prefillJoin());

    const { PromptCache } = await import("../../src/prompt-cache");
    const cache = new PromptCache(512 * 1024 ** 2);
    const cachedGroup = new MlxBatchExecutionGroup(model, { maxBatch: 4, promptCache: cache });
    try {
      const outputs: number[][] = [];
      for (let repeat = 0; repeat < 2; repeat++) {
        const output: number[] = []; outputs.push(output);
        const stats = await cachedGroup.submit({ method: bind(options), promptIds: prompt, maxTokens: 24,
          eosTokenIds: [], onToken(token) { output.push(token); } });
        expect(stats.cachedTokens).toBe(repeat ? prompt.length - 1 : 0);
      }
      expect(outputs[1]).toEqual(outputs[0]);
    } finally { await cachedGroup.close(); cache.clear(); clearCache(); }

    const { createServer, shutdownServer } = await import("../../src/server");
    const { loadTokenizer } = await import("../../src/tokenizer");
    const { ChatTemplate } = await import("../../src/chat-template");
    const { AdapterManager } = await import("../../src/lora");
    const { resolveModelProfile } = await import("../../src/model/profile");
    const { GenerationGateway } = await import("../../src/serve/generation-gateway");
    const context = { model, tokenizer: await loadTokenizer(path), template: await ChatTemplate.load(path),
      profile: resolveModelProfile(model.config), modelId: "qwen-mtp-group", adapters: new AdapterManager(model),
      kvConfig: kvConfig ?? null, genDefaults: {}, vision: null, loadVision: null,
      visionTokenIds: { imageTokenId: 0, boiTokenId: 0, eoiTokenId: 0 },
      audio: null, loadAudio: null, audioTokenIds: null, draft: { provider, numDraftTokens: depth } };
    // Served KV configuration starts at zero; positive thresholds above are
    // a library setting, exercised by the group and precision-transition gates.
    const server = createServer(context, 0, { batch: 4, promptCacheBytes: 0,
      hostname: "127.0.0.1", defaultThinking: false,
      ...(turboQuant ? { turboQuant } : kvConfig ? { kvQuant: "config" as const } : bits ? { kvQuant: bits } : {}) });
    const base = `http://127.0.0.1:${server.port}`;
    let maxVerifyRows = 0, arrivals = 0;
    const forward = model.forwardHidden.bind(model);
    const graphProbe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
      if (ngram ? ids.shape[1]! <= depth + 1 : ids.shape[1] === depth + 1)
        maxVerifyRows = Math.max(maxVerifyRows, ids.shape[0]!);
      return forward(ids, caches);
    });
    let release!: () => void;
    const ready = new Promise<void>(resolve => { release = resolve; });
    const timer = setTimeout(release, 5000);
    const originalRun = GenerationGateway.prototype.run;
    const arrivalProbe = spyOn(GenerationGateway.prototype, "run").mockImplementation(async function (
      this: InstanceType<typeof GenerationGateway>, ...args) {
      if (++arrivals === 4) release();
      await ready;
      return originalRun.apply(this, args);
    });
    try {
      const responses = await Promise.all(Array.from({ length: 4 }, async (_, row) => {
        const grammar = row % 2 === 1;
        const response = await fetch(`${base}/v1/${grammar ? "chat/" : ""}completions`, { method: "POST",
          headers: { "content-type": "application/json" }, body: JSON.stringify({
            ...(grammar ? { messages: [{ role: "user", content: "Return an object with color red." }],
              response_format: { type: "json_schema", json_schema: { name: "color", any_whitespace: false,
                schema: { type: "object", properties: { color: { type: "string", enum: ["red", "blue"] } },
                  required: ["color"], additionalProperties: false } } } }
              : { prompt: "Count upwards: 1, 2, 3," }), temperature: 0.7, seed: 734,
            max_tokens: 24, logprobs: true, top_logprobs: 3 }) });
        const body = await response.json() as any;
        expect(response.status, JSON.stringify(body)).toBe(200);
        expect(body.usage.completion_tokens).toBeGreaterThan(0);
        expect(body.usage.lane).toBe("batched");
        expect(body.usage.speculation.rounds).toBeGreaterThan(0);
        const metadata = body.choices[0].logprobs.content;
        expect(metadata.length).toBeGreaterThan(0);
        for (const token of metadata) {
          expect(Number.isFinite(token.logprob)).toBe(true);
          expect(token.top_logprobs).toHaveLength(3);
        }
        if (grammar) {
          const parsed = JSON.parse(body.choices[0].message.content);
          expect(["red", "blue"]).toContain(parsed.color);
          expect(Object.keys(parsed)).toEqual(["color"]);
          expect(body.choices[0].finish_reason).toBe("stop");
        }
        return body;
      }));
      expect(maxVerifyRows).toBe(4);
      const stats = await (await fetch(`${base}/stats`)).json() as any;
      expect(stats.batch.submitted_rows).toBe(4);
      expect(stats.batch.active_rows + stats.batch.pending_rows).toBe(0);
      console.error(JSON.stringify({ http: { kvBits: bits, maxVerifyRows,
        usage: responses.map(body => body.usage), batch: stats.batch } }));
    } finally {
      clearTimeout(timer); arrivalProbe.mockRestore(); graphProbe.mockRestore();
      await shutdownServer(server); clearCache();
    }

  }, 300_000);
});
