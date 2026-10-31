import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC74
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl74`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl74 : List Nat := [2665, 2673467, 2732743]
def PRE_first_tail_x15_r0_body.clo74 : List Nat := []
def PRE_first_tail_x15_r0_body.cln74 : List Nat := []
def PRE_first_tail_x15_r0_body.cli74 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap74 : PRE_first_tail_x15_r0_body.s657.heap = Stage.setAll PRE_first_tail_x15_r0_body.s655.heap (PRE_first_tail_x15_r0_body.cl74.filterMap fun a => (PRE_first_tail_x15_r0_body.s657.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe74 : Nat.ble PRE_first_tail_x15_r0_body.s655.next PRE_first_tail_x15_r0_body.s657.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP74 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s655 PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp74 : Conv.suppListB PRE_first_tail_x15_r0_body.s657 3217 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound74 : Conv.boundListB PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.cl74 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK74 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s655.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli74.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst74 : Conv.sstListB 3217 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s657.ffi).mlx PRE_first_tail_x15_r0_body.cln74 PRE_first_tail_x15_r0_body.clo74 PRE_first_tail_x15_r0_body.cli74 = true

end Host.Load.Run.Tpl
