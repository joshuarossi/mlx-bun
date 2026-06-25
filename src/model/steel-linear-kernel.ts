// Plain quantized linear y = x @ Wᵀ as OUR dispatch, composed from the steel
// building blocks already in src/train/steel-qmm-header.ts (BlockMMA + Block/
// QuantizedBlockLoader — MLX's verbatim GEMM, the same code qmm_t_impl wraps).
// This is the projection primitive for the controlled forward (q/k/v/o/down):
// we own the dispatch and the eval boundary instead of emitting an ops.* node
// into MLX's lazy graph. N (out) and H (in/K) are baked as template literals;
// M comes from the x_shape helper. Output bit-matches the BlockMMA store epilogue
// (TransformNone → cast to T), the same store qmm_t_impl uses.

import { MlxArray } from "../mlx/array";
import { MetalKernel } from "../mlx/metal-kernel";
import { STEEL_QMM_HEADER } from "../train/steel-qmm-header";
import * as ops from "../mlx/ops";
import type { QuantSpec } from "../mlx/ops";

const BM = 32, BN = 32, BK = 32, WM = 2, WN = 2;
const TGN = WM * WN * 32;

// One BM×BN output tile per threadgroup (grid.y = N-tiles, grid.z = M-tiles), the
// K=H reduction looped inside — the qmm_t_impl body, dims via templateInts.
const SOURCE = String.raw`
  const uint M=x_shape[0]; constexpr int N=N_T, H=H_T;
  constexpr int gs=GS_T, bts=BITS_T;
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>();
  constexpr int BKp=BK_T+16/sizeof(T);
  threadgroup T Xs[BM_T*BKp];
  threadgroup T Ws[BN_T*BKp];
  using mma_t=mlx::steel::BlockMMA<T,T,BM_T,BN_T,BK_T,WM_T,WN_T,false,true,BKp,BKp>;
  using lx_t=mlx::steel::BlockLoader<T,BM_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gs,bts>;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup;
  const int Hh=(int)H, K_w=Hh*bpp/pf, K_g=Hh/gs;
  const int m0=(int)threadgroup_position_in_grid.z*BM_T;
  const int n0=(int)threadgroup_position_in_grid.y*BN_T;
  const short num_els=(short)min(BM_T,(int)M-m0);
  const short num_outs=(short)min(BN_T,(int)N-n0);

  mma_t mma_op(sg,sl);
  lx_t  lx(x + (int64_t)m0*Hh, Hh, Xs, sg, sl);
  lw_t  lw((const device uint8_t*)w + (int64_t)n0*K_w, scales + (int64_t)n0*K_g, biases + (int64_t)n0*K_g, Hh, Ws, sg, sl);

  for (int k=0; k<Hh; k+=BK_T){
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (num_els<BM_T) lx.load_safe(short2(BK_T,num_els)); else lx.load_unsafe();
    if (num_outs<BN_T) lw.load_safe(short2(BK_T,num_outs)); else lw.load_unsafe();
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mma_op.mma(Xs,Ws);
    lx.next(); lw.next();
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  // Store straight to device y[m0.., n0..] via the BlockMMA epilogue (float accum
  // → T, the SAME rounding MLX's quantized_matmul applies).
  device T* yp = y + (int64_t)m0*(int64_t)N + n0;
  if (num_els<BM_T || num_outs<BN_T) mma_op.store_result_safe(yp, N, short2(num_outs,num_els));
  else mma_op.store_result(yp, N);
`;

const _kernels = new Map<string, MetalKernel>();
function getKernel(gs: number, bits: number): MetalKernel {
  const key = `${gs}:${bits}`;
  let k = _kernels.get(key);
  if (!k) {
    k = new MetalKernel({
      name: "mlx_bun_steel_linear",
      inputNames: ["x", "w", "scales", "biases"],
      outputNames: ["y"],
      source: SOURCE,
      header:
        `${STEEL_QMM_HEADER}\n` +
        `#define GS_T ${gs}\n#define BITS_T ${bits}\n` +
        `#define BM_T ${BM}\n#define BN_T ${BN}\n#define BK_T ${BK}\n` +
        `#define WM_T ${WM}\n#define WN_T ${WN}\n#define TGN_T ${TGN}\n`,
      ensureRowContiguous: true,
    });
    _kernels.set(key, k);
  }
  return k;
}

/** y = x @ Wᵀ, quantized, as our own dispatch. `x` is [M, H] (bf16/f16); `w` is
 *  the packed weight [N, H*bits/32] with per-group scales/biases [N, H/groupSize].
 *  Returns [M, N] in x.dtype. H % BK == 0 and groupSize % BK == 0 required. */
export function steelLinear(
  x: MlxArray, w: MlxArray, scales: MlxArray, biases: MlxArray, spec: QuantSpec,
): MlxArray {
  const M = x.shape[0]!, H = x.shape[1]!, N = w.shape[0]!;
  const [y] = getKernel(spec.groupSize, spec.bits).apply([x, w, scales, biases], {
    outputShapeFn: (ins) => [{ shape: [ins[0]!.shape[0]!, N], dtype: x.dtype }],
    grid: (ins) => [TGN, Math.ceil(N / BN), Math.ceil(ins[0]!.shape[0]! / BM)],
    threadGroup: [TGN, 1, 1],
    templateInts: { N_T: N, H_T: H },
    templateDtypes: { T: x.dtype },
  });
  void M;
  return y!;
}
