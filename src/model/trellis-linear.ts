// TrellisLinear — a linear layer over PACKED trellis-coded weights (Q2b), the
// on-disk format src/quantize/trellis.ts describes: `.weight` = uint32 bit-
// stream [rows, cols·k/32], `.scales` = fp16 [rows], config entry
// `{mode:"trellis", bits:k, group_size:T, trellis:{L, code:"1mad", axis}}`.
//
// axis=1 (gate/up): coded along the INPUT dim, stored [out, in·k/32].
// axis=0 (down):    coded along the OUTPUT dim, stored [in, out·k/32] — i.e.
//                   the stored matrix is Wᵀ, coded along its last axis.
//
// Three Metal kernels, one decode primitive: state_t is the L-bit window at
// bit offset (T−1−t)·k of the block (wrapping), so any weight decodes in O(1)
// with the 1MAD code computed inline (no LUT, no threadgroup memory):
//   • reduce  — M≤4 matvec for axis=1: one SIMD group per output row, each
//               lane owns runs of 32 consecutive positions held in K+1
//               registers (every window shift a compile-time constant), simd_sum.
//   • scatter — M≤4 matvec for axis=0: lane-per-WORD of a block (a row's
//               lanes read one contiguous 96/128-byte span), each lane keeps
//               running sums for the positions in its word, split-K over
//               input rows (partials folded by one mlx sum).
//   • expand  — decode a whole tensor to bf16 for M>4 (prefill), then a stock
//               matmul; the transient is one tensor (≤178 MB at 27B).
// The reconstructed weight is bf16(f32(lut[state])·f32(scale)) in every path,
// bit-identical to the fake-quant artifact's stored bf16.
//
// `MLX_BUN_TRELLIS=expand` decodes every trellis tensor at LOAD into 8-bit
// g64 affine (the eval-carrier numerics, ~−45 dB) and serves it through the
// stock QuantizedLinear — the fallback when the kernels lose on a machine.

import { MlxArray, gpuStream } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { MetalKernel } from "../mlx/metal-kernel";
import type { Weights } from "../weights";
import { quantFor, type ModelConfig, type QuantSpec } from "../config";
import { lut1mad, wordsPerBlock } from "../quantize/trellis";
import { QuantizedLinear } from "./gemma4-base";

const THREADS = 128;           // 4 SIMD groups per threadgroup
const SG_PER_TG = 4;
const MATVEC_MAX_M = 4;        // above this, expand + matmul wins (weights re-read per sample)
const SCATTER_SPLITS = 128;    // scatter split-K: (blocks/nb) × SPLITS SIMD groups must fill the GPU

const HEADER = String.raw`
static inline float trellis_bf16(float v) {
  uint u = as_type<uint>(v);
  u = (u + 0x7FFFu + ((u >> 16) & 1u)) & 0xFFFF0000u;
  return as_type<float>(u);
}
// QTIP 1MAD computed code for state s: x = s*34038481 + 76625530 (mod 2^32),
// y = sum of the four bytes of x - 510, value = y / 147.800537109375. Two
// byte-pair adds replace the four extracts; precise divide matches the host
// LUT (src/quantize/trellis.ts lut1mad) bit for bit.
static inline int trellis_y(uint s) {
  const uint x = s * 34038481u + 76625530u;
  const uint p = (x & 0x00FF00FFu) + ((x >> 8) & 0x00FF00FFu);
  return (int)((p & 0xFFFFu) + (p >> 16)) - 510;
}
static inline float trellis_val(uint s) {
  return metal::precise::divide((float)trellis_y(s), 147.800537109375f);
}
// y × (1/d) refined by one residual step: q' = fma(fma(-q, d, y), 1/d, q).
// Correctly rounded for every y in [-510, 510] (checked host-side against
// the LUT), 3 FMA-class ops instead of a precise divide.
static inline float trellis_val_rcp(uint s) {
  const float y = (float)trellis_y(s);
  const float r = 1.0f / 147.800537109375f;
  const float q = y * r;
  const float e = metal::fma(-q, 147.800537109375f, y);
  return metal::fma(e, r, q);
}
// VARIANT: 0 = inline 1MAD + precise divide; 1 = inline 1MAD × reciprocal
// (1 ulp risk vs the host LUT); 2 = 4096-entry f32 LUT in threadgroup memory;
// 3 = the same LUT gathered from device memory.
// 4 = NO decode (timing floor only, wrong numerics); 5 = rcp decode, no bf16
// rounding; 6 = unrefined y×(1/d) (≤1 ulp f32), no bf16 rounding — the
// weight is f32 code×scale, more accurate than the artifact's stored bf16.
#define TRELLIS_DECODE(win, lutTG, lut) \
  ((VARIANT) == 0 ? trellis_val(win) : \
   (VARIANT) == 1 || (VARIANT) == 5 ? trellis_val_rcp(win) : \
   (VARIANT) == 6 ? (float)trellis_y(win) * (1.0f / 147.800537109375f) : \
   (VARIANT) == 2 ? lutTG[win] : \
   (VARIANT) == 4 ? (float)(win) : lut[win])
#define TRELLIS_ROUND(v) ((VARIANT) >= 4 ? (v) : trellis_bf16(v))
// state_t of one packed block: L bits at offset (BT-1-t)*K, wrapping (32-bit ops).
static inline uint trellis_state(const device uint32_t* blk, uint wpb, uint t, uint bt, uint k, uint l) {
  const uint p = (bt - 1u - t) * k;
  const uint wi = p >> 5;
  const uint off = p & 31u;
  uint win = blk[wi] >> off;
  if (off + l > 32u) win |= blk[(wi + 1u == wpb) ? 0u : (wi + 1u)] << (32u - off);
  return win & ((1u << l) - 1u);
}
`;

/** y[m, r] = Σ_c bf16(val(s(r,c))·scale[r]) · x[m, c]   (axis=1)
 *  A lane owns RUNS of 32 consecutive coded positions: the run's T·K/… bits
 *  sit in K words starting at word (BT-32-t0)·K/32 (always word-aligned), the
 *  window of position t0+j starts at local bit (31-j)·K, so after unrolling
 *  every shift is a compile-time constant — no LUT, no threadgroup memory. */
const REDUCE_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* codeRow = codes + (ulong)row * (ulong)((C / BT) * wpb);
  const device T* xs = x + (ulong)sample * (ulong)C;
  const float scale = float(scales[row]);
  float acc = 0.0f, acc2 = 0.0f;
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* bw = codeRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint w[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      w[i] = bw[wi >= wpb ? wi - wpb : wi];
    }
    const uint c0 = blk * (uint)BT + t0;
    const device metal::vec<T, 4>* x4 = (const device metal::vec<T, 4>*)(xs + c0);
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      const float4 xv = float4(x4[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint win = w[wi] >> off;
        if (off + (uint)L > 32u) win |= w[wi + 1] << (32u - off);
        win &= (1u << (uint)L) - 1u;
        const float wv = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * scale);
        if (q & 1u) acc2 = metal::fma(wv, xv[q], acc2);
        else acc = metal::fma(wv, xv[q], acc);
      }
    }
  }
  const float v = metal::simd_sum(acc + acc2);
  if (lane == 0u) out[(ulong)sample * (ulong)R + row] = T(v);
`;

/** partial[m, split, c] = Σ_{r in split} val(s(r,c))·scale[r] · x[m, r]   (axis=0)
 *  Lane-per-WORD: lane w of a SIMD group owns word w of one block (k=2: two
 *  blocks per group), so a row's 32 lanes read one contiguous 96/128-byte
 *  span — every code byte crosses the bus exactly once. Each lane decodes the
 *  NP positions whose symbol sits in its word (the window may spill into the
 *  next word, fetched by simd_shuffle from the neighbour lane, wrapping at the
 *  block end) and keeps NP running sums; x[r] and scale[r] are broadcast
 *  loads. Split-K over rows for occupancy; one mlx sum folds the partials. */
const SCATTER_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint wpb = (uint)(BT * K / 32);
  const uint nb = 32u / wpb;                       // blocks per SIMD group
  const uint nBlocks = (uint)C / (uint)BT;
  const uint groups = (nBlocks + nb - 1u) / nb;
  const uint group = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
  const uint bi = lane / wpb;
  const uint wi = lane - bi * wpb;
  const uint blk = group * nb + bi;
  const bool active = (group < groups) && (bi < nb) && (blk < nBlocks) && (sample < (uint)M);
  const uint nbrLane = bi * wpb + ((wi + 1u == wpb) ? 0u : wi + 1u);
  // This lane's positions: symbol offsets p = multiples of K inside [32wi, 32wi+32).
  const uint pBase = 32u * wi;
  const uint p0 = ((pBase + (uint)K - 1u) / (uint)K) * (uint)K;
  uint offs[NP];
  bool valid[NP];
  bool spill[NP];
  uint cols[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) {
    const uint p = p0 + i * (uint)K;
    valid[i] = active && (p < pBase + 32u);
    offs[i] = p - pBase;
    spill[i] = offs[i] + (uint)L > 32u;
    const uint t = (uint)BT - 1u - p / (uint)K;
    cols[i] = blk * (uint)BT + t;
  }
  const ulong rowWords = (ulong)(nBlocks * wpb);
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  const device T* xs = x + (ulong)sample * (ulong)R;
  const device uint32_t* col0 = codes + blk * wpb + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[NP];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      acc[i] = metal::fma(TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * sr), xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < (uint)NP; ++i)
    if (valid[i]) partial[outBase + cols[i]] = acc[i];
`;

/** mid[m, r] = bf16(silu(bf16(gate[m,r])) · bf16(up[m,r])) with gate/up two
 *  axis=1 trellis matvecs over the SAME x — one pass over x, one launch, no
 *  gate/up vectors materialized. Rounding matches the production graph
 *  (gate, up → T; sigmoid → T; silu → T; product → T), i.e. mlx-lm's compiled
 *  swiglu over two QuantizedLinear outputs. */
const GATEUP_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
  const device T* xs = x + (ulong)sample * (ulong)C;
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc = 0.0f, gAcc2 = 0.0f;
  float uAcc = 0.0f, uAcc2 = 0.0f;
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* gw = gRow + blk * wpb;
    const device uint32_t* uw = uRow + blk * wpb;
    const uint w0 = ((uint)BT - 32u - t0) * (uint)K / 32u;
    uint g[K + 1];
    uint u[K + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)K; ++i) {
      const uint wi = w0 + i;
      const uint idx = wi >= wpb ? wi - wpb : wi;
      g[i] = gw[idx];
      u[i] = uw[idx];
    }
    const uint c0 = blk * (uint)BT + t0;
    const device metal::vec<T, 4>* x4 = (const device metal::vec<T, 4>*)(xs + c0);
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      const float4 xv4 = float4(x4[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint b = (31u - j) * (uint)K;
        const uint wi = b >> 5;
        const uint off = b & 31u;
        uint gwin = g[wi] >> off;
        uint uwin = u[wi] >> off;
        if (off + (uint)L > 32u) { gwin |= g[wi + 1] << (32u - off); uwin |= u[wi + 1] << (32u - off); }
        gwin &= (1u << (uint)L) - 1u;
        uwin &= (1u << (uint)L) - 1u;
        const float xv = xv4[q];
        const float gv = TRELLIS_ROUND(TRELLIS_DECODE(gwin, lutTG, lut) * gScale);
        const float uv = TRELLIS_ROUND(TRELLIS_DECODE(uwin, lutTG, lut) * uScale);
        if (q & 1u) { gAcc2 = metal::fma(gv, xv, gAcc2); uAcc2 = metal::fma(uv, xv, uAcc2); }
        else { gAcc = metal::fma(gv, xv, gAcc); uAcc = metal::fma(uv, xv, uAcc); }
      }
    }
  }
  const float gate = metal::simd_sum(gAcc + gAcc2);
  const float up = metal::simd_sum(uAcc + uAcc2);
  if (lane == 0u) {
    const T gateT = T(gate);
    const T upT = T(up);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)sample * (ulong)R + row] = T(float(siluT) * float(upT));
  }
`;

/** out[r, c] = bf16(val(s(r,c))·scale[r]) — the stored matrix, decoded. */
const EXPAND_SOURCE = String.raw`
  const uint c = thread_position_in_grid.x;
  const uint r = thread_position_in_grid.y;
  if (c >= (uint)C || r >= (uint)R) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint blk = c / (uint)BT;
  const uint t = c - blk * (uint)BT;
  const device uint32_t* codeRow = codes + (ulong)r * (ulong)((C / BT) * wpb);
  const uint s = trellis_state(codeRow + blk * wpb, wpb, t, (uint)BT, (uint)K, (uint)L);
  out[(ulong)r * (uint)C + c] = T(((VARIANT) >= 2 ? lut[s] : (VARIANT) == 1 ? trellis_val_rcp(s) : trellis_val(s)) * float(scales[r]));
`;

let kernels: { reduce: MetalKernel; scatter: MetalKernel; expand: MetalKernel; gateUp: MetalKernel } | null = null;
function kernelSet() {
  if (!kernels) {
    kernels = {
      reduce: new MetalKernel({
        name: "mlx_bun_trellis_reduce", inputNames: ["x", "codes", "scales", "lut"],
        outputNames: ["out"], source: REDUCE_SOURCE, header: HEADER, ensureRowContiguous: true,
      }),
      scatter: new MetalKernel({
        name: "mlx_bun_trellis_scatter", inputNames: ["x", "codes", "scales", "lut"],
        outputNames: ["partial"], source: SCATTER_SOURCE, header: HEADER, ensureRowContiguous: true,
      }),
      expand: new MetalKernel({
        name: "mlx_bun_trellis_expand", inputNames: ["codes", "scales", "lut"],
        outputNames: ["out"], source: EXPAND_SOURCE, header: HEADER, ensureRowContiguous: true,
      }),
      gateUp: new MetalKernel({
        name: "mlx_bun_trellis_gateup_swiglu",
        inputNames: ["x", "gcodes", "gscales", "ucodes", "uscales", "lut"],
        outputNames: ["mid"], source: GATEUP_SOURCE, header: HEADER, ensureRowContiguous: true,
      }),
    };
  }
  return kernels;
}

const luts = new Map<number, MlxArray>();
function lutFor(L: number): MlxArray {
  let a = luts.get(L);
  if (!a) { a = MlxArray.fromFloat32(lut1mad(L), [1 << L]); a.eval(); luts.set(L, a); }
  return a;
}

/** Decode variant (see HEADER). Default is the fastest measured on M1 Max;
 *  `MLX_BUN_TRELLIS_VARIANT` overrides for experiments. */
let VARIANT = Number(process.env.MLX_BUN_TRELLIS_VARIANT ?? "1");
export function setTrellisVariant(v: number): void { VARIANT = v; }

export interface TrellisGeometry {
  k: number;
  L: number;
  T: number;
  axis: 0 | 1;
  /** Stored-matrix rows / coded columns. */
  rows: number;
  cols: number;
  inFeatures: number;
  outFeatures: number;
}

export function trellisGeometry(codes: MlxArray, spec: QuantSpec): TrellisGeometry {
  const tr = spec.trellis;
  if (spec.mode !== "trellis" || !tr) throw new Error("trellisGeometry: spec is not a trellis spec");
  const [rows, words] = codes.shape as [number, number];
  const k = spec.bits, T = spec.groupSize;
  if ((words * 32) % k !== 0) throw new Error(`trellis: ${words} words not a whole number of ${k}-bit symbols`);
  const cols = (words * 32) / k;
  if (cols % T !== 0) throw new Error(`trellis: ${cols} coded columns not a multiple of block ${T}`);
  wordsPerBlock(T, k);
  return {
    k, L: tr.L, T, axis: tr.axis, rows, cols,
    inFeatures: tr.axis === 1 ? cols : rows,
    outFeatures: tr.axis === 1 ? rows : cols,
  };
}

/** Decode the stored matrix ([rows, cols], coded along cols) to `dtype`. */
export function expandTrellis(codes: MlxArray, scales: MlxArray, g: TrellisGeometry, dtype: Dtype): MlxArray {
  const [out] = kernelSet().expand.apply([codes, scales, lutFor(g.L)], {
    outputs: [{ shape: [g.rows, g.cols], dtype }],
    grid: [g.cols, g.rows, 1],
    threadGroup: [Math.min(256, g.cols), 1, 1],
    templateDtypes: { T: dtype },
    templateInts: { R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, VARIANT },
  });
  return out!;
}

export type TrellisMode = "kernel" | "expand";

export function trellisModeFromEnv(): TrellisMode {
  const v = process.env.MLX_BUN_TRELLIS;
  if (v === "expand") return "expand";
  return "kernel";
}

/** Can gate and up be served by the fused kernel? Same axis-1 geometry and k,
 *  neither in the expand fallback. */
export function fusedGateUpEligible(gate: TrellisLinear, up: TrellisLinear): boolean {
  const a = gate.geometry, b = up.geometry;
  return !gate.fallback && !up.fallback && a.axis === 1 && b.axis === 1 &&
    a.k === b.k && a.rows === b.rows && a.cols === b.cols && a.T === b.T && a.L === b.L;
}

/** silu(gate(x)) · up(x) for M ≤ 4 rows in ONE kernel over the packed codes:
 *  x is read once, the gate/up vectors never exist. Callers check
 *  fusedGateUpEligible and the row budget (use plain forwards otherwise). */
export function fusedGateUpSwiglu(x: MlxArray, gate: TrellisLinear, up: TrellisLinear): MlxArray {
  const g = gate.geometry;
  const lead = x.shape.slice(0, -1);
  const M = lead.reduce((a, b) => a * b, 1);
  if (M > MATVEC_MAX_M) throw new Error(`fusedGateUpSwiglu: M=${M} > ${MATVEC_MAX_M}`);
  const x2 = ops.reshape(x, [M, g.inFeatures]);
  const [mid] = kernelSet().gateUp.apply([x2, gate.codes, gate.scales, up.codes, up.scales, lutFor(g.L)], {
    outputs: [{ shape: [M, g.rows], dtype: x.dtype }],
    grid: [THREADS, Math.ceil(g.rows / SG_PER_TG), M],
    threadGroup: [THREADS, 1, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, ROWS_TG: SG_PER_TG, VARIANT },
  });
  x2.dispose();
  const out = ops.reshape(mid!, [...lead, g.rows]);
  mid!.dispose();
  return out;
}

export const TRELLIS_MATVEC_MAX_M = MATVEC_MAX_M;

export class TrellisLinear {
  readonly geometry: TrellisGeometry;
  readonly spec: QuantSpec;
  /** `MLX_BUN_TRELLIS=expand`: the load-time 8-bit affine carrier. */
  readonly fallback: QuantizedLinear | null;

  constructor(
    readonly codes: MlxArray,
    readonly scales: MlxArray,
    spec: QuantSpec,
    mode: TrellisMode = trellisModeFromEnv(),
  ) {
    this.spec = spec;
    this.geometry = trellisGeometry(codes, spec);
    this.fallback = mode === "expand" ? this.#expandToAffine() : null;
  }

  static load(weights: Weights, path: string, config: ModelConfig): TrellisLinear {
    const spec = quantFor(config.quantization, path);
    if (!spec || spec.mode !== "trellis")
      throw new Error(`${path}: expected a trellis quant spec`);
    if (!weights.has(`${path}.scales`)) throw new Error(`${path}: trellis tensor has no .scales`);
    return new TrellisLinear(weights.tensor(`${path}.weight`), weights.tensor(`${path}.scales`), spec);
  }

  static isTrellis(config: ModelConfig, path: string): boolean {
    return quantFor(config.quantization, path)?.mode === "trellis";
  }

  get inFeatures(): number { return this.geometry.inFeatures; }
  get outFeatures(): number { return this.geometry.outFeatures; }

  /** The weight as [out, in] bf16 (decoded; transposed for axis=0). */
  expandWeight(dtype: Dtype = Dtype.bfloat16): MlxArray {
    const g = this.geometry;
    const stored = expandTrellis(this.codes, this.scales, g, dtype);
    if (g.axis === 1) return stored;
    const t = ops.transposeAxes(stored, [1, 0]);
    const w = ops.contiguous(t);
    t.dispose(); stored.dispose();
    return w;
  }

  #expandToAffine(): QuantizedLinear {
    const w = this.expandWeight(Dtype.bfloat16);
    const q = ops.quantize(w, 64, 8, "affine");
    ops.evalAll([q.packed, q.scales, ...(q.biases ? [q.biases] : [])]);
    w.dispose();
    return new QuantizedLinear(q.packed, q.scales, q.biases, { bits: 8, groupSize: 64, mode: "affine" });
  }

  forward(x: MlxArray): MlxArray {
    if (this.fallback) return this.fallback.forward(x);
    const g = this.geometry;
    const lead = x.shape.slice(0, -1);
    const M = lead.reduce((a, b) => a * b, 1);
    if (x.shape[x.shape.length - 1] !== g.inFeatures)
      throw new Error(`TrellisLinear: input dim ${x.shape[x.shape.length - 1]} != ${g.inFeatures}`);
    const x2 = ops.reshape(x, [M, g.inFeatures]);
    let y: MlxArray;
    if (M <= MATVEC_MAX_M) y = g.axis === 1 ? this.#reduce(x2, M) : this.#scatter(x2, M);
    else {
      const stored = expandTrellis(this.codes, this.scales, g, x.dtype);
      if (g.axis === 1) {
        const wt = ops.transposeAxes(stored, [1, 0]);
        y = ops.matmul(x2, wt);
        wt.dispose();
      } else y = ops.matmul(x2, stored);
      stored.dispose();
    }
    x2.dispose();
    const out = ops.reshape(y, [...lead, g.outFeatures]);
    y.dispose();
    return out;
  }

  #reduce(x2: MlxArray, M: number): MlxArray {
    const g = this.geometry;
    const [out] = kernelSet().reduce.apply([x2, this.codes, this.scales, lutFor(g.L)], {
      outputs: [{ shape: [M, g.rows], dtype: x2.dtype }],
      grid: [THREADS, Math.ceil(g.rows / SG_PER_TG), M],
      threadGroup: [THREADS, 1, 1],
      templateDtypes: { T: x2.dtype },
      templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, ROWS_TG: SG_PER_TG, VARIANT },
    });
    return out!;
  }

  #scatter(x2: MlxArray, M: number): MlxArray {
    const g = this.geometry;
    const wpb = wordsPerBlock(g.T, g.k);
    const nb = Math.floor(32 / wpb);
    if (nb < 1) throw new Error(`trellis scatter: block of ${wpb} words exceeds one SIMD group`);
    const groups = Math.ceil((g.cols / g.T) / nb);
    const NP = Math.ceil(32 / g.k);
    const [partial] = kernelSet().scatter.apply([x2, this.codes, this.scales, lutFor(g.L)], {
      outputs: [{ shape: [M, SCATTER_SPLITS, g.cols], dtype: Dtype.float32 }],
      grid: [THREADS, Math.ceil(groups / SG_PER_TG), M * SCATTER_SPLITS],
      threadGroup: [THREADS, 1, 1],
      templateDtypes: { T: x2.dtype },
      templateInts: { M, R: g.rows, C: g.cols, BT: g.T, K: g.k, L: g.L, SG_TG: SG_PER_TG, SPLITS: SCATTER_SPLITS, NP, VARIANT },
    });
    const sum = ops.sumAxis(partial!, 1, false);
    partial!.dispose();
    const out = sum.astype(x2.dtype);
    sum.dispose();
    return out;
  }
}
