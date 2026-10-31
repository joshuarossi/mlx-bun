import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC135
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl135`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl135 : List Nat := [2665, 2672646, 2673467, 2780465, 2781010, 2781266, 2781291, 2781292, 2781293, 2781294, 2781295, 2781296]
def PRE_first_tail_x15_r0_body.clo135 : List Nat := [20849, 20862, 20868, 20869, 20870, 20871]
def PRE_first_tail_x15_r0_body.cln135 : List Nat := [17948, 17949, 17950, 17951, 17952, 17953, 17954, 17955, 17956, 17957, 17958, 17959, 17960, 17961, 17962, 17963, 17964, 17965, 17966, 17967, 17968, 17969, 17970, 17971, 17972, 17973, 17974]
def PRE_first_tail_x15_r0_body.cli135 : List Nat := [17948, 17949, 17950, 17951, 17952, 17953, 17954, 17955, 17956, 17957, 17958, 17959, 17960, 17961, 17962, 17963, 17964, 17965, 17966, 17967, 17968, 17969, 17970, 17971, 17972, 17973, 17974]
kernel_rfl PRE_first_tail_x15_r0_body.cheap135 : PRE_first_tail_x15_r0_body.s1312.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1310.heap (PRE_first_tail_x15_r0_body.cl135.filterMap fun a => (PRE_first_tail_x15_r0_body.s1312.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe135 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next PRE_first_tail_x15_r0_body.s1312.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP135 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp135 : Conv.suppListB PRE_first_tail_x15_r0_body.s1312 5873 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound135 : Conv.boundListB PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst135 : Conv.sstListB 5873 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cli135 = true

end Host.Load.Run.Tpl
