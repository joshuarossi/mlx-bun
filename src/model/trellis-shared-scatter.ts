// Experimental variant 10: reuse each decoded scatter weight across M=2..4.
// Both kernels retain each output's ordered row accumulation, split boundaries
// and the caller's partial reduction/cast. M=1 keeps the incumbent kernel.
// The balanced path requires k=3 / T=256 / L<=12; the generic path preserves
// the existing packed-word lane mapping for other supported geometries.

export const SCATTER_SHARED_M_SOURCE = String.raw`
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
  const uint sample = 0u;
  const uint split = zi;
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
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);

  const device uint32_t* col0 = codes + (INTERLEAVE
    ? (ulong)(blk / 2) * R * 2 * wpb + (blk % 2) * wpb : (ulong)blk * wpb) + wi;
  const uint mask = (1u << (uint)L) - 1u;
  float acc[M][NP];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = active ? col0[(ulong)r * rowWords] : 0u;
    const uint nxt = metal::simd_shuffle(word, (ushort)nbrLane);
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i) {
      uint win = word >> offs[i];
      if (spill[i]) win |= nxt << (32u - offs[i]);
      win &= mask;
      const float weight = TRELLIS_ROUND(TRELLIS_DECODE(win, lutTG, lut) * sr);
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < (uint)NP; ++i)
      if (valid[i]) partial[outBase + cols[i]] = acc[m][i];
  }
`;

export const BALANCED_SCATTER_SHARED_M_SOURCE = String.raw`
  // Model-owned tuning selects this table for measured small-M shapes.
  // Store integers so the reciprocal multiply retains its original rounding.
  threadgroup short codebookY[CODEBOOK ? 4096 : 1];
  if (CODEBOOK) {
    for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += threads_per_threadgroup.x)
      codebookY[i] = (short)trellis_y(i);
    threadgroup_barrier(metal::mem_flags::mem_threadgroup);
  }
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = 0u;
  const uint split = zi;
  if (block >= nBlocks || sample >= (uint)M) return;
  const uint wpb = (uint)(BT * K / 32);
  const ulong rowWords = (ulong)(INTERLEAVE ? 2 : nBlocks) * wpb;
  const uint pBase = lane * 8u * (uint)K;
  const uint wi = pBase >> 5u;
  const uint off = pBase & 31u;
  const uint next = (wi + 1u == wpb) ? 0u : wi + 1u;
  const device uint32_t* words = codes + (INTERLEAVE
    ? (ulong)(block / 2) * R * 2 * wpb + (block % 2) * wpb : (ulong)block * wpb);
  const uint rowsPer = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;
  const uint r0 = split * rowsPer;
  const uint r1 = metal::min((uint)R, r0 + rowsPer);
  float acc[M][8];
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m)
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) acc[m][i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    float xr[M];
    #pragma clang loop unroll(full)
    for (uint m = 0; m < (uint)M; ++m) xr[m] = float(x[(ulong)m * (ulong)R + r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const float value = (CODEBOOK ? (float)codebookY[win] : (float)trellis_y(win)) * (1.0f / 147.800537109375f);
      const float weight = value * sr;
      #pragma clang loop unroll(full)
      for (uint m = 0; m < (uint)M; ++m) acc[m][i] = metal::fma(weight, xr[m], acc[m][i]);
    }
  }
  #pragma clang loop unroll(full)
  for (uint m = 0; m < (uint)M; ++m) {
    const ulong outBase = ((ulong)m * (ulong)SPLITS + split) * (ulong)C;
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i)
      partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[m][i];
  }
`;
