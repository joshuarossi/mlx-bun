// Time the pure grid-barrier overhead: B barriers, G threadgroups, no real work.
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
const TGN=Number(process.env.TGN||256), G=Number(process.env.G||24), B=Number(process.env.B||194);
const HEADER=String.raw`
inline void gb(device atomic_uint* ga, device atomic_uint* gs, uint lid, int G, thread uint& e){
  threadgroup_barrier(mem_flags::mem_device); e^=1u;
  if(lid==0){ uint o=atomic_fetch_add_explicit(ga,1u,memory_order_relaxed);
    if(o+1u==(uint)G){atomic_store_explicit(ga,0u,memory_order_relaxed);atomic_store_explicit(gs,e,memory_order_relaxed);}
    else{while(atomic_load_explicit(gs,memory_order_relaxed)!=e){}} }
  threadgroup_barrier(mem_flags::mem_device); }`;
const SRC=String.raw`
  const uint lid=thread_position_in_threadgroup.x; uint e=0u;
  device atomic_uint* ga=(device atomic_uint*)&ba[0]; device atomic_uint* gs=(device atomic_uint*)&bs[0];
  for(int i=0;i<B_T;i++) gb(ga,gs,lid,G_T,e);
  if(lid==0) out[0]=1.0f;`;
const k=new MetalKernel({name:"barrtime",inputNames:["d"],outputNames:["out","ba","bs"],header:HEADER,source:SRC,ensureRowContiguous:true});
const d=MlxArray.fromFloat32(new Float32Array([0]),[1]);
function once(){ const t0=performance.now(); const [o]=k.apply([d],{outputs:[{shape:[1],dtype:Dtype.float32},{shape:[1],dtype:Dtype.uint32},{shape:[1],dtype:Dtype.uint32}],grid:[G*TGN,1,1],threadGroup:[TGN,1,1],templateInts:{G_T:G,B_T:B},initValue:0}); o!.eval(); const dt=performance.now()-t0; o!.dispose(); return dt; }
once(); // warm
let s=0; const R=20; for(let i=0;i<R;i++) s+=once();
console.log(`G=${G} B=${B}: ${(s/R).toFixed(2)}ms for ${B} barriers = ${(s/R/B*1000).toFixed(1)}us/barrier  (megakernel does ~194/token)`);
