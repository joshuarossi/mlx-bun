import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC53
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl53`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl53 : List Nat := [2665, 2673467, 2716167]
def PRE_first_tail_x15_r0_body.clo53 : List Nat := []
def PRE_first_tail_x15_r0_body.cln53 : List Nat := []
def PRE_first_tail_x15_r0_body.cli53 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap53 : PRE_first_tail_x15_r0_body.s474.heap = Stage.setAll PRE_first_tail_x15_r0_body.s472.heap (PRE_first_tail_x15_r0_body.cl53.filterMap fun a => (PRE_first_tail_x15_r0_body.s474.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe53 : Nat.ble PRE_first_tail_x15_r0_body.s472.next PRE_first_tail_x15_r0_body.s474.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP53 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s472 PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp53 : Conv.suppListB PRE_first_tail_x15_r0_body.s474 2320 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound53 : Conv.boundListB PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.cl53 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK53 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s472.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli53.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst53 : Conv.sstListB 2320 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s474.ffi).mlx PRE_first_tail_x15_r0_body.cln53 PRE_first_tail_x15_r0_body.clo53 PRE_first_tail_x15_r0_body.cli53 = true

end Host.Load.Run.Tpl
