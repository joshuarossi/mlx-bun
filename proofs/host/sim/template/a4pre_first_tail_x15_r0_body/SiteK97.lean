import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC97
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl97`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl97 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo97 : List Nat := []
def PRE_first_tail_x15_r0_body.cln97 : List Nat := []
def PRE_first_tail_x15_r0_body.cli97 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap97 : PRE_first_tail_x15_r0_body.s863.heap = Stage.setAll PRE_first_tail_x15_r0_body.s861.heap (PRE_first_tail_x15_r0_body.cl97.filterMap fun a => (PRE_first_tail_x15_r0_body.s863.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe97 : Nat.ble PRE_first_tail_x15_r0_body.s861.next PRE_first_tail_x15_r0_body.s863.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP97 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s861 PRE_first_tail_x15_r0_body.s863 PRE_first_tail_x15_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp97 : Conv.suppListB PRE_first_tail_x15_r0_body.s863 4226 PRE_first_tail_x15_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound97 : Conv.boundListB PRE_first_tail_x15_r0_body.s863 PRE_first_tail_x15_r0_body.cl97 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK97 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s861.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli97.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst97 : Conv.sstListB 4226 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s863.ffi).mlx PRE_first_tail_x15_r0_body.cln97 PRE_first_tail_x15_r0_body.clo97 PRE_first_tail_x15_r0_body.cli97 = true

end Host.Load.Run.Tpl
