import host.sim.template.a4pre_first_tail_x15_r0.SiteC0
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0.cl0`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0.cl0 : List Nat := [2665]
def PRE_first_tail_x15_r0.clo0 : List Nat := []
def PRE_first_tail_x15_r0.cln0 : List Nat := []
def PRE_first_tail_x15_r0.cli0 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.cheap0 : PRE_first_tail_x15_r0.s6.heap = Stage.setAll PRE_first_tail_x15_r0.s4.heap (PRE_first_tail_x15_r0.cl0.filterMap fun a => (PRE_first_tail_x15_r0.s6.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0.cnextLe0 : Nat.ble PRE_first_tail_x15_r0.s4.next PRE_first_tail_x15_r0.s6.next = true
kernel_rfl PRE_first_tail_x15_r0.ckeepP0 : Conv.keptPresentB PRE_first_tail_x15_r0.s4 PRE_first_tail_x15_r0.s6 PRE_first_tail_x15_r0.cl0 = true
kernel_rfl PRE_first_tail_x15_r0.csupp0 : Conv.suppListB PRE_first_tail_x15_r0.s6 10 PRE_first_tail_x15_r0.cl0 = true
kernel_rfl PRE_first_tail_x15_r0.cbound0 : Conv.boundListB PRE_first_tail_x15_r0.s6 PRE_first_tail_x15_r0.cl0 = true
kernel_rfl PRE_first_tail_x15_r0.cnodesK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.nodes (PRE_first_tail_x15_r0.cln0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.cobjsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.objs (PRE_first_tail_x15_r0.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.citemsK0 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s4.ffi).mlx.items (PRE_first_tail_x15_r0.cli0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.csst0 : Conv.sstListB 10 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s6.ffi).mlx PRE_first_tail_x15_r0.cln0 PRE_first_tail_x15_r0.clo0 PRE_first_tail_x15_r0.cli0 = true

end Host.Load.Run.Tpl
