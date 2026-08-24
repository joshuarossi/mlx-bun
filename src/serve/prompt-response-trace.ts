import { runtimeValue } from "../runtime-config";

export const P2R_TRACE_PREFIX = "[p2r] ";
export const P2R_TRACE_VERSION = 1;

export type P2RTraceOutcome = "success" | "error" | "abort";

export type P2RTracePhase =
  | "request.body_parse"
  | "request.prompt_prepare"
  | "completion.total"
  | "completion.placement"
  | "engine.admission_wait"
  | "cache.lookup_restore"
  | "prefill.total"
  | "prefill.batch_setup"
  | "prefill.chunk"
  | "prefill.kv_maintenance"
  | "token_zero.total"
  | "token_zero.forward"
  | "token_zero.head"
  | "token_zero.sample"
  | "response.first_write"
  | "response.final_write";

export type P2RTraceAttributes = Readonly<Record<
  string,
  string | number | boolean | null
>>;

export interface P2RTraceEvent {
  phase: P2RTracePhase;
  startMs: number;
  durationMs: number;
  attributes?: P2RTraceAttributes;
}

export interface P2RTraceRecord {
  version: typeof P2R_TRACE_VERSION;
  traceId: string;
  requestId: string;
  route: string;
  clock: "monotonic-ms";
  outcome: P2RTraceOutcome;
  totalMs: number;
  events: P2RTraceEvent[];
  attributes?: P2RTraceAttributes;
}

type Clock = () => number;
type Emit = (record: P2RTraceRecord) => void;

export interface PromptResponseTraceOptions {
  traceId: string;
  requestId: string;
  route: string;
  clock?: Clock;
  emit?: Emit;
}

/** Request-local diagnostic trace. Callers pass it explicitly because the
 * continuous scheduler interleaves rows and cannot safely use ambient async
 * context. No instance is created unless MLX_BUN_P2R_TRACE=1. */
export class PromptResponseTrace {
  readonly #startedAt: number;
  readonly #events: P2RTraceEvent[] = [];
  readonly #clock: Clock;
  readonly #emit: Emit;
  #finished = false;

  readonly traceId: string;
  readonly requestId: string;
  readonly route: string;

  constructor(options: PromptResponseTraceOptions) {
    this.traceId = options.traceId;
    this.requestId = options.requestId;
    this.route = options.route;
    this.#clock = options.clock ?? performance.now.bind(performance);
    this.#emit = options.emit ?? ((record) => {
      console.error(`${P2R_TRACE_PREFIX}${JSON.stringify(record)}`);
    });
    this.#startedAt = this.#clock();
  }

  get finished(): boolean {
    return this.#finished;
  }

  /** Start one span. The returned closer is idempotent so finally blocks and
   * early exits cannot double-record a phase. */
  begin(phase: P2RTracePhase, attributes?: P2RTraceAttributes): () => void {
    const startedAt = this.#clock();
    let closed = false;
    return () => {
      if (closed || this.#finished) return;
      closed = true;
      const endedAt = this.#clock();
      this.#events.push({
        phase,
        startMs: startedAt - this.#startedAt,
        durationMs: endedAt - startedAt,
        ...(attributes ? { attributes } : {}),
      });
    };
  }

  mark(phase: P2RTracePhase, attributes?: P2RTraceAttributes): void {
    if (this.#finished) return;
    this.#events.push({
      phase,
      startMs: this.#clock() - this.#startedAt,
      durationMs: 0,
      ...(attributes ? { attributes } : {}),
    });
  }

  finish(
    outcome: P2RTraceOutcome,
    attributes?: P2RTraceAttributes,
  ): P2RTraceRecord | null {
    if (this.#finished) return null;
    this.#finished = true;
    const totalMs = this.#clock() - this.#startedAt;
    const record: P2RTraceRecord = {
      version: P2R_TRACE_VERSION,
      traceId: this.traceId,
      requestId: this.requestId,
      route: this.route,
      clock: "monotonic-ms",
      outcome,
      totalMs,
      events: [...this.#events].sort((a, b) => a.startMs - b.startMs),
      ...(attributes ? { attributes } : {}),
    };
    this.#emit(record);
    return record;
  }
}

export function createPromptResponseTrace(
  options: PromptResponseTraceOptions,
): PromptResponseTrace | undefined {
  return runtimeValue("MLX_BUN_P2R_TRACE") === "1"
    ? new PromptResponseTrace(options)
    : undefined;
}
