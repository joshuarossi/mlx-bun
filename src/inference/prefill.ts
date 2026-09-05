export interface PrefillPosition {
  readonly length: number;
  readonly position: number;
  readonly chunkSize: number;
  readonly tailSplit: boolean;
  readonly snapshotAt?: number | null;
}

export interface PrefillStep {
  readonly start: number;
  readonly end: number;
  readonly kind: "drain" | "final";
  readonly snapshot: boolean;
  /** Batch admission may finish a short last drain and token zero in one tick.
   * Serial execution still yields between every drain and the next forward. */
  readonly batchYield: boolean;
}

/** Shared serial/solo-batch prefill program. No tensors, runtime policy reads,
 * or sampling. Advance position only after executing the returned step. */
export function nextPrefillStep(input: PrefillPosition): PrefillStep {
  const { length, position, chunkSize, tailSplit, snapshotAt } = input;
  if (!Number.isSafeInteger(length) || !Number.isSafeInteger(position) ||
      !Number.isSafeInteger(chunkSize) || chunkSize < 1 || position < 0 || position >= length)
    throw new Error("invalid prefill position or chunk size");
  if (snapshotAt != null && (!Number.isSafeInteger(snapshotAt) || snapshotAt < 0 || snapshotAt > length))
    throw new Error("invalid prefill snapshot boundary");
  if (snapshotAt != null && snapshotAt > position && snapshotAt < length) {
    const end = Math.min(position + chunkSize, snapshotAt);
    return { start: position, end, kind: "drain", snapshot: end === snapshotAt, batchYield: true };
  }
  const remaining = length - position;
  if (remaining > (tailSplit ? 1 : chunkSize)) {
    const end = position + (tailSplit ? Math.min(chunkSize, remaining - 1) : chunkSize);
    return { start: position, end, kind: "drain", snapshot: false,
      batchYield: !tailSplit || remaining - 1 > chunkSize };
  }
  return { start: position, end: length, kind: "final", snapshot: false, batchYield: false };
}
