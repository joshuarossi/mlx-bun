// InferenceRequest: a prompt (token ids + optional media embeddings) with
// resolved generation settings, ready for a model. InferenceStage first
// ADMITS it (memory ceiling → reject or clamp; the resolved settings become
// an opaque, single-use plan) and then RUNS it — the gateway routes it to
// the lane it belongs to (serial / batch / spec) and the executor returns
// the terminal InferenceResult. Every completion surface — chat, raw text,
// Anthropic, Responses — produces one of these and reads one of those.
import {
  CompletionRejected,
  prepareCompletion,
  type CompletionExecutor,
  type CompletionPreparation,
  type CompletionSummary,
  type PreparedCompletion,
} from "./completion-executor";
import { createTimedFlowControl } from "./completion-sink";
import { runtimeValue } from "../runtime-config";
import { RequestError, type RunControl } from "./pipeline";

export interface InferenceRequest
  extends Omit<CompletionPreparation, "createFlowControl" | "onPlacement"> {
  /** SSE consumers pace event delivery (timed flow control); JSON consumers
   *  take the whole result at the end. */
  stream: boolean;
  /** Non-fatal notes for the response (`Warning` header): e.g. a grammar
   *  that failed to compile and degraded to prompt injection. */
  warnings: string[];
}

/** An admitted request: its plan is sealed and it can run exactly once. */
export interface AdmittedRequest {
  requestId: string;
  warnings: string[];
  prepared: PreparedCompletion;
}

export type InferenceResult = CompletionSummary;

export class InferenceStage {
  constructor(private readonly executor: Pick<CompletionExecutor, "execute">) {}

  /** Admission: throws RequestError(400, memory_admission) when the prompt
   *  leaves no room to generate inside the safe context; otherwise clamps
   *  and seals the plan. Owned resources dispose on rejection. */
  admit(request: InferenceRequest): AdmittedRequest {
    const { stream, warnings, ...preparation } = request;
    try {
      const prepared = prepareCompletion({
        ...preparation,
        ...(stream
          ? {
              createFlowControl: ({ mechanism }: { mechanism: string }) =>
                createTimedFlowControl(mechanism === "serial"),
            }
          : {}),
        onPlacement: ({ mechanism, shape }) => {
          if (runtimeValue("MLX_BUN_LANE_DEBUG") === "1")
            console.error(
              `[scheduling] mechanism=${mechanism} shape=${JSON.stringify(shape)} ` +
                `t=${Date.now() % 100000}`,
            );
        },
      });
      return { requestId: request.requestId, warnings, prepared };
    } catch (error) {
      if (!(error instanceof CompletionRejected)) throw error;
      throw new RequestError(error.status, error.error.message, error.error);
    }
  }

  run(admitted: AdmittedRequest, control: RunControl = {}): Promise<InferenceResult> {
    return this.executor.execute(admitted.prepared, {
      ...(control.signal ? { signal: control.signal } : {}),
      ...(control.trace ? { trace: control.trace } : {}),
      ...(control.onEvents ? { onEvents: control.onEvents } : {}),
      ...(control.onUsageProgress ? { onUsageProgress: control.onUsageProgress } : {}),
    });
  }
}
