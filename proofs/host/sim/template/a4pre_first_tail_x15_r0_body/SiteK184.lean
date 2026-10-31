import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC184
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl184`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl184 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo184 : List Nat := []
def PRE_first_tail_x15_r0_body.cln184 : List Nat := []
def PRE_first_tail_x15_r0_body.cli184 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap184 : PRE_first_tail_x15_r0_body.s1625.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1623.heap (PRE_first_tail_x15_r0_body.cl184.filterMap fun a => (PRE_first_tail_x15_r0_body.s1625.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe184 : Nat.ble PRE_first_tail_x15_r0_body.s1623.next PRE_first_tail_x15_r0_body.s1625.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP184 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1623 PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp184 : Conv.suppListB PRE_first_tail_x15_r0_body.s1625 7946 PRE_first_tail_x15_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound184 : Conv.boundListB PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.cl184 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK184 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1623.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK184 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1623.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK184 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1623.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli184.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst184 : Conv.sstListB 7946 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1625.ffi).mlx PRE_first_tail_x15_r0_body.cln184 PRE_first_tail_x15_r0_body.clo184 PRE_first_tail_x15_r0_body.cli184 = true

end Host.Load.Run.Tpl
