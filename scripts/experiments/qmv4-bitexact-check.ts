// Is the megakernel's qmv4 (port of mlx qmv_fast) BIT-EXACT with ops.quantizedMatmul?
// If yes, the megakernel's ~1-ULP K divergence comes from rmsnorm/rope, not the GEMV.
// If no, qmv4 isn't a faithful port → fix it (the user's "copy what quantizedMatmul does").
//   bun scripts/experiments/qmv4-bitexact-check.ts
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
import * as ops from "../../src/mlx/ops";

const N = 256, K = 1536, GS = 64, TGN = 256;

// qmv4 + helpers, lifted verbatim from megakernel-kernel.ts (single-threadgroup driver).
const FPC = process.env.FPC || "default"; // default | off | fast
const HEADER = (bits: number, ppt: number) => String.raw`
${FPC === "off" ? "#pragma clang fp contract(off)" : FPC === "fast" ? "#pragma clang fp contract(fast)" : ""}
#define GS 64
#define RESULTS_PER_SG 4
#define PPT ${ppt}
#define NSG (${TGN}/32)
template <int BITS>
inline float load_vec_tg(threadgroup const bfloat16_t* x, thread float* xt) {
  constexpr int VPT = (32/BITS)*PPT; float sum = 0.0f;
  if (BITS == 4) { for (int i=0;i<VPT;i+=4){ float a=(float)x[i],b=(float)x[i+1],c=(float)x[i+2],d=(float)x[i+3]; sum+=a+b+c+d; xt[i]=a; xt[i+1]=b/16.0f; xt[i+2]=c/256.0f; xt[i+3]=d/4096.0f; } }
  else { for (int i=0;i<VPT;++i){ float a=(float)x[i]; sum+=a; xt[i]=a; } }
  return sum;
}
template <int BITS>
inline float qdot_t(const device uint8_t* w, thread const float* xt, float scale, float bias, float sum) {
  constexpr int VPT=(32/BITS)*PPT; float accum=0.0f;
  if (BITS==4) { const device uint16_t* ws=(const device uint16_t*)w; for (int i=0;i<VPT/4;++i) accum += xt[4*i]*(ws[i]&0x000f)+xt[4*i+1]*(ws[i]&0x00f0)+xt[4*i+2]*(ws[i]&0x0f00)+xt[4*i+3]*(ws[i]&0xf000); }
  else { for (int i=0;i<VPT;++i) accum += xt[i]*(float)w[i]; }
  return scale*accum + sum*bias;
}
template <int BITS>
inline void qmv4(const device uint8_t* wbase, const device bfloat16_t* scbase, const device bfloat16_t* bibase,
                 threadgroup const bfloat16_t* x, int K, int orow, uint lane, thread float* result) {
  constexpr int pf=32/BITS, bpp=4, ppt=PPT, VPT=pf*ppt, block=VPT*32;
  const int wrow=K*bpp/pf; const int grow=K/64;
  const device uint8_t* ws=wbase+(uint)orow*(uint)wrow+(uint)lane*ppt*bpp;
  const device bfloat16_t* sl=scbase+(uint)orow*(uint)grow+lane/(64/VPT);
  const device bfloat16_t* bl=bibase+(uint)orow*(uint)grow+lane/(64/VPT);
  threadgroup const bfloat16_t* xp=x+lane*VPT;
  for (int r=0;r<RESULTS_PER_SG;++r) result[r]=0.0f;
  for (int k=0;k<K;k+=block) { float xt[VPT]; float s=load_vec_tg<BITS>(xp,xt);
    for (int row=0;row<RESULTS_PER_SG;++row){ const device uint8_t* wl=ws+(uint)row*(uint)wrow; float sc=(float)sl[row*grow],bi=(float)bl[row*grow]; result[row]+=qdot_t<BITS>(wl,xt,sc,bi,s);}
    ws+=(uint)(block*bpp/pf); sl+=block/64; bl+=block/64; xp+=block; }
}`;
const SRC = String.raw`
  const uint lid=thread_position_in_threadgroup.x;
  const uint sgid=simdgroup_index_in_threadgroup;
  const uint lane=thread_index_in_simdgroup;
  threadgroup bfloat16_t xloc[${K}];
  for (uint i=lid;i<${K}u;i+=${TGN}u) xloc[i]=x[i];
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (int orow=(int)sgid*RESULTS_PER_SG; orow<${N}; orow+=(int)NSG*RESULTS_PER_SG) {
    float res[RESULTS_PER_SG]; qmv4<BITS_T>(W8, scales, biases, xloc, ${K}, orow, lane, res);
    for (int r=0;r<RESULTS_PER_SG;++r){ float v=metal::simd_sum(res[r]); if (lane==0 && orow+r<${N}) y[orow+r]=(bfloat16_t)v; }
  }`;

for (const [bits, ppt] of [[4, 2], [4, 1], [8, 2], [8, 1]] as [number, number][]) {
  // random weight, quantize → packed/scales/biases (the ops.quantizedMatmul reference)
  const wf = new Float32Array(N * K);
  for (let i = 0; i < wf.length; i++) wf[i] = (Math.sin(i * 7.13) * 1234.5 % 1) * 2 - 1;
  const W = MlxArray.fromFloat32(wf, [N, K]).astype(Dtype.bfloat16);
  const q = ops.quantize(W, GS, bits);
  const xf = new Float32Array(K);
  for (let i = 0; i < K; i++) xf[i] = (Math.cos(i * 3.7) * 99.9 % 1) * 2 - 1;
  const x = MlxArray.fromFloat32(xf, [1, K]).astype(Dtype.bfloat16);
  // reference: ops.quantizedMatmul (transpose=true → [1,N])
  const ref = ops.quantizedMatmul(x, q.packed, q.scales, q.biases, { groupSize: GS, bits, mode: "affine" }, true).astype(Dtype.float32).toFloat32();
  // ours: qmv4
  const k = new MetalKernel({ name: `qmv4chk${bits}_${ppt}`, inputNames: ["W8", "scales", "biases", "x"], outputNames: ["y"], header: HEADER(bits, ppt), source: SRC, ensureRowContiguous: true });
  const W8 = MlxArray.fromBytesCopy(new Uint8Array((q.packed.eval(), q.packed.rawBytes())), [q.packed.rawBytes().byteLength], Dtype.uint8);
  const xr = ops.reshape(x, [K]);
  const [y] = k.apply([W8, q.scales, q.biases, xr], { outputs: [{ shape: [N], dtype: Dtype.bfloat16 }], grid: [TGN, 1, 1], threadGroup: [TGN, 1, 1], templateInts: { BITS_T: bits } });
  const ours = y!.astype(Dtype.float32).toFloat32();
  let maxDiff = 0, ne = 0; const diffRows: string[] = [];
  for (let i = 0; i < N; i++) { const d = Math.abs(ours[i]! - ref[i]!); if (d > maxDiff) maxDiff = d; if (d > 1e-3) { ne++; if (diffRows.length < 8) diffRows.push(`row${i}(sg${(((i/4)|0)%(TGN/32))}): ours=${ours[i]!.toFixed(3)} ref=${ref[i]!.toFixed(3)}`); } }
  console.log(`bits=${bits} ppt=${ppt}: qmv4 vs ops.quantizedMatmul  maxDiff=${maxDiff.toExponential(3)}  diff elems=${ne}/${N}`);
  if (ne) console.log("  " + diffRows.join("\n  "));
}
