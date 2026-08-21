import type { GenerateOptions } from "../generate";
import type { RequestShape } from "./generation-gateway";

export interface DisposableResource {
  dispose(): void;
}

export class RequestOwnership {
  #resources = new Set<DisposableResource>();
  #transferred = false;

  own<T extends DisposableResource | null | undefined>(resource: T): T {
    if (resource) this.#resources.add(resource);
    return resource;
  }

  transfer(): void {
    this.#transferred = true;
    this.#resources.clear();
  }

  dispose(): void {
    if (this.#transferred) return;
    for (const resource of this.#resources) resource.dispose();
    this.#resources.clear();
  }
}

export interface RequestPlanInput {
  promptIds: number[];
  options: GenerateOptions & { stopSequences: string[] };
  requestedMaxTokens: number;
  maxSafeContext: number;
  stream: boolean;
  wantLogprobs: boolean;
  topLogprobs: number;
  adapterIds: string[];
  hasVision: boolean;
  userSeed: boolean;
  hasGrammar: boolean;
  hasDraft: boolean;
  ownership: RequestOwnership;
}

export class RequestRejection {
  readonly ok = false;
  readonly status = 400;
  readonly error: {
    message: string;
    type: "memory_admission";
    code: "context_over_budget";
  };

  readonly #ownership: RequestOwnership;

  constructor(message: string, ownership: RequestOwnership) {
    this.error = {
      message,
      type: "memory_admission",
      code: "context_over_budget",
    };
    this.#ownership = ownership;
  }

  dispose(): void {
    this.#ownership.dispose();
  }
}

export class RequestPlan {
  readonly ok = true;
  readonly promptIds: number[];
  readonly options: GenerateOptions & { stopSequences: string[] };
  readonly shape: RequestShape;
  readonly captureLogprobs: boolean;
  readonly wantLogprobs: boolean;
  readonly topLogprobs: number;
  readonly #ownership: RequestOwnership;

  constructor(input: {
    promptIds: number[];
    options: GenerateOptions & { stopSequences: string[] };
    shape: RequestShape;
    captureLogprobs: boolean;
    wantLogprobs: boolean;
    topLogprobs: number;
    ownership: RequestOwnership;
  }) {
    this.promptIds = input.promptIds;
    this.options = input.options;
    this.shape = input.shape;
    this.captureLogprobs = input.captureLogprobs;
    this.wantLogprobs = input.wantLogprobs;
    this.topLogprobs = input.topLogprobs;
    this.#ownership = input.ownership;
  }

  transferOwnership(): void {
    this.#ownership.transfer();
  }

  dispose(): void {
    this.#ownership.dispose();
  }
}

export type PlanRequestResult = RequestPlan | RequestRejection;

/** Compile the model-independent part of request execution into one value.
 * Prompt/media construction happens before this boundary; admission, capture
 * options, adapter selection, and lane shape are derived here once for chat
 * and raw completions. */
export function planRequest(input: RequestPlanInput): PlanRequestResult {
  const available = input.maxSafeContext - input.promptIds.length;
  if (available < 1) {
    return new RequestRejection(
      `prompt is ${input.promptIds.length} tokens but the memory budget caps ` +
        `safe context at ${input.maxSafeContext} — no room to generate; ` +
        "shorten the prompt or raise --memory-budget",
      input.ownership,
    );
  }

  const options = { ...input.options };
  options.maxTokens = Math.min(input.requestedMaxTokens, available);
  if (input.adapterIds.length) options.adapters = [...input.adapterIds];
  const captureLogprobs = !input.stream && (input.wantLogprobs || input.topLogprobs > 0);
  if (captureLogprobs) {
    options.logprobs = input.wantLogprobs;
    options.topLogprobs = input.topLogprobs;
  }

  const shape: RequestShape = {
    hasVision: input.hasVision,
    hasAdapters: !!options.adapters?.length,
    hasRepetitionPenalty: !!options.repetitionPenalty,
    hasLogitsExtras: !!(
      options.minP || options.xtcProbability || options.logitBias ||
      options.presencePenalty || options.frequencyPenalty
    ),
    wantsLogprobs: captureLogprobs,
    userSeed: input.userSeed,
    kvQuant: !!(options.kvConfig?.length || options.kvBits),
    turboQuant: !!options.turboQuant,
    hasGrammar: input.hasGrammar,
    hasDraft: input.hasDraft,
  };

  return new RequestPlan({
    promptIds: input.promptIds,
    options,
    shape,
    captureLogprobs,
    wantLogprobs: input.wantLogprobs,
    topLogprobs: input.topLogprobs,
    ownership: input.ownership,
  });
}
