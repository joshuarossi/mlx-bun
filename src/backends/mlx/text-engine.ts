import { createCompletionMethod } from "../../serve/session-completion-engine";
import type { ExecutionPlanner, InferenceEngine, Timer } from "../../contracts/generation";
import { createInferenceEngine, type EngineOptions } from "../../engine/engine";
import { throwIfCancelled } from "../../engine/cancellation";
import type { GenerateOptions, GenerateStats } from "../../generate";
import type { GenerationGateway, RequestShape } from "../../serve/generation-gateway";

/** Data-only API for text requests whose policy/shape was already
 * resolved by the caller. Native request resources still belong to the prepared
 * completion API; they are deliberately absent from this token API. */
export type TextGenerationOptions = Omit<GenerateOptions,
  "signal" | "cache" | "grammar" | "fill" | "adapters" | "promptEmbeddings" |
  "imageMask" | "multimodalMask" | "visionPixels" | "onPrefillDone" |
  "onDecodeCheckpoint" | "initialPendingToken" | "initialGeneratedTokens" |
  "originalPromptTokens" | "snapshotAt" | "checkpointEveryTokens"
>;

export interface TextGenerationRequest {
  readonly promptIds: readonly number[];
  readonly options: TextGenerationOptions;
  readonly shape: RequestShape;
}

export const hostTimer: Timer = {
  after(milliseconds, callback) {
    const timer = setTimeout(callback, milliseconds);
    return () => { clearTimeout(timer); };
  },
};

/** Reuses the gateway's placement, exclusive lease, prompt cache, batching,
 * and quant-specific execution. The portable session never imports them.
 * Closing this engine cancels its sessions; it does not dispose a shared gateway. */
export function createTextInferenceEngine(
  gateway: Pick<GenerationGateway, "place" | "run">,
  options: Omit<EngineOptions, "timer"> & { timer?: Timer } = {},
): InferenceEngine<TextGenerationRequest, GenerateStats> {
  const planner: ExecutionPlanner<TextGenerationRequest, GenerateStats> = {
    async plan(request, cancellation) {
      throwIfCancelled(cancellation);
      if (request.shape.hasVision || request.shape.hasAdapters || request.shape.hasGrammar)
        throw new Error("native request resources require the prepared completion API");
      const placement = gateway.place(request.shape, request.options);
      const maxTokens = request.options.maxTokens ?? 512;
      return {
        id: `text:${placement.mechanism}`, outputTokenLimit: maxTokens,
        method: createCompletionMethod(gateway, {
          prompt: [...request.promptIds], options: request.options,
          shape: request.shape, placement,
        }),
      };
    },
  };
  const engine = createInferenceEngine(planner, { ...options, timer: options.timer ?? hostTimer });
  return {
    open(request, control) {
      // Snapshot before demand-start: callers may reuse/mutate request arrays.
      // TextGenerationOptions contains data only; no native handles or callbacks.
      const snapshot = structuredClone(request);
      if (!snapshot.promptIds.length || snapshot.promptIds.some((id) => !Number.isInteger(id) || id < 0 || id > 0xffffffff))
        return Promise.reject(new Error("prompt must contain valid token ids"));
      const maxTokens = snapshot.options.maxTokens ?? 512;
      if (!Number.isSafeInteger(maxTokens) || maxTokens <= 0)
        return Promise.reject(new Error("text generation requires a positive token limit"));
      if ((snapshot.options.topLogprobs ?? 0) > (options.maxTopLogprobs ?? 20))
        return Promise.reject(new Error("top logprobs exceed session delivery capacity"));
      if (control.output === "collect" && (snapshot.options.logprobs || snapshot.options.topLogprobs))
        return Promise.reject(new Error("token logprobs require stream consumption"));
      return engine.open(snapshot, control);
    },
    close: () => engine.close(),
  };
}
