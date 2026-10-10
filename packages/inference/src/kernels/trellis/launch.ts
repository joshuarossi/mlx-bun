/** Default Trellis matvec launch: four SIMD groups of 32 lanes per threadgroup,
 * one output row per SIMD group. Qualified codebook decode uses wider groups. */
export const TRELLIS_THREADS = 128;
export const TRELLIS_SG_PER_TG = 4;
/** Amortize the 16 KiB codebook over sixteen rows in the qualified M1 decode. */
export const TRELLIS_CODEBOOK_THREADS = 512;
export const TRELLIS_CODEBOOK_SG_PER_TG = 16;
