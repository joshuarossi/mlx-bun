// Steel backward phase-1: logit[BM,BN] = X@Wᵀ via BlockMMA (WM=1,WN=4,BM=8), then
// coeff = g·(onehot − softmax(logit−lse))·sech²(softcap). Validate coeff vs reference.
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { STEEL_QMM_HEADER } from "../../src/train/steel-qmm-header";
const M=64, H=128, V=256, GS=64, BITS=8, WPR=H*BITS/32, GR=H/GS;
// one threadgroup per (token-block BM=8, vocab-tile BN=32); output coeff[M,V] for validation.
const BODY = String.raw`
  const int Hh=(int)shp[0], Vv=(int)shp[1], Mm=(int)shp[2];
  constexpr int BM=8,BN=32,BK=32,WM=1,WN=4,gs=${GS},bts=${BITS};
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BN*BKp]; threadgroup float Ls[BM*BN];
  using mma_t=mlx::steel::BlockMMA<float,float,BM,BN,BK,WM,WN,false,true,BKp,BKp>;
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BN,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  const uint tb=threadgroup_position_in_grid.z, vt=threadgroup_position_in_grid.y;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int K_w=Hh*bpp/pf, K_g=Hh/gs, tokBase=(int)tb*BM, v0=(int)vt*BN;
  mma_t mma_op(sg,sl);
  lx_t loader_x(x+(int64_t)tokBase*Hh, Hh, Xs, sg, sl);
  lw_t loader_w((const device uint8_t*)w+v0*K_w, scales+v0*K_g, biases+v0*K_g, Hh, Ws, sg, sl);
  for(int k=0;k<Hh;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup); loader_x.load_unsafe(); loader_w.load_unsafe(); threadgroup_barrier(mem_flags::mem_threadgroup); mma_op.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  mma_op.Ctile.store<float,WM,WN,BN,1>(Ls + mma_op.sm*BN + mma_op.sn);
  threadgroup_barrier(mem_flags::mem_threadgroup);
  if (lid<(uint)BM && tokBase+(int)lid<Mm){ uint b=lid; const float lseb=lse[tokBase+b], gb=gv[tokBase+b]; const uint tg=targets[tokBase+b];
    for (int v=0; v<BN; ++v){ int n=v0+v; if(n>=Vv) break;
      float logit=Ls[b*BN+v], sech2=1.0f; if(cap>0.0f){ float th=tanh(logit/cap); logit=cap*th; sech2=1.0f-th*th; }
      float sm=exp(logit-lseb); float c=gb*(((uint)n==tg?1.0f:0.0f)-sm); if(cap>0.0f) c*=sech2;
      coeff_out[(tokBase+b)*Vv+n]=c; }
  }
`;
const k=new MetalKernel({name:"steel_coeff",inputNames:["w","x","scales","biases","targets","lse","gv","shp","capv"],outputNames:["coeff_out"],source:BODY,header:STEEL_QMM_HEADER,ensureRowContiguous:true});
const wHost=new Uint32Array(V*WPR).map(()=>(Math.random()*0xffffffff)>>>0);
const w=MlxArray.fromView(new Uint8Array(wHost.buffer.slice(0)),[V,WPR],Dtype.uint32);
const x=MlxArray.fromFloat32(new Float32Array(M*H).map(()=>-0.3+Math.random()*0.6),[M,H]);
const scales=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.02),[V,GR]);
const biases=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.0),[V,GR]);
const targets=Array.from({length:M},(_, i)=>(i*131+7)%V);
const tgt=MlxArray.fromView(new Uint8Array(new Uint32Array(targets).buffer.slice(0)),[M],Dtype.uint32);
const spec={bits:BITS,groupSize:GS,mode:"affine"} as any;
// reference logits → lse, then coeff = (onehot−softmax) (cap=0, g=1 for simplicity)
const refLogits=ops.quantizedMatmul(x,w,scales,biases,spec,true);
const lseRef=ops.logsumexpAxis(refLogits,-1,false);
const lse=MlxArray.fromFloat32(lseRef.toFloat32(),[M]);
const gv=MlxArray.fromFloat32(new Float32Array(M).fill(1),[M]);
const shp=MlxArray.fromView(new Uint8Array(new Uint32Array([H,V,M]).buffer.slice(0)),[3],Dtype.uint32);
const capv=MlxArray.fromFloat32(new Float32Array([0]),[1]);
const [coeff]=k.apply([w,x,scales,biases,tgt,lse,gv,shp,capv],{outputs:[{shape:[M,V],dtype:Dtype.float32}],grid:[128, V/32, Math.ceil(M/8)],threadGroup:[128,1,1]});
// ref coeff = onehot − softmax
const lseC=ops.reshape(lseRef,[M,1]); const sm=ops.exp(ops.sub(refLogits,lseC));
const refC=sm.toFloat32(); const ch=coeff.toFloat32();
evalAll([coeff]);
let md=0; for(let i=0;i<M;i++)for(let n=0;n<V;n++){ const oneh=(targets[i]===n?1:0); const ref=oneh-refC[i*V+n]!; md=Math.max(md,Math.abs(ch[i*V+n]!-ref)); }
console.log(`### steel phase-1 coeff vs reference (onehot−softmax): maxAbs=${md.toExponential(3)} → ${md<2e-3?"PASS":"FAIL"}`);
