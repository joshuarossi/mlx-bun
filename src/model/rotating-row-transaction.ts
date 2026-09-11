import * as ops from "../mlx/ops";
import { BatchedRotatingCache } from "./batched-rotating";
import { BatchedRotatingQuantCache } from "./batched-rotating-quant";
import { rotatingRollbackPlan } from "./batched-rotating-state";
import { plainRowStorage, quantizedRowStorage, rowRollIndices } from "./batched-row-storage";

export type RotatingRing = BatchedRotatingCache | BatchedRotatingQuantCache;

/** Retain accepted columns without decoding or recomputing the ring. Ownership
 * moves to the returned ring; aligned members preserve their shared rectangle. */
export function rollbackRotatingRing(ring: BatchedRotatingCache, before: readonly number[], keep: number | readonly number[], preserveColumns?: boolean): BatchedRotatingCache;
export function rollbackRotatingRing(ring: BatchedRotatingQuantCache, before: readonly number[], keep: number | readonly number[], preserveColumns?: boolean): BatchedRotatingQuantCache;
export function rollbackRotatingRing(ring: RotatingRing, before: readonly number[], keep: number | readonly number[], preserveColumns?: boolean): RotatingRing;
export function rollbackRotatingRing(ring: RotatingRing, before: readonly number[],
  keep: number | readonly number[], preserveColumns = false): RotatingRing {
  const plan = rotatingRollbackPlan(ring.positionSnapshot, before, keep, preserveColumns);
  if ("trim" in plan) { ring.trim(plan.trim); ring.releaseRopeArr(); return ring; }
  let next: RotatingRing;
  if (ring instanceof BatchedRotatingQuantCache) {
    using indices = rowRollIndices(ring.keys!.packed.shape[2]!, plan.shifts);
    const keys = quantizedRowStorage.rollRows(ring.keys!, indices);
    let values: ops.QuantizedTensor;
    try { values = quantizedRowStorage.rollRows(ring.values!, indices); }
    catch (error) { quantizedRowStorage.dispose(keys); throw error; }
    next = BatchedRotatingQuantCache.adoptPhysical(keys, values, ring.groupSize, ring.bits, plan.position);
  } else {
    using indices = rowRollIndices(ring.keys!.shape[2]!, plan.shifts);
    const keys = plainRowStorage.rollRows(ring.keys!, indices);
    let values: import("../mlx/array").MlxArray;
    try { values = plainRowStorage.rollRows(ring.values!, indices); }
    catch (error) { keys.dispose(); throw error; }
    next = BatchedRotatingCache.adoptPhysical(keys, values, plan.position);
  }
  ring.dispose(); return next;
}
