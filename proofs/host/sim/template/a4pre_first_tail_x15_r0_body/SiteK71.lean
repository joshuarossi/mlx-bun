import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC71
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl71`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl71 : List Nat := [2665, 2673467, 2730465]
def PRE_first_tail_x15_r0_body.clo71 : List Nat := []
def PRE_first_tail_x15_r0_body.cln71 : List Nat := []
def PRE_first_tail_x15_r0_body.cli71 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap71 : PRE_first_tail_x15_r0_body.s691.heap = Stage.setAll PRE_first_tail_x15_r0_body.s689.heap (PRE_first_tail_x15_r0_body.cl71.filterMap fun a => (PRE_first_tail_x15_r0_body.s691.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe71 : Nat.ble PRE_first_tail_x15_r0_body.s689.next PRE_first_tail_x15_r0_body.s691.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP71 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp71 : Conv.suppListB PRE_first_tail_x15_r0_body.s691 3088 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound71 : Conv.boundListB PRE_first_tail_x15_r0_body.s691 PRE_first_tail_x15_r0_body.cl71 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK71 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s689.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli71.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst71 : Conv.sstListB 3088 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s691.ffi).mlx PRE_first_tail_x15_r0_body.cln71 PRE_first_tail_x15_r0_body.clo71 PRE_first_tail_x15_r0_body.cli71 = true

end Host.Load.Run.Tpl
