// Packed axis-0 prefill with in-tile weight reconstruction and float partials.
// Partitioning, SIMD fragment layout and ordered accumulation follow MLX 0.31.2
// (MIT, Apple Inc.): mlx/backend/metal/matmul.cpp and steel/gemm/kernels/
// steel_gemm_splitk.h. The shared operation preserves that reduction contract.
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import type { TrellisGeometry } from "./trellis-linear";

export function splitKTrellisPrefillEligible(g: TrellisGeometry, m: number, dtype: Dtype): boolean {
  return dtype === Dtype.bfloat16 && m >= 5 && m <= 8 &&
    g.axis === 0 && g.T === 256 && g.L === 12 && [2, 3, 4].includes(g.k) &&
    g.inFeatures === 17408 && g.outFeatures === 5120;
}

let partialKernel: MetalKernel | undefined;
let reductionKernel: MetalKernel | undefined;
function kernels(): [MetalKernel, MetalKernel] {
  partialKernel ??= new MetalKernel({ name: "mlx_bun_trellis_splitk_prefill",
    inputNames: ["x", "codes", "scales"], outputNames: ["out"],
    header: "#include <metal_simdgroup_matrix>\n", source: String.raw`
    const uint tid=thread_position_in_threadgroup.x;
    const uint lane=thread_index_in_simdgroup;
    const uint sg=simdgroup_index_in_threadgroup;
    const uint mbase=threadgroup_position_in_grid.y*BM;
    const uint nbase=threadgroup_position_in_grid.x*BN;
    const uint fm=((lane/4)&4)+((lane/2)%4);
    const uint fn=((lane/4)&2)*2+(lane%2)*2;
    // The eligible M=5..8 path needs one row of 8x8 SIMD-group tiles.
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
    const uint split=threadgroup_position_in_grid.z;
    const uint k0=split*PARTITION;
    const uint k1=split+1==SPLITS?KC:k0+PARTITION;
    for(uint kb=k0;kb<k1;kb+=BK) {
      for(uint a=tid;a<BM*BK;a+=128) {
        const uint m=mbase+a/BK, k=kb+a%BK;
        As[(a/BK)*BK+a%BK]=(m<M && k<KC)?x[(ulong)m*KC+k]:T(0);
      }
      for(uint b=tid;b<BK*BN;b+=128) {
        const uint k=kb+b/BN, n=nbase+b%BN;
        T w=T(0);
        if(k<KC && n<N) {
          const uint row=k;
          const uint col=n;
          const uint block=col/BT, t=col%BT;
          const device uint* bw=codes+(INTERLEAVE
            ? (ulong)(block/2)*KC*2*wpb+(ulong)row*2*wpb+(block%2)*wpb
            : (ulong)row*(C/BT)*wpb+block*wpb);
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
        Bs[(b/BN)*BN+b%BN]=w;
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
        if(m<M && n<N)out[(ulong)split*M*N+(ulong)m*N+n]=acc[i][j].thread_elements()[0];
        if(m<M && n+1<N)out[(ulong)split*M*N+(ulong)m*N+n+1]=acc[i][j].thread_elements()[1];
      }
    }
  ` });
  reductionKernel ??= new MetalKernel({ name: "mlx_bun_trellis_splitk_accumulate",
    inputNames: ["partials"], outputNames: ["out"], source: String.raw`
      const uint i = thread_position_in_grid.x;
      if (i >= SIZE) return;
      float total = 0.0f;
      for (uint s = 0; s < SPLITS; s++) total += partials[(ulong)s * SIZE + i];
      out[i] = T(total);
    ` });
  return [partialKernel, reductionKernel];
}

/** Borrow bf16 [M,K] and axis-0 1MAD weights; return owned lazy [M,N].
 * M=5..8, T=256/L=12, k=2/3/4. Match MLX's non-NAX split-K matrix regime;
 * other shapes and hardware require their own dispatch and full-model gates.
 * Peak workspace is SPLITS*M*N float elements, with no dense weight buffer. */
export function splitKTrellisPrefill(
  x: MlxArray, codes: MlxArray, scales: MlxArray, g: TrellisGeometry,
): MlxArray {
  const [m, k] = x.shape, n = g.outFeatures;
  if (x.ndim !== 2 || x.dtype !== Dtype.bfloat16 || !m || m < 5 || m > 8 ||
      k !== g.inFeatures || g.axis !== 0 || g.T !== 256 || g.L !== 12 ||
      ![2, 3, 4].includes(g.k) || g.cols % 256 !== 0 || n < 1 ||
      k < 128 || k < n || Math.ceil(m / 16) * Math.ceil(n / 16) > 1024)
    throw new Error("unsupported split-K trellis prefill geometry or dtype");
  const tilesM = Math.ceil(m / 32), tilesN = Math.ceil(n / 32), tilesK = Math.floor(k / 16);
  const ratio = Math.max(1, Math.floor(tilesK / (tilesM * tilesN)));
  const splits = Math.min(32, Math.max(2, 2 ** Math.ceil(Math.log2(ratio))));
  const partition = Math.floor(tilesK / splits) * 16;
  const [partial, reduce] = kernels();
  const [workspace] = partial.apply([x, codes, scales], {
    outputs: [{ shape: [splits, m, n], dtype: Dtype.float32 }],
    grid: [Math.ceil(n / 32) * 128, 1, splits], threadGroup: [128, 1, 1],
    templateDtypes: { T: x.dtype }, templateInts: { M: m, N: n, KC: k, C: g.cols,
      BITS: g.k, L: g.L, BT: g.T, BM: 8, BN: 32, BK: 16, SPLITS: splits,
      PARTITION: partition, INTERLEAVE: g.blockInterleave ?? 0 },
  });
  try {
    return reduce.apply([workspace!], {
      outputs: [{ shape: [m, n], dtype: x.dtype }],
      grid: [m * n, 1, 1], threadGroup: [256, 1, 1], templateDtypes: { T: x.dtype },
      templateInts: { SIZE: m * n, SPLITS: splits },
    })[0]!;
  } finally { workspace!.dispose(); }
}
