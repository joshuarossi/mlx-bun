// Experimental variant 8, k=3 / T=256 / L<=12 only.
// The word-per-lane kernel uses 24 of 32 SIMD lanes for a 3-bit block.
// Assign eight outputs to every lane, load adjacent packed words, and align
// them once so each unrolled decoder has constant shifts. Row accumulation,
// split boundaries and the separate partial reduction stay identical to v6.
export const BALANCED_SCATTER_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint block = thread_position_in_grid.y * (uint)SG_TG + sg;
  const uint nBlocks = (uint)C / (uint)BT;
  const uint zi = thread_position_in_grid.z;
  const uint sample = zi / (uint)SPLITS;
  const uint split = zi - sample * (uint)SPLITS;
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
  const device T* xs = x + (ulong)sample * (ulong)R;
  float acc[8];
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i) acc[i] = 0.0f;
  for (uint r = r0; r < r1; ++r) {
    const uint word = words[(ulong)r * rowWords + wi];
    const uint nxt = words[(ulong)r * rowWords + next];
    const uint lo = off == 0u ? word : (word >> off) | (nxt << (32u - off));
    const uint hi = off == 0u ? nxt : nxt >> off;
    const float xr = float(xs[r]);
    const float sr = float(scales[r]);
    #pragma clang loop unroll(full)
    for (uint i = 0; i < 8u; ++i) {
      const uint shift = i * (uint)K;
      uint win = lo >> shift;
      if (shift + (uint)L > 32u) win |= hi << (32u - shift);
      win &= (1u << (uint)L) - 1u;
      const float value = (float)trellis_y(win) * (1.0f / 147.800537109375f);
      acc[i] = metal::fma(value * sr, xr, acc[i]);
    }
  }
  const ulong outBase = ((ulong)sample * (ulong)SPLITS + split) * (ulong)C;
  #pragma clang loop unroll(full)
  for (uint i = 0; i < 8u; ++i)
    partial[outBase + block * (uint)BT + (uint)BT - 1u - lane * 8u - i] = acc[i];
`;
