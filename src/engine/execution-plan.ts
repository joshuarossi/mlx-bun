import type { ExecutionCapabilities, ExecutionFeatures, ExecutionRequirements, ResolvedExecution } from "../contracts/execution";

/** Select the request method, then place it using executor capabilities. */
export function resolveExecution(
  request: ExecutionRequirements, capabilities: ExecutionCapabilities,
  features: ExecutionFeatures = { pagedKv: false, fill: false },
): ResolvedExecution {
  const reasons: string[] = [];
  const sharedRequestExclusions = [
    [!capabilities.continuous, "continuous-unavailable"],
    [request.hasVision, "media-requires-serial"],
    [request.hasAdapters && !capabilities.adapterBatch, "adapters-require-serial"],
    [request.kvQuant && !capabilities.quantizedBatch, "kv-scheme-requires-serial"],
    [request.turboQuant && !capabilities.turboQuantBatch, "turbo-kv-requires-serial"],
    [request.hasGrammar && !capabilities.grammarBatch, "grammar-batching-disabled"],
    [features.pagedKv && !capabilities.pagedBatch, "paged-kv-requires-serial"],
  ] as const;
  const sharedAdapterMethod = capabilities.sharedSpeculativeAdapters === true &&
    !sharedRequestExclusions.some(([excluded]) => excluded) &&
    capabilities.groupedMethods?.includes("speculative") === true;
  const speculative = capabilities.method === "autoregressive" && request.hasDraft &&
    !request.hasVision && (!request.hasAdapters || sharedAdapterMethod) && (!request.wantsLogprobs || capabilities.speculativeLogprobs === true) &&
    (!request.kvQuant || capabilities.speculativeKvQuant === true) &&
    (!request.turboQuant || capabilities.speculativeTurboQuant === true) && !features.pagedKv;
  const method = speculative ? "speculative" : capabilities.method;
  const continuousExclusions = [sharedRequestExclusions[0],
    [!(capabilities.groupedMethods ?? ["autoregressive"]).includes(method), "method-requires-serial"],
    ...sharedRequestExclusions.slice(1),
  ] as const;
  for (const [excluded, reason] of continuousExclusions) if (excluded) reasons.push(reason);
  const mechanism = reasons.length ? "serial" : "continuous";
  if (request.hasDraft && !speculative) reasons.push("draft-incompatible-with-request");
  const pagedKv = features.pagedKv && !request.hasVision && !request.hasAdapters;
  if (features.pagedKv && !pagedKv) reasons.push("paged-kv-bypassed-for-media-or-adapters");
  const promptCache = method !== "speculative" && !request.hasVision;
  const fill = features.fill && method === "autoregressive" && mechanism === "serial" &&
    !request.hasDraft && !request.hasVision && !request.userSeed && !request.hasGrammar &&
    !request.wantsLogprobs && !request.kvQuant && !request.turboQuant;
  if (features.fill && !fill) reasons.push("fill-incompatible-with-request");
  const checkpoint = capabilities.checkpoints && method === "autoregressive" &&
    (mechanism === "serial" || capabilities.sharedCheckpoints === true) && promptCache && !pagedKv && !request.hasGrammar &&
    !features.fill && !request.wantsLogprobs;
  const compiledDecode = features.compiledDecode === true && capabilities.compiledDecode === true &&
    method === "autoregressive" && !request.hasAdapters && !pagedKv;
  if (features.compiledDecode && !compiledDecode) reasons.push("compiled-decode-unavailable-for-request");
  const grammarJump = features.grammarJump === true && request.hasGrammar &&
    method === "autoregressive" && mechanism === "serial" && !request.wantsLogprobs;
  if (features.grammarJump && request.hasGrammar && !grammarJump)
    reasons.push("grammar-jump-incompatible-with-request");
  return Object.freeze({ method, mechanism, pagedKv, promptCache, checkpoint, fill,
    compiledDecode, grammarJump,
    reasons: Object.freeze(reasons) });
}
