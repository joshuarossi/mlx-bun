import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC69
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl69`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl69 : List Nat := [2665, 2672477, 2673467, 2729580, 2729581, 2729582, 2729583, 2729584, 2729585, 2729586, 2729587, 2729588, 2729589, 2729590, 2729591, 2729592, 2729593, 2729594]
def PRE_first_tail_x15_r0_body.clo69 : List Nat := [19573, 19574, 19575, 19576]
def PRE_first_tail_x15_r0_body.cln69 : List Nat := [16661, 16662, 16663, 16664, 16665, 16666]
def PRE_first_tail_x15_r0_body.cli69 : List Nat := [16661, 16662, 16663, 16664, 16665, 16666]
kernel_rfl PRE_first_tail_x15_r0_body.cheap69 : PRE_first_tail_x15_r0_body.s619.heap = Stage.setAll PRE_first_tail_x15_r0_body.s617.heap (PRE_first_tail_x15_r0_body.cl69.filterMap fun a => (PRE_first_tail_x15_r0_body.s619.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe69 : Nat.ble PRE_first_tail_x15_r0_body.s617.next PRE_first_tail_x15_r0_body.s619.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP69 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s617 PRE_first_tail_x15_r0_body.s619 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp69 : Conv.suppListB PRE_first_tail_x15_r0_body.s619 3048 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound69 : Conv.boundListB PRE_first_tail_x15_r0_body.s619 PRE_first_tail_x15_r0_body.cl69 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK69 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s617.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli69.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst69 : Conv.sstListB 3048 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s619.ffi).mlx PRE_first_tail_x15_r0_body.cln69 PRE_first_tail_x15_r0_body.clo69 PRE_first_tail_x15_r0_body.cli69 = true

end Host.Load.Run.Tpl
