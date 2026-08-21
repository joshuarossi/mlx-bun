export interface CompletionToolCall {
  id: string;
  type: "function";
  function: { name: string; arguments: string };
}

export type CompletionEvent =
  | { type: "content"; text: string }
  | { type: "reasoning"; text: string }
  | { type: "tool_calls"; calls: CompletionToolCall[] };

export type CompletionFlowControl = false | Promise<void> | undefined;

export interface CompletionPush {
  events: CompletionEvent[];
  control: CompletionFlowControl;
}

export interface CompletionResult {
  events: CompletionEvent[];
  content: string;
  reasoning: string;
  toolCalls: CompletionToolCall[];
  stopped: boolean;
}

export type CompletionFinishReason = "stop" | "length" | "tool_calls";

export interface CompletionStreamProtocol {
  start(): string[];
  addEvents(events: CompletionEvent[]): string[];
  finish(reason: CompletionFinishReason, usage: Record<string, unknown>): string[];
  error(message: string): string[];
}

export interface TokenTextRouter {
  push(token: number): string;
  flush(): string;
  takeReasoning(): string;
  toolCalls(): CompletionToolCall[];
}

export interface TextStopper {
  readonly stopped: boolean;
  push(text: string): string;
  flush(): string;
}

export interface ThinkingSplitter {
  push(text: string): { content: string; reasoning: string };
  flush(): { content: string; reasoning: string };
}

export interface CompletionSinkOptions {
  router: TokenTextRouter;
  stopper: TextStopper;
  thinking: ThinkingSplitter;
  collectToolCalls: boolean;
  flowControl?: (emitted: boolean) => CompletionFlowControl;
}

/** One generated-token sink for every text-serving surface.
 *
 * Chat uses the full router → stop matcher → thinking splitter stack.
 * Text completions use the same sink with a plain router, thinking disabled,
 * and tool-call collection off. `push()` returns both semantic events and the
 * generation callback's control signal: false halts decode; a Promise yields
 * before the next token. */
export class CompletionSink {
  readonly #router: TokenTextRouter;
  readonly #stopper: TextStopper;
  readonly #thinking: ThinkingSplitter;
  readonly #collectToolCalls: boolean;
  readonly #flowControl?: (emitted: boolean) => CompletionFlowControl;
  #content = "";
  #reasoning = "";

  constructor(options: CompletionSinkOptions) {
    this.#router = options.router;
    this.#stopper = options.stopper;
    this.#thinking = options.thinking;
    this.#collectToolCalls = options.collectToolCalls;
    this.#flowControl = options.flowControl;
  }

  get stopped(): boolean {
    return this.#stopper.stopped;
  }

  push(token: number): CompletionPush {
    const events: CompletionEvent[] = [];
    const rawContent = this.#router.push(token);
    this.#emitReasoning(events, this.#router.takeReasoning());
    this.#emitParts(events, this.#thinking.push(this.#stopper.push(rawContent)));
    return {
      events,
      control: this.#stopper.stopped
        ? false
        : this.#flowControl?.(events.length > 0),
    };
  }

  finish(): CompletionResult {
    const events: CompletionEvent[] = [];
    if (!this.#stopper.stopped) {
      const flushed = this.#router.flush();
      this.#emitReasoning(events, this.#router.takeReasoning());
      let tail = this.#stopper.push(flushed);
      if (!this.#stopper.stopped) tail += this.#stopper.flush();
      this.#emitParts(events, this.#thinking.push(tail));
    }
    this.#emitParts(events, this.#thinking.flush());

    const toolCalls = this.#collectToolCalls ? this.#router.toolCalls() : [];
    if (toolCalls.length) events.push({ type: "tool_calls", calls: toolCalls });
    return {
      events,
      content: this.#content,
      reasoning: this.#reasoning,
      toolCalls,
      stopped: this.#stopper.stopped,
    };
  }

  #emitParts(
    events: CompletionEvent[],
    parts: { content: string; reasoning: string },
  ): void {
    this.#emitReasoning(events, parts.reasoning);
    if (parts.content) {
      this.#content += parts.content;
      events.push({ type: "content", text: parts.content });
    }
  }

  #emitReasoning(events: CompletionEvent[], text: string): void {
    if (!text) return;
    this.#reasoning += text;
    events.push({ type: "reasoning", text });
  }
}

export function createTimedFlowControl(
  enabled: boolean,
  intervalMs = 25,
  now: () => number = () => performance.now(),
  yieldTask: () => Promise<void> = () => new Promise<void>((resolve) => setImmediate(resolve)),
): (emitted: boolean) => CompletionFlowControl {
  let lastYield = now();
  return (emitted) => {
    if (!enabled || !emitted) return undefined;
    const current = now();
    if (current - lastYield < intervalMs) return undefined;
    lastYield = current;
    return yieldTask();
  };
}
