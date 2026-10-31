import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC47
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl47`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl47 : List Nat := [2665, 2673467, 2711625]
def PRE_first_tail_x15_r0_body.clo47 : List Nat := []
def PRE_first_tail_x15_r0_body.cln47 : List Nat := []
def PRE_first_tail_x15_r0_body.cli47 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap47 : PRE_first_tail_x15_r0_body.s420.heap = Stage.setAll PRE_first_tail_x15_r0_body.s418.heap (PRE_first_tail_x15_r0_body.cl47.filterMap fun a => (PRE_first_tail_x15_r0_body.s420.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe47 : Nat.ble PRE_first_tail_x15_r0_body.s418.next PRE_first_tail_x15_r0_body.s420.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP47 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s418 PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp47 : Conv.suppListB PRE_first_tail_x15_r0_body.s420 2062 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound47 : Conv.boundListB PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.cl47 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK47 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s418.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli47.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst47 : Conv.sstListB 2062 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s420.ffi).mlx PRE_first_tail_x15_r0_body.cln47 PRE_first_tail_x15_r0_body.clo47 PRE_first_tail_x15_r0_body.cli47 = true

end Host.Load.Run.Tpl
