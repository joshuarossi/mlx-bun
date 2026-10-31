import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC107
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl107`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl107 : List Nat := [2665, 2673467, 2758717]
def PRE_first_tail_x15_r0_body.clo107 : List Nat := []
def PRE_first_tail_x15_r0_body.cln107 : List Nat := []
def PRE_first_tail_x15_r0_body.cli107 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap107 : PRE_first_tail_x15_r0_body.s1036.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1034.heap (PRE_first_tail_x15_r0_body.cl107.filterMap fun a => (PRE_first_tail_x15_r0_body.s1036.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe107 : Nat.ble PRE_first_tail_x15_r0_body.s1034.next PRE_first_tail_x15_r0_body.s1036.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP107 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1034 PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp107 : Conv.suppListB PRE_first_tail_x15_r0_body.s1036 4627 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound107 : Conv.boundListB PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.cl107 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK107 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1034.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli107.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst107 : Conv.sstListB 4627 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1036.ffi).mlx PRE_first_tail_x15_r0_body.cln107 PRE_first_tail_x15_r0_body.clo107 PRE_first_tail_x15_r0_body.cli107 = true

end Host.Load.Run.Tpl
