import { speculativePrefixNamespace, captureSpeculativeOptions } from "../../spec/cache-identity";
import { createOrdinaryContinuationRequest } from "./continuation-request";
import type { MlxSerialServices } from "./serial-executor";
import { bindPagedRequestState, pagedPrefixNamespace, type MlxRequestStatePolicy } from "./request-state-policy";
import type { ExecutionContext } from "../../contracts/scheduling";
import type { ModelConfig } from "../../config";
import type { KvScheme } from "../../kv-scheme";
import type { RuntimeModel } from "../../model/factory";
import { DiffusionGemmaModel } from "../../model/diffusion-gemma";
import { UniversalDenseModel } from "../../model/universal/dense";
import { KVCache, RotatingKVCache, isBatchableCache, isPlainKvCache, isRotatingPlainCache } from "../../model/gemma4-base";
import { SSMCache } from "../../model/qwen3-delta";
import { Gemma4Model } from "../../model/gemma4";
import { Qwen35Model } from "../../model/qwen3_5";
import { runtimeConfig, type RuntimeConfig } from "../../runtime-config";
import { disposeResources } from "../../engine/resources";
import { legacyCompiledDecodeAvailable } from "./autoregressive";
import { MlxBatchExecutionGroup, type MlxBatchExecutionGroupOptions, type MlxGroupMethodRequest } from "./batch-group";
import type { DraftProvider } from "../../spec/source";
import { constraintDraftProvider } from "../../spec/ngram-source";
import { targetRowLayoutFactory } from "./target-layout-capability";
import { bindSpeculativeGroupRequests } from "./speculative-group";
import type { GenerateOptions } from "../../generate";
import type { ExecutionRequirements, ResolvedExecution } from "../../contracts/execution";
import { resolveExecution } from "../../engine/execution-plan";

export interface MlxBatchGroup extends Pick<MlxBatchExecutionGroup,
  "activeRows" | "pendingRows" | "projectedKvBytes" | "kvBudgetBytes" | "submit" | "kick" | "close"> {}

/** A model implementation owns capability checks and the execution group.
 * Scheduling never inspects concrete model/cache classes. */
export interface MlxGatewayBinding {
  configureContinuation?(services: MlxSerialServices): void;
  continuationRequest?(execution: ResolvedExecution | undefined, options: GenerateOptions, prompt: number[],
    onToken: Parameters<typeof createOrdinaryContinuationRequest>[0]["onToken"]): ReturnType<typeof createOrdinaryContinuationRequest> | undefined;
  readonly config: ModelConfig;
  readonly runtime: RuntimeConfig;
  plan(request: ExecutionRequirements, options: GenerateOptions,
    scheduling: { continuous: boolean; quantizedBatch: boolean; checkpoints: boolean }): ResolvedExecution;
  bindAdapterContext?(adapters: string[], key: string): ExecutionContext;
  cachesBatchable(): boolean;
  kvBatchable(scheme: KvScheme): boolean;
  statePolicy?(execution: ResolvedExecution | undefined, options: GenerateOptions, capacityTokens: number): MlxRequestStatePolicy | undefined;
  prefixNamespace?(execution: ResolvedExecution | undefined, options: GenerateOptions, adapters: string): string | null;
  methodRequest?(execution: ResolvedExecution | undefined, options: GenerateOptions): MlxGroupMethodRequest | undefined;
  createBatchGroup(options: MlxBatchExecutionGroupOptions): MlxBatchGroup;
}

export function bindMlxGateway(model: RuntimeModel, draft?: { provider: DraftProvider; numDraftTokens: number }): MlxGatewayBinding {
  const runtime = runtimeConfig();
  let continuationServices: MlxSerialServices | undefined;
  const kvBatchCapabilities = { delayedAffine: model instanceof Qwen35Model || model instanceof Gemma4Model };
  const cachesBatchable = () => {
    if (model instanceof UniversalDenseModel)
      return !model.args.maskArray && !model.args.layerTypes?.includes("sliding_attention");
    const caches = model.makeCache();
    try {
      const ssm = runtime.value("MLX_BUN_BATCH_SSM") !== "0";
      return caches.every((cache) => cache instanceof KVCache || cache instanceof RotatingKVCache ||
        isBatchableCache(cache) || (ssm && cache instanceof SSMCache));
    } finally { disposeResources(caches); }
  };
  const supportsTargetRows = () => {
    const caches = model.makeCache();
    try { return caches.every(cache => targetRowLayoutFactory(cache) !== undefined); }
    finally { disposeResources(caches); }
  };
  const speculative = draft?.provider.grouped && cachesBatchable() && supportsTargetRows()
    ? bindSpeculativeGroupRequests(model, draft.provider, draft.numDraftTokens) : undefined;
  const grammarProvider = runtime.flag("MLX_BUN_GRAMMAR_JUMP", false) && cachesBatchable() && supportsTargetRows()
    ? constraintDraftProvider() : undefined;
  const grammarProposals = grammarProvider ? bindSpeculativeGroupRequests(model, grammarProvider,
    Math.max(1, Math.trunc(runtime.number("MLX_BUN_GRAMMAR_DRAFT_TOKENS", 3)))) : undefined;
  const adapterState = "loraState" in model ? model.loraState : undefined;
  return {
    config: model.config, runtime,
    configureContinuation: services => { continuationServices = services; },
    continuationRequest(execution, options, prompt, onToken) {
      if (!execution?.checkpoint || execution.mechanism !== "continuous") return undefined;
      const services = continuationServices;
      if (!services?.checkpoints || !services.checkpointPersistence)
        throw new Error("qualified continuation requires bound persistence services");
      return createOrdinaryContinuationRequest({ options, prompt, onToken, execution,
        store: services.checkpoints, persistence: services.checkpointPersistence,
        restore: entry => services.checkpoints!.restore(entry, model),
        interval: services.checkpointEveryTokens!, identity: services.identity });
    },
    statePolicy: (execution, options, capacity) => execution?.pagedKv ? bindPagedRequestState(model, options, capacity, continuationServices?.promptCache) : undefined,
    prefixNamespace: (execution, options, adapters) => {
      if (execution?.pagedKv) return pagedPrefixNamespace(options, adapters);
      if (execution?.method !== "speculative") return adapters;
      const namespace = (execution.grammarJump ? grammarProvider : draft?.provider)?.grouped?.checkpointNamespace?.();
      return namespace === undefined ? null : speculativePrefixNamespace(namespace, adapters, captureSpeculativeOptions(options));
    },
    methodRequest: (execution, options) => execution?.method === "speculative"
      ? (execution.grammarJump ? grammarProposals : speculative)?.(options) : undefined,
    ...(adapterState ? { bindAdapterContext(adapters: string[], key: string): ExecutionContext {
      const selected = [...adapters];
      return { key, enter() {
        const previous = adapterState.active;
        adapterState.active = selected;
        return () => { adapterState.active = previous; };
      } };
    } } : {}),
    plan(request, options, scheduling) {
      const sharedMethod = request.hasDraft ? speculative : grammarProposals;
      const provider = request.hasDraft ? draft?.provider : grammarProvider;
      return resolveExecution(request, {
        ...scheduling,
        sharedCheckpoints: !!continuationServices?.checkpointPersistence &&
          !request.hasDraft && !request.hasVision && !request.hasGrammar &&
          !request.wantsLogprobs && !options.fill && !options.pagedKv,
        adapterBatch: !!adapterState, pagedBatch: model instanceof Gemma4Model,
        groupedMethods: sharedMethod ? ["autoregressive", "speculative"] : ["autoregressive"],
        sharedGrammarProposals: !!grammarProposals,
        speculativeLogprobs: scheduling.continuous && !!sharedMethod,
        sharedSpeculativeAdapters: scheduling.continuous && !!sharedMethod && !!adapterState &&
          provider?.grouped?.supportsTargetAdapters === true,
        turboQuantBatch: scheduling.quantizedBatch,
        speculativeTurboQuant: scheduling.continuous && !!sharedMethod && !!options.turboQuant,
        method: model instanceof DiffusionGemmaModel ? "denoising" : "autoregressive",
        compiledDecode: legacyCompiledDecodeAvailable(model),
        grammarBatch: runtime.value("MLX_BUN_GRAMMAR_BATCH") !== "0",
        speculativeKvQuant: (!(model instanceof Qwen35Model) || runtime.flag("MLX_BUN_QWEN_SPEC_KV4", true)) && (
          (scheduling.continuous && !!sharedMethod && (options.kvBits === 4 || options.kvBits === 8 || !!options.kvConfig?.length)) ||
          (!options.kvConfig?.length && model instanceof Qwen35Model &&
            (options.kvBits === 4 || (scheduling.continuous && !!sharedMethod && options.kvBits === 8)) &&
            (options.quantizedKvStart === 0 || (scheduling.continuous && !!sharedMethod)))
        ),
      }, {
        pagedKv: !!options.pagedKv, fill: !!options.fill,
        compiledDecode: runtime.flag("MLX_BUN_COMPILED_DECODE", true),
        grammarJump: runtime.flag("MLX_BUN_GRAMMAR_JUMP", false),
      });
    },
    cachesBatchable,
    kvBatchable(scheme) {
      const caches = model.makeCache();
      try {
        return scheme.batchable(model.config,
          (layer) => isPlainKvCache(caches[layer]) || isRotatingPlainCache(caches[layer]), caches.length,
          kvBatchCapabilities);
      } finally { disposeResources(caches); }
    },
    createBatchGroup: (options) => new MlxBatchExecutionGroup(model, { ...options, kvBatchCapabilities }),
  };
}
