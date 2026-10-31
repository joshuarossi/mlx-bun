import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC112
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl112`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl112 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo112 : List Nat := []
def PRE_first_tail_x15_r0_body.cln112 : List Nat := []
def PRE_first_tail_x15_r0_body.cli112 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap112 : PRE_first_tail_x15_r0_body.s995.heap = Stage.setAll PRE_first_tail_x15_r0_body.s993.heap (PRE_first_tail_x15_r0_body.cl112.filterMap fun a => (PRE_first_tail_x15_r0_body.s995.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe112 : Nat.ble PRE_first_tail_x15_r0_body.s993.next PRE_first_tail_x15_r0_body.s995.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP112 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s993 PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp112 : Conv.suppListB PRE_first_tail_x15_r0_body.s995 4868 PRE_first_tail_x15_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound112 : Conv.boundListB PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.cl112 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK112 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s993.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK112 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s993.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK112 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s993.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli112.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst112 : Conv.sstListB 4868 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s995.ffi).mlx PRE_first_tail_x15_r0_body.cln112 PRE_first_tail_x15_r0_body.clo112 PRE_first_tail_x15_r0_body.cli112 = true

end Host.Load.Run.Tpl
