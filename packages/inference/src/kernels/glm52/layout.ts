

/**
 * The subset of the canonical expert-slot layout consumed by the decode
 * kernel. Offsets are bytes from the beginning of one aligned residency slot.
 */
export interface Glm52CanonicalQ4MetalLayout {
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


export interface Glm52CanonicalQ8MetalLayout
extends Glm52CanonicalQ4MetalLayout {}


export function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`${label} must be a positive safe integer`);
  return value;
}


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
