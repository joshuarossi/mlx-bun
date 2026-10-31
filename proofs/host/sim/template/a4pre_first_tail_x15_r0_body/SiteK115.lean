import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC115
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl115`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl115 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo115 : List Nat := []
def PRE_first_tail_x15_r0_body.cln115 : List Nat := []
def PRE_first_tail_x15_r0_body.cli115 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap115 : PRE_first_tail_x15_r0_body.s1022.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1020.heap (PRE_first_tail_x15_r0_body.cl115.filterMap fun a => (PRE_first_tail_x15_r0_body.s1022.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe115 : Nat.ble PRE_first_tail_x15_r0_body.s1020.next PRE_first_tail_x15_r0_body.s1022.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP115 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1020 PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp115 : Conv.suppListB PRE_first_tail_x15_r0_body.s1022 4997 PRE_first_tail_x15_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound115 : Conv.boundListB PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.cl115 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK115 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1020.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK115 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1020.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK115 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1020.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli115.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst115 : Conv.sstListB 4997 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx PRE_first_tail_x15_r0_body.cln115 PRE_first_tail_x15_r0_body.clo115 PRE_first_tail_x15_r0_body.cli115 = true

end Host.Load.Run.Tpl
