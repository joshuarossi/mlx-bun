

/**
 * The subset of the canonical expert-slot layout consumed by the decode
 * kernels. Offsets are bytes from the beginning of one aligned residency slot.
 * Q4 (packed nibbles) and Q8 (int8) slots share this shape.
 */
export interface Glm52CanonicalMetalLayout {
  readonly hiddenSize: number;
  readonly intermediateSize: number;
  readonly slotBytes: number;
  readonly downWeightOffset: number;
  readonly gateWeightOffset: number;
  readonly upWeightOffset: number;
  readonly downScaleOffset: number;
  readonly gateScaleOffset: number;
  readonly upScaleOffset: number;
}

export type Glm52CanonicalQ4MetalLayout = Glm52CanonicalMetalLayout;
export type Glm52CanonicalQ8MetalLayout = Glm52CanonicalMetalLayout;

export function validateRange(
  offset: number,
  byteLength: number,
  slotBytes: number,
  label: string,
): void {
  if (!Number.isSafeInteger(offset) || offset < 0)
    throw new Error(`${label} offset must be a non-negative safe integer`);
  if (!Number.isSafeInteger(byteLength) || byteLength < 0)
    throw new Error(`${label} length must be a non-negative safe integer`);
  if (offset + byteLength > slotBytes)
    throw new Error(`${label} exceeds the canonical expert slot`);
}

export const GLM52_EXPERT_SLOT_ALIGNMENT = 16 * 1024;
