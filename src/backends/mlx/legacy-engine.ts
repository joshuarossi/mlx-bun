import type { ExecutionPlanner, InferenceEngine, Cancellation, Timer } from "../../contracts/generation";
import { createInferenceEngine, type EngineOptions } from "../../engine/engine";
import { throwIfCancelled } from "../../engine/cancellation";
import type { GenerateOptions, GenerateStats } from "../../generate";
import type { GenerationGateway, RequestShape } from "../../serve/generation-gateway";

/** Transitional adapter for text requests whose policy/shape was already
 * resolved by the caller. Native request resources still belong to the legacy
 * completion executor; they are deliberately absent from this token API. */
export type LegacyTextOptions = Omit<GenerateOptions,
  "signal" | "cache" | "grammar" | "fill" | "adapters" | "promptEmbeddings" |
  "imageMask" | "multimodalMask" | "visionPixels" | "onPrefillDone" |
  "onDecodeCheckpoint" | "initialPendingToken" | "initialGeneratedTokens" |
  "originalPromptTokens" | "snapshotAt" | "checkpointEveryTokens"
>;

export interface LegacyTextRequest {
  readonly promptIds: readonly number[];
  readonly options: LegacyTextOptions;
  readonly shape: RequestShape;
}

export const hostTimer: Timer = {
  after(milliseconds, callback) {
    const timer = setTimeout(callback, milliseconds);
    return () => { clearTimeout(timer); };
  },
};

/** AbortSignal stays at the host boundary. Every subscription has one owner. */
function abortBridge(cancellation: Cancellation): { signal: AbortSignal; close(): void } {
  const controller = new AbortController();
  const unsubscribe = cancellation.subscribe((reason) => {
    controller.abort(new DOMException(`generation cancelled: ${reason}`, "AbortError"));
  });
  return { signal: controller.signal, close: unsubscribe };
}

/** Reuses the gateway's placement, exclusive lease, prompt cache, batching,
 * and quant-specific execution. The portable session never imports them.
 * Closing this engine cancels its sessions; it does not dispose a shared gateway. */
export function createLegacyInferenceEngine(
  gateway: Pick<GenerationGateway, "place" | "run">,
  options: Omit<EngineOptions, "timer"> & { timer?: Timer } = {},
): InferenceEngine<LegacyTextRequest, GenerateStats> {
  const planner: ExecutionPlanner<LegacyTextRequest, GenerateStats> = {
    async plan(request, cancellation) {
      throwIfCancelled(cancellation);
      if (request.shape.hasVision || request.shape.hasAdapters || request.shape.hasGrammar)
        throw new Error("native request resources require the legacy completion executor");
      const placement = gateway.place(request.shape, request.options);
      const maxTokens = request.options.maxTokens ?? 512;
      return {
        id: `legacy:${placement.mechanism}`, outputTokenLimit: maxTokens,
        method: {
          id: "legacy-gateway",
          async createRun(cancellation) {
            const bridge = abortBridge(cancellation);
            return {
              async execute(output) {
                const stats = await gateway.run([...request.promptIds], request.options,
                  async (token, logprobs) => { await output.commit([token], logprobs ? [logprobs] : undefined); },
                  undefined, request.shape, placement, bridge.signal);
                return { finishReason: stats.generatedTokens >= maxTokens ? "length" : "stop", metrics: stats };
              },
              async close() { bridge.close(); },
            };
          },
        },
      };
    },
  };
  const engine = createInferenceEngine(planner, { ...options, timer: options.timer ?? hostTimer });
  return {
    open(request, control) {
      // Snapshot before demand-start: callers may reuse/mutate request arrays.
      // LegacyTextOptions contains data only; no native handles or callbacks.
      const snapshot = structuredClone(request);
      if (!snapshot.promptIds.length || snapshot.promptIds.some((id) => !Number.isInteger(id) || id < 0 || id > 0xffffffff))
        return Promise.reject(new Error("prompt must contain valid token ids"));
      const maxTokens = snapshot.options.maxTokens ?? 512;
      if (!Number.isSafeInteger(maxTokens) || maxTokens <= 0)
        return Promise.reject(new Error("legacy generation requires a positive token limit"));
      if ((snapshot.options.topLogprobs ?? 0) > (options.maxTopLogprobs ?? 20))
        return Promise.reject(new Error("top logprobs exceed session delivery capacity"));
      if (control.output === "collect" && (snapshot.options.logprobs || snapshot.options.topLogprobs))
        return Promise.reject(new Error("token logprobs require stream consumption"));
      return engine.open(snapshot, control);
    },
    close: () => engine.close(),
  };
}
