// Experimental small-M trellis kernels (variant 7).
// Decode each weight once per SIMD group and reuse it across M input vectors.
// Callers restrict M to 2..4 and pass variant 6's decoder/rounding constants.
// Each vector keeps the original two-accumulator FMA order and simd_sum;
// fused gate/up also keeps the original bf16 activation rounding boundaries.
// Baseline implementation and the shared 1MAD header: trellis-linear.ts.
// Full-model paired performance and quality gates are required before a default.

export const REDUCE_SHARED_M_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = 0u;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const device uint32_t* codeRow = codes + (ulong)row * (ulong)((C / BT) * wpb);
  const float scale = float(scales[row]);
  float acc[M], acc2[M];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) { acc[m] = 0.0f; acc2[m] = 0.0f; }
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
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      float4 xv[M];
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m)
        xv[m] = float4(((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + c0))[j4]);
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
        #pragma clang loop unroll(full)
        for (uint m = 0; m < (uint)M; ++m) {
          if (q & 1u) acc2[m] = metal::fma(wv, xv[m][q], acc2[m]);
          else acc[m] = metal::fma(wv, xv[m][q], acc[m]);
        }
      }
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const float v = metal::simd_sum(acc[m] + acc2[m]);
    if (lane == 0u) out[(ulong)m * (ulong)R + row] = T(v);
  }
`;

export const GATEUP_SHARED_M_SOURCE = String.raw`
  threadgroup float lutTG[4096];
  if ((VARIANT) == 2) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 128u) lutTG[i] = lut[i];
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = 0u;
  if (row >= (uint)R || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const uint runsPerBlock = (uint)BT / 32u;
  const uint nRuns = (uint)C / 32u;
  const ulong rowWords = (ulong)((C / BT) * wpb);
  const device uint32_t* gRow = gcodes + (ulong)row * rowWords;
  const device uint32_t* uRow = ucodes + (ulong)row * rowWords;
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
    #pragma clang loop unroll(full)
    for (uint j4 = 0; j4 < 8u; ++j4) {
      float4 xv4[M];
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m)
        xv4[m] = float4(((const device metal::vec<T, 4>*)(x + (ulong)m * (ulong)C + c0))[j4]);
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
      const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
      const T siluT = T(float(gateT) * float(sigmoidT));
      mid[(ulong)m * (ulong)R + row] = T(float(siluT) * float(upT));
    }
  }
`;
