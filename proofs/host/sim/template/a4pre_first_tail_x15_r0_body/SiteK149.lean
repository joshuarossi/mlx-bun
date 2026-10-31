import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC149
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl149`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl149 : List Nat := [2665, 2673467, 2791503]
def PRE_first_tail_x15_r0_body.clo149 : List Nat := []
def PRE_first_tail_x15_r0_body.cln149 : List Nat := []
def PRE_first_tail_x15_r0_body.cli149 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap149 : PRE_first_tail_x15_r0_body.s1439.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1437.heap (PRE_first_tail_x15_r0_body.cl149.filterMap fun a => (PRE_first_tail_x15_r0_body.s1439.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe149 : Nat.ble PRE_first_tail_x15_r0_body.s1437.next PRE_first_tail_x15_r0_body.s1439.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP149 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp149 : Conv.suppListB PRE_first_tail_x15_r0_body.s1439 6424 PRE_first_tail_x15_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound149 : Conv.boundListB PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.cl149 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1437.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1437.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK149 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1437.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli149.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst149 : Conv.sstListB 6424 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1439.ffi).mlx PRE_first_tail_x15_r0_body.cln149 PRE_first_tail_x15_r0_body.clo149 PRE_first_tail_x15_r0_body.cli149 = true

end Host.Load.Run.Tpl
