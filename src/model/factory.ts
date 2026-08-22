// Model construction consumes one declared profile. Exact artifact profiles
// outrank family profiles; dedicated/generated graphs outrank the universal
// fallback. Request-level methods are resolved elsewhere and are never changed
// by this module.

import { loadModelConfig, type ModelConfig } from "../config";
import { totalmem } from "node:os";
import { Weights } from "../weights";
import { Gemma4Model } from "./gemma4";
import { configFingerprint } from "./fingerprint";
import { GENERATED } from "./generated";
import { MiniCPM5Model } from "./minicpm5";
import { Qwen35Model } from "./qwen3_5";
import { Qwen3Model } from "./qwen3";
import { Qwen3MoeModel } from "./qwen3-moe";
import { DiffusionGemmaModel } from "./diffusion-gemma";
import { Glm52Model } from "./glm52";
import {
  GLM52_G5_DEFAULT_CONTEXT_TOKENS,
  GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
  planGlm52MemoryForArtifact,
  type Glm52MemoryPlan,
} from "./glm52-memory";
import { UniversalDenseModel } from "./universal/dense";
import { genericArgsFor } from "./universal/archs";
import {
  assertResolvedModelProfile,
  resolveModelProfile,
  type ResolvedModelProfile,
} from "./profile";

export type RuntimeModel =
  | Gemma4Model | MiniCPM5Model | Qwen35Model | Qwen3Model | Qwen3MoeModel
  | DiffusionGemmaModel | Glm52Model | UniversalDenseModel;

export interface Glm52RuntimeOpenOptions {
  /** Whole-process ceiling. Defaults to the smaller of the validated 25 GiB
   * preset and physical RAM. */
  memoryBudgetBytes?: number;
  /** Context reserved by the exact GLM resource equation. */
  contextTokens?: number;
  /** Generated-token allowance within contextTokens. */
  maxGenerationTokens?: number;
  /** Maximum ordinary continuous-batch rows. */
  batchSize?: number;
  /** Native checkpoint MTP row; on by default. */
  enableMtp?: boolean;
  mtpDraftTokens?: number;
  /** Test/diagnostic override; normal callers use physical RAM. */
  machineBytes?: number;
  /** Native expert-I/O dylib override. Packaged/dev defaults are automatic. */
  libraryPath?: string;
}

/** Open the direct Colibri artifact through the validated bounded expert
 * runtime. The header-only plan runs before any resident tensor or expert slab
 * is opened, so an impossible configuration fails without committing memory. */
export async function openGlm52RuntimeModel(
  modelDir: string,
  options: Glm52RuntimeOpenOptions = {},
): Promise<{ model: Glm52Model; plan: Glm52MemoryPlan }> {
  const machineBytes = options.machineBytes ?? totalmem();
  const processLimitBytes = options.memoryBudgetBytes ??
    Math.min(GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES, machineBytes);
  const plan = await planGlm52MemoryForArtifact(modelDir, {
    machineBytes,
    processLimitBytes,
    contextTokens: options.contextTokens ?? GLM52_G5_DEFAULT_CONTEXT_TOKENS,
    maxGenerationTokens:
      options.maxGenerationTokens ?? GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
    batchSize: options.batchSize ?? 1,
    enableMtp: options.enableMtp !== false,
    mtpDraftTokens: options.mtpDraftTokens,
  });
  const model = await Glm52Model.openStreamed(modelDir, {
    budgetBytes: plan.processLimitBytes,
    reserveBytes: plan.runtimeReserveBytes,
    workingSlots: plan.mainWorkingSlots,
    maxSlotsPerLayer: 1,
    workers: 2,
    libraryPath: options.libraryPath,
    decodeKernel: "metal",
    enableMtp: plan.enableMtp,
    mtpDraftTokens: plan.mtpDraftTokens,
  });
  if (model.expertRuntime?.plan.plannedBytes !== plan.plannedProcessBytes) {
    const actual = model.expertRuntime?.plan.plannedBytes ?? 0;
    model.dispose();
    throw new Error(
      `GLM runtime plan ${actual} != preflight resource equation ` +
      `${plan.plannedProcessBytes}`,
    );
  }
  return { model, plan };
}

/**
 * Artifact-aware construction. GLM-5.2's Colibri snapshot has no ordinary
 * model.safetensors.index.json, so it must bypass Weights.open and use its
 * dedicated header catalog/tensor source.
 */
export async function openModel(
  modelDir: string,
  options: Glm52RuntimeOpenOptions = {},
): Promise<RuntimeModel> {
  const config = await loadModelConfig(modelDir);
  const profile = resolveModelProfile(config);
  if (profile.profile.execution.loader === "colibri")
    return (await openGlm52RuntimeModel(modelDir, options)).model;
  return createModel(await Weights.open(modelDir), config, profile);
}

/** Construct the graph named by a previously validated profile. */
export function createModel(
  weights: Weights,
  config: ModelConfig,
  resolved: ResolvedModelProfile = resolveModelProfile(config),
): RuntimeModel {
  assertResolvedModelProfile(config, resolved);
  const execution = resolved.profile.execution;
  switch (execution.graph) {
    case "glm5.2":
      throw new Error(
        "glm_moe_dsa uses the direct Colibri container; construct it with " +
        "openModel(modelDir) or Glm52Model.open(modelDir)",
      );
    // DiffusionGemma is non-autoregressive. The profile pairs this graph with
    // the denoising loop; generate() recognizes the constructed model surface.
    case "diffusion-gemma": return new DiffusionGemmaModel(weights, config);
    case "minicpm5": return new MiniCPM5Model(weights, config);
    case "qwen3.5": return new Qwen35Model(weights, config);
    case "qwen3-moe": return new Qwen3MoeModel(weights, config);
    case "qwen3": return new Qwen3Model(weights, config);
    case "gemma4": {
      // Generated specializations remain exact config matches. Output-changing
      // request methods stay independently resolved and cannot be fallbacks.
      const cls = execution.specialization === "generated"
        ? GENERATED.get(configFingerprint(config))!
        : Gemma4Model;
      return new cls(weights, config);
    }
    case "universal-dense":
      return new UniversalDenseModel(weights, config, genericArgsFor(config)!);
  }
}
