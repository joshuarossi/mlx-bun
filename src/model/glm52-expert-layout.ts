import type {
  ColibriGlm52Container,
  ColibriQuantTensorInfo,
  ColibriTensorInfo,
} from "./glm52-container";
import type { Glm52Config } from "./glm52-config";

export const GLM52_EXPERT_SLOT_ALIGNMENT = 16 * 1024;
export const GLM52_EXPERT_MAX_READ_SEGMENTS = 8;

export type Glm52ExpertProjection = "down" | "gate" | "up";

export interface Glm52ExpertProjectionLayout {
  readonly projection: Glm52ExpertProjection;
  readonly tensor: ColibriQuantTensorInfo;
  readonly weightOffset: number;
  readonly scaleOffset: number;
}

export interface Glm52ExpertReadSegment {
  readonly file: string;
  readonly sourceOffset: number;
  readonly destinationOffset: number;
  readonly length: number;
}

export interface Glm52ExpertSlotLayout {
  readonly layer: number;
  readonly expertId: number;
  readonly bits: 4 | 8;
  readonly groupSize: number | null;
  readonly alignment: number;
  readonly weightBytes: number;
  readonly scaleBytes: number;
  readonly scaleOffset: number;
  readonly payloadBytes: number;
  readonly slotBytes: number;
  readonly projections: Readonly<Record<
    Glm52ExpertProjection,
    Glm52ExpertProjectionLayout
  >>;
  /**
   * Positioned reads in canonical slot order. Adjacent tensor reads are
   * coalesced only when both their source and destination ranges are adjacent
   * in the same shard.
   */
  readonly segments: readonly Glm52ExpertReadSegment[];
}

type ExpertGeometry = Pick<
  Glm52Config,
  "hiddenSize" | "moeIntermediateSize" | "numRoutedExperts"
>;

interface PrimitiveRead {
  readonly tensor: ColibriTensorInfo;
  readonly destinationOffset: number;
}

function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`${label} must be a positive safe integer`);
  return value;
}

function alignUp(value: number, alignment: number): number {
  const result = Math.ceil(value / alignment) * alignment;
  if (!Number.isSafeInteger(result))
    throw new Error("expert slot size exceeds the safe integer range");
  return result;
}

function coalesceReads(
  reads: readonly PrimitiveRead[],
): Glm52ExpertReadSegment[] {
  const segments: Glm52ExpertReadSegment[] = [];
  for (const read of reads) {
    const next: Glm52ExpertReadSegment = {
      file: read.tensor.file,
      sourceOffset: read.tensor.absoluteBegin,
      destinationOffset: read.destinationOffset,
      length: read.tensor.byteLength,
    };
    const prior = segments.at(-1);
    if (
      prior &&
      prior.file === next.file &&
      prior.sourceOffset + prior.length === next.sourceOffset &&
      prior.destinationOffset + prior.length === next.destinationOffset
    ) {
      segments[segments.length - 1] = {
        ...prior,
        length: prior.length + next.length,
      };
    } else {
      segments.push(next);
    }
  }
  return segments;
}

/**
 * Describe one routed expert as a fixed aligned native slot without opening or
 * mapping any tensor payload.
 *
 * The slot order is deliberately independent of safetensors header order:
 * down/gate/up packed weights followed by down/gate/up F32 scales. Every
 * pointer-addressed component begins at a 16 KiB boundary: MLX/Metal cannot
 * safely no-copy-wrap a merely sub-page-aligned host pointer. Source-adjacent
 * components still coalesce when the required padding is zero.
 */
export function buildGlm52ExpertSlotLayout(
  container: ColibriGlm52Container,
  config: ExpertGeometry,
  layer: number,
  expertId: number,
  alignment = GLM52_EXPERT_SLOT_ALIGNMENT,
): Glm52ExpertSlotLayout {
  positiveInteger(config.hiddenSize, "hidden size");
  positiveInteger(config.moeIntermediateSize, "MoE intermediate size");
  positiveInteger(config.numRoutedExperts, "routed expert count");
  if (!Number.isSafeInteger(layer) || layer < 0)
    throw new Error("expert layer must be a non-negative safe integer");
  if (
    !Number.isSafeInteger(expertId) ||
    expertId < 0 ||
    expertId >= config.numRoutedExperts
  ) {
    throw new Error(
      `expert ID ${expertId} is outside [0,${config.numRoutedExperts})`,
    );
  }
  if (
    !Number.isSafeInteger(alignment) ||
    alignment < 1 ||
    (alignment & (alignment - 1)) !== 0
  ) {
    throw new Error("expert slot alignment must be a positive power of two");
  }

  const prefix = `model.layers.${layer}.mlp.experts.${expertId}`;
  const dimensions: Record<
    Glm52ExpertProjection,
    readonly [outputRows: number, inputColumns: number]
  > = {
    down: [config.hiddenSize, config.moeIntermediateSize],
    gate: [config.moeIntermediateSize, config.hiddenSize],
    up: [config.moeIntermediateSize, config.hiddenSize],
  };
  const suffix: Record<Glm52ExpertProjection, string> = {
    down: "down_proj",
    gate: "gate_proj",
    up: "up_proj",
  };
  const order: readonly Glm52ExpertProjection[] = ["down", "gate", "up"];

  const tensors = {} as Record<
    Glm52ExpertProjection,
    ColibriQuantTensorInfo
  >;
  for (const projection of order) {
    const [outputRows, inputColumns] = dimensions[projection];
    tensors[projection] = container.quantized(
      `${prefix}.${suffix[projection]}.weight`,
      outputRows,
      inputColumns,
    );
  }

  const bits = tensors.down.bits;
  const groupSize = tensors.down.groupSize;
  for (const projection of order) {
    const tensor = tensors[projection];
    if (tensor.bits !== bits || tensor.groupSize !== groupSize) {
      throw new Error(
        `${prefix}: routed expert projections must use one quantization layout`,
      );
    }
  }

  let weightBytes = 0;
  let cursor = 0;
  const weightOffsets = {} as Record<Glm52ExpertProjection, number>;
  for (const projection of order) {
    cursor = alignUp(cursor, alignment);
    weightOffsets[projection] = cursor;
    weightBytes += tensors[projection].weight.byteLength;
    cursor += tensors[projection].weight.byteLength;
  }
  if (!Number.isSafeInteger(weightBytes))
    throw new Error(`${prefix}: expert weight bytes exceed the safe integer range`);

  const scaleOffset = alignUp(cursor, alignment);
  cursor = scaleOffset;
  let scaleBytes = 0;
  const scaleOffsets = {} as Record<Glm52ExpertProjection, number>;
  for (const projection of order) {
    cursor = alignUp(cursor, alignment);
    scaleOffsets[projection] = cursor;
    scaleBytes += tensors[projection].scales.byteLength;
    cursor += tensors[projection].scales.byteLength;
  }
  const payloadBytes = cursor;
  if (!Number.isSafeInteger(payloadBytes))
    throw new Error(`${prefix}: expert payload bytes exceed the safe integer range`);
  const slotBytes = alignUp(payloadBytes, alignment);

  const primitiveReads: PrimitiveRead[] = [
    ...order.map((projection) => ({
      tensor: tensors[projection].weight,
      destinationOffset: weightOffsets[projection],
    })),
    ...order.map((projection) => ({
      tensor: tensors[projection].scales,
      destinationOffset: scaleOffsets[projection],
    })),
  ];
  const segments = coalesceReads(primitiveReads);
  if (segments.length > GLM52_EXPERT_MAX_READ_SEGMENTS) {
    throw new Error(
      `${prefix}: expert requires ${segments.length} read segments; maximum is ` +
      `${GLM52_EXPERT_MAX_READ_SEGMENTS}`,
    );
  }

  const projections = {} as Record<
    Glm52ExpertProjection,
    Glm52ExpertProjectionLayout
  >;
  for (const projection of order) {
    projections[projection] = {
      projection,
      tensor: tensors[projection],
      weightOffset: weightOffsets[projection],
      scaleOffset: scaleOffsets[projection],
    };
  }

  return {
    layer,
    expertId,
    bits,
    groupSize,
    alignment,
    weightBytes,
    scaleBytes,
    scaleOffset,
    payloadBytes,
    slotBytes,
    projections,
    segments,
  };
}
