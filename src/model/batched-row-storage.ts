import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { BatchedRotatingState } from "./batched-rotating-state";
import { Dtype } from "../mlx/ffi";

export interface RowStorage<T> {
  shape(value: T): readonly [number, number, number, number];
  slice(value: T, batchFrom: number, batchTo: number, tokenFrom: number, tokenTo: number): T;
  concatTokens(values: readonly T[]): T;
  concatRows(values: readonly T[]): T;
  padLeft(value: T, tokens: number): T;
  takeRows(value: T, keep: readonly number[]): T;
  copy(value: T): T;
  rollRows(value: T, indices: MlxArray): T;
  dispose(value: T): void;
}

export const plainRowStorage: RowStorage<MlxArray> = {
  shape: (value) => value.shape as [number, number, number, number],
  slice(value, batchFrom, batchTo, tokenFrom, tokenTo) {
    const [, H, , D] = value.shape as [number, number, number, number];
    return value.slice([batchFrom, 0, tokenFrom, 0], [batchTo, H, tokenTo, D]);
  },
  concatTokens: (values) => ops.concatAxis([...values], 2),
  concatRows: (values) => ops.concatAxis([...values], 0),
  padLeft(value, tokens) {
    if (tokens === 0) return value.slice([0, 0, 0, 0], value.shape as number[]);
    const [B, H, , D] = value.shape as [number, number, number, number];
    const zeros = ops.zeros([B, H, tokens, D], value.dtype);
    const out = ops.concatAxis([zeros, value], 2);
    zeros.dispose();
    return out;
  },
  takeRows(value, keep) {
    const indices = MlxArray.fromInt32(Int32Array.from(keep), [keep.length]);
    const out = ops.takeAxis(value, indices, 0);
    indices.dispose();
    return out;
  },
  copy: (value) => ops.copyOf(value),
  rollRows: (value, indices) => ops.takeAlongAxis(value, indices, 2),
  dispose: (value) => value.dispose(),
};

export const quantizedRowStorage: RowStorage<ops.QuantizedTensor> = {
  shape: (value) => value.packed.shape as [number, number, number, number],
  slice(value, batchFrom, batchTo, tokenFrom, tokenTo) {
    const cut = (array: MlxArray): MlxArray => {
      const [, H, , D] = array.shape as [number, number, number, number];
      return array.slice([batchFrom, 0, tokenFrom, 0], [batchTo, H, tokenTo, D]);
    };
    return { packed: cut(value.packed), scales: cut(value.scales), biases: cut(value.biases) };
  },
  concatTokens(values) {
    return {
      packed: ops.concatAxis(values.map((value) => value.packed), 2),
      scales: ops.concatAxis(values.map((value) => value.scales), 2),
      biases: ops.concatAxis(values.map((value) => value.biases), 2),
    };
  },
  concatRows(values) {
    return {
      packed: ops.concatAxis(values.map((value) => value.packed), 0),
      scales: ops.concatAxis(values.map((value) => value.scales), 0),
      biases: ops.concatAxis(values.map((value) => value.biases), 0),
    };
  },
  padLeft(value, tokens) {
    const pad = (array: MlxArray): MlxArray => plainRowStorage.padLeft(array, tokens);
    return { packed: pad(value.packed), scales: pad(value.scales), biases: pad(value.biases) };
  },
  takeRows(value, keep) {
    const take = (array: MlxArray): MlxArray => plainRowStorage.takeRows(array, keep);
    return { packed: take(value.packed), scales: take(value.scales), biases: take(value.biases) };
  },
  copy(value) {
    return {
      packed: ops.copyOf(value.packed),
      scales: ops.copyOf(value.scales),
      biases: ops.copyOf(value.biases),
    };
  },
  rollRows(value, indices) {
    const packed = ops.takeAlongAxis(value.packed, indices, 2);
    let scales: MlxArray | undefined;
    try {
      scales = ops.takeAlongAxis(value.scales, indices, 2);
      return { packed, scales, biases: ops.takeAlongAxis(value.biases, indices, 2) };
    } catch (error) { packed.dispose(); scales?.dispose(); throw error; }
  },
  dispose(value) {
    value.packed.dispose();
    value.scales.dispose();
    value.biases.dispose();
  },
};

/** Per-row cyclic shift, shared by plain and encoded storage planes.
 * This is mlx-lm's dynamic_roll indexing; only positions cross the FFI. */
export function rowRollIndices(length: number, shifts: readonly number[]): MlxArray {
  using columns = ops.arange(0, length, 1, Dtype.int32);
  using positions = ops.reshape(columns, [1, 1, length, 1]);
  using starts = ops.fromInt32(shifts.map(shift => ((-shift % length) + length) % length), [shifts.length, 1, 1, 1]);
  using raw = ops.add(positions, starts);
  using width = ops.fromInt32([length], []);
  using wrapped = ops.sub(raw, width);
  using over = ops.greaterEqual(raw, width);
  return ops.where(over, wrapped, raw);
}

export function mergeStorageRows<T>(
  storage: RowStorage<T>,
  rows: readonly T[],
  leftPad: readonly number[],
): T {
  const padded = rows.map((row, index) => storage.padLeft(row, leftPad[index]!));
  try {
    return storage.concatRows(padded);
  } finally {
    for (const row of padded) storage.dispose(row);
  }
}

/** De-roll storage into temporal order, then cut one row or the whole batch. */
export function temporalStorageView<T>(
  storage: RowStorage<T>,
  value: T,
  state: BatchedRotatingState,
  options: { row?: number; from?: number; to?: number; copy?: boolean } = {},
): T {
  const [batch, , tokens] = storage.shape(value);
  const batchFrom = options.row ?? 0;
  const batchTo = options.row === undefined ? batch : options.row + 1;
  const parts = state.temporalRanges(tokens).map(([from, to]) =>
    storage.slice(value, batchFrom, batchTo, from, to)
  );
  const ordered = parts.length === 1 ? parts[0]! : storage.concatTokens(parts);
  if (parts.length > 1) for (const part of parts) storage.dispose(part);
  const cut = storage.slice(
    ordered,
    0,
    batchTo - batchFrom,
    options.from ?? 0,
    options.to ?? state.validLength,
  );
  storage.dispose(ordered);
  if (!options.copy) return cut;
  const owned = storage.copy(cut);
  storage.dispose(cut);
  return owned;
}

/** Borrow storage, return an owned chronological block without decoding the
 * representation. Port of mlx-lm's BatchRotatingKVCache._update_concat
 * (MIT): discard spare capacity, retain the full window for the first query. */
export function appendRotatingStorage<T>(
  storage: RowStorage<T>, previous: T | null, incoming: T, state: BatchedRotatingState,
): T {
  if (previous === null) return storage.slice(incoming, 0, storage.shape(incoming)[0], 0, storage.shape(incoming)[2]);
  const active = state.activeLength;
  const shifts = state.prefillRoll();
  if (shifts?.some(shift => shift !== 0)) {
    const chronological = temporalStorageView(storage, previous, state, { to: active });
    let rolled: T | undefined, history: T | undefined;
    try {
      using indices = rowRollIndices(active, shifts);
      rolled = storage.rollRows(chronological, indices);
      history = storage.slice(rolled, 0, state.batchSize, Math.max(0, active - state.maxSize + 1), active);
      return storage.concatTokens([history, incoming]);
    } finally {
      storage.dispose(chronological); if (rolled) storage.dispose(rolled); if (history) storage.dispose(history);
    }
  }
  const history = temporalStorageView(storage, previous, state, {
    from: Math.max(0, active - state.maxSize + 1), to: active,
  });
  try { return storage.concatTokens([history, incoming]); }
  finally { storage.dispose(history); }
}
