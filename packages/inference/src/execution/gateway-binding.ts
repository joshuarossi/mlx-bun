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
import { affineQuantizedKvStart, createKvMaintenance } from "../state/kv-maintenance";
import type { Cache } from "../contracts/mlx/cache";
import { runtimeConfig, type RuntimeConfig } from "../runtime/config";
import { disposeResources } from "../runtime/resources";
import { legacyCompiledDecodeAvailable } from "../generation/bindings/autoregressive";
import { MlxBatchExecutionGroup } from "./batch-group";
import { type MlxBatchExecutionGroupOptions, type MlxGroupMethodRequest } from "./batch-types";
import type { DraftProvider } from "../generation/speculative/source";
import { constraintDraftProvider } from "../generation/speculative/sources/ngram-source";
import { targetRowLayoutFactory } from "../state/target-layout";
import { bindSpeculativeGroupRequests } from "./speculative-group";
import { bindGrammarGroupRequests } from "./grammar-group";
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

/** Which operations the graph's own caches provide: batch rows (plain and
 * rotating KV, batchable layouts, SSM under the binding's policy), target
 * transaction rows, and per-layer quantized conversion. */
function probeStorage(model: RuntimeModel, ssm: boolean) {
  const caches = model.makeCache();
  try {
    return Object.freeze({
      batchable: caches.every(cache => cache instanceof KVCache || cache instanceof RotatingKVCache ||
        isBatchableCache(cache) || (ssm && cache instanceof SSMCache)),
      targetRows: caches.every(cache => targetRowLayoutFactory(cache) !== undefined),
      convertible: Object.freeze(caches.map(cache => isPlainKvCache(cache) || isRotatingPlainCache(cache))),
    });
  } finally { disposeResources(caches); }
}

/** Whether this graph's storage, once `scheme`'s own maintenance binds it,
 * certifies dense KV reads in every layer: the storage's capability, answered
 * with that maintenance. Probed over fresh caches that hold no buffers, when a
 * binding or group is composed (never per request, never remembered: the
 * scheme is read as given each time); every probe cache is released. */
function certifiesDenseKvReads(model: RuntimeModel, scheme: KvScheme): boolean {
  const caches = model.makeCache() as Cache[];
  try {
    createKvMaintenance(scheme.generationOptions).preparePrefill?.(caches);
    return caches.every(cache => cache.denseKvReads !== undefined);
  } finally { disposeResources(caches); }
}

export function bindMlxGateway(model: RuntimeModel, draft?: { provider: DraftProvider; numDraftTokens: number }): MlxGatewayBinding {
  const runtime = runtimeConfig();
  let continuationServices: ContinuationServices | undefined;
  // Manual softcap attention is qualified for plain-KV requests, including
  // grammar-constrained and adapter requests, for plain-KV fill through the
  // shared fill binding, for shared generation continuation checkpoints, and
  // for grouped drafts (below); plain-KV fill runs inside the request's adapter
  // context like any other row. Configured drafts ignore fill, as main did;
  // adapter-bearing drafted requests also ignore the draft and decode ordinarily.
  // Encoded storage is admitted only where it certifies dense reads (kvBatchable).
  // From the graph as bound (its attention layers), not the mutable descriptor.
  const plainSoftcap = model instanceof UniversalDenseModel && model.encodedKvAttention === false;
  // Denoising rows interleave through their own grouped method. Token-level
  // methods (speculation, grammar proposals, fill) never bind to this graph.
  const denoising = model instanceof DiffusionGemmaModel ? bindDenoisingGroupRequests(bindLegacyDenoisingModel(model)) : undefined;
  const tokenMethods = !plainSoftcap && !denoising;
  // The graph's state operations, probed once when the binding is built and
  // released on every path. Only these facts are retained; planning never
  // allocates or touches a probe. Denoising rows keep private encoder state.
  const storage = denoising ? null : probeStorage(model, runtime.value("MLX_BUN_BATCH_SSM") !== "0");
  // A graph whose bound attention reads encoded KV views (its own construction
  // fact) and whose every cache layer, plain or rotating, converts row by row.
  // The scheme's per-layer cache guard still decides.
  const encodedKvRows = (model as { encodedKvAttention?: boolean }).encodedKvAttention === true &&
    !!storage?.convertible.length && storage.convertible.every(Boolean);
  // Delayed affine KV (rows convert once they pass quantizedKvStart) batches row by row.
  const delayedAffineRows = model instanceof Qwen35Model || model instanceof Gemma4Model ||
    model instanceof MiniCPM5Model || encodedKvRows;
  // A graph reading dense KV takes a scheme whose own maintenance leaves every
  // layer's storage certified for dense reads: affine rows until their
  // transition (rows the storage no longer certifies are rejected before any
  // shared append, execution/batch-group.ts), TurboQuant rows throughout, as
  // they decode on read. Answered for the scheme at hand when composed.
  const kvBatchCapabilities = (scheme: KvScheme | undefined) => {
    const dense = plainSoftcap && !!scheme && scheme.kind !== "bf16" ? certifiesDenseKvReads(model, scheme) : undefined;
    return { certified: dense !== false, capabilities: { delayedAffine: delayedAffineRows || dense === true } };
  };
  const delayedAffine = (options: GenerateOptions) => !options.turboQuant &&
    (options.kvBits !== undefined || !!options.kvConfig?.length) && affineQuantizedKvStart(options) > 0;
  // MiniCPM5's and encoded-KV graphs' delayed affine KV are qualified for ordinary
  // continuous decoding only. Adapter requests ignore a configured draft and
  // fill, as main did; actual delayed speculation and fill remain refused.
  // Grammar jump falls back to ordinary masking. Generation checkpoints are
  // qualified for both. Their adapters use the same row context.
  const affineKv = (options: GenerateOptions) => !options.turboQuant && (options.kvBits !== undefined || !!options.kvConfig?.length);
  const delayedAffineOrdinaryOnly = (options: GenerateOptions) =>
    ((model instanceof MiniCPM5Model || encodedKvRows) && delayedAffine(options)) || (plainSoftcap && affineKv(options));
  const cachesBatchable = () => storage?.batchable ?? true;
  const supportsTargetRows = () => storage?.targetRows ?? false;
  // Grouped speculation needs batchable caches, row layouts for verification and
  // rollback, and a forward that captures any hidden layers the provider taps.
  // Any provider meeting those operations binds; one that cannot bind is refused
  // by placement rather than served ordinarily. Grammar proposals stay off softcap.
  const speculative = !denoising && draft?.provider.grouped && cachesBatchable() && supportsTargetRows()
    ? bindSpeculativeGroupRequests(model, draft.provider, draft.numDraftTokens) : undefined;
  const grammarSpans = plainSoftcap ? bindGrammarGroupRequests(model) : undefined;
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
      // A checkpointed plan never pages: as main's serial executor did, a media or
      // adapter request that bypassed the server-wide paging flag runs without it.
      const { pagedKv: _bypassed, ...scoped } = options;
      return createOrdinaryContinuationRequest({ options: scoped, prompt, onToken, execution,
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
      : execution?.grammarJump ? grammarSpans?.(options)
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
      // TurboQuant on a graph reading dense KV: main served these serially,
      // with speculation off (a configured draft is ignored).
      const decodedDense = plainSoftcap && !!options.turboQuant;
      // Main placed this request ordinarily: no draft provider is opened, so
      // the fallback and its ordinary checkpoints do not depend on provider kind.
      // Softcap adapter requests never speculate (below), whatever their KV.
      // Main bound no grouped speculation on a softcap graph, so a drafted
      // request over encoded KV there, affine or TurboQuant, decoded ordinarily.
      const ignoredDraft = request.hasDraft &&
        (((ordinaryOnly || plainSoftcap) && request.hasAdapters) || decodedDense || (plainSoftcap && affineKv(options)));
      const sharedMethod = request.hasDraft ? speculative : grammarProposals;
      const provider = request.hasDraft ? draft?.provider : grammarProvider;
      return resolveExecution(request, {
        ...scheduling,
        continuous: scheduling.continuous && !(ordinaryOnly && !ignoredDraft && request.hasDraft),
        // The scheme's dense-read certification is part of the scheduling fact (kvBatchable).
        quantizedBatch: !denoising && scheduling.quantizedBatch,
        // Paging is decided on the resolved plan, which never checkpoints a paged
        // row; an adapter row that bypasses paging checkpoints as main's serial path did.
        sharedCheckpoints: (!ordinaryOnly || model instanceof MiniCPM5Model || encodedKvRows || plainSoftcap) && !!continuationServices?.checkpointPersistence &&
          (!request.hasDraft || ignoredDraft) && !request.hasVision && !request.hasGrammar &&
          !request.wantsLogprobs && !options.fill,
        adapterBatch: !!adapterState, pagedBatch: model instanceof Gemma4Model,
        mediaBatch: !!mediaInput,
        mediaPrefixCache: runtime.flag("MLX_BUN_MEDIA_PREFIX_CACHE", true),
        groupedMethods: denoising ? ["denoising"] : sharedMethod ? ["autoregressive", "speculative"] : ["autoregressive"],
        sharedGrammarProposals: !!grammarProposals,
        // Committed spans append through the graph's dense reads after one
        // maintenance call, as main's serial jump did. TurboQuant storage decodes
        // on read, so its spans run once the gateway has certified the scheme's
        // dense reads (kvBatchable); affine storage stops reading dense at its
        // transition and keeps ordinary masking.
        sharedGrammarJump: !!grammarSpans && !request.hasVision && !request.kvQuant &&
          (!request.turboQuant || scheduling.quantizedBatch) && !options.pagedKv,
        // Main filled only through a committed append declaring the scheme's
        // formats (shouldUseFill); this graph declares none for TurboQuant, so
        // supplied fill decodes ordinarily there, as it did in main.
        sharedFill: !ordinaryOnly && !decodedDense && !!fillRequests && !!options.fill,
        // Main's softcap serial verifier ignored fill, including echo proposals.
        sharedSpeculativeEcho: !plainSoftcap && !!options.fill?.plan.echo && provider?.grouped?.supportsExternalTokens === true,
        // As main's serial path did, logprobs keep a softcap request ordinary.
        speculativeLogprobs: scheduling.continuous && !!sharedMethod && !plainSoftcap,
        // Main served softcap adapters ordinarily even when a draft was configured.
        sharedSpeculativeAdapters: !plainSoftcap && scheduling.continuous && !!sharedMethod && !!adapterState &&
          provider?.grouped?.supportsTargetAdapters === true,
        turboQuantBatch: !denoising && scheduling.quantizedBatch,
        speculativeTurboQuant: !plainSoftcap && scheduling.continuous && !!sharedMethod && !!options.turboQuant,
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
      if (!storage) return false;
      const { certified, capabilities } = kvBatchCapabilities(scheme);
      return certified && scheme.batchable(model.config, layer => storage.convertible[layer] === true,
        storage.convertible.length, capabilities);
    },
    createBatchGroup: (options) => new MlxBatchExecutionGroup(model, { ...options,
      kvBatchCapabilities: kvBatchCapabilities(options.kvScheme).capabilities,
      ...(plainSoftcap ? { denseKvReads: true } : {}) }),
  };
}
