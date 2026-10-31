import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC14
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl14`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl14 : List Nat := [2665, 2673467, 2685659]
def PRE_first_tail_x15_r0_body.clo14 : List Nat := []
def PRE_first_tail_x15_r0_body.cln14 : List Nat := []
def PRE_first_tail_x15_r0_body.cli14 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap14 : PRE_first_tail_x15_r0_body.s132.heap = Stage.setAll PRE_first_tail_x15_r0_body.s130.heap (PRE_first_tail_x15_r0_body.cl14.filterMap fun a => (PRE_first_tail_x15_r0_body.s132.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe14 : Nat.ble PRE_first_tail_x15_r0_body.s130.next PRE_first_tail_x15_r0_body.s132.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP14 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s130 PRE_first_tail_x15_r0_body.s132 PRE_first_tail_x15_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp14 : Conv.suppListB PRE_first_tail_x15_r0_body.s132 652 PRE_first_tail_x15_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound14 : Conv.boundListB PRE_first_tail_x15_r0_body.s132 PRE_first_tail_x15_r0_body.cl14 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s130.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s130.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK14 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s130.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli14.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst14 : Conv.sstListB 652 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s132.ffi).mlx PRE_first_tail_x15_r0_body.cln14 PRE_first_tail_x15_r0_body.clo14 PRE_first_tail_x15_r0_body.cli14 = true

end Host.Load.Run.Tpl
