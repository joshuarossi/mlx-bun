// H-TILED steel backward (the production memory shape + phase-2 dequant): per
// (vocab-tile, H-tile) a TEMP BlockMMA over a bounded Wd[32 vocab, HTw H-cols]
// staging, with the temp's Ctile accumulated into a persistent register accumulator
// D = MMATile<1, H/32> lane-locally (no get_coord gymnastics — frag += frag is
// per-lane). The Wd staging uses MLX's vectorized+fused QuantizedBlockLoader
// (reduction_dim=0; the SAME loader the forward uses), NOT a manual scalar dequant —
// which pins HTw == group_size so each H-tile is exactly one quant group (the
// BCOLS<=group_size && group_size%BCOLS==0 loader constraint). TNv = HTw/32 frags per
// H-tile. This mirrors src/train/flash-cce.ts BWD_STEEL_SOURCE exactly. Validate dh
// vs quantizedMatmul(coeff,W,t=F).
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { STEEL_QMM_HEADER } from "../../src/train/steel-qmm-header";

const M = 64, H = 2560, V = 256, GS = 64, BITS = 8;
const WPR = (H * BITS) / 32, GR = H / GS;
// QBL phase-2: HTw == group_size (64) so each H-tile is exactly one quant group →
// QuantizedBlockLoader(reduction_dim=0) stages Wd[32 vocab, 64 H-cols] vectorized+fused
// (same loader the forward uses), replacing the manual scalar dequant. TN = HTw/32 = 2.
const TNv = GS / 32; // frags per H-tile (2)
const NHT = H / GS, NHTF = NHT * TNv; // # H-tiles, total accumulator frags/sg (= H/32)

const BODY = String.raw`
  const int Hh=(int)shp[0], Vv=(int)shp[1], Mm=(int)shp[2];
  constexpr int BM=8,BNv=32,BK=32,WM=1,WN=4,gs=${GS},bts=${BITS},HTw=${GS},NHTc=${NHT},TNv=${TNv};
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BNv*BKp]; threadgroup float Ls[BM*BNv];
  threadgroup float coeffS[BM*BNv]; threadgroup float Wd[BNv*HTw];   // bounded per-H-tile dequant
  using lmma_t=mlx::steel::BlockMMA<float,float,BM,BNv,BK,WM,WN,false,true,BKp,BKp>;     // logit X@Wᵀ
  using dmma_t=mlx::steel::BlockMMA<float,float,BM,HTw,BNv,WM,WN,false,false,BNv,HTw>;    // dh tile coeff@Wd
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BNv,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  // phase-2 W loader: BROWS=32 vocab (the GEMM's K), BCOLS=HTw=group_size (one group/tile),
  // reduction_dim=0, dst_ld=HTw. Constructed fresh per H-tile, single load_unsafe (no next()).
  using lw2_t=QuantizedBlockLoader<float,BNv,HTw,HTw,0,WM*WN*SIMD_SIZE,gs,bts>;
  const uint tb=threadgroup_position_in_grid.z;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int K_w=Hh*bpp/pf, K_g=Hh/gs, tokBase=(int)tb*BM;
  short2 sc2=mlx::steel::BaseMMAFrag<float,8,8>::get_coord(sl); const short fm=sc2.y, fn=sc2.x;
  const uint perWord=32u/bts, qmask=(bts==32u)?0xffffffffu:((1u<<bts)-1u);

  mlx::steel::MMATile<float,1,${NHTF}> D;   // persistent dh accumulator (H/32 frags @ e4b)

  for (int v0=0; v0<Vv; v0+=BNv){
    // --- phase 1: logit tile X[8,H] @ Wᵀ[H,32] → Ls[8,32] → coeff epilogue ---
    lmma_t lmma(sg,sl);
    lx_t loader_x(x+(int64_t)tokBase*Hh, Hh, Xs, sg, sl);
    lw_t loader_w((const device uint8_t*)w+v0*K_w, scales+v0*K_g, biases+v0*K_g, Hh, Ws, sg, sl);
    for(int k=0;k<Hh;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup); loader_x.load_unsafe(); loader_w.load_unsafe(); threadgroup_barrier(mem_flags::mem_threadgroup); lmma.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    lmma.Ctile.store<float,WM,WN,BNv,1>(Ls + lmma.sm*BNv + lmma.sn);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (lid<(uint)BM && tokBase+(int)lid<Mm){ uint b=lid; const float lseb=lse[tokBase+b], gb=gv[tokBase+b]; const uint tgt=targets[tokBase+b];
      for(int v=0;v<BNv;++v){ int n=v0+v; float logit=Ls[b*BNv+v],sech2=1.0f; if(cap>0.0f){float th=tanh(logit/cap);logit=cap*th;sech2=1.0f-th*th;} float sm=exp(logit-lseb); float c=(n<Vv)?gb*(((uint)n==tgt?1.0f:0.0f)-sm):0.0f; if(cap>0.0f)c*=sech2; coeffS[b*BNv+v]=c; } }
    threadgroup_barrier(mem_flags::mem_threadgroup);

    // --- phase 2: per H-tile, QuantizedBlockLoader stages Wd[32,HTw], temp BlockMMA, accum into D ---
    for (int ht=0; ht<NHTc; ++ht){
      const int hbase=ht*HTw;
      // src at byte addr of W[v0, hbase]; scales/biases at group ht of vocab row v0.
      lw2_t loader_w2((const device uint8_t*)w + (int64_t)v0*K_w + (int64_t)hbase*bpp/pf,
                      scales + (int64_t)v0*K_g + ht, biases + (int64_t)v0*K_g + ht, Hh, Wd, sg, sl);
      loader_w2.load_unsafe();
      threadgroup_barrier(mem_flags::mem_threadgroup);
      dmma_t tmp(sg,sl);
      tmp.mma(coeffS, Wd);    // tmp.Ctile[8,HTw] = coeff[8,32] @ Wd[32,HTw]
      for(int j=0;j<TNv;++j) D.frag_at(0, ht*TNv+j) += tmp.Ctile.frag_at(0,j);
      threadgroup_barrier(mem_flags::mem_threadgroup);
    }
  }

  // --- store D → dh (single-program test: plain write; production atomic-adds) ---
  for(int gj=0; gj<${NHTF}; ++gj){
    int ht=gj/TNv, j=gj%TNv; int row=tokBase+(int)fm; int col=ht*HTw + 8*(int)sg + (int)fn + j*32;
    if(row<Mm && col+1<=Hh){ thread auto& fr=D.frag_at(0,gj); dh[(int64_t)row*Hh + col]=fr[0]; dh[(int64_t)row*Hh + col+1]=fr[1]; }
  }
`.replace(/WPRC/g, String(WPR));

const k = new MetalKernel({ name: "steel_bwd_htile", inputNames: ["w", "x", "scales", "biases", "targets", "lse", "gv", "shp", "capv"], outputNames: ["dh"], source: BODY, header: STEEL_QMM_HEADER, ensureRowContiguous: true });
const wHost = new Uint32Array(V * WPR).map(() => (Math.random() * 0xffffffff) >>> 0);
const w = MlxArray.fromBytesCopy(new Uint8Array(wHost.buffer.slice(0)), [V, WPR], Dtype.uint32);
const x = MlxArray.fromFloat32(new Float32Array(M * H).map(() => -0.3 + Math.random() * 0.6), [M, H]);
const scales = MlxArray.fromFloat32(new Float32Array(V * GR).map(() => 0.02), [V, GR]);
const biases = MlxArray.fromFloat32(new Float32Array(V * GR).map(() => 0.0), [V, GR]);
const targets = Array.from({ length: M }, (_, i) => (i * 131 + 7) % V);
const tgt = MlxArray.fromBytesCopy(new Uint8Array(new Uint32Array(targets).buffer.slice(0)), [M], Dtype.uint32);
const spec = { bits: BITS, groupSize: GS, mode: "affine" } as any;
const refLogits = ops.quantizedMatmul(x, w, scales, biases, spec, true);
const lseRef = ops.logsumexpAxis(refLogits, -1, false);
const lse = MlxArray.fromFloat32(lseRef.toFloat32(), [M]);
const gv = MlxArray.fromFloat32(new Float32Array(M).fill(1), [M]);
const shp = MlxArray.fromBytesCopy(new Uint8Array(new Uint32Array([H, V, M]).buffer.slice(0)), [3], Dtype.uint32);
const capv = MlxArray.fromFloat32(new Float32Array([0]), [1]);
const dh = k.apply([w, x, scales, biases, tgt, lse, gv, shp, capv], { outputs: [{ shape: [M, H], dtype: Dtype.float32 }], grid: [128, 1, Math.ceil(M / 8)], threadGroup: [128, 1, 1] })[0]!;
// reference: coeff = onehot − softmax; dh_ref = quantizedMatmul(coeff, W, transpose=false)
const lseC = ops.reshape(lseRef, [M, 1]); const sm = ops.exp(ops.sub(refLogits, lseC)); const smH = sm.toFloat32();
const coeffArr = new Float32Array(M * V); for (let i = 0; i < M; i++) for (let n = 0; n < V; n++) coeffArr[i * V + n] = (targets[i] === n ? 1 : 0) - smH[i * V + n]!;
const coeff = MlxArray.fromFloat32(coeffArr, [M, V]);
const dhRef = ops.quantizedMatmul(coeff, w, scales, biases, spec, false);
evalAll([dh, dhRef]);
const a = dh.toFloat32(), b = dhRef.toFloat32();
let md = 0, mr = 0; for (let i = 0; i < M * H; i++) { md = Math.max(md, Math.abs(a[i]! - b[i]!)); mr = Math.max(mr, Math.abs(b[i]!)); }
console.log(`### H-tiled steel backward dh vs quantizedMatmul(coeff,W,t=false): maxAbs=${md.toExponential(3)} (max ${mr.toFixed(3)}) → ${md / mr < 2e-3 ? "PASS" : "FAIL"}`);
