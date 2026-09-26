import type { ExecutionCapabilities, ExecutionFeatures, ExecutionRequirements, ResolvedExecution } from "../contracts/portable/execution";

/** Select the request method, then place it using executor capabilities. */
export function resolveExecution(
  request: ExecutionRequirements, capabilities: ExecutionCapabilities,
  features: ExecutionFeatures = { pagedKv: false, fill: false },
): ResolvedExecution {
  const reasons: string[] = [];
  const sharedRequestExclusions = [
    [!capabilities.continuous, "continuous-unavailable"],
    [request.hasVision && !capabilities.mediaBatch, "media-batch-unsupported"],
    [request.hasAdapters && !capabilities.adapterBatch, "adapter-batch-unsupported"],
    [request.kvQuant && !capabilities.quantizedBatch, "kv-scheme-batch-unsupported"],
    [request.turboQuant && !capabilities.turboQuantBatch, "turbo-kv-batch-unsupported"],
    [request.hasGrammar && !capabilities.grammarBatch, "grammar-batch-unsupported"],
    [features.pagedKv && !capabilities.pagedBatch, "paged-kv-batch-unsupported"],
  ] as const;
  const sharedAdapterMethod = capabilities.sharedSpeculativeAdapters === true &&
    !sharedRequestExclusions.some(([excluded]) => excluded) &&
    capabilities.groupedMethods?.includes("speculative") === true;
  const grammarProposals = features.grammarJump === true && request.hasGrammar && !request.hasDraft && !request.hasVision &&
    (!request.wantsLogprobs || capabilities.speculativeLogprobs === true) && !features.pagedKv && capabilities.method === "autoregressive" &&
    capabilities.sharedGrammarProposals === true && capabilities.groupedMethods?.includes("speculative") === true &&
    (!request.hasAdapters || sharedAdapterMethod) && (!request.kvQuant || capabilities.speculativeKvQuant === true) &&
    (!request.turboQuant || capabilities.speculativeTurboQuant === true) &&
    !sharedRequestExclusions.some(([excluded]) => excluded);
  const speculative = grammarProposals || (capabilities.method === "autoregressive" && request.hasDraft &&
    !request.hasVision && (!request.hasAdapters || sharedAdapterMethod) && (!request.wantsLogprobs || capabilities.speculativeLogprobs === true) &&
    (!request.kvQuant || capabilities.speculativeKvQuant === true) &&
    (!request.turboQuant || capabilities.speculativeTurboQuant === true) && !features.pagedKv);
  const method = speculative ? "speculative" : capabilities.method;
  const continuousExclusions = [sharedRequestExclusions[0],
    [!(capabilities.groupedMethods ?? ["autoregressive"]).includes(method), "method-batch-unsupported"],
    ...sharedRequestExclusions.slice(1),
  ] as const;
  for (const [excluded, reason] of continuousExclusions) if (excluded) reasons.push(reason);
  const mechanism = reasons.length ? "unsupported" : "continuous";
  if (request.hasDraft && !speculative) reasons.push("draft-incompatible-with-request");
  const pagedKv = features.pagedKv && !request.hasVision && !request.hasAdapters;
  if (features.pagedKv && !pagedKv) reasons.push("paged-kv-bypassed-for-media-or-adapters");
  const promptCache = method !== "speculative" && (!request.hasVision ||
    (mechanism === "continuous" && request.hasPreparedPrefixIdentity === true && capabilities.mediaPrefixCache === true));
  const sharedFill = mechanism === "continuous" && capabilities.sharedFill === true && !pagedKv;
  const speculativeEcho = method === "speculative" && mechanism === "continuous" &&
    capabilities.sharedSpeculativeEcho === true;
  const fill = features.fill && !request.hasVision && !request.hasGrammar && !request.wantsLogprobs &&
    (speculativeEcho || (method === "autoregressive" && sharedFill && !request.hasDraft));
  // Cache-format eligibility belongs to the method's append binding.
  if (features.fill && !fill) reasons.push("fill-incompatible-with-request");
  const checkpoint = capabilities.checkpoints && method === "autoregressive" && !request.hasVision &&
    capabilities.sharedCheckpoints === true && promptCache && !pagedKv && !request.hasGrammar &&
    !features.fill && !request.wantsLogprobs;
  const compiledDecode = features.compiledDecode === true && capabilities.compiledDecode === true &&
    method === "autoregressive" && !request.hasAdapters && !pagedKv && !(sharedFill && fill);
  if (features.compiledDecode && !compiledDecode) reasons.push("compiled-decode-unavailable-for-request");
  const grammarJump = grammarProposals;
  if (features.grammarJump && request.hasGrammar && !grammarJump)
    reasons.push("grammar-jump-incompatible-with-request");
  return Object.freeze({ method, mechanism, pagedKv, promptCache, checkpoint, fill,
    compiledDecode, grammarJump,
    reasons: Object.freeze(reasons) });
}
