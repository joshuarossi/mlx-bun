import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC151
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl151`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl151 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo151 : List Nat := []
def PRE_first_tail_x15_r0_body.cln151 : List Nat := []
def PRE_first_tail_x15_r0_body.cli151 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap151 : PRE_first_tail_x15_r0_body.s1464.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1462.heap (PRE_first_tail_x15_r0_body.cl151.filterMap fun a => (PRE_first_tail_x15_r0_body.s1464.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe151 : Nat.ble PRE_first_tail_x15_r0_body.s1462.next PRE_first_tail_x15_r0_body.s1464.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP151 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp151 : Conv.suppListB PRE_first_tail_x15_r0_body.s1464 6536 PRE_first_tail_x15_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound151 : Conv.boundListB PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.cl151 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK151 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1462.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli151.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst151 : Conv.sstListB 6536 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1464.ffi).mlx PRE_first_tail_x15_r0_body.cln151 PRE_first_tail_x15_r0_body.clo151 PRE_first_tail_x15_r0_body.cli151 = true

end Host.Load.Run.Tpl
