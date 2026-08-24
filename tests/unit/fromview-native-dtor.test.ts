// FAST (no model load): fromView's native-dtor redesign (the 2026-07-06
// JSCallback-deadlock class — see the hazard note in src/mlx/array.ts).
//
// What's under test:
//  - fromView hands mlx the native free(NULL) dtor, so nothing here can call
//    back into JS from the Metal completion thread; the JS view is pinned in
//    a process-side map (a GC root) instead.
//  - Pinned buffers survive ops + a forced Bun.gc(true): the pin is the only
//    root keeping a JS-heap source buffer alive while mlx reads it.
//  - unpinHostBuffer() is the explicit JS-thread release path: it frees the
//    pin map entry (pinnedBufferCount), is idempotent, and is a no-op on
//    non-fromView arrays.
//  - mmap-backed views (the expert-offload shape) stay readable after unpin
//    because the mapping — not the pin — owns the memory.

import { describe, expect, test } from "bun:test";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, cpuStream, gpuStream, pinnedBufferCount } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { MmapFile } from "../../src/mmap";

const N = 1024;

describe("fromView native dtor", () => {
  test("mmap-backed view: valid through GPU ops + forced GC; unpin frees the pin, mmap keeps the bytes", () => {
    // Page-aligned source (mmap base is page-aligned; offset 0) — required
    // for GPU no-copy wrapping (CLAUDE.md: unaligned host pointers read
    // garbage on the GPU stream).
    const dir = mkdtempSync(join(tmpdir(), "fromview-"));
    const path = join(dir, "data.f32");
    const src = new Float32Array(N);
    for (let i = 0; i < N; i++) src[i] = i * 0.5;
    writeFileSync(path, new Uint8Array(src.buffer));

    const mm = MmapFile.open(path, "ro");
    const before = pinnedBufferCount();
    const a = MlxArray.fromView(mm.view(0, N * 4), [N], Dtype.float32);
    expect(pinnedBufferCount()).toBe(before + 1);

    const doubled = ops.add(a, a, gpuStream);
    doubled.eval();
    Bun.gc(true); // pin map must root the view; array must stay valid
    const out = doubled.toFloat32();
    expect(out[0]).toBe(0);
    expect(out[7]).toBe(7);
    expect(out[N - 1]).toBe((N - 1));

    // Release path: unpin frees the map entry; the mmap (not the pin) owns
    // the memory, so the array stays readable — the expert-offload contract.
    a.unpinHostBuffer();
    expect(pinnedBufferCount()).toBe(before);
    a.unpinHostBuffer(); // idempotent
    expect(pinnedBufferCount()).toBe(before);
    Bun.gc(true);
    expect(a.toFloat32()[10]).toBe(5);

    doubled.dispose();
    a.dispose();
    // mm intentionally left mapped: mlx may release the buffer after
    // dispose(), and the memory contract is the caller's (process-lifetime
    // here, matching expert-offload).
  });

  test("JS-heap view: the pin is the GC root; unpin after a sync point decrements the count", () => {
    const before = pinnedBufferCount();
    let arr: MlxArray;
    {
      // Only reference to the buffer flows into fromView — the pin map must
      // keep it alive across GC while mlx reads it (CPU stream: JS-heap
      // buffers aren't page-aligned, so no GPU ops here).
      const buf = new Float32Array([1, 2, 3, 4]);
      arr = MlxArray.fromView(new Uint8Array(buf.buffer), [4], Dtype.float32);
    }
    expect(pinnedBufferCount()).toBe(before + 1);
    Bun.gc(true);

    const sum = ops.add(arr, arr, cpuStream);
    sum.eval();
    Bun.gc(true);
    expect([...sum.toFloat32()]).toEqual([2, 4, 6, 8]);

    // Sync point reached (everything evaluated) → dispose, then release the
    // pin on the JS thread. No JS callback ever runs from an mlx thread.
    sum.dispose();
    arr.dispose();
    arr.unpinHostBuffer();
    expect(pinnedBufferCount()).toBe(before);
  });

  test("unpinHostBuffer is a no-op on non-fromView arrays", () => {
    const before = pinnedBufferCount();
    const a = MlxArray.fromFloat32(new Float32Array([1, 2]), [2]);
    a.unpinHostBuffer();
    expect(pinnedBufferCount()).toBe(before);
    a.dispose();
  });
});
