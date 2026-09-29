// Denoising generation: adapts a non-autoregressive denoising graph to the
// Generation contract. The denoising engine runs its own prefill and canvas
// loop to completion (`denoiseAsync`); only then are the finished canvas's
// tokens yielded one by one, so nothing streams while it runs. There is no
// chunked prefill, decode pipelining or early token-zero yield here (those are
// the autoregressive path), and prefill/cache stats are zero.

import { runtimeConfig } from "../runtime/config";
import { type MlxDenoisingBinding } from "./bindings/denoising";
import { adapterScoped,modelNeedsWiredLimit,usageScoped,wiredScoped } from "./scopes";
import { denoiseAsync, type DiffusionGenOptions } from "./diffusion";
import { Generation } from "./result";
import { GenerateOptions,GenerateStats,GeneratedToken } from "./types";

/** Denoising bindings use their own state and feedback graph. Each request
 * draws from its own key sequence; callers still serialize model access. */
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

/** The served denoising request: greedy confidence-threshold, a fresh canvas
 *  seed unless the caller pins one, the checkpoint's stopping set {1, 106}
 *  united with any caller EOS, and 256 tokens unless the caller sets a limit. */
export function denoisingRequestOptions(options: GenerateOptions): DiffusionGenOptions {
  const seed =
    options.seed !== undefined
      ? BigInt(options.seed)
      : BigInt(Math.floor(Math.random() * 0x7fffffff));
  return {
    maxTokens: options.maxTokens ?? 256,
    sampler: "confidence-threshold",
    temperature: 0,
    eosTokenIds: [...new Set([1, 106, ...(options.eosTokenIds ?? [])])],
    seed,
    visionPixels: options.visionPixels,
  };
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
  const result = await denoiseAsync(binding.graph, promptTokens, denoisingRequestOptions(options), options.signal);
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
