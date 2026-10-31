import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC70
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl70`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl70 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo70 : List Nat := []
def PRE_first_tail_x15_r0_body.cln70 : List Nat := []
def PRE_first_tail_x15_r0_body.cli70 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap70 : PRE_first_tail_x15_r0_body.s687.heap = Stage.setAll PRE_first_tail_x15_r0_body.s685.heap (PRE_first_tail_x15_r0_body.cl70.filterMap fun a => (PRE_first_tail_x15_r0_body.s687.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe70 : Nat.ble PRE_first_tail_x15_r0_body.s685.next PRE_first_tail_x15_r0_body.s687.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP70 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp70 : Conv.suppListB PRE_first_tail_x15_r0_body.s687 3071 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound70 : Conv.boundListB PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.cl70 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK70 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s685.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli70.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst70 : Conv.sstListB 3071 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s687.ffi).mlx PRE_first_tail_x15_r0_body.cln70 PRE_first_tail_x15_r0_body.clo70 PRE_first_tail_x15_r0_body.cli70 = true

end Host.Load.Run.Tpl
