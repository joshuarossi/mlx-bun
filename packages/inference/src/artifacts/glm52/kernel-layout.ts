import { positiveInteger } from "../../runtime/integers";
import { validateRange, type Glm52CanonicalMetalLayout, type Glm52CanonicalQ4MetalLayout, type Glm52CanonicalQ8MetalLayout } from "../../kernels/glm52/layout";
import { type Glm52ExpertSlotLayout } from "./expert-layout";

/** What differs between the canonical Q4 and Q8 slot layouts: the slot's bit
 *  width, the `Glm52ExpertSlotLayout` rejections' wording, and the element
 *  packing (Q4 packs two weights per byte in uint32 words and checks weight
 *  alignment; Q8 stores one signed int8 per weight). */
interface CanonicalSlotSpec {
  readonly bits: 4 | 8;
  readonly label: "Q4" | "Q8";
  readonly bitsError: string;
  readonly perRowError: string;
  readonly weightsPerByte: 1 | 2;
  readonly weightsMustBeWordAligned: boolean;
}

function resolveCanonicalMetalLayout(
  layout: Glm52ExpertSlotLayout,
  spec: CanonicalSlotSpec,
): Glm52CanonicalMetalLayout {
  if (layout.bits !== spec.bits) throw new Error(spec.bitsError);
  if (layout.groupSize !== null) throw new Error(spec.perRowError);

  const down = layout.projections.down;
  const gate = layout.projections.gate;
  const up = layout.projections.up;
  const hiddenSize = positiveInteger(down.tensor.outputRows, "hidden size");
  const intermediateSize = positiveInteger(
    down.tensor.inputColumns,
    "intermediate size",
  );
  const expected = [
    [gate.tensor.outputRows, intermediateSize, "gate output rows"],
    [gate.tensor.inputColumns, hiddenSize, "gate input columns"],
    [up.tensor.outputRows, intermediateSize, "up output rows"],
    [up.tensor.inputColumns, hiddenSize, "up input columns"],
  ] as const;
  for (const [actual, wanted, label] of expected) {
    if (actual !== wanted)
      throw new Error(`${label} must be ${wanted}, got ${actual}`);
  }

  const slotBytes = positiveInteger(layout.slotBytes, "expert slot bytes");
  for (const [projection, outputRows, inputColumns] of [
    [down, hiddenSize, intermediateSize],
    [gate, intermediateSize, hiddenSize],
    [up, intermediateSize, hiddenSize],
  ] as const) {
    const weightBytes = outputRows * inputColumns / spec.weightsPerByte;
    const scaleBytes = outputRows * 4;
    if (projection.tensor.weight.byteLength !== weightBytes) {
      throw new Error(
        `${projection.projection} ${spec.label} weight bytes must be ${weightBytes}`,
      );
    }
    if (projection.tensor.scales.byteLength !== scaleBytes) {
      throw new Error(
        `${projection.projection} ${spec.label} scale bytes must be ${scaleBytes}`,
      );
    }
    validateRange(
      projection.weightOffset,
      weightBytes,
      slotBytes,
      `${projection.projection} weights`,
    );
    validateRange(
      projection.scaleOffset,
      scaleBytes,
      slotBytes,
      `${projection.projection} scales`,
    );
    if (spec.weightsMustBeWordAligned && (projection.weightOffset & 3) !== 0)
      throw new Error(`${projection.projection} weights must be uint32-aligned`);
    if ((projection.scaleOffset & 3) !== 0)
      throw new Error(`${projection.projection} scales must be F32-aligned`);
  }

  return {
    hiddenSize,
    intermediateSize,
    slotBytes,
    downWeightOffset: down.weightOffset,
    gateWeightOffset: gate.weightOffset,
    upWeightOffset: up.weightOffset,
    downScaleOffset: down.scaleOffset,
    gateScaleOffset: gate.scaleOffset,
    upScaleOffset: up.scaleOffset,
  };
}

/**
 * Resolve and validate a production-compatible Q4 descriptor from the
 * artifact-driven slot catalog. Colibri's main routed experts use one F32
 * scale per output row (`groupSize === null`) and affine zero-point 8.
 */
export function glm52CanonicalQ4MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ4MetalLayout {
  return resolveCanonicalMetalLayout(layout, {
    bits: 4,
    label: "Q4",
    bitsError: "GLM Metal streamed experts require a Q4 slot",
    perRowError: "GLM Metal streamed experts currently require per-row Q4 scales",
    weightsPerByte: 2,
    weightsMustBeWordAligned: true,
  });
}

/** Resolve the signed two's-complement, per-output-row int8 layout used by
 * GLM-5.2's native MTP routed experts. */
export function glm52CanonicalQ8MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ8MetalLayout {
  return resolveCanonicalMetalLayout(layout, {
    bits: 8,
    label: "Q8",
    bitsError: "GLM MTP Metal streamed experts require a Q8 slot",
    perRowError: "GLM MTP Metal streamed experts require per-row Q8 scales",
    weightsPerByte: 1,
    weightsMustBeWordAligned: false,
  });
}
