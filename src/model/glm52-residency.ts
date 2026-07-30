import { ExpertIOSlabStore } from "../expert-io";
import {
  ExpertResidencyManager,
  planExpertResidency,
  type ExpertResidencyPlan,
} from "../expert-residency";
import type { Glm52Config } from "./glm52-config";
import { ColibriGlm52Container } from "./glm52-container";
import {
  buildGlm52ExpertSlotLayout,
  type Glm52ExpertSlotLayout,
} from "./glm52-expert-layout";
import { Glm52StockStreamedExpertExecutor } from "./glm52-streamed-experts";

export interface Glm52ExpertRuntimeOptions {
  readonly budgetBytes: number;
  /** Dense/shared/router + KV/transient/allocator/Bun/OS reserve. */
  readonly fixedBytes: number;
  readonly workingSlots?: number;
  readonly maxSlotsPerLayer?: number;
  readonly pinned?: ReadonlyArray<{ layer: number; expertId: number }>;
  readonly workers?: number;
  readonly noCache?: boolean;
  readonly libraryPath?: string;
  readonly decodeKernel?: "stock" | "metal";
  /** Native MTP verify width. The int8 working tier reserves topK*gamma
   *  scratch slots plus one persistent LRU slot. */
  readonly mtpDraftTokens?: number;
  readonly enableMtp?: boolean;
}

export interface Glm52MtpExpertRuntime {
  readonly plan: ExpertResidencyPlan;
  readonly store: ExpertIOSlabStore;
  readonly manager: ExpertResidencyManager;
  readonly executor: Glm52StockStreamedExpertExecutor;
  readonly slotBytes: number;
  readonly layer: number;
}

export class Glm52ExpertRuntime {
  readonly plan: ExpertResidencyPlan;
  readonly store: ExpertIOSlabStore;
  readonly manager: ExpertResidencyManager;
  readonly executor: Glm52StockStreamedExpertExecutor;
  readonly slotBytes: number;
  readonly sparseLayerIds: readonly number[];
  readonly mtp: Glm52MtpExpertRuntime | null;
  readonly mtpExecutor: Glm52StockStreamedExpertExecutor | null;
  #layouts = new Map<string, Glm52ExpertSlotLayout>();
  #mtpLayouts = new Map<string, Glm52ExpertSlotLayout>();

  private constructor(
    plan: ExpertResidencyPlan,
    store: ExpertIOSlabStore,
    manager: ExpertResidencyManager,
    executor: Glm52StockStreamedExpertExecutor,
    slotBytes: number,
    sparseLayerIds: readonly number[],
    mtp: Glm52MtpExpertRuntime | null,
  ) {
    this.plan = plan;
    this.store = store;
    this.manager = manager;
    this.executor = executor;
    this.slotBytes = slotBytes;
    this.sparseLayerIds = sparseLayerIds;
    this.mtp = mtp;
    this.mtpExecutor = mtp?.executor ?? null;
  }

  static open(
    modelDir: string,
    config: Glm52Config,
    options: Glm52ExpertRuntimeOptions,
  ): Glm52ExpertRuntime {
    const container = ColibriGlm52Container.open(modelDir);
    const sparseLayerIds = Array.from(
      { length: config.numHiddenLayers - config.firstKDenseReplace },
      (_, index) => config.firstKDenseReplace + index,
    );
    if (sparseLayerIds.length === 0)
      throw new Error("GLM expert residency requires at least one sparse layer");
    const representative = buildGlm52ExpertSlotLayout(
      container,
      config,
      sparseLayerIds[0]!,
      0,
    );
    const capabilities = container.capabilities(config);
    const mtpLayer = config.numHiddenLayers;
    const mtpRepresentative = capabilities.hasMtp && options.enableMtp !== false
      ? buildGlm52ExpertSlotLayout(container, config, mtpLayer, 0)
      : null;
    const mtpDraftTokens = options.mtpDraftTokens ?? 3;
    if (!Number.isSafeInteger(mtpDraftTokens) || mtpDraftTokens < 1)
      throw new Error("GLM MTP draft token count must be a positive safe integer");
    const mtpWorkingSlots = mtpRepresentative
      ? Math.min(
          config.numRoutedExperts,
          config.numExpertsPerToken * mtpDraftTokens,
        )
      : 0;
    const mtpPlan = mtpRepresentative
      ? planExpertResidency({
          // physicalFootprint() is process-wide, not slab-local. Give the
          // auxiliary manager the same global ceiling as the main manager;
          // the main plan below is the single source of accounting truth and
          // includes this MTP slab in fixedBytes.
          budgetBytes: options.budgetBytes,
          fixedBytes: 0,
          slotBytes: mtpRepresentative.slotBytes,
          sparseLayers: 1,
          workingSlots: mtpWorkingSlots,
          maxSlotsPerLayer: 1,
        })
      : null;
    const pinned = options.pinned ?? [];
    const plan = planExpertResidency({
      budgetBytes: options.budgetBytes,
      fixedBytes: options.fixedBytes + (mtpPlan?.slabBytes ?? 0),
      slotBytes: representative.slotBytes,
      sparseLayers: sparseLayerIds.length,
      workingSlots: options.workingSlots,
      pinnedExperts: pinned.length,
      maxSlotsPerLayer: options.maxSlotsPerLayer,
    });
    const mainFiles = container.files
      .filter((file) => file.family === "main")
      .map((file) => file.path);
    const fileIndex = new Map(
      mainFiles.map((path, index) => [path, index]),
    );
    const mtpFiles = container.files
      .filter((file) => file.family === "mtp")
      .map((file) => file.path);
    const mtpFileIndex = new Map(
      mtpFiles.map((path, index) => [path, index]),
    );
    const layouts = new Map<string, Glm52ExpertSlotLayout>();
    const layout = (layer: number, expertId: number): Glm52ExpertSlotLayout => {
      const key = `${layer}:${expertId}`;
      let value = layouts.get(key);
      if (!value) {
        value = buildGlm52ExpertSlotLayout(
          container,
          config,
          layer,
          expertId,
        );
        if (value.slotBytes !== representative.slotBytes)
          throw new Error(
            `${key}: expert slot ${value.slotBytes} != ${representative.slotBytes}`,
          );
        layouts.set(key, value);
      }
      return value;
    };
    const store = new ExpertIOSlabStore(mainFiles, {
      slots: plan.totalSlots,
      slotBytes: representative.slotBytes,
      workers: options.workers,
      noCache: options.noCache,
      libraryPath: options.libraryPath,
    });
    let mtpStore: ExpertIOSlabStore | null = null;
    let executor: Glm52StockStreamedExpertExecutor | null = null;
    let mtpExecutor: Glm52StockStreamedExpertExecutor | null = null;
    try {
      if (mtpPlan && mtpRepresentative) {
        mtpStore = new ExpertIOSlabStore(mtpFiles, {
          slots: mtpPlan.totalSlots,
          slotBytes: mtpRepresentative.slotBytes,
          workers: options.workers,
          noCache: options.noCache,
          libraryPath: options.libraryPath,
        });
      }
      const manager = new ExpertResidencyManager({
        plan,
        sparseLayerIds,
        backend: store,
        pinned,
        locate: (layer, expertId) => {
          const value = layout(layer, expertId);
          return {
            layer,
            expertId,
            segments: value.segments.map((segment) => {
              const file = fileIndex.get(segment.file);
              if (file === undefined)
                throw new Error(`${layer}:${expertId}: non-main expert shard`);
              return {
                file,
                offset: segment.sourceOffset,
                destination: segment.destinationOffset,
                length: segment.length,
              };
            }),
          };
        },
      });
      executor = new Glm52StockStreamedExpertExecutor({
        manager,
        store,
        layout,
        hiddenSize: config.hiddenSize,
        // G1/G3 quiet-machine selection: custom Metal wins eligible M=1
        // expert jobs; the hybrid executor falls back to stock MLX for
        // multi-row ragged/prefill jobs. Keep an explicit "stock" override
        // for oracle and diagnostic runs.
        decodeKernel: options.decodeKernel ?? "metal",
      });
      let mtp: Glm52MtpExpertRuntime | null = null;
      const mtpLayouts = new Map<string, Glm52ExpertSlotLayout>();
      if (mtpPlan && mtpRepresentative && mtpStore) {
        const mtpLayout = (
          layer: number,
          expertId: number,
        ): Glm52ExpertSlotLayout => {
          if (layer !== mtpLayer)
            throw new Error(`MTP expert layer ${layer} != ${mtpLayer}`);
          const key = `${layer}:${expertId}`;
          let value = mtpLayouts.get(key);
          if (!value) {
            value = buildGlm52ExpertSlotLayout(
              container,
              config,
              layer,
              expertId,
            );
            if (value.bits !== 8)
              throw new Error(`${key}: MTP expert must be signed int8`);
            if (value.slotBytes !== mtpRepresentative.slotBytes) {
              throw new Error(
                `${key}: MTP expert slot ${value.slotBytes} != ` +
                `${mtpRepresentative.slotBytes}`,
              );
            }
            mtpLayouts.set(key, value);
          }
          return value;
        };
        const mtpManager = new ExpertResidencyManager({
          plan: mtpPlan,
          sparseLayerIds: [mtpLayer],
          backend: mtpStore,
          locate: (layer, expertId) => {
            const value = mtpLayout(layer, expertId);
            return {
              layer,
              expertId,
              segments: value.segments.map((segment) => {
                const file = mtpFileIndex.get(segment.file);
                if (file === undefined)
                  throw new Error(`${layer}:${expertId}: non-MTP expert shard`);
                return {
                  file,
                  offset: segment.sourceOffset,
                  destination: segment.destinationOffset,
                  length: segment.length,
                };
              }),
            };
          },
        });
        mtpExecutor = new Glm52StockStreamedExpertExecutor({
          manager: mtpManager,
          store: mtpStore,
          layout: mtpLayout,
          hiddenSize: config.hiddenSize,
          // The signed-Q8 custom kernel is one fixed family for both S=1
          // drafts and S>1 accepted-token absorption (SPEC_PIN equivalent).
          // Preserve the explicit stock-kernel diagnostic escape hatch across
          // both the target and MTP tiers.
          decodeKernel: options.decodeKernel ?? "metal",
        });
        mtp = {
          plan: mtpPlan,
          store: mtpStore,
          manager: mtpManager,
          executor: mtpExecutor,
          slotBytes: mtpRepresentative.slotBytes,
          layer: mtpLayer,
        };
      }
      const runtime = new Glm52ExpertRuntime(
        plan,
        store,
        manager,
        executor,
        representative.slotBytes,
        Object.freeze(sparseLayerIds),
        mtp,
      );
      runtime.#layouts = layouts;
      runtime.#mtpLayouts = mtpLayouts;
      return runtime;
    } catch (error) {
      mtpExecutor?.dispose();
      executor?.dispose();
      mtpStore?.close();
      store.close();
      throw error;
    }
  }

  close(): void {
    this.mtp?.executor.dispose();
    this.mtp?.store.close();
    this.executor.dispose();
    this.store.close();
  }
}
