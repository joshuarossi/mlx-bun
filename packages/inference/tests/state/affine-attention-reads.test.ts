// B1b bit-identity gate: every affine cache's named reads against what the
// graphs compute today for the same cache and phase. "Old" is the graph's call
// copied verbatim: `makeMask` before the append, `updateAndFetchQuantized`, then
// `quantizedSdpa` with that mask, frozen below as it was before B1b (its
// MLX_BUN_NO_FUSED_SDPA read becomes the `noFused` argument, and the M4 Pro
// grouped-heads case keeps its device check). The committed read's old call is
// the independent-rows branch; the M4 Pro graph's is its `decodeCore` or
// `foldedCore`. "New" is the phase-named append and `attend`. Same random
// q/k/v. Each step names the kernel the old dispatch took and the one the new
// read takes: the same kernel must give maxDiff 0; a different one is a
// recorded divergence, named in the report and bounded at bf16 level: outputs
// lie in [-2, 2], where a bf16 step is 2^-6, and the bound is four steps (the
// tiled port normalizes after its value matmul, so it rounds differently from
// the unfused port, and is about as far from an f32 reference).
import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { AttentionCache, AttentionRead, Cache, CommittedAttentionCache, Mask } from "../../src/contracts/mlx/cache";
import {
  FINFO_MIN, foldedQuantizedSdpa, quantizedSdpa, quantizedSdpaTiled, quantizedSdpaUnfused,
} from "../../src/layers/quantized-attention";
import { quantizedAppendAttention } from "../../src/layers/quantized-append-attention";
import { kv4DecodeAttention } from "../../src/layers/kv4-decode-attention";
import { tiledAffineKernels, tiledCausalAffineKernels, unfusedAffineKernels, type AffineKernels } from "../../src/state/affine-attention";
import { AttentionMasks } from "../../src/state/attention-read";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { BatchedQuantizedKVCache } from "../../src/state/batched-quantized-kv";
import { PaddedQuantKVRows } from "../../src/state/batched-quant";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { BatchedRotatingQuantCache } from "../../src/state/batched-rotating-quant";
import { SpeculativeRotatingAffineLayout } from "../../src/state/rotating-kv-layout";
import { Kv4Head256Cache } from "../../src/state/kv4-head256-cache";
import { GroupedHeadsKv4Cache } from "../../src/state/grouped-heads-kv4-cache";
import { disposeTriple } from "../../src/state/quantized-tensor";
import { disposeResources } from "../../src/runtime/resources";
import { createRuntimeConfig, runtimeConfig, withRuntimeConfig } from "../../src/runtime/config";

const HKV = 2, HQ = 8, D = 128, SCALE = 0.088, WINDOW = 32, TOLERANCE = 4 * 2 ** -6;
const M4PRO = deviceArchitecture() === "applegpu_g16s";

// --- The dispatch before B1b, frozen ------------------------------------------------------------

/** `quantizedSdpaUnfused` before B1b, verbatim (the grouped-heads case with
 * its device check included). */
function oldUnfused(
  q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor,
  scale: number, mask: Mask, groupSize: number, bits: number,
): MlxArray {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  const KV = kq.packed.shape[1]!;
  const nRep = H / KV;
  const N = kq.packed.shape[2]!;

  // scale is 1.0 for Gemma4 (q/k are RMS-normed) — skip the identity multiply.
  let queries = q;
  const owned: MlxArray[] = [];
  if (scale !== 1.0) { queries = ops.mulScalar(q, scale); owned.push(queries); }

  let kT = kq;
  let vT = vq;
  if (nRep > 1) {
    const qr = ops.reshape(queries, [B, KV, nRep, L, D]);
    owned.push(qr);
    queries = qr;
    const expand = (t: ops.QuantizedTensor): ops.QuantizedTensor => {
      const e = (a: MlxArray): MlxArray => {
        // expand_dims(axis=-3) like the reference — view-preserving;
        // reshape would copy the strided slice and change kernel paths
        const r = ops.expandDims(a, -3);
        owned.push(r);
        return r;
      };
      return { packed: e(t.packed), scales: e(t.scales), biases: e(t.biases) };
    };
    kT = expand(kq);
    vT = expand(vq);
  }

  // M4 Pro's native key matvec retains exact arithmetic when three GQA
  // heads share a batch. Restore score geometry before softmax/value work.
  const groupHeads = oldGroupsHeads(q, kq, groupSize, bits);
  let keyQueries = queries;
  if (groupHeads) {
    keyQueries = ops.reshape(queries, [B, KV, 2, 9, D]);
    owned.push(keyQueries);
  }
  let scores = ops.quantizedMatmulQT(keyQueries, kT, true, groupSize, bits);
  owned.push(scores);
  if (groupHeads) {
    scores = ops.reshape(scores, [B, KV, nRep, L, N]);
    owned.push(scores);
  }

  let maskArr: MlxArray | null = null;
  let ownsMask = false;
  if (mask.mode === "causal") {
    const qIdx = ops.arange(N - L, N, 1, Dtype.int32);
    const kIdx = ops.arange(0, N, 1, Dtype.int32);
    const qCol = ops.reshape(qIdx, [L, 1]);
    const kRow = ops.reshape(kIdx, [1, N]);
    maskArr = ops.greaterEqual(qCol, kRow);
    ownsMask = true;
    for (const a of [qIdx, kIdx, qCol, kRow]) a.dispose();
  } else if (mask.mode === "array") {
    maskArr = mask.arr;
    if (maskArr && maskArr.ndim === 4 && nRep > 1) {
      maskArr = ops.expandDims(maskArr, 1);
      ownsMask = true;
    }
  }
  if (maskArr) {
    let masked: MlxArray;
    if (maskArr.dtype === Dtype.bool) {
      using ninf = ops.scalarLike(FINFO_MIN[scores.dtype] ?? -3.4e38, scores);
      masked = ops.where(maskArr, scores, ninf);
    } else masked = ops.add(scores, maskArr);
    if (ownsMask) maskArr.dispose();
    owned.push(masked);
    scores = masked;
  }

  const probs = ops.softmaxAxis(scores, -1, true);
  owned.push(probs);
  let out = ops.quantizedMatmulQT(probs, vT, false, groupSize, bits);
  if (nRep > 1) {
    const r = ops.reshape(out, [B, H, L, D]);
    out.dispose();
    out = r;
  }
  for (const a of owned) a.dispose();
  return out;
}

function oldGroupsHeads(q: MlxArray, kq: ops.QuantizedTensor, groupSize: number, bits: number): boolean {
  const [B, H, L, D] = q.shape as [number, number, number, number];
  return B <= 2 && H === 24 && kq.packed.shape[1] === 4 && L === 3 && D === 256 &&
    kq.packed.shape[2]! >= 8192 && groupSize === 64 && bits === 4 &&
    (q.dtype === Dtype.bfloat16 || q.dtype === Dtype.float32) &&
    deviceArchitecture() === "applegpu_g16s";
}

/** `fusedSdpaSupported` before B1b; `noFused` is its env read. */
function oldFusedSupported(q: MlxArray, mask: Mask, groupSize: number, bits: number, noFused: boolean): boolean {
  if (noFused) return false;
  if (bits !== 4 && bits !== 8) return false;
  if (groupSize !== 32 && groupSize !== 64 && groupSize !== 128) return false;
  if (q.dtype !== Dtype.bfloat16 && q.dtype !== Dtype.float16) return false;
  if (mask.mode === "causal" || mask.mode === "") return true;
  if (mask.mode === "array")
    return mask.causalEquivalent === true && mask.arr !== null &&
      mask.arr.shape.length === 2 && mask.arr.dtype === Dtype.bool;
  return false;
}

/** The old output, the kernel the dispatch took, and whether the cache handed
 * it an array mask (its own state made the mask other than plain causal). */
interface Result { out: MlxArray; kernel: string; masked?: boolean }

/** `quantizedSdpa` before B1b, naming the kernel it took. The tiled port is
 * unchanged by B1b and imported. */
function oldQuantizedSdpa(q: MlxArray, kq: ops.QuantizedTensor, vq: ops.QuantizedTensor, scale: number, mask: Mask,
  groupSize: number, bits: number, noFused: boolean): Result {
  if (q.shape[2]! > 1 && oldFusedSupported(q, mask, groupSize, bits, noFused))
    return { out: quantizedSdpaTiled(q, kq, vq, scale, mask, groupSize, bits), kernel: "tiled" };
  return { out: oldUnfused(q, kq, vq, scale, mask, groupSize, bits), kernel: oldGroupsHeads(q, kq, groupSize, bits) ? "grouped" : "unfused" };
}

// --- The graphs' calls ----------------------------------------------------------------------------

/** Qwen3Attention / Gemma 4 / MiniCPM 5 today: the mask before the append, the
 * quantized append, then `quantizedSdpa`. */
function oldRead(cache: Cache, window: number | null, k: MlxArray, v: MlxArray, q: MlxArray, noFused: boolean,
  scale = SCALE): Result {
  const mask = cache.makeMask(k.shape[2]!, window);
  const quantized = cache.quantizedAttention!;
  const [keys, values] = quantized.updateAndFetchQuantized(k, v);
  try { return { ...oldQuantizedSdpa(q, keys, values, scale, mask, quantized.groupSize, quantized.bits, noFused), masked: mask.mode === "array" }; }
  finally { disposeTriple(keys); disposeTriple(values); mask.arr?.dispose(); }
}

/** Qwen3Attention's independent-rows branch (token fill) today. */
function oldCommittedRead(cache: Cache, k: MlxArray, v: MlxArray, q: MlxArray): Result {
  const L = k.shape[2]!;
  const mask = cache.makeMask(L, null);
  const quantized = cache.quantizedAttention!;
  const [keys, values] = quantized.updateAndFetchQuantized(k, v);
  try {
    if (L > 1) return { out: quantizedAppendAttention(q, keys, values, SCALE, quantized.groupSize, quantized.bits), kernel: "append" };
    return oldQuantizedSdpa(q, keys, values, SCALE, mask, quantized.groupSize, quantized.bits, false);
  } finally { disposeTriple(keys); disposeTriple(values); mask.arr?.dispose(); }
}

/** The M4 Pro graph's attention core today: `decodeCore` on its one-row plan,
 * `foldedCore` on every other. */
function oldM4ProRead(cache: QuantizedKVCache, k: MlxArray, v: MlxArray, q: MlxArray, scale: number): Result {
  const [keys, values] = cache.updateAndFetchQuantized(k, v);
  try {
    return q.shape[2] === 1
      ? { out: kv4DecodeAttention(q, keys, values, scale, 64, 4), kernel: "kv4" }
      : { out: foldedQuantizedSdpa(q, keys, values, scale, 64, 4), kernel: "folded" };
  } finally { disposeTriple(keys); disposeTriple(values); }
}

// --- Harness ------------------------------------------------------------------------------------

let seed = 1;
function tensor(shape: number[]): MlxArray {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  let s = (seed++ * 2654435761) >>> 0;
  for (let i = 0; i < n; i++) { s = (s * 1664525 + 1013904223) >>> 0; data[i] = (s / 2 ** 32) * 4 - 2; }
  using f = MlxArray.fromFloat32(data, shape);
  return f.astype(Dtype.bfloat16);
}

interface Geometry { hq: number; hkv: number; d: number; scale: number }
const BASE: Geometry = { hq: HQ, hkv: HKV, d: D, scale: SCALE };
const QWEN38: Geometry = { hq: 24, hkv: 4, d: 256, scale: 1 / 16 };

const kv = (B: number, L: number, g: Geometry = BASE): [MlxArray, MlxArray] =>
  [tensor([B, g.hkv, L, g.d]), tensor([B, g.hkv, L, g.d])];
const query = (B: number, L: number, g: Geometry = BASE) => tensor([B, g.hq, L, g.d]);

/** Elementwise; outputs are read row-major (a kernel can return a transposed
 * layout, which a linear host read would scramble). */
function maxDiff(a: MlxArray, b: MlxArray): number {
  expect(a.shape).toEqual(b.shape);
  using ra = ops.contiguous(a), rb = ops.contiguous(b);
  using fa = ra.astype(Dtype.float32), fb = rb.astype(Dtype.float32);
  const x = fa.toFloat32(), y = fb.toFloat32();
  let m = 0;
  for (let i = 0; i < x.length; i++) m = Math.max(m, Math.abs(x[i]! - y[i]!));
  return m;
}

function attendOnce(read: AttentionRead, q: MlxArray, scale: number): MlxArray {
  try { const out = read.attend(q, scale); out.eval(); return out; } finally { read.dispose(); }
}

type Step = "D" | number; // decode, or a window of that many rows
type Phase = "decode" | "window" | "committed";
const phaseOf = (step: Step): Phase => step === "D" ? "decode" : "window";

interface Outcome { label: string; diff: number; divergence: string | null }
const outcomes: Outcome[] = [];

/** Record one comparison. Returns a failure message, or null. */
function record(label: string, diff: number, oldKernel: string, newKernel: string, storage: string | null = null): string | null {
  const divergence = storage ?? (oldKernel === newKernel ? null : `old ${oldKernel}, new ${newKernel}`);
  outcomes.push({ label: `${label} [${newKernel}]`, diff, divergence });
  if (divergence === null) return diff === 0 ? null : `${label}: maxDiff ${diff} with the same kernel (${newKernel})`;
  return diff < TOLERANCE ? null : `${label}: divergence ${divergence} too large (${diff})`;
}

type Old<C> = (cache: C, k: MlxArray, v: MlxArray, q: MlxArray) => Result;
/** The kernel the new read takes for a phase, given whether the cache's own
 * mask was an array before the append. */
type NewKernel = (phase: Phase, L: number, masked: boolean) => string;

/** Run `steps` on two identically prepared caches: the old call on one, the
 * named read on the other. Returns the failures. */
function compareSteps<C extends AttentionCache>(label: string, pair: [C, C], B: number, steps: readonly Step[],
  old: Old<C>, newKernel: NewKernel, g: Geometry = BASE, storage: (step: Step) => string | null = () => null): string[] {
  const failures: string[] = [];
  for (const step of steps) {
    const L = step === "D" ? 1 : step;
    const [k, v] = kv(B, L, g);
    using q = query(B, L, g);
    try {
      const at = pair[1].offset;
      const expected = old(pair[0], k, v, q);
      using reference = expected.out;
      reference.eval();
      using actual = attendOnce(step === "D" ? pair[1].appendDecode(k, v) : pair[1].appendWindow(k, v), q, g.scale);
      const failure = record(`${label} ${step === "D" ? "decode" : `window ${L}`} @${at}`, maxDiff(actual, reference),
        expected.kernel, newKernel(phaseOf(step), L, expected.masked ?? false), storage(step));
      if (failure) failures.push(failure);
    } finally { k.dispose(); v.dispose(); }
  }
  return failures;
}

function twice<C>(make: () => C): [C, C] { return [make(), make()]; }

/** Solo caches with the given histories, identical between the two runs. */
function soloRows<C extends Cache>(make: () => C, lengths: readonly number[], g: Geometry = BASE): [C[], C[]] {
  const a: C[] = [], b: C[] = [];
  for (const length of lengths) {
    const [x, y] = twice(make);
    const [k, v] = kv(1, length, g);
    try { for (const c of [x, y]) for (const t of c.quantizedAttention!.updateAndFetchQuantized(k, v)) disposeTriple(t); }
    finally { k.dispose(); v.dispose(); }
    a.push(x); b.push(y);
  }
  return [a, b];
}

/** Advance both caches identically through the deprecated append. */
function advance(pair: [Cache, Cache], B: number, steps: readonly Step[], g: Geometry = BASE): void {
  for (const [index, step] of steps.entries()) {
    const [k, v] = kv(B, step === "D" ? 1 : step, g);
    try { for (const cache of pair) for (const t of cache.quantizedAttention!.updateAndFetchQuantized(k, v)) disposeTriple(t); }
    finally { k.dispose(); v.dispose(); }
    if (index % 64 === 63) ops.evalAll(pair.flatMap(cache => cache.state()));
  }
}

/** One composition of the generic caches and the old dispatch it is compared
 * with. `tiled-causal`: `tiledCausalAffineKernels` (`--kv-quant config`, OptiQ
 * parity) against the dispatch with fused SDPA on. `unfused`:
 * `unfusedAffineKernels` (uniform `--kv-quant N`, mlx-lm parity) against it
 * with MLX_BUN_NO_FUSED_SDPA=1. `tiled`: `tiledAffineKernels` (always tiled, no
 * oracle) against the fused-on dispatch, recorded. */
interface Variant { name: "tiled-causal" | "unfused" | "tiled"; noFused: boolean; kernels(groupSize: number, bits: number): AffineKernels }
const VARIANTS: Variant[] = [
  { name: "tiled-causal", noFused: false, kernels: (groupSize, bits) => tiledCausalAffineKernels(bits, groupSize, Dtype.bfloat16) },
  { name: "unfused", noFused: true, kernels: (groupSize, bits) => unfusedAffineKernels(bits, groupSize, Dtype.bfloat16) },
  { name: "tiled", noFused: false, kernels: (groupSize, bits) => tiledAffineKernels(bits, groupSize, Dtype.bfloat16) },
];
/** The window kernel a variant's kernels hold for a plain causal mask, and for
 * a mask the cache's own state made an array. */
const windowKernel = (variant: Variant, masked: boolean) =>
  variant.name === "unfused" || variant.name === "tiled-causal" && masked ? "unfused" : "tiled";
const genericKernel = (variant: Variant): NewKernel =>
  (phase, _L, masked) => phase === "window" ? windowKernel(variant, masked) : "unfused";
const TILED = VARIANTS[2]!;

const CONFIGS: Array<[bits: number, groupSize: number]> = [[4, 64], [8, 64], [4, 32], [8, 128]];
const BATCH_CONFIGS: Array<[bits: number, groupSize: number]> = [[4, 64], [8, 64], [8, 32]];

// --- QuantizedKVCache -----------------------------------------------------------------------------

for (const [bits, groupSize] of CONFIGS) for (const variant of VARIANTS) {
  test(`QuantizedKVCache ${bits}-bit g${groupSize} ${variant.name}: decode and windows across the 256 step and the 512 tile`, () => {
    const pair: [QuantizedKVCache, QuantizedKVCache] = [new QuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)),
      new QuantizedKVCache(groupSize, bits, variant.kernels(groupSize, bits))];
    try {
      expect(compareSteps(`QuantizedKVCache ${bits}b g${groupSize} ${variant.name}`, pair, 1,
        [37, "D", "D", 1, 3, 8, 37, 200, "D", 8, 1, 300, "D", 3],
        (c, k, v, q) => oldRead(c, null, k, v, q, variant.noFused), genericKernel(variant))).toEqual([]);
    } finally { disposeResources(pair); }
  });
}

test("QuantizedKVCache: Gemma 4's scale 1.0 (the kernels skip the scale multiply)", () => {
  const failures: string[] = [];
  for (const variant of VARIANTS) {
    const pair: [QuantizedKVCache, QuantizedKVCache] = [new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
      new QuantizedKVCache(64, 4, variant.kernels(64, 4))];
    try {
      failures.push(...compareSteps(`QuantizedKVCache 4b g64 ${variant.name} scale 1`, pair, 1, [37, "D", 3, 200, "D"],
        (c, k, v, q) => oldRead(c, null, k, v, q, variant.noFused, 1), genericKernel(variant),
        { ...BASE, scale: 1 }));
    } finally { disposeResources(pair); }
  }
  expect(failures).toEqual([]);
});

// --- Batched full-attention layouts ---------------------------------------------------------------

for (const [bits, groupSize] of BATCH_CONFIGS) for (const variant of VARIANTS)
  for (const lengths of [[9, 9], [5, 17], [5, 17, 3, 40]]) {
    test(`BatchedQuantizedKVCache ${bits}-bit g${groupSize} ${variant.name}: rows at offsets ${lengths}`, () => {
      const [a, b] = soloRows(() => new QuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)), lengths);
      const pair: [BatchedQuantizedKVCache, BatchedQuantizedKVCache] = [new BatchedQuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)),
        new BatchedQuantizedKVCache(groupSize, bits, variant.kernels(groupSize, bits))];
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        expect(compareSteps(`BatchedQuantizedKVCache ${bits}b g${groupSize} ${variant.name} [${lengths}]`, pair, lengths.length,
          ["D", "D", 1, 3, 8, 37, "D"], (c, k, v, q) => oldRead(c, null, k, v, q, variant.noFused),
          genericKernel(variant))).toEqual([]);
      } finally { disposeResources([...pair, ...a, ...b]); }
    });

    test(`PaddedQuantKVRows ${bits}-bit g${groupSize} ${variant.name}: rows at offsets ${lengths}`, () => {
      const [a, b] = soloRows(() => new QuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)), lengths);
      const pair: [PaddedQuantKVRows, PaddedQuantKVRows] = [new PaddedQuantKVRows(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)),
        new PaddedQuantKVRows(groupSize, bits, variant.kernels(groupSize, bits))];
      try {
        // Rows join one at a time, as the scheduler adds them.
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        expect(compareSteps(`PaddedQuantKVRows ${bits}b g${groupSize} ${variant.name} [${lengths}]`, pair, lengths.length,
          ["D", "D", 1, 3, 8, 37, "D"], (c, k, v, q) => oldRead(c, null, k, v, q, variant.noFused),
          genericKernel(variant))).toEqual([]);
      } finally { disposeResources([...pair, ...a, ...b]); }
    });
  }

for (const variant of VARIANTS) for (const padding of [{ leftPadding: [2, 0], lengths: [6, 8] },
  { lengths: [5, 8], rightPadding: [3, 0] },
  { leftPadding: [0, 3, 1, 5], lengths: [8, 5, 7, 3], rightPadding: [0, 0, 0, 0] }]) {
  test(`BatchedQuantizedKVCache ${variant.name}: padded prefill ${JSON.stringify(padding)}`, () => {
    const B = padding.lengths.length;
    const pair: [BatchedQuantizedKVCache, BatchedQuantizedKVCache] = [new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
      new BatchedQuantizedKVCache(64, 4, variant.kernels(64, 4))];
    try {
      for (const cache of pair) cache.preparePrefill(padding);
      const old: Old<BatchedQuantizedKVCache> = (c, k, v, q) => oldRead(c, null, k, v, q, variant.noFused);
      const failures = compareSteps(`BatchedQuantizedKVCache ${variant.name} prefill`, pair, B, [8], old, genericKernel(variant));
      for (const cache of pair) cache.finalizePrefill();
      failures.push(...compareSteps(`BatchedQuantizedKVCache ${variant.name} after prefill`, pair, B, ["D", "D", 3], old,
        genericKernel(variant)));
      expect(failures).toEqual([]);
    } finally { disposeResources(pair); }
  });
}

test("BatchedQuantizedKVCache always tiled: one query head per KV head (no GQA axis for the per-row mask)", () => {
  const mha: Geometry = { hq: 2, hkv: 2, d: D, scale: SCALE };
  const [a, b] = soloRows(() => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), [5, 17], mha);
  const pair = twice(() => new BatchedQuantizedKVCache(64, 4, tiledAffineKernels(4, 64, Dtype.bfloat16)));
  try {
    pair[0].mergeRows(a); pair[1].mergeRows(b);
    expect(compareSteps("BatchedQuantizedKVCache 4b g64 tiled MHA [5,17]", pair, 2, ["D", 3, 37, "D"],
      (c, k, v, q) => oldRead(c, null, k, v, q, false), genericKernel(TILED), mha)).toEqual([]);
  } finally { disposeResources([...pair, ...a, ...b]); }
});

// --- Rotating layouts -----------------------------------------------------------------------------

for (const [bits, groupSize] of CONFIGS) for (const variant of VARIANTS) {
  test(`RotatingQuantizedKVCache ${bits}-bit g${groupSize} ${variant.name}: windows before, across and after the sliding boundary`, () => {
    const pair: [RotatingQuantizedKVCache, RotatingQuantizedKVCache] = [new RotatingQuantizedKVCache(WINDOW, groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)),
      new RotatingQuantizedKVCache(WINDOW, groupSize, bits, variant.kernels(groupSize, bits))];
    try {
      // A one-row window only while the ring has room (see the divergence test).
      expect(compareSteps(`RotatingQuantizedKVCache ${bits}b g${groupSize} ${variant.name}`, pair, 1,
        [3, 8, "D", "D", "D", "D", "D", 1, 37, ...Array<Step>(40).fill("D"), 3, 8, 37, "D", "D", "D"],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q, variant.noFused), genericKernel(variant))).toEqual([]);
    } finally { disposeResources(pair); }
  });
}

test("RotatingQuantizedKVCache at a Gemma 4 sliding window (512, head dim 256, scale 1): multi-tile chunks", () => {
  const gemma: Geometry = { hq: 8, hkv: 2, d: 256, scale: 1 };
  const failures: string[] = [];
  for (const variant of VARIANTS) {
    const pair: [RotatingQuantizedKVCache, RotatingQuantizedKVCache] = [new RotatingQuantizedKVCache(512, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
      new RotatingQuantizedKVCache(512, 64, 4, variant.kernels(64, 4))];
    try {
      failures.push(...compareSteps(`RotatingQuantizedKVCache(512) 4b g64 d256 ${variant.name}`, pair, 1,
        [300, "D", 200, 300, "D", "D", 8, 600, "D"],
        (c, k, v, q) => oldRead(c, 512, k, v, q, variant.noFused, 1), genericKernel(variant), gemma));
    } finally { disposeResources(pair); }
  }
  expect(failures).toEqual([]);
});

// The deprecated append writes a one-position append in place, so a one-row
// window attended the ring in ring order there; the window read concatenates
// (temporal order). B1a's first divergence, on the affine ring.
test("RotatingQuantizedKVCache: a one-row window after the ring wraps (documented divergence)", () => {
  const failures: string[] = [];
  for (const variant of VARIANTS) for (let trial = 0; trial < 3; trial++) {
    const pair: [RotatingQuantizedKVCache, RotatingQuantizedKVCache] = [new RotatingQuantizedKVCache(WINDOW, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)),
      new RotatingQuantizedKVCache(WINDOW, 64, 4, variant.kernels(64, 4))];
    try {
      advance(pair, 1, [37, ...Array<Step>(WINDOW + 20 + trial).fill("D")]);
      failures.push(...compareSteps(`RotatingQuantizedKVCache 4b g64 ${variant.name} wrapped`, pair, 1, [1],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q, variant.noFused), genericKernel(variant), BASE,
        () => "old wrote in place (ring order), new concatenates (temporal order)"));
    } finally { disposeResources(pair); }
  }
  expect(failures).toEqual([]);
});

const unfusedOnly: NewKernel = () => "unfused";

for (const [bits, groupSize] of BATCH_CONFIGS) for (const noFused of [false, true])
  for (const lengths of [[5, 20], [5, 40], [3, 40, 17, 70]]) {
    test(`BatchedRotatingQuantCache ${bits}-bit g${groupSize} vs ${noFused ? "unfused" : "fused"} dispatch: rows at offsets ${lengths}`, () => {
      const [a, b] = soloRows(() => new RotatingQuantizedKVCache(WINDOW, groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)), lengths);
      const pair = twice(() => BatchedRotatingQuantCache.empty(WINDOW, groupSize, bits, []));
      try {
        pair[0].mergeRows(a); pair[1].mergeRows(b);
        const roomy = Math.max(...lengths) + 1 < WINDOW;
        expect(compareSteps(`BatchedRotatingQuantCache ${bits}b g${groupSize} ${noFused ? "unfused" : "fused"} [${lengths}]`,
          pair, lengths.length, [...(roomy ? [1] : []), "D", "D", 3, 8, 37, ...Array<Step>(40).fill("D"), 3, "D", 8, "D"],
          (c, k, v, q) => oldRead(c, WINDOW, k, v, q, noFused), unfusedOnly)).toEqual([]);
      } finally { disposeResources([...pair, ...a, ...b]); }
    });
  }

for (const padding of [{ leftPadding: [2, 0], lengths: [6, 8] }, { lengths: [5, 8], rightPadding: [3, 0] },
  { leftPadding: [0, 3, 1, 5], lengths: [8, 5, 7, 3], rightPadding: [0, 0, 0, 0] }]) {
  test(`BatchedRotatingQuantCache: padded prefill ${JSON.stringify(padding)}`, () => {
    const B = padding.lengths.length;
    const failures: string[] = [];
    for (const noFused of [false, true]) {
      const pair = twice(() => BatchedRotatingQuantCache.empty(WINDOW, 64, 4, Array(B).fill(0)));
      try {
        for (const cache of pair) cache.preparePrefill(padding);
        const old: Old<BatchedRotatingQuantCache> = (c, k, v, q) => oldRead(c, WINDOW, k, v, q, noFused);
        failures.push(...compareSteps(`BatchedRotatingQuantCache prefill ${noFused ? "unfused" : "fused"}`, pair, B, [8, 1], old, unfusedOnly));
        for (const cache of pair) cache.finalizePrefill();
        failures.push(...compareSteps(`BatchedRotatingQuantCache after prefill ${noFused ? "unfused" : "fused"}`, pair, B,
          ["D", "D", 3, 37, "D"], old, unfusedOnly));
      } finally { disposeResources(pair); }
    }
    expect(failures).toEqual([]);
  });
}

test("BatchedRotatingQuantCache: a one-row window after the ring wraps (documented divergence)", () => {
  const failures: string[] = [];
  for (let trial = 0; trial < 3; trial++) {
    const [a, b] = soloRows(() => new RotatingQuantizedKVCache(WINDOW, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), [37, WINDOW + 50]);
    const pair = twice(() => BatchedRotatingQuantCache.empty(WINDOW, 64, 4, []));
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      advance(pair, 2, Array<Step>(WINDOW + 20 + trial).fill("D"));
      failures.push(...compareSteps("BatchedRotatingQuantCache 4b g64 wrapped", pair, 2, [1],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q, true), unfusedOnly, BASE,
        () => "old wrote in place (ring order), new concatenates (temporal order)"));
    } finally { disposeResources([...pair, ...a, ...b]); }
  }
  expect(failures).toEqual([]);
});

for (const variant of VARIANTS) for (const lengths of [[9, 9], [5, 40]]) {
  test(`SpeculativeRotatingAffineLayout ${variant.name}: verify windows and decode at offsets ${lengths}`, () => {
    const [a, b] = soloRows(() => new RotatingQuantizedKVCache(WINDOW, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), lengths);
    const pair = twice(() => new SpeculativeRotatingAffineLayout(WINDOW, 64, 4, variant.kernels(64, 4)));
    // Plain causal windows take the layout's window kernel; masked ones the
    // ring's, which reads unfused in every composition.
    const kernel: NewKernel = (phase, _L, masked) => phase === "window" && !masked ? windowKernel(variant, false) : "unfused";
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      // A one-row window only while the window has room (see the ring tests).
      expect(compareSteps(`SpeculativeRotatingAffineLayout ${variant.name} [${lengths}]`, pair, lengths.length,
        ["D", 3, ...(Math.max(...lengths) + 5 <= WINDOW ? [1] : []), 8, ...Array<Step>(30).fill("D"), 37, "D"],
        (c, k, v, q) => oldRead(c, WINDOW, k, v, q, variant.noFused),
        kernel)).toEqual([]);
    } finally { disposeResources([...pair, ...a, ...b]); }
  });
}

// --- Committed spans ------------------------------------------------------------------------------

for (const [bits, groupSize] of BATCH_CONFIGS) {
  test(`committed spans ${bits}-bit g${groupSize}: QuantizedKVCache and a one-row BatchedQuantizedKVCache`, () => {
    const failures: string[] = [];
    for (const at of [23, 300]) for (const L of [1, 2, 3, 4]) {
      const [a, b] = soloRows(() => new QuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)), [at, at]);
      const solo: [QuantizedKVCache, QuantizedKVCache] = [a[1]!, b[1]!];
      const batched = twice(() => new BatchedQuantizedKVCache(groupSize, bits, unfusedAffineKernels(bits, groupSize, Dtype.bfloat16)));
      try {
        batched[0].mergeRows([a[0]!]); batched[1].mergeRows([b[0]!]);
        for (const [name, pair] of [["QuantizedKVCache", solo], ["BatchedQuantizedKVCache", batched]] as
          Array<[string, [CommittedAttentionCache, CommittedAttentionCache]]>) {
          const [k, v] = kv(1, L);
          using q = query(1, L);
          try {
            const expected = oldCommittedRead(pair[0], k, v, q);
            using reference = expected.out;
            using actual = attendOnce(pair[1].appendCommitted(k, v), q, SCALE);
            // A one-position span takes the unfused port either way.
            const failure = record(`${name} ${bits}b g${groupSize} committed ${L} @${at}`, maxDiff(actual, reference),
              expected.kernel === "unfused" ? "append" : expected.kernel, "append");
            if (failure) failures.push(failure);
          } finally { k.dispose(); v.dispose(); }
        }
      } finally { disposeResources([...batched, ...a, ...b]); }
    }
    expect(failures).toEqual([]);
  });
}

// --- Device-specific legos ------------------------------------------------------------------------

test("Kv4Head256Cache: the M4 Pro graph's decode and folded kernels at its shapes", () => {
  const pair: [QuantizedKVCache, Kv4Head256Cache] = [new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), new Kv4Head256Cache()];
  const kernel: NewKernel = phase => phase === "decode" ? "kv4" : "folded";
  try {
    // Prefill chunk, decode across the KV4 kernel's 512-key blocks, verify
    // widths 2..8 (rows, rows4, verify plans), longer prefill chunks.
    const failures = compareSteps("Kv4Head256Cache", pair, 1,
      [600, "D", "D", 2, 3, 4, 5, 8, "D", 37, 200, "D", 3, "D"],
      (c, k, v, q) => oldM4ProRead(c, k, v, q, QWEN38.scale), kernel, QWEN38);
    // The graph's one-row plan decodes; a one-row window takes the folded kernel.
    failures.push(...compareSteps("Kv4Head256Cache [divergent: graph's one-row plan]", pair, 1, [1],
      (c, k, v, q) => oldM4ProRead(c, k, v, q, QWEN38.scale), kernel, QWEN38));
    expect(failures).toEqual([]);
  } finally { disposeResources(pair); }
}, 60_000);

test.skipIf(!M4PRO)("GroupedHeadsKv4Cache: the grouped-heads kernel at depth-2 verify shapes, 8192+ keys", () => {
  const failures: string[] = [];
  const kernel: NewKernel = phase => phase === "window" ? "grouped" : "unfused";
  for (const lengths of [[8200], [8200, 8200], [8200, 8263]]) {
    const [a, b] = soloRows(() => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), lengths, QWEN38);
    const pair: [BatchedQuantizedKVCache, GroupedHeadsKv4Cache] = [new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), new GroupedHeadsKv4Cache()];
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      // Its own kernel is what the unfused dispatch ran at these shapes.
      failures.push(...compareSteps(`GroupedHeadsKv4Cache [${lengths}]`, pair, lengths.length, [3, "D", 3, 3, "D", 3],
        (c, k, v, q) => oldRead(c, null, k, v, q, true, QWEN38.scale), kernel, QWEN38));
    } finally { disposeResources([...pair, ...a, ...b]); }
  }
  expect(failures).toEqual([]);
}, 120_000);

test.skipIf(!M4PRO)("GroupedHeadsKv4Cache below 8192 keys: grouped where the old dispatch was not (recorded)", () => {
  const kernel: NewKernel = phase => phase === "window" ? "grouped" : "unfused";
  const failures: string[] = [];
  for (const lengths of [[700], [4000, 4100]]) {
    const [a, b] = soloRows(() => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), lengths, QWEN38);
    const pair: [BatchedQuantizedKVCache, GroupedHeadsKv4Cache] = [new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), new GroupedHeadsKv4Cache()];
    try {
      pair[0].mergeRows(a); pair[1].mergeRows(b);
      failures.push(...compareSteps(`GroupedHeadsKv4Cache below 8192 [${lengths}]`, pair, lengths.length, [3, 3],
        (c, k, v, q) => oldRead(c, null, k, v, q, true, QWEN38.scale), kernel, QWEN38));
    } finally { disposeResources([...pair, ...a, ...b]); }
  }
  expect(failures).toEqual([]);
}, 60_000);

// --- The deprecated dispatch for today's callers -------------------------------------------------

test.skipIf(!M4PRO)("quantizedSdpaUnfused without the device check, at the grouped-heads shape (recorded)", () => {
  const failures: string[] = [];
  for (const [B, N] of [[1, 8200], [2, 9000]] as const) {
    const [k, v] = kv(B, N, QWEN38);
    using q = query(B, 3, QWEN38);
    const kq = ops.quantize(k, 64, 4), vq = ops.quantize(v, 64, 4);
    k.dispose(); v.dispose();
    try {
      const mask: Mask = { mode: "causal", arr: null };
      using before = oldUnfused(q, kq, vq, QWEN38.scale, mask, 64, 4);
      using after = quantizedSdpaUnfused(q, kq, vq, QWEN38.scale, mask, 64, 4);
      const failure = record(`quantizedSdpaUnfused B${B} N${N} window 3 (current callers)`, maxDiff(after, before), "grouped", "unfused");
      if (failure) failures.push(failure);
    } finally { disposeTriple(kq); disposeTriple(vq); }
  }
  expect(failures).toEqual([]);
}, 60_000);

test("quantizedSdpa still reads MLX_BUN_NO_FUSED_SDPA: today's callers compute what they did", () => {
  const failures: string[] = [];
  for (const noFused of [false, true]) for (const [bits, groupSize] of [[4, 64], [8, 64]])
    for (const [L, N] of [[3, 300], [37, 600], [200, 1200]] as const) {
      const [k, v] = kv(1, N);
      using q = query(1, L);
      const kq = ops.quantize(k, groupSize!, bits!), vq = ops.quantize(v, groupSize!, bits!);
      k.dispose(); v.dispose();
      try {
        const mask: Mask = { mode: "causal", arr: null };
        const before = oldQuantizedSdpa(q, kq, vq, SCALE, mask, groupSize!, bits!, noFused);
        using reference = before.out;
        using after = withRuntimeConfig(createRuntimeConfig({ ...runtimeConfig().values, MLX_BUN_NO_FUSED_SDPA: noFused ? "1" : undefined }),
          () => quantizedSdpa(q, kq, vq, SCALE, mask, groupSize!, bits!));
        const failure = record(`quantizedSdpa ${bits}b g${groupSize} window ${L} over ${N} flag ${noFused ? "1" : "unset"}`,
          maxDiff(after, reference), before.kernel, before.kernel);
        if (failure) failures.push(failure);
      } finally { disposeTriple(kq); disposeTriple(vq); }
    }
  expect(failures).toEqual([]);
});

test("tiledAffineKernels and tiledCausalAffineKernels refuse a configuration the tiled port does not take", () => {
  for (const [bits, groupSize, dtype] of [[3, 64, Dtype.bfloat16], [4, 16, Dtype.bfloat16], [4, 64, Dtype.float32]] as const) {
    expect(() => tiledAffineKernels(bits, groupSize, dtype)).toThrow("tiledAffineKernels");
    expect(() => tiledCausalAffineKernels(bits, groupSize, dtype)).toThrow("tiledCausalAffineKernels");
  }
  for (const [bits, groupSize, dtype] of [[4, 32, Dtype.float16], [8, 128, Dtype.bfloat16]] as const) {
    expect(() => tiledAffineKernels(bits, groupSize, dtype)).not.toThrow();
    expect(() => tiledCausalAffineKernels(bits, groupSize, dtype)).not.toThrow();
  }
  expect(() => unfusedAffineKernels(3, 64, Dtype.float32)).not.toThrow();
});

// --- The mask memo ------------------------------------------------------------------------------

test("mask memo: one causal matrix per window forward over a 4-layer cache set, none for decode", () => {
  const masks = new AttentionMasks();
  const layers = Array.from({ length: 4 }, () => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16), masks));
  const reference = Array.from({ length: 4 }, () => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)));
  const held: AttentionRead[] = [];
  try {
    const forward = (L: number) => {
      const diffs: number[] = [];
      for (let layer = 0; layer < 4; layer++) {
        const [k, v] = kv(1, L);
        using q = query(1, L);
        try {
          using expected = oldRead(reference[layer]!, null, k, v, q, true).out;
          const read = L === 1 ? layers[layer]!.appendDecode(k, v) : layers[layer]!.appendWindow(k, v);
          held.push(read);
          using actual = read.attend(q, SCALE);
          diffs.push(maxDiff(actual, expected));
        } finally { k.dispose(); v.dispose(); }
      }
      return diffs;
    };
    expect(Math.max(...forward(37))).toBe(0);
    expect(masks.builds).toBe(1);
    expect(Math.max(...forward(1))).toBe(0);
    expect(masks.builds).toBe(1);
    expect(Math.max(...forward(3))).toBe(0);
    expect(masks.builds).toBe(2);
    // A read from an earlier forward still attends after its mask was replaced.
    using q = query(1, 37);
    using before = held[0]!.attend(q, SCALE);
    before.eval();
    masks.clear();
    using after = held[0]!.attend(q, SCALE);
    expect(maxDiff(after, before)).toBe(0);
  } finally { disposeResources([...held, ...layers, ...reference]); }
});

test("mask memo: per-row and ring masks once per forward across interleaved batched layers", () => {
  const masks = new AttentionMasks();
  const [full] = soloRows(() => new QuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), [5, 17]);
  const [ring] = soloRows(() => new RotatingQuantizedKVCache(WINDOW, 64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16)), [5, 40]);
  const layers: Array<BatchedRotatingQuantCache | BatchedQuantizedKVCache> = [BatchedRotatingQuantCache.empty(WINDOW, 64, 4, [], masks),
    new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16), masks), BatchedRotatingQuantCache.empty(WINDOW, 64, 4, [], masks), new BatchedQuantizedKVCache(64, 4, unfusedAffineKernels(4, 64, Dtype.bfloat16), masks)];
  try {
    for (const [i, layer] of layers.entries()) layer.mergeRows(i % 2 ? full : ring);
    for (const forward of [3, 1, 1]) {
      const before = masks.builds;
      for (const layer of layers) {
        const [k, v] = kv(2, forward);
        try { (forward === 1 ? layer.appendDecode(k, v) : layer.appendWindow(k, v)).dispose(); }
        finally { k.dispose(); v.dispose(); }
      }
      expect(masks.builds - before).toBe(2);
    }
  } finally { disposeResources([...layers, ...full, ...ring]); }
});

test("empty batches keep their layout's masks and kernels", () => {
  const masks = new AttentionMasks(), kernels = unfusedAffineKernels(4, 64, Dtype.bfloat16);
  const sources = [new BatchedQuantizedKVCache(64, 4, kernels, masks), new PaddedQuantKVRows(64, 4, kernels, masks)];
  const grouped = new GroupedHeadsKv4Cache(masks);
  const empties = [...sources.map(source => source.makeEmptyBatch()), grouped.makeEmptyBatch()];
  try {
    for (const layout of empties.slice(0, 2)) { expect(layout.masks).toBe(masks); expect(layout.kernels).toBe(kernels); }
    expect(empties[2]).toBeInstanceOf(GroupedHeadsKv4Cache);
    expect(empties[2]!.kernels).toBe(grouped.kernels);
  } finally { disposeResources([...sources, grouped, ...empties]); }
});

test("bit-identity report", () => {
  for (const { label, diff, divergence } of outcomes)
    console.log(`${divergence === null ? "identical" : "DIFFERS  "} maxDiff=${diff} ${label}${divergence ? ` (${divergence})` : ""}`);
  expect(outcomes.length).toBeGreaterThan(0);
});
