import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC145
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl145`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl145 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo145 : List Nat := []
def PRE_first_tail_x15_r0_body.cln145 : List Nat := []
def PRE_first_tail_x15_r0_body.cli145 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap145 : PRE_first_tail_x15_r0_body.s1406.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1404.heap (PRE_first_tail_x15_r0_body.cl145.filterMap fun a => (PRE_first_tail_x15_r0_body.s1406.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe145 : Nat.ble PRE_first_tail_x15_r0_body.s1404.next PRE_first_tail_x15_r0_body.s1406.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP145 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1404 PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp145 : Conv.suppListB PRE_first_tail_x15_r0_body.s1406 6278 PRE_first_tail_x15_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound145 : Conv.boundListB PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.cl145 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK145 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1404.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli145.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst145 : Conv.sstListB 6278 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx PRE_first_tail_x15_r0_body.cln145 PRE_first_tail_x15_r0_body.clo145 PRE_first_tail_x15_r0_body.cli145 = true

end Host.Load.Run.Tpl
