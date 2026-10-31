import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC128
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl128`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl128 : List Nat := [2665, 2673467, 2774919]
def PRE_first_tail_x15_r0_body.clo128 : List Nat := []
def PRE_first_tail_x15_r0_body.cln128 : List Nat := []
def PRE_first_tail_x15_r0_body.cli128 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap128 : PRE_first_tail_x15_r0_body.s1131.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1129.heap (PRE_first_tail_x15_r0_body.cl128.filterMap fun a => (PRE_first_tail_x15_r0_body.s1131.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe128 : Nat.ble PRE_first_tail_x15_r0_body.s1129.next PRE_first_tail_x15_r0_body.s1131.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP128 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1129 PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp128 : Conv.suppListB PRE_first_tail_x15_r0_body.s1131 5527 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound128 : Conv.boundListB PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.cl128 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1129.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1129.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK128 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1129.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli128.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst128 : Conv.sstListB 5527 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1131.ffi).mlx PRE_first_tail_x15_r0_body.cln128 PRE_first_tail_x15_r0_body.clo128 PRE_first_tail_x15_r0_body.cli128 = true

end Host.Load.Run.Tpl
