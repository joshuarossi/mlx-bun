import { speculativePrefixNamespace, captureSpeculativeOptions } from "../generation/speculative/cache-identity";
import { createOrdinaryContinuationRequest } from "./continuation-request";
import type { ContinuationServices } from "./continuation";
import { bindPagedRequestState, pagedPrefixNamespace, type MlxRequestStatePolicy } from "../state/request-policy";
import type { ExecutionContext } from "../contracts/portable/scheduling";
import type { ModelConfig } from "../artifacts/config";
import type { KvScheme } from "../state/kv-scheme";
import type { RuntimeModel } from "../models/factory";
import { DiffusionGemmaModel } from "../models/diffusion-gemma/model";
import { UniversalDenseModel } from "../models/universal/dense";
import { KVCache } from "../state/kv";
import { RotatingKVCache } from "../state/rotating-kv";
import { isBatchableCache, isPlainKvCache, isRotatingPlainCache } from "../state/capabilities";
import { SSMCache } from "../state/ssm";
import { Gemma4Model } from "../models/gemma4/model";
import { Qwen35Model } from "../models/qwen/qwen3_5";
import { MiniCPM5Model } from "../models/minicpm5/model";
import { affineQuantizedKvStart } from "../state/kv-maintenance";
import { runtimeConfig, type RuntimeConfig } from "../runtime/config";
import { disposeResources } from "../runtime/resources";
import { legacyCompiledDecodeAvailable } from "../generation/bindings/autoregressive";
import { MlxBatchExecutionGroup } from "./batch-group";
import { type MlxBatchExecutionGroupOptions, type MlxGroupMethodRequest } from "./batch-types";
import type { DraftProvider } from "../generation/speculative/source";
import { constraintDraftProvider, NgramProvider } from "../generation/speculative/sources/ngram-source";
import { TwoModelProvider } from "../generation/speculative/sources/two-model";
import { targetRowLayoutFactory } from "../state/target-layout";
import { bindSpeculativeGroupRequests } from "./speculative-group";
import { bindFillGroupRequests } from "./fill-group";
import { bindDenoisingGroupRequests } from "./denoising-group";
import { bindLegacyDenoisingModel } from "../generation/bindings/denoising";
import type { GenerateOptions } from "../generation/index";
import type { ExecutionRequirements, ResolvedExecution } from "../contracts/portable/execution";
import { resolveExecution } from "./plan";
import { bindEmbeddingsInput, type MlxPromptInput } from "./prompt-input";
import { bindQwenMediaInput } from "./qwen-prompt-input";
import type { Vision } from "../contracts/mlx/media";

export interface MlxBatchGroup extends Pick<MlxBatchExecutionGroup,
  "activeRows" | "pendingRows" | "projectedKvBytes" | "kvBudgetBytes" | "submit" | "kick" | "close"> {
  runPreparation?<T>(work: () => Promise<T>, signal?: AbortSignal): Promise<T>;
}

/** A model implementation owns capability checks and the execution group.
 * Scheduling never inspects concrete model/cache classes. */
export interface MlxGatewayBinding {
  mediaInput?(input: Vision): MlxPromptInput;
  configureContinuation?(services: ContinuationServices): void;
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
  let continuationServices: ContinuationServices | undefined;
  // Manual softcap attention is qualified for plain-KV requests, including
  // grammar-constrained and adapter requests, for plain-KV fill through the
  // shared fill binding, for shared generation continuation checkpoints, and
  // for two-model and n-gram drafts (below). Encoded attention, other drafts,
  // drafts with adapters or fill, and fill with adapters need their own evidence.
  const plainSoftcap = model instanceof UniversalDenseModel && model.args.attnLogitSoftcap !== null;
  // Denoising rows interleave through their own grouped method. Token-level
  // methods (speculation, grammar proposals, fill) never bind to this graph.
  const denoising = model instanceof DiffusionGemmaModel ? bindDenoisingGroupRequests(bindLegacyDenoisingModel(model)) : undefined;
  const tokenMethods = !plainSoftcap && !denoising;
  // A universal descriptor without softcap, mask array or sliding layer type:
  // makeCache gives every layer a plain KVCache, the layout delayed affine
  // conversion supports. The scheme's per-layer cache guard still decides.
  const universalPlainKv = model instanceof UniversalDenseModel && model.args.attnLogitSoftcap === null &&
    !model.args.maskArray && !model.args.layerTypes?.includes("sliding_attention");
  // Delayed affine KV (plain rows convert once they pass quantizedKvStart) batches row by row for these families.
  const kvBatchCapabilities = { delayedAffine: model instanceof Qwen35Model || model instanceof Gemma4Model ||
    model instanceof MiniCPM5Model || universalPlainKv };
  const delayedAffine = (options: GenerateOptions) => !options.turboQuant &&
    (options.kvBits !== undefined || !!options.kvConfig?.length) && affineQuantizedKvStart(options) > 0;
  // MiniCPM5's and plain universal delayed affine KV are qualified for ordinary
  // continuous decoding only. A draft or fill request over it is refused, as
  // for softcap models; grammar jump falls back to ordinary masking, until those
  // compositions have their own evidence. Its generation checkpoints are
  // qualified for both. Universal adapter requests over it are refused.
  const delayedAffineOrdinaryOnly = (options: GenerateOptions) =>
    (model instanceof MiniCPM5Model || universalPlainKv) && delayedAffine(options);
  const cachesBatchable = () => {
    if (denoising) return true; // denoising rows keep private encoder state
    if (model instanceof UniversalDenseModel)
      return (!model.args.maskArray || model.args.modelType === "gemma2") &&
        !model.args.layerTypes?.includes("sliding_attention");
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
  // Softcap attention is qualified for the existing two-model and n-gram
  // providers' grouped speculation over plain KV (main served both serially);
  // other providers and grammar proposals stay off this graph.
  const softcapDraft = plainSoftcap &&
    (draft?.provider instanceof TwoModelProvider || draft?.provider instanceof NgramProvider);
  const speculative = (tokenMethods || softcapDraft) && draft?.provider.grouped && cachesBatchable() && supportsTargetRows()
    ? bindSpeculativeGroupRequests(model, draft.provider, draft.numDraftTokens) : undefined;
  const grammarProvider = tokenMethods && runtime.flag("MLX_BUN_GRAMMAR_JUMP", false) && cachesBatchable() && supportsTargetRows()
    ? constraintDraftProvider() : undefined;
  const grammarProposals = grammarProvider ? bindSpeculativeGroupRequests(model, grammarProvider,
    Math.max(1, Math.trunc(runtime.number("MLX_BUN_GRAMMAR_DRAFT_TOKENS", 3)))) : undefined;
  const adapterState = "loraState" in model ? model.loraState : undefined;
  const fillRequests = !denoising && supportsTargetRows() ? bindFillGroupRequests(model) : undefined;
  const mediaInput = model instanceof Gemma4Model ? (input: Vision) =>
    bindEmbeddingsInput((ids, caches, start) => start > 0 ? model.forwardHidden(ids, caches)
      : model.forwardEmbeddings(input.embeddings,
      caches, input.imageMask ?? null, ids, input.multimodalMask ?? null))
    : model instanceof Qwen35Model ? (input: Vision) => bindQwenMediaInput(model, input.embeddings, input.mrope!)
    : undefined;
  return {
    mediaInput,
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
    statePolicy: (execution, options, capacity) => {
      // Media token IDs alone do not identify the prepared embeddings.
      // Preserve the existing uncached media policy through the state port.
      if (execution?.method === "autoregressive" && !execution.promptCache)
        return { key: "uncached-prepared-input", create: () => model.makeCache() };
      return execution?.pagedKv ? bindPagedRequestState(model, options, capacity, continuationServices?.promptCache, runtime) : undefined;
    },
    prefixNamespace: (execution, options, adapters) => {
      if (execution?.pagedKv) return pagedPrefixNamespace(options, adapters, runtime.flag("MLX_BUN_PAGED_ATTN", false));
      if (execution?.method !== "speculative") return adapters;
      const namespace = (execution.grammarJump ? grammarProvider : draft?.provider)?.grouped?.checkpointNamespace?.();
      return namespace === undefined ? null : speculativePrefixNamespace(namespace, adapters, captureSpeculativeOptions(options));
    },
    methodRequest: (execution, options) => execution?.method === "denoising" ? denoising?.(options)
      : execution?.method === "speculative"
      ? (execution.grammarJump ? grammarProposals : speculative)?.(
        options.fill && !execution.fill ? { ...options, fill: undefined } : options)
      : execution?.fill ? fillRequests?.(options) : undefined,
    ...(adapterState ? { bindAdapterContext(adapters: string[], key: string): ExecutionContext {
      // Denoising applies each row's adapters around that row's own units, so
      // its rows share one neutral group context whatever their adapters.
      if (denoising) return { key: "", enter: () => () => {} };
      const selected = [...adapters];
      return { key, enter() {
        const previous = adapterState.active;
        adapterState.active = selected;
        return () => { adapterState.active = previous; };
      } };
    } } : {}),
    plan(request, options, scheduling) {
      const ordinaryOnly = delayedAffineOrdinaryOnly(options);
      const sharedMethod = request.hasDraft ? speculative : grammarProposals;
      const provider = request.hasDraft ? draft?.provider : grammarProvider;
      return resolveExecution(request, {
        ...scheduling,
        continuous: scheduling.continuous && !(ordinaryOnly && (request.hasDraft || options.fill ||
          (universalPlainKv && request.hasAdapters))) &&
          !(plainSoftcap && ((request.hasDraft && (!softcapDraft || request.hasAdapters || !!options.fill)) ||
            (options.fill && request.hasAdapters))),
        quantizedBatch: !plainSoftcap && !denoising && scheduling.quantizedBatch,
        sharedCheckpoints: (!ordinaryOnly || model instanceof MiniCPM5Model || universalPlainKv) && !!continuationServices?.checkpointPersistence &&
          !request.hasDraft && !request.hasVision && !request.hasGrammar &&
          !request.wantsLogprobs && !options.fill && !options.pagedKv,
        adapterBatch: !!adapterState, pagedBatch: model instanceof Gemma4Model,
        mediaBatch: !!mediaInput,
        mediaPrefixCache: runtime.flag("MLX_BUN_MEDIA_PREFIX_CACHE", true),
        groupedMethods: denoising ? ["denoising"] : sharedMethod ? ["autoregressive", "speculative"] : ["autoregressive"],
        sharedGrammarProposals: !!grammarProposals,
        sharedFill: !!fillRequests && !!options.fill,
        sharedSpeculativeEcho: !!options.fill?.plan.echo && provider?.grouped?.supportsExternalTokens === true,
        // As main's serial path did, logprobs keep a softcap request ordinary.
        speculativeLogprobs: scheduling.continuous && !!sharedMethod && !softcapDraft,
        sharedSpeculativeAdapters: scheduling.continuous && !!sharedMethod && !!adapterState &&
          provider?.grouped?.supportsTargetAdapters === true,
        turboQuantBatch: !plainSoftcap && !denoising && scheduling.quantizedBatch,
        speculativeTurboQuant: scheduling.continuous && !!sharedMethod && !!options.turboQuant,
        method: model instanceof DiffusionGemmaModel ? "denoising" : "autoregressive",
        compiledDecode: legacyCompiledDecodeAvailable(model),
        // The batch group coordinates per-row grammar for every token method;
        // masks come from the shared sampler, so no model qualifies or declines
        // them. Denoising samples canvases, which an AR token mask cannot apply to.
        grammarBatch: !denoising,
        speculativeKvQuant: !ordinaryOnly && (!(model instanceof Qwen35Model) || runtime.flag("MLX_BUN_QWEN_SPEC_KV4", true)) && (
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
      if (denoising || (plainSoftcap && scheme.kind !== "bf16")) return false;
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
