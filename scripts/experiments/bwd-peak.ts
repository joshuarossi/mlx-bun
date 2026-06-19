// Clean, isolated backward peak: forward → eval → RESET peak → backward → eval → peak.
// Single flash-CCE kernel call (no host loop), so peakMemory is trustworthy.
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { evalAll } from "../../src/mlx/ops";
import { resetPeakMemory, peakMemory, clearCache } from "../../src/mlx/ffi";
import { flashCceForward, flashCceBackward, type FlashCceHead } from "../../src/train/flash-cce";
const H=2560, V=262144, GS=64, BITS=8, WPR=H*BITS/32, GR=H/GS;   // e4b head
const gb=(b:number)=>`${(b/1e9).toFixed(3)} GB`;
const w=MlxArray.fromView(new Uint8Array(new Uint32Array(V*WPR).map(()=>(Math.random()*0xffffffff)>>>0).buffer.slice(0)),[V,WPR],Dtype.uint32);
const scales=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.02),[V,GR]);
const biases=MlxArray.fromFloat32(new Float32Array(V*GR).map(()=>0.0),[V,GR]);
const head:FlashCceHead={w,scales,biases,bits:BITS,groupSize:GS,softcap:30};
console.log(`### e4b head: weights ${gb(V*WPR*4 + V*GR*4*2)} (always resident)`);
for (const M of [512, 2048, 8192]) {
  const h=MlxArray.fromFloat32(new Float32Array(M*H).map(()=>-0.3+Math.random()*0.6),[M,H]);
  const targets=Array.from({length:M},(_, i)=>(i*2659+7)%V);
  const cot=new Array(M).fill(1/M);
  clearCache();
  const {lse,blockMax}=flashCceForward(h,head,targets); evalAll([lse,blockMax]);
  resetPeakMemory();                                  // <- peak only counts the backward
  const dh=flashCceBackward(h,head,targets,lse,cot,"0",blockMax,"0"); evalAll([dh]);
  console.log(`### M=${M}: backward peak ${gb(peakMemory())}  (h+dh = ${gb(2*M*H*4)})`);
  h.dispose(); lse.dispose(); blockMax.dispose(); dh.dispose();
}
