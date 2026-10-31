import host.sim.template.a4pre_first_tail_x15_r0.SiteC1
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0.cl1`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0.cl1 : List Nat := [2665, 2673457]
def PRE_first_tail_x15_r0.clo1 : List Nat := []
def PRE_first_tail_x15_r0.cln1 : List Nat := []
def PRE_first_tail_x15_r0.cli1 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0.cheap1 : PRE_first_tail_x15_r0.s19.heap = Stage.setAll PRE_first_tail_x15_r0.s17.heap (PRE_first_tail_x15_r0.cl1.filterMap fun a => (PRE_first_tail_x15_r0.s19.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0.cnextLe1 : Nat.ble PRE_first_tail_x15_r0.s17.next PRE_first_tail_x15_r0.s19.next = true
kernel_rfl PRE_first_tail_x15_r0.ckeepP1 : Conv.keptPresentB PRE_first_tail_x15_r0.s17 PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.cl1 = true
kernel_rfl PRE_first_tail_x15_r0.csupp1 : Conv.suppListB PRE_first_tail_x15_r0.s19 15 PRE_first_tail_x15_r0.cl1 = true
kernel_rfl PRE_first_tail_x15_r0.cbound1 : Conv.boundListB PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.cl1 = true
kernel_rfl PRE_first_tail_x15_r0.cnodesK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.nodes (PRE_first_tail_x15_r0.cln1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.cobjsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.objs (PRE_first_tail_x15_r0.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.citemsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s17.ffi).mlx.items (PRE_first_tail_x15_r0.cli1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0.csst1 : Conv.sstListB 15 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0.s19.ffi).mlx PRE_first_tail_x15_r0.cln1 PRE_first_tail_x15_r0.clo1 PRE_first_tail_x15_r0.cli1 = true

end Host.Load.Run.Tpl
