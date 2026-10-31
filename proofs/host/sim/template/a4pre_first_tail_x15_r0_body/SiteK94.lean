import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC94
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl94`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl94 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo94 : List Nat := []
def PRE_first_tail_x15_r0_body.cln94 : List Nat := []
def PRE_first_tail_x15_r0_body.cli94 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap94 : PRE_first_tail_x15_r0_body.s917.heap = Stage.setAll PRE_first_tail_x15_r0_body.s915.heap (PRE_first_tail_x15_r0_body.cl94.filterMap fun a => (PRE_first_tail_x15_r0_body.s917.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe94 : Nat.ble PRE_first_tail_x15_r0_body.s915.next PRE_first_tail_x15_r0_body.s917.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP94 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s915 PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp94 : Conv.suppListB PRE_first_tail_x15_r0_body.s917 4097 PRE_first_tail_x15_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound94 : Conv.boundListB PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.cl94 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK94 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK94 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK94 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s915.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli94.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst94 : Conv.sstListB 4097 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s917.ffi).mlx PRE_first_tail_x15_r0_body.cln94 PRE_first_tail_x15_r0_body.clo94 PRE_first_tail_x15_r0_body.cli94 = true

end Host.Load.Run.Tpl
