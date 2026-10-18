import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Factory
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/factory.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Model construction consumes one declared profile and one composition. Exact
// artifact profiles outrank family profiles; the profile names the family's
// implementation, and the family's graph table picks the graph for the
// composition. Request-level methods are resolved elsewhere and are never
// changed by this module.

import { loadModelConfig, type ModelConfig } from "../artifacts/config";
import { totalmem } from "node:os";
import { Weights } from "../artifacts/weights";
import { Gemma4Model } from "./gemma4/model";
import { configFingerprint } from "../artifacts/fingerprint";
import { qwen35GraphFingerprint } from "./qwen/checkpoint";
import {
  DECODE_ROWS as QWEN38_M4PRO_DECODE_ROWS, QWEN38_TRELLIS_M4PRO_GRAPH, Qwen38TrellisM4Pro,
  anePrograms as qwen38TrellisM4ProAnePrograms,
} from "./qwen/qwen38-27b-trellis-m4pro";
import {
  QWEN38_TRELLIS_M1MAX_GRAPH, Qwen38TrellisM1Max,
  anePrograms as qwen38TrellisM1MaxAnePrograms,
} from "./qwen/qwen38-27b-trellis-m1max";
import { GEMMA_GRAPHS, type Gemma4Graph } from "./gemma4/graphs";
import { MiniCPM5Model } from "./minicpm5/model";
import { Qwen35Model } from "./qwen/qwen3_5";
import { Qwen3Model } from "./qwen/qwen3";
import { Qwen3MoeModel } from "./qwen/qwen3-moe";
import { DiffusionGemmaModel } from "./diffusion-gemma/model";
import { Glm52Model, type Glm52LoadedModel, type Glm52LatentCaches } from "./glm52/model";
import {
  GLM52_G5_DEFAULT_CONTEXT_TOKENS,
  GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS,
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
  planGlm52MemoryForArtifact,
  type Glm52MemoryPlan,
} from "../artifacts/glm52/memory";
import { UniversalDenseModel } from "./universal/dense";
import { WhisperModel } from "./whisper/model";
import { genericArgsFor } from "./universal/archs";
import { familyForGraph } from "./families";
import { resolveComposition } from "./composition";
import { bindGraphCaches } from "./cache-composition";
import { phaseRowLimit } from "./graph";
import type { Composition } from "../contracts/portable/composition";
import type { Cache } from "../contracts/mlx/cache";
import {
  GraphTable,
  ModelImplementationRegistry,
  type GraphEntry,
  type ModelImplementation,
  type ModelImplementationProvider,
} from "./implementation";
import {
  assertResolvedModelProfile,
  resolveModelProfile,
  type ResolvedModelProfile,
  type ResolveModelProfileOptions,
  type ModelGraph,
  type ModelLoader,
  type GenerationLoop,
} from "./profile";

type WrittenGraph = (
  | Gemma4Model | Gemma4Graph | MiniCPM5Model | Qwen35Model | Qwen38TrellisM4Pro | Qwen38TrellisM1Max | Qwen3Model | Qwen3MoeModel
  | DiffusionGemmaModel | Glm52Model | UniversalDenseModel);

export type RuntimeModel = WrittenGraph & { makeCache(): Cache[]; readonly composition?: Composition };

/** The family's single fallback graph. */
function generic(id: string, create: GraphEntry<Weights, WrittenGraph>["create"]): GraphEntry<Weights, RuntimeModel> {
  return loadedEntry({ id, serves: {}, create });
}

function loadedEntry(entry: GraphEntry<Weights, WrittenGraph>): GraphEntry<Weights, RuntimeModel> {
  return { ...entry, create: (weights, config, composition) => loadedGraph(entry.create(weights, config, composition), composition) };
}

/** Attach the loader's cache and scheduler configuration to a shipped graph.
 * Its written implementation only provides the layer layout and operations. */
function loadedGraph(graph: WrittenGraph, composition: Composition): RuntimeModel {
  return Object.assign(bindGraphCaches(graph, composition), { composition });
}

/** Resident graph files and their default recommendation keys. Explicit
 * choices are unrestricted; see {@link GraphTable}. */
export const MLX_GRAPH_TABLES: Readonly<Record<ModelGraph, GraphTable<Weights, RuntimeModel>>> = Object.freeze({
  "diffusion-gemma": new GraphTable([generic("diffusion-gemma", (weights, config, composition) => new DiffusionGemmaModel(weights, config))]),
  "minicpm5": new GraphTable([generic("minicpm5", (weights, config, composition) => new MiniCPM5Model(weights, config, phaseRowLimit(composition)))]),
  // Written graph recommendations for the published Trellis artifact.
  // Explicit caller choices bypass these artifact and device keys.
  "qwen3.5": new GraphTable([
    loadedEntry({ id: QWEN38_TRELLIS_M4PRO_GRAPH, serves: {
        fingerprint:"cfa205c8f5af046a",device:"applegpu_g16s",maxRows:QWEN38_M4PRO_DECODE_ROWS,
        kv:[{kind:"bf16"},{kind:"affine",bits:4,groupSize:64}],
      },
      create: (weights,config) => new Qwen38TrellisM4Pro(weights,config),
      anePrograms: () => qwen38TrellisM4ProAnePrograms() }),
    loadedEntry({ id: QWEN38_TRELLIS_M1MAX_GRAPH, serves: {
      fingerprint:"cfa205c8f5af046a",device:"applegpu_g13s",
    }, create: (weights, config) => new Qwen38TrellisM1Max(weights, config),
      anePrograms: () => qwen38TrellisM1MaxAnePrograms() }),
    generic("qwen3.5", (weights, config, composition) => new Qwen35Model(weights, config, phaseRowLimit(composition), composition.device)),
  ], qwen35GraphFingerprint),
  "qwen3-moe": new GraphTable([generic("qwen3-moe", (weights, config, composition) => new Qwen3MoeModel(weights, config, phaseRowLimit(composition)))]),
  "qwen3": new GraphTable([generic("qwen3", (weights, config, composition) => new Qwen3Model(weights, config, phaseRowLimit(composition)))]),
  "gemma4": new GraphTable([...GEMMA_GRAPHS.map(loadedEntry), generic("gemma4", (weights, config, composition) => new Gemma4Model(weights, config, phaseRowLimit(composition)))],
    configFingerprint),
  "universal-dense": new GraphTable([
    generic("universal-dense", (weights, config, composition) =>
      new UniversalDenseModel(weights, config, genericArgsFor(config)!, phaseRowLimit(composition), composition.device))]),
});

/** A resident family's native construction: its graph table selects the graph for
 * the composition it receives. Its loader and loop are the family's own declaration. */
function residentImplementation(graph: ModelGraph, table: GraphTable<Weights, RuntimeModel>): ModelImplementation<Weights, RuntimeModel> {
  const family = familyForGraph(graph);
  if (!family) throw new Error(`graph table ${graph} names a graph no model family declares`);
  return { id: graph, graph, loader: family.loader, loop: family.loop,
    create: (weights, config, _profile, composition) =>
      table.select(config, composition).create(weights, config, composition) };
}

/** Engine-owned registrations, one per resident graph of `MODEL_FAMILIES`. Exact
 * quant profiles can name additional implementations in a composed registry,
 * without changing sessions or files. */
export const MLX_MODEL_IMPLEMENTATIONS = new ModelImplementationRegistry<Weights, RuntimeModel>(
  Object.entries(MLX_GRAPH_TABLES).map(([graph, table]) => residentImplementation(graph, table)));

export interface ModelOpenOptions<Model = RuntimeModel> extends Glm52RuntimeOpenOptions {
  readonly profiles?: ResolveModelProfileOptions;
  readonly implementations?: ModelImplementationProvider<Weights, Model>;
  /** The composition the graph is built for; absent resolves the default record
   * (`resolveComposition(config)`). The direct Colibri runtime plans its own
   * resources from the options above and takes none. */
  readonly composition?: Composition;
  /** A named shipped graph or the caller's own load function. Explicit choices
   * bypass device and configuration recommendations and need no registration. */
  readonly graph?: string | ((weights: Weights, config: ModelConfig) => Model);
}

/** A loader entry cannot provide the requested artifact/operation pairing. */
export class UnsupportedModelLoadError extends Error {
  readonly code = "unsupported-model-load";
  constructor(readonly profile: ResolvedModelProfile, message: string) {
    super(message);
    this.name = "UnsupportedModelLoadError";
  }
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
  /** The composition's KV scheme and paging, which the graph's latent caches
   * compose (default f32, unpaged). */
  caches?: Glm52LatentCaches;
}

/** Open the direct Colibri artifact through the validated bounded expert
 * runtime. The header-only plan runs before any resident tensor or expert slab
 * is opened, so an impossible configuration fails without committing memory. */
export async function openGlm52RuntimeModel(
  modelDir: string,
  options: Glm52RuntimeOpenOptions = {},
): Promise<{ model: Glm52LoadedModel; plan: Glm52MemoryPlan }> {
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
    ...(options.caches ? { caches: options.caches } : {}),
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

/** Open a Whisper checkpoint (encoder-decoder speech model) through the same
 * profile resolution as text models. Whisper never enters the chat loop, so
 * it is not a RuntimeModel: the transcription engine
 * (packages/inference/src/transcription/whisper/)
 * owns it. */
export async function openWhisperModel(
  modelDir: string, options: { readonly profiles?: ResolveModelProfileOptions } = {},
): Promise<{ model: WhisperModel; profile: ResolvedModelProfile; config: ModelConfig }> {
  const config = await loadModelConfig(modelDir);
  const profile = resolveModelProfile(config, options.profiles);
  if (profile.profile.execution.graph !== "whisper")
    throw new Error(`${modelDir} is not a Whisper checkpoint (profile ${profile.profile.id})`);
  const weights = await Weights.open(modelDir);
  try {
    return { model: new WhisperModel(weights, config), profile, config };
  } catch (error) {
    weights.dispose();
    throw error;
  }
}

/**
 * Artifact-aware construction. GLM-5.2's Colibri snapshot has no ordinary
 * model.safetensors.index.json, so it must bypass Weights.open and use its
 * dedicated header catalog/tensor source.
 */
export function openModel<Model>(
  modelDir: string,
  options: ModelOpenOptions<Model> & { readonly graph: (weights: Weights, config: ModelConfig) => Model },
): Promise<Model>;
export function openModel<Model>(
  modelDir: string,
  options: ModelOpenOptions<Model> & { readonly implementations: ModelImplementationProvider<Weights, Model> },
): Promise<Model>;
export function openModel(modelDir: string, options?: ModelOpenOptions): Promise<RuntimeModel>;
export async function openModel<Model>(
  modelDir: string,
  options: ModelOpenOptions<Model> = {},
): Promise<Model | RuntimeModel> {
  const config = await loadModelConfig(modelDir);
  const composition = options.composition ?? resolveComposition(config);
  // A caller's graph is the complete arrangement. Loading it does not require
  // a family profile or participation in the default recommendation table.
  if (typeof options.graph === "function") {
    const weights = await Weights.open(modelDir);
    try { return options.graph(weights, config); }
    catch (error) { weights.dispose(); throw error; }
  }
  const profile = resolveModelProfile(config, options.profiles);
  if (options.graph !== undefined) {
    const entry = MLX_GRAPH_TABLES[profile.profile.execution.graph]?.explicit(options.graph);
    if (!entry) throw new Error(`no shipped graph table for ${profile.profile.execution.graph}`);
    const weights = await Weights.open(modelDir);
    try { return entry.create(weights, config, composition); }
    catch (error) { weights.dispose(); throw error; }
  }
  return ARTIFACT_LOADERS[profile.profile.execution.loader][profile.profile.execution.loop]
    .open({ modelDir, config, profile, composition, options });
}

interface ArtifactLoad<Model> {
  readonly modelDir: string;
  readonly config: ModelConfig;
  readonly profile: ResolvedModelProfile;
  readonly composition: Composition;
  readonly options: ModelOpenOptions<Model>;
}

interface ArtifactLoader {
  open<Model>(load: ArtifactLoad<Model>): Promise<Model | RuntimeModel>;
  create<Model>(weights: Weights, config: ModelConfig, profile: ResolvedModelProfile,
    composition: Composition, implementations: ModelImplementationProvider<Weights, Model>): Model;
}

const residentLoader: ArtifactLoader = {
  async open({ modelDir, config, profile, composition, options }) {
    const implementation = (options.implementations ?? MLX_MODEL_IMPLEMENTATIONS).select(config, profile);
    const weights = await Weights.open(modelDir);
    try { return implementation.create(weights, config, profile, composition); }
    catch (error) { weights.dispose(); throw error; }
  },
  create: (weights, config, profile, composition, implementations) =>
    implementations.select(config, profile).create(weights, config, profile, composition),
};

const streamedLoader: ArtifactLoader = {
  async open({ modelDir, profile, composition, options }) {
    if (options.implementations || profile.profile.execution.implementation !== undefined)
      throw new UnsupportedModelLoadError(profile, "custom Colibri implementations require a streamed loader binding; refusing to fall back");
    return (await openGlm52RuntimeModel(modelDir, options.composition
      ? { ...options, caches: { kv: composition.kv, pagedKv: composition.pagedKv } } : options)).model;
  },
  create(_weights, _config, profile) {
    throw new UnsupportedModelLoadError(profile, `${profile.profile.id} uses the direct Colibri container; construct it with ` +
      "openModel(modelDir) or Glm52Model.open(modelDir)");
  },
};

const speechLoader: ArtifactLoader = {
  async open({ modelDir, profile }) {
    throw new UnsupportedModelLoadError(profile, `${modelDir} is a speech model (${profile.profile.id}); open it with openWhisperModel ` +
      "or serve it as a transcription model — it has no chat/completion loop");
  },
  create(_weights, _config, profile) {
    throw new UnsupportedModelLoadError(profile, `${profile.profile.id} has an encoder-decoder graph; open it with openWhisperModel`);
  },
};

/** Artifact loading follows declared table facts, including streamed weights
 * and the separate speech operation. It never selects by a model predicate. */
const ARTIFACT_LOADERS: Readonly<Record<ModelLoader, Readonly<Record<GenerationLoop, ArtifactLoader>>>> = {
  safetensors: { autoregressive: residentLoader, diffusion: residentLoader, "encoder-decoder": speechLoader },
  colibri: { autoregressive: streamedLoader, diffusion: streamedLoader, "encoder-decoder": speechLoader },
};

/** Construct the binding named by a validated profile for `composition`, which
 * the implementation receives (absent: the default record,
 * `resolveComposition(config)`). A supplied registry can return any
 * backend-owned interface; the compatibility default returns the legacy model
 * union. The caller retains ownership of the supplied weights. */
export function createModel<Model>(
  weights: Weights, config: ModelConfig, composition: Composition | undefined,
  resolved: ResolvedModelProfile | undefined, implementations: ModelImplementationProvider<Weights, Model>,
): Model;
export function createModel(
  weights: Weights, config: ModelConfig, composition?: Composition, resolved?: ResolvedModelProfile,
  implementations?: ModelImplementationProvider<Weights, RuntimeModel>,
): RuntimeModel;
export function createModel<Model>(
  weights: Weights,
  config: ModelConfig,
  composition: Composition = resolveComposition(config),
  resolved: ResolvedModelProfile = resolveModelProfile(config),
  implementations: ModelImplementationProvider<Weights, Model> | ModelImplementationProvider<Weights, RuntimeModel> = MLX_MODEL_IMPLEMENTATIONS,
): Model | RuntimeModel {
  assertResolvedModelProfile(config, resolved);
  return ARTIFACT_LOADERS[resolved.profile.execution.loader][resolved.profile.execution.loop]
    .create<Model | RuntimeModel>(weights, config, resolved, composition, implementations);
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Factory
