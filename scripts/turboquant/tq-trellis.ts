// QTIP-style bitshift trellis-coded quantization (TCQ), fake-quant, on MLX.
//
// Reference (verified against source, not memory):
//   Tseng et al., "QTIP: Quantization with Trellises and Incoherence Processing",
//   arXiv:2406.11235v3 — Fig. 2 (bitshift trellis), §3.1.1 (computed codes),
//   §3.2 + Algorithm 4 (tail-biting approximation), Table 2 (the (12,k,1)
//   tail-biting distortion numbers this file's --validate reproduces).
//   github.com/Cornell-RelaxML/qtip @ main, lib/codebook/bitshift.py.
//
// Bitshift trellis (L, k, V=1). State = L bits. Successor n of state p must
// satisfy `n >> k == p & (2^(L-k) - 1)` (Fig. 2: "the 2^kV nodes that share
// their top L-kV bits with its bottom L-kV bits"), i.e.
//     n = ((p << k) | b) mod 2^L,   b in [0, 2^k)
// so the predecessors of n are { (n >> k) + m·2^(L-k) : m in [0, 2^k) }.
// The emitted value for state s is a computed pseudo-Gaussian f(s) — no
// lookup table on the decode side (we materialize one anyway for the encoder).
//
// Encoder = Viterbi over 2^L states, UNWEIGHTED squared error (no Hessian /
// LDLQ — v2 lever), batched over thousands of 256-weight blocks at a time.
// Sign convention: we MAXIMIZE g = -(cost), and drop the per-step constant
// x², so the emission term is a single addmm:  g_err = -lut² + 2·x·lut.
// Dropping x² shifts every path in a block by the same amount, so argmax
// decisions and the traceback are unchanged.

import { MlxArray as Arr, gpuStream, type MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache, activeMemory, cacheMemory, peakMemory } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

const S = gpuStream;

// ------------------------------------------------------------- codebooks ---

/** QTIP `decode_1mad` (lib/codebook/bitshift.py) evaluated over [0, 2^L).
 *  x = (x·34038481 + 76625530) mod 2^32; y = Σ bytes(x) − 510; y / 147.800537109375.
 *  (510 = 2·255 = E[Σ of 4 uniform bytes]; 147.8005… ≈ √(4·(2^16−1)/12) is the
 *  std of that sum, so the code is unit-variance by construction.) */
export function lut1mad(L: number): Float32Array {
  const n = 1 << L;
  const out = new Float32Array(n);
  const M = (1n << 32n) - 1n;
  for (let i = 0; i < n; i++) {
    let x = BigInt(i) & M;
    x = (x * 34038481n + 76625530n) & M;
    const y =
      Number((x & 255n) + ((x >> 8n) & 255n) + ((x >> 16n) & 255n) + ((x >> 24n) & 255n)) - 510;
    out[i] = y / 147.800537109375;
  }
  return out;
}

/** QTIP `decode_3inst`: two bf16-shaped 16-bit lanes masked out of one
 *  multiply-add, xor'd with an exponent mask, read as fp16 and summed. */
export function lut3inst(L: number): Float32Array {
  const n = 1 << L;
  const out = new Float32Array(n);
  const M = (1n << 32n) - 1n;
  const a = 89226354n, b = 64248484n, fpmask = 996162400n;
  const half = (1n << 15n) + ((1n << 12n) - 1n);
  const mask = (half << 16n) + half;
  const f16 = (bits: number): number => {
    const sgn = bits & 0x8000 ? -1 : 1;
    const exp = (bits >> 10) & 0x1f;
    const man = bits & 0x3ff;
    if (exp === 0) return sgn * man * 2 ** -24;
    if (exp === 31) return sgn * (man ? NaN : Infinity);
    return sgn * (1 + man / 1024) * 2 ** (exp - 15);
  };
  for (let i = 0; i < n; i++) {
    let x = BigInt(i) & M;
    x = (x * a + b) & M;
    const res = (mask & x) ^ fpmask;
    out[i] = f16(Number(res >> 16n) & 0xffff) + f16(Number(res & 0xffffn));
  }
  return out;
}

/** Pure-lookup random Gaussian trellis code (paper's RPTC) — the L-bit LUT is
 *  2^L iid N(0,1) draws. Used only as a codec-validation reference. */
export function lutRandom(L: number, seed = 0xc0ffee): Float32Array {
  const n = 1 << L;
  const out = new Float32Array(n);
  let s = seed >>> 0;
  const u = () => {
    s = (s + 0x9e3779b9) >>> 0;
    let z = s;
    z = Math.imul(z ^ (z >>> 16), 0x21f0aaad) >>> 0;
    z = Math.imul(z ^ (z >>> 15), 0x735a2d97) >>> 0;
    return ((z ^ (z >>> 15)) >>> 0) / 4294967296 + 2 ** -33;
  };
  for (let i = 0; i < n; i += 2) {
    const r = Math.sqrt(-2 * Math.log(u()));
    const t = 2 * Math.PI * u();
    out[i] = r * Math.cos(t);
    if (i + 1 < n) out[i + 1] = r * Math.sin(t);
  }
  return out;
}

// ----------------------------------------------------------------- codec ---

export type CodeName = "1mad" | "3inst" | "rand";

export interface TrellisCfg {
  L: number;          // state bits
  K: number;          // bits per weight (V = 1)
  T: number;          // block length (weights per tail-biting trellis)
  code: CodeName;
  tailBiting: boolean;
}

export class Trellis {
  readonly cfg: TrellisCfg;
  readonly nStates: number;
  readonly G: number;      // 2^K branches
  readonly J: number;      // 2^(L-K) predecessor groups
  readonly lutRms: number;
  /** [S] f32 code values, and the [1,S] row / -lut² row the encoder needs. */
  private lutFlat: MlxArray;
  private lutRow: MlxArray;
  private negLut2: MlxArray;
  private sHigh: MlxArray;   // [1,S] int32, state >> K
  private sLow: MlxArray;    // [1,S] int32, state & (J-1)
  private mrow: MlxArray;    // [1,G,1] uint8, branch index 0..G-1
  private sIdx: MlxArray;    // [1,S] int32, arange(S)
  private negOne: MlxArray;  // int32 scalar -1
  private kConst: MlxArray;  // int32 scalar K
  private jConst: MlxArray;  // int32 scalar J
  private negBig: MlxArray;  // f32 scalar -1e30

  constructor(cfg: TrellisCfg) {
    this.cfg = cfg;
    if (!Number.isInteger(cfg.K) || cfg.K < 1 || cfg.K >= cfg.L)
      throw new Error(`Trellis: K=${cfg.K} must be an integer in [1, L=${cfg.L})`);
    const n = (this.nStates = 1 << cfg.L);
    this.G = 1 << cfg.K;
    this.J = n >> cfg.K;
    const host =
      cfg.code === "1mad" ? lut1mad(cfg.L) : cfg.code === "3inst" ? lut3inst(cfg.L) : lutRandom(cfg.L);
    let ss = 0;
    for (const v of host) ss += v * v;
    this.lutRms = Math.sqrt(ss / n);

    this.lutFlat = Arr.fromFloat32(host, [n]);
    this.lutRow = ops.reshape(this.lutFlat, [1, n], S);
    const sq = ops.square(this.lutRow, S);
    this.negLut2 = ops.neg(sq, S);
    sq.dispose();

    const idx = new Int32Array(n);
    for (let i = 0; i < n; i++) idx[i] = i >> cfg.K;
    this.sHigh = Arr.fromInt32(idx, [1, n]);
    const idx2 = new Int32Array(n);
    for (let i = 0; i < n; i++) idx2[i] = i & (this.J - 1);
    this.sLow = Arr.fromInt32(idx2, [1, n]);

    const idx3 = new Int32Array(n);
    for (let i = 0; i < n; i++) idx3[i] = i;
    this.sIdx = Arr.fromInt32(idx3, [1, n]);
    this.negOne = Arr.fromInt32(new Int32Array([-1]), []);

    const mh = new Int32Array(this.G);
    for (let i = 0; i < this.G; i++) mh[i] = i;
    const m32 = Arr.fromInt32(mh, [1, this.G, 1]);
    this.mrow = m32.astype(Dtype.uint8, S);
    m32.dispose();

    this.kConst = Arr.fromInt32(new Int32Array([cfg.K]), []);
    this.jConst = Arr.fromInt32(new Int32Array([this.J]), []);
    this.negBig = Arr.fromFloat32(new Float32Array([-1e30]), []);
    ops.evalAll([this.lutFlat, this.lutRow, this.negLut2, this.sHigh, this.sLow, this.mrow, this.sIdx]);
  }

  dispose(): void {
    for (const a of [this.lutFlat, this.lutRow, this.negLut2, this.sHigh, this.sLow,
      this.mrow, this.sIdx, this.negOne, this.kConst, this.jConst, this.negBig]) a.dispose();
  }

  /** One Viterbi pass over [B,T] (time on axis 1, already scaled to the code's
   *  variance). `overlap` [B,1] int32 or null. Returns the decoded state at
   *  every t >= `from` ([B,1] int32 each; earlier slots are null). */
  private viterbi(X2T: MlxArray, B: number, overlap: MlxArray | null, from: number): (MlxArray | null)[] {
    const { T } = this.cfg;
    const n = this.nStates, G = this.G, J = this.J;
    const col = (t: number): MlxArray => {
      const row = X2T.slice([t, 0], [t + 1, B], S);   // [1,B]
      const c = ops.reshape(row, [B, 1], S);
      row.dispose();
      return c;
    };

    // t = 0 (initial state free, or pinned to the tail-biting overlap).
    let x = col(0);
    let g = ops.addmm(this.negLut2, x, this.lutRow, S);
    x.dispose();
    if (overlap) {
      const m = ops.equal(this.sHigh, overlap, S);
      const masked = ops.where(m, g, this.negBig, S);
      m.dispose(); g.dispose();
      g = masked;
    }

    // NOTE: mlx's ArgReduce kernel is ~85x slower than Reduce on this shape
    // (measured M1 Max: argmax over [4096,8,512] axis 1 = 42.9 ms vs max =
    // 0.5 ms), so the branch index is recovered from the max with a
    // compare + uint8 max instead of a real argmax.
    const back: (MlxArray | null)[] = new Array(T).fill(null);
    for (let t = 1; t < T; t++) {
      const g3 = ops.reshape(g, [B, G, J], S);
      const mx = ops.maxAxis(g3, 1, true, S);                    // [B,1,J]
      const eq = ops.equal(g3, mx, S);                           // bool [B,G,J]
      const e8 = eq.astype(Dtype.uint8, S);
      const sel = ops.mul(e8, this.mrow, S);
      back[t] = ops.maxAxis(sel, 1, false, S);                   // [B,J] uint8
      const best = ops.reshape(mx, [B, J, 1], S);
      x = col(t);
      const err = ops.addmm(this.negLut2, x, this.lutRow, S);    // [B,S]
      const err3 = ops.reshape(err, [B, J, G], S);
      const gn3 = ops.add(err3, best, S);
      const gn = ops.reshape(gn3, [B, n], S);
      ops.evalAll([gn, back[t]!]);
      for (const a of [g3, mx, eq, e8, sel, best, x, err, err3, gn3, g]) a.dispose();
      g = gn;
    }

    if (overlap) {
      const m = ops.equal(this.sLow, overlap, S);
      const masked = ops.where(m, g, this.negBig, S);
      m.dispose(); g.dispose();
      g = masked;
    }
    // argmax over all 2^L states, again via max+compare (see note above).
    const fmx = ops.maxAxis(g, 1, true, S);                       // [B,1]
    const feq = ops.equal(g, fmx, S);
    const fsel = ops.where(feq, this.sIdx, this.negOne, S);       // [B,S] int32
    const finI = ops.maxAxis(fsel, 1, true, S);                   // [B,1] int32
    for (const a of [fmx, feq, fsel, g]) a.dispose();

    const states: (MlxArray | null)[] = new Array(T).fill(null);
    let cur = finI;
    let curKept = T - 1 >= from;
    if (curKept) states[T - 1] = cur;
    for (let t = T - 1; t >= 1; t--) {
      const j = ops.rightShift(cur, this.kConst, S);              // [B,1] int32
      const m8 = ops.takeAlongAxis(back[t]!, j, 1, S);            // [B,1] uint8
      const mi = m8.astype(Dtype.int32, S);
      const off = ops.mul(mi, this.jConst, S);
      const prev = ops.add(j, off, S);
      for (const a of [m8, mi, off, j]) a.dispose();
      back[t]!.dispose();
      back[t] = null;
      if (!curKept) cur.dispose();
      cur = prev;
      curKept = t - 1 >= from;
      if (curKept) states[t - 1] = cur;
    }
    if (!curKept) cur.dispose();
    return states;
  }

  /** Trellis-encode + decode [B,T] rows (already variance-matched to the code).
   *  Returns [B,T] f32 reconstruction. */
  encodeDecode(X: MlxArray): MlxArray {
    const [B, T] = X.shape as [number, number];
    if (T !== this.cfg.T) throw new Error(`block length ${T} != cfg.T ${this.cfg.T}`);
    // NOTE: every intermediate gets its own handle and an explicit dispose —
    // an undisposed handle for a view (transpose/concat/slice) pins its PARENT
    // buffer, which is how the first 27-tensor run leaked ~1.4 GB per tensor.
    const two = ops.mulScalar(X, 2, S);
    const twoT = ops.transposeAxes(two, [1, 0], S);
    const X2T = ops.contiguous(twoT, S);                                // [T,B]
    two.dispose(); twoT.dispose();
    ops.evalAll([X2T]);

    let overlap: MlxArray | null = null;
    if (this.cfg.tailBiting) {
      // Algorithm 4: rotate right by ⌊T/2⌋, unconstrained Viterbi, read the
      // state that lands on original t=0 and use its top L-k bits as overlap.
      const H = T >> 1;
      const a = X2T.slice([H, 0], [T, B], S);
      const b = X2T.slice([0, 0], [H, B], S);
      const cat = ops.concatAxis([a, b], 0, S);
      const rot = ops.contiguous(cat, S);
      a.dispose(); b.dispose(); cat.dispose();
      ops.evalAll([rot]);
      const st = this.viterbi(rot, B, null, H);
      rot.dispose();
      overlap = ops.rightShift(st[H]!, this.kConst, S);
      ops.evalAll([overlap]);
      for (const s of st) s?.dispose();
      clearCache();
    }

    const st = this.viterbi(X2T, B, overlap, 0);
    X2T.dispose();
    overlap?.dispose();
    const idx = ops.concatAxis(st as MlxArray[], 1, S);                 // [B,T] int32
    for (const s of st) s?.dispose();
    const out = ops.takeAxis(this.lutFlat, idx, 0, S);
    idx.dispose();
    ops.evalAll([out]);
    return out;
  }

  /** encodeDecode over [B,T] in chunks of at most `maxB` rows. The caller has
   *  already variance-matched X to the code (BlockLDLQ path). */
  encodeDecodeChunked(X: MlxArray, maxB: number): MlxArray {
    const [B, T] = X.shape as [number, number];
    if (B <= maxB) return this.encodeDecode(X);
    const parts: MlxArray[] = [];
    for (let b0 = 0; b0 < B; b0 += maxB) {
      const b1 = Math.min(B, b0 + maxB);
      const sl = X.slice([b0, 0], [b1, T], S);
      const chunk = ops.contiguous(sl, S);
      sl.dispose();
      ops.evalAll([chunk]);
      parts.push(this.encodeDecode(chunk));
      chunk.dispose();
      clearCache();
    }
    const out = ops.concatAxis(parts, 0, S);
    for (const p of parts) p.dispose();
    ops.evalAll([out]);
    return out;
  }

  /** Fake-quant a 2-D tensor whose trellis axis is the LAST axis. Per-row
   *  (per rotated vector) fp16 scale, QTIP's Wscale = RMS(W)/RMS(lut) applied
   *  per row instead of per tensor (deviation: our incoherence processing is
   *  one-sided, so rows do not share a norm). */
  fakeQuantRows(W: MlxArray, batchBlocks: number, onProgress?: (done: number, total: number) => void): MlxArray {
    const [N, C] = W.shape as [number, number];
    const T = this.cfg.T;
    if (C % T !== 0) throw new Error(`trellis axis ${C} not a multiple of block ${T}`);
    const sq = ops.square(W, S);
    const ms = ops.meanAxis(sq, 1, true, S);
    sq.dispose();
    const rms = ops.sqrt(ms, S);
    ms.dispose();
    const inv = ops.mulScalar(rms, 1 / this.lutRms, S);   // scale = rms/lutRms
    rms.dispose();
    // guard all-zero rows
    const zero = Arr.fromFloat32(new Float32Array([0]), []);
    const one = Arr.fromFloat32(new Float32Array([1]), []);
    const isz = ops.equal(inv, zero, S);
    const scale = ops.where(isz, one, inv, S);
    for (const a of [zero, one, isz, inv]) a.dispose();
    // fp16 round-trip: the scale we would actually store
    const s16 = scale.astype(Dtype.float16, S);
    const scaleQ = s16.astype(Dtype.float32, S);
    scale.dispose(); s16.dispose();

    const Xn = ops.div(W, scaleQ, S);
    const flat = ops.reshape(Xn, [(N * C) / T, T], S);
    Xn.dispose();
    ops.evalAll([flat]);

    const nBlocks = (N * C) / T;
    const parts: MlxArray[] = [];
    for (let b0 = 0; b0 < nBlocks; b0 += batchBlocks) {
      const b1 = Math.min(nBlocks, b0 + batchBlocks);
      const sl = flat.slice([b0, 0], [b1, T], S);
      const chunk = ops.contiguous(sl, S);
      sl.dispose();
      ops.evalAll([chunk]);
      const rec = this.encodeDecode(chunk);
      chunk.dispose();
      parts.push(rec);
      clearCache();
      onProgress?.(b1, nBlocks);
    }
    flat.dispose();
    const all = parts.length === 1 ? parts[0]! : ops.concatAxis(parts, 0, S);
    if (parts.length > 1) for (const p of parts) p.dispose();
    const rec2 = ops.reshape(all, [N, C], S);
    all.dispose();
    const out = ops.mul(rec2, scaleQ, S);
    rec2.dispose();
    scaleQ.dispose();
    ops.evalAll([out]);
    return out;
  }
}

// -------------------------------------------------------------- validate ---

if (import.meta.main) {
  const argv = process.argv.slice(2);
  const opt = (k: string, d: string) => {
    const i = argv.indexOf(`--${k}`);
    return i > -1 ? argv[i + 1]! : d;
  };
  const L = Number(opt("L", "12"));
  const T = Number(opt("T", "256"));
  const nSeq = Number(opt("seqs", "4096"));
  const codes = opt("codes", "1mad,rand").split(",") as CodeName[];
  const ks = opt("k", "1,2,3,4").split(",").map(Number);
  const batch = Number(opt("batch", "4096"));
  const bench = argv.includes("--bench");

  if (bench) {
    // Throughput probe on a 5120-column MLP-shaped tensor.
    const rows = Number(opt("rows", "2048"));
    const cols = Number(opt("cols", "5120"));
    const K = Number(opt("k", "3"));
    const reps = Number(opt("reps", "1"));
    const tr = new Trellis({ L, K, T, code: "1mad", tailBiting: !argv.includes("--no-tail") });
    const key = ops.randomKey(7n);
    const W = ops.randomNormal([rows, cols], Dtype.float32, 0, 1, key, S);
    ops.evalAll([W]);
    const gb = (n: number) => (n / 2 ** 30).toFixed(2);
    for (let r = 0; r < reps; r++) {
      const t0 = performance.now();
      const rec = tr.fakeQuantRows(W, batch);
      const dt = (performance.now() - t0) / 1000;
      const d = ops.sub(rec, W, S);
      const sq = ops.square(d, S);
      const mse = ops.meanAll(sq, false, S);
      const v = mse.toFloat32()[0]!;
      for (const a of [rec, d, sq, mse]) a.dispose();
      console.log(
        `bench[${r}] L=${L} k=${K} T=${T} batch=${batch} tail=${!argv.includes("--no-tail")} ` +
        `${rows}x${cols}=${((rows * cols) / 1e6).toFixed(1)}M in ${dt.toFixed(1)}s ` +
        `→ ${((rows * cols) / 1e6 / dt).toFixed(3)} Mw/s · mse ${v.toFixed(5)} · ` +
        `mlx active ${gb(activeMemory())} cache ${gb(cacheMemory())} peak ${gb(peakMemory())} GiB · ` +
        `rss ${gb(process.memoryUsage().rss)} GiB`,
      );
    }
    process.exit(0);
  }

  console.log(`# tail-biting (${L}, k, 1) trellis, T=${T}, ${nSeq} iid N(0,1) seqs (paper Table 2)`);
  for (const code of codes) {
    for (const K of ks) {
      const tb = new Trellis({ L, K, T, code, tailBiting: true });
      const nb = new Trellis({ L, K, T, code, tailBiting: false });
      const key = ops.randomKey(1234n);
      const X = ops.randomNormal([nSeq, T], Dtype.float32, 0, 1, key, S);
      ops.evalAll([X]);
      // QTIP scales the source to the code's RMS (Wscale = RMS(W)/RMS(lut)).
      const run = (tr: Trellis) => {
        const xs = ops.mulScalar(X, tr.lutRms, S);
        const r0 = tr.encodeDecode(xs);
        const r = ops.mulScalar(r0, 1 / tr.lutRms, S);
        const d = ops.sub(r, X, S);
        const sq = ops.square(d, S);
        const m = ops.meanAll(sq, false, S);
        const v = m.toFloat32()[0]!;
        for (const a of [xs, r0, r, d, sq, m]) a.dispose();
        return v;
      };
      const a = run(tb), b = run(nb);
      console.log(
        `  code=${code.padEnd(5)} k=${K}  tail-biting MSE ${a.toFixed(4)}   ` +
        `free-ends MSE ${b.toFixed(4)}   (lut rms ${tb.lutRms.toFixed(4)})`,
      );
      X.dispose(); tb.dispose(); nb.dispose(); clearCache();
    }
  }
}
