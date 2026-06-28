// Does PLAIN (non-atomic) float device scratch become coherent across the working
// atomic-counter grid barrier? (The megakernel's shared state is float/bf16 data.)
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
const TGN = Number(process.env.TGN || 1024);
const G = Number(process.env.G || 16);
const VOL = process.env.VOL === "1" ? "volatile " : "";
const HEADER = String.raw`
inline void grid_barrier(device atomic_uint* g_arrive, device atomic_uint* g_sense,
                         uint lid, int G, thread uint& expect) {
  threadgroup_barrier(mem_flags::mem_device);
  expect ^= 1u;
  if (lid == 0) {
    uint old = atomic_fetch_add_explicit(g_arrive, 1u, memory_order_relaxed);
    if (old + 1u == (uint)G) {
      atomic_store_explicit(g_arrive, 0u, memory_order_relaxed);
      atomic_store_explicit(g_sense, expect, memory_order_relaxed);
    } else { while (atomic_load_explicit(g_sense, memory_order_relaxed) != expect) {} }
  }
  threadgroup_barrier(mem_flags::mem_device);
}
`;
const SRC = String.raw`
  const uint lid = thread_position_in_threadgroup.x;
  const uint tgid = threadgroup_position_in_grid.x;
  device atomic_uint* g_arrive = (device atomic_uint*)&barrier_arrive[0];
  device atomic_uint* g_sense  = (device atomic_uint*)&barrier_sense[0];
  ${VOL}device float* sc = (${VOL}device float*)scratch;
  uint expect = 0u;
  if (lid == 0) sc[tgid] = (float)tgid + 0.5f;   // plain write
  grid_barrier(g_arrive, g_sense, lid, G_T, expect);
  if (lid == 0) {
    float s = 0.0f;
    for (int i=0;i<G_T;i++) s += sc[i];           // plain read
    out[tgid] = s;
  }
`;
const k = new MetalKernel({ name:"barrier_probe3", inputNames:["dummy"],
  outputNames:["out","scratch","barrier_arrive","barrier_sense"], header:HEADER, source:SRC, ensureRowContiguous:true });
const dummy = MlxArray.fromFloat32(new Float32Array([0]),[1]);
const [out] = k.apply([dummy], { outputs:[
  {shape:[G],dtype:Dtype.float32},{shape:[G],dtype:Dtype.float32},
  {shape:[1],dtype:Dtype.uint32},{shape:[1],dtype:Dtype.uint32}],
  grid:[G*TGN,1,1], threadGroup:[TGN,1,1], templateInts:{G_T:G}, initValue:0 });
out!.eval();
const v = Array.from(out!.toFloat32());
const expected = Array.from({length:G},(_,i)=>i+0.5).reduce((a,b)=>a+b,0);
const ok = v.every((x)=>Math.abs(x-expected)<1e-3);
console.log(`G=${G} TGN=${TGN} VOL=${process.env.VOL||0}  ${ok?"OK":"FAIL"}  out[0]=${v[0]} expected=${expected}${ok?"":" out="+JSON.stringify(v.slice(0,16))}`);
