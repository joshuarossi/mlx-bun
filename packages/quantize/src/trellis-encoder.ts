// Packed-Trellis tensor encoders: fold-basis weight in, packed codes + fp16 row
// scales out. Two objectives share one Viterbi codec:
//
//   * `encode`      unweighted squared error (QTIP TCQ), one tail-biting
//                   trellis per T-block of each coded row;
//   * `encodeLdlq`  BlockLDLQ error feedback against a per-layer Hessian
//                   factor L, a port of Cornell-RelaxML/qtip lib/algo/ldlq.py
//                   at block size T with `for_kernel=False` semantics — QTIP's
//                   own non-kernel path, which quantizes a trellis of length T
//                   along the INPUT dim with one independent sequence per
//                   output row. Choosing T = 256 makes the LDLQ column blocks
//                   coincide with the trellis blocks, so this arm changes ONLY
//                   the distortion objective.
//
// The packed form of a coded tensor: `.weight` uint32 [rows, C·k/32] with the
// coded axis LAST (axis-0 tensors are stored transposed), reversed-time symbols
// in a tail-biting window, plus `.scales` fp16 [rows].
//
// Handle discipline matters here: an undisposed view pins its parent buffer,
// which is what OOM-killed the first LDLQ build at 86 GiB.

import { ptr, read } from "bun:ffi";
import { MlxArray as Arr, cpuStream, gpuStream, type MlxArray } from "@mlx-bun/mlx/array";
import { C, Dtype, activeMemory, clearCache } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { TRELLIS_L, TRELLIS_T, Trellis, packStates, wordsPerBlock } from "./trellis";

const S = gpuStream;

/** The packed form of a coded tensor. */
export interface PackedTrellisTensor {
  codes: MlxArray;
  scales: MlxArray;
}

export interface LdlqEncoding extends PackedTrellisTensor {
  /** The feedback guard fired: the codes are the unweighted encoding instead. */
  tripped: boolean;
}

/** tq-gptq.py's guard shape: the weighted path must stay within this multiple
 *  of the unweighted normalized magnitude. */
const LDLQ_CEILING = 4.0;
/** Hard abort when MLX's live allocation runs away: turns a silent OOM kill
 *  into a diagnosable failure. A down_proj tensor's working set is ~4 GiB. */
const DEFAULT_MEMORY_ABORT = 20 * 2 ** 30;

export interface TrellisEncoderOptions {
  /** Coded rows per Viterbi batch (a memory knob; never changes the codes). */
  batch?: number;
  /** Abort LDLQ when MLX's live allocation exceeds this many bytes. */
  memoryAbortBytes?: number;
}

/** Load the `L` tensor of a Hessian factor file (a safetensors with one tensor). */
export function loadHessianFactor(path: string): MlxArray {
  const slot = new BigUint64Array([C.mlx_map_string_to_array_new()]);
  const meta = new BigUint64Array([C.mlx_map_string_to_string_new()]);
  try {
    if (C.mlx_load_safetensors(ptr(slot), ptr(meta), ptr(Buffer.from(path + "\0", "utf8")), cpuStream) !== 0)
      throw new Error(`mlx_load_safetensors(${path}) failed`);
    const out = new BigUint64Array([C.mlx_array_new()]);
    if (C.mlx_map_string_to_array_get(ptr(out), read.u64(ptr(slot), 0), ptr(Buffer.from("L\0", "utf8"))) !== 0)
      throw new Error(`tensor L missing from ${path}`);
    return new Arr(read.u64(ptr(out), 0));
  } finally {
    C.mlx_map_string_to_string_free(read.u64(ptr(meta), 0));
    C.mlx_map_string_to_array_free(read.u64(ptr(slot), 0));
  }
}

/** contiguous(transpose(x)) with the intermediate VIEW handle disposed. */
function tContig(x: MlxArray): MlxArray {
  const t = ops.transposeAxes(x, [1, 0], S);
  const c = ops.contiguous(t, S);
  t.dispose();
  return c;
}

/** Owned contiguous copy of a row range; the slice view is disposed. */
function rows(a: MlxArray, r0: number, r1: number, cols: number): MlxArray {
  const sl = a.slice([r0, 0], [r1, cols], S);
  const c = ops.contiguous(sl, S);
  sl.dispose();
  return c;
}

function maxAbs(a: MlxArray): number {
  const ab = ops.abs(a, S);
  const flat = ops.reshape(ab, [a.shape[0]! * a.shape[1]!], S);
  const mx = ops.maxAxis(flat, 0, false, S);
  const v = mx.toFloat32()[0]!;
  ab.dispose(); flat.dispose(); mx.dispose();
  return v;
}

/** [T, m] LDLQ tile <-> [m, T] trellis batch. axis 1: the trellis axis IS the
 *  LDLQ axis (transpose); axis 0 (down_proj): the tile splits into T-long runs
 *  down `m` (reshape only). Both reproduce the unweighted block partition. */
function tileToBatch(x: MlxArray, axis: 0 | 1, m: number, T: number): MlxArray {
  return axis === 1 ? tContig(x) : ops.reshape(x, [m, T], S);
}
function batchToTile(b: MlxArray, axis: 0 | 1, m: number, T: number): MlxArray {
  return axis === 1 ? tContig(b) : ops.reshape(b, [T, m], S);
}

/** Per-batch-row scale for one LDLQ block. gate/up: indexed by output row
 *  (block-independent). down_proj: indexed by input column, each of which owns
 *  m/T consecutive batch rows. */
function blockScale(scale: MlxArray, axis: 0 | 1, k: number, m: number, T: number): MlxArray {
  if (axis === 1) return scale;
  const sl = scale.slice([k * T, 0], [(k + 1) * T, 1], S);
  const z = ops.zeros([T, m / T], Dtype.float32, S);
  const b = ops.add(z, sl, S);
  const out = ops.reshape(b, [m, 1], S);
  sl.dispose(); z.dispose(); b.dispose();
  return out;
}

/** Pack one T-block of states (row `i` of a [B,T] host state matrix) into `out`
 *  at word offset `at`. */
function packOne(states: Int32Array, i: number, T: number, k: number, out: Uint32Array, at: number): void {
  packStates(states.subarray(i * T, (i + 1) * T), 1, T, k, out.subarray(at, at + wordsPerBlock(T, k)));
}

/** One codec per distinct k (the L=12 1MAD codebook is shared; k only changes
 *  the branching), created lazily so a uniform run builds exactly one. */
export class TrellisEncoder {
  readonly L = TRELLIS_L;
  readonly T = TRELLIS_T;
  readonly #codecs = new Map<number, Trellis>();
  readonly #batch: number;
  readonly #memoryAbort: number;

  constructor(opts: TrellisEncoderOptions = {}) {
    this.#batch = opts.batch ?? 16384;
    this.#memoryAbort = opts.memoryAbortBytes ?? DEFAULT_MEMORY_ABORT;
  }

  codec(k: number): Trellis {
    let t = this.#codecs.get(k);
    if (!t) this.#codecs.set(k, (t = new Trellis({ L: this.L, K: k, T: this.T, code: "1mad", tailBiting: true })));
    return t;
  }

  dispose(): void {
    for (const t of this.#codecs.values()) t.dispose();
    this.#codecs.clear();
  }

  /** Unweighted encoding of a folded [out, in] weight along `axis`. */
  encode(folded: MlxArray, axis: 0 | 1, k: number): PackedTrellisTensor {
    const f32 = folded.astype(Dtype.float32, S);
    let X = f32;
    if (axis === 0) {
      const t = ops.transposeAxes(f32, [1, 0], S);
      X = ops.contiguous(t, S);
      t.dispose(); f32.dispose();
    }
    ops.evalAll([X]);
    const { rec, codes, scales } = this.codec(k).fakeQuantRowsPacked(X, this.#batch);
    rec.dispose();
    X.dispose();
    clearCache();
    return { codes, scales };
  }

  /** The per-coded-row fp16 scale, computed on the ORIGINAL folded weight so
   *  the weighted and unweighted arms share it exactly. In the LDLQ orientation:
   *  axis 1 -> [m,1] (per output row); axis 0 -> [n,1] (per input column).
   *  `Wt` is [n, m]. */
  #rowScale(Wt: MlxArray, axis: 0 | 1, k: number): MlxArray {
    const src = axis === 1 ? tContig(Wt) : Wt;
    const sq = ops.square(src, S);
    const ms = ops.meanAxis(sq, 1, true, S);
    const rms = ops.sqrt(ms, S);
    const inv = ops.mulScalar(rms, 1 / this.codec(k).lutRms, S);
    const zero = Arr.fromFloat32(new Float32Array([0]), []);
    const one = Arr.fromFloat32(new Float32Array([1]), []);
    const isz = ops.equal(inv, zero, S);
    const guarded = ops.where(isz, one, inv, S);
    const s16 = guarded.astype(Dtype.float16, S);
    const out = s16.astype(Dtype.float32, S);
    for (const a of [sq, ms, rms, inv, zero, one, isz, guarded, s16]) a.dispose();
    if (axis === 1) src.dispose();
    ops.evalAll([out]);
    return out;
  }

  /** BlockLDLQ encoding of a folded weight against Hessian factor `Lf`
   *  ([n, n], n = the LDLQ dim). Falls back to the unweighted encoding, with
   *  `tripped` set, when the feedback grows past the guard ceiling. */
  encodeLdlq(folded: MlxArray, axis: 0 | 1, Lf: MlxArray, k: number): LdlqEncoding {
    const T = this.T;
    const f32 = folded.astype(Dtype.float32, S);
    const Wt = tContig(f32); // [n, m]
    f32.dispose();
    ops.evalAll([Wt]);
    const [n, m] = Wt.shape as [number, number];
    if (Lf.shape[0] !== n) throw new Error(`L dim ${Lf.shape[0]} != LDLQ dim ${n}`);
    const K = n / T;
    const scale = this.#rowScale(Wt, axis, k);

    // Guard ceiling from the UNWEIGHTED normalized weight.
    let ceiling: number;
    {
      const s0 = blockScale(scale, axis, 0, m, T);
      const w0 = rows(Wt, 0, T, m);
      const b0 = tileToBatch(w0, axis, m, T);
      const nrm = ops.div(b0, s0, S);
      ceiling = LDLQ_CEILING * maxAbs(nrm);
      w0.dispose(); b0.dispose(); nrm.dispose();
      if (axis === 0) s0.dispose();
    }

    let prod = ops.zeros([n, m], Dtype.float32, S);
    let What = ops.zeros([n, m], Dtype.float32, S);
    ops.evalAll([prod, What]);
    let tripped = false;
    // Packed geometry: gate/up (axis 1) rows = m output rows, one block per LDLQ
    // block; down (axis 0) rows = n input columns, m/T blocks each (batch row i
    // of block b = input col b·T + i div (m/T), out-block i mod (m/T)).
    const wpb = wordsPerBlock(T, k);
    const codeRows = axis === 1 ? m : n;
    const blocksPerRow = axis === 1 ? K : m / T;
    const packed = new Uint32Array(codeRows * blocksPerRow * wpb);
    const codec = this.codec(k);

    for (let b = K - 1; b >= 0; b--) {
      const w = rows(Wt, b * T, (b + 1) * T, m);
      const p = rows(prod, b * T, (b + 1) * T, m);
      const x = ops.add(w, p, S);
      p.dispose();
      const s = blockScale(scale, axis, b, m, T);
      const batch = tileToBatch(x, axis, m, T);
      const xn = ops.div(batch, s, S);
      ops.evalAll([xn]);
      batch.dispose(); x.dispose();

      const peak = maxAbs(xn);
      if (!Number.isFinite(peak) || peak > ceiling) {
        tripped = true;
        for (const y of [w, xn]) y.dispose();
        if (axis === 0) s.dispose();
        break;
      }

      // Chunked encode that keeps the STATES: pack them, then decode for the
      // error feedback (the same map encodeDecode applies).
      const parts: MlxArray[] = [];
      for (let r0 = 0; r0 < m; r0 += this.#batch) {
        const r1 = Math.min(m, r0 + this.#batch);
        const sl = xn.slice([r0, 0], [r1, T], S);
        const chunk = ops.contiguous(sl, S);
        sl.dispose();
        ops.evalAll([chunk]);
        const idx = codec.encodeStates(chunk);
        chunk.dispose();
        const u32 = idx.astype(Dtype.uint32, S);
        const raw = u32.rawBytes();
        u32.dispose();
        const st = new Int32Array(raw.buffer, raw.byteOffset, raw.byteLength / 4);
        for (let i = 0; i < r1 - r0; i++) {
          const bi = r0 + i;
          const row = axis === 1 ? bi : b * T + Math.floor(bi / (m / T));
          const blk = axis === 1 ? b : bi % (m / T);
          packOne(st, i, T, k, packed, (row * blocksPerRow + blk) * wpb);
        }
        parts.push(codec.decodeStates(idx));
        idx.dispose();
      }
      const rec = parts.length === 1 ? parts[0]! : ops.concatAxis(parts, 0, S);
      if (parts.length > 1) for (const part of parts) part.dispose();
      ops.evalAll([rec]);
      xn.dispose();
      const hatB = ops.mul(rec, s, S);
      rec.dispose();
      if (axis === 0) s.dispose();
      const hat = batchToTile(hatB, axis, m, T);
      hatB.dispose();

      // The error fed forward is (W − Ŵ) against the ORIGINAL weight, per ldlq.py.
      const err = ops.sub(w, hat, S);
      w.dispose();
      const nw = ops.sliceUpdate(What, hat, [b * T, 0], [(b + 1) * T, m], S);
      What.dispose(); hat.dispose();
      What = nw;

      // prod += L[block, :]ᵀ @ err        ([n,T] @ [T,m])
      const Lb = rows(Lf, b * T, (b + 1) * T, n);
      const Lt = tContig(Lb);
      const contrib = ops.matmul(Lt, err, S);
      const next = ops.add(prod, contrib, S);
      prod.dispose();
      prod = next;
      ops.evalAll([prod, What]);
      for (const y of [err, Lb, Lt, contrib]) y.dispose();
      clearCache();
      if (activeMemory() > this.#memoryAbort)
        throw new Error(
          `LDLQ leak guard: mlx active ${(activeMemory() / 2 ** 30).toFixed(1)} GiB > ` +
          `${(this.#memoryAbort / 2 ** 30).toFixed(0)} GiB at block ${b} — aborting instead of OOM-killing`,
        );
    }

    prod.dispose();
    if (tripped) {
      scale.dispose();
      Wt.dispose(); What.dispose();
      clearCache();
      return { ...this.encode(folded, axis, k), tripped: true };
    }
    Wt.dispose(); What.dispose();
    // The fp16-rounded per-coded-row scale in LDLQ orientation is exactly the
    // packed rows' order.
    const s16 = scale.astype(Dtype.float16, S);
    scale.dispose();
    const scales = ops.reshape(s16, [codeRows], S);
    s16.dispose();
    ops.evalAll([scales]);
    const codes = Arr.fromBytesCopy(
      new Uint8Array(packed.buffer, packed.byteOffset, packed.byteLength),
      [codeRows, blocksPerRow * wpb], Dtype.uint32,
    );
    clearCache();
    return { codes, scales, tripped: false };
  }
}
