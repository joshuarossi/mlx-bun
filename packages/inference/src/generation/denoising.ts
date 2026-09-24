// Streaming generation — port of mlx-lm's generate_step:
// - prefill in chunks; cache state evaluated per chunk (bounded transient
//   memory), logits never computed for non-final prefill positions
// - decode pipelining via mx.async_eval: step n+1's graph is built and
//   dispatched before step n's token is read back, so the GPU never idles
//   on the JS round-trip
// - opt-in early token-zero yield reduces latency before that pipeline starts
// - sampling stays on-device; only the chosen token id crosses to JS

import { runtimeConfig } from "../execution/config";
import { type MlxDenoisingBinding } from "../execution/denoising";
import { adapterScoped,modelNeedsWiredLimit,usageScoped,wiredScoped } from '../execution/generation-scopes';
import { denoiseAsync } from "./diffusion";
import { Generation } from './result';
import { GenerateOptions,GenerateStats,GeneratedToken } from './types';

/** Denoising bindings use their own state and feedback graph. Callers hold
 * the native runtime's exclusive generation lease, including its global RNG. */
export function generateDenoising<State>(
  binding: MlxDenoisingBinding<State>, promptTokens: number[], options: GenerateOptions = {},
): Generation {
  let inner = generateDiffusionInner(binding, promptTokens, options);
  if (options.adapters?.length && binding.adapters)
    inner = adapterScoped({ loraState: binding.adapters }, options.adapters, inner);
  if (binding.memory.expertRuntime?.finishUsage || binding.memory.expertRuntime?.flushUsage)
    inner = usageScoped(binding.memory, inner);
  const runtime = binding.runtime ?? runtimeConfig();
  return new Generation(modelNeedsWiredLimit(binding.memory, undefined,
    runtime.value("MLX_BUN_FORCE_WIRE") === "1") ? wiredScoped(inner) : inner, runtime);
}

/** Non-autoregressive diffusion generation, adapted to the AR Generation
 *  contract. Runs the denoising engine (its own prefill + canvas loop) and
 *  streams the emitted tokens. v1: greedy (temperature 0, confidence-threshold
 *  sampler — the OptiQ default); per-block intra-stream + temperature>0
 *  (categorical) are follow-ups. */
async function* generateDiffusionInner<State>(
  binding: MlxDenoisingBinding<State>,
  promptTokens: number[],
  options: GenerateOptions,
): AsyncGenerator<GeneratedToken, GenerateStats> {
  options.signal?.throwIfAborted();
  const t0 = performance.now();
  const maxTokens = options.maxTokens ?? 256;
  // A fresh random canvas seed per request unless the caller pins one.
  const seed =
    options.seed !== undefined
      ? BigInt(options.seed)
      : BigInt(Math.floor(Math.random() * 0x7fffffff));
  // The shipped checkpoint's tokenizer stops on {1, 106}; union any caller eos.
  const eos = [...new Set([1, 106, ...(options.eosTokenIds ?? [])])];
  const result = await denoiseAsync(binding.graph, promptTokens, {
    maxTokens,
    sampler: "confidence-threshold",
    temperature: 0,
    eosTokenIds: eos,
    seed,
    visionPixels: options.visionPixels,
  }, options.signal);
  const decodeMs = performance.now() - t0;
  let index = 0;
  let failure: { error: unknown } | undefined;
  try {
    for (const token of result.tokens) {
      options.signal?.throwIfAborted();
      yield { token, index: index++ };
    }
  } catch (error) { failure = { error }; }
  finally {
    // A stop parser may close delivery before the finished canvas is exhausted.
    // Settle the emitted count on return(), without suppressing cancellation/errors.
    if (failure) throw failure.error;
    return {
      promptTokens: promptTokens.length,
      cachedTokens: 0,
      generatedTokens: index,
      prefillTps: 0,
      decodeTps: index / Math.max(decodeMs / 1000, 1e-9),
      prefillMs: 0,
      decodeMs,
      cacheTokens: [],
    };
  }
}
