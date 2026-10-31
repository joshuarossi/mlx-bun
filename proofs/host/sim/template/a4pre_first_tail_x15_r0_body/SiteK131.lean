import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC131
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl131`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl131 : List Nat := [2665, 2673467, 2777541]
def PRE_first_tail_x15_r0_body.clo131 : List Nat := []
def PRE_first_tail_x15_r0_body.cln131 : List Nat := []
def PRE_first_tail_x15_r0_body.cli131 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap131 : PRE_first_tail_x15_r0_body.s1155.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1153.heap (PRE_first_tail_x15_r0_body.cl131.filterMap fun a => (PRE_first_tail_x15_r0_body.s1155.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe131 : Nat.ble PRE_first_tail_x15_r0_body.s1153.next PRE_first_tail_x15_r0_body.s1155.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP131 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1153 PRE_first_tail_x15_r0_body.s1155 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp131 : Conv.suppListB PRE_first_tail_x15_r0_body.s1155 5653 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound131 : Conv.boundListB PRE_first_tail_x15_r0_body.s1155 PRE_first_tail_x15_r0_body.cl131 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK131 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1153.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli131.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst131 : Conv.sstListB 5653 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1155.ffi).mlx PRE_first_tail_x15_r0_body.cln131 PRE_first_tail_x15_r0_body.clo131 PRE_first_tail_x15_r0_body.cli131 = true

end Host.Load.Run.Tpl
