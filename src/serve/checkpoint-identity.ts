import type { GenerateOptions } from "../generate";

/** Stable identity for an exactly resumable generation. The prompt already
 * includes rendered messages and tool schemas; the remaining fields cover
 * every sampling policy that can change the continuation. */
export function generationCheckpointKey(
  promptIds: number[], options: GenerateOptions & { stopSequences?: readonly string[] }, cacheNs = "",
): string {
  const policy = {
    version: 2,
    stopSequences: options.stopSequences ?? [],
    cacheNs,
    promptIds,
    maxTokens: options.maxTokens,
    eosTokenIds: options.eosTokenIds,
    temperature: options.temperature,
    topP: options.topP,
    topK: options.topK,
    minP: options.minP,
    minTokensToKeep: options.minTokensToKeep,
    xtcProbability: options.xtcProbability,
    xtcThreshold: options.xtcThreshold,
    xtcSpecialTokens: options.xtcSpecialTokens,
    // A missing client seed means "fresh randomness" for a new request, but
    // an identical RETRY must find the durable checkpoint and restore the
    // original random stream. Keep the generated seed out of request identity;
    // it travels in checkpoint metadata instead. Explicit seeds remain part of
    // the policy, so changing one cannot select an incompatible checkpoint.
    seedMode: options.seedWasExplicit ? "explicit" : "server-default",
    seed: options.seedWasExplicit ? options.seed : undefined,
    hlg: options.hlg,
    curve: options.curve,
    logitBias: options.logitBias,
    repetitionPenalty: options.repetitionPenalty,
    repetitionContextSize: options.repetitionContextSize,
    presencePenalty: options.presencePenalty,
    presenceContextSize: options.presenceContextSize,
    frequencyPenalty: options.frequencyPenalty,
    frequencyContextSize: options.frequencyContextSize,
    kvBits: options.kvBits,
    kvGroupSize: options.kvGroupSize,
    quantizedKvStart: options.quantizedKvStart,
    kvConfig: options.kvConfig,
    turboQuant: options.turboQuant,
  };
  return Bun.hash(JSON.stringify(policy)).toString(16);
}
