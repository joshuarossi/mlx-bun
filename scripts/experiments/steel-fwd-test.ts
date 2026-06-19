// Forward CCE epilogue on the steel GEMM: per (token-block, vocab-block) threadgroup,
// loop BN vocab-tiles (steel K-loop → logit tile in Ctile → threadgroup Ls), online
// softmax → [M,NBLK] partials; merge in MLX → logp. Compare to dense reference.
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { STEEL_QMM_HEADER } from "../../src/train/steel-qmm-header";
const M=128, H=256, V=512, GS=64, BITS=8, VB=256; // aligned; NBLK=V/VB=2
const WPR=H*BITS/32, GR=H/GS, NBLK=Math.ceil(V/VB);
const BODY = String.raw`
  const int Kk=(int)shp[0], Nn=(int)shp[1], Mm=(int)shp[2], blockV=(int)shp[3];
  constexpr int BM=32,BK=32,BN=32,WM=2,WN=2,gs=${GS},bts=${BITS};
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BN*BKp]; threadgroup float Ls[BM*BN];
  threadgroup float tgMax[BM], tgSum[BM], tgTgt[BM]; threadgroup uint tgTid[BM];
  using mma_t=mlx::steel::BlockMMA<float,float,BM,BN,BK,WM,WN,false,true,BKp,BKp>;
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BN,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  const uint tokBlk=threadgroup_position_in_grid.z, vb=threadgroup_position_in_grid.y;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int K_w=Kk*bpp/pf, K_g=Kk/gs;
  const int nStart=vb*blockV, nEnd=min(nStart+blockV, Nn), tokBase=tokBlk*BM;
  if (lid<BM){ tgMax[lid]=-INFINITY; tgSum[lid]=0; tgTgt[lid]=0; tgTid[lid]=(tokBase+lid<Mm)?targets[tokBase+lid]:0xffffffffu; }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  for (int v0=nStart; v0<nEnd; v0+=BN){
    mma_t mma_op(sg,sl);
    lx_t loader_x(x+(int64_t)tokBase*Kk, Kk, Xs, sg, sl);
    lw_t loader_w((const device uint8_t*)w+v0*K_w, scales+v0*K_g, biases+v0*K_g, Kk, Ws, sg, sl);
    for(int k=0;k<Kk;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup); loader_x.load_unsafe(); loader_w.load_unsafe(); threadgroup_barrier(mem_flags::mem_threadgroup); mma_op.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    mma_op.Ctile.store<float,WM,WN,BN,1>(Ls + mma_op.sm*BN + mma_op.sn);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if (lid<BM && tokBase+lid<Mm){
      uint b=lid;
      for (int v=0; v<BN; ++v){ int n=v0+v; if(n>=nEnd) break;
        float logit=Ls[b*BN+v]; if(cap>0) logit=cap*tanh(logit/cap);
        float nm=max(tgMax[b],logit); tgSum[b]=tgSum[b]*exp(tgMax[b]-nm)+exp(logit-nm); tgMax[b]=nm;
        if((uint)n==tgTid[b]) tgTgt[b]=logit; }
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
  if (lid<BM && tokBase+lid<Mm){ uint t=tokBase+lid;
    bMax_out[t*NBLK+vb]=tgMax[lid]; bSum_out[t*NBLK+vb]=tgSum[lid]; bTgt_out[t*NBLK+vb]=tgTgt[lid]; }
`.replace(/NBLK/g, String(NBLK));
const k=new MetalKernel({name:"steel_fwd",inputNames:["w","x","scales","biases","targets","shp","capv"],outputNames:["bMax_out","bSum_out","bTgt_out"],source:BODY,header:STEEL_QMM_HEADER,ensureRowContiguous:true});
const w=MlxArray.fromView(new Uint8Array(new Uint32Array(V*WPR).map(()=>(Math.random()*0xffffffff)>>>0).buffer.slice(0)),[V,WPR],Dtype.uint32);
const xh=new Float32Array(M*H).map(()=>-0.3+Math.random()*0.6);
const x=MlxArray.fromFloat32(xh,[M,H]);
const scales=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.01+Math.random()*0.02),[V,GR]);
const biases=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>-0.1+Math.random()*0.2),[V,GR]);
const targets=Array.from({length:M},(_, i)=>(i*131+7)%V);
const tgt=MlxArray.fromView(new Uint8Array(new Uint32Array(targets).buffer.slice(0)),[M],Dtype.uint32);
const blockV=Math.ceil(V/NBLK);
const shp=MlxArray.fromView(new Uint8Array(new Uint32Array([H,V,M,blockV]).buffer.slice(0)),[4],Dtype.uint32);
const capv=MlxArray.fromFloat32(new Float32Array([0]),[1]);
const outs=k.apply([w,x,scales,biases,tgt,shp,capv],{outputs:[{shape:[M,NBLK],dtype:Dtype.float32},{shape:[M,NBLK],dtype:Dtype.float32},{shape:[M,NBLK],dtype:Dtype.float32}],grid:[128,NBLK,Math.ceil(M/32)],threadGroup:[128,1,1]});
const [bMax,bSum,bTgt]=outs as [MlxArray,MlxArray,MlxArray];
const gMax=ops.maxAxis(bMax,1,false); const gMaxC=ops.reshape(gMax,[M,1]);
const gSum=ops.sumAxis(ops.mul(bSum,ops.exp(ops.sub(bMax,gMaxC))),1,false);
const lse=ops.add(gMax,ops.log(gSum)); const tg=ops.sumAxis(bTgt,1,false);
const logp=ops.sub(tg,lse);
// reference: dense logits via quantizedMatmul + logsumexp
const ref=ops.quantizedMatmul(x,w,scales,biases,{bits:BITS,groupSize:GS,mode:"affine"} as any,true);
const reflse=ops.logsumexpAxis(ref,-1,false);
const tcol=MlxArray.fromView(new Uint8Array(new Int32Array(targets).buffer.slice(0)),[M,1],Dtype.int32);
const reftgt=ops.reshape(ops.takeAlongAxis(ref,tcol,-1),[M]);
const reflogp=ops.sub(reftgt,reflse);
evalAll([logp,reflogp]);
const a=logp.toFloat32(), b=reflogp.toFloat32();
let md=0,mr=0; for(let i=0;i<M;i++){md=Math.max(md,Math.abs(a[i]!-b[i]!)); mr=Math.max(mr,Math.abs(b[i]!));}
console.log(`### steel-fwd logp vs reference: maxAbs=${md.toExponential(3)} (logp mag ${mr.toFixed(3)}) → ${md/mr<2e-3?"PASS":"FAIL"}`);
