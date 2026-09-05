import type { ExecutionCapabilities, ExecutionFeatures, ExecutionRequirements, ResolvedExecution } from "../contracts/execution";

/** Preserve the shipped support matrix. A configured draft still forces serial
 * placement even when this request must use the ordinary AR method. */
export function resolveExecution(
  request: ExecutionRequirements, capabilities: ExecutionCapabilities,
  features: ExecutionFeatures = { pagedKv: false, fill: false },
): ResolvedExecution {
  const reasons: string[] = [];
  const continuousExclusions = [
    [!capabilities.continuous, "continuous-unavailable"],
    [capabilities.method !== "autoregressive", "method-requires-serial"],
    [request.hasVision, "media-requires-serial"],
    [request.hasAdapters, "adapters-require-serial"],
    [request.wantsLogprobs, "logprobs-require-serial"],
    [request.userSeed, "explicit-seed-requires-serial"],
    [request.kvQuant && !capabilities.quantizedBatch, "kv-scheme-requires-serial"],
    [request.turboQuant, "turbo-kv-requires-serial"],
    [request.hasDraft, "configured-draft-requires-serial"],
    [request.hasGrammar && !capabilities.grammarBatch, "grammar-batching-disabled"],
    [features.pagedKv, "paged-kv-requires-serial"],
  ] as const;
  for (const [excluded, reason] of continuousExclusions) if (excluded) reasons.push(reason);
  const mechanism = reasons.length ? "serial" : "continuous";
  const speculative = capabilities.method === "autoregressive" && request.hasDraft &&
    !request.hasVision && !request.hasAdapters && !request.wantsLogprobs &&
    !request.kvQuant && !request.turboQuant && !features.pagedKv;
  if (request.hasDraft && !speculative) reasons.push("draft-incompatible-with-request");
  const method = speculative ? "speculative" : capabilities.method;
  const pagedKv = features.pagedKv && !request.hasVision && !request.hasAdapters;
  if (features.pagedKv && !pagedKv) reasons.push("paged-kv-bypassed-for-media-or-adapters");
  const promptCache = method !== "speculative" && !request.hasVision && !pagedKv;
  const fill = features.fill && method === "autoregressive" && mechanism === "serial" &&
    !request.hasDraft && !request.hasVision && !request.userSeed && !request.hasGrammar &&
    !request.wantsLogprobs && !request.kvQuant && !request.turboQuant;
  if (features.fill && !fill) reasons.push("fill-incompatible-with-request");
  const checkpoint = capabilities.checkpoints && method === "autoregressive" &&
    mechanism === "serial" && promptCache && !request.hasGrammar &&
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
