import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC5
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl5`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl5 : List Nat := [2665, 2673467, 2678407]
def PRE_first_tail_x15_r0_body.clo5 : List Nat := []
def PRE_first_tail_x15_r0_body.cln5 : List Nat := []
def PRE_first_tail_x15_r0_body.cli5 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap5 : PRE_first_tail_x15_r0_body.s59.heap = Stage.setAll PRE_first_tail_x15_r0_body.s57.heap (PRE_first_tail_x15_r0_body.cl5.filterMap fun a => (PRE_first_tail_x15_r0_body.s59.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe5 : Nat.ble PRE_first_tail_x15_r0_body.s57.next PRE_first_tail_x15_r0_body.s59.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP5 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp5 : Conv.suppListB PRE_first_tail_x15_r0_body.s59 268 PRE_first_tail_x15_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound5 : Conv.boundListB PRE_first_tail_x15_r0_body.s59 PRE_first_tail_x15_r0_body.cl5 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK5 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s57.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli5.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst5 : Conv.sstListB 268 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s59.ffi).mlx PRE_first_tail_x15_r0_body.cln5 PRE_first_tail_x15_r0_body.clo5 PRE_first_tail_x15_r0_body.cli5 = true

end Host.Load.Run.Tpl
