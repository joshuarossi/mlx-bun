import {
type Glm52ExpertSlotLayout
} from "./expert-layout";


/**
 * Resolve and validate a production-compatible Q4 descriptor from the
 * artifact-driven slot catalog. Colibri's main routed experts use one F32
 * scale per output row (`groupSize === null`) and affine zero-point 8.
 */
export function glm52CanonicalQ4MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ4MetalLayout {
  if (layout.bits !== 4)
    throw new Error("GLM Metal streamed experts require a Q4 slot");
  if (layout.groupSize !== null) {
    throw new Error(
      "GLM Metal streamed experts currently require per-row Q4 scales",
    );
  }

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
    const weightBytes = outputRows * inputColumns / 2;
    const scaleBytes = outputRows * 4;
    if (projection.tensor.weight.byteLength !== weightBytes) {
      throw new Error(
        `${projection.projection} Q4 weight bytes must be ${weightBytes}`,
      );
    }
    if (projection.tensor.scales.byteLength !== scaleBytes) {
      throw new Error(
        `${projection.projection} Q4 scale bytes must be ${scaleBytes}`,
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
    if ((projection.weightOffset & 3) !== 0)
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


/** Resolve the signed two's-complement, per-output-row int8 layout used by
 * GLM-5.2's native MTP routed experts. */
export function glm52CanonicalQ8MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ8MetalLayout {
  if (layout.bits !== 8)
    throw new Error("GLM MTP Metal streamed experts require a Q8 slot");
  if (layout.groupSize !== null)
    throw new Error("GLM MTP Metal streamed experts require per-row Q8 scales");

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
    const weightBytes = outputRows * inputColumns;
    const scaleBytes = outputRows * 4;
    if (projection.tensor.weight.byteLength !== weightBytes)
      throw new Error(
        `${projection.projection} Q8 weight bytes must be ${weightBytes}`,
      );
    if (projection.tensor.scales.byteLength !== scaleBytes)
      throw new Error(
        `${projection.projection} Q8 scale bytes must be ${scaleBytes}`,
      );
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

import { positiveInteger,validateRange,type Glm52CanonicalQ4MetalLayout,type Glm52CanonicalQ8MetalLayout } from "../../kernels/glm52/layout";
