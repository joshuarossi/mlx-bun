// Regression guard for the Bun DFG stale-read bug (repro/bun-ffi-f64/
// ISSUE.md): typed-array reads after a bun:ffi call return stale values
// once the calling function is DFG-compiled (~6-20k invocations). All
// out-param readbacks must go through bun:ffi read.* (outArray,
// itemUint32, activeMemory/peakMemory).
//
// This loop drives those exact helpers far past tier-up with a
// correctness check every iteration. Against the pre-fix code (slot[0]
// reads) it fails with stale handles/values shortly after ~6-20k iters;
// it must stay clean for the full run.

import { describe, expect, test } from "bun:test";
import { ptr, read } from "bun:ffi";
import { MlxArray, cpuStream } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { C, activeMemory, peakMemory } from "../src/mlx/ffi";

const ITERS = 50_000; // comfortably past the ~6-20k DFG tier-up window

describe("bun:ffi out-param reads survive DFG tier-up", () => {
  test(`outArray + itemUint32 correct across ${ITERS} hot iterations`, () => {
    let firstBad = -1;
    for (let i = 0; i < ITERS; i++) {
      const a = ops.fromInt32([i % 100_000], [1]);
      const b = ops.fromInt32([1], [1]);
      const c = ops.add(a, b, cpuStream);
      const got = ops.itemUint32(c);
      if (got !== (i % 100_000) + 1 && firstBad < 0) firstBad = i;
      a.dispose();
      b.dispose();
      c.dispose();
    }
    expect(firstBad).toBe(-1);
  });

  test(`activeMemory/peakMemory stay sane across hot iterations`, () => {
    // Keep one array alive so active memory is provably non-zero, then
    // poll the memory readbacks hot. Stale reads here would freeze the
    // value at the tier-up-era number; we can't assert exact bytes, but
    // we can assert the reads are finite, non-negative, and consistent
    // (peak >= active) on every iteration.
    const pin = MlxArray.fromFloat32(new Float32Array(1024), [1024]);
    pin.eval();
    let bad = 0;
    for (let i = 0; i < ITERS; i++) {
      const active = activeMemory();
      const peak = peakMemory();
      if (!(Number.isFinite(active) && active > 0 && peak >= active)) bad++;
    }
    pin.dispose();
    expect(bad).toBe(0);
  });

  // The repro's failing shape: a PERSISTENT out-param buffer reused
  // across calls inside one hot function. Caveat on what this harness can
  // show (2026-06-10, Bun 1.3.14): neither this shape nor a slot[0]-
  // reverted outArray went stale inside bun:test — the loop bodies here
  // carry extra host calls (array alloc/eval/dispose) that apparently
  // block the load elimination; the minimal standalone repro
  // (repro/bun-ffi-f64/) is the authoritative demonstration. So this test
  // asserts the read.* path stays correct past tier-up and counts/logs
  // naive out[0] staleness as evidence if a future Bun/codegen shape
  // makes it bite here; it is NOT proof the naive read would be safe.
  test(`persistent out-param buffer: read.u32 correct across ${ITERS} hot iterations`, () => {
    const out = new Uint32Array(1);
    const outPtr = ptr(out);
    let firstBad = -1;
    let naiveStale = 0;
    for (let i = 0; i < ITERS; i++) {
      const v = i % 100_000;
      const a = ops.fromInt32([v], [1]);
      a.eval();
      if (C.mlx_array_item_uint32(outPtr, a.handle) !== 0)
        throw new Error("mlx_array_item_uint32 failed");
      if (out[0] !== v) naiveStale++; // naive read first: no host call between FFI write and load
      if (read.u32(outPtr, 0) !== v && firstBad < 0) firstBad = i;
      a.dispose();
    }
    if (naiveStale > 0)
      console.log(`  (naive out[0] read was stale on ${naiveStale}/${ITERS} iterations — bug live in this Bun)`);
    expect(firstBad).toBe(-1);
  });
});
