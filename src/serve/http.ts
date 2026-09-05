import { AdmissionRejected } from "../engine/admission";
// The HTTP end of the pipeline: build + admit a request (errors → a JSON
// error response in the surface's own shape), then run it and write the
// result as JSON, or as protocol frames while events arrive. One writer for
// every surface — the protocol object (OpenAI chat / text, Anthropic,
// Responses) and the error formatter are the only things that differ.
import type { CompletionStreamProtocol } from "./completion-sink";
import type { CompletionUsage } from "./completion-executor";
import type {
  AdmittedRequest, InferenceRequest, InferenceResult, InferenceStage,
} from "./inference-request";
import { openAiSummaryUsage, openAiUsage } from "./openai-wire";
import { RequestError } from "./pipeline";
import type { PromptResponseTrace } from "./prompt-response-trace";

export type ErrorFormatter = (status: number, message: string, body: Record<string, unknown>) => Response;

/** OpenAI-shaped error body: `{error: {message, …}}`. */
export const openAiError: ErrorFormatter = (status, _message, body) =>
  Response.json({ error: body }, { status });

/** RequestError → the surface's error response; anything else is a 500 with
 *  its stack logged (a 500 with no server-side trace is undebuggable). */
export function errorResponse(e: unknown, context: string, format: ErrorFormatter = openAiError): Response {
  if (e instanceof AdmissionRejected) return format(429, e.message, { message: e.message, type: "resource_admission", code: "queue_full" });
  if (e instanceof RequestError) return format(e.status, e.message, e.body);
  console.error(`[serve] 500 on ${context}:\n${(e as Error).stack ?? e}`);
  const message = (e as Error).message;
  return format(500, message, { message });
}

/** Build the InferenceRequest (a stage's `run`) and admit it, under the
 *  request's prompt-prepare trace span. A refusal at either step is the
 *  surface's error response, never a thrown exception past this point. */
export async function admit(
  stage: InferenceStage,
  build: () => Promise<InferenceRequest>,
  trace: PromptResponseTrace | undefined,
  context: string,
  format: ErrorFormatter = openAiError,
): Promise<{ admitted: AdmittedRequest } | { response: Response }> {
  const closePrepare = trace?.begin("request.prompt_prepare");
  try {
    const admitted = stage.admit(await build());
    closePrepare?.();
    return { admitted };
  } catch (e) {
    closePrepare?.();
    trace?.finish("error", { stage: "prepare_completion" });
    return { response: errorResponse(e, context, format) };
  }
}

const warningHeaders = (admitted: AdmittedRequest): Record<string, string> =>
  admitted.warnings.length ? { Warning: admitted.warnings.join(", ") } : {};

/** Run to completion, answer with `json(result)`. */
export async function respondJson(
  stage: InferenceStage,
  admitted: AdmittedRequest,
  json: (result: InferenceResult) => unknown,
  signal: AbortSignal,
  trace?: PromptResponseTrace,
  format: ErrorFormatter = openAiError,
): Promise<Response> {
  try {
    const result = await stage.run(admitted, { signal, ...(trace ? { trace } : {}) });
    trace?.mark("response.final_write");
    const response = Response.json(json(result), { headers: warningHeaders(admitted) });
    trace?.finish("success");
    return response;
  } catch (e) {
    trace?.finish(signal.aborted ? "abort" : "error");
    return errorResponse(e, `request ${admitted.requestId}`, format);
  }
}

/** Stream protocol frames as the model produces events. An error after the
 *  stream opened is the protocol's error frame(s) (the OpenAI protocols end
 *  the stream there; Anthropic/Responses also emit a terminal frame with
 *  the usage accumulated so far). */
export function respondStream(
  stage: InferenceStage,
  admitted: AdmittedRequest,
  protocol: CompletionStreamProtocol,
  signal: AbortSignal,
  trace?: PromptResponseTrace,
): Response {
  const streamAbort = new AbortController();
  const generationSignal = AbortSignal.any([signal, streamAbort.signal]);
  let cancelled = false;
  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      const enc = new TextEncoder();
      const emit = (frames: string[]) => {
        if (generationSignal.aborted) return;
        for (const frame of frames) controller.enqueue(enc.encode(frame));
      };
      let latestUsage: Readonly<CompletionUsage> | null = null;
      let wroteFirstEvent = false;
      let outcome: "success" | "error" | "abort" = "success";
      void (async () => {
        try {
          // The gateway owns lane selection + GPU exclusivity; this body
          // runs per-request (concurrently in batched mode, each writing
          // its own stream — the per-row fan-out).
          emit(protocol.start());
          const result = await stage.run(admitted, {
            signal: generationSignal,
            ...(trace ? { trace } : {}),
            onEvents: (events) => {
              if (events.length && !wroteFirstEvent) {
                wroteFirstEvent = true;
                trace?.mark("response.first_write");
              }
              emit(protocol.addEvents([...events]));
            },
            onUsageProgress: (usage) => { latestUsage = usage; },
          });
          emit(protocol.finish(result.finishReason, openAiSummaryUsage(result)));
          trace?.mark("response.final_write");
        } catch (e) {
          outcome = generationSignal.aborted ? "abort" : "error";
          if (!generationSignal.aborted) {
            emit([
              ...protocol.error((e as Error).message),
              ...protocol.finish("stop", latestUsage ? openAiUsage(latestUsage) : {}),
            ]);
          }
        } finally {
          trace?.finish(outcome);
          if (!cancelled) {
            if (generationSignal.aborted) controller.error(generationSignal.reason);
            else controller.close();
          }
        }
      })();
    },
    cancel(reason) {
      cancelled = true;
      streamAbort.abort(reason);
    },
  });
  return new Response(stream, {
    headers: {
      "content-type": "text/event-stream",
      "cache-control": "no-cache",
      connection: "keep-alive",
      ...warningHeaders(admitted),
    },
  });
}
