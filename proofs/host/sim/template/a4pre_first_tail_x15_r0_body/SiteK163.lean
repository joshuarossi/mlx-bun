import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC163
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl163`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl163 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo163 : List Nat := []
def PRE_first_tail_x15_r0_body.cln163 : List Nat := []
def PRE_first_tail_x15_r0_body.cli163 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap163 : PRE_first_tail_x15_r0_body.s1442.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1440.heap (PRE_first_tail_x15_r0_body.cl163.filterMap fun a => (PRE_first_tail_x15_r0_body.s1442.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe163 : Nat.ble PRE_first_tail_x15_r0_body.s1440.next PRE_first_tail_x15_r0_body.s1442.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP163 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1440 PRE_first_tail_x15_r0_body.s1442 PRE_first_tail_x15_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp163 : Conv.suppListB PRE_first_tail_x15_r0_body.s1442 7049 PRE_first_tail_x15_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound163 : Conv.boundListB PRE_first_tail_x15_r0_body.s1442 PRE_first_tail_x15_r0_body.cl163 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1440.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1440.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK163 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1440.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli163.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst163 : Conv.sstListB 7049 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1442.ffi).mlx PRE_first_tail_x15_r0_body.cln163 PRE_first_tail_x15_r0_body.clo163 PRE_first_tail_x15_r0_body.cli163 = true

end Host.Load.Run.Tpl
