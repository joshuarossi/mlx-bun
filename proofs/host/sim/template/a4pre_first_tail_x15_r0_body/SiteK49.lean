import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC49
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl49`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl49 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo49 : List Nat := []
def PRE_first_tail_x15_r0_body.cln49 : List Nat := []
def PRE_first_tail_x15_r0_body.cli49 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap49 : PRE_first_tail_x15_r0_body.s486.heap = Stage.setAll PRE_first_tail_x15_r0_body.s484.heap (PRE_first_tail_x15_r0_body.cl49.filterMap fun a => (PRE_first_tail_x15_r0_body.s486.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe49 : Nat.ble PRE_first_tail_x15_r0_body.s484.next PRE_first_tail_x15_r0_body.s486.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP49 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp49 : Conv.suppListB PRE_first_tail_x15_r0_body.s486 2174 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound49 : Conv.boundListB PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.cl49 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK49 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s484.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli49.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst49 : Conv.sstListB 2174 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s486.ffi).mlx PRE_first_tail_x15_r0_body.cln49 PRE_first_tail_x15_r0_body.clo49 PRE_first_tail_x15_r0_body.cli49 = true

end Host.Load.Run.Tpl
