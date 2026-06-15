// FAST (no model load): the batched sliding-window cache (BatchedRotatingCache,
// src/model/batched-rotating.ts) vs the mlx-lm BatchRotatingKVCache oracle.
//
// Replays the EXACT sequence scripts/gen-rotating-golden.py drove through
// mlx-lm — solo-prefill two rows, merge, then N=1 decode steps that force the
// ring to WRAP — and asserts, at every step, that our make_mask AND our
// extracted per-row temporal keys match the reference. This is the decisive
// gate for the trickiest math in batched serving (the rotated/rolled mask);
// it runs model-free so the wrap logic can be iterated cheaply. End-to-end
// parity on a real Gemma forward is gated separately.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { RotatingKVCache } from "../src/model/gemma4-base";
import { BatchedRotatingCache } from "../src/model/batched-rotating";

const golden = await Bun.file(`${import.meta.dir}/fixtures/batched-rotating-golden.json`).json();

describe("BatchedRotatingCache vs mlx-lm BatchRotatingKVCache (model-free)", () => {
  test("merge + wrapping decode: per-step make_mask + extracted keys match", () => {
    const W: number = golden.max_size;
    const B: number = golden.B;
    const prefillKeys: number[][] = golden.prefill_keys;
    const decodeKeys: number[][] = golden.decode_keys; // [B][steps]

    const tagged = (vals: number[]) =>
      MlxArray.fromFloat32(Float32Array.from(vals), [1, 1, vals.length, 1]);

    // Solo-prefill each row (single-stream RotatingKVCache, no wrap in prefill).
    const rows: { keys: MlxArray; values: MlxArray }[] = [];
    const offsets: number[] = [];
    for (let b = 0; b < B; b++) {
      const c = new RotatingKVCache(W);
      const k = tagged(prefillKeys[b]!);
      c.updateAndFetch(k, k);
      k.dispose();
      const [tk, tv] = c.temporalView();
      rows.push({ keys: tk, values: tv });
      offsets.push(prefillKeys[b]!.length);
    }
    const cache = BatchedRotatingCache.merge(rows, offsets, W);
    for (const r of rows) { r.keys.dispose(); r.values.dispose(); }

    const maskToInts = (m: MlxArray): number[][][][] => {
      const [b, , n, s] = m.shape as [number, number, number, number];
      const flat = m.toFloat32();
      const out: number[][][][] = [];
      for (let bi = 0; bi < b; bi++) {
        const r0: number[][][] = [[]];
        for (let ni = 0; ni < n; ni++) {
          const row: number[] = [];
          for (let si = 0; si < s; si++) row.push(Math.round(flat[((bi * 1 + 0) * n + ni) * s + si]!));
          r0[0]!.push(row);
        }
        out.push(r0);
      }
      return out;
    };

    // Per-row real keys in temporal order (padding stripped) from temporalView.
    // temporalView returns a strided view; toFloat32 reads `size` CONTIGUOUS
    // elements, so a non-contiguous view must be materialized first (the real
    // model path reads bf16 → astype copies it; our f32 tags don't).
    const extractedRows = (): number[][] => {
      const [tkv] = cache.temporalView(); // [B,1,valid,1] (strided)
      const tk = ops.contiguous(tkv);
      tkv.dispose();
      const [, , valid] = tk.shape as [number, number, number, number];
      const flat = tk.toFloat32();
      tk.dispose();
      const out: number[][] = [];
      for (let b = 0; b < B; b++) {
        const pad = Math.max(0, cache.leftPad[b]!);
        const row: number[] = [];
        for (let j = pad; j < valid; j++) row.push(Math.round(flat[b * valid + j]!));
        out.push(row);
      }
      return out;
    };

    for (let s = 0; s < golden.steps; s++) {
      const step = golden.per_step[s];
      const m = cache.makeMask(1, null);
      expect(maskToInts(m.arr!)).toEqual(step.mask);
      m.arr!.dispose();

      const k = MlxArray.fromFloat32(
        Float32Array.from(decodeKeys.map((dk) => dk[s]!)), [B, 1, 1, 1],
      );
      cache.updateAndFetch(k, k);
      k.dispose();
      cache.releaseRopeArr();

      expect(extractedRows()).toEqual(step.extracted);
    }
    cache.dispose();
  });
});
