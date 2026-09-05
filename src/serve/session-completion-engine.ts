import { cleanupFailure } from "../engine/resources";
import type { ExecutionPlan, InferenceMethod, Timer } from "../contracts/generation";
import { CancellationSource, throwIfCancelled } from "../engine/cancellation";
import { createInferenceEngine } from "../engine/engine";
import type { GenerateStats } from "../generate";
import type { CompletionEngine } from "./completion-executor";

const timer: Timer = {
  after(ms, callback) {
    const handle = setTimeout(callback, ms);
    return () => clearTimeout(handle);
  },
};

type RuntimeArguments = Parameters<CompletionEngine["run"]>;

export interface CompletionRunRequest {
  prompt: RuntimeArguments[0]; options: RuntimeArguments[1]; vision?: RuntimeArguments[3];
  shape: RuntimeArguments[4]; placement: RuntimeArguments[5];
  signal?: RuntimeArguments[6]; trace?: RuntimeArguments[7];
}

/** Bind one selected runtime operation to the method-neutral session. */
export function createCompletionMethod(
  runtime: CompletionEngine, request: CompletionRunRequest,
  onStarted?: () => void, onFailure?: (error: unknown) => void,
): InferenceMethod<GenerateStats> {
  const { prompt, options, vision, shape, placement, signal, trace } = request;
  const maxTokens = options.maxTokens ?? 512;
  return {
    id: placement.execution?.method ?? placement.mechanism,
    async createRun(cancel) {
      throwIfCancelled(cancel);
      const controller = new AbortController();
      const unsubscribe = cancel.subscribe(() => controller.abort(
        signal?.reason ?? new DOMException("generation cancelled", "AbortError"),
      ));
      return {
        async execute(output) {
          onStarted?.();
          try {
            const stats = await runtime.run(prompt, options,
              (token, logprobs) => output.commit([token], logprobs ? [logprobs] : undefined),
              vision, shape, placement, controller.signal, trace);
            return { finishReason: stats.generatedTokens >= maxTokens ? "length" : "stop", metrics: stats };
          } catch (error) { onFailure?.(error); throw error; }
        },
        async close() { unsubscribe(); },
      };
    },
  };
}

/** HTTP already bounds its output in CompletionSink. Deliver through the same
 * session lifecycle without inserting another queue between sampling and the
 * stop/tool parser. The runtime retains scheduling and native resource ownership. */
export function createSessionCompletionEngine(
  runtime: CompletionEngine,
  releaseUnstarted: (options: Parameters<CompletionEngine["run"]>[1],
    vision: Parameters<CompletionEngine["run"]>[3]) => void,
): CompletionEngine & { close(): Promise<void> } {
  const engine = createInferenceEngine<ExecutionPlan<GenerateStats>, GenerateStats>({
    async plan(plan, cancellation) { throwIfCancelled(cancellation); return plan; },
  }, { timer });
  return {
    place: (shape, options) => runtime.place(shape, options),
    async run(prompt, options, onToken, vision, shape, placement, signal, trace) {
      const cancellation = new CancellationSource();
      const abort = () => cancellation.cancel("requested");
      signal?.addEventListener("abort", abort, { once: true });
      if (signal?.aborted) abort();
      let started = false;
      let failure: unknown;
      let failed = false;
      const maxTokens = options.maxTokens ?? 512;
      const method = createCompletionMethod(runtime,
        { prompt, options, vision, shape, placement, signal, trace },
        () => { started = true; },
        (error) => { failed = true; failure = error; });
      try {
        const session = await engine.open({ id: method.id, method, outputTokenLimit: maxTokens }, {
          output: "callback", cancellation,
          async onTokens(ids, logprobs) {
            for (let i = 0; i < ids.length; i++)
              if (await onToken(ids[i]!, logprobs?.[i]) === false) return false;
          },
        });
        const outcome = await session.result;
        if (outcome.status === "completed") return outcome.result.metrics;
        if (failed) throw failure; // preserve native/HTTP error identity and stack
        if (outcome.status === "cancelled")
          throw signal?.reason ?? new DOMException("generation cancelled", "AbortError");
        throw new Error(outcome.error.message);
      } catch (error) {
        if (!started) {
          started = true; // release once, preserving the original execution error
          cleanupFailure(error, () => releaseUnstarted(options, vision));
        }
        throw error;
      } finally {
        signal?.removeEventListener("abort", abort);
        if (!started) releaseUnstarted(options, vision);
      }
    },
    close: () => engine.close(),
  };
}
