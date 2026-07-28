import { ExpertIOSlabStore } from "../expert-io";
import {
  ExpertResidencyManager,
  type ExpertResidencyLeaseEntry,
} from "../expert-residency";
import { MlxArray, gpuStream } from "../mlx/array";
import { Dtype, synchronize } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type {
  Glm52ExpertProjectionLayout,
  Glm52ExpertSlotLayout,
} from "./glm52-expert-layout";
import type {
  Glm52MoeBatchPlan,
  Glm52MoeExpertJob,
} from "./glm52-moe";
import {
  Glm52CanonicalQ4MetalExecutor,
  glm52CanonicalQ4MetalLayout,
  glm52CanonicalQ4SlotView,
} from "./glm52-streamed-metal";

export interface Glm52ExpertExecutionArgs {
  readonly layer: number;
  readonly input: MlxArray;
  readonly plan: Glm52MoeBatchPlan;
  readonly shared: MlxArray | null;
}

export interface Glm52ExpertExecutionBackend {
  execute(args: Glm52ExpertExecutionArgs): Promise<MlxArray>;
}

export interface Glm52StreamedExpertExecutorOptions {
  readonly manager: ExpertResidencyManager;
  readonly store: ExpertIOSlabStore;
  readonly layout: (layer: number, expertId: number) => Glm52ExpertSlotLayout;
  readonly hiddenSize: number;
  /** Explicit candidate selection; stock remains default until the G1 matrix. */
  readonly decodeKernel?: "stock" | "metal";
}

interface MaterializedJob {
  readonly job: Glm52MoeExpertJob;
  readonly output: MlxArray;
}

function projectionDimensions(
  projection: Glm52ExpertProjectionLayout,
): readonly [outputRows: number, inputColumns: number] {
  return [
    projection.tensor.outputRows,
    projection.tensor.inputColumns,
  ];
}

/**
 * Correctness-first stock MLX consumer for a canonical Colibri expert slot.
 * Packed Q4 bytes are already in MLX's little-endian uint32 lane order.
 */
function slotLinear(
  store: ExpertIOSlabStore,
  lease: ExpertResidencyLeaseEntry,
  layout: Glm52ExpertSlotLayout,
  projection: Glm52ExpertProjectionLayout,
  input: MlxArray,
): MlxArray {
  const [outputRows, inputColumns] = projectionDimensions(projection);
  const base = store.pointer(lease.slot, lease.generation);
  if ((base + projection.weightOffset) % layout.alignment !== 0 ||
      (base + projection.scaleOffset) % layout.alignment !== 0) {
    throw new Error(
      `${projection.projection}: streamed MLX pointer is not ` +
      `${layout.alignment}-byte aligned`,
    );
  }
  if (layout.bits === 4) {
    const rowBytes = Math.ceil(inputColumns / 2);
    if (rowBytes % 4 !== 0)
      throw new Error("streamed Q4 projection row must occupy whole uint32 lanes");
    const packed = MlxArray.fromPointer(
      base + projection.weightOffset,
      [outputRows, rowBytes / 4],
      Dtype.uint32,
    );
    const scaleGroups =
      projection.tensor.scales.byteLength / 4 / outputRows;
    if (!Number.isSafeInteger(scaleGroups) || scaleGroups < 1)
      throw new Error("streamed Q4 projection has invalid scale geometry");
    const rawScales = MlxArray.fromPointer(
      base + projection.scaleOffset,
      [outputRows, scaleGroups],
      Dtype.float32,
    );
    let scales = rawScales;
    let groupSize = layout.groupSize ?? inputColumns;
    if (layout.groupSize === null && inputColumns > 32) {
      if (inputColumns % 32 !== 0)
        throw new Error("per-row streamed Q4 requires a 32-divisible input width");
      groupSize = 32;
      const zeros = ops.zeros(
        [outputRows, inputColumns / groupSize],
        Dtype.float32,
      );
      scales = ops.add(rawScales, zeros);
      zeros.dispose();
    }
    const biases = ops.mulScalar(scales, -8);
    const output = ops.quantizedMatmul(
      input,
      packed,
      scales,
      biases,
      { bits: 4, groupSize, mode: "affine" },
      true,
    );
    packed.dispose();
    rawScales.dispose();
    if (scales !== rawScales) scales.dispose();
    biases.dispose();
    return output;
  }

  // MTP uses signed two's-complement Q8. G4 will replace this materializing
  // reference path with its fixed draft/verify kernel family.
  if (layout.groupSize !== null)
    throw new Error("streamed Q8 grouped scales are unsupported");
  const packed = MlxArray.fromPointer(
    base + projection.weightOffset,
    [outputRows, inputColumns],
    Dtype.int8,
  );
  const rawScales = MlxArray.fromPointer(
    base + projection.scaleOffset,
    [outputRows, 1],
    Dtype.float32,
  );
  const values = packed.astype(Dtype.float32);
  const zeros = ops.zeros([outputRows, inputColumns], Dtype.float32);
  const scales = ops.add(rawScales, zeros);
  const weights = ops.mul(values, scales);
  const transposed = ops.transposeAxes(weights, [1, 0]);
  const output = ops.matmul(input, transposed);
  packed.dispose();
  rawScales.dispose();
  values.dispose();
  zeros.dispose();
  scales.dispose();
  weights.dispose();
  transposed.dispose();
  return output;
}

function slotSwiGlu(
  store: ExpertIOSlabStore,
  lease: ExpertResidencyLeaseEntry,
  layout: Glm52ExpertSlotLayout,
  input: MlxArray,
): MlxArray {
  let gate: MlxArray | null = null;
  let up: MlxArray | null = null;
  let activated: MlxArray | null = null;
  let product: MlxArray | null = null;
  try {
    gate = slotLinear(
      store, lease, layout, layout.projections.gate, input,
    );
    up = slotLinear(
      store, lease, layout, layout.projections.up, input,
    );
    activated = ops.silu(gate);
    product = ops.mul(activated, up);
    return slotLinear(
      store, lease, layout, layout.projections.down, product,
    );
  } finally {
    gate?.dispose();
    up?.dispose();
    activated?.dispose();
    product?.dispose();
  }
}

/**
 * Stable batch-union executor. Resident graphs and the shared expert are
 * submitted before miss reads; every wave is materialized and fenced before
 * its scratch slots are promoted/reused.
 */
export class Glm52StockStreamedExpertExecutor
implements Glm52ExpertExecutionBackend {
  readonly manager: ExpertResidencyManager;
  readonly store: ExpertIOSlabStore;
  readonly hiddenSize: number;
  #layout: Glm52StreamedExpertExecutorOptions["layout"];
  #metal: Glm52CanonicalQ4MetalExecutor | null;

  constructor(options: Glm52StreamedExpertExecutorOptions) {
    this.manager = options.manager;
    this.store = options.store;
    this.#layout = options.layout;
    this.hiddenSize = options.hiddenSize;
    this.#metal = options.decodeKernel === "metal"
      ? new Glm52CanonicalQ4MetalExecutor()
      : null;
  }

  async execute(args: Glm52ExpertExecutionArgs): Promise<MlxArray> {
    const [batch, tokens, hidden] = args.input.shape;
    if (args.input.shape.length !== 3 || hidden !== this.hiddenSize)
      throw new Error(
        `streamed GLM experts require [B,T,${this.hiddenSize}] input`,
      );
    const rowCount = batch! * tokens!;
    if (args.plan.routes.length !== rowCount)
      throw new Error(
        `streamed GLM plan has ${args.plan.routes.length} rows; input has ${rowCount}`,
      );

    const flattened = ops.reshape(args.input, [rowCount, this.hiddenSize]);
    const sharedFlat = args.shared
      ? ops.reshape(args.shared, [rowCount, this.hiddenSize])
      : null;
    const materialized = new Map<number, MaterializedJob>();
    let sharedSubmitted = false;
    try {
      for (const wave of args.plan.waves) {
        const jobs = new Map(wave.jobs.map((job) => [job.expertId, job]));
        const waveOutputs: MlxArray[] = [];
        let lease = await this.manager.acquireBlock(
          args.layer,
          wave.jobs.map((job) => job.expertId),
          (resident) => {
            for (const entry of resident) {
              const job = jobs.get(entry.expertId)!;
              const output = this.#executeJob(
                flattened,
                job,
                entry,
                this.#layout(args.layer, entry.expertId),
              );
              materialized.set(entry.expertId, { job, output });
              waveOutputs.push(output);
            }
            const submit = sharedFlat && !sharedSubmitted
              ? [...waveOutputs, sharedFlat]
              : waveOutputs;
            if (submit.length) ops.asyncEvalAll(submit);
            if (sharedFlat && !sharedSubmitted) sharedSubmitted = true;
          },
        );
        let releaseAttempted = false;
        try {
          for (const entry of lease.entries) {
            if (entry.hit) continue;
            const job = jobs.get(entry.expertId)!;
            const output = this.#executeJob(
              flattened,
              job,
              entry,
              this.#layout(args.layer, entry.expertId),
            );
            materialized.set(entry.expertId, { job, output });
            waveOutputs.push(output);
          }
          const fence = sharedFlat && !sharedSubmitted
            ? [...waveOutputs, sharedFlat]
            : waveOutputs;
          if (sharedFlat && !sharedSubmitted) sharedSubmitted = true;
          if (fence.length) ops.evalAll(fence);
          synchronize(gpuStream);
          releaseAttempted = true;
          lease.releaseFenced();
        } catch (error) {
          if (releaseAttempted) throw error;
          const cleanupErrors: unknown[] = [];
          try {
            synchronize(gpuStream);
          } catch (cleanupError) {
            cleanupErrors.push(cleanupError);
          }
          if (cleanupErrors.length === 0) {
            releaseAttempted = true;
            try {
              lease.releaseFenced();
            } catch (cleanupError) {
              cleanupErrors.push(cleanupError);
            }
          }
          if (cleanupErrors.length) {
            throw new AggregateError(
              [error, ...cleanupErrors],
              "streamed expert wave failed and fenced cleanup was incomplete",
            );
          }
          throw error;
        }
      }
      this.manager.correctForPressure();
      return this.#compose(
        args.plan,
        materialized,
        sharedFlat,
        [batch!, tokens!, hidden!],
      );
    } finally {
      flattened.dispose();
      sharedFlat?.dispose();
      for (const value of materialized.values()) value.output.dispose();
    }
  }

  #executeJob(
    flattened: MlxArray,
    job: Glm52MoeExpertJob,
    lease: ExpertResidencyLeaseEntry,
    layout: Glm52ExpertSlotLayout,
  ): MlxArray {
    const indices = MlxArray.fromInt32(job.rows, [job.rows.length]);
    let rows: MlxArray | null = null;
    try {
      rows = ops.takeAxis(flattened, indices, 0);
      if (this.#metal && rows.shape[0] === 1) {
        const descriptor = glm52CanonicalQ4MetalLayout(layout);
        const slot = glm52CanonicalQ4SlotView(
          this.store.pointer(lease.slot, lease.generation),
          descriptor,
        );
        try {
          return this.#metal.execute(rows, slot, descriptor);
        } finally {
          slot.dispose();
        }
      }
      return slotSwiGlu(this.store, lease, layout, rows);
    } finally {
      indices.dispose();
      rows?.dispose();
    }
  }

  dispose(): void {
    this.#metal?.dispose();
    this.#metal = null;
  }

  #compose(
    plan: Glm52MoeBatchPlan,
    materialized: ReadonlyMap<number, MaterializedJob>,
    shared: MlxArray | null,
    shape: readonly [number, number, number],
  ): MlxArray {
    const [batch, tokens, hidden] = shape;
    const consumers = new Map<string, { value: MlxArray; index: number }>();
    for (const { job, output } of materialized.values()) {
      for (let index = 0; index < job.rows.length; index++)
        consumers.set(`${job.rows[index]}:${job.ranks[index]}`, {
          value: output,
          index,
        });
    }

    const rows: MlxArray[] = [];
    try {
      for (let row = 0; row < plan.routes.length; row++) {
        const route = plan.routes[row]!;
        let sum: MlxArray | null = null;
        for (let rank = 0; rank < route.indices.length; rank++) {
          const consumer = consumers.get(`${row}:${rank}`);
          if (!consumer)
            throw new Error(`missing streamed output for row ${row} rank ${rank}`);
          const view = consumer.value.slice(
            [consumer.index, 0],
            [consumer.index + 1, hidden],
          );
          const scaled = ops.mulScalar(view, route.executionWeights[rank]!);
          view.dispose();
          if (sum === null) {
            sum = scaled;
          } else {
            const next = ops.add(sum, scaled);
            sum.dispose();
            scaled.dispose();
            sum = next;
          }
        }
        if (shared) {
          const sharedRow = shared.slice([row, 0], [row + 1, hidden]);
          if (sum === null) {
            sum = ops.mulScalar(sharedRow, 1);
          } else {
            const next = ops.add(sum, sharedRow);
            sum.dispose();
            sum = next;
          }
          sharedRow.dispose();
        }
        if (!sum) throw new Error(`streamed GLM row ${row} has no expert output`);
        rows.push(sum);
      }
      const flat = rows.length === 1
        ? rows[0]!
        : ops.concatAxis(rows, 0);
      const output = ops.reshape(flat, [batch, tokens, hidden]);
      flat.dispose();
      return output;
    } finally {
      if (rows.length > 1)
        for (const row of rows) row.dispose();
    }
  }
}
