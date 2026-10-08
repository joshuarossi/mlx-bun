/** `value` when it is a positive safe integer; otherwise a RangeError naming `label`. */
export function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new RangeError(`${label} must be a positive safe integer`);
  return value;
}
