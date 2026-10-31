import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC92
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl92`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl92 : List Nat := [2665, 2673467, 2746671]
def PRE_first_tail_x15_r0_body.clo92 : List Nat := []
def PRE_first_tail_x15_r0_body.cln92 : List Nat := []
def PRE_first_tail_x15_r0_body.cli92 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap92 : PRE_first_tail_x15_r0_body.s816.heap = Stage.setAll PRE_first_tail_x15_r0_body.s814.heap (PRE_first_tail_x15_r0_body.cl92.filterMap fun a => (PRE_first_tail_x15_r0_body.s816.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe92 : Nat.ble PRE_first_tail_x15_r0_body.s814.next PRE_first_tail_x15_r0_body.s816.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP92 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s814 PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp92 : Conv.suppListB PRE_first_tail_x15_r0_body.s816 3988 PRE_first_tail_x15_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound92 : Conv.boundListB PRE_first_tail_x15_r0_body.s816 PRE_first_tail_x15_r0_body.cl92 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK92 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK92 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK92 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s814.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli92.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst92 : Conv.sstListB 3988 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s816.ffi).mlx PRE_first_tail_x15_r0_body.cln92 PRE_first_tail_x15_r0_body.clo92 PRE_first_tail_x15_r0_body.cli92 = true

end Host.Load.Run.Tpl
