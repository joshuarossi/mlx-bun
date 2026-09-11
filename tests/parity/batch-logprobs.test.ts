// Native composition gate; no downloads. Run on the campaign artifact with
// MLX_BUN_TEST_BATCH_LOGPROBS_MODEL=/path bun test tests/parity/batch-logprobs.test.ts
import { expect, test, spyOn } from "bun:test";
import type { TokenLogprobs } from "../../src/contracts/generation";
const artifact = Bun.env.MLX_BUN_TEST_BATCH_LOGPROBS_MODEL;

test.skipIf(!artifact)("logprobs survive native B=1/B=2 execution and row retirement", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { generate } = await import("../../src/generate");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { clearCache } = await import("../../src/mlx/ffi");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const { QuantizedKVCache, RotatingQuantizedKVCache } = await import("../../src/model/gemma4-base");
  const kvBits = Bun.env.MLX_BUN_TEST_BATCH_LOGPROBS_KV_BITS;
  const kvScheme = kvBits ? resolveKvScheme({ override: Number(kvBits) }) : undefined;
  const weights = await Weights.open(artifact!);
  const model = createModel(weights, await loadModelConfig(artifact!));
  const tokenizer = await loadTokenizer(artifact!);
  const prompts = ["Count upwards: 1, 2, 3,", "List the weekdays: Monday, Tuesday,"]
    .map(text => tokenizer.encode(text));
  type Output = Array<{ token: number; lp?: TokenLogprobs }>;
  let maxB = 0;
  let sawQuantized = false;
  const forward = model.forwardHidden.bind(model);
  const probe = spyOn(model, "forwardHidden").mockImplementation((ids, caches) => {
    maxB = Math.max(maxB, ids.shape[0]!);
    sawQuantized ||= caches.some(c => c instanceof QuantizedKVCache || c instanceof RotatingQuantizedKVCache);
    return forward(ids, caches);
  });
  const run = async (batch: number, count: number, capture: boolean, stopFirst = false, draftConfigured = false) => {
    maxB = 0;
    sawQuantized = false;
    const gateway = new GenerationGateway(model, batch, async (prompt, options, sink) => {
      const gen = generate(model, prompt, options);
      for await (const t of gen) if (await sink(t.token, t.logprobs) === false) break;
      return gen.stats!;
    }, { kvScheme });
    try {
      const outputs = await Promise.all(prompts.slice(0, count).map(async (prompt, index) => {
        const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
          hasLogitsExtras: false, wantsLogprobs: capture, userSeed: false,
          kvQuant: !!kvScheme, turboQuant: false, hasGrammar: false, hasDraft: draftConfigured };
        const options = { ...kvScheme?.generationOptions, maxTokens: 12, temperature: 0, logprobs: capture,
          topLogprobs: capture ? 3 : 0, eosTokenIds: [], prefillChunkSize: 2048 };
        const placement = gateway.place(shape, options);
        expect(placement.mechanism).toBe(batch === 1 ? "serial" : "continuous");
        const output: Output = [];
        await gateway.run(prompt, options, (token, lp) => {
          output.push({ token, ...(lp ? { lp } : {}) });
          if (stopFirst && index === 0 && output.length === 3) return false;
        }, undefined, shape, placement);
        return output;
      }));
      if (kvScheme) expect(sawQuantized).toBe(true);
      return { outputs, maxB };
    } finally { await gateway.close(); clearCache(); }
  };
  try {
    const serial = await run(1, 1, true), single = await run(2, 1, true);
    expect(single.maxB).toBe(1);
    expect(single.outputs).toEqual(serial.outputs);
    const control = await run(2, 2, false), batched = await run(2, 2, true);
    expect(control.maxB).toBe(2); expect(batched.maxB).toBe(2);
    expect(batched.outputs.map(row => row.map(t => t.token)))
      .toEqual(control.outputs.map(row => row.map(t => t.token)));
    for (const row of batched.outputs) for (const { token, lp } of row) {
      expect(lp!.top).toHaveLength(3);
      expect(lp!.top![0]!.id).toBe(token);
      expect(lp!.logprob).toBe(lp!.top![0]!.logprob);
      expect(Number.isFinite(lp!.logprob)).toBe(true);
    }
    const draftFallback = await run(2, 2, true, false, true);
    expect(draftFallback.maxB).toBe(2);
    expect(draftFallback.outputs).toEqual(batched.outputs);
    const retired = await run(2, 2, true, true);
    expect(retired.maxB).toBe(2);
    expect(retired.outputs[0]).toHaveLength(3);
    expect(retired.outputs[1]).toHaveLength(12);
    for (const { lp } of retired.outputs[1]!) expect(Number.isFinite(lp!.logprob)).toBe(true);
    console.log("[batch-logprobs] serial/B=1 exact; B=2 capture on/off tokens exact; early row retirement passed");

    // Exercise the wire builders with the same loaded model, without another
    // model allocation or a persistent server. Deliberately disable caching.
    const { createServer, shutdownServer } = await import("../../src/server");
    const { ChatTemplate } = await import("../../src/chat-template");
    const { AdapterManager } = await import("../../src/lora");
    const { resolveModelProfile } = await import("../../src/model/profile");
    const ctx = { model, tokenizer, template: await ChatTemplate.load(artifact!),
      profile: resolveModelProfile(model.config), modelId: "batch-logprobs",
      adapters: new AdapterManager(model), kvConfig: null, genDefaults: {},
      vision: null, loadVision: null,
      visionTokenIds: { imageTokenId: 0, boiTokenId: 0, eoiTokenId: 0 },
      audio: null, loadAudio: null, audioTokenIds: null };
    const http = async (batch: number, concurrent: boolean, draftConfigured = false) => {
      // A configured producer must remain unused for requests selecting AR.
      const context = draftConfigured ? { ...ctx, draft: {
        provider: { id: "unused-logprob-draft", weightsBytes: 0,
          open(): never { throw new Error("logprob fallback opened its draft"); }, dispose() {} },
        numDraftTokens: 2,
      } } : ctx;
      const server = createServer(context, 0, { batch, promptCacheBytes: 0,
        ...(kvBits ? { kvQuant: Number(kvBits) } : {}),
        hostname: "127.0.0.1", defaultThinking: false });
      const base = `http://127.0.0.1:${server.port}`;
      maxB = 0;
      sawQuantized = false;
      try {
        const request = async (chat: boolean, top: boolean, stream = false) => {
          const response = await fetch(`${base}/v1/${chat ? "chat/" : ""}completions`, {
            method: "POST", headers: { "content-type": "application/json" },
            body: JSON.stringify({ ...(chat ? { messages: [{ role: "user", content: "Count upwards from one." }] }
              : { prompt: "Count upwards: 1, 2, 3," }),
              temperature: 0.8, seed: 734, max_tokens: 48, logprobs: !top,
              ...(top ? { top_logprobs: 3 } : {}), stream }),
          });
          expect(response.status).toBe(200);
          if (stream) {
            const chunks = (await response.text()).split("\n\n")
              .filter(line => line.startsWith("data: ") && !line.includes("[DONE]"))
              .map(line => JSON.parse(line.slice(6)));
            expect(chunks.length).toBeGreaterThan(0);
            for (const chunk of chunks) expect(chunk.choices[0]?.logprobs).toBeUndefined();
            return null;
          }
          const body = await response.json() as any;
          const entries = body.choices[0].logprobs.content;
          expect(entries.length).toBeGreaterThan(0);
          expect(entries.length).toBeLessThanOrEqual(body.usage.completion_tokens);
          for (const entry of entries) {
            expect(Number.isInteger(entry.id)).toBe(true);
            expect(Number.isFinite(entry.logprob)).toBe(true);
            expect(entry.logprob).toBeLessThanOrEqual(0);
            if (top) {
              expect(entry.top_logprobs).toHaveLength(3);
              expect(entry.id).toBe(entry.top_logprobs[0].id);
              expect(entry.logprob).toBe(entry.top_logprobs[0].logprob);
            } else expect(entry.top_logprobs).toBeUndefined();
          }
          return body.choices;
        };
        if (!concurrent) return await request(true, true);
        // Rendering can finish at different times. Align these two arrivals
        // at the engine boundary so this correctness test always exercises
        // concurrent work; the serving benchmark measures natural arrivals.
        let arrivals = 0;
        let release!: () => void;
        const ready = new Promise<void>(resolve => { release = resolve; });
        const timer = setTimeout(release, 5000);
        const originalRun = GenerationGateway.prototype.run;
        const arrivalProbe = spyOn(GenerationGateway.prototype, "run")
          .mockImplementation(async function (this: InstanceType<typeof GenerationGateway>, ...args) {
            if (++arrivals === 2) release();
            await ready;
            return originalRun.apply(this, args);
          });
        try {
          await Promise.all([request(true, false), request(false, true)]);
          expect(arrivals).toBe(2);
        } finally { release(); clearTimeout(timer); arrivalProbe.mockRestore(); }
        expect(maxB).toBe(2);
        const stats = await (await fetch(`${base}/stats`)).json() as any;
        expect(stats.batch.submitted_rows).toBe(2);
        if (kvScheme) expect(sawQuantized).toBe(true);
        // Streaming omits logprob capture and can legitimately select spec;
        // the mounted-producer case covers the non-streaming AR fallback.
        if (!draftConfigured)
          await Promise.all([request(true, true, true), request(false, false, true)]);
        return null;
      } finally {
        try { expect((await shutdownServer(server)).stopped).toBe(true); }
        finally { server.stop(true); clearCache(); }
      }
    };
    const serialHttp = await http(1, false);
    expect(await http(2, false)).toEqual(serialHttp);
    await http(2, true);
    await http(2, true, true);
    console.log("[batch-logprobs] HTTP serial/B=1 exact; B=2 chat/text selected/top-only and SSE passed");
  } finally { probe.mockRestore(); weights.dispose(); clearCache(); }
}, 300_000);
