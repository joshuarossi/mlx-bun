import type {
  GenerateOptions,
  GenerateStats,
  TokenLogprobs,
} from "@mlx-bun/inference/generation";
import type {
  GenerationPlacement,
  OnToken,
  RequestShape,
  Vision,
} from "../engine/completion";
import {
  type CompletionEvent,
  type CompletionFinishReason,
  type CompletionFlowControl,
  type CompletionResult,
  type CompletionSinkOptions,
  CompletionSink,
  type CompletionToolCall,
} from "./completion-sink";
type Lane = "batched";
type GenerationMechanism = "continuous";
import {
  planRequest,
  type RequestPlan,
  type RequestPlanInput,
  type RequestRejection,
} from "./request-plan";
import type { PromptResponseTrace } from "@mlx-bun/inference/runtime/trace";
import { cleanupFailure } from "@mlx-bun/inference/runtime/resources";

import type { CompletionEngine } from "../engine/completion";
export type { CompletionEngine } from "../engine/completion";

export interface CompletionPreparation {
  requestId: string;
  plan: RequestPlanInput;
  vision?: Vision;
  pipeline: Omit<CompletionSinkOptions, "flowControl">;
  createFlowControl?(placement: CompletionPlacement):
    | CompletionSinkOptions["flowControl"];
  onPlacement?(placement: CompletionPlacement): void;
  idToToken(id: number): string;
}

export interface CompletionPlacement {
  mechanism: GenerationMechanism;
  lane: Lane;
  shape: RequestShape;
}

interface PreparedData extends Omit<CompletionPreparation, "plan"> {
  plan: RequestPlan;
  stream: boolean;
  requestedMaxTokens: number;
}

const preparedBrand: unique symbol = Symbol("PreparedCompletion");

/** A single-use completion declaration. Protocol adapters can create one but
 * cannot inspect or rewrite the resolved execution plan after preparation. */
export interface PreparedCompletion {
  readonly [preparedBrand]: true;
}

const preparedData = new WeakMap<PreparedCompletion, PreparedData>();

export function prepareCompletion(data: CompletionPreparation): PreparedCompletion {
  const planned = planRequest(data.plan);
  if (!planned.ok) {
    planned.dispose();
    throw new CompletionRejected(planned);
  }
  const prepared = Object.freeze({ [preparedBrand]: true }) as PreparedCompletion;
  preparedData.set(prepared, {
    requestId: data.requestId,
    plan: planned,
    stream: data.plan.stream,
    requestedMaxTokens: data.plan.requestedMaxTokens,
    ...(data.vision ? { vision: data.vision } : {}),
    pipeline: data.pipeline,
    ...(data.createFlowControl
      ? { createFlowControl: data.createFlowControl }
      : {}),
    ...(data.onPlacement ? { onPlacement: data.onPlacement } : {}),
    idToToken: data.idToToken,
  });
  return prepared;
}

export interface CompletionControl {
  signal?: AbortSignal;
  trace?: PromptResponseTrace;
  onEvents?(events: readonly CompletionEvent[]):
    | void
    | false
    | Promise<void | false>;
  /** Receives one live, read-only usage view before execution. Retain the
   *  reference to close an errored protocol stream with accumulated usage.
   *  The executor updates it in place, avoiding per-token callback/allocation
   *  work on the decode path. */
  onUsageProgress?(usage: Readonly<CompletionUsage>): void;
}

export interface CompletionUsage {
  promptTokens: number;
  cachedTokens: number;
  completionTokens: number;
  totalTokens: number;
  speculation?: GenerateStats["spec"];
  /** Token fast-forwarding telemetry. */
  fill?: GenerateStats["fill"];
}

export interface CompletionSummary {
  content: string;
  reasoning: string;
  toolCalls: CompletionToolCall[];
  stopped: boolean;
  finishReason: CompletionFinishReason;
  lane: Lane;
  usage: CompletionUsage;
  logprobs: { content: Record<string, unknown>[] } | null;
}

export class CompletionRejected extends Error {
  readonly status: number;
  readonly error: RequestRejection["error"];

  constructor(rejection: RequestRejection) {
    super(rejection.error.message);
    this.name = "CompletionRejected";
    this.status = rejection.status;
    this.error = rejection.error;
  }
}

class LogprobsCollector {
  readonly #tokens: number[] = [];
  readonly #tokenLogprobs: number[] = [];
  readonly #topTokens: { id: number; token: string; logprob: number }[][] = [];

  constructor(
    private readonly wantLogprobs: boolean,
    private readonly topK: number,
    private readonly idToToken: (id: number) => string,
  ) {}

  push(token: number, info?: TokenLogprobs): void {
    this.#tokens.push(token);
    if (this.wantLogprobs) this.#tokenLogprobs.push(info?.logprob ?? NaN);
    if (this.topK > 0) {
      this.#topTokens.push(
        (info?.top ?? []).map((candidate) => ({
          id: candidate.id,
          token: this.idToToken(candidate.id),
          logprob: candidate.logprob,
        })),
      );
    }
  }

  payload(): { content: Record<string, unknown>[] } | null {
    if (this.#topTokens.length) {
      return {
        content: this.#topTokens.map((tokens) =>
          tokens.length ? { ...tokens[0]!, top_logprobs: tokens } : {},
        ),
      };
    }
    if (this.#tokenLogprobs.length) {
      return {
        content: this.#tokens.map((id, index) => ({
          id,
          logprob: this.#tokenLogprobs[index]!,
        })),
      };
    }
    return null;
  }
}

function finishReason(
  result: CompletionResult,
  stats: GenerateStats,
  maxTokens: number,
): CompletionFinishReason {
  if (result.toolCalls.length) return "tool_calls";
  if (result.stopped) return "stop";
  return stats.finishReason ?? (stats.generatedTokens >= maxTokens ? "length" : "stop");
}

function combineControl(
  sinkControl: CompletionFlowControl,
  eventControl: void | false | Promise<void | false>,
): void | false | Promise<void | false> {
  if (sinkControl === false || eventControl === false) return false;
  if (!(sinkControl instanceof Promise) && !(eventControl instanceof Promise))
    return undefined;
  return Promise.all([sinkControl, eventControl]).then((values) =>
    values.includes(false) ? false : undefined,
  );
}

/** Owns one completion attempt from admission through terminal accounting.
 * Model math and scheduling policy remain in the supplied CompletionEngine. */
export class CompletionExecutor {
  readonly #placements = new WeakMap<PreparedCompletion, GenerationPlacement>();
  constructor(private readonly engine: CompletionEngine) {}

  /** Resolve capability gaps before a transport commits streaming headers.
   * A rejected placement releases the prepared request's owned resources. */
  place(prepared: PreparedCompletion): GenerationPlacement {
    const input = preparedData.get(prepared);
    if (!input) throw new Error("prepared completion has already been executed");
    const existing = this.#placements.get(prepared);
    if (existing) return existing;
    try {
      const placement = this.engine.place(input.plan.shape, input.plan.options);
      if (placement.shape !== input.plan.shape)
        throw new Error("generation placement does not belong to this request shape");
      this.#placements.set(prepared, placement);
      return placement;
    } catch (error) {
      preparedData.delete(prepared);
      return cleanupFailure(error, () => input.plan.dispose());
    }
  }

  async execute(
    prepared: PreparedCompletion,
    control: CompletionControl = {},
  ): Promise<CompletionSummary> {
    const input = preparedData.get(prepared);
    if (!input) throw new Error("prepared completion has already been executed");
    preparedData.delete(prepared);

    const planned = input.plan;
    const closeCompletion = control.trace?.begin("completion.total");
    const usageProgress: CompletionUsage | null = control.onUsageProgress
      ? {
          promptTokens: planned.promptIds.length,
          cachedTokens: 0,
          completionTokens: 0,
          totalTokens: planned.promptIds.length,
        }
      : null;

    try {
      if (usageProgress) control.onUsageProgress!(usageProgress);
      const closePlacement = control.trace?.begin("completion.placement");
      const enginePlacement = this.#placements.get(prepared) ?? this.engine.place(planned.shape, planned.options);
      this.#placements.delete(prepared);
      closePlacement?.();
      if (enginePlacement.shape !== planned.shape)
        throw new Error("generation placement does not belong to this request shape");
      const mechanism = enginePlacement.mechanism;
      const lane: Lane = "batched";
      const placement = { mechanism, lane, shape: planned.shape };
      input.onPlacement?.(placement);
      const flowControl = input.createFlowControl?.(placement);
      const sink = new CompletionSink({
        ...input.pipeline,
        ...(flowControl ? { flowControl } : {}),
      });
      const logprobs = planned.captureLogprobs
        ? new LogprobsCollector(
            planned.wantLogprobs,
            planned.topLogprobs,
            input.idToToken,
          )
        : null;
      control.signal?.throwIfAborted();
      planned.transferOwnership();

      // Bounded diagnostic of hidden markers versus visible events. No token
      // readbacks are added: these IDs already crossed the sampling interface.
      let traceTokens = control.trace ? 8 : 0;
      const consumeToken: OnToken = (token, tokenLogprobs) => {
        logprobs?.push(token, tokenLogprobs);
        const route = traceTokens ? { token, index: 8 - traceTokens, events: 0 } : undefined;
        const closeRoute = route ? control.trace!.begin("response.token_route", route) : undefined;
        let pushed: ReturnType<CompletionSink["push"]>;
        try { pushed = sink.push(token); if (route) route.events = pushed.events.length; }
        finally { closeRoute?.(); }
        if (traceTokens) traceTokens = pushed.events.length ? 0 : traceTokens - 1;
        const observed = pushed.events.length
          ? control.onEvents?.(pushed.events)
          : undefined;
        return combineControl(pushed.control, observed);
      };
      const onToken: OnToken = usageProgress
        ? (token, tokenLogprobs) => {
            usageProgress.completionTokens++;
            usageProgress.totalTokens++;
            return consumeToken(token, tokenLogprobs);
          }
        : consumeToken;
      const stats = await this.engine.run(
        planned.promptIds,
        planned.options,
        onToken,
        input.vision,
        planned.shape,
        enginePlacement,
        control.signal,
        control.trace,
      );

      if (input.stream) control.signal?.throwIfAborted();
      const result = sink.finish();
      if (result.events.length) await control.onEvents?.(result.events);

      const resolvedLane = lane;
      if (usageProgress) {
        usageProgress.promptTokens = stats.promptTokens;
        usageProgress.cachedTokens = stats.cachedTokens;
        usageProgress.completionTokens = stats.generatedTokens;
        usageProgress.totalTokens = stats.promptTokens + stats.generatedTokens;
        if (stats.spec) usageProgress.speculation = stats.spec;
        else delete usageProgress.speculation;
        if (stats.fill) usageProgress.fill = stats.fill;
        else delete usageProgress.fill;
      }
      const summary = {
        content: result.content,
        reasoning: result.reasoning,
        toolCalls: result.toolCalls,
        stopped: result.stopped,
        finishReason: finishReason(
          result,
          stats,
          planned.options.maxTokens ?? input.requestedMaxTokens,
        ),
        lane: resolvedLane,
        usage: {
          promptTokens: stats.promptTokens,
          cachedTokens: stats.cachedTokens,
          completionTokens: stats.generatedTokens,
          totalTokens: stats.promptTokens + stats.generatedTokens,
          ...(stats.spec ? { speculation: stats.spec } : {}),
          ...(stats.fill ? { fill: stats.fill } : {}),
        },
        logprobs: logprobs?.payload() ?? null,
      };
      planned.dispose(); // retained preparation reservations outlive the native run
      closeCompletion?.();
      return summary;
    } catch (error) {
      closeCompletion?.();
      cleanupFailure(error, () => planned.dispose());
    }
  }
}
