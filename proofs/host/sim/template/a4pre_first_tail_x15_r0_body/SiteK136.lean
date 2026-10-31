import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC136
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl136`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl136 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo136 : List Nat := []
def PRE_first_tail_x15_r0_body.cln136 : List Nat := []
def PRE_first_tail_x15_r0_body.cli136 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap136 : PRE_first_tail_x15_r0_body.s1320.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1318.heap (PRE_first_tail_x15_r0_body.cl136.filterMap fun a => (PRE_first_tail_x15_r0_body.s1320.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe136 : Nat.ble PRE_first_tail_x15_r0_body.s1318.next PRE_first_tail_x15_r0_body.s1320.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP136 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp136 : Conv.suppListB PRE_first_tail_x15_r0_body.s1320 5894 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound136 : Conv.boundListB PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst136 : Conv.sstListB 5894 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cli136 = true

end Host.Load.Run.Tpl
