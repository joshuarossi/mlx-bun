import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC2
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl2`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl2 : List Nat := [2665, 2673467, 2676053]
def PRE_first_tail_x15_r0_body.clo2 : List Nat := []
def PRE_first_tail_x15_r0_body.cln2 : List Nat := []
def PRE_first_tail_x15_r0_body.cli2 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap2 : PRE_first_tail_x15_r0_body.s27.heap = Stage.setAll PRE_first_tail_x15_r0_body.s25.heap (PRE_first_tail_x15_r0_body.cl2.filterMap fun a => (PRE_first_tail_x15_r0_body.s27.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe2 : Nat.ble PRE_first_tail_x15_r0_body.s25.next PRE_first_tail_x15_r0_body.s27.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP2 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s25 PRE_first_tail_x15_r0_body.s27 PRE_first_tail_x15_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp2 : Conv.suppListB PRE_first_tail_x15_r0_body.s27 139 PRE_first_tail_x15_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound2 : Conv.boundListB PRE_first_tail_x15_r0_body.s27 PRE_first_tail_x15_r0_body.cl2 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK2 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s25.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli2.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst2 : Conv.sstListB 139 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s27.ffi).mlx PRE_first_tail_x15_r0_body.cln2 PRE_first_tail_x15_r0_body.clo2 PRE_first_tail_x15_r0_body.cli2 = true

end Host.Load.Run.Tpl
