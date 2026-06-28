// Loop the grid barrier N times (mimics the megakernel's ~200 barriers/step) with
// atomic scratch read across threadgroups each iter. Reproduces races the single-
// barrier probe misses. Each iter: tg writes iter to sc[tgid]; barrier; tg0 verifies
// all G entries == iter; barrier. bad>0 => race.
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
const TGN = Number(process.env.TGN || 256);
const G = Number(process.env.G || 4);
const N = Number(process.env.N || 500);
const HEADER = String.raw`
inline void grid_barrier(device atomic_uint* ga, device atomic_uint* gs, uint lid, int G, thread uint& e) {
  threadgroup_barrier(mem_flags::mem_device);
  e ^= 1u;
  if (lid==0) { uint old=atomic_fetch_add_explicit(ga,1u,memory_order_relaxed);
    if (old+1u==(uint)G){ atomic_store_explicit(ga,0u,memory_order_relaxed); atomic_store_explicit(gs,e,memory_order_relaxed); }
    else { while (atomic_load_explicit(gs,memory_order_relaxed)!=e){} } }
  threadgroup_barrier(mem_flags::mem_device);
}`;
const SRC = String.raw`
  const uint lid=thread_position_in_threadgroup.x;
  const uint tgid=threadgroup_position_in_grid.x;
  device atomic_uint* ga=(device atomic_uint*)&barr_a[0];
  device atomic_uint* gs=(device atomic_uint*)&barr_s[0];
  device atomic_uint* sc=(device atomic_uint*)scratch;
  uint e=0u; uint bad=0u;
  for (int it=1; it<=N_T; ++it) {
    if (lid==0) atomic_store_explicit(&sc[tgid], (uint)it, memory_order_relaxed);
    grid_barrier(ga,gs,lid,G_T,e);
    if (tgid==0 && lid==0) {
      for (int i=0;i<G_T;i++) if (atomic_load_explicit(&sc[i],memory_order_relaxed)!=(uint)it) bad++;
    }
    grid_barrier(ga,gs,lid,G_T,e);
  }
  if (tgid==0 && lid==0) out[0]=(float)bad;
`;
const k=new MetalKernel({name:"barr_loop",inputNames:["dummy"],outputNames:["out","scratch","barr_a","barr_s"],header:HEADER,source:SRC,ensureRowContiguous:true});
const dummy=MlxArray.fromFloat32(new Float32Array([0]),[1]);
function run(){ const [out]=k.apply([dummy],{outputs:[{shape:[1],dtype:Dtype.float32},{shape:[G],dtype:Dtype.uint32},{shape:[1],dtype:Dtype.uint32},{shape:[1],dtype:Dtype.uint32}],grid:[G*TGN,1,1],threadGroup:[TGN,1,1],templateInts:{G_T:G,N_T:N},initValue:0}); out!.eval(); const b=out!.toFloat32()[0]!; out!.dispose(); return b; }
const r1=run(), r2=run(), r3=run();
console.log(`G=${G} TGN=${TGN} N=${N}  bad: ${r1}, ${r2}, ${r3}  (0=barrier correct)`);
