/** Launch shape shared by every Trellis matvec-family kernel: four SIMD groups
 * of 32 lanes per threadgroup, one output row per SIMD group. */
export const TRELLIS_THREADS = 128;
export const TRELLIS_SG_PER_TG = 4;
