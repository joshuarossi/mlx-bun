/** Portable execution contracts. No transport, model, tensor, or runtime imports. */
export type CancelReason = "requested" | "consumer_closed" | "consumer_idle" | "engine_closed";

export interface Cancellation {
  readonly reason: CancelReason | undefined;
  /** Invoked immediately when already cancelled. Returns an idempotent unsubscribe. */
  subscribe(listener: (reason: CancelReason) => void): () => void;
}

export interface TokenLogprobs {
  /** Selected-token logprob, before sampler truncation. */
  logprob?: number;
  /** Top-k pairs, sorted by descending logprob. */
  top?: { id: number; logprob: number }[];
}

export type GenerationEvent =
  | { readonly type: "committed"; readonly sequence: number;
      readonly tokenIds: readonly number[]; readonly logprobs?: readonly (TokenLogprobs | undefined)[] }
  | { readonly type: "progress"; readonly completed: number; readonly total?: number };

/** Methods publish in order and await each publication before publishing again.
 * Only committed tokens cross this boundary. Tentative canvases/drafts stay private. */
export interface GenerationOutput {
  /** False requests a normal stop. The method must stop publishing and settle
   * its metrics after releasing its private execution state. */
  commit(tokenIds: readonly number[], logprobs?: readonly (TokenLogprobs | undefined)[]): Promise<void | false>;
  progress(completed: number, total?: number): Promise<void>;
}

export interface MethodResult<Metrics> {
  readonly finishReason: "stop" | "length";
  readonly metrics: Metrics;
}

/** One attempt's private state, including any pending device work.
 * close must await safe resource release, including on execute failure. */
export interface MethodRun<Metrics> {
  execute(output: GenerationOutput, cancellation: Cancellation): Promise<MethodResult<Metrics>>;
  close(): Promise<void>;
}

export interface InferenceMethod<Metrics> {
  readonly id: string;
  /** A rejected creation must release its own partial allocations. */
  createRun(cancellation: Cancellation): Promise<MethodRun<Metrics>>;
}

export interface ExecutionPlan<Metrics> {
  readonly id: string;
  readonly outputTokenLimit: number;
  readonly method: InferenceMethod<Metrics>;
}

export interface ExecutionPlanner<Request, Metrics> {
  /** Planning selects a bound implementation; it does not allocate device state. */
  plan(request: Request, cancellation: Cancellation): Promise<ExecutionPlan<Metrics>>;
}

export type GenerationOutcome<Metrics> =
  | { readonly status: "completed"; readonly committedTokens: number;
      readonly output?: Uint32Array; readonly result: MethodResult<Metrics> }
  | { readonly status: "cancelled"; readonly committedTokens: number;
      readonly output?: Uint32Array; readonly reason: CancelReason }
  | { readonly status: "failed"; readonly committedTokens: number;
      readonly output?: Uint32Array; readonly error: { readonly code: string; readonly message: string;
        readonly cleanupError?: string } };

export type SessionState = "created" | "preparing" | "running" | "settling" | "terminal";

export type RunControl = {
  /** collect returns token IDs; per-token logprobs require stream consumption. */
  readonly output: "stream" | "collect";
  readonly cancellation?: Cancellation;
} | {
  /** Direct delivery for consumers that already own bounded output storage.
   * The callback is awaited before execution continues; false is a normal
   * token stop. Borrowed arrays are valid until the callback settles. */
  readonly output: "callback";
  readonly onTokens: GenerationOutput["commit"];
  readonly cancellation?: Cancellation;
};

export interface GenerationSession<Metrics> {
  readonly id: string;
  readonly state: SessionState;
  /** Single consumer. Stream mode starts on first next(); collect mode has no events. */
  readonly events: AsyncIterable<GenerationEvent>;
  /** Always resolves with one terminal outcome, after native resources are released. */
  readonly result: Promise<GenerationOutcome<Metrics>>;
  cancel(reason?: CancelReason): Promise<void>;
  close(): Promise<void>;
}

export interface InferenceEngine<Request, Metrics> {
  open(request: Request, control: RunControl): Promise<GenerationSession<Metrics>>;
  close(): Promise<void>;
}

/** Injected host timer. The portable engine has no DOM/Node/Bun dependency. */
export interface Timer {
  after(milliseconds: number, callback: () => void): () => void;
}
