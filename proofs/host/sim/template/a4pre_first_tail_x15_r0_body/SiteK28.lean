import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC28
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl28`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl28 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo28 : List Nat := []
def PRE_first_tail_x15_r0_body.cln28 : List Nat := []
def PRE_first_tail_x15_r0_body.cli28 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap28 : PRE_first_tail_x15_r0_body.s285.heap = Stage.setAll PRE_first_tail_x15_r0_body.s283.heap (PRE_first_tail_x15_r0_body.cl28.filterMap fun a => (PRE_first_tail_x15_r0_body.s285.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe28 : Nat.ble PRE_first_tail_x15_r0_body.s283.next PRE_first_tail_x15_r0_body.s285.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP28 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s283 PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp28 : Conv.suppListB PRE_first_tail_x15_r0_body.s285 1277 PRE_first_tail_x15_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound28 : Conv.boundListB PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.cl28 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK28 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s283.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK28 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s283.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK28 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s283.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli28.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst28 : Conv.sstListB 1277 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s285.ffi).mlx PRE_first_tail_x15_r0_body.cln28 PRE_first_tail_x15_r0_body.clo28 PRE_first_tail_x15_r0_body.cli28 = true

end Host.Load.Run.Tpl
