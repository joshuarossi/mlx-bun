// MiniCPM5 DECODE megakernel (Phase 2: G=1, correctness) — the ENTIRE decode
// forward (embed→24 layers→finalNorm→lm_head→logits[V]) in ONE metal_kernel
// dispatch. No per-op MLX node, so MLX's lazy planner never gets a chain of our
// custom kernels to corrupt (docs/design/minicpm5-decode-megakernel.md §0).
//
// Scope: M=1 decode. Weights stay mixed-precision quantized (4/8-bit per tensor,
// dequant in-kernel via the same affine math as ops.quantizedMatmul). KV (L1) is
// bf16: the kernel READS the prior cache (device, positions 0..pos-1) and the
// just-computed row (threadgroup, position pos), and EMITS the new per-layer k/v
// rows as compact outputs that the caller sliceUpdates into the persistent cache
// (MLX donates that write — no in-kernel copy).
//
// Phase 2 is a SINGLE threadgroup (TGN threads, threadgroup_barrier between
// stages); state lives in threadgroup memory. Phase 3 generalises to G>1 with a
// software grid-barrier + device scratch for SPEED. Per-stage math is identical.
//
// L3 path: f32 accumulation, bf16-rounded at each op boundary to track the
// reference (mirrors fused-mlp-kernel). Gated by teacher-forced agreement + KL
// (scripts/experiments/megakernel-teacherforced.ts), not bit-exactness.

import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
import * as ops from "../../src/mlx/ops";
import type { MiniCPM5Model } from "../../src/model/minicpm5";
import { packMiniCpm5, type MegaLayout, type MatLayout, type PackedModel } from "./megakernel-pack";

const TGN = 1024;
const META_STRIDE = 44; // 7 matrices * 6 fields + 2 norm offsets
// matrix record fields: [wOffBytes, sOff, bOff, N, K, bits]

function buildMeta(layout: MegaLayout): Uint32Array {
  const L = layout.nLayers;
  const meta = new Uint32Array(L * META_STRIDE + 1 + 6);
  const putMat = (base: number, m: MatLayout) => {
    meta[base + 0] = m.wOff; meta[base + 1] = m.sOff; meta[base + 2] = m.bOff;
    meta[base + 3] = m.N; meta[base + 4] = m.K; meta[base + 5] = m.bits;
  };
  for (let i = 0; i < L; i++) {
    const ly = layout.layers[i]!;
    const b = i * META_STRIDE;
    putMat(b + 0, ly.q); putMat(b + 6, ly.k); putMat(b + 12, ly.v); putMat(b + 18, ly.o);
    putMat(b + 24, ly.gate); putMat(b + 30, ly.up); putMat(b + 36, ly.down);
    meta[b + 42] = ly.inputNormOff; meta[b + 43] = ly.postNormOff;
  }
  const tail = L * META_STRIDE;
  meta[tail + 0] = layout.finalNormOff;
  putMat(tail + 1, layout.lmHead);
  return meta;
}

/** Emit a valid MSL float literal (integers need a decimal point). */
function fl(n: number): string {
  return Number.isInteger(n) ? `${n}.0f` : `${n}f`;
}

function kernelHeader(layout: MegaLayout): string {
  const KVDIM = layout.nKvHeads * layout.headDim;
  return [
    `#define H_C ${layout.H}`,
    `#define I_C ${layout.I}`,
    `#define V_C ${layout.V}`,
    `#define NLAYERS ${layout.nLayers}`,
    `#define NHEADS ${layout.nHeads}`,
    `#define NKVHEADS ${layout.nKvHeads}`,
    `#define HEADDIM ${layout.headDim}`,
    `#define HALFDIM ${layout.headDim / 2}`,
    `#define NREP ${layout.nHeads / layout.nKvHeads}`,
    `#define KVDIM ${KVDIM}`,
    `#define GS 64`,
    `#define TGN_C ${TGN}`,
    `#define META_STRIDE ${META_STRIDE}`,
    `#define EPS ${fl(layout.eps)}`,
    `#define ROPE_BASE ${fl(layout.ropeBase)}`,
    `#define ATTN_SCALE ${fl(layout.scale)}`,
    helpers(),
  ].join("\n");
}

// Device helper functions (header position — outside the templated kernel, so they
// use concrete bfloat16_t rather than the kernel's template alias).
function helpers(): string {
  return String.raw`
// ── one quantized GEMV output row: acc = sum_k deq(W[n,k]) * x[k], f32 ──
inline float gemv_row(const device uint8_t* W8, uint wOffBytes,
                      const device bfloat16_t* scales, uint sOff,
                      const device bfloat16_t* biases, uint bOff,
                      threadgroup const bfloat16_t* x, int K, int bits, int n) {
  const int ng = K / GS;
  const device uint8_t* wr = W8 + wOffBytes + (uint)n * (uint)((K*bits)/8);
  const uint sb = sOff + (uint)n*ng;
  const uint bbb = bOff + (uint)n*ng;
  float acc = 0.0f;
  for (int g=0; g<ng; ++g) {
    float sc = (float)scales[sb+g];
    float bi = (float)biases[bbb+g];
    int k0 = g*GS;
    if (bits == 4) {
      const device uint8_t* wb = wr + (k0/2);
      for (int kk=0; kk<GS; kk+=2) {
        uint8_t byte = wb[kk/2];
        acc += (sc*(float)(byte & 0x0f) + bi) * (float)x[k0+kk];
        acc += (sc*(float)(byte >> 4)   + bi) * (float)x[k0+kk+1];
      }
    } else {
      const device uint8_t* wb = wr + k0;
      for (int kk=0; kk<GS; ++kk)
        acc += (sc*(float)wb[kk] + bi) * (float)x[k0+kk];
    }
  }
  return acc;
}

// ── RMSNorm(x, w) → out, with a threadgroup sum-of-squares reduction ──
inline void rms_norm(threadgroup const bfloat16_t* x, const device bfloat16_t* norms,
                     uint wOff, threadgroup bfloat16_t* out, threadgroup float* red, uint lid) {
  float part = 0.0f;
  for (uint i=lid; i<H_C; i+=TGN_C) { float v=(float)x[i]; part += v*v; }
  red[lid] = part;
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint s=TGN_C/2; s>0; s>>=1) {
    if (lid < s) red[lid] += red[lid+s];
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
  float inv = 1.0f / metal::sqrt(red[0]/(float)H_C + EPS);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint i=lid; i<H_C; i+=TGN_C)
    out[i] = (bfloat16_t)((float)x[i] * inv * (float)norms[wOff+i]);
}

// ── NeoX/Llama rope of one (head, pair) index, in place ──
inline void rope_pair(threadgroup bfloat16_t* x, uint idx, int pos) {
  uint h = idx / HALFDIM;
  uint i = idx % HALFDIM;
  float inv = metal::pow((float)ROPE_BASE, -2.0f*(float)i/(float)HEADDIM);
  float ang = (float)pos * inv;
  float c = metal::precise::cos(ang), s = metal::precise::sin(ang);
  threadgroup bfloat16_t* base = x + h*HEADDIM;
  float x0 = (float)base[i], x1 = (float)base[i+HALFDIM];
  base[i]         = (bfloat16_t)(x0*c - x1*s);
  base[i+HALFDIM] = (bfloat16_t)(x1*c + x0*s);
}

// ── attention for one q-head (online softmax over pos+1 keys) ──
inline void attend(uint h, threadgroup const bfloat16_t* qbuf,
                   threadgroup const bfloat16_t* knew, threadgroup const bfloat16_t* vnew,
                   const device bfloat16_t* kcache, const device bfloat16_t* vcache,
                   threadgroup bfloat16_t* attbuf, int L, int pos, int KVSEQ) {
  uint kvh = h / NREP;
  threadgroup const bfloat16_t* q = qbuf + h*HEADDIM;
  float m = -INFINITY, l = 0.0f;
  float acc[HEADDIM];
  for (int d=0; d<HEADDIM; ++d) acc[d]=0.0f;
  for (int j=0; j<=pos; ++j) {
    const device bfloat16_t* kj = 0; const device bfloat16_t* vj = 0;
    threadgroup const bfloat16_t* kjt = 0; threadgroup const bfloat16_t* vjt = 0;
    if (j < pos) {
      uint off = ((uint)(L*KVSEQ + j))*KVDIM + kvh*HEADDIM;
      kj = kcache + off; vj = vcache + off;
    } else { kjt = knew + kvh*HEADDIM; vjt = vnew + kvh*HEADDIM; }
    float score = 0.0f;
    if (j < pos) for (int d=0; d<HEADDIM; ++d) score += (float)q[d]*(float)kj[d];
    else         for (int d=0; d<HEADDIM; ++d) score += (float)q[d]*(float)kjt[d];
    score *= ATTN_SCALE;
    float mnew = metal::max(m, score);
    float corr = metal::precise::exp(m - mnew);
    float p = metal::precise::exp(score - mnew);
    l = l*corr + p;
    if (j < pos) for (int d=0; d<HEADDIM; ++d) acc[d] = acc[d]*corr + p*(float)vj[d];
    else         for (int d=0; d<HEADDIM; ++d) acc[d] = acc[d]*corr + p*(float)vjt[d];
    m = mnew;
  }
  float invl = 1.0f / l;
  for (int d=0; d<HEADDIM; ++d) attbuf[h*HEADDIM+d] = (bfloat16_t)(acc[d]*invl);
}
`;
}

// ── The kernel body. KVSEQ_T is a templateInt (cache seq stride). ──
const SOURCE = String.raw`
  const uint lid = thread_position_in_threadgroup.x;
  const int pos = (int)posArr[0];
  const device uint8_t* W8 = (const device uint8_t*)wbytes;

  threadgroup bfloat16_t hid[H_C];          // residual stream
  threadgroup bfloat16_t nrm[H_C];          // RMSNorm output (xn / hn)
  threadgroup bfloat16_t knew[KVDIM];       // current-position roped keys
  threadgroup bfloat16_t vnew[KVDIM];       // current-position values
  threadgroup float red[TGN_C];             // reduction scratch
  threadgroup bfloat16_t U[2*I_C];          // union: {q,attn} | {gate,up}
  threadgroup bfloat16_t* qbuf   = U;
  threadgroup bfloat16_t* attbuf = U + NHEADS*HEADDIM;  // q occupies [0,2048)
  threadgroup bfloat16_t* gatebuf = U;
  threadgroup bfloat16_t* upbuf   = U + I_C;

  // stage 0: hid = embed(token)
  for (uint i=lid; i<H_C; i+=TGN_C) hid[i] = hidden0[i];
  threadgroup_barrier(mem_flags::mem_threadgroup);

  for (int L=0; L<NLAYERS; ++L) {
    const uint mb = (uint)L*META_STRIDE;

    // stage 1: nrm = RMSNorm(hid, inputNorm[L])
    rms_norm(hid, norms, meta[mb+42], nrm, red, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 2: q=Wq·nrm, k=Wk·nrm, v=Wv·nrm
    { const uint qb=mb+0, kb=mb+6, vb=mb+12;
      for (uint n=lid; n<(uint)meta[qb+3]; n+=TGN_C)
        qbuf[n] = (bfloat16_t)gemv_row(W8, meta[qb+0], scales, meta[qb+1], biases, meta[qb+2], nrm, (int)meta[qb+4], (int)meta[qb+5], (int)n);
      for (uint n=lid; n<(uint)meta[kb+3]; n+=TGN_C)
        knew[n] = (bfloat16_t)gemv_row(W8, meta[kb+0], scales, meta[kb+1], biases, meta[kb+2], nrm, (int)meta[kb+4], (int)meta[kb+5], (int)n);
      for (uint n=lid; n<(uint)meta[vb+3]; n+=TGN_C)
        vnew[n] = (bfloat16_t)gemv_row(W8, meta[vb+0], scales, meta[vb+1], biases, meta[vb+2], nrm, (int)meta[vb+4], (int)meta[vb+5], (int)n);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 3: RoPE(q), RoPE(k)
    for (uint idx=lid; idx<(uint)(NHEADS*HALFDIM);  idx+=TGN_C) rope_pair(qbuf, idx, pos);
    for (uint idx=lid; idx<(uint)(NKVHEADS*HALFDIM); idx+=TGN_C) rope_pair(knew, idx, pos);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 4: emit new k/v rows
    for (uint i=lid; i<KVDIM; i+=TGN_C) { knewOut[(uint)L*KVDIM+i]=knew[i]; vnewOut[(uint)L*KVDIM+i]=vnew[i]; }

    // stage 5: attention → attbuf (one q-head per thread)
    if (lid < (uint)NHEADS) attend(lid, qbuf, knew, vnew, kcache, vcache, attbuf, L, pos, KVSEQ_T);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 6: o = Wo·attbuf; hid += o
    { const uint ob=mb+18;
      for (uint n=lid; n<(uint)meta[ob+3]; n+=TGN_C) {
        float a=gemv_row(W8, meta[ob+0], scales, meta[ob+1], biases, meta[ob+2], attbuf, (int)meta[ob+4], (int)meta[ob+5], (int)n);
        hid[n] = (bfloat16_t)((float)hid[n] + a);
      }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 7: nrm = RMSNorm(hid, postAttnNorm[L])
    rms_norm(hid, norms, meta[mb+43], nrm, red, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // stage 8: gate/up → silu·up → down; hid += down
    { const uint gb=mb+24, ub=mb+30;
      for (uint n=lid; n<(uint)meta[gb+3]; n+=TGN_C)
        gatebuf[n] = (bfloat16_t)gemv_row(W8, meta[gb+0], scales, meta[gb+1], biases, meta[gb+2], nrm, (int)meta[gb+4], (int)meta[gb+5], (int)n);
      for (uint n=lid; n<(uint)meta[ub+3]; n+=TGN_C)
        upbuf[n]   = (bfloat16_t)gemv_row(W8, meta[ub+0], scales, meta[ub+1], biases, meta[ub+2], nrm, (int)meta[ub+4], (int)meta[ub+5], (int)n);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    for (uint i=lid; i<(uint)I_C; i+=TGN_C) {
      bfloat16_t gT = gatebuf[i];
      bfloat16_t sigT = (bfloat16_t)(1.0f/(1.0f+metal::precise::exp(-(float)gT)));
      bfloat16_t siluT = (bfloat16_t)((float)gT*(float)sigT);
      gatebuf[i] = (bfloat16_t)((float)siluT*(float)upbuf[i]);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    { const uint db=mb+36;
      for (uint n=lid; n<(uint)meta[db+3]; n+=TGN_C) {
        float a=gemv_row(W8, meta[db+0], scales, meta[db+1], biases, meta[db+2], gatebuf, (int)meta[db+4], (int)meta[db+5], (int)n);
        hid[n] = (bfloat16_t)((float)hid[n] + a);
      }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }

  // final: nrm = RMSNorm(hid, finalNorm); logits = lm_head·nrm
  rms_norm(hid, norms, meta[NLAYERS*META_STRIDE+0], nrm, red, lid);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  { const uint hb = NLAYERS*META_STRIDE+1;
    for (uint n=lid; n<(uint)V_C; n+=TGN_C)
      logits[n] = gemv_row(W8, meta[hb+0], scales, meta[hb+1], biases, meta[hb+2], nrm, (int)meta[hb+4], (int)meta[hb+5], (int)n);
  }
`;

let _kernel: MetalKernel | null = null;
function getKernel(layout: MegaLayout): MetalKernel {
  if (!_kernel) {
    _kernel = new MetalKernel({
      name: "mlx_bun_minicpm5_megakernel",
      inputNames: ["wbytes", "scales", "biases", "norms", "hidden0", "kcache", "vcache", "meta", "posArr"],
      outputNames: ["logits", "knewOut", "vnewOut"],
      header: kernelHeader(layout),
      source: SOURCE,
      ensureRowContiguous: true,
    });
  }
  return _kernel;
}

// ───────────────────────── Multi-threadgroup (G>1) kernel ─────────────────────
// Persistent kernel: G co-resident threadgroups walk the forward together, with a
// software grid-barrier between stages. Cross-threadgroup shared state lives in
// atomic_uint device scratch (float bits via as_type) — the ONLY device memory
// that is coherent across threadgroups on Apple (memory metal-persistent-kernel-
// coherence). Weights are read-only inputs (coherent, no atomics). Each stage loads
// its small input vector device→threadgroup ONCE per group, then GEMVs are simd-
// coalesced (32 lanes split K) with rows split across all G*NSG simdgroups.
const TGN_MT = Number(process.env.MLX_BUN_MEGAKERNEL_TGN) || 256;

function helpersMt(): string {
  return String.raw`
#define A_LD(p, i)    as_type<float>(atomic_load_explicit(&((device atomic_uint*)(p))[(i)], memory_order_relaxed))
#define A_ST(p, i, f) atomic_store_explicit(&((device atomic_uint*)(p))[(i)], as_type<uint>((float)(f)), memory_order_relaxed)
#define NSG (TGN_MT_C/32)

inline void grid_barrier(device atomic_uint* ga, device atomic_uint* gs, uint lid, int G, thread uint& expect) {
#ifdef MEGABAR_NOOP
  return;   // ablation: measures total grid-barrier cost (results are garbage)
#endif
  threadgroup_barrier(mem_flags::mem_device);
  expect ^= 1u;
  if (lid == 0) {
    uint old = atomic_fetch_add_explicit(ga, 1u, memory_order_relaxed);
    if (old + 1u == (uint)G) { atomic_store_explicit(ga, 0u, memory_order_relaxed); atomic_store_explicit(gs, expect, memory_order_relaxed); }
    else { while (atomic_load_explicit(gs, memory_order_relaxed) != expect) {} }
  }
  threadgroup_barrier(mem_flags::mem_device);
}

// Per-LANE partial dot of one quantized GEMV row over the K-slice [kStart, kStart+kl):
// 32 lanes stride VECTORIZED uint32 words (8 nibbles @4-bit, 4 bytes @8-bit) for
// coalesced device loads + register dequant. x holds the slice staged at x[0..kl).
// Caller simd_sum's across (chunks and) lanes. (Scalar byte loads were ~7x slower.)
inline float gemv_partial(const device uint8_t* W8, uint wOff, const device bfloat16_t* scales, uint sOff,
                          const device bfloat16_t* biases, uint bOff, threadgroup const bfloat16_t* x,
                          int K, int kStart, int kl, int bits, int n, uint lane) {
  const device uint* wr = (const device uint*)(W8 + wOff + (uint)n*(uint)((K*bits)/8));
  uint sb = sOff + (uint)n*(uint)(K/GS), bb = bOff + (uint)n*(uint)(K/GS);
  float part = 0.0f;
  if (bits == 4) {
    int w0=(kStart/8)+(int)lane, w1=(kStart+kl)/8;
    for (int w=w0; w<w1; w+=32) {
      uint pk = wr[w]; int kg=w*8, g=kg/GS, xl=kg-kStart;
      float sc=(float)scales[sb+g], bi=(float)biases[bb+g];
      for (int t=0; t<8; ++t) part += (sc*(float)((pk>>(4*t))&0xf) + bi) * (float)x[xl+t];
    }
  } else {
    int w0=(kStart/4)+(int)lane, w1=(kStart+kl)/4;
    for (int w=w0; w<w1; w+=32) {
      uint pk = wr[w]; int kg=w*4, g=kg/GS, xl=kg-kStart;
      float sc=(float)scales[sb+g], bi=(float)biases[bb+g];
      for (int t=0; t<4; ++t) part += (sc*(float)((pk>>(8*t))&0xff) + bi) * (float)x[xl+t];
    }
  }
  return part;
}
// whole-row GEMV (input fully staged in x): partial over [0,K) then simd_sum.
inline float gemv_simd(const device uint8_t* W8, uint wOff, const device bfloat16_t* scales, uint sOff,
                       const device bfloat16_t* biases, uint bOff, threadgroup const bfloat16_t* x,
                       int K, int bits, int n, uint lane) {
  return metal::simd_sum(gemv_partial(W8, wOff, scales, sOff, biases, bOff, x, K, 0, K, bits, n, lane));
}

// ── mlx qmv_fast port (the baseline's actual decode GEMV; copied verbatim from
// mlx/backend/metal/kernels/quantized.h qmv_fast_impl + load_vector + qdot). The
// three wins over the naive gemv above: (1) load_vector PRE-SCALES x so qdot is
// mask-only (no per-nibble shifts); (2) the affine bias folds once per group as
// scale*accum + sum*bias (not (sc*q+bi)*x per element); (3) each simdgroup does
// RESULTS_PER_SG=4 output rows reusing one register-resident x_thread → 4×
// arithmetic per x-load + 4 independent accumulators hiding FMA/load latency.
// Our weight layout already matches mlx's (w uint32 [N,K*bits/32], sc/bi bf16
// [N,K/GS]); all our N,K divide the fast-path block sizes, so no safe-tail path. ──
#define RESULTS_PER_SG 4

// pre-scale x into registers, return sum(x) for the bias term
template <int BITS>
inline float load_vec_tg(threadgroup const bfloat16_t* x, thread float* xt) {
  constexpr int VPT = (32/BITS)*2;   // values per thread
  float sum = 0.0f;
  if (BITS == 4) {
    for (int i=0; i<VPT; i+=4) {
      float a=(float)x[i], b=(float)x[i+1], c=(float)x[i+2], d=(float)x[i+3];
      sum += a+b+c+d;
      xt[i]=a; xt[i+1]=b/16.0f; xt[i+2]=c/256.0f; xt[i+3]=d/4096.0f;
    }
  } else {
    for (int i=0; i<VPT; ++i) { float a=(float)x[i]; sum += a; xt[i]=a; }
  }
  return sum;
}
// dequant dot of one row's packed weights with the pre-scaled x_thread
template <int BITS>
inline float qdot_t(const device uint8_t* w, thread const float* xt, float scale, float bias, float sum) {
  constexpr int VPT = (32/BITS)*2;
  float accum = 0.0f;
  if (BITS == 4) {
    const device uint16_t* ws = (const device uint16_t*)w;
    for (int i=0; i<VPT/4; ++i)
      accum += xt[4*i]*(ws[i]&0x000f) + xt[4*i+1]*(ws[i]&0x00f0) + xt[4*i+2]*(ws[i]&0x0f00) + xt[4*i+3]*(ws[i]&0xf000);
  } else {
    for (int i=0; i<VPT; ++i) accum += xt[i]*(float)w[i];
  }
  return scale*accum + sum*bias;
}
// one RESULTS_PER_SG-row block for output rows [orow, orow+4): fills per-lane
// partials in result[4] (caller simd_sums + writes). x is the full staged input.
template <int BITS>
inline void qmv4(const device uint8_t* wbase, const device bfloat16_t* scbase, const device bfloat16_t* bibase,
                 threadgroup const bfloat16_t* x, int K, int orow, uint lane, thread float* result) {
  constexpr int pf = 32/BITS, bpp = 4, ppt = 2, VPT = pf*ppt, block = VPT*32, sstep = 64/VPT;
  const int wrow = K*bpp/pf;   // bytes per weight row
  const int grow = K/64;       // groups per row
  const device uint8_t* ws = wbase + (uint)orow*(uint)wrow + (uint)lane*ppt*bpp;
  const device bfloat16_t* sl = scbase + (uint)orow*(uint)grow + lane/sstep;
  const device bfloat16_t* bl = bibase + (uint)orow*(uint)grow + lane/sstep;
  threadgroup const bfloat16_t* xp = x + lane*VPT;
  for (int r=0; r<RESULTS_PER_SG; ++r) result[r]=0.0f;
  for (int k=0; k<K; k+=block) {
    float xt[VPT]; float s = load_vec_tg<BITS>(xp, xt);
    for (int row=0; row<RESULTS_PER_SG; ++row) {
      const device uint8_t* wl = ws + (uint)row*(uint)wrow;
      float sc=(float)sl[row*grow], bi=(float)bl[row*grow];
      result[row] += qdot_t<BITS>(wl, xt, sc, bi, s);
    }
    ws += (uint)(block*bpp/pf); sl += block/64; bl += block/64; xp += block;
  }
}

// Per-matrix dispatch over output rows. bits dispatched ONCE outside the row loop
// (each branch is the efficient mlx kernel, so the duplication is worth it here,
// unlike the naive-GEMV templating that regressed). WRITE: fresh output to DST.
#define QMV_W(DST, BASE) do { \
  const uint _b=(BASE); int _N=(int)meta[_b+3], _K=(int)meta[_b+4], _bits=(int)meta[_b+5]; \
  const device uint8_t* _w=W8+meta[_b+0]; const device bfloat16_t* _s=scales+meta[_b+1]; const device bfloat16_t* _bi=biases+meta[_b+2]; \
  if (_bits==4) { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<4>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) A_ST(DST,(uint)(orow+r),(bfloat16_t)v); } } } \
  else          { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<8>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) A_ST(DST,(uint)(orow+r),(bfloat16_t)v); } } } } while(0)
// ACCUMULATE into d_hidden (residual add for o-proj / down).
#define QMV_ACC(BASE) do { \
  const uint _b=(BASE); int _N=(int)meta[_b+3], _K=(int)meta[_b+4], _bits=(int)meta[_b+5]; \
  const device uint8_t* _w=W8+meta[_b+0]; const device bfloat16_t* _s=scales+meta[_b+1]; const device bfloat16_t* _bi=biases+meta[_b+2]; \
  if (_bits==4) { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<4>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) A_ST(d_hidden,(uint)(orow+r),(bfloat16_t)(A_LD(d_hidden,(uint)(orow+r))+v)); } } } \
  else          { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<8>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) A_ST(d_hidden,(uint)(orow+r),(bfloat16_t)(A_LD(d_hidden,(uint)(orow+r))+v)); } } } } while(0)
// final lm_head → logits (f32, plain store)
#define QMV_LOGITS(BASE) do { \
  const uint _b=(BASE); int _N=(int)meta[_b+3], _K=(int)meta[_b+4], _bits=(int)meta[_b+5]; \
  const device uint8_t* _w=W8+meta[_b+0]; const device bfloat16_t* _s=scales+meta[_b+1]; const device bfloat16_t* _bi=biases+meta[_b+2]; \
  if (_bits==4) { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<4>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) logits[orow+r]=v; } } } \
  else          { for (int orow=(int)sgG*RESULTS_PER_SG; orow<_N; orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<8>(_w,_s,_bi,xloc,_K,orow,lane,res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<_N) logits[orow+r]=v; } } } } while(0)

// Literal-argument variants for the GENERATED (layer-unrolled) kernel: the caller
// bakes (wOff,sOff,bOff,N,K,bits) as compile-time literals per (layer,matrix), so
// there is no META lookup and no runtime bits dispatch — bits picks the qmv4<>
// instantiation at compile time and every address fold is constant. (See
// genSourceMt; the layer loop is unrolled but K-loops stay rolled → no register
// bloat, sequential layers reuse registers. docs/.../Phase 3.)
#define QMV_WL(DST, WOFF, SOFF, BOFF, NN, KK, BITS) \
  for (int orow=(int)sgG*RESULTS_PER_SG; orow<(NN); orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<BITS>(W8+(WOFF), scales+(SOFF), biases+(BOFF), xloc, (KK), orow, lane, res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<(NN)) A_ST(DST,(uint)(orow+r),(bfloat16_t)v); } }
#define QMV_ACCL(WOFF, SOFF, BOFF, NN, KK, BITS) \
  for (int orow=(int)sgG*RESULTS_PER_SG; orow<(NN); orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<BITS>(W8+(WOFF), scales+(SOFF), biases+(BOFF), xloc, (KK), orow, lane, res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<(NN)) A_ST(d_hidden,(uint)(orow+r),(bfloat16_t)(A_LD(d_hidden,(uint)(orow+r))+v)); } }
#define QMV_LOGITSL(WOFF, SOFF, BOFF, NN, KK, BITS) \
  for (int orow=(int)sgG*RESULTS_PER_SG; orow<(NN); orow+=(int)NSGT*RESULTS_PER_SG) { float res[RESULTS_PER_SG]; qmv4<BITS>(W8+(WOFF), scales+(SOFF), biases+(BOFF), xloc, (KK), orow, lane, res); for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<(NN)) logits[orow+r]=v; } }

// load a device-atomic activation vector into threadgroup memory (once per group)
inline void load_xloc(const device uint* src, threadgroup bfloat16_t* xloc, int K, uint lid) {
  for (uint i=lid; i<(uint)K; i+=TGN_MT_C) xloc[i] = (bfloat16_t)A_LD(src, i);
}

// RMSNorm: every group reduces the full residual stream (redundant, tiny) and
// writes its strided share of d_nrm. (input already in xloc.)
inline void rms_norm_mt(threadgroup const bfloat16_t* xloc, const device bfloat16_t* norms, uint wOff,
                        device uint* d_nrm, threadgroup float* red, uint lid, uint gid, uint GT) {
  float part = 0.0f;
  for (uint i=lid; i<H_C; i+=TGN_MT_C) { float v=(float)xloc[i]; part += v*v; }
  red[lid] = part;
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint s=TGN_MT_C/2; s>0; s>>=1) { if (lid<s) red[lid]+=red[lid+s]; threadgroup_barrier(mem_flags::mem_threadgroup); }
  float inv = 1.0f / metal::sqrt(red[0]/(float)H_C + EPS);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint i=gid; i<H_C; i+=GT) A_ST(d_nrm, i, (bfloat16_t)((float)xloc[i]*inv*(float)norms[wOff+i]));
}

// RMSNorm computed ENTIRELY within one threadgroup, in place on xloc (no device
// write, no grid barrier): every threadgroup redundantly normalizes the full
// hidden (H is tiny) so the following GEMV reads xloc directly. d_hidden is already
// globally consistent from the prior layer's end-of-layer barrier, so all
// threadgroups produce identical xloc. Replaces rms_norm_mt + grid barrier + reload.
inline void rms_norm_local(threadgroup bfloat16_t* xloc, const device bfloat16_t* norms, uint wOff,
                           threadgroup float* red, uint lid) {
  float part = 0.0f;
  for (uint i=lid; i<H_C; i+=TGN_MT_C) { float v=(float)xloc[i]; part += v*v; }
  red[lid] = part;
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint s=TGN_MT_C/2; s>0; s>>=1) { if (lid<s) red[lid]+=red[lid+s]; threadgroup_barrier(mem_flags::mem_threadgroup); }
  float inv = 1.0f / metal::sqrt(red[0]/(float)H_C + EPS);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (uint i=lid; i<H_C; i+=TGN_MT_C) xloc[i] = (bfloat16_t)((float)xloc[i]*inv*(float)norms[wOff+i]);
}

// rope one (head,pair) of a threadgroup vector, in place
inline void rope_pair_tg(threadgroup bfloat16_t* x, uint idx, int pos) {
  uint h=idx/HALFDIM, i=idx%HALFDIM;
  float inv=metal::pow((float)ROPE_BASE, -2.0f*(float)i/(float)HEADDIM);
  float ang=(float)pos*inv, c=metal::precise::cos(ang), s=metal::precise::sin(ang);
  threadgroup bfloat16_t* b=x+h*HEADDIM;
  float x0=(float)b[i], x1=(float)b[i+HALFDIM];
  b[i]=(bfloat16_t)(x0*c-x1*s); b[i+HALFDIM]=(bfloat16_t)(x1*c+x0*s);
}

// KV quantize (Phase 4 L2, increment 2a): one thread quantizes a 64-value group of a
// device-atomic KV vector, replicating mlx affine_quantize (quantized.h:2432). Stores
// the quantized INT q back into d (q ≤ 255 is EXACT in bf16 — lossless), and the
// bf16 scale/bias into the side buffer sb at the given flat slots. attend_simd_q
// dequants q to f32 on read (scale*q+bias) = optiq's exact f32 dequant, NO extra bf16
// rounding (vs increment 1 which stored bf16(scale*q+bias)). Two passes (no 64-reg
// array). q uses f32 scale/bias; dequant later uses the bf16-stored ones (== mlx).
template <int KVBITS>
inline void kv_quant_group(device uint* d, uint base, device uint* dsb, uint scaleSlot, uint biasSlot) {
  constexpr float nBins = (float)((1 << KVBITS) - 1), eps = 1e-7f;
  float wmin = INFINITY, wmax = 0.0f;
  for (uint i=0; i<64u; ++i) { float v=A_LD(d, base+i); wmin=metal::min(wmin,v); wmax=metal::max(wmax,v); }
  float scale = metal::max((wmax-wmin)/nBins, eps);
  bool side = metal::abs(wmin) > metal::abs(wmax);
  scale = side ? scale : -scale;
  float edge = side ? wmin : wmax;
  float q0 = metal::round(edge/scale);
  scale = (q0==0.0f) ? scale : edge/q0;
  float bias = (q0==0.0f) ? 0.0f : edge;
  // store bf16-rounded scale/bias ATOMICALLY (cross-threadgroup coherent — attention
  // reads them from every threadgroup; non-atomic device writes would be stale).
  A_ST(dsb, scaleSlot, (float)(bfloat16_t)scale);
  A_ST(dsb, biasSlot, (float)(bfloat16_t)bias);
  // q from the F32 scale/bias (== mlx affine_quantize); dequant later uses the bf16 ones.
  for (uint i=0; i<64u; ++i) { float v=A_LD(d, base+i); float q=metal::min(metal::round((v-bias)/scale), nBins); A_ST(d, base+i, (bfloat16_t)q); }
}

// attention for one q-head, SIMD-COOPERATIVE: the 32 lanes split head_dim (HEADDIM/32
// dims each), so per-thread state is tiny (a few registers, not acc[128]) — that's
// what keeps kernel occupancy high enough for the GEMV stages to saturate bandwidth.
// q/k/v current pos in device-atomic scratch; prior keys/values in the device KV cache.
#define DPL (HEADDIM/32)   // dims per lane
inline void attend_simd(uint h, uint lane, device uint* d_q, device uint* d_k, device uint* d_v,
                        const device bfloat16_t* kcache, const device bfloat16_t* vcache,
                        device uint* d_attn, int L, int pos, int KVSEQ) {
  uint kvh=h/NREP, qbase=h*HEADDIM;
  float qd[DPL], acc[DPL];
  for (int t=0; t<DPL; ++t) { qd[t]=A_LD(d_q, qbase + lane + 32u*t); acc[t]=0.0f; }
  float m=-INFINITY, l=0.0f;
  for (int j=0; j<=pos; ++j) {
    bool cur=(j==pos);
    uint off = cur ? (kvh*HEADDIM) : (((uint)(L*KVSEQ+j))*KVDIM + kvh*HEADDIM);
    float ps=0.0f;
    for (int t=0; t<DPL; ++t) { uint d=lane+32u*t; float kv = cur ? A_LD(d_k, off+d) : (float)kcache[off+d]; ps += qd[t]*kv; }
    float score = metal::simd_sum(ps) * ATTN_SCALE;     // full dot, broadcast to all lanes
    float mnew=metal::max(m,score), corr=metal::precise::exp(m-mnew), p=metal::precise::exp(score-mnew);
    l=l*corr+p;
    for (int t=0; t<DPL; ++t) { uint d=lane+32u*t; float vv = cur ? A_LD(d_v, off+d) : (float)vcache[off+d]; acc[t]=acc[t]*corr+p*vv; }
    m=mnew;
  }
  float invl=1.0f/l;
  for (int t=0; t<DPL; ++t) A_ST(d_attn, qbase + lane + 32u*t, (bfloat16_t)(acc[t]*invl));
}

// L2 attention (Phase 4 2a): identical to attend_simd but K/V are stored as quantized
// ints (kcache/vcache, d_k/d_v) + per-group bf16 scale/bias in side buffers; dequant
// scale·q+bias to f32 on read (== optiq quantizedMatmulQT). sbCur = current-pos
// scale/bias (sbNew, base L*16); SB = cached [NLAYERS,KVSEQ,16]. 16 slots/pos:
// K-scale[0..3], K-bias[4..7], V-scale[8..11], V-bias[12..15], slot = kvh*2+group.
template <int KVBITS>
inline void attend_simd_q(uint h, uint lane, device uint* d_q, device uint* d_k, device uint* d_v,
                          const device bfloat16_t* kcache, const device bfloat16_t* vcache,
                          device uint* d_sb, const device bfloat16_t* SB,
                          device uint* d_attn, int L, int pos, int KVSEQ) {
  uint kvh=h/NREP, qbase=h*HEADDIM;
  float qd[DPL], acc[DPL];
  for (int t=0; t<DPL; ++t) { qd[t]=A_LD(d_q, qbase + lane + 32u*t); acc[t]=0.0f; }
  float m=-INFINITY, l=0.0f;
  for (int j=0; j<=pos; ++j) {
    bool cur=(j==pos);
    uint off = cur ? (kvh*HEADDIM) : (((uint)(L*KVSEQ+j))*KVDIM + kvh*HEADDIM);
    uint sbBase = cur ? (uint)(L*16) : ((uint)(L*KVSEQ+j))*16u;
    // scale/bias: current-pos from atomic d_sb (cross-threadgroup coherent), cached
    // from the coherent SB input. SC(slot)/BI(slot) pick the right source.
    #define KV_SC(s) (cur ? A_LD(d_sb, sbBase+(s)) : (float)SB[sbBase+(s)])
    float ps=0.0f;
    for (int t=0; t<DPL; ++t) {
      uint d=lane+32u*t, slot=kvh*2u + d/64u;
      float q = cur ? A_LD(d_k, off+d) : (float)kcache[off+d];
      ps += qd[t]*(KV_SC(slot)*q + KV_SC(4u+slot));
    }
    float score = metal::simd_sum(ps) * ATTN_SCALE;
    float mnew=metal::max(m,score), corr=metal::precise::exp(m-mnew), p=metal::precise::exp(score-mnew);
    l=l*corr+p;
    for (int t=0; t<DPL; ++t) {
      uint d=lane+32u*t, slot=kvh*2u + d/64u;
      float q = cur ? A_LD(d_v, off+d) : (float)vcache[off+d];
      acc[t]=acc[t]*corr+p*(KV_SC(8u+slot)*q + KV_SC(12u+slot));
    }
    #undef KV_SC
    m=mnew;
  }
  float invl=1.0f/l;
  for (int t=0; t<DPL; ++t) A_ST(d_attn, qbase + lane + 32u*t, (bfloat16_t)(acc[t]*invl));
}
`;
}

const SOURCE_MT = String.raw`
  const uint lid  = thread_position_in_threadgroup.x;
  const uint tgid = threadgroup_position_in_grid.x;
  const uint sgid = simdgroup_index_in_threadgroup;
  const uint lane = thread_index_in_simdgroup;
  const uint gid  = tgid*TGN_MT_C + lid;
  const uint GT   = (uint)G_T*TGN_MT_C;
  const uint sgG  = tgid*NSG + sgid;          // global simdgroup id
  const uint NSGT = (uint)G_T*NSG;            // total simdgroups
  const int  pos  = (int)posArr[0];
  const device uint8_t* W8 = (const device uint8_t*)wbytes;
  device atomic_uint* ga = (device atomic_uint*)&barrier_arrive[0];
  device atomic_uint* gs = (device atomic_uint*)&barrier_sense[0];
  uint expect = 0u;

  threadgroup bfloat16_t xloc[XLOC_CAP];   // staged GEMV input (down K=I is tiled)
  threadgroup float red[TGN_MT_C];

  // stage 0: d_hidden = embed(token)
  for (uint i=gid; i<H_C; i+=GT) A_ST(d_hidden, i, (float)hidden0[i]);
  grid_barrier(ga, gs, lid, G_T, expect);

  for (int L=0; L<NLAYERS; ++L) {
    const uint mb=(uint)L*META_STRIDE;

    // stage 1+2 FUSED: input RMSNorm(d_hidden) in-place into xloc (no grid barrier),
    // then q/k/v GEMVs read it directly. d_hidden is globally consistent from the
    // prior layer's end barrier (or stage 0's barrier for L=0).
    load_xloc(d_hidden, xloc, H_C, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    rms_norm_local(xloc, norms, meta[mb+42], red, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    QMV_W(d_q, mb+0);
    QMV_W(d_k, mb+6);
    QMV_W(d_v, mb+12);
    grid_barrier(ga, gs, lid, G_T, expect);

    // stage 3a: rope q (d_q) + k (d_k) across the grid; emit cache rows from d_k/d_v
    for (uint idx=gid; idx<(uint)(NHEADS*HALFDIM);  idx+=GT) {
      uint h=idx/HALFDIM, i=idx%HALFDIM, base=h*HEADDIM;
      float inv=metal::pow((float)ROPE_BASE,-2.0f*(float)i/(float)HEADDIM), ang=(float)pos*inv, c=metal::precise::cos(ang), s=metal::precise::sin(ang);
      float x0=A_LD(d_q,base+i), x1=A_LD(d_q,base+i+HALFDIM);
      A_ST(d_q,base+i,(bfloat16_t)(x0*c-x1*s)); A_ST(d_q,base+i+HALFDIM,(bfloat16_t)(x1*c+x0*s));
    }
    for (uint idx=gid; idx<(uint)(NKVHEADS*HALFDIM); idx+=GT) {
      uint h=idx/HALFDIM, i=idx%HALFDIM, base=h*HEADDIM;
      float inv=metal::pow((float)ROPE_BASE,-2.0f*(float)i/(float)HEADDIM), ang=(float)pos*inv, c=metal::precise::cos(ang), s=metal::precise::sin(ang);
      float x0=A_LD(d_k,base+i), x1=A_LD(d_k,base+i+HALFDIM);
      A_ST(d_k,base+i,(bfloat16_t)(x0*c-x1*s)); A_ST(d_k,base+i+HALFDIM,(bfloat16_t)(x1*c+x0*s));
    }
    grid_barrier(ga, gs, lid, G_T, expect);   // rope must complete before d_k/d_q are read

    // stage 3b: emit cache rows (roped k, v) + attention (heads split over the grid)
    for (uint i=gid; i<KVDIM; i+=GT) { knewOut[(uint)L*KVDIM+i]=(bfloat16_t)A_LD(d_k,i); vnewOut[(uint)L*KVDIM+i]=(bfloat16_t)A_LD(d_v,i); }
    for (uint hh=sgG; hh<(uint)NHEADS; hh+=NSGT) attend_simd(hh, lane, d_q, d_k, d_v, kcache, vcache, d_attn, L, pos, KVSEQ_T);
    grid_barrier(ga, gs, lid, G_T, expect);

    // stage 4: o = Wo·attn; d_hidden += o
    load_xloc(d_attn, xloc, NHEADS*HEADDIM, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    QMV_ACC(mb+18);
    grid_barrier(ga, gs, lid, G_T, expect);

    // stage 5+6 FUSED: post-attn RMSNorm(d_hidden) in-place into xloc (no grid
    // barrier), then gate/up GEMVs read it directly. d_hidden globally consistent
    // from stage 4's barrier.
    load_xloc(d_hidden, xloc, H_C, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    rms_norm_local(xloc, norms, meta[mb+43], red, lid);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    QMV_W(d_gate, mb+24);
    QMV_W(d_up,   mb+30);
    grid_barrier(ga, gs, lid, G_T, expect);

    // stage 7+8 FUSED: silu(gate)·up is computed straight into each threadgroup's
    // private xloc (no grid barrier, no d_gate device round-trip — gate/up are
    // already globally visible from stage 6's barrier), then the down qmv4 GEMV
    // accumulates into the residual. Saves one grid barrier + one I-vector device
    // write/read per layer vs the old separate elementwise stage.
    for (uint i=lid; i<(uint)I_C; i+=TGN_MT_C) {
      bfloat16_t gT=(bfloat16_t)A_LD(d_gate,i);
      bfloat16_t sigT=(bfloat16_t)(1.0f/(1.0f+metal::precise::exp(-(float)gT)));
      bfloat16_t siluT=(bfloat16_t)((float)gT*(float)sigT);
      xloc[i]=(bfloat16_t)((float)siluT*A_LD(d_up,i));
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    QMV_ACC(mb+36);
    grid_barrier(ga, gs, lid, G_T, expect);
  }

  // final: d_nrm = RMSNorm(d_hidden, finalNorm); logits = lm_head·nrm
  load_xloc(d_hidden, xloc, H_C, lid);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  rms_norm_local(xloc, norms, meta[NLAYERS*META_STRIDE+0], red, lid);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_LOGITS(NLAYERS*META_STRIDE+1);
`;

// ── GENERATED (layer-unrolled, constants baked) MT source ────────────────────
// The user's "layer 17 is pre-determined RIGHT NOW": emit the 24-layer body with
// every (layer,matrix) bits/offsets/N/K and the layer index L as compile-time
// literals — no META lookups, no runtime bits dispatch, all address arithmetic
// constant-folded. The layer loop is unrolled (sequential → registers reused, no
// occupancy hit); inner K-loops stay rolled (that's what would bloat registers).
function genSourceMt(layout: MegaLayout, kvSeq: number, kvQuant: boolean): string {
  const mat = (m: MatLayout) => `${m.wOff}u, ${m.sOff}u, ${m.bOff}u, ${m.N}, ${m.K}, ${m.bits}`;
  const lines: string[] = [String.raw`
  const uint lid  = thread_position_in_threadgroup.x;
  const uint tgid = threadgroup_position_in_grid.x;
  const uint sgid = simdgroup_index_in_threadgroup;
  const uint lane = thread_index_in_simdgroup;
  const uint gid  = tgid*TGN_MT_C + lid;
  const uint GT   = (uint)G_T*TGN_MT_C;
  const uint sgG  = tgid*NSG + sgid;
  const uint NSGT = (uint)G_T*NSG;
  const int  pos  = (int)posArr[0];
  const device uint8_t* W8 = (const device uint8_t*)wbytes;
  device atomic_uint* ga = (device atomic_uint*)&barrier_arrive[0];
  device atomic_uint* gs = (device atomic_uint*)&barrier_sense[0];
  uint expect = 0u;
  threadgroup bfloat16_t xloc[XLOC_CAP];
  threadgroup float red[TGN_MT_C];

  for (uint i=gid; i<H_C; i+=GT) A_ST(d_hidden, i, (float)hidden0[i]);
  grid_barrier(ga, gs, lid, G_T, expect);
`];
  for (let L = 0; L < layout.nLayers; L++) {
    const ly = layout.layers[L]!;
    // L2: quantize→dequant round-trip of the roped current-pos k/v (per-layer KVBITS
    // literal). Stored bf16 == what real packed storage dequantizes to ⇒ logits match.
    const kvb = kvQuant ? (layout.kvBits[L] ?? 0) : 0;
    // L2 2a: quantize roped current k/v → store int q in d_k/d_v + bf16 scale/bias in
    // sbNew (16 slots/layer: Ks0-3,Kb0-3,Vs0-3,Vb0-3; slot = kvh*2+group).
    const rt = kvb > 0 ? `
  for (uint g=gid; g<(uint)(KVDIM/64); g+=GT) { kv_quant_group<${kvb}>(d_k, g*64u, d_sb, ${L}*16u+g, ${L}*16u+4u+g); kv_quant_group<${kvb}>(d_v, g*64u, d_sb, ${L}*16u+8u+g, ${L}*16u+12u+g); }
  grid_barrier(ga, gs, lid, G_T, expect);
  for (uint s=gid; s<16u; s+=GT) sbNew[${L}*16u+s] = (bfloat16_t)A_LD(d_sb, ${L}*16u+s);` : "";
    const attn = kvb > 0
      ? `attend_simd_q<${kvb}>(hh, lane, d_q, d_k, d_v, kcache, vcache, d_sb, sb, d_attn, ${L}, pos, ${kvSeq})`
      : `attend_simd(hh, lane, d_q, d_k, d_v, kcache, vcache, d_attn, ${L}, pos, ${kvSeq})`;
    lines.push(String.raw`
  // ───── layer ${L} ─────
  load_xloc(d_hidden, xloc, H_C, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  rms_norm_local(xloc, norms, ${ly.inputNormOff}u, red, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_WL(d_q, ${mat(ly.q)});
  QMV_WL(d_k, ${mat(ly.k)});
  QMV_WL(d_v, ${mat(ly.v)});
  grid_barrier(ga, gs, lid, G_T, expect);
  for (uint idx=gid; idx<(uint)(NHEADS*HALFDIM); idx+=GT) {
    uint h=idx/HALFDIM, i=idx%HALFDIM, base=h*HEADDIM;
    float inv=metal::pow((float)ROPE_BASE,-2.0f*(float)i/(float)HEADDIM), ang=(float)pos*inv, c=metal::precise::cos(ang), s=metal::precise::sin(ang);
    float x0=A_LD(d_q,base+i), x1=A_LD(d_q,base+i+HALFDIM);
    A_ST(d_q,base+i,(bfloat16_t)(x0*c-x1*s)); A_ST(d_q,base+i+HALFDIM,(bfloat16_t)(x1*c+x0*s));
  }
  for (uint idx=gid; idx<(uint)(NKVHEADS*HALFDIM); idx+=GT) {
    uint h=idx/HALFDIM, i=idx%HALFDIM, base=h*HEADDIM;
    float inv=metal::pow((float)ROPE_BASE,-2.0f*(float)i/(float)HEADDIM), ang=(float)pos*inv, c=metal::precise::cos(ang), s=metal::precise::sin(ang);
    float x0=A_LD(d_k,base+i), x1=A_LD(d_k,base+i+HALFDIM);
    A_ST(d_k,base+i,(bfloat16_t)(x0*c-x1*s)); A_ST(d_k,base+i+HALFDIM,(bfloat16_t)(x1*c+x0*s));
  }
  grid_barrier(ga, gs, lid, G_T, expect);${rt}
  for (uint i=gid; i<KVDIM; i+=GT) { knewOut[${L}*KVDIM+i]=(bfloat16_t)A_LD(d_k,i); vnewOut[${L}*KVDIM+i]=(bfloat16_t)A_LD(d_v,i); }
  for (uint hh=sgG; hh<(uint)NHEADS; hh+=NSGT) ${attn};
  grid_barrier(ga, gs, lid, G_T, expect);
  load_xloc(d_attn, xloc, NHEADS*HEADDIM, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_ACCL(${mat(ly.o)});
  grid_barrier(ga, gs, lid, G_T, expect);
  load_xloc(d_hidden, xloc, H_C, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  rms_norm_local(xloc, norms, ${ly.postNormOff}u, red, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_WL(d_gate, ${mat(ly.gate)});
  QMV_WL(d_up, ${mat(ly.up)});
  grid_barrier(ga, gs, lid, G_T, expect);
  for (uint i=lid; i<(uint)I_C; i+=TGN_MT_C) {
    bfloat16_t gT=(bfloat16_t)A_LD(d_gate,i);
    bfloat16_t sigT=(bfloat16_t)(1.0f/(1.0f+metal::precise::exp(-(float)gT)));
    bfloat16_t siluT=(bfloat16_t)((float)gT*(float)sigT);
    xloc[i]=(bfloat16_t)((float)siluT*A_LD(d_up,i));
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_ACCL(${mat(ly.down)});
  grid_barrier(ga, gs, lid, G_T, expect);
`);
  }
  lines.push(String.raw`
  load_xloc(d_hidden, xloc, H_C, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  rms_norm_local(xloc, norms, ${layout.finalNormOff}u, red, lid); threadgroup_barrier(mem_flags::mem_threadgroup);
  QMV_LOGITSL(${mat(layout.lmHead)});
`);
  return lines.join("\n");
}

// L2 quantized KV (Phase 4): in-kernel quantize→dequant of cached KV (per-layer
// bits from config.kvQuant). Requires the generated path (per-layer KVBITS literal).
export const USE_KVQUANT = process.env.MLX_BUN_MEGAKERNEL_KVQUANT === "1";
const USE_GEN = process.env.MLX_BUN_MEGAKERNEL_GEN === "1" || USE_KVQUANT;

let _kernelMt: MetalKernel | null = null;
function getKernelMt(layout: MegaLayout, kvSeq: number): MetalKernel {
  if (!_kernelMt) {
    _kernelMt = new MetalKernel({
      name: USE_GEN ? "mlx_bun_minicpm5_megakernel_mt_gen" : "mlx_bun_minicpm5_megakernel_mt",
      // L2 adds `sb` (cached per-group KV scale/bias) input + `sbNew` (current-pos
      // scale/bias) output. Order must match decodeStep's apply() arrays.
      inputNames: ["wbytes", "scales", "biases", "norms", "hidden0", "kcache", "vcache", "meta", "posArr",
        ...(USE_KVQUANT ? ["sb"] : [])],
      outputNames: ["logits", "knewOut", "vnewOut", "d_hidden", "d_nrm", "d_q", "d_k", "d_v", "d_attn", "d_gate", "d_up", "barrier_arrive", "barrier_sense",
        ...(USE_KVQUANT ? ["sbNew", "d_sb"] : [])],
      header: kernelHeader(layout) + `\n#define TGN_MT_C ${TGN_MT}\n#define XLOC_CAP ${layout.I}\n#define MAXROWS 8\n`
        + (process.env.MLX_BUN_MEGAKERNEL_NOBAR === "1" ? `#define MEGABAR_NOOP\n` : ``) + helpersMt(),
      source: USE_GEN ? genSourceMt(layout, kvSeq, USE_KVQUANT) : SOURCE_MT,
      ensureRowContiguous: true,
    });
  }
  return _kernelMt;
}

/** Stateful decode runner: holds the packed weights + persistent KV cache and
 *  runs one M=1 megakernel dispatch per token. */
export class MegakernelRunner {
  readonly packed: PackedModel;
  readonly meta: MlxArray;
  readonly layout: MegaLayout;
  readonly KVDIM: number;
  kcache: MlxArray;   // [NLAYERS, KVSEQ, KVDIM] bf16 (L2: stores quantized int q)
  vcache: MlxArray;
  sb!: MlxArray;      // L2 only: [NLAYERS, KVSEQ, sbWidth] bf16 KV scale/bias side buffer
  readonly sbWidth: number;  // nKvHeads*(headDim/64) groups × 2 (K/V) × 2 (scale/bias)
  kvSeq: number;
  pos = 0;
  readonly G: number;

  constructor(private model: MiniCPM5Model, kvSeq = 512, G = Number(process.env.MLX_BUN_MEGAKERNEL_G) || 32) {
    // Default G=32 @ TGN=256 is the measured Phase-3 peak on the M4 Pro (20 GPU
    // cores): ~202 tok/s, ~0.94× baseline, paired same-process A/B (Phase 3 results
    // in docs/design/minicpm5-decode-megakernel.md). G must stay ≤ co-resident
    // threadgroups or the software grid-barrier deadlocks (G≥~144 hangs here); the
    // qmv4 GEMV removed the old down-tiling G≥24 constraint, so any G is now correct.
    // G=1 falls back to the single-threadgroup correctness kernel. TGN via env
    // MLX_BUN_MEGAKERNEL_TGN (power-of-2 only; default 256).
    this.G = G;
    this.packed = packMiniCpm5(model);
    this.layout = this.packed.layout;
    this.KVDIM = this.layout.nKvHeads * this.layout.headDim;
    const metaArr = buildMeta(this.layout);
    this.meta = MlxArray.fromBytesCopy(new Uint8Array(metaArr.buffer), [metaArr.length], Dtype.uint32);
    this.sbWidth = this.layout.nKvHeads * (this.layout.headDim / this.layout.kvGroupSize) * 4;
    this.kvSeq = kvSeq;
    this.kcache = ops.zeros([this.layout.nLayers, kvSeq, this.KVDIM], Dtype.bfloat16);
    this.vcache = ops.zeros([this.layout.nLayers, kvSeq, this.KVDIM], Dtype.bfloat16);
    if (USE_KVQUANT) this.sb = ops.zeros([this.layout.nLayers, kvSeq, this.sbWidth], Dtype.bfloat16);
    for (const a of [this.packed.wbytes, this.packed.scales, this.packed.biases, this.packed.norms, this.meta]) a.eval();
  }

  reset(): void {
    this.pos = 0;
    this.kcache.dispose(); this.vcache.dispose();
    this.kcache = ops.zeros([this.layout.nLayers, this.kvSeq, this.KVDIM], Dtype.bfloat16);
    this.vcache = ops.zeros([this.layout.nLayers, this.kvSeq, this.KVDIM], Dtype.bfloat16);
    if (USE_KVQUANT) { this.sb.dispose(); this.sb = ops.zeros([this.layout.nLayers, this.kvSeq, this.sbWidth], Dtype.bfloat16); }
  }

  /** One decode step: token at `this.pos` → logits[1,V] (f32); advances pos. */
  decodeStep(tokenId: number): MlxArray {
    if (this.pos >= this.kvSeq) this.#growCache();
    const L = this.layout;
    const ids = ops.fromInt32([tokenId], [1, 1]);
    const emb = this.model.embed.encode(ids); // [1,1,H] bf16
    ids.dispose();
    const hidden0 = ops.reshape(emb, [L.H]);
    emb.dispose();
    const posArr = MlxArray.fromBytesCopy(new Uint8Array(new Uint32Array([this.pos]).buffer), [1], Dtype.uint32);
    const inputs = [this.packed.wbytes, this.packed.scales, this.packed.biases, this.packed.norms,
      hidden0, this.kcache, this.vcache, this.meta, posArr];
    if (USE_KVQUANT) inputs.push(this.sb);

    let logits: MlxArray | undefined, knewOut: MlxArray | undefined, vnewOut: MlxArray | undefined, sbNew: MlxArray | undefined;
    if (this.G > 1) {
      const QD = L.nHeads * L.headDim;
      const u = (n: number) => ({ shape: [n], dtype: Dtype.uint32 });
      const outs = getKernelMt(L, this.kvSeq).apply(inputs, {
        outputs: [
          { shape: [1, L.V], dtype: Dtype.float32 },
          { shape: [L.nLayers, this.KVDIM], dtype: Dtype.bfloat16 },
          { shape: [L.nLayers, this.KVDIM], dtype: Dtype.bfloat16 },
          u(L.H), u(L.H), u(QD), u(this.KVDIM), u(this.KVDIM), u(QD), u(L.I), u(L.I), u(1), u(1), // d_hidden,d_nrm,d_q,d_k,d_v,d_attn,d_gate,d_up,barrier×2
          ...(USE_KVQUANT ? [{ shape: [L.nLayers, this.sbWidth], dtype: Dtype.bfloat16 }, u(L.nLayers * 16)] : []), // sbNew, d_sb (atomic scratch)
        ],
        grid: [this.G * TGN_MT, 1, 1],
        threadGroup: [TGN_MT, 1, 1],
        templateInts: { KVSEQ_T: this.kvSeq, G_T: this.G },
        initValue: 0,
      });
      [logits, knewOut, vnewOut] = outs;
      if (USE_KVQUANT) sbNew = outs[outs.length - 2]; // d_sb is last (scratch)
      for (let i = 3; i < outs.length; i++) { if (USE_KVQUANT && i === outs.length - 2) continue; outs[i]!.dispose(); } // dispose all scratch, keep sbNew
    } else {
      [logits, knewOut, vnewOut] = getKernel(L).apply(inputs, {
        outputs: [
          { shape: [1, L.V], dtype: Dtype.float32 },
          { shape: [L.nLayers, this.KVDIM], dtype: Dtype.bfloat16 },
          { shape: [L.nLayers, this.KVDIM], dtype: Dtype.bfloat16 },
        ],
        grid: [TGN, 1, 1],
        threadGroup: [TGN, 1, 1],
        templateInts: { KVSEQ_T: this.kvSeq },
      });
    }
    hidden0.dispose();
    posArr.dispose();
    const kRow = ops.reshape(knewOut!, [L.nLayers, 1, this.KVDIM]);
    const vRow = ops.reshape(vnewOut!, [L.nLayers, 1, this.KVDIM]);
    knewOut!.dispose(); vnewOut!.dispose();
    const k2 = ops.sliceUpdate(this.kcache, kRow, [0, this.pos, 0], [L.nLayers, this.pos + 1, this.KVDIM]);
    const v2 = ops.sliceUpdate(this.vcache, vRow, [0, this.pos, 0], [L.nLayers, this.pos + 1, this.KVDIM]);
    kRow.dispose(); vRow.dispose();
    this.kcache.dispose(); this.vcache.dispose();
    this.kcache = k2; this.vcache = v2;
    if (USE_KVQUANT) {
      const sbRow = ops.reshape(sbNew!, [L.nLayers, 1, this.sbWidth]);
      sbNew!.dispose();
      const sb2 = ops.sliceUpdate(this.sb, sbRow, [0, this.pos, 0], [L.nLayers, this.pos + 1, this.sbWidth]);
      sbRow.dispose(); this.sb.dispose(); this.sb = sb2;
      ops.evalAll([this.kcache, this.vcache, this.sb]);
    } else {
      ops.evalAll([this.kcache, this.vcache]);
    }
    this.pos += 1;
    return logits!;
  }

  #growCache(): void {
    const L = this.layout;
    const padK = ops.zeros([L.nLayers, 512, this.KVDIM], Dtype.bfloat16);
    const padV = ops.zeros([L.nLayers, 512, this.KVDIM], Dtype.bfloat16);
    const k2 = ops.concatAxis([this.kcache, padK], 1);
    const v2 = ops.concatAxis([this.vcache, padV], 1);
    for (const a of [this.kcache, this.vcache, padK, padV]) a.dispose();
    this.kcache = k2; this.vcache = v2;
    if (USE_KVQUANT) {
      const padSB = ops.zeros([L.nLayers, 512, this.sbWidth], Dtype.bfloat16);
      const sb2 = ops.concatAxis([this.sb, padSB], 1);
      this.sb.dispose(); padSB.dispose(); this.sb = sb2;
    }
    this.kvSeq += 512;
    if (_kernel) { _kernel.dispose(); _kernel = null; } // KVSEQ baked as templateInt
    if (_kernelMt) { _kernelMt.dispose(); _kernelMt = null; }
  }

  dispose(): void {
    for (const a of [this.packed.wbytes, this.packed.scales, this.packed.biases, this.packed.norms, this.meta, this.kcache, this.vcache]) a.dispose();
    if (USE_KVQUANT && this.sb) this.sb.dispose();
  }
}
