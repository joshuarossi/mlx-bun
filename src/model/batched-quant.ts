// Batched QUANTIZED KV for continuous batching (Phase 3.1 of
// docs/design/unified-engine-frontier-plan.md) — the quantized twins of
// batched-mask.ts's dynamic-B ops, over (packed, scales, biases) triples.
//
// Why this is safe surgery: mlx quantization packs along HEAD_DIM (the last
// axis; packed last-dim = D/(32/bits), scales/biases last-dim = D/groupSize),
// so the TOKEN axis (axis 2) stays token-granular in all three tensors —
// left-padding, concat, and row-filter at token granularity never touch a
// quantization group. Pad columns hold zeros; they are never attended (the
// padding mask covers them) and never dequantized into anything a real row
// reads. QuantizedKVCache.updateAndFetchQuantized already handles arbitrary
// starting widths (it trims to `offset` and regrows in STEP chunks), so a
// merged exact-width buffer needs no STEP alignment here.
//
// Composition contract (the L2 oracle binds per ROW): each joiner solo-
// prefills with the SAME per-layer conversion the serial path runs
// (maybeQuantizeKv at chunk boundaries — see BatchScheduler.#quantizeSolo),
// so a row's quantized bytes are bit-exact vs serial `--kv-quant config` by
// construction; this module only re-arranges those bytes across the batch
// axis. Gates: tests/batched-kv-quant-parity.test.ts.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { QuantizedKVCache, type Mask } from "./gemma4-base";
import { buildBatchedDecodeMask } from "./batched-mask";

export interface QuantRow {
  keys: ops.QuantizedTensor;
  values: ops.QuantizedTensor;
}

const disposeTriple = (t: ops.QuantizedTensor): void => {
  t.packed.dispose();
  t.scales.dispose();
  t.biases.dispose();
};

/** Apply an MlxArray op to each member of a triple. Each tensor keeps its
 *  OWN last-dim (packed vs scales/biases differ) — helpers must never share
 *  one `D` across the triple (recon hazard, 2026-07-05). */
const tripleMap = (
  t: ops.QuantizedTensor, f: (a: MlxArray) => MlxArray,
): ops.QuantizedTensor => ({ packed: f(t.packed), scales: f(t.scales), biases: f(t.biases) });

/** Left-pad one tensor of a triple by `pad` tokens (axis 2) with zeros of
 *  its own dtype/last-dim. pad=0 returns a fresh full view (mirrors
 *  batched-mask.ts leftPadTo so ownership is uniform). */
const leftPadTo = (a: MlxArray, pad: number): MlxArray => {
  if (pad === 0) return a.slice([0, 0, 0, 0], a.shape as number[]);
  const [B, H, , D] = a.shape as [number, number, number, number];
  const z = ops.zeros([B, H, pad, D], a.dtype);
  const out = ops.concatAxis([z, a], 2);
  z.dispose();
  return out;
};

/** Quantized twin of mergeKVRows: stack N single-row quantized KV slices
 *  into one left-padded [B,H,Smax,*] triple pair. Caller owns the result;
 *  input rows are not disposed. */
export function mergeQuantRows(rows: QuantRow[]): {
  keys: ops.QuantizedTensor; values: ops.QuantizedTensor; leftPad: number[]; width: number;
} {
  const lens = rows.map((r) => r.keys.packed.shape[2]!);
  const width = Math.max(...lens);
  const leftPad = lens.map((l) => width - l);
  const padded = rows.map((r, i) => ({
    keys: tripleMap(r.keys, (a) => leftPadTo(a, leftPad[i]!)),
    values: tripleMap(r.values, (a) => leftPadTo(a, leftPad[i]!)),
  }));
  const cat = (pick: (r: QuantRow) => ops.QuantizedTensor): ops.QuantizedTensor => ({
    packed: ops.concatAxis(padded.map((r) => pick(r).packed), 0),
    scales: ops.concatAxis(padded.map((r) => pick(r).scales), 0),
    biases: ops.concatAxis(padded.map((r) => pick(r).biases), 0),
  });
  const keys = cat((r) => r.keys);
  const values = cat((r) => r.values);
  for (const r of padded) { disposeTriple(r.keys); disposeTriple(r.values); }
  return { keys, values, leftPad, width };
}

/** Quantized twin of extendKVRows: append ONE right-justified quantized row
 *  to an existing batched triple pair in one pad + one B-axis concat.
 *  Existing pads grow, never shrink (mlx-lm extend semantics). Caller owns
 *  the result; inputs are not disposed. */
export function extendQuantRows(
  keys: ops.QuantizedTensor, values: ops.QuantizedTensor, leftPad: number[], row: QuantRow,
): { keys: ops.QuantizedTensor; values: ops.QuantizedTensor; leftPad: number[]; width: number } {
  const S = keys.packed.shape[2]!;
  const Lr = row.keys.packed.shape[2]!;
  const width = Math.max(S, Lr);
  const bk = tripleMap(keys, (a) => leftPadTo(a, width - S));
  const bv = tripleMap(values, (a) => leftPadTo(a, width - S));
  const rk = tripleMap(row.keys, (a) => leftPadTo(a, width - Lr));
  const rv = tripleMap(row.values, (a) => leftPadTo(a, width - Lr));
  const cat = (b: ops.QuantizedTensor, r: ops.QuantizedTensor): ops.QuantizedTensor => ({
    packed: ops.concatAxis([b.packed, r.packed], 0),
    scales: ops.concatAxis([b.scales, r.scales], 0),
    biases: ops.concatAxis([b.biases, r.biases], 0),
  });
  const outK = cat(bk, rk);
  const outV = cat(bv, rv);
  for (const t of [bk, bv, rk, rv]) disposeTriple(t);
  return {
    keys: outK, values: outV,
    leftPad: [...leftPad.map((p) => p + (width - S)), width - Lr],
    width,
  };
}

/** Quantized twin of extractKVRow (mlx-lm BatchKVCache.extract,
 *  models/cache.py:1080, over triples): pull row `i` past its left padding
 *  into a fresh SERIAL QuantizedKVCache with OWNED contiguous copies.
 *  Token-axis slicing is byte-safe because quantization packs along
 *  HEAD_DIM (file header) — a row's quantized bytes come out exactly as
 *  the serial oracle wrote them. */
export function extractQuantRow(
  cache: QuantizedKVCache, leftPad: number, i: number,
): QuantizedKVCache {
  if (!cache.keys || !cache.values) throw new Error("extractQuantRow: empty cache");
  const S = cache.offset;
  const cut = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
    tripleMap(t, (a) => {
      const [, H, , D] = a.shape as [number, number, number, number];
      const view = a.slice([i, 0, leftPad, 0], [i + 1, H, S, D]);
      const own = ops.copyOf(view); // TRUE copy: contiguous(view) is a no-op VIEW when already contiguous — pins the source buffer (2026-08-20 DeltaNet conv leak class)
      view.dispose();
      return own;
    });
  const out = new QuantizedKVCache(cache.groupSize, cache.bits);
  out.restoreState(cut(cache.keys), cut(cache.values), S - leftPad);
  return out;
}

/** Quantized twin of filterKVRows: keep `keep` rows along the batch axis.
 *  Caller owns the result; inputs are not disposed. */
export function filterQuantRows(
  keys: ops.QuantizedTensor, values: ops.QuantizedTensor, keep: number[],
): { keys: ops.QuantizedTensor; values: ops.QuantizedTensor } {
  const idx = MlxArray.fromInt32(Int32Array.from(keep), [keep.length]);
  const take = (t: ops.QuantizedTensor): ops.QuantizedTensor =>
    tripleMap(t, (a) => ops.takeAxis(a, idx, 0));
  const k = take(keys);
  const v = take(values);
  idx.dispose();
  return { keys: k, values: v };
}

/** Per-step cache wrapper for batched QUANTIZED decode with left-padded
 *  rows — the quantized twin of BatchedDecodeMaskCache. Subclasses
 *  QuantizedKVCache so attention's `instanceof` dispatch routes to
 *  quantizedSdpa exactly as for a serial quantized cache; delegates KV
 *  storage to the persistent batched inner and overrides the two things a
 *  padded batch needs: the padding-aware decode mask and per-row RoPE
 *  positions. Ephemeral — the scheduler builds a fresh wrapper each step
 *  and calls releaseRopeArr() after (never dispose(), which would free the
 *  inner). Rope is captured ONCE per step before updateAndFetch (attention
 *  reads it pre-write; see minicpm5.ts LlamaAttention.forward), so an
 *  eagerly-built [B] position array is exact. */
export class BatchedQuantDecodeMaskCache extends QuantizedKVCache {
  override readonly ropeOffsetArr: MlxArray;

  constructor(
    private readonly inner: QuantizedKVCache,
    private readonly B: number,
    private readonly leftPad: number[],
  ) {
    super(inner.groupSize, inner.bits);
    this.offset = inner.offset;
    const data = new Int32Array(B);
    for (let b = 0; b < B; b++) data[b] = inner.offset - leftPad[b]!;
    this.ropeOffsetArr = MlxArray.fromInt32(data, [B]);
  }

  override updateAndFetchQuantized(k: MlxArray, v: MlxArray): [ops.QuantizedTensor, ops.QuantizedTensor] {
    const r = this.inner.updateAndFetchQuantized(k, v);
    this.offset = this.inner.offset;
    return r;
  }

  override makeMask(N: number, _windowSize: number | null): Mask {
    // Same convention as BatchedDecodeMaskCache: built pre-write, S spans
    // offset + N; quantizedSdpaUnfused expands it for the 5-D GQA scores.
    const S = this.inner.offset + N;
    return { mode: "array", arr: buildBatchedDecodeMask(this.B, N, S, this.leftPad, null) };
  }

  /** Free the per-step RoPE array WITHOUT touching the persistent inner —
   *  name and signature must match the scheduler's structural
   *  `(c as { releaseRopeArr?: () => void })` cast. */
  releaseRopeArr(): void {
    this.ropeOffsetArr.dispose();
  }

  override state(): MlxArray[] {
    return this.inner.state();
  }
  override isTrimmable(): boolean {
    return this.inner.isTrimmable();
  }
  override trim(n: number): void {
    this.inner.trim(n);
  }
  override dispose(): void {
    this.inner.dispose();
  }
}
