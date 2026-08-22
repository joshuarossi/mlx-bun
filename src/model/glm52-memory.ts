import { buildGlm52ExpertSlotLayout } from "./glm52-expert-layout";
import {
  loadGlm52Config,
  type Glm52Config,
} from "./glm52-config";
import { ColibriGlm52Container } from "./glm52-container";
import type { MemoryPlan } from "../memory-plan";

export const GLM52_G5_GIB = 1024 ** 3;
export const GLM52_G5_DEFAULT_MACHINE_BYTES = 32 * GLM52_G5_GIB;
export const GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES = 25 * GLM52_G5_GIB;
export const GLM52_G5_DEFAULT_CONTEXT_TOKENS = 4096;
export const GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS = 128;
export const GLM52_G5_DEFAULT_ALLOCATOR_RESERVE_BYTES = 4 * GLM52_G5_GIB;
export const GLM52_G5_DEFAULT_BUN_NATIVE_RESERVE_BYTES = 512 * 1024 ** 2;
export const GLM52_G5_DEFAULT_SAFETY_MARGIN_BYTES = 512 * 1024 ** 2;
/** Curated G5 quality-preserving warm result on the M1 Max 32 GB, native MTP
 * on, 128 generated tokens. This is operator guidance, not a prediction. */
export const GLM52_G5_MEASURED_WARM_DECODE_TPS = 0.149;
/** Same-machine direct Colibri/Metal warm median with native MTP on. */
export const GLM52_G5_DIRECT_ORACLE_WARM_DECODE_TPS = 0.27;
export const GLM52_G5_ASPIRATIONAL_DECODE_TPS = 2;
export const GLM52_G5_MEASURED_AT = Date.UTC(2026, 7, 15);

const ROUTED_EXPERT = /\.mlp\.experts\.\d+\./;

export interface Glm52MemoryGeometry {
  readonly residentWeightBytes: number;
  readonly mainExpertSlotBytes: number;
  readonly mtpExpertSlotBytes?: number;
  readonly hiddenSize: number;
  readonly vocabSize: number;
  readonly numHiddenLayers: number;
  readonly sparseLayers: number;
  readonly numAttentionHeads: number;
  readonly kvLoraRank: number;
  readonly qkRopeHeadDim: number;
  readonly qkHeadDim: number;
  readonly vHeadDim: number;
  readonly numRoutedExperts: number;
  readonly numExpertsPerToken: number;
  readonly dsaLayers?: number;
  readonly dsaHeadDim?: number;
  readonly mtpLayers?: number;
}

export interface Glm52MemoryPlanOptions {
  readonly machineBytes?: number;
  readonly processLimitBytes?: number;
  readonly contextTokens?: number;
  readonly maxGenerationTokens?: number;
  readonly batchSize?: number;
  readonly enableMtp?: boolean;
  readonly mtpDraftTokens?: number;
  readonly workingSlots?: number;
  readonly pinnedExpertSlots?: number;
  readonly slotsPerSparseLayer?: number;
  readonly mtpSlotsPerLayer?: number;
  readonly allocatorReserveBytes?: number;
  readonly bunNativeReserveBytes?: number;
  readonly safetyMarginBytes?: number;
}

export interface Glm52MemoryLineItems {
  readonly residentWeightsBytes: number;
  readonly mainExpertSlabBytes: number;
  readonly mtpExpertSlabBytes: number;
  readonly targetKvBytes: number;
  readonly mtpKvBytes: number;
  readonly reconstructedKvTransientBytes: number;
  readonly verifyBatchTransientBytes: number;
  readonly allocatorReserveBytes: number;
  readonly bunNativeReserveBytes: number;
  readonly safetyMarginBytes: number;
}

export interface Glm52MemoryPlan extends MemoryPlan {
  readonly schemaVersion: 1;
  readonly strategy: "glm52-colibri";
  readonly preset: "g5-32gb-quality";
  readonly machineBytes: number;
  readonly processLimitBytes: number;
  /** Deliberately unavailable to this process. */
  readonly osReserveBytes: number;
  readonly contextTokens: number;
  readonly maxGenerationTokens: number;
  readonly batchSize: number;
  readonly enableMtp: boolean;
  readonly mtpDraftTokens: number;
  readonly verifyRows: number;
  readonly mainWorkingSlots: number;
  readonly mainRequiredUnionSlots: number;
  readonly mainResidentSlots: number;
  readonly mainTotalSlots: number;
  readonly mtpWorkingSlots: number;
  readonly mtpResidentSlots: number;
  readonly mtpTotalSlots: number;
  readonly lineItems: Glm52MemoryLineItems;
  readonly runtimeReserveBytes: number;
  readonly plannedProcessBytes: number;
  readonly processHeadroomBytes: number;
  readonly plannedMachineBytes: number;
  readonly machineHeadroomBytes: number;
}

function nonNegativeSafeInteger(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value < 0)
    throw new RangeError(`${label} must be a non-negative safe integer`);
}

function positiveSafeInteger(value: number, label: string): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${label} must be a positive safe integer`);
}

function sum(label: string, values: readonly number[]): number {
  let result = 0;
  for (const value of values) {
    nonNegativeSafeInteger(value, label);
    result += value;
    if (!Number.isSafeInteger(result))
      throw new RangeError(`${label} exceeds the safe integer range`);
  }
  return result;
}

function product(label: string, values: readonly number[]): number {
  let result = 1;
  for (const value of values) {
    nonNegativeSafeInteger(value, label);
    result *= value;
    if (!Number.isSafeInteger(result))
      throw new RangeError(`${label} exceeds the safe integer range`);
  }
  return result;
}

function bytesWithoutRoutedExperts(
  container: ColibriGlm52Container,
  includeMtp: boolean,
): number {
  return sum(
    "GLM resident weights",
    [...container.tensors.values()]
      .filter((tensor) =>
        (includeMtp || tensor.family !== "mtp") &&
        !ROUTED_EXPERT.test(tensor.name))
      .map((tensor) => tensor.byteLength),
  );
}

/**
 * Full G5 process equation. The 32 GB preset reserves one persistent slot per
 * sparse layer, keeps the global 64-slot miss bank, and treats the OS reserve
 * as memory that the process is never allowed to claim.
 */
export function planGlm52Memory(
  geometry: Glm52MemoryGeometry,
  options: Glm52MemoryPlanOptions = {},
): Glm52MemoryPlan {
  const machineBytes =
    options.machineBytes ?? GLM52_G5_DEFAULT_MACHINE_BYTES;
  const processLimitBytes =
    options.processLimitBytes ?? GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES;
  const contextTokens =
    options.contextTokens ?? GLM52_G5_DEFAULT_CONTEXT_TOKENS;
  const maxGenerationTokens =
    options.maxGenerationTokens ?? GLM52_G5_DEFAULT_MAX_GENERATION_TOKENS;
  const batchSize = options.batchSize ?? 1;
  const enableMtp = options.enableMtp !== false;
  const mtpDraftTokens = options.mtpDraftTokens ?? 3;
  const mainWorkingSlots = options.workingSlots ?? 64;
  const pinnedExpertSlots = options.pinnedExpertSlots ?? 0;
  const slotsPerSparseLayer = options.slotsPerSparseLayer ?? 1;
  const mtpSlotsPerLayer = options.mtpSlotsPerLayer ?? 1;
  const allocatorReserveBytes =
    options.allocatorReserveBytes ??
    GLM52_G5_DEFAULT_ALLOCATOR_RESERVE_BYTES;
  const bunNativeReserveBytes =
    options.bunNativeReserveBytes ??
    GLM52_G5_DEFAULT_BUN_NATIVE_RESERVE_BYTES;
  const safetyMarginBytes =
    options.safetyMarginBytes ??
    GLM52_G5_DEFAULT_SAFETY_MARGIN_BYTES;

  for (const [label, value] of [
    ["GLM machineBytes", machineBytes],
    ["GLM processLimitBytes", processLimitBytes],
    ["GLM contextTokens", contextTokens],
    ["GLM maxGenerationTokens", maxGenerationTokens],
    ["GLM batchSize", batchSize],
    ["GLM mtpDraftTokens", mtpDraftTokens],
    ["GLM workingSlots", mainWorkingSlots],
    ["GLM slotsPerSparseLayer", slotsPerSparseLayer],
    ["GLM mtpSlotsPerLayer", mtpSlotsPerLayer],
    ["GLM residentWeightBytes", geometry.residentWeightBytes],
    ["GLM mainExpertSlotBytes", geometry.mainExpertSlotBytes],
    ["GLM hiddenSize", geometry.hiddenSize],
    ["GLM vocabSize", geometry.vocabSize],
    ["GLM numHiddenLayers", geometry.numHiddenLayers],
    ["GLM sparseLayers", geometry.sparseLayers],
    ["GLM numAttentionHeads", geometry.numAttentionHeads],
    ["GLM kvLoraRank", geometry.kvLoraRank],
    ["GLM qkRopeHeadDim", geometry.qkRopeHeadDim],
    ["GLM qkHeadDim", geometry.qkHeadDim],
    ["GLM vHeadDim", geometry.vHeadDim],
    ["GLM numRoutedExperts", geometry.numRoutedExperts],
    ["GLM numExpertsPerToken", geometry.numExpertsPerToken],
  ] as const) {
    positiveSafeInteger(value, label);
  }
  for (const [label, value] of [
    ["GLM pinnedExpertSlots", pinnedExpertSlots],
    ["GLM allocatorReserveBytes", allocatorReserveBytes],
    ["GLM bunNativeReserveBytes", bunNativeReserveBytes],
    ["GLM safetyMarginBytes", safetyMarginBytes],
    ["GLM dsaLayers", geometry.dsaLayers ?? 0],
    ["GLM dsaHeadDim", geometry.dsaHeadDim ?? 0],
    ["GLM mtpLayers", geometry.mtpLayers ?? 0],
  ] as const) {
    nonNegativeSafeInteger(value, label);
  }
  if (processLimitBytes > machineBytes) {
    throw new Error(
      `GLM memory contract cannot start: process limit ${processLimitBytes} ` +
      `exceeds machine memory ${machineBytes}`,
    );
  }
  if (maxGenerationTokens > contextTokens) {
    throw new Error(
      `GLM memory contract cannot start: ${maxGenerationTokens} generated ` +
      `tokens exceed the ${contextTokens}-token context preset`,
    );
  }

  const mtpLayers = enableMtp ? (geometry.mtpLayers ?? 0) : 0;
  if (enableMtp && mtpLayers === 0)
    throw new Error("GLM memory contract cannot enable MTP without an MTP layer");
  if (enableMtp && geometry.mtpExpertSlotBytes === undefined) {
    throw new Error(
      "GLM memory contract cannot enable MTP without an MTP expert slot",
    );
  }
  const dsaLayers = geometry.dsaLayers ?? 0;
  if (dsaLayers > geometry.numHiddenLayers)
    throw new Error("GLM DSA layer count exceeds the target layer count");
  if (dsaLayers > 0 && (geometry.dsaHeadDim ?? 0) === 0)
    throw new Error("GLM DSA layers require a positive DSA head width");

  const verifyRows = enableMtp ? mtpDraftTokens + 1 : 1;
  const mainRequiredUnionSlots = Math.min(
    geometry.numRoutedExperts,
    geometry.numExpertsPerToken * verifyRows,
  );
  if (mainRequiredUnionSlots > mainWorkingSlots) {
    throw new Error(
      `GLM memory contract cannot start: ${mainRequiredUnionSlots} target ` +
      `verify-union slots exceed the ${mainWorkingSlots}-slot working bank`,
    );
  }
  const mainResidentSlots = geometry.sparseLayers * slotsPerSparseLayer;
  const mainTotalSlots =
    mainWorkingSlots + pinnedExpertSlots + mainResidentSlots;
  const mtpWorkingSlots = enableMtp
    ? Math.min(
        geometry.numRoutedExperts,
        geometry.numExpertsPerToken * mtpDraftTokens,
      )
    : 0;
  const mtpResidentSlots = enableMtp ? mtpLayers * mtpSlotsPerLayer : 0;
  const mtpTotalSlots = mtpWorkingSlots + mtpResidentSlots;

  const mainExpertSlabBytes = product(
    "GLM main expert slab",
    [mainTotalSlots, geometry.mainExpertSlotBytes],
  );
  const mtpExpertSlabBytes = enableMtp
    ? product(
        "GLM MTP expert slab",
        [mtpTotalSlots, geometry.mtpExpertSlotBytes!],
      )
    : 0;
  const baseKvWidth = geometry.kvLoraRank + geometry.qkRopeHeadDim;
  const targetKvBytes = product(
    "GLM target KV",
    [
      batchSize,
      contextTokens,
      (
        geometry.numHiddenLayers * baseKvWidth +
        dsaLayers * (geometry.dsaHeadDim ?? 0)
      ),
      4,
    ],
  );
  const mtpKvBytes = enableMtp
    ? product(
        "GLM MTP KV",
        [batchSize, contextTokens, mtpLayers, baseKvWidth, 4],
      )
    : 0;
  // MLA reconstructs full per-head K/V for the largest target verification
  // graph. Count the cache horizon plus that graph's appended rows.
  const reconstructedKvTransientBytes = product(
    "GLM reconstructed KV transient",
    [
      batchSize,
      geometry.numAttentionHeads,
      contextTokens + verifyRows,
      geometry.qkHeadDim + geometry.vHeadDim,
      4,
    ],
  );
  // Explicit user-visible rows at the verify boundary. Internal graph
  // temporaries and allocator cache remain covered by the separate allocator
  // reserve rather than being guessed tensor-by-tensor.
  const targetVerifyBytes = product(
    "GLM target verify batch",
    [
      batchSize,
      verifyRows,
      geometry.hiddenSize + geometry.vocabSize,
      4,
    ],
  );
  const mtpDraftBytes = enableMtp
    ? product(
        "GLM MTP draft batch",
        [
          batchSize,
          mtpDraftTokens,
          geometry.hiddenSize + geometry.vocabSize,
          4,
        ],
      )
    : 0;
  const verifyBatchTransientBytes =
    sum("GLM verify batch transient", [targetVerifyBytes, mtpDraftBytes]);

  const lineItems: Glm52MemoryLineItems = {
    residentWeightsBytes: geometry.residentWeightBytes,
    mainExpertSlabBytes,
    mtpExpertSlabBytes,
    targetKvBytes,
    mtpKvBytes,
    reconstructedKvTransientBytes,
    verifyBatchTransientBytes,
    allocatorReserveBytes,
    bunNativeReserveBytes,
    safetyMarginBytes,
  };
  const runtimeReserveBytes = sum("GLM runtime reserve", [
    targetKvBytes,
    mtpKvBytes,
    reconstructedKvTransientBytes,
    verifyBatchTransientBytes,
    allocatorReserveBytes,
    bunNativeReserveBytes,
    safetyMarginBytes,
  ]);
  const plannedProcessBytes = sum(
    "GLM planned process bytes",
    Object.values(lineItems),
  );
  if (plannedProcessBytes > processLimitBytes) {
    throw new Error(
      `GLM memory contract cannot start: planned ${plannedProcessBytes} bytes ` +
      `exceed the ${processLimitBytes}-byte process limit`,
    );
  }
  const osReserveBytes = machineBytes - processLimitBytes;
  const plannedMachineBytes = sum(
    "GLM planned machine bytes",
    [plannedProcessBytes, osReserveBytes],
  );

  return {
    schemaVersion: 1,
    strategy: "glm52-colibri",
    fits: true,
    preset: "g5-32gb-quality",
    machineBytes,
    processLimitBytes,
    osReserveBytes,
    contextTokens,
    maxSafeContext: contextTokens,
    maxGenerationTokens,
    batchSize,
    enableMtp,
    mtpDraftTokens,
    verifyRows,
    mainWorkingSlots,
    mainRequiredUnionSlots,
    mainResidentSlots,
    mainTotalSlots,
    mtpWorkingSlots,
    mtpResidentSlots,
    mtpTotalSlots,
    lineItems,
    weightsBytes: sum("GLM planned weights", [
      lineItems.residentWeightsBytes,
      lineItems.mainExpertSlabBytes,
      lineItems.mtpExpertSlabBytes,
    ]),
    kvBytes: sum("GLM planned KV", [
      lineItems.targetKvBytes,
      lineItems.mtpKvBytes,
    ]),
    transientBytes: sum("GLM planned transient", [
      lineItems.reconstructedKvTransientBytes,
      lineItems.verifyBatchTransientBytes,
    ]),
    reserveBytes: sum("GLM planned reserves", [
      lineItems.allocatorReserveBytes,
      lineItems.bunNativeReserveBytes,
      lineItems.safetyMarginBytes,
    ]),
    totalBytes: plannedProcessBytes,
    usableBytes: processLimitBytes,
    predictedDecodeTps: null,
    allocatorLimitBytes: lineItems.allocatorReserveBytes,
    runtimeReserveBytes,
    plannedProcessBytes,
    processHeadroomBytes: processLimitBytes - plannedProcessBytes,
    plannedMachineBytes,
    machineHeadroomBytes: machineBytes - plannedMachineBytes,
  };
}

export function describeGlm52MemoryGeometry(
  container: ColibriGlm52Container,
  config: Glm52Config,
  enableMtp = true,
): Glm52MemoryGeometry {
  const sparseLayers = config.numHiddenLayers - config.firstKDenseReplace;
  if (sparseLayers <= 0)
    throw new Error("GLM memory contract requires at least one sparse layer");
  const capabilities = container.capabilities(config);
  if (enableMtp && !capabilities.hasMtp) {
    throw new Error(
      "GLM memory contract cannot enable MTP: artifact is missing the " +
      `complete MTP tensor family (${capabilities.missingMtpTensors.join(", ")})`,
    );
  }
  const mainSlot = buildGlm52ExpertSlotLayout(
    container,
    config,
    config.firstKDenseReplace,
    0,
  );
  const mtpSlot = enableMtp
    ? buildGlm52ExpertSlotLayout(
        container,
        config,
        config.numHiddenLayers,
        0,
      )
    : null;
  const dsaLayers = capabilities.hasDsa
    ? config.indexerTypes.filter((kind) => kind === "full").length
    : 0;
  return {
    residentWeightBytes: bytesWithoutRoutedExperts(container, enableMtp),
    mainExpertSlotBytes: mainSlot.slotBytes,
    ...(mtpSlot ? { mtpExpertSlotBytes: mtpSlot.slotBytes } : {}),
    hiddenSize: config.hiddenSize,
    vocabSize: config.vocabSize,
    numHiddenLayers: config.numHiddenLayers,
    sparseLayers,
    numAttentionHeads: config.numAttentionHeads,
    kvLoraRank: config.kvLoraRank,
    qkRopeHeadDim: config.qkRopeHeadDim,
    qkHeadDim: config.qkHeadDim,
    vHeadDim: config.vHeadDim,
    numRoutedExperts: config.numRoutedExperts,
    numExpertsPerToken: config.numExpertsPerToken,
    dsaLayers,
    dsaHeadDim: config.indexHeadDim,
    mtpLayers: enableMtp ? config.numNextnPredictLayers : 0,
  };
}

/**
 * Header-only preflight for the direct Colibri artifact. This is intentionally
 * safe to call before any resident weight mmap or native expert slab exists.
 */
export async function planGlm52MemoryForArtifact(
  modelDir: string,
  options: Glm52MemoryPlanOptions = {},
): Promise<Glm52MemoryPlan> {
  const enableMtp = options.enableMtp !== false;
  const [config, container] = await Promise.all([
    loadGlm52Config(modelDir),
    Promise.resolve().then(() => ColibriGlm52Container.open(modelDir)),
  ]);
  return planGlm52Memory(
    describeGlm52MemoryGeometry(container, config, enableMtp),
    { ...options, enableMtp },
  );
}
