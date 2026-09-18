// Fused gate/up SwiGLU for packed Trellis projections whose bit widths DIFFER.
//
// The stock fused kernel (trellis-linear.ts / trellis-shared-m.ts) needs gate
// and up to share k, because one word layout and one bit offset serve both. A
// sensitivity-driven allocation assigns k per tensor, so some layers end up
// mixed (q4b: 10 of 64) and fall back to two projection kernels plus a separate
// SwiGLU: the input is read twice and both intermediate vectors are
// materialized. This kernel keeps everything else identical - one SIMD group per
// output row, lanes own 32-position runs, the two-accumulator FMA order,
// simd_sum, and the bf16 SwiGLU rounding boundaries - and gives gate and up their
// own word layout (KG, KU). M is a template parameter (1..4 rows share each
// decoded weight), so the same source serves decode and small verify windows.
//
// TAIL selects the SwiGLU arithmetic after the two bf16 projections:
//   0  sigmoid in float32 (precise::exp): the same-width fused kernel's arithmetic.
//   1  MLX's compiled swiglu, every temporary in type T (kernels/unary_ops.h
//      Sigmoid, then Multiply twice): what a mixed layer computes today through two
//      projection kernels plus the compiled closure. Bit-identical to that split
//      path, so switching a mixed layer onto this kernel changes no output.
//
// Header (TRELLIS_DECODE / TRELLIS_ROUND, 1MAD) is the shared one from
// trellis-linear.ts; this file only contributes the kernel body.

export const MIXED_GATEUP_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  if (row >= (uint)R) return;
  const uint gWpb = (uint)(BT * KG / 32);
  const uint uWpb = (uint)(BT * KU / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* gRow = gcodes + (ulong)row * (ulong)((C / BT) * gWpb);
  const device uint32_t* uRow = ucodes + (ulong)row * (ulong)((C / BT) * uWpb);
  const float gScale = float(gscales[row]);
  const float uScale = float(uscales[row]);
  float gAcc[M], gAcc2[M], uAcc[M], uAcc2[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    gAcc[m] = 0.0f; gAcc2[m] = 0.0f; uAcc[m] = 0.0f; uAcc2[m] = 0.0f;
  }
  for (uint run = lane; run < nRuns; run += 32u) {
    const uint blk = run / runsPerBlock;
    const uint t0 = (run - blk * runsPerBlock) * 32u;
    const device uint32_t* gw = gRow + blk * gWpb;
    const device uint32_t* uw = uRow + blk * uWpb;
    const uint gW0 = ((uint)BT - 32u - t0) * (uint)KG / 32u;
    const uint uW0 = ((uint)BT - 32u - t0) * (uint)KU / 32u;
    uint g[KG + 1];
    uint u[KU + 1];
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)KG; ++i) {
      const uint wi = gW0 + i;
      g[i] = gw[wi >= gWpb ? wi - gWpb : wi];
    }
    #pragma clang loop unroll(full)
    for (uint i = 0; i <= (uint)KU; ++i) {
      const uint wi = uW0 + i;
      u[i] = uw[wi >= uWpb ? wi - uWpb : wi];
    }
    const uint c0 = blk * (uint)BT + t0;
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      float4 xv4[M];
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m)
        xv4[m] = float4(((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + c0))[j4]);
      #pragma clang loop unroll(full)
      for (uint q = 0; q < 4u; ++q) {
        const uint j = j4 * 4u + q;
        const uint gb = (31u - j) * (uint)KG;
        const uint ub = (31u - j) * (uint)KU;
        const uint gwi = gb >> 5, goff = gb & 31u;
        const uint uwi = ub >> 5, uoff = ub & 31u;
        uint gwin = g[gwi] >> goff;
        uint uwin = u[uwi] >> uoff;
        if (goff + (uint)L > 32u) gwin |= g[gwi + 1] << (32u - goff);
        if (uoff + (uint)L > 32u) uwin |= u[uwi + 1] << (32u - uoff);
        gwin &= (1u << (uint)L) - 1u;
        uwin &= (1u << (uint)L) - 1u;
        const float gv = TRELLIS_ROUND(TRELLIS_DECODE(gwin, lutTG, lut) * gScale);
        const float uv = TRELLIS_ROUND(TRELLIS_DECODE(uwin, lutTG, lut) * uScale);
        #pragma clang loop unroll(full)
        for (uint m = 0; m < (uint)M; ++m) {
          const float xv = xv4[m][q];
          if (q & 1u) { gAcc2[m] = metal::fma(gv, xv, gAcc2[m]); uAcc2[m] = metal::fma(uv, xv, uAcc2[m]); }
          else { gAcc[m] = metal::fma(gv, xv, gAcc[m]); uAcc[m] = metal::fma(uv, xv, uAcc[m]); }
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float gate = metal::simd_sum(gAcc[m] + gAcc2[m]);
    const float up = metal::simd_sum(uAcc[m] + uAcc2[m]);
    if (lane == 0u) {
      const T gateT = T(gate);
      const T upT = T(up);
      if ((TAIL) == 1) {
        const T sigY = 1 / (1 + metal::exp(metal::abs(gateT)));
        const T sigmoidT = (gateT < 0) ? sigY : 1 - sigY;
        const T siluT = gateT * sigmoidT;
        mid[(ulong)m * (ulong)R + row] = siluT * upT;
      } else {
        const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
        const T siluT = T(float(gateT) * float(sigmoidT));
        mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
      }
    }
  }
`;
