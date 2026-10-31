import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC85
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl85`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl85 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo85 : List Nat := []
def PRE_first_tail_x15_r0_body.cln85 : List Nat := []
def PRE_first_tail_x15_r0_body.cli85 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap85 : PRE_first_tail_x15_r0_body.s831.heap = Stage.setAll PRE_first_tail_x15_r0_body.s829.heap (PRE_first_tail_x15_r0_body.cl85.filterMap fun a => (PRE_first_tail_x15_r0_body.s831.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe85 : Nat.ble PRE_first_tail_x15_r0_body.s829.next PRE_first_tail_x15_r0_body.s831.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP85 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp85 : Conv.suppListB PRE_first_tail_x15_r0_body.s831 3713 PRE_first_tail_x15_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound85 : Conv.boundListB PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.cl85 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK85 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s829.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli85.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst85 : Conv.sstListB 3713 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s831.ffi).mlx PRE_first_tail_x15_r0_body.cln85 PRE_first_tail_x15_r0_body.clo85 PRE_first_tail_x15_r0_body.cli85 = true

end Host.Load.Run.Tpl
