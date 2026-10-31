import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC129
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl129`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl129 : List Nat := [2665, 2672632, 2673467, 2776656, 2776657, 2776658, 2776659, 2776660, 2776661, 2776662, 2776663, 2776664, 2776665, 2776666, 2776667, 2776668, 2776669, 2776670]
def PRE_first_tail_x15_r0_body.clo129 : List Nat := [20753, 20754, 20755, 20756]
def PRE_first_tail_x15_r0_body.cln129 : List Nat := [17846, 17847, 17848, 17849, 17850, 17851]
def PRE_first_tail_x15_r0_body.cli129 : List Nat := [17846, 17847, 17848, 17849, 17850, 17851]
kernel_rfl PRE_first_tail_x15_r0_body.cheap129 : PRE_first_tail_x15_r0_body.s1254.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1252.heap (PRE_first_tail_x15_r0_body.cl129.filterMap fun a => (PRE_first_tail_x15_r0_body.s1254.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe129 : Nat.ble PRE_first_tail_x15_r0_body.s1252.next PRE_first_tail_x15_r0_body.s1254.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP129 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp129 : Conv.suppListB PRE_first_tail_x15_r0_body.s1254 5613 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound129 : Conv.boundListB PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.cl129 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK129 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1252.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli129.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst129 : Conv.sstListB 5613 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1254.ffi).mlx PRE_first_tail_x15_r0_body.cln129 PRE_first_tail_x15_r0_body.clo129 PRE_first_tail_x15_r0_body.cli129 = true

end Host.Load.Run.Tpl
