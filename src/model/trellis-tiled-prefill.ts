// Packed axis-1 trellis prefill without a full expanded weight allocation.
// SIMD-group fragment layout follows MLX steel/gemm/mma.h (MIT, Apple Inc.):
// https://github.com/ml-explore/mlx/blob/v0.31.2/mlx/backend/metal/kernels/steel/gemm/mma.h
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import type { TrellisGeometry } from "./trellis-linear";
import { nativeTrellisWidePrefill } from "./trellis-wide-prefill";

/** Dispatch profile measured on Qwen's MLP geometry. No model-name check. */
export function tiledTrellisPrefillEligible(g: TrellisGeometry, m: number, dtype: Dtype): boolean {
  return dtype === Dtype.bfloat16 && m >= 5 && m <= 32 && !nativeTrellisWidePrefill(m) &&
    g.axis === 1 && g.T === 256 && g.L === 12 && [2, 3, 4].includes(g.k) &&
    g.inFeatures === 5120 && g.outFeatures === 17408;
}

let kernel: MetalKernel | undefined;
function tiledKernel(): MetalKernel {
  return kernel ??= new MetalKernel({ name: "mlx_bun_trellis_prefill_tile",
    inputNames: ["x", "codes", "scales"], outputNames: ["out"],
    header: "#include <metal_simdgroup_matrix>\n",
    source: String.raw`
    const uint tid=thread_position_in_threadgroup.x;
    const uint lane=thread_index_in_simdgroup;
    const uint sg=simdgroup_index_in_threadgroup;
    const uint mbase=threadgroup_position_in_grid.y*BM;
    const uint nbase=threadgroup_position_in_grid.x*BN;
    const uint fm=((lane/4)&4)+((lane/2)%4);
    const uint fn=((lane/4)&2)*2+(lane%2)*2;
    // An eight-row tile assigns all four SIMD groups to output columns.
    // Each output keeps the same 8x8 products and K accumulation order.
    constexpr int WM=BM==8?1:2, WN=4/WM, SM=WM*8, SN=WN*8;
    const uint sm=(sg/WN)*8+fm, sn=(sg%WN)*8+fn;
    constexpr int TM=BM/SM, TN=BN/SN;
    threadgroup T As[BM*BK];
    threadgroup T Bs[BK*BN];
    metal::simdgroup_float8x8 acc[TM][TN];
    #pragma clang loop unroll(full)
    for(uint i=0;i<TM;i++) {
      #pragma clang loop unroll(full)
      for(uint j=0;j<TN;j++) {
        acc[i][j].thread_elements()[0]=0.0f;
        acc[i][j].thread_elements()[1]=0.0f;
      }
    }
    constexpr uint wpb=BT*BITS/32;
    for(uint kb=0;kb<KC;kb+=BK) {
      for(uint a=tid;a<BM*BK;a+=128) {
        const uint m=mbase+a/BK, k=kb+a%BK;
        As[a]=(m<M && k<KC)?x[(ulong)m*KC+k]:T(0);
      }
      for(uint b=tid;b<BK*BN;b+=128) {
        const uint k=kb+b/BN, n=nbase+b%BN;
        T w=T(0);
        if(k<KC && n<N) {
          const uint row=AXIS==1?n:k;
          const uint col=AXIS==1?k:n;
          const uint block=col/BT, t=col%BT;
          const device uint* bw=codes+(ulong)row*(C/BT)*wpb+block*wpb;
          const uint pos=(BT-1-t)*BITS, wi=pos>>5, off=pos&31u;
          uint win=bw[wi]>>off;
          if(off+L>32)win|=bw[wi+1==wpb?0:wi+1]<<(32-off);
          win&=(1u<<L)-1;
          const uint z=win*34038481u+76625530u;
          const uint p=(z&0x00FF00FFu)+((z>>8)&0x00FF00FFu);
          const int code=int((p&0xFFFFu)+(p>>16))-510;
          // Expansion consumes the precise host LUT even for variant 6.
          // Refine the reciprocal product before scaling and bf16 rounding.
          const float reciprocal=1.0f/147.800537109375f;
          const float approx=float(code)*reciprocal;
          const float residual=metal::fma(-approx,147.800537109375f,float(code));
          const float value=metal::fma(residual,reciprocal,approx);
          w=T(value*float(scales[row]));
        }
        Bs[b]=w;
      }
      threadgroup_barrier(metal::mem_flags::mem_threadgroup);
      #pragma clang loop unroll(full)
      for(uint kk=0;kk<BK;kk+=8) {
        metal::simdgroup_float8x8 a[TM],b[TN];
        #pragma clang loop unroll(full)
        for(uint i=0;i<TM;i++) {
          a[i].thread_elements()[0]=float(As[(sm+i*SM)*BK+kk+fn]);
          a[i].thread_elements()[1]=float(As[(sm+i*SM)*BK+kk+fn+1]);
        }
        #pragma clang loop unroll(full)
        for(uint j=0;j<TN;j++) {
          b[j].thread_elements()[0]=float(Bs[(kk+fm)*BN+sn+j*SN]);
          b[j].thread_elements()[1]=float(Bs[(kk+fm)*BN+sn+j*SN+1]);
        }
        #pragma clang loop unroll(full)
        for(uint i=0;i<TM;i++) {
          #pragma clang loop unroll(full)
          for(uint j=0;j<TN;j++) {
            const uint nj=(i%2)?TN-1-j:j;
            metal::simdgroup_multiply_accumulate(acc[i][nj],a[i],b[nj],acc[i][nj]);
          }
        }
      }
      threadgroup_barrier(metal::mem_flags::mem_threadgroup);
    }
    #pragma clang loop unroll(full)
    for(uint i=0;i<TM;i++) {
      #pragma clang loop unroll(full)
      for(uint j=0;j<TN;j++) {
        const uint m=mbase+sm+i*SM,n=nbase+sn+j*SN;
        if(m<M && n<N)out[(ulong)m*N+n]=T(acc[i][j].thread_elements()[0]);
        if(m<M && n+1<N)out[(ulong)m*N+n+1]=T(acc[i][j].thread_elements()[1]);
      }
    }
  ` });
}

/** Shared operation for bf16 [M, K], axis-1 1MAD, T=256/L=12, k=2/3/4.
 * M=5..32. Borrow inputs and return owned [M, N]; caller controls evaluation.
 * Reconstruct the precise LUT value before bf16 weight rounding. The default
 * packed matvec's unrefined f32 code value is a different numerical contract.
 * Other geometries need a measured dispatch profile and model-level gates. */
export function tiledTrellisPrefill(
  x: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry,
): MlxArray {
  const [m, k] = x.shape;
  if (x.ndim !== 2 || x.dtype !== Dtype.bfloat16 || !m || m < 5 || m > 32 ||
      k !== g.inFeatures || g.axis !== 1 || g.T !== 256 || g.L !== 12 ||
      ![2, 3, 4].includes(g.k) || g.cols % 256 !== 0 || g.rows < 1)
    throw new Error("unsupported tiled trellis prefill geometry or dtype");
  const bm = m <= 8 ? 8 : m <= 16 ? 16 : 32, bn = 64, bk = 16;
  const [out] = tiledKernel().apply([x, codes, scales], {
    outputs: [{ shape: [m, g.outFeatures], dtype: x.dtype }],
    grid: [Math.ceil(g.outFeatures / bn) * 128, Math.ceil(m / bm), 1],
    threadGroup: [128, 1, 1], templateDtypes: { T: x.dtype },
    templateInts: { M: m, N: g.outFeatures, KC: g.inFeatures, C: g.cols,
      BITS: g.k, L: g.L, BT: g.T, AXIS: g.axis, BM: bm, BN: bn, BK: bk },
  });
  return out!;
}
