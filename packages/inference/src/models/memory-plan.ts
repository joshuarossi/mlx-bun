// Memory plans that need only the artifact's headers, so callers can ask for
// one without loading any native module.

import { totalmem } from "node:os";
import type { ModelConfig } from "../artifacts/config";
import {
  GLM52_G5_DEFAULT_CONTEXT_TOKENS,
  GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
  planGlm52MemoryForArtifact,
} from "../artifacts/glm52/memory";
import type { MemoryPlan } from "../contracts/portable/memory-plan";
import { resolveModelProfile, type ResolvedModelProfile, type ResolveModelProfileOptions } from "./profile";

/** Whether the resolved profile's weights load through a planned runtime. */
export function plansMemory(resolved: ResolvedModelProfile): boolean {
  return resolved.profile.execution.loader !== "safetensors";
}

/** The memory plan a planned runtime would run under on this machine, or null
 * when the model has none (its caller estimates from resident weights). Reads
 * artifact headers only. */
export async function planRuntimeMemory(
  modelDir: string, config: ModelConfig,
  options: { contextTokens?: number; machineBytes?: number; profiles?: ResolveModelProfileOptions } = {},
): Promise<MemoryPlan | null> {
  const resolved = resolveModelProfile(config, options.profiles);
  if (!plansMemory(resolved)) return null;
  const machineBytes = options.machineBytes ?? totalmem();
  const contextTokens = options.contextTokens ?? GLM52_G5_DEFAULT_CONTEXT_TOKENS;
  return planGlm52MemoryForArtifact(modelDir, {
    machineBytes,
    processLimitBytes: Math.min(GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES, machineBytes),
    contextTokens,
    maxGenerationTokens: Math.min(contextTokens, GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS),
    batchSize: 1,
    enableMtp: true,
  });
}
