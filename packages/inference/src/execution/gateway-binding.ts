import { speculativePrefixNamespace, captureSpeculativeOptions } from "../generation/speculative/cache-identity";
import { createOrdinaryContinuationRequest } from "./continuation-request";
import type { ContinuationServices } from "./continuation";
import { bindPagedRequestState, pagedPrefixNamespace, type MlxRequestStatePolicy } from "../state/request-policy";
import type { ExecutionContext } from "../contracts/portable/scheduling";
import type { ModelConfig } from "../artifacts/config";
import type { KvScheme } from "../state/kv-scheme";
import type { MlxTokenGraph } from "../models/graph";
import { declaredGraph } from "../models/capabilities";
import { isPlainKvCache, isRecurrentCache, isRotatingPlainCache } from "../state/capabilities";
import { bindRequiredDenseKvLayers } from "../state/dense-kv-reads";
import { ownedCacheLayoutFactory } from "../state/layout";
import { affineQuantizedKvStart, createKvMaintenance } from "../state/kv-maintenance";
import type { Cache } from "../contracts/mlx/cache";
import { runtimeConfig, type RuntimeConfig } from "../runtime/config";
import { disposeResources } from "../runtime/resources";
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
import type { GraphCapabilities } from "../contracts/portable/graph";
import { resolveExecution } from "./plan";
import type { MlxPromptInput, Vision } from "../contracts/mlx/media";

export interface MlxBatchGroup extends Pick<MlxBatchExecutionGroup,
  "activeRows" | "pendingRows" | "projectedKvBytes" | "kvBudgetBytes" | "submit" | "kick" | "close"> {
  runPreparation?<T>(work: () => Promise<T>, signal?: AbortSignal): Promise<T>;
}

/** Planning consumes the graph's declared capabilities (`declaredGraph`), the
 * request, and dynamic state; it never inspects a model's class, type, or name. */
export interface MlxGatewayBinding {
  mediaInput?(input: Vision): MlxPromptInput;
  configureContinuation?(services: ContinuationServices): void;
  continuationRequest?(execution: ResolvedExecution | undefined, options: GenerateOptions, prompt: number[],
    onToken: Parameters<typeof createOrdinaryContinuationRequest>[0]["onToken"]): ReturnType<typeof createOrdinaryContinuationRequest> | undefined;
  readonly config: ModelConfig;
  readonly runtime: RuntimeConfig;
  /** What the bound graph declares, as resolved when it was bound. */
  readonly capabilities: GraphCapabilities;
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

/** Which operations the graph's own caches provide: a batch row layout for
 * every layer (recurrent state only under the binding's policy), target
 * transaction rows and per-layer quantized conversion; and the graph's declared
 * dense-read layers, bound against those caches. */
function probeStorage(model: MlxTokenGraph, ssm: boolean) {
  const caches = model.makeCache();
  try {
    return Object.freeze({
      batchable: caches.every(cache => ownedCacheLayoutFactory(cache) !== undefined && (ssm || !isRecurrentCache(cache))),
      targetRows: caches.every(cache => targetRowLayoutFactory(cache) !== undefined),
      convertible: Object.freeze(caches.map(cache => isPlainKvCache(cache) || isRotatingPlainCache(cache))),
      requiredDenseKvLayers: bindRequiredDenseKvLayers(model.requiredDenseKvLayers, caches),
    });
  } finally { disposeResources(caches); }
}

/** Whether this graph's storage, once `scheme`'s own maintenance binds it,
 * certifies dense KV reads in every layer: the storage's capability, answered
 * with that maintenance. Probed over fresh caches that hold no buffers, when a
 * binding or group is composed (never per request, never remembered: the
 * scheme is read as given each time); every probe cache is released. */
function certifiesDenseKvReads(model: MlxTokenGraph, scheme: KvScheme): boolean {
  const caches = model.makeCache() as Cache[];
  try {
    createKvMaintenance(scheme.generationOptions).preparePrefill?.(caches);
    return caches.every(cache => cache.denseKvReads !== undefined);
  } finally { disposeResources(caches); }
}

/** `adaptiveDepth`: each round drafts up to `numDraftTokens`, chosen from the
 *  decayed acceptance rate and the graph's measured `verifyRoundCosts` (the
 *  graph must declare them); otherwise every round drafts `numDraftTokens`. */
export function bindMlxGateway(model: MlxTokenGraph,
  draft?: { provider: DraftProvider; numDraftTokens: number; adaptiveDepth?: boolean }): MlxGatewayBinding {
  const runtime = runtimeConfig();
  let continuationServices: ContinuationServices | undefined;
  // The declarations are resolved once, when the graph is bound; planning reads
  // only these and the request.
  const graph = declaredGraph(model);
  const caps = graph.graphCapabilities;
  const verification = caps.speculation;
  // A graph whose attention reads plain K/V (softcapped) is qualified for
  // plain-KV requests, including grammar-constrained and adapter requests, for
  // plain-KV fill through the shared fill binding, for shared generation
  // continuation checkpoints, and for grouped drafts (below); plain-KV fill runs
  // inside the request's adapter context like any other row. Configured drafts
  // ignore fill; adapter-bearing drafted requests also ignore the draft and
  // decode ordinarily. Encoded storage is admitted only where it certifies
  // dense reads (kvBatchable).
  const denseReads = caps.kv.denseReads;
  // Denoising rows interleave through their own grouped method. Token-level
  // methods (speculation, grammar proposals, fill) never bind to this graph.
  const denoising = caps.method === "denoising" ? bindDenoisingGroupRequests(bindLegacyDenoisingModel(model)) : undefined;
  // The graph's state operations, probed once when the binding is built and
  // released on every path. Only these facts are retained; planning never
  // allocates or touches a probe. Denoising rows keep private encoder state.
  const storage = denoising ? null : probeStorage(model, runtime.value("MLX_BUN_BATCH_SSM") !== "0");
  // Delayed affine KV: `all` graphs convert rows in their own caches; `ordinary`
  // graphs convert row by row where every cache layer, plain or rotating, does.
  // The scheme's per-layer cache guard still decides.
  const rowsConvert = !!storage?.convertible.length && storage.convertible.every(Boolean);
  const ordinaryAffineRows = caps.kv.delayedAffine === "ordinary" && rowsConvert;
  const delayedAffineRows = caps.kv.delayedAffine === "all" || ordinaryAffineRows;
  // A graph reading dense KV takes a scheme whose own maintenance leaves every
  // layer's storage certified for dense reads: affine rows until their
  // transition (rows the storage no longer certifies are rejected before any
  // shared append, execution/batch-group.ts), TurboQuant rows throughout, as
  // they decode on read. Answered for the scheme at hand when composed.
  const kvBatchCapabilities = (scheme: KvScheme | undefined) => {
    const dense = denseReads && !!scheme && scheme.kind !== "bf16" ? certifiesDenseKvReads(model, scheme) : undefined;
    return { certified: dense !== false, capabilities: { delayedAffine: delayedAffineRows || dense === true } };
  };
  const delayedAffine = (options: GenerateOptions) => !options.turboQuant &&
    (options.kvBits !== undefined || !!options.kvConfig?.length) && affineQuantizedKvStart(options) > 0;
  // Ordinary-only delayed affine KV is qualified for ordinary continuous
  // decoding only. Adapter requests ignore a configured draft and fill;
  // actual delayed speculation and fill remain refused. Their direct grammar
  // jump commits spans. Generation checkpoints are qualified for both. Their
  // adapters use the same row context.
  const affineKv = (options: GenerateOptions) => !options.turboQuant && (options.kvBits !== undefined || !!options.kvConfig?.length);
  const delayedAffineOrdinaryOnly = (options: GenerateOptions) =>
    (ordinaryAffineRows && delayedAffine(options)) || (denseReads && affineKv(options));
  const cachesBatchable = () => storage?.batchable ?? true;
  const supportsTargetRows = () => storage?.targetRows ?? false;
  // Grouped speculation needs batchable caches, row layouts for verification and
  // rollback, and a forward that captures any hidden layers the provider taps.
  // Any provider meeting those operations binds; one that cannot bind is refused
  // by placement rather than served ordinarily.
  const speculative = !denoising && draft?.provider.grouped && cachesBatchable() && supportsTargetRows()
    ? bindSpeculativeGroupRequests(model, draft.provider, draft.numDraftTokens, draft.adaptiveDepth ?? false) : undefined;
  // Committed spans serve the direct grammar jump, held to the graph's declared
  // dense-read layers, as its ordinary rows are: every layer of a graph reading
  // dense KV; none of a graph whose delayed affine rows are ordinary-only, as it
  // attends the encoded storage it holds.
  const grammarSpans = (denseReads || ordinaryAffineRows) && storage
    ? bindGrammarGroupRequests(model, storage.requiredDenseKvLayers, storage.convertible.length) : undefined;
  const grammarProvider = caps.method === "autoregressive" && verification.grammarProposals &&
    runtime.flag("MLX_BUN_GRAMMAR_JUMP", false) && cachesBatchable() && supportsTargetRows()
    ? constraintDraftProvider() : undefined;
  const grammarProposals = grammarProvider ? bindSpeculativeGroupRequests(model, grammarProvider,
    Math.max(1, Math.trunc(runtime.number("MLX_BUN_GRAMMAR_DRAFT_TOKENS", 3)))) : undefined;
  const adapterState = caps.adapters.batched ? model.loraState : undefined;
  const fillRequests = !denoising && supportsTargetRows() ? bindFillGroupRequests(model) : undefined;
  const mediaInput = caps.media && caps.media.input !== "pixels"
    ? (input: Vision): MlxPromptInput => graph.bindMediaInput!(input) : undefined;
  return {
    mediaInput,
    config: model.config, runtime, capabilities: caps,
    configureContinuation: services => { continuationServices = services; },
    continuationRequest(execution, options, prompt, onToken) {
      if (!execution?.checkpoint || execution.mechanism !== "continuous") return undefined;
      const services = continuationServices;
      if (!services?.checkpoints || !services.checkpointPersistence)
        throw new Error("qualified continuation requires bound persistence services");
      // A checkpointed plan never pages: a media or adapter request that bypassed
      // the server-wide paging flag runs without it.
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
      // TurboQuant on a graph reading dense KV decodes ordinarily; a configured
      // draft is ignored.
      const decodedDense = denseReads && !!options.turboQuant;
      const sharedMethod = request.hasDraft ? speculative : grammarProposals;
      const provider = request.hasDraft ? draft?.provider : grammarProvider;
      // A graph whose verifier does not qualify adapters serves adapter requests
      // ordinarily even when a draft is configured.
      const sharedSpeculativeAdapters = verification.adapters && scheduling.continuous && !!sharedMethod &&
        caps.adapters.batched && provider?.grouped?.supportsTargetAdapters === true;
      // A drafted request placed ordinarily opens no draft provider and keeps the
      // ordinary checkpoint rules: an adapter request the provider cannot serve
      // (its verifier does not qualify adapters) or whose delayed affine KV keeps
      // it ordinary, and a drafted request over encoded KV on a graph reading
      // dense KV.
      const ignoredDraft = request.hasDraft &&
        ((request.hasAdapters && (ordinaryOnly || !sharedSpeculativeAdapters)) || decodedDense ||
          (denseReads && affineKv(options)));
      return resolveExecution(request, {
        ...scheduling,
        continuous: scheduling.continuous && !(ordinaryOnly && !ignoredDraft && request.hasDraft),
        // The scheme's dense-read certification is part of the scheduling fact (kvBatchable).
        quantizedBatch: !denoising && scheduling.quantizedBatch,
        // Paging is decided on the resolved plan, which never checkpoints a paged
        // row; an adapter row that bypasses paging still checkpoints.
        sharedCheckpoints: (!ordinaryOnly || ordinaryAffineRows || denseReads) && !!continuationServices?.checkpointPersistence &&
          (!request.hasDraft || ignoredDraft) && !request.hasVision && !request.hasGrammar &&
          !request.wantsLogprobs && !options.fill,
        adapterBatch: caps.adapters.batched, pagedBatch: caps.pagedAttention,
        mediaBatch: !!mediaInput,
        mediaPrefixCache: runtime.flag("MLX_BUN_MEDIA_PREFIX_CACHE", true),
        groupedMethods: denoising ? ["denoising"] : sharedMethod ? ["autoregressive", "speculative"] : ["autoregressive"],
        sharedGrammarProposals: !!grammarProposals,
        // Committed spans append after one maintenance call, once the gateway
        // has certified the scheme (kvBatchable). On a graph reading dense KV,
        // TurboQuant storage decodes on read throughout; a row whose affine
        // storage would no longer read plain at its next append is refused before
        // that append. Elsewhere spans serve only ordinary-only delayed affine
        // requests; other grammar requests keep verified proposals.
        sharedGrammarJump: !!grammarSpans && (denseReads || ordinaryOnly) && !request.hasVision &&
          (!(request.kvQuant || request.turboQuant) || scheduling.quantizedBatch) && !options.pagedKv,
        // Fill needs a committed append declaring the scheme's formats; a graph
        // reading dense KV declares none for TurboQuant, so supplied fill decodes
        // ordinarily there.
        sharedFill: !ordinaryOnly && !decodedDense && !!fillRequests && !!options.fill,
        sharedSpeculativeEcho: verification.externalTokens && !!options.fill?.plan.echo &&
          provider?.grouped?.supportsExternalTokens === true,
        speculativeLogprobs: scheduling.continuous && !!sharedMethod && verification.logprobs,
        sharedSpeculativeAdapters,
        turboQuantBatch: !denoising && scheduling.quantizedBatch,
        speculativeTurboQuant: verification.turboKv && scheduling.continuous && !!sharedMethod && !!options.turboQuant,
        method: caps.method,
        compiledDecode: caps.compiledDecode,
        // The batch group coordinates per-row grammar for every token method;
        // masks come from the shared sampler, so no graph qualifies or declines
        // them. Denoising samples canvases, which an AR token mask cannot apply to.
        grammarBatch: !denoising,
        speculativeKvQuant: !ordinaryOnly && verification.affineKv && (
          (scheduling.continuous && !!sharedMethod && (options.kvBits === 4 || options.kvBits === 8 || !!options.kvConfig?.length)) ||
          (verification.immediateAffine4 && !options.kvConfig?.length &&
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
      kvBatchCapabilities: kvBatchCapabilities(options.kvScheme).capabilities }),
  };
}
