// Software grid barrier probe v2: atomic load/store on the shared DATA (not just
// the barrier counters) to force device coherence across threadgroups.
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { MetalKernel } from "../../src/mlx/metal-kernel";
const TGN = Number(process.env.TGN || 1024);
const G = Number(process.env.G || 8);
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
    } else {
      while (atomic_load_explicit(g_sense, memory_order_relaxed) != expect) { }
    }
  }
  threadgroup_barrier(mem_flags::mem_device);
}
`;
const SRC = String.raw`
  const uint lid = thread_position_in_threadgroup.x;
  const uint tgid = threadgroup_position_in_grid.x;
  device atomic_uint* g_arrive = (device atomic_uint*)&barrier_arrive[0];
  device atomic_uint* g_sense  = (device atomic_uint*)&barrier_sense[0];
  device atomic_uint* sc = (device atomic_uint*)&scratch[0];
  uint expect = 0u;
  if (lid == 0) atomic_store_explicit(&sc[tgid], tgid, memory_order_relaxed);
  grid_barrier(g_arrive, g_sense, lid, G_T, expect);
  if (lid == 0) {
    uint s = 0u;
    for (int i=0;i<G_T;i++) s += atomic_load_explicit(&sc[i], memory_order_relaxed);
    out[tgid] = (float)s;
  }
`;
const k = new MetalKernel({
  name: "barrier_probe2",
  inputNames: ["dummy"],
  outputNames: ["out", "scratch", "barrier_arrive", "barrier_sense"],
  header: HEADER, source: SRC, ensureRowContiguous: true,
});
const dummy = MlxArray.fromFloat32(new Float32Array([0]), [1]);
const t0 = performance.now();
const [out] = k.apply([dummy], {
  outputs: [
    { shape: [G], dtype: Dtype.float32 },
    { shape: [G], dtype: Dtype.uint32 },
    { shape: [1], dtype: Dtype.uint32 },
    { shape: [1], dtype: Dtype.uint32 },
  ],
  grid: [G * TGN, 1, 1], threadGroup: [TGN, 1, 1],
  templateInts: { G_T: G }, initValue: 0,
});
out!.eval();
const dt = performance.now() - t0;
const v = Array.from(out!.toFloat32());
const expected = G * (G - 1) / 2;
const ok = v.every((x) => x === expected);
console.log(`G=${G} TGN=${TGN}  ${dt.toFixed(1)}ms  ${ok ? "OK" : "FAIL"}  out[0]=${v[0]} expected=${expected}${ok?"":"  out="+JSON.stringify(v.slice(0,16))}`);
