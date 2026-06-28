// Validate the verbatim steel qmm port: compute [M,V] logits via the ported
// BlockMMA/QuantizedBlockLoader, compare to ops.quantizedMatmul (same quant data).
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { STEEL_QMM_HEADER } from "../../src/train/steel-qmm-header";
const M=64, H=128, V=256, GS=64, BITS=8;
const WPR = H*BITS/32, GR = H/GS;
const BODY = String.raw`
  const int Kk=(int)shp[0], Nn=(int)shp[1];
  constexpr int BM=32, BK=32, BN=32, WM=2, WN=2;
  constexpr int gs=${GS}, bts=${BITS};
  constexpr int pf = get_pack_factor<bts,8>();
  constexpr int bpp = get_bytes_per_pack<bts>();
  constexpr int BKp = BK + 16/sizeof(float);
  threadgroup float Xs[BM*BKp];
  threadgroup float Ws[BN*BKp];
  using mma_t = mlx::steel::BlockMMA<float,float,BM,BN,BK,WM,WN,false,true,BKp,BKp>;
  using lx_t = mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t = QuantizedBlockLoader<float,BN,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  const int K_w = Kk*bpp/pf, K_g = Kk/gs;
  const uint3 tid = threadgroup_position_in_grid;
  const uint sg = simdgroup_index_in_threadgroup, sl = thread_index_in_simdgroup;
  const int yr = tid.y*BM, yc = tid.x*BN;
  const device uint8_t* wl = (const device uint8_t*)w + yc*K_w;
  const device float* xx = x + (int64_t)yr*Kk;
  const device float* scl = scales + yc*K_g;
  const device float* bis = biases + yc*K_g;
  device float* yy = y + (int64_t)yr*Nn + yc;
  lx_t loader_x(xx, Kk, Xs, sg, sl);
  lw_t loader_w(wl, scl, bis, Kk, Ws, sg, sl);
  mma_t mma_op(sg, sl);
  for (int k=0;k<Kk;k+=BK){
    threadgroup_barrier(mem_flags::mem_threadgroup);
    loader_x.load_unsafe(); loader_w.load_unsafe();
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mma_op.mma(Xs,Ws);
    loader_x.next(); loader_w.next();
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  mma_op.store_result(yy, Nn);
`;
const k = new MetalKernel({ name:"qmm_port", inputNames:["w","x","scales","biases","shp"], outputNames:["y"], source:BODY, header:STEEL_QMM_HEADER, ensureRowContiguous:true });
const wHost = new Uint32Array(V*WPR).map(()=>(Math.random()*0xffffffff)>>>0);
const w = MlxArray.fromBytesCopy(new Uint8Array(wHost.buffer.slice(0)),[V,WPR],Dtype.uint32);
const x = MlxArray.fromFloat32(new Float32Array(M*H).map(()=>-0.5+Math.random()),[M,H]);
const scales = MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.01+Math.random()*0.02),[V,GR]);
const biases = MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>-0.1+Math.random()*0.2),[V,GR]);
const shp = MlxArray.fromBytesCopy(new Uint8Array(new Uint32Array([H,V,M]).buffer.slice(0)),[3],Dtype.uint32);
const y = k.apply([w,x,scales,biases,shp],{outputs:[{shape:[M,V],dtype:Dtype.float32}],grid:[(V/32)*128,M/32,1],threadGroup:[128,1,1]})[0]!;
const ref = ops.quantizedMatmul(x, w, scales, biases, {bits:BITS, groupSize:GS, mode:"affine"} as any, true);
evalAll([y, ref]);
const yh = y.toFloat32(), rh = ref.toFloat32();
let maxd=0, maxr=0; for(let i=0;i<M*V;i++){maxd=Math.max(maxd,Math.abs(yh[i]!-rh[i]!)); maxr=Math.max(maxr,Math.abs(rh[i]!));}
console.log(`### steel-port logits vs quantizedMatmul: maxAbs=${maxd.toExponential(3)} (ref max ${maxr.toFixed(3)}) → ${maxd/maxr<1e-3?"PASS":"FAIL"}`);
