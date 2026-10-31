import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC82
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl82`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl82 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo82 : List Nat := []
def PRE_first_tail_x15_r0_body.cln82 : List Nat := []
def PRE_first_tail_x15_r0_body.cli82 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap82 : PRE_first_tail_x15_r0_body.s731.heap = Stage.setAll PRE_first_tail_x15_r0_body.s729.heap (PRE_first_tail_x15_r0_body.cl82.filterMap fun a => (PRE_first_tail_x15_r0_body.s731.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe82 : Nat.ble PRE_first_tail_x15_r0_body.s729.next PRE_first_tail_x15_r0_body.s731.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP82 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s729 PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp82 : Conv.suppListB PRE_first_tail_x15_r0_body.s731 3584 PRE_first_tail_x15_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound82 : Conv.boundListB PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.cl82 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s729.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s729.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK82 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s729.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli82.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst82 : Conv.sstListB 3584 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s731.ffi).mlx PRE_first_tail_x15_r0_body.cln82 PRE_first_tail_x15_r0_body.clo82 PRE_first_tail_x15_r0_body.cli82 = true

end Host.Load.Run.Tpl
