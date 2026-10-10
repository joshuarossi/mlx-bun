// TrellisLinear (decode variant fixed at 13, no flag reads) against the layer
// it replaced (trellis-linear-reference.ts) under an empty runtime
// configuration. Synthetic weights at the Qwen MLP geometry reach every
// row-count kernel: the packed matvecs (M <= 4), wide and tiled axis-1 prefill,
// split-K axis-0 prefill, and the dense expansion, whichever this GPU selects.
import { expect, test } from "bun:test";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import type { QuantSpec } from "../../src/artifacts/config";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";
import { ExpandedTrellisLinear, TrellisLinear, fusedGateUpSwiglu, fusedGateUpSwigluMixed } from "../../src/layers/trellis-linear";
import * as reference from "./trellis-linear-reference";

const defaults = createRuntimeConfig({});
// 32 adds the tiled prefill on GPUs whose native wide prefill takes M=5..15.
const ROWS = [1, 2, 4, 8, 32, 64, 512, 2048];
const IN = 5120, OUT = 17408;

interface Packed { codes: MlxArray; scales: MlxArray; spec: QuantSpec; [Symbol.dispose](): void }

function packed(axis: 0 | 1, k: number, seed: number, interleave = false): Packed {
  const rows = OUT, cols = IN, words = cols * k / 32;
  let s = seed;
  using ints = MlxArray.fromInt32(Int32Array.from({ length: rows * words }, () => s = Math.imul(s, 1664525) + 1013904223),
    interleave ? [cols / 512, rows, 48] : [rows, words]);
  using scale32 = MlxArray.fromFloat32(Float32Array.from({ length: rows }, (_, i) => (i % 251 + 1) / 4096), [rows]);
  const codes = ints.astype(Dtype.uint32), scales = scale32.astype(Dtype.float16);
  return { codes, scales, spec: { bits: k, groupSize: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis } },
    [Symbol.dispose]() { codes.dispose(); scales.dispose(); } };
}

function input(m: number, width: number): MlxArray {
  using raw = MlxArray.fromFloat32(Float32Array.from({ length: m * width }, (_, i) => Math.sin(i * 0.37 + m) * ((i % 7) + 1) / 8), [1, m, width]);
  return raw.astype(Dtype.bfloat16);
}

/** Largest absolute difference; also requires identical shape, dtype and bytes. */
function maxDiff(actual: MlxArray, expected: MlxArray): number {
  expect(actual.shape).toEqual(expected.shape);
  expect(actual.dtype).toBe(expected.dtype);
  using a = actual.astype(Dtype.float32), b = expected.astype(Dtype.float32);
  using d = ops.sub(a, b);
  using ad = ops.abs(d);
  using m = ops.maxAll(ad);
  const diff = m.toFloat32()[0]!;
  expect(Buffer.from(actual.rawBytes()).equals(Buffer.from(expected.rawBytes()))).toBe(true);
  return diff;
}

test("TrellisLinear forward and expandWeight are bit-identical to the committed layer", () => {
  const layouts: [string, 0 | 1, number, boolean, boolean][] = [
    ["axis1 k2", 1, 2, false, false], ["axis1 k3", 1, 3, false, false], ["axis1 k4", 1, 4, false, false],
    ["axis0 k2", 0, 2, false, false], ["axis0 k3", 0, 3, false, false], ["axis0 k4", 0, 4, false, false],
    ["axis0 k3 interleaved", 0, 3, true, false],
    // The 27B graph builds its down projections with the shared scatter codebook.
    ["axis0 k2 shared-codebook", 0, 2, false, true], ["axis0 k3 shared-codebook", 0, 3, false, true],
    ["axis0 k4 shared-codebook", 0, 4, false, true], ["axis0 k3 interleaved shared-codebook", 0, 3, true, true],
  ];
  withRuntimeConfig(defaults, () => {
    for (const [name, axis, k, interleave, shared] of layouts) {
      using w = packed(axis, k, 17 + 7 * k + axis + (interleave ? 3 : 0), interleave);
      const current = new TrellisLinear(w.codes, w.scales, w.spec, shared);
      const committed = new reference.TrellisLinear(w.codes, w.scales, w.spec, undefined, shared);
      expect(committed.fallback).toBeNull();
      const diffs: string[] = [];
      for (const m of ROWS) for (const rowContiguous of [false, true]) {
        using x = input(m, current.inFeatures);
        using actual = current.forward(x, rowContiguous);
        using expected = committed.forward(x, rowContiguous);
        const diff = maxDiff(actual, expected);
        expect(diff, `${name} M=${m} rowContiguous=${rowContiguous}`).toBe(0);
        diffs.push(`M${m}${rowContiguous ? "c" : ""}=${diff}`);
      }
      using actualWeight = current.expandWeight(), expectedWeight = committed.expandWeight();
      const weightDiff = maxDiff(actualWeight, expectedWeight);
      expect(weightDiff, `${name} expandWeight`).toBe(0);
      console.log(`[trellis-identity] ${name}: maxDiff ${diffs.join(" ")} expandWeight=${weightDiff}`);
    }
  });
}, 300_000);

test("fused gate/up wrappers are bit-identical to the committed layer's", () => {
  withRuntimeConfig(defaults, () => {
    const gates = [2, 3, 4].map((k) => packed(1, k, 101 + k)), ups = [2, 3, 4].map((k) => packed(1, k, 211 + k));
    try {
      const layer = (w: Packed) => new TrellisLinear(w.codes, w.scales, w.spec);
      const committed = (w: Packed) => new reference.TrellisLinear(w.codes, w.scales, w.spec);
      for (const m of [1, 2, 4]) {
        using x = input(m, IN);
        const diffs: string[] = [];
        for (const [gi, ui] of [[0, 0], [1, 1], [2, 2]] as const) {
          using actual = fusedGateUpSwiglu(x, layer(gates[gi]!), layer(ups[ui]!));
          using expected = reference.fusedGateUpSwiglu(x, committed(gates[gi]!), committed(ups[ui]!));
          const diff = maxDiff(actual, expected);
          expect(diff, `same-width k${gi + 2} M=${m}`).toBe(0);
          diffs.push(`k${gi + 2}=${diff}`);
        }
        for (const [gi, ui] of [[0, 1], [1, 2], [2, 0], [1, 0]] as const) for (const tail of ["fused", "split"] as const) {
          using actual = fusedGateUpSwigluMixed(x, layer(gates[gi]!), layer(ups[ui]!), tail);
          using expected = reference.fusedGateUpSwigluMixed(x, committed(gates[gi]!), committed(ups[ui]!), tail);
          const diff = maxDiff(actual, expected);
          expect(diff, `mixed k${gi + 2}/${ui + 2} ${tail} M=${m}`).toBe(0);
          diffs.push(`k${gi + 2}/${ui + 2}-${tail}=${diff}`);
        }
        console.log(`[trellis-identity] gate/up M=${m}: maxDiff ${diffs.join(" ")}`);
      }
    } finally { for (const w of [...gates, ...ups]) w[Symbol.dispose](); }
  });
}, 120_000);

test("ExpandedTrellisLinear is bit-identical to the committed layer's expand mode", () => {
  withRuntimeConfig(defaults, () => {
    for (const [name, axis, interleave] of [["axis1 k3", 1, false], ["axis0 k3 interleaved", 0, true]] as const) {
      using w = packed(axis, 3, 307 + axis, interleave);
      const current = new ExpandedTrellisLinear(new TrellisLinear(w.codes, w.scales, w.spec));
      const committed = new reference.TrellisLinear(w.codes, w.scales, w.spec, "expand");
      const diffs: string[] = [];
      try {
        for (const m of [1, 8, 64]) {
          using x = input(m, current.inFeatures);
          using actual = current.forward(x);
          using expected = committed.forward(x);
          const diff = maxDiff(actual, expected);
          expect(diff, `${name} M=${m}`).toBe(0);
          diffs.push(`M${m}=${diff}`);
        }
      } finally {
        for (const q of [current.carrier, committed.fallback!]) { q.w.dispose(); q.scales.dispose(); q.biases?.dispose(); }
      }
      console.log(`[trellis-identity] expanded carrier ${name}: maxDiff ${diffs.join(" ")}`);
    }
  });
}, 120_000);
