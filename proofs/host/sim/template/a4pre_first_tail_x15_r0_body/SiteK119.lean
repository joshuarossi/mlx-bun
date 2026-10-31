import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC119
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl119`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl119 : List Nat := [2665, 2673467, 2768129]
def PRE_first_tail_x15_r0_body.clo119 : List Nat := []
def PRE_first_tail_x15_r0_body.cln119 : List Nat := []
def PRE_first_tail_x15_r0_body.cli119 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap119 : PRE_first_tail_x15_r0_body.s1050.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1048.heap (PRE_first_tail_x15_r0_body.cl119.filterMap fun a => (PRE_first_tail_x15_r0_body.s1050.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe119 : Nat.ble PRE_first_tail_x15_r0_body.s1048.next PRE_first_tail_x15_r0_body.s1050.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP119 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1048 PRE_first_tail_x15_r0_body.s1050 PRE_first_tail_x15_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp119 : Conv.suppListB PRE_first_tail_x15_r0_body.s1050 5140 PRE_first_tail_x15_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound119 : Conv.boundListB PRE_first_tail_x15_r0_body.s1050 PRE_first_tail_x15_r0_body.cl119 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1048.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1048.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK119 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1048.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli119.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst119 : Conv.sstListB 5140 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1050.ffi).mlx PRE_first_tail_x15_r0_body.cln119 PRE_first_tail_x15_r0_body.clo119 PRE_first_tail_x15_r0_body.cli119 = true

end Host.Load.Run.Tpl
