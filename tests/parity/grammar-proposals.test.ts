import { expect, test } from "bun:test";
import { existsSync } from "node:fs";

const target = Bun.env.MLX_BUN_TEST_GRAMMAR_TARGET ?? `${Bun.env.HOME}/.cache/huggingface/hub/models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/664aabaed233c653f82716d8dc822234d0091f78`;
const enabled = Bun.env.MLX_BUN_TEST_GRAMMAR_PROPOSALS === "1" && existsSync(`${target}/config.json`);

test.skipIf(!enabled)("grammar proposals preserve matcher state and compose with shared row retirement", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { compileGrammarRequest } = await import("../../src/grammar");
  const { GenerationGateway } = await import("../../src/serve/generation-gateway");
  const { resolveKvScheme } = await import("../../src/kv-scheme");
  const kvScheme = resolveKvScheme(Bun.env.MLX_BUN_TEST_GRAMMAR_KV === "turbo"
    ? { turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 0 }
    : { override: Bun.env.MLX_BUN_TEST_GRAMMAR_KV === "4" ? 4 : "off" });
  const { configureRuntime } = await import("../../src/runtime-config");
  using resources = new DisposableStack();
  const weights = await Weights.open(target); resources.defer(() => weights.dispose());
  const model = createModel(weights, await loadModelConfig(target));
  const tok = await loadTokenizer(target);
  const texts = ['{"alpha":"a long deterministic response"}', '{"beta":"another independent response"}'];
  const compile = async (text: string) => {
    const result = await compileGrammarRequest({ guidedChoice: [text] }, tok, model.config.text.vocabSize);
    expect(result?.controller).toBeTruthy(); return result!.controller!;
  };
  const grammar = await compile(texts[0]!);
  try {
    const first = await grammar.proposeTokens(3);
    expect(first.length).toBeGreaterThan(0);
    expect(await grammar.proposeTokens(3)).toEqual(first);
    expect(grammar.isTerminated).toBe(false);
    expect(grammar.jumpedTokens).toBe(0);
    for (const id of first) { await grammar.ready(); grammar.accept(id); }
    expect(await grammar.proposeTokens(3)).not.toEqual(first);
  } finally { grammar.dispose(); }
  const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false,
    userSeed: false, kvQuant: kvScheme.kind === "affine-uniform", turboQuant: kvScheme.kind === "turbo", hasLogitsExtras: false,
    wantsLogprobs: false, hasDraft: false, hasGrammar: true };
  const run = async (jump: boolean, mode: "length" | "stop" | "cancel", count = 2, logprobs = false) => {
    const restore = configureRuntime({ MLX_BUN_GRAMMAR_JUMP: jump ? "1" : "0" });
    const gw = new GenerationGateway(model, 8, async () => { throw new Error("unexpected serial execution"); }, { kvScheme });
    restore();
    const controllers = await Promise.all(texts.slice(0, count).map(compile));
    try {
      return await Promise.all(controllers.map(async (controller, i) => {
        const abort = new AbortController();
        const requestShape = { ...shape, wantsLogprobs: logprobs };
        const options = { logprobs, topLogprobs: logprobs ? 3 : undefined, ...kvScheme.options, kvConfig: kvScheme.options.kvConfig?.map(entry => ({ ...entry })), grammar: controller, temperature: 0, maxTokens: 64, eosTokenIds: [] };
        const placement = gw.place(requestShape, options);
        expect(placement.execution).toMatchObject({ mechanism: "continuous", method: jump ? "speculative" : "autoregressive" });
        const ids: number[] = [];
        const stats = await gw.run(tok.encode("Return the required JSON object."), options,
          (id, metadata) => {
            if (logprobs) { expect(metadata?.logprob).toBeNumber(); expect(metadata?.top?.length).toBe(3); }
            ids.push(id); if (mode !== "length" && i === 0 && ids.length === 3) {
            if (mode === "stop") return false;
            abort.abort(new Error("grammar request cancelled"));
          } },
          undefined, requestShape, placement, abort.signal).catch(error => {
            if (mode !== "cancel" || i !== 0) throw error;
            expect(error.message).toBe("grammar request cancelled"); return null;
          });
        if (mode !== "length" && i === 0) expect(ids.length).toBe(3);
        else expect(JSON.parse(tok.decode(ids, true))).toEqual(JSON.parse(texts[i]!));
        if (jump && stats) expect(stats.spec!.drafted).toBeGreaterThan(0);
        return { ids, stats };
      }));
    } finally { await gw.close(); controllers.forEach(c => c.dispose()); }
  };
  const plain = await run(false, "length");
  const proposed = await run(true, "length");
  if (kvScheme.kind === "bf16") expect(proposed.map(r => r.ids)).toEqual(plain.map(r => r.ids));
  // Affine/TQ token-width rounding is qualified by the same-geometry native
  // verifier oracles. A different width can choose another valid tokenization.
  else expect((await run(true, "length")).map(r => r.ids)).toEqual(proposed.map(r => r.ids));
  expect(proposed.reduce((n, r) => n + r.stats!.spec!.accepted, 0)).toBeGreaterThan(0);
  await run(true, "stop");
  await run(true, "cancel");
  await run(true, "length", 1);
  await run(true, "length", 2, true);
}, 240_000);
