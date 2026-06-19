// Full steel backward (test dims, full-H staging): phase-1 BlockMMA logit→coeff, then
// phase-2 persistent BlockMMA dh += coeff@W accumulated over ALL vocab-tiles (one TG
// per token-block). Validate dh vs quantizedMatmul(coeff_ref, W, transpose=false).
import { MetalKernel } from "../../src/mlx/metal-kernel";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { evalAll } from "../../src/mlx/ops";
import { STEEL_QMM_HEADER } from "../../src/train/steel-qmm-header";
const M=64, H=128, V=256, GS=64, BITS=8, WPR=H*BITS/32, GR=H/GS;
const BODY = String.raw`
  const int Hh=(int)shp[0], Vv=(int)shp[1], Mm=(int)shp[2];
  constexpr int BM=8,BN=32,BK=32,WM=1,WN=4,gs=${GS},bts=${BITS},HH=${H};
  constexpr int pf=get_pack_factor<bts,8>(), bpp=get_bytes_per_pack<bts>(), BKp=BK+16/sizeof(float);
  threadgroup float Xs[BM*BKp]; threadgroup float Ws[BN*BKp]; threadgroup float Ls[BM*BN];
  threadgroup float coeffS[BM*BN]; threadgroup float Wd[BN*HH];   // dequant W[vocab,H] for phase-2
  using lmma_t=mlx::steel::BlockMMA<float,float,BM,BN,BK,WM,WN,false,true,BKp,BKp>;     // logit X@Wᵀ
  using dmma_t=mlx::steel::BlockMMA<float,float,BM,HH,BN,WM,WN,false,false,BN,HH>;       // dh coeff@W (BK=vocab)
  using lx_t=mlx::steel::BlockLoader<float,BM,BK,BKp,1,WM*WN*SIMD_SIZE>;
  using lw_t=QuantizedBlockLoader<float,BN,BK,BKp,1,WM*WN*SIMD_SIZE,gs,bts>;
  const uint tb=threadgroup_position_in_grid.z;
  const uint sg=simdgroup_index_in_threadgroup, sl=thread_index_in_simdgroup, lid=thread_position_in_threadgroup.x;
  const float cap=capv[0];
  const int K_w=Hh*bpp/pf, K_g=Hh/gs, tokBase=(int)tb*BM;
  dmma_t dmma(sg,sl);   // persistent dh accumulator (Ctile starts 0)
  for (int v0=0; v0<Vv; v0+=BN){
    lmma_t lmma(sg,sl);
    lx_t loader_x(x+(int64_t)tokBase*Hh, Hh, Xs, sg, sl);
    lw_t loader_w((const device uint8_t*)w+v0*K_w, scales+v0*K_g, biases+v0*K_g, Hh, Ws, sg, sl);
    for(int k=0;k<Hh;k+=BK){ threadgroup_barrier(mem_flags::mem_threadgroup); loader_x.load_unsafe(); loader_w.load_unsafe(); threadgroup_barrier(mem_flags::mem_threadgroup); lmma.mma(Xs,Ws); loader_x.next(); loader_w.next(); }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    lmma.Ctile.store<float,WM,WN,BN,1>(Ls + lmma.sm*BN + lmma.sn);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    // coeff epilogue into coeffS[BM,BN]
    if (lid<(uint)BM && tokBase+(int)lid<Mm){ uint b=lid; const float lseb=lse[tokBase+b], gb=gv[tokBase+b]; const uint tgt=targets[tokBase+b];
      for(int v=0;v<BN;++v){ int n=v0+v; float logit=Ls[b*BN+v],sech2=1.0f; if(cap>0.0f){float th=tanh(logit/cap);logit=cap*th;sech2=1.0f-th*th;} float sm=exp(logit-lseb); float c=(n<Vv)?gb*(((uint)n==tgt?1.0f:0.0f)-sm):0.0f; if(cap>0.0f)c*=sech2; coeffS[b*BN+v]=c; } }
    // dequant W[BN vocab, H] (non-transposed) for phase-2 — perWord=32/bits elems/uint32
    const uint perWord=32u/bts, wordsPerRow=(uint)Hh/perWord, qmask=(bts==32u)?0xffffffffu:((1u<<bts)-1u);
    for (uint i=lid; i<(uint)(BN*(int)wordsPerRow); i+=WM*WN*SIMD_SIZE){ uint vr=i/wordsPerRow, wi=i%wordsPerRow; uint n=v0+vr; uint dbase=wi*perWord; uint word=0u; float sc=0.0f,bi=0.0f; if((int)n<Vv){ word=((const device uint*)w)[n*WPRC + wi]; uint grp=dbase/gs; sc=scales[n*K_g+grp]; bi=biases[n*K_g+grp]; } for(uint kk=0;kk<perWord;++kk) Wd[vr*HH + dbase+kk]=sc*(float)((word>>(bts*kk))&qmask)+bi; }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    dmma.mma(coeffS, Wd);   // dh += coeff @ W  (accumulate over vocab-tiles)
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
  dmma.store_result(dh + (int64_t)tokBase*Hh, Hh);
`.replace(/WPRC/g, String(WPR));
const k=new MetalKernel({name:"steel_bwd",inputNames:["w","x","scales","biases","targets","lse","gv","shp","capv"],outputNames:["dh"],source:BODY,header:STEEL_QMM_HEADER,ensureRowContiguous:true});
const wHost=new Uint32Array(V*WPR).map(()=>(Math.random()*0xffffffff)>>>0);
const w=MlxArray.fromView(new Uint8Array(wHost.buffer.slice(0)),[V,WPR],Dtype.uint32);
const x=MlxArray.fromFloat32(new Float32Array(M*H).map(()=>-0.3+Math.random()*0.6),[M,H]);
const scales=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.02),[V,GR]);
const biases=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.0),[V,GR]);
const targets=Array.from({length:M},(_, i)=>(i*131+7)%V);
const tgt=MlxArray.fromView(new Uint8Array(new Uint32Array(targets).buffer.slice(0)),[M],Dtype.uint32);
const spec={bits:BITS,groupSize:GS,mode:"affine"} as any;
const refLogits=ops.quantizedMatmul(x,w,scales,biases,spec,true);
const lseRef=ops.logsumexpAxis(refLogits,-1,false);
const lse=MlxArray.fromFloat32(lseRef.toFloat32(),[M]);
const gv=MlxArray.fromFloat32(new Float32Array(M).fill(1),[M]);
const shp=MlxArray.fromView(new Uint8Array(new Uint32Array([H,V,M]).buffer.slice(0)),[3],Dtype.uint32);
const capv=MlxArray.fromFloat32(new Float32Array([0]),[1]);
const [dh]=k.apply([w,x,scales,biases,tgt,lse,gv,shp,capv],{outputs:[{shape:[M,H],dtype:Dtype.float32}],grid:[128,1,Math.ceil(M/8)],threadGroup:[128,1,1]});
// reference: coeff = onehot − softmax; dh_ref = quantizedMatmul(coeff, W, transpose=false)
const lseC=ops.reshape(lseRef,[M,1]); const sm=ops.exp(ops.sub(refLogits,lseC)); const smH=sm.toFloat32();
const coeffArr=new Float32Array(M*V); for(let i=0;i<M;i++)for(let n=0;n<V;n++)coeffArr[i*V+n]=(targets[i]===n?1:0)-smH[i*V+n]!;
const coeff=MlxArray.fromFloat32(coeffArr,[M,V]);
const dhRef=ops.quantizedMatmul(coeff,w,scales,biases,spec,false);
evalAll([dh,dhRef]);
const a=dh.toFloat32(), b=dhRef.toFloat32();
let md=0,mr=0; for(let i=0;i<M*H;i++){md=Math.max(md,Math.abs(a[i]!-b[i]!));mr=Math.max(mr,Math.abs(b[i]!));}
console.log(`### steel backward dh vs quantizedMatmul(coeff,W,t=false): maxAbs=${md.toExponential(3)} (max ${mr.toFixed(3)}) → ${md/mr<2e-3?"PASS":"FAIL"}`);
