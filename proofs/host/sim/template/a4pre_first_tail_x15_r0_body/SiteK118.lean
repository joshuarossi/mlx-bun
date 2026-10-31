import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC118
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl118`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl118 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo118 : List Nat := []
def PRE_first_tail_x15_r0_body.cln118 : List Nat := []
def PRE_first_tail_x15_r0_body.cli118 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap118 : PRE_first_tail_x15_r0_body.s1046.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1044.heap (PRE_first_tail_x15_r0_body.cl118.filterMap fun a => (PRE_first_tail_x15_r0_body.s1046.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe118 : Nat.ble PRE_first_tail_x15_r0_body.s1044.next PRE_first_tail_x15_r0_body.s1046.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP118 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1044 PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp118 : Conv.suppListB PRE_first_tail_x15_r0_body.s1046 5123 PRE_first_tail_x15_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound118 : Conv.boundListB PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.cl118 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK118 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1044.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK118 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1044.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK118 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1044.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli118.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst118 : Conv.sstListB 5123 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1046.ffi).mlx PRE_first_tail_x15_r0_body.cln118 PRE_first_tail_x15_r0_body.clo118 PRE_first_tail_x15_r0_body.cli118 = true

end Host.Load.Run.Tpl
