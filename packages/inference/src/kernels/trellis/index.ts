// Packed Trellis projection kernels (QTIP 1MAD code) and the decode-variant
// semantics the layer (layers/trellis-linear.ts) selects between.
//
// Format: `.weight` = uint32 bitstream, `.scales` = fp16 [rows], config entry
// `{mode:"trellis", bits:k, group_size:T, trellis:{L, code:"1mad", axis}}`.
// axis=1 (gate/up) is coded along the INPUT dim, stored [out, in*k/32]; axis=0
// (down) is coded along the OUTPUT dim, stored [in, out*k/32] (the stored matrix
// is W^T, coded along its last axis). The k3/axis0 layout [cols/512, rows, 48]
// interleaves two coded blocks across rows (`blockInterleave`); the tensor
// shape identifies it and no second code copy is kept.
//
// One decode primitive: state_t is the L-bit window at bit offset (T-1-t)*k of
// the block (wrapping), so any weight decodes in O(1) with the 1MAD code
// computed inline (codebook.ts HEADER), no LUT and no threadgroup memory.
//   - reduce   (M <= 4, axis=1): one SIMD group per output row; each lane owns
//               runs of 32 consecutive positions held in K+1 registers (every
//               window shift a compile-time constant); simd_sum.
//   - scatter  (M <= 4, axis=0): lane-per-WORD of a block, running sums per
//               position in the word, split-K over input rows (partials folded
//               by one mlx sum).
//   - expand   (M > 4 fallback): decode the whole tensor to bf16, then a stock
//               matmul; the transient is one tensor.
//   - gate-up / mixed-gate-up: fused gate+up+SwiGLU for M <= 4 rows. The mixed
//               kernel serves layers whose gate and up bit widths differ (one
//               word layout and bit offset each); TAIL "split" reproduces MLX's
//               compiled swiglu over two bf16 projections bit for bit (no output
//               changes vs the two-kernel path), "fused" the float32 sigmoid of
//               the same-width kernel.
//
// Decode VARIANT (`MLX_BUN_TRELLIS_VARIANT`, default 13; `setTrellisVariant`
// overrides for benches and self-flag KL gates). 0-6 select the decode
// arithmetic (see HEADER in codebook.ts): 0-3 reconstruct bf16(lut[state]*scale);
// 6 is f32 code*scale in the packed kernels (expansion still stores bf16).
// Variants 7-13 keep variant 6's decoded values (`decoderVariant`) and add
// kernel selection, each including the ones below it:
//    7  weight decoding shared across M=2..4 in reduce and gate-up
//    8  balanced 3-bit scatter (k=3, T=256, L<=12)
//    9  same kernels as 8; it once also deferred prefill projection evaluation
//       to the Qwen layer barrier, which no longer exists
//   10  shared-M scatter across M=2..4
//   11  tiled axis-1 prefill at M=5..32 on the measured MLP shape; wide prefill
//       when the input is proven row-contiguous
//   12  tiled axis-0 prefill at M=5..8 with MLX's split-K reduction
//   13  shared packed-word loads in the remaining bf16 expansion (vector
//       expand), and the shared scatter codebook for M=3..4 bf16 on the
//       interleaved k3 layout
//
// Factored-scale kernels: weights contribute their code value y and the scale
// (with 1/147.8) applies once per output (gate/up) or per input row (down);
// one kernel per row form and code layout:
//   - gate-up-factored: same-width gate/up, one row / 2..4 shared rows
//   - mixed-gate-up-factored: different-width gate/up, 1..4 rows
//   - down-factored: row-major axis-0 codes, one row / 2..4 rows
//   - down-k3-interleaved-factored: 3-bit block-interleaved axis-0 codes
//   - gate-up-mma / down-mma: 1..8 rows on the simdgroup matrix unit
//
// `MLX_BUN_TRELLIS=expand` decodes every trellis tensor at LOAD into 8-bit g64
// affine (the eval-carrier numerics, about -45 dB) and serves it through the
// stock QuantizedLinear: the fallback when the kernels lose on a machine.
export type { TrellisGeometry, TrellisWeights } from "./geometry";
export { vectorTrellisExpand, vectorTrellisExpandEligible } from "./vector-expand";
export { expandTrellis } from "./expand";
export { trellisReduce, TRELLIS_MATVEC_MAX_M } from "./reduce";
export { trellisScatter } from "./scatter";
export { fusedGateUpSwiglu } from "./gate-up";
export { fusedGateUpSwigluMixed, type MixedGateUpTail } from "./mixed-gate-up";
export { tiledTrellisPrefill, tiledTrellisPrefillEligible } from "./tiled-prefill";
export { splitKTrellisPrefill, splitKTrellisPrefillEligible } from "./splitk-prefill";
export { wideTrellisPrefill, wideTrellisPrefillEligible, nativeTrellisWidePrefill } from "./wide-prefill";
export { lut1mad, wordsPerBlock } from "./codebook";
export { gateUpFactoredRow, gateUpFactoredRows } from "./gate-up-factored";
export { mixedGateUpFactoredRows } from "./mixed-gate-up-factored";
export { downFactoredRow, downFactoredRows } from "./down-factored";
export { downK3InterleavedFactoredRow, downK3InterleavedFactoredRows } from "./down-k3-interleaved-factored";
export { gateUpMma } from "./gate-up-mma";
export { downMma, downK3InterleavedMma } from "./down-mma";
