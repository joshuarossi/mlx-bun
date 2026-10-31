import host.sim.template.a4pre_first_tail_x15_r0_suffix.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_suffix.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_suffix.cl0 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_suffix.clo0 : List Nat := []
def PRE_first_tail_x15_r0_suffix.cln0 : List Nat := []
def PRE_first_tail_x15_r0_suffix.cli0 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_suffix.cheap0 : PRE_first_tail_x15_r0_suffix.s4.heap = Stage.setAll PRE_first_tail_x15_r0_suffix.s2.heap (PRE_first_tail_x15_r0_suffix.cl0.filterMap fun a => (PRE_first_tail_x15_r0_suffix.s4.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.cnextLe0 : Nat.ble PRE_first_tail_x15_r0_suffix.s2.next PRE_first_tail_x15_r0_suffix.s4.next = true
kernel_rfl PRE_first_tail_x15_r0_suffix.ckeepP0 : Conv.keptPresentB PRE_first_tail_x15_r0_suffix.s2 PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.csupp0 : Conv.suppListB PRE_first_tail_x15_r0_suffix.s4 8226 PRE_first_tail_x15_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cbound0 : Conv.boundListB PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.cl0 = true
kernel_rfl PRE_first_tail_x15_r0_suffix.cnodesK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.nodes (PRE_first_tail_x15_r0_suffix.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.cobjsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.objs (PRE_first_tail_x15_r0_suffix.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.citemsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s2.ffi).mlx.items (PRE_first_tail_x15_r0_suffix.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_suffix.csst0 : Conv.sstListB 8226 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_suffix.s4.ffi).mlx PRE_first_tail_x15_r0_suffix.cln0 PRE_first_tail_x15_r0_suffix.clo0 PRE_first_tail_x15_r0_suffix.cli0 = true

end Host.Load.Run.Tpl
