import type { KvDonorAttention } from "./gemma4-base";
import { BatchedRotatingState } from "./batched-rotating-state";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { plainRowStorage, quantizedRowStorage, temporalStorageView } from "./batched-row-storage";
import { quantizedDonorAttention } from "./kv-attention-view";
import { decodedKvDonorAttention } from "./decoded-kv-donor";
import type { RotatingRing } from "./rotating-row-transaction";

/** Capture the same chronological donor rectangle for plain and encoded rings. */
export function captureRotatingDonorAttention(ring: RotatingRing): KvDonorAttention {
  const position = new BatchedRotatingState(ring.maxSize, []);
  position.restore(ring.positionSnapshot);
  const offsets = position.offsets.map((_, row) => position.validOffset(row));
  const ends = offsets.map((offset, row) => position.activeLength - (position.offsets[row]! - offset));
  // Pending prefill keeps a shared physical rectangle, including when mixed
  // rows are captured separately. Cropping from each row's valid end would
  // give siblings different widths and can discard an earlier valid window.
  const from = position.hasPendingPadding ? 0 : Math.max(0, position.activeLength - ring.maxSize);
  const range = { from, to: position.activeLength };
  const validity = { offsets,
    starts: position.leftPad.map((pad, row) => Math.max(0, pad - from, ends[row]! - from - ring.maxSize)),
    ends: ends.map(end => Math.max(0, end - from)) };
  if (ring instanceof BatchedRotatingQuantCache) {
    const keys = temporalStorageView(quantizedRowStorage, ring.keys!, position, range);
    let values: import("../mlx/ops").QuantizedTensor;
    try { values = temporalStorageView(quantizedRowStorage, ring.values!, position, range); }
    catch (error) { quantizedRowStorage.dispose(keys); throw error; }
    return quantizedDonorAttention(keys, values, validity, ring.groupSize, ring.bits);
  }
  const keys = temporalStorageView(plainRowStorage, ring.keys!, position, range);
  let values: import("../mlx/array").MlxArray;
  try { values = temporalStorageView(plainRowStorage, ring.values!, position, range); }
  catch (error) { keys.dispose(); throw error; }
  return decodedKvDonorAttention({ keys, values, ...validity });
}
