import type {
  Cancellation, CancelReason, ExecutionPlan, GenerationEvent, GenerationOutcome,
  GenerationOutput, GenerationSession, MethodResult, MethodRun, RunControl,
  SessionState, Timer, TokenLogprobs,
} from "../contracts/generation";
import { CancellationSource, throwIfCancelled } from "./cancellation";

export interface SessionResources {
  readonly timer: Timer;
  readonly idleTimeoutMs: number;
  readonly maxQueuedEvents: number;
  readonly maxQueuedTokens: number;
  readonly maxTopLogprobs: number;
  reserveOutput(tokens: number): { buffer: Uint32Array; release(): void };
}

/** Lifecycle and bounded delivery only. No graph, cache, sampler, or method branches. */
export class EngineSession<Metrics> implements GenerationSession<Metrics> {
  readonly result: Promise<GenerationOutcome<Metrics>>;
  readonly events: AsyncIterable<GenerationEvent>;
  #state: SessionState = "created";
  #cancel = new CancellationSource();
  #settle!: (outcome: GenerationOutcome<Metrics>) => void;
  #started = false;
  #readerClaimed = false;
  #reading = false;
  #publishing = false;
  #queue: GenerationEvent[] = [];
  #queuedTokens = 0;
  #committed = 0;
  #sequence = 0;
  #wakeReader: (() => void) | undefined;
  #wakeProducer: (() => void) | undefined;
  #stopTimer: (() => void) | undefined;
  #unsubscribe: (() => void) | undefined;
  #buffer: Uint32Array | undefined;
  #limit = 0;

  constructor(
    readonly id: string,
    private readonly prepare: (cancellation: Cancellation) => Promise<ExecutionPlan<Metrics>>,
    private readonly control: RunControl,
    private readonly resources: SessionResources,
    private readonly onTerminal: () => void,
  ) {
    this.result = new Promise((resolve) => { this.#settle = resolve; });
    this.events = { [Symbol.asyncIterator]: () => this.#iterator() };
    const unsubscribe = control.cancellation?.subscribe((reason) => { void this.cancel(reason); });
    if (this.#state === "terminal") unsubscribe?.();
    else this.#unsubscribe = unsubscribe;
    if (this.#state !== "terminal") {
      if (control.output === "collect") this.#start();
      else this.#armIdle();
    }
  }

  get state(): SessionState { return this.#state; }

  async cancel(reason: CancelReason = "requested"): Promise<void> {
    if (this.#state !== "terminal") {
      this.#cancel.cancel(reason);
      this.#queue = [];
      this.#queuedTokens = 0;
      this.#wakeReader?.();
      this.#wakeProducer?.();
      this.#stopTimer?.();
      if (!this.#started) this.#finish({ status: "cancelled", reason, committedTokens: 0 });
    }
    await this.result;
  }

  close(): Promise<void> { return this.cancel("consumer_closed"); }

  #armIdle(): void {
    this.#stopTimer?.();
    this.#stopTimer = this.resources.timer.after(this.resources.idleTimeoutMs,
      () => { void this.cancel("consumer_idle"); });
  }

  #iterator(): AsyncIterator<GenerationEvent> {
    if (this.control.output !== "stream") throw new Error("collect sessions return output through result");
    if (this.#readerClaimed) throw new Error("generation events have one consumer");
    this.#readerClaimed = true;
    return {
      next: async () => {
        if (this.#reading) throw new Error("concurrent next() is not supported");
        this.#reading = true;
        this.#stopTimer?.();
        try {
          this.#start();
          while (!this.#queue.length && this.#state !== "terminal") {
            await new Promise<void>((resolve) => { this.#wakeReader = resolve; });
            this.#wakeReader = undefined;
          }
          const event = this.#queue.shift();
          if (!event) return { done: true, value: undefined };
          if (event.type === "committed") this.#queuedTokens -= event.tokenIds.length;
          this.#wakeProducer?.();
          if (this.#state !== "terminal") this.#armIdle();
          return { done: false, value: event };
        } finally { this.#reading = false; }
      },
      return: async () => { await this.close(); return { done: true, value: undefined }; },
      throw: async (error) => { await this.close(); throw error; },
    };
  }

  #start(): void {
    if (this.#started || this.#state === "terminal") return;
    this.#started = true;
    void this.#execute();
  }

  async #execute(): Promise<void> {
    let run: MethodRun<Metrics> | undefined;
    let reservation: ReturnType<SessionResources["reserveOutput"]> | undefined;
    let result: MethodResult<Metrics> | undefined;
    let failure: unknown;
    let failed = false;
    try {
      this.#state = "preparing";
      throwIfCancelled(this.#cancel);
      const plan = await this.prepare(this.#cancel);
      throwIfCancelled(this.#cancel);
      if (!Number.isSafeInteger(plan.outputTokenLimit) || plan.outputTokenLimit < 0)
        throw new Error("invalid planned output token limit");
      this.#limit = plan.outputTokenLimit;
      if (this.control.output === "collect") {
        reservation = this.resources.reserveOutput(this.#limit);
        this.#buffer = reservation.buffer;
      }
      run = await plan.method.createRun(this.#cancel);
      throwIfCancelled(this.#cancel);
      this.#state = "running";
      const output: GenerationOutput = {
        commit: (ids, logprobs) => this.#publish(ids, logprobs),
        progress: (completed, total) => this.#progress(completed, total),
      };
      result = await run.execute(output, this.#cancel);
    } catch (error) { failure = error; failed = true; }
    this.#state = "settling";
    // Terminal means resources are safe to release, not merely that JS stopped reading.
    let cleanupFailed = false;
    let cleanupError: string | undefined;
    try { await run?.close(); }
    catch (error) {
      cleanupError = error instanceof Error ? error.message : String(error);
      if (!failed) failure = error;
      failed = true;
      cleanupFailed = true;
    }
    reservation?.release(); // Completed output ownership transfers to the caller.
    const common = { committedTokens: this.#committed,
      ...(this.#buffer ? { output: this.#buffer.subarray(0, this.#committed) } : {}) };
    if (this.#cancel.reason && !cleanupFailed) {
      this.#finish({ status: "cancelled", reason: this.#cancel.reason, ...common });
    } else if (failed) {
      this.#finish({ status: "failed", error: { code: cleanupFailed ? "cleanup_failed" : "execution_failed",
        message: failure instanceof Error ? failure.message : String(failure),
        ...(cleanupError === undefined ? {} : { cleanupError }) }, ...common });
    } else {
      this.#finish({ status: "completed", result: result!, ...common });
    }
  }

  async #publish(ids: readonly number[], logprobs?: readonly (TokenLogprobs | undefined)[]): Promise<void> {
    if (this.#publishing) throw new Error("method must await each publication");
    this.#publishing = true;
    try {
      throwIfCancelled(this.#cancel);
      if (this.#state !== "running") throw new Error("publication outside method execution");
      if (ids.length > this.#limit - this.#committed) throw new Error("method exceeded planned output limit");
      if (logprobs && logprobs.length !== ids.length) throw new Error("logprobs must align with committed tokens");
      if (logprobs?.some((item) => (item?.top?.length ?? 0) > this.resources.maxTopLogprobs))
        throw new Error("top logprobs exceed session delivery capacity");
      for (const id of ids)
        if (!Number.isInteger(id) || id < 0 || id > 0xffffffff) throw new Error("invalid committed token id");
      if (this.#buffer) {
        if (logprobs) throw new Error("token logprobs require stream consumption");
        this.#buffer.set(ids, this.#committed);
        this.#committed += ids.length;
        return;
      }
      for (let offset = 0; offset < ids.length;) {
        const length = Math.min(ids.length - offset, this.resources.maxQueuedTokens);
        await this.#space(length);
        // Snapshot producer-owned arrays; later scratch-buffer reuse cannot alter events.
        const event: GenerationEvent = { type: "committed", sequence: this.#sequence++,
          tokenIds: ids.slice(offset, offset + length),
          ...(logprobs ? { logprobs: logprobs.slice(offset, offset + length).map((item) => item && ({
            ...(item.logprob === undefined ? {} : { logprob: item.logprob }),
            ...(item.top ? { top: item.top.map((entry) => ({ id: entry.id, logprob: entry.logprob })) } : {}),
          })) } : {}) };
        this.#queue.push(event);
        this.#queuedTokens += length;
        this.#committed += length;
        offset += length;
        this.#wakeReader?.();
      }
    } finally { this.#publishing = false; }
  }

  async #progress(completed: number, total?: number): Promise<void> {
    if (this.#publishing) throw new Error("method must await each publication");
    this.#publishing = true;
    try {
      throwIfCancelled(this.#cancel);
      if (this.#state !== "running") throw new Error("publication outside method execution");
      if (!Number.isFinite(completed) || completed < 0 ||
          (total !== undefined && (!Number.isFinite(total) || total < completed)))
        throw new Error("invalid progress");
      if (this.control.output === "collect") return;
      await this.#space(0);
      this.#queue.push({ type: "progress", completed, ...(total === undefined ? {} : { total }) });
      this.#wakeReader?.();
    } finally { this.#publishing = false; }
  }

  async #space(tokens: number): Promise<void> {
    while (this.#queue.length >= this.resources.maxQueuedEvents ||
           this.#queuedTokens + tokens > this.resources.maxQueuedTokens) {
      throwIfCancelled(this.#cancel);
      this.#armIdle();
      await new Promise<void>((resolve) => { this.#wakeProducer = resolve; });
      this.#wakeProducer = undefined;
    }
    throwIfCancelled(this.#cancel);
  }

  #finish(outcome: GenerationOutcome<Metrics>): void {
    if (this.#state === "terminal") return;
    this.#state = "terminal";
    this.#stopTimer?.();
    this.#unsubscribe?.();
    this.#settle(outcome);
    this.#wakeReader?.();
    this.onTerminal();
  }
}
