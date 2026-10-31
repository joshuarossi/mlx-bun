import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC110
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl110`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl110 : List Nat := [2665, 2673467, 2760995]
def PRE_first_tail_x15_r0_body.clo110 : List Nat := []
def PRE_first_tail_x15_r0_body.cln110 : List Nat := []
def PRE_first_tail_x15_r0_body.cli110 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap110 : PRE_first_tail_x15_r0_body.s1065.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1063.heap (PRE_first_tail_x15_r0_body.cl110.filterMap fun a => (PRE_first_tail_x15_r0_body.s1065.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe110 : Nat.ble PRE_first_tail_x15_r0_body.s1063.next PRE_first_tail_x15_r0_body.s1065.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP110 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1063 PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp110 : Conv.suppListB PRE_first_tail_x15_r0_body.s1065 4756 PRE_first_tail_x15_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound110 : Conv.boundListB PRE_first_tail_x15_r0_body.s1065 PRE_first_tail_x15_r0_body.cl110 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK110 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1063.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli110.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst110 : Conv.sstListB 4756 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1065.ffi).mlx PRE_first_tail_x15_r0_body.cln110 PRE_first_tail_x15_r0_body.clo110 PRE_first_tail_x15_r0_body.cli110 = true

end Host.Load.Run.Tpl
