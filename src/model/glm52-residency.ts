import { ExpertIOSlabStore } from "../expert-io";
import {
  ExpertUsageLedger,
  planExpertAutoPins,
  selectExpertLfruCandidates,
  type ExpertAutoPinPlan,
} from "../expert-usage";
import { join } from "node:path";
import {
  ExpertResidencyManager,
  DEFAULT_EXPERT_WORKING_SLOTS,
  planExpertResidency,
  type ExpertRepinEvent,
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
  /** Persistent Colibri-compatible route profile. Defaults to
   * `<modelDir>/.coli_usage`; false disables persistence. */
  readonly usagePath?: string | false;
  /** Opt-in G6 candidate. Explicit `pinned` entries take precedence. */
  readonly autoPin?: boolean;
  /** Opt-in G6 candidate: adapt at generation safe points, max four swaps. */
  readonly liveRepin?: boolean;
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
  readonly usage: ExpertUsageLedger | null;
  readonly autoPin: ExpertAutoPinPlan | null;
  lastRepin: readonly ExpertRepinEvent[] = Object.freeze([]);
  #liveRepin: boolean;
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
    usage: ExpertUsageLedger | null,
    autoPin: ExpertAutoPinPlan | null,
    liveRepin: boolean,
  ) {
    this.plan = plan;
    this.store = store;
    this.manager = manager;
    this.executor = executor;
    this.slotBytes = slotBytes;
    this.sparseLayerIds = sparseLayerIds;
    this.mtp = mtp;
    this.mtpExecutor = mtp?.executor ?? null;
    this.usage = usage;
    this.autoPin = autoPin;
    this.#liveRepin = liveRepin;
  }

  static async open(
    modelDir: string,
    config: Glm52Config,
    options: Glm52ExpertRuntimeOptions,
  ): Promise<Glm52ExpertRuntime> {
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
    const usagePath = options.usagePath === false
      ? null
      : options.usagePath ?? join(modelDir, ".coli_usage");
    const usage = usagePath === null
      ? null
      : ExpertUsageLedger.open({
          path: usagePath,
          layers: mtpRepresentative
            ? [...sparseLayerIds, mtpLayer]
            : sparseLayerIds,
          expertsPerLayer: config.numRoutedExperts,
          onWarning: (message) => console.warn(message),
        });
    if ((options.autoPin || options.liveRepin) && !usage)
      throw new Error("GLM expert learning policies require persistent usage");
    const autoPin = options.autoPin && options.pinned === undefined && usage
      ? planExpertAutoPins({
          ledger: usage,
          residentTierBudgetBytes: Math.max(
            0,
            options.budgetBytes - options.fixedBytes -
            (options.workingSlots ?? DEFAULT_EXPERT_WORKING_SLOTS) *
              representative.slotBytes -
            mtpWorkingSlots * (mtpRepresentative?.slotBytes ?? 0),
          ),
          mandatoryResidentBytes:
            sparseLayerIds.length * representative.slotBytes +
            (mtpRepresentative?.slotBytes ?? 0),
          slotBytes: (layer) => {
            if (layer === mtpLayer && mtpRepresentative)
              return mtpRepresentative.slotBytes;
            if (sparseLayerIds.includes(layer)) return representative.slotBytes;
            throw new RangeError(`auto-pin layer ${layer} is not managed`);
          },
        })
      : null;
    const autoPins = autoPin?.pins ?? [];
    const pinned = options.pinned ?? autoPins
      .filter((item) => item.layer !== mtpLayer)
      .map(({ layer, expertId }) => ({ layer, expertId }));
    const mtpPinned = autoPins
      .filter((item) => item.layer === mtpLayer)
      .map(({ layer, expertId }) => ({ layer, expertId }));
    for (const item of pinned) {
      if (!sparseLayerIds.includes(item.layer) || item.expertId < 0 ||
          item.expertId >= config.numRoutedExperts ||
          !Number.isSafeInteger(item.expertId)) {
        throw new RangeError(`invalid pinned expert ${item.layer}:${item.expertId}`);
      }
    }
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
          pinnedExperts: mtpPinned.length,
          maxSlotsPerLayer: 1,
        })
      : null;
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
      // These slots are the bounded resident/working expert cache, not an
      // expendable file cache. Letting macOS compress them turns every warm
      // forward into decompression churn and invalidates the G5 equation.
      wireSlots: true,
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
          wireSlots: true,
          libraryPath: options.libraryPath,
        });
      }
      const manager = new ExpertResidencyManager({
        plan,
        sparseLayerIds,
        backend: store,
        pinned,
        usage: usage ?? undefined,
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
          pinned: mtpPinned,
          usage: usage ?? undefined,
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
        usage,
        autoPin,
        options.liveRepin === true,
      );
      await manager.preloadPinned();
      await mtp?.manager.preloadPinned();
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
    let flushError: unknown = null;
    try {
      this.flushUsage();
    } catch (error) {
      flushError = error;
    }
    this.mtp?.executor.dispose();
    this.mtp?.store.close();
    this.executor.dispose();
    this.store.close();
    if (flushError) throw flushError;
  }

  /** Generation safe-point: atomically publish target + MTP route counts. */
  flushUsage(): void {
    this.usage?.flush();
  }

  /** Turn boundary: adapt the shared target/MTP tier, decay heat, then save. */
  async finishUsage(): Promise<void> {
    if (!this.#liveRepin || !this.usage) {
      this.lastRepin = Object.freeze([]);
      this.flushUsage();
      return;
    }
    const candidates = [
      ...this.manager.repinCandidates().map((candidate) => ({
        manager: this.manager,
        candidate,
      })),
      ...(this.mtp?.manager.repinCandidates() ?? []).map((candidate) => ({
        manager: this.mtp!.manager,
        candidate,
      })),
    ];
    const selected = new Set(selectExpertLfruCandidates(
      candidates.map((item) => item.candidate),
      4,
    ));
    const planned = candidates.filter((item) => selected.has(item.candidate));
    const events: ExpertRepinEvent[] = [];
    let repinError: unknown = null;
    try {
      for (const item of planned)
        events.push(await item.manager.applyRepin(item.candidate));
    } catch (error) {
      repinError = error;
    }
    this.lastRepin = Object.freeze(events.slice());
    this.usage.decayHeat();
    try {
      this.flushUsage();
    } catch (flushError) {
      if (repinError) {
        throw new AggregateError(
          [repinError, flushError],
          "live repin and expert usage flush both failed",
        );
      }
      throw flushError;
    }
    if (repinError) throw repinError;
  }
}
