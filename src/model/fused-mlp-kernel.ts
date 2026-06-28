// The WHOLE MLP in ONE dispatch — down = (silu(x·Wgᵀ)·(x·Wuᵀ)) · Wdownᵀ — with no
// intermediate `hidden` ever exposed to MLX. MLX runs this one kernel; there is no
// boundary between our kernels for its planner to alias (the corruption only lives
// at those boundaries). Built from the steel building blocks in steel-qmm-header.ts,
// structured like the flash-CCE backward: each threadgroup owns one (M-block,I-block),
// computes silu·up for that I-block ONCE (no recompute), then atomic-accumulates its
// contribution to every down output — exactly how flash-CCE BWD atomic-adds dh.
//
//   grid = (TGN, I/BI, M/BM); each tg: i-block i0 = tid.y*BI, m-block m0 = tid.z*BM
//   phase A: gate/up [BM,BI] = x[BM,H] @ {Wg,Wu}[i0,H]ᵀ  (reduce H) → silu·up = Hs[BM,BI]
//   phase B: for each Ho-block no: D[BM,BN] = Hs @ Wdown[no,i0]ᵀ; atomic-add D → y[M,Ho]
//
// Per-weight quant constants (gate/up/down) are baked literals; H/I/Ho are templateInts;
// M from x_shape. Output is f32 (atomic accumulation); the caller casts to the model
// dtype at the MLP boundary. L3 (atomic-add ordering + bf16-rounded silu); gated by
// teacher-forced KL like the rest of the controlled path.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import { STEEL_QMM_HEADER } from "../train/steel-qmm-header";
import * as ops from "../mlx/ops";
import type { QuantSpec } from "../mlx/ops";

const BM = 32, BN = 32, BK = 32, WM = 2, WN = 2;
const TGN = WM * WN * 32; // 128 threads / threadgroup

const SOURCE = String.raw`
  const uint M=x_shape[0];
  constexpr int I=I_T, H=H_T, Ho=HO_T;
  constexpr int gsG=GS_G,btsG=BITS_G, gsU=GS_U,btsU=BITS_U, gsD=GS_D,btsD=BITS_D;
  constexpr int pfG=get_pack_factor<btsG,8>(), bppG=get_bytes_per_pack<btsG>();
  constexpr int pfU=get_pack_factor<btsU,8>(), bppU=get_bytes_per_pack<btsU>();
  constexpr int pfD=get_pack_factor<btsD,8>(), bppD=get_bytes_per_pack<btsD>();
  constexpr int BKp=BK_T+16/sizeof(T);
  threadgroup T Xs[BM_T*BKp];
  threadgroup T Wgs[BN_T*BKp];
  threadgroup T Wus[BN_T*BKp];
  threadgroup T Lg[BM_T*BN_T];
  threadgroup T Lu[BM_T*BN_T];
  threadgroup T Hs[BM_T*BKp];   // silu·up for this I-block, padded leading dim BKp
  threadgroup T Wds[BN_T*BKp];  // a down-weight [BN, BI] tile
  using gu_mma=mlx::steel::BlockMMA<T,T,BM_T,BN_T,BK_T,WM_T,WN_T,false,true,BKp,BKp>;
  using lx_t  =mlx::steel::BlockLoader<T,BM_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE>;
  using lwg_t =QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gsG,btsG>;
  using lwu_t =QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gsU,btsU>;
  using d_mma =mlx::steel::BlockMMA<T,T,BM_T,BN_T,BK_T,WM_T,WN_T,false,true,BKp,BKp>;
  using lwd_t =QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gsD,btsD>;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup;
  const uint lid=thread_position_in_threadgroup.x;
  const int Hh=(int)H;
  const int KwG=Hh*bppG/pfG, KgG=Hh/gsG;
  const int KwU=Hh*bppU/pfU, KgU=Hh/gsU;
  const int KwD=I*bppD/pfD,  KgD=I/gsD;          // down weight rows are length I
  const int m0=(int)threadgroup_position_in_grid.z*BM_T;
  const int i0=(int)threadgroup_position_in_grid.y*BN_T;
  const short num_els=(short)min(BM_T,(int)M-m0);

  // ---- Phase A: hidden[BM,BI] = silu(x@Wg[i0]ᵀ)·(x@Wu[i0]ᵀ), reduce over H ----
  gu_mma mg(sg,sl), mu(sg,sl);
  lx_t  lx (x  + (int64_t)m0*Hh, Hh, Xs, sg, sl);
  lwg_t lwg((const device uint8_t*)wg + (int64_t)i0*KwG, sg_w + (int64_t)i0*KgG, bg_w + (int64_t)i0*KgG, Hh, Wgs, sg, sl);
  lwu_t lwu((const device uint8_t*)wu + (int64_t)i0*KwU, su_w + (int64_t)i0*KgU, bu_w + (int64_t)i0*KgU, Hh, Wus, sg, sl);
  for (int k=0;k<Hh;k+=BK_T){
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (num_els<BM_T) lx.load_safe(short2(BK_T,num_els)); else lx.load_unsafe();
    lwg.load_unsafe(); lwu.load_unsafe();
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mg.mma(Xs,Wgs); mu.mma(Xs,Wus);
    lx.next(); lwg.next(); lwu.next();
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  mg.Ctile.template store<T,WM_T,WN_T,BN_T,1>(Lg + mg.sm*BN_T + mg.sn);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  mu.Ctile.template store<T,WM_T,WN_T,BN_T,1>(Lu + mu.sm*BN_T + mu.sn);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  // silu·up into Hs (padded BKp leading dim, so the phase-B BlockMMA can read it as A)
  for (uint idx=lid; idx<(uint)(BM_T*BN_T); idx+=TGN_T){
    int r=(int)idx/BN_T, c=(int)idx%BN_T;
    T gT=Lg[idx], uT=Lu[idx];
    T sigT=(T)(1.0f/(1.0f+metal::precise::exp(-(float)gT)));
    T siluT=(T)((float)gT*(float)sigT);
    Hs[r*BKp + c] = (T)((float)siluT*(float)uT);
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);

  // ---- Phase B: for each Ho-block, D[BM,BN] = Hs @ Wdown[no,i0]ᵀ; atomic-add → y ----
  for (int no=0; no<Ho; no+=BN_T){
    lwd_t lwd((const device uint8_t*)wd + (int64_t)no*KwD + (int64_t)i0*bppD/pfD,
              sd_w + (int64_t)no*KgD + i0/gsD, bd_w + (int64_t)no*KgD + i0/gsD, I, Wds, sg, sl);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    lwd.load_unsafe();               // one BI-wide tile (BI==BK, single step)
    threadgroup_barrier(mem_flags::mem_threadgroup);
    d_mma D(sg,sl);
    D.mma(Hs, Wds);                  // D[BM,BN] = Hs[BM,BI] @ Wds[BN,BI]ᵀ
    threadgroup_barrier(mem_flags::mem_threadgroup);
    D.Ctile.template store<T,WM_T,WN_T,BN_T,1>(Lg + D.sm*BN_T + D.sn); // reuse Lg to stage D
    threadgroup_barrier(mem_flags::mem_threadgroup);
    for (uint idx=lid; idx<(uint)(BM_T*BN_T); idx+=TGN_T){
      int r=(int)idx/BN_T, c=(int)idx%BN_T;
      if (m0+r<(int)M){
        const int64_t off=(int64_t)(m0+r)*(int64_t)Ho + (no+c);
        // Absorb the residual: add h exactly once (only the i0==0 threadgroups,
        // which cover every (m,ho) once) so the kernel outputs h + mlp(x) and
        // nothing is left live across it for MLX to plan a buffer around.
        float add = (float)Lg[idx];
        if (i0==0) add += (float)h[off];
        atomic_fetch_add_explicit(&y[off], add, memory_order_relaxed);
      }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
`;

const _kernels = new Map<string, MetalKernel>();
function getKernel(
  gsG: number, btsG: number, gsU: number, btsU: number, gsD: number, btsD: number,
): MetalKernel {
  const key = `${gsG}:${btsG}:${gsU}:${btsU}:${gsD}:${btsD}`;
  let k = _kernels.get(key);
  if (!k) {
    k = new MetalKernel({
      name: "mlx_bun_fused_mlp",
      inputNames: ["x", "wg", "sg_w", "bg_w", "wu", "su_w", "bu_w", "wd", "sd_w", "bd_w", "h"],
      outputNames: ["y"],
      source: SOURCE,
      header:
        `${STEEL_QMM_HEADER}\n` +
        `#define GS_G ${gsG}\n#define BITS_G ${btsG}\n#define GS_U ${gsU}\n#define BITS_U ${btsU}\n` +
        `#define GS_D ${gsD}\n#define BITS_D ${btsD}\n` +
        `#define BM_T ${BM}\n#define BN_T ${BN}\n#define BK_T ${BK}\n` +
        `#define WM_T ${WM}\n#define WN_T ${WN}\n#define TGN_T ${TGN}\n`,
      ensureRowContiguous: true,
      atomicOutputs: true,
    });
    _kernels.set(key, k);
  }
  return k;
}

/** The whole MLP, fused, as one dispatch. x is [M, H] (bf16/f16). Returns the MLP
 *  output [M, Ho] in x.dtype (cast from the f32 atomic accumulator). gate/up have
 *  shape [I, H*bits/32]; down has [Ho, I*bits/32]. Caller owns the result. */
export function fusedMlp(
  x: MlxArray,
  wg: MlxArray, sg: MlxArray, bg: MlxArray, gateSpec: QuantSpec,
  wu: MlxArray, su: MlxArray, bu: MlxArray, upSpec: QuantSpec,
  wd: MlxArray, sd: MlxArray, bd: MlxArray, downSpec: QuantSpec,
  h: MlxArray,  // the residual (layer input) — absorbed: output = h + mlp(x)
): MlxArray {
  const M = x.shape[0]!, I = wg.shape[0]!, H = x.shape[1]!, Ho = wd.shape[0]!;
  const [yF] = getKernel(
    gateSpec.groupSize, gateSpec.bits, upSpec.groupSize, upSpec.bits, downSpec.groupSize, downSpec.bits,
  ).apply([x, wg, sg, bg, wu, su, bu, wd, sd, bd, h], {
    // f32 atomic accumulator, zero-initialised; grid tiles (M, I) — every I-block
    // contributes to the output via atomic-add.
    outputShapeFn: (ins) => [{ shape: [ins[0]!.shape[0]!, Ho], dtype: Dtype.float32 }],
    grid: (ins) => [TGN, Math.ceil(I / BN), Math.ceil(ins[0]!.shape[0]! / BM)],
    threadGroup: [TGN, 1, 1],
    templateInts: { I_T: I, H_T: H, HO_T: Ho },
    templateDtypes: { T: x.dtype },
    initValue: 0,
  });
  void M;
  if (yF!.dtype === x.dtype) return yF!;
  const y = yF!.astype(x.dtype);
  yF!.dispose();
  return y;
}
