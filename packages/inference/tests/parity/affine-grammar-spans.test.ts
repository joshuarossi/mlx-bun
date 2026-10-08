// Opt in with MLX_BUN_TEST_AFFINE_SPANS_MODEL=/cached/checkpoint. No downloads.
// Committed grammar spans over delayed affine KV on real weights: the span
// method the gateway binds, in a batch group, against this tree's direct
// jump-forward generation at B1, below and across the transition, and beside
// an interleaved peer. A graph that reads plain KV refuses the crossing row
// before the forward direct generation fails in; a graph that reads encoded KV
// continues over converted layers. The model must be one whose gateway admits
// the jump over affine KV.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { existsSync } from "node:fs";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { GrammarController } from "../../src/sampling";
import type { GenerateOptions } from "../../src/generation/index";

const target = Bun.env.MLX_BUN_TEST_AFFINE_SPANS_MODEL;
if (target && !existsSync(`${target}/config.json`)) throw new Error(`unavailable model: ${target}`);

/** A permissive matcher that forces the given spans, one per jump. */
function spanGrammar(spans: readonly (readonly number[])[]) {
  const accepted: number[] = [];
  let next = 0;
  const grammar = {
    accepted, get isTerminated() { return false; }, ready: async () => {},
    applyMask: (scores: MlxArray) => scores,
    accept(token: number) { accepted.push(token); },
    jumpForward(budget: number) {
      const span = spans[next];
      if (!span || budget < span.length) return null;
      next++; accepted.push(...span); return [...span];
    },
    dispose() {},
  };
  return grammar as typeof grammar & GrammarController;
}

test.skipIf(!target)("real-weight committed spans over delayed affine KV equal direct generation below and across the transition, and beside a peer", async () => {
  const { Weights, loadModelConfig, createModel, generateAutoregressive } = await import("../../src/index");
  const { bindMlxGateway, createRuntimeConfig, withRuntimeConfig } = await import("../../src/execution");
  const { bindMlxAutoregressiveGraph } = await import("../../src/generation/bindings/autoregressive");
  const { resolveKvScheme } = await import("../../src/state/kv-scheme");
  const weights = await Weights.open(target!);
  try {
    const model = createModel(weights, await loadModelConfig(target!));
    const dense = model.requiredDenseKvLayers.length > 0;
    type Projection = { shape: number[]; dtype: string; sha256: string };
    let lane: Projection[] | null = null, kinds: string[][] = [];
    const project = model.logitsFromHidden.bind(model), forward = model.forwardHidden.bind(model);
    model.logitsFromHidden = (hidden: MlxArray) => {
      const logits = project(hidden);
      lane?.push({ shape: [...logits.shape], dtype: logits.dtypeName, sha256: createHash("sha256").update(logits.rawBytes()).digest("hex") });
      return logits;
    };
    (model as { forwardHidden: typeof forward }).forwardHidden = (ids, caches) => {
      kinds.push(caches.map(cache => cache.constructor.name));
      return forward(ids, caches as never);
    };
    const binding = withRuntimeConfig(createRuntimeConfig({ MLX_BUN_GRAMMAR_JUMP: "1" }), () => bindMlxGateway(model));
    const affine = (start: number) => resolveKvScheme({ override: 4, quantizedKvStart: start });
    const chunk = 64;
    const options = (scheme: ReturnType<typeof affine>, maxTokens: number, grammar: GrammarController): GenerateOptions =>
      ({ temperature: 0, maxTokens, eosTokenIds: [], prefillChunkSize: chunk, ...scheme.generationOptions, grammar });

    const direct = async (prompt: number[], maxTokens: number, scheme: ReturnType<typeof affine>, spans: number[][]) => {
      const grammar = spanGrammar(spans), tokens: number[] = [], seen: Projection[] = [];
      let outcome = "length";
      lane = seen; kinds = [];
      try {
        const generation = generateAutoregressive(bindMlxAutoregressiveGraph(model), prompt,
          { ...options(scheme, maxTokens, grammar), decodePolicy: { compiledDecode: false, grammarJump: true } });
        for await (const { token } of generation) tokens.push(token);
      } catch (error) { outcome = (error as Error).name; } finally { lane = null; }
      return { tokens, accepted: grammar.accepted, seen, outcome, kinds };
    };
    const shape = { hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: false, kvQuant: true,
      turboQuant: false, hasLogitsExtras: false, hasGrammar: true, wantsLogprobs: false, hasDraft: false };
    const grouped = (scheme: ReturnType<typeof affine>) => {
      const group = binding.createBatchGroup({ maxBatch: 2, prefillChunkSize: chunk, kvScheme: scheme,
        runtime: createRuntimeConfig({ MLX_BUN_PREFILL_TAIL_SPLIT: "1" }) });
      const submit = async (prompt: number[], maxTokens: number, spans: number[][], onToken?: () => void) => {
        const grammar = spanGrammar(spans), tokens: number[] = [], request = options(scheme, maxTokens, grammar);
        const execution = binding.plan(shape, request, { continuous: true, quantizedBatch: binding.kvBatchable(scheme), checkpoints: false });
        expect(execution).toMatchObject({ method: "autoregressive", mechanism: "continuous", grammarJump: true });
        const outcome = await group.submit({ promptIds: prompt, maxTokens, eosTokenIds: [], grammar,
          method: binding.methodRequest!(execution, request)!,
          onToken(token: number) { tokens.push(token); onToken?.(); return undefined; } })
          .then(stats => stats.finishReason as string, (error: Error) => error.name);
        return { tokens, accepted: grammar.accepted, outcome };
      };
      return { group, submit, async close() { await group.close(); expect(group.activeRows + group.pendingRows).toBe(0); } };
    };
    const A = [2, 651, 6037, 576, 6081, 603, 1000, 1200], B = [2, 651, 6037];
    const spansA = [[3000, 3001], [3002]], spansB = [[3003], [3004, 3005]];
    // Direct generation fails in the forward that reads a converted layer on a
    // plain-read graph; the span method refuses before that forward.
    const refused = dense ? "DenseKvReadError" : "length";

    // Below the transition.
    const below = await direct(A, 9, affine(64), spansA);
    expect(below.outcome).toBe("length");
    expect(below.tokens).toHaveLength(9);
    {
      const env = grouped(affine(64)), seen: Projection[] = [];
      lane = seen;
      try {
        expect(await env.submit(A, 9, spansA)).toEqual({ tokens: below.tokens, accepted: below.accepted, outcome: "length" });
        expect(seen).toEqual(below.seen);
      } finally { lane = null; await env.close(); }
    }

    // Across the transition: A converts three tokens into decode, after its span.
    const start = A.length + 3;
    const across = await direct(A, 10, affine(start), [[3000, 3001]]);
    expect(across.outcome).toBe(dense ? "Error" : "length");
    expect(across.kinds.at(-1)!.some(kind => kind.includes("Quantized"))).toBe(true);
    const peer = await direct(B, 7, affine(start), spansB);
    expect(peer.outcome).toBe("length");
    {
      const env = grouped(affine(start)), seen: Projection[] = [];
      lane = seen;
      try {
        expect(await env.submit(A, 10, [[3000, 3001]])).toEqual({ tokens: across.tokens, accepted: across.accepted, outcome: refused });
        expect(seen).toEqual(across.seen);
        lane = null;
        // Beside an interleaved peer, each row equals its solo direct run; the group serves again.
        let overlap = 0;
        const watch = () => { overlap = Math.max(overlap, env.group.activeRows); };
        const [a, b] = await Promise.all([env.submit(A, 10, [[3000, 3001]], watch), env.submit(B, 7, spansB, watch)]);
        expect(overlap).toBe(2);
        expect(a).toEqual({ tokens: across.tokens, accepted: across.accepted, outcome: refused });
        expect(b).toEqual({ tokens: peer.tokens, accepted: peer.accepted, outcome: "length" });
        expect(await env.submit(B, 7, spansB)).toEqual({ tokens: peer.tokens, accepted: peer.accepted, outcome: "length" });
      } finally { lane = null; await env.close(); }
    }
  } finally { weights.dispose(); }
}, 900_000);
