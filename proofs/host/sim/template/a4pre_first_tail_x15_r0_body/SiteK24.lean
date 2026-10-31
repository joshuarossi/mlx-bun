import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC24
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl24`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl24 : List Nat := [2665, 2672362, 2673467, 2693461, 2694006, 2694262, 2694287, 2694288, 2694289, 2694290, 2694291, 2694292]
def PRE_first_tail_x15_r0_body.clo24 : List Nat := [18668, 18681, 18687, 18688, 18689, 18690]
def PRE_first_tail_x15_r0_body.cln24 : List Nat := [15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15766, 15767, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15778]
def PRE_first_tail_x15_r0_body.cli24 : List Nat := [15752, 15753, 15754, 15755, 15756, 15757, 15758, 15759, 15760, 15761, 15762, 15763, 15764, 15765, 15766, 15767, 15768, 15769, 15770, 15771, 15772, 15773, 15774, 15775, 15776, 15777, 15778]
kernel_rfl PRE_first_tail_x15_r0_body.cheap24 : PRE_first_tail_x15_r0_body.s248.heap = Stage.setAll PRE_first_tail_x15_r0_body.s246.heap (PRE_first_tail_x15_r0_body.cl24.filterMap fun a => (PRE_first_tail_x15_r0_body.s248.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe24 : Nat.ble PRE_first_tail_x15_r0_body.s246.next PRE_first_tail_x15_r0_body.s248.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP24 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp24 : Conv.suppListB PRE_first_tail_x15_r0_body.s248 1127 PRE_first_tail_x15_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound24 : Conv.boundListB PRE_first_tail_x15_r0_body.s248 PRE_first_tail_x15_r0_body.cl24 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK24 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s246.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli24.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst24 : Conv.sstListB 1127 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s248.ffi).mlx PRE_first_tail_x15_r0_body.cln24 PRE_first_tail_x15_r0_body.clo24 PRE_first_tail_x15_r0_body.cli24 = true

end Host.Load.Run.Tpl
