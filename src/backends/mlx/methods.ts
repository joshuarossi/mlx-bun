import type { GenerationOutput, InferenceMethod, MethodResult } from "../../contracts/generation";
import { throwIfCancelled } from "../../engine/cancellation";
import { generateAutoregressive, generateDenoising, type GenerateOptions, type GenerateStats } from "../../generate";
import { specRun } from "../../spec/serve-loop";
import type { MlxAutoregressiveBinding } from "./autoregressive";
import type { MlxSpeculativeBinding } from "./speculative";
import type { MlxDenoisingBinding } from "./diffusion";

/** The native algorithm owns cleanup in its finally. This host adapter owns
 * cancellation subscriptions and waits for the algorithm before closing. */
function nativeMethod<Metrics>(
  id: string,
  execute: (output: GenerationOutput, signal: AbortSignal) => Promise<MethodResult<Metrics>>,
): InferenceMethod<Metrics> {
  return {
    id,
    async createRun(cancellation) {
      throwIfCancelled(cancellation);
      const abort = new AbortController();
      const unsubscribe = cancellation.subscribe((reason) => abort.abort(
        new DOMException(`generation cancelled: ${reason}`, "AbortError"),
      ));
      let work: Promise<MethodResult<Metrics>> | undefined;
      let closing: Promise<void> | undefined;
      return {
        execute(output) {
          if (work || closing) return Promise.reject(new Error("method run can execute only once"));
          work = execute(output, abort.signal);
          return work;
        },
        close() {
          return closing ??= (async () => {
            abort.abort(new DOMException("method closed", "AbortError"));
            try { await work; } catch { /* execute owns the algorithm's error */ }
            finally { unsubscribe(); }
          })();
        },
      };
    },
  };
}

/** Each plan supplies its prepared per-run resources. Caches/media in options
 * retain the same ownership contract as generateAutoregressive. */
export function createAutoregressiveMethod(
  binding: MlxAutoregressiveBinding, promptIds: readonly number[], options: GenerateOptions,
): InferenceMethod<GenerateStats> {
  const prompt = [...promptIds];
  return nativeMethod("mlx-autoregressive", async (output, signal) => {
    const generation = generateAutoregressive(binding, prompt, { ...options, signal });
    for await (const item of generation)
      await output.commit([item.token], item.logprobs ? [item.logprobs] : undefined);
    const metrics = generation.stats;
    if (!metrics) throw new Error("AR method did not settle its metrics");
    return { finishReason: metrics.generatedTokens >= (options.maxTokens ?? 512) ? "length" : "stop", metrics };
  });
}

export function createSpeculativeMethod(
  binding: MlxSpeculativeBinding, numDraftTokens: number,
  promptIds: readonly number[], options: GenerateOptions,
): InferenceMethod<GenerateStats> {
  const prompt = [...promptIds];
  return nativeMethod("mlx-speculative", async (output, signal) => {
    const metrics = await specRun(binding, numDraftTokens, prompt, { ...options, signal },
      (token) => output.commit([token]));
    return { finishReason: metrics.generatedTokens >= (options.maxTokens ?? 512) ? "length" : "stop", metrics };
  });
}

/** The canvas stays private. This method publishes only the finished result. */
export function createDenoisingMethod<State>(
  binding: MlxDenoisingBinding<State>, promptIds: readonly number[], options: GenerateOptions,
): InferenceMethod<GenerateStats> {
  const prompt = [...promptIds];
  return nativeMethod("mlx-denoising", async (output, signal) => {
    const generation = generateDenoising(binding, prompt, { ...options, signal });
    for await (const item of generation) await output.commit([item.token]);
    const metrics = generation.stats;
    if (!metrics) throw new Error("denoising method did not settle its metrics");
    return { finishReason: metrics.generatedTokens >= (options.maxTokens ?? 256) ? "length" : "stop", metrics };
  });
}
