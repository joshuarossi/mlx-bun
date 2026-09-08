// Packed Trellis prefill with MLX 0.32.2 GemvWide arithmetic.
// Ported from ml-explore/mlx v0.32.2, mlx/backend/metal/kernels/gemv.h
// (MIT). Decode weights to bf16 inside the native dot/unroll/shuffle order;
// share each decoded row across every input vector in this narrow regime.
import { MetalKernel } from "../mlx/metal-kernel";
import { type MlxArray } from "../mlx/array";
import { Dtype, deviceArchitecture } from "../mlx/ffi";
import { type TrellisGeometry } from "./trellis-linear";

/** Matches the bundled runtime's native reduction on M3 and newer GPUs. */
export function nativeTrellisWidePrefill(m: number): boolean {
  return m >= 5 && m <= 15 &&
    Number(/^applegpu_[a-z](\d{2})/.exec(deviceArchitecture())?.[1] ?? 0) >= 15;
}

export function wideTrellisPrefillEligible(g: TrellisGeometry, m: number, dtype: Dtype): boolean {
  return dtype === Dtype.bfloat16 && nativeTrellisWidePrefill(m) &&
    g.axis === 1 && g.T === 256 && g.L === 12 && [2, 3, 4].includes(g.k) &&
    g.inFeatures === 5120 && g.outFeatures === 17408 && !g.blockInterleave;
}

let kernel: MetalKernel | undefined;
function wideKernel() {
  return kernel ??= new MetalKernel({ name: 'mlx_bun_trellis_wide_prefill',
    inputNames: ['x', 'codes', 'scales'], outputNames: ['out'], source: String.raw`
    constexpr uint unroll=8, rows_per_simd=32/KL, simdgroups=KL/8;
    const uint lane=thread_index_in_simdgroup, sg=simdgroup_index_in_threadgroup;
    const uint kl=lane%KL, row=threadgroup_position_in_grid.y*4+sg*rows_per_simd+lane/KL;
    const uint vec0=threadgroup_position_in_grid.x*SM;
    constexpr uint wpb=BT*BITS/32, row_words=KC*BITS/32;
    const float scale=float(scales[row]);
    constexpr uint n_v4=KC/4, n_main=n_v4-n_v4%(KL*unroll);
    float result[SM]={0};
    for(uint base=0;base<n_main;base+=KL*unroll) {
      float4 wf[unroll];
      #pragma clang loop unroll(full)
      for(uint i=0;i<unroll;i++) {
        #pragma clang loop unroll(full)
        for(uint c=0;c<4;c++) {
          const uint k=(base+i*KL+kl)*4+c, block=k/BT, t=k%BT;
          const device uint* bw=codes+(ulong)row*row_words+block*wpb;
          const uint pos=(BT-1-t)*BITS, wi=pos>>5, off=pos&31u;
          uint win=bw[wi]>>off;
          if(off+L>32)win|=bw[wi+1==wpb?0:wi+1]<<(32-off);
          win&=(1u<<L)-1;
          const uint z=win*34038481u+76625530u;
          const uint p=(z&0x00FF00FFu)+((z>>8)&0x00FF00FFu);
          const int code=int((p&0xFFFFu)+(p>>16))-510;
          const float reciprocal=1.0f/147.800537109375f;
          const float approx=float(code)*reciprocal;
          const float residual=metal::fma(-approx,147.800537109375f,float(code));
          const float value=metal::fma(residual,reciprocal,approx);
          wf[i][c]=float(T(value*scale));
        }
      }
      #pragma clang loop unroll(full)
      for(uint v=0;v<SM;v++) {
        const uint m=min(vec0+v,uint(M-1));
        float acc=0;
        #pragma clang loop unroll(full)
        for(uint i=0;i<unroll;i++) {
          const ulong offset=(ulong)m*KC+(base+i*KL+kl)*4;
          const float4 xv=float4(float(x[offset]),float(x[offset+1]),float(x[offset+2]),float(x[offset+3]));
          acc+=metal::dot(wf[i],xv);
        }
        result[v]+=acc;
      }
    }
    #pragma clang loop unroll(full)
    for(uint v=0;v<SM;v++) {
      #pragma clang loop unroll(full)
      for(ushort off=KL/2;off>=1;off>>=1) result[v]+=simd_shuffle_down(result[v],off);
      if(kl==0 && vec0+v<M) out[(ulong)(vec0+v)*N+row]=T(result[v]);
    }
  ` });
}
/** Requires the caller to prove aligned, row-contiguous x, as Qwen does
 * with its RMSNorm output. Preserve native fallback when that proof is absent. */
export function wideTrellisPrefill(x: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry): MlxArray {
  const [m, k] = x.shape;
  if (x.ndim !== 2 || x.dtype !== Dtype.bfloat16 || !m || m < 5 || m > 15 ||
      k !== 5120 || g.inFeatures !== k || g.axis !== 1 || g.T !== 256 || g.L !== 12 ||
      ![2, 3, 4].includes(g.k) || g.blockInterleave || g.rows < 4 || g.rows % 4 ||
      g.outFeatures !== g.rows || g.cols !== k || codes.dtype !== Dtype.uint32 ||
      codes.ndim !== 2 || codes.shape[0] !== g.rows || codes.shape[1] !== k * g.k / 32 || scales.size !== g.rows)
    throw new Error("unsupported wide trellis prefill geometry, dtype or layout");
  const kl = m <= 5 ? 32 : 16;
  return wideKernel().apply([x, codes, scales], {
    outputs: [{ shape: [m, g.outFeatures], dtype: x.dtype }],
    grid: [32, g.outFeatures / 4 * (kl / 8), 1], threadGroup: [32, kl / 8, 1],
    templateDtypes: { T: x.dtype },
    templateInts: { M: m, SM: m, KL: kl, KC: k, N: g.outFeatures, BT: g.T, L: g.L, BITS: g.k },
  })[0]!;
}
