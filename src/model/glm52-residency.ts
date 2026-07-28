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
}

export class Glm52ExpertRuntime {
  readonly plan: ExpertResidencyPlan;
  readonly store: ExpertIOSlabStore;
  readonly manager: ExpertResidencyManager;
  readonly executor: Glm52StockStreamedExpertExecutor;
  readonly slotBytes: number;
  readonly sparseLayerIds: readonly number[];
  #layouts = new Map<string, Glm52ExpertSlotLayout>();

  private constructor(
    plan: ExpertResidencyPlan,
    store: ExpertIOSlabStore,
    manager: ExpertResidencyManager,
    executor: Glm52StockStreamedExpertExecutor,
    slotBytes: number,
    sparseLayerIds: readonly number[],
  ) {
    this.plan = plan;
    this.store = store;
    this.manager = manager;
    this.executor = executor;
    this.slotBytes = slotBytes;
    this.sparseLayerIds = sparseLayerIds;
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
    const pinned = options.pinned ?? [];
    const plan = planExpertResidency({
      budgetBytes: options.budgetBytes,
      fixedBytes: options.fixedBytes,
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
    try {
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
      const executor = new Glm52StockStreamedExpertExecutor({
        manager,
        store,
        layout,
        hiddenSize: config.hiddenSize,
        decodeKernel: options.decodeKernel,
      });
      const runtime = new Glm52ExpertRuntime(
        plan,
        store,
        manager,
        executor,
        representative.slotBytes,
        Object.freeze(sparseLayerIds),
      );
      runtime.#layouts = layouts;
      return runtime;
    } catch (error) {
      store.close();
      throw error;
    }
  }

  close(): void {
    this.executor.dispose();
    this.store.close();
  }
}
