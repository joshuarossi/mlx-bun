import type { ExecutionPlanner, GenerationSession, InferenceEngine, RunControl, Timer } from "../contracts/generation";
import { EngineSession, type SessionResources } from "./session";

export interface EngineOptions {
  readonly timer: Timer;
  /** Deadline for an unread stream or a producer blocked by an idle consumer. */
  readonly idleTimeoutMs?: number;
  readonly maxQueuedEvents?: number;
  readonly maxQueuedTokens?: number;
  readonly maxTopLogprobs?: number;
  /** Aggregate output buffers for active collecting sessions, in tokens (4 bytes each).
   * Once terminal, output storage belongs to the caller. */
  readonly maxCollectTokens?: number;
}

export function createInferenceEngine<Request, Metrics>(
  planner: ExecutionPlanner<Request, Metrics>, options: EngineOptions,
): InferenceEngine<Request, Metrics> {
  const idleTimeoutMs = options.idleTimeoutMs ?? 30_000;
  const maxQueuedEvents = options.maxQueuedEvents ?? 32;
  const maxQueuedTokens = options.maxQueuedTokens ?? 256;
  const maxCollectTokens = options.maxCollectTokens ?? 65_536;
  const maxTopLogprobs = options.maxTopLogprobs ?? 20;
  for (const [name, value] of Object.entries({ idleTimeoutMs, maxQueuedEvents, maxQueuedTokens, maxCollectTokens, maxTopLogprobs }))
    if (!Number.isSafeInteger(value) || value <= 0) throw new Error(`${name} must be a positive safe integer`);
  const sessions = new Set<GenerationSession<Metrics>>();
  let closed = false;
  let closing: Promise<void> | undefined;
  let nextId = 0;
  let reserved = 0;
  const resources: SessionResources = {
    timer: options.timer, idleTimeoutMs, maxQueuedEvents, maxQueuedTokens, maxTopLogprobs,
    reserveOutput(tokens) {
      if (tokens > maxCollectTokens - reserved) throw new Error("collection output capacity exceeded");
      const buffer = new Uint32Array(tokens);
      reserved += tokens;
      let released = false;
      return { buffer, release() { if (!released) { released = true; reserved -= tokens; } } };
    },
  };
  return {
    async open(request: Request, control: RunControl) {
      if (closed) throw new Error("inference engine is closed");
      let session: EngineSession<Metrics> | undefined;
      session = new EngineSession(String(++nextId), (cancellation) => planner.plan(request, cancellation),
        { output: control.output, cancellation: control.cancellation }, resources,
        () => { if (session) sessions.delete(session); });
      if (session.state !== "terminal") sessions.add(session);
      return session;
    },
    close() {
      closed = true;
      return closing ??= Promise.all([...sessions].map((session) => session.cancel("engine_closed"))).then(() => {});
    },
  };
}
