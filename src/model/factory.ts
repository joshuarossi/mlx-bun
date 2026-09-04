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
  ModelImplementationRegistry,
  type ModelImplementation,
  type ModelImplementationProvider,
} from "./implementation";
import {
  assertResolvedModelProfile,
  resolveModelProfile,
  type ResolvedModelProfile,
  type ResolveModelProfileOptions,
  type ModelGraph,
} from "./profile";

export type RuntimeModel =
  | Gemma4Model | MiniCPM5Model | Qwen35Model | Qwen3Model | Qwen3MoeModel
  | DiffusionGemmaModel | Glm52Model | UniversalDenseModel;

function residentImplementation(
  id: string,
  graph: ModelGraph,
  create: ModelImplementation<Weights, RuntimeModel>["create"],
): ModelImplementation<Weights, RuntimeModel> {
  return { id, graph, loader: "safetensors",
    loop: graph === "diffusion-gemma" ? "diffusion" : "autoregressive", create };
}

/** Engine-owned registrations. Exact quant profiles can name additional
 * implementations in a composed registry, without changing sessions or files. */
export const MLX_MODEL_IMPLEMENTATIONS = new ModelImplementationRegistry<Weights, RuntimeModel>([
  residentImplementation("diffusion-gemma", "diffusion-gemma", (weights, config) => new DiffusionGemmaModel(weights, config)),
  residentImplementation("minicpm5", "minicpm5", (weights, config) => new MiniCPM5Model(weights, config)),
  residentImplementation("qwen3.5", "qwen3.5", (weights, config) => new Qwen35Model(weights, config)),
  residentImplementation("qwen3-moe", "qwen3-moe", (weights, config) => new Qwen3MoeModel(weights, config)),
  residentImplementation("qwen3", "qwen3", (weights, config) => new Qwen3Model(weights, config)),
  residentImplementation("gemma4", "gemma4", (weights, config) => new Gemma4Model(weights, config)),
  residentImplementation("gemma4-generated", "gemma4", (weights, config) => {
    const Graph = GENERATED.get(configFingerprint(config));
    if (!Graph) throw new Error("no generated Gemma graph for this config; refusing to fall back");
    return new Graph(weights, config);
  }),
  residentImplementation("universal-dense", "universal-dense", (weights, config) =>
    new UniversalDenseModel(weights, config, genericArgsFor(config)!)),
]);

export interface ModelOpenOptions extends Glm52RuntimeOpenOptions {
  readonly profiles?: ResolveModelProfileOptions;
  readonly implementations?: ModelImplementationProvider<Weights, RuntimeModel>;
}

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
  options: ModelOpenOptions = {},
): Promise<RuntimeModel> {
  const config = await loadModelConfig(modelDir);
  const profile = resolveModelProfile(config, options.profiles);
  if (profile.profile.execution.loader === "colibri") {
    if (profile.profile.execution.implementation !== undefined)
      throw new Error("named Colibri implementations require a streamed loader binding; refusing to fall back");
    return (await openGlm52RuntimeModel(modelDir, options)).model;
  }
  // Resolve before opening weights; missing or incompatible code allocates nothing.
  const implementation = (options.implementations ?? MLX_MODEL_IMPLEMENTATIONS).select(config, profile);
  const weights = await Weights.open(modelDir);
  try { return implementation.create(weights, config, profile); }
  catch (error) { weights.dispose(); throw error; }
}

/** Construct the graph named by a previously validated profile. */
export function createModel(
  weights: Weights,
  config: ModelConfig,
  resolved: ResolvedModelProfile = resolveModelProfile(config),
  implementations: ModelImplementationProvider<Weights, RuntimeModel> = MLX_MODEL_IMPLEMENTATIONS,
): RuntimeModel {
  assertResolvedModelProfile(config, resolved);
  if (resolved.profile.execution.loader === "colibri")
    throw new Error(
      "glm_moe_dsa uses the direct Colibri container; construct it with " +
      "openModel(modelDir) or Glm52Model.open(modelDir)",
    );
  return implementations.select(config, resolved).create(weights, config, resolved);
}
