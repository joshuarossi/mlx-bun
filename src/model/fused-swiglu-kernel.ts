// Fused SwiGLU MLP expansion kernel (cpm5-generate-and-fuse-inference): compute
//   hidden = silu(gate_proj(x)) · up_proj(x)
// in ONE Metal dispatch, reusing MLX's verbatim steel quantized BlockMMA GEMM
// (src/train/steel-qmm-header.ts — the same building block the ORPO flash-CCE
// head uses). Replaces the spelled-out path's two quantized_matmul dispatches +
// the gate/up/silu/product global-memory materialization (minicpm5.ts LlamaMLP):
//   gate = qmm(x, Wg);  up = qmm(x, Wu);  silu = gate·σ(gate);  hidden = silu·up
// down_proj is LEFT as a separate qmm so the `hidden` boundary stays bit-exact —
// the existing minicpm5 L1/L2 parity goldens (maxDiff===0) gate this path directly
// (their 6-token prompt prefill is an M>1 MLP call).
//
// WHERE THE WIN IS: prefill / M>1, where the BlockMMA GEMM is the right tool and
// the [M, intermediate] materialization is real. At decode (M=1) the matmuls are
// memory-bound GEMVs (reading Wg/Wu dominates), so the fused kernel only saves the
// per-token dispatch + a tiny [1,I] round-trip — the caller falls back to unfused
// below M_MIN. Benchmarks (prefill AND decode) decide the default.
//
// PRECISION (two variants, env-flagged — "flag and try both"):
//  - MATCH (default): T = the activation dtype (bf16/f16). The gate/up tiles are
//    stored bf16-rounded out of the float BlockMMA accumulator, exactly as MLX's
//    quantized_matmul casts its float accum to the input dtype; σ/·/· then run
//    op-for-op with ops.sigmoid+ops.mul+ops.mul on bf16. AIM: maxDiff===0 vs the
//    unfused path (like the fused-gelu kernel, kl=0). Only residual: the metal
//    exp() vs MLX's math lib — quantified by the parity test.
//  - F32 (MLX_BUN_FUSED_SWIGLU_F32=1): keep gate/up/silu in f32 through the fusion,
//    round to T only at the final store. More accurate, NOT bit-exact → L3, gated
//    by teacher-forced KL like the fused-decode kernel.
//
// Never inside a compiled-decode trace: a CustomKernel has no output_shapes (same
// rule as fusedDecodeSdpa / fusedGeglu) — the caller guards on !isCompiledTrace().

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import { STEEL_QMM_HEADER } from "../train/steel-qmm-header";
import * as ops from "../mlx/ops";
import type { QuantSpec } from "../mlx/ops";

/** OFF by default until the prefill/decode benchmark + parity delta are in (then
 *  flip to on like FUSED_GELU if it lands bit-exact). MLX_BUN_FUSED_SWIGLU=1 opts in. */
export function fusedSwigluEnabled(): boolean {
  return process.env.MLX_BUN_FUSED_SWIGLU === "1";
}

/** f32-internal variant (NOT bit-exact). Default off → the bit-exact MATCH path. */
function f32Internal(): boolean {
  return process.env.MLX_BUN_FUSED_SWIGLU_F32 === "1";
}

/** Dispatch counter — a gate test asserts the kernel actually ran. */
export let fusedSwigluCalls = 0;

/** Debug bisect: cap how many fused calls actually run (rest fall back). */
function maxCalls(): number {
  const v = Number(process.env.MLX_BUN_SWIGLU_MAXCALLS);
  return Number.isFinite(v) && v >= 0 ? v : Infinity;
}
export function swigluUnderCap(): boolean {
  return fusedSwigluCalls < maxCalls();
}

// Below this many rows (M) the matmuls are memory-bound GEMVs and the fusion win
// is just dispatch overhead; the caller keeps the unfused path. Tunable via env
// for the decode-vs-prefill sweep.
export function swigluMMin(): number {
  const v = Number(process.env.MLX_BUN_FUSED_SWIGLU_MMIN);
  return Number.isFinite(v) && v > 0 ? v : 2;
}

const BM = 32, BN = 32, BK = 32, WM = 2, WN = 2;
const TGN = WM * WN * 32; // 128 threads / threadgroup

// One BM×BN output tile per threadgroup (grid.y = I-tiles, grid.z = M-tiles), the
// K=H reduction looped inside. Xs is loaded once and fed to BOTH the gate and up
// BlockMMA (the whole point of fusing — x is read from global once for two GEMMs).
const SOURCE = String.raw`
  // M from the x_shape helper (varies per call); I, H BAKED as template literals
  // (model-constant) — no runtime `+"`shape`"+` input array to thread through the
  // lazy graph. The per-loader quant constants (GS_G/BITS_G gate, GS_U/BITS_U up)
  // are baked too — the de-branch from the known per-tensor mixed-precision config,
  // so the gate=4/up=8 layers fuse instead of falling back.
  const uint M=x_shape[0]; constexpr int I=I_T, H=H_T;
  constexpr int gsG=GS_G, btsG=BITS_G, gsU=GS_U, btsU=BITS_U;
  constexpr int pfG=get_pack_factor<btsG,8>(), bppG=get_bytes_per_pack<btsG>();
  constexpr int pfU=get_pack_factor<btsU,8>(), bppU=get_bytes_per_pack<btsU>();
  constexpr int BKp=BK_T+16/sizeof(T);
  threadgroup T Xs[BM_T*BKp];
  threadgroup T Wgs[BN_T*BKp];
  threadgroup T Wus[BN_T*BKp];
  threadgroup T Lg[BM_T*BN_T];
  threadgroup T Lu[BM_T*BN_T];
  using mma_t=mlx::steel::BlockMMA<T,T,BM_T,BN_T,BK_T,WM_T,WN_T,false,true,BKp,BKp>;
  using lx_t=mlx::steel::BlockLoader<T,BM_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE>;
  using lwg_t=QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gsG,btsG>;
  using lwu_t=QuantizedBlockLoader<T,BN_T,BK_T,BKp,1,WM_T*WN_T*SIMD_SIZE,gsU,btsU>;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup;
  const uint lid=thread_position_in_threadgroup.x;
  const int Hh=(int)H;
  const int K_wG=Hh*bppG/pfG, K_gG=Hh/gsG;   // gate: packed-row bytes, group count
  const int K_wU=Hh*bppU/pfU, K_gU=Hh/gsU;   // up
  const int m0=(int)threadgroup_position_in_grid.z*BM_T;
  const int n0=(int)threadgroup_position_in_grid.y*BN_T;
  const short num_els=(short)min(BM_T,(int)M-m0);
  const short num_outs=(short)min(BN_T,(int)I-n0);

#if SWIGLU_TGZERO
  // Diagnostic: zero threadgroup memory so a back-to-back dispatch can't read the
  // previous kernel's leftover staging (the cross-dispatch hazard hypothesis).
  for (uint z=lid; z<(uint)(BM_T*BKp); z+=TGN_T) Xs[z]=T(0);
  for (uint z=lid; z<(uint)(BN_T*BKp); z+=TGN_T){ Wgs[z]=T(0); Wus[z]=T(0); }
  for (uint z=lid; z<(uint)(BM_T*BN_T); z+=TGN_T){ Lg[z]=T(0); Lu[z]=T(0); }
  threadgroup_barrier(mem_flags::mem_threadgroup);
#endif
  mma_t mg(sg,sl), mu(sg,sl);
  lx_t   lx (x  + (int64_t)m0*Hh, Hh, Xs, sg, sl);
  lwg_t  lwg((const device uint8_t*)wg + (int64_t)n0*K_wG, sg_w + (int64_t)n0*K_gG, bg_w + (int64_t)n0*K_gG, Hh, Wgs, sg, sl);
  lwu_t  lwu((const device uint8_t*)wu + (int64_t)n0*K_wU, su_w + (int64_t)n0*K_gU, bu_w + (int64_t)n0*K_gU, Hh, Wus, sg, sl);

  for (int k=0; k<Hh; k+=BK_T){
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (num_els<BM_T) lx.load_safe(short2(BK_T,num_els)); else lx.load_unsafe();
    if (num_outs<BN_T){ lwg.load_safe(short2(BK_T,num_outs)); lwu.load_safe(short2(BK_T,num_outs)); }
    else { lwg.load_unsafe(); lwu.load_unsafe(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mg.mma(Xs,Wgs);
    mu.mma(Xs,Wus);
    lx.next(); lwg.next(); lwu.next();
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  // Stage both accumulators to threadgroup. store<T,...> casts the float accum to
  // T (bf16) — the SAME rounding MLX's quantized_matmul applies to its output, so
  // Lg/Lu hold the bf16 gate/up the unfused path would have written to global.
  // Xs/Wgs/Wus alias Lg/Lu only if a kernel reused the same tgmem — they don't here,
  // but the stores write threadgroup that the epilogue reads, so bracket with barriers.
  mg.Ctile.template store<T,WM_T,WN_T,BN_T,1>(Lg + mg.sm*BN_T + mg.sn);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  mu.Ctile.template store<T,WM_T,WN_T,BN_T,1>(Lu + mu.sm*BN_T + mu.sn);
  threadgroup_barrier(mem_flags::mem_threadgroup);

  for (uint idx=lid; idx<(uint)(BM_T*BN_T); idx+=TGN_T){
    int r=(int)idx/BN_T, c=(int)idx%BN_T;
    if (m0+r>=(int)M || n0+c>=(int)I) continue;
#if SWIGLU_DEBUG_GATE
    hidden[(int64_t)(m0+r)*(int64_t)I + n0+c] = Lg[idx]; // raw gate proj (debug)
#elif SWIGLU_F32
    // f32-internal: gate/up stayed bf16 in Lg/Lu (the matmul output is the same),
    // but σ·/· run in f32 with no intermediate rounding → NOT bit-exact.
    float g=(float)Lg[idx], u=(float)Lu[idx];
    float sig=1.0f/(1.0f+metal::precise::exp(-g));
    hidden[(int64_t)(m0+r)*(int64_t)I + n0+c] = (T)(g*sig*u);
#else
    // MATCH: round σ, silu, product to T op-for-op with ops.sigmoid+mul+mul on bf16.
    T gT=Lg[idx], uT=Lu[idx];
    T sigT=(T)(1.0f/(1.0f+metal::precise::exp(-(float)gT)));
    T siluT=(T)((float)gT*(float)sigT);
    hidden[(int64_t)(m0+r)*(int64_t)I + n0+c] = (T)((float)siluT*(float)uT);
#endif
  }
`;

const _kernels = new Map<string, MetalKernel>();
function getKernel(gsG: number, btsG: number, gsU: number, btsU: number, f32: boolean): MetalKernel {
  const key = `${gsG}:${btsG}:${gsU}:${btsU}:${f32 ? 1 : 0}`;
  let k = _kernels.get(key);
  if (!k) {
    k = new MetalKernel({
      name: "mlx_bun_fused_swiglu",
      inputNames: ["x", "wg", "sg_w", "bg_w", "wu", "su_w", "bu_w"],
      outputNames: ["hidden"],
      source: SOURCE,
      header:
        `${STEEL_QMM_HEADER}\n` +
        `#define GS_G ${gsG}\n#define BITS_G ${btsG}\n#define GS_U ${gsU}\n#define BITS_U ${btsU}\n` +
        `#define BM_T ${BM}\n#define BN_T ${BN}\n#define BK_T ${BK}\n` +
        `#define WM_T ${WM}\n#define WN_T ${WN}\n#define TGN_T ${TGN}\n` +
        `#define SWIGLU_F32 ${f32 ? 1 : 0}\n` +
        `#define SWIGLU_TGZERO ${process.env.MLX_BUN_SWIGLU_TGZERO === "1" ? 1 : 0}\n` +
        `#define SWIGLU_DEBUG_GATE ${process.env.MLX_BUN_SWIGLU_DEBUG_GATE === "1" ? 1 : 0}\n`,
      ensureRowContiguous: true,
    });
    _kernels.set(key, k);
  }
  return k;
}

/** Each loader's (bits, groupSize) is baked independently, so gate and up may
 *  differ (the per-tensor mixed-precision layers). Requires bf16/f16 activations,
 *  affine biases, group size a multiple of BK, and H % BK == 0. */
export function fusedSwigluSupported(
  x: MlxArray, gateSpec: QuantSpec, upSpec: QuantSpec,
  gateBias: MlxArray | null, upBias: MlxArray | null,
): boolean {
  const H = x.shape[x.shape.length - 1]!;
  const specOk = (s: QuantSpec) =>
    (s.bits === 2 || s.bits === 4 || s.bits === 8) && s.groupSize % BK === 0 && BK <= s.groupSize;
  return (
    (x.dtype === Dtype.bfloat16 || x.dtype === Dtype.float16) &&
    gateBias != null && upBias != null &&
    specOk(gateSpec) && specOk(upSpec) &&
    H % BK === 0
  );
}

/** silu(gate_proj(x)) · up_proj(x), fused. `x` is [..., H] (collapsed to [M, H]);
 *  wg/wu are the packed quantized weights [I, H*bits/32], with per-group
 *  scales/biases [I, H/groupSize]. gate and up may use different quant specs.
 *  Returns hidden [M, I] in x.dtype. Caller owns it. */
export function fusedSwiglu(
  x: MlxArray,
  wg: MlxArray, sg: MlxArray, bg: MlxArray,
  wu: MlxArray, su: MlxArray, bu: MlxArray,
  gateSpec: QuantSpec, upSpec: QuantSpec = gateSpec,
): MlxArray {
  fusedSwigluCalls++;
  const H = x.shape[x.shape.length - 1]!;
  const M = x.shape.reduce((a, b) => a * b, 1) / H;
  const I = wg.shape[0]!;
  const x2 = x.shape.length === 2 ? x : ops.reshape(x, [M, H]);
  try {
    const [hidden] = getKernel(gateSpec.groupSize, gateSpec.bits, upSpec.groupSize, upSpec.bits, f32Internal()).apply(
      [x2, wg, sg, bg, wu, su, bu],
      {
        outputShapeFn: (ins) => [{ shape: [ins[0]!.shape[0]!, I], dtype: x.dtype }],
        grid: (ins) => [TGN, Math.ceil(I / BN), Math.ceil(ins[0]!.shape[0]! / BM)],
        threadGroup: [TGN, 1, 1],
        templateInts: { I_T: I, H_T: H },
        templateDtypes: { T: x.dtype },
      },
    );
    // Restore the leading dims the caller passed (e.g. [B, T, I]).
    if (x.shape.length !== 2) {
      const out = ops.reshape(hidden!, [...x.shape.slice(0, -1), I]);
      hidden!.dispose();
      return out;
    }
    return hidden!;
  } finally {
    if (x2 !== x && process.env.MLX_BUN_SWIGLU_NODISPOSE !== "1") x2.dispose();
  }
}
