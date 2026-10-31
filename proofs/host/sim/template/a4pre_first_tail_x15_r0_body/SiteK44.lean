import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC44
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl44`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl44 : List Nat := [2665, 2673467, 2709003]
def PRE_first_tail_x15_r0_body.clo44 : List Nat := []
def PRE_first_tail_x15_r0_body.cln44 : List Nat := []
def PRE_first_tail_x15_r0_body.cli44 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap44 : PRE_first_tail_x15_r0_body.s433.heap = Stage.setAll PRE_first_tail_x15_r0_body.s431.heap (PRE_first_tail_x15_r0_body.cl44.filterMap fun a => (PRE_first_tail_x15_r0_body.s433.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe44 : Nat.ble PRE_first_tail_x15_r0_body.s431.next PRE_first_tail_x15_r0_body.s433.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP44 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s431 PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp44 : Conv.suppListB PRE_first_tail_x15_r0_body.s433 1936 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound44 : Conv.boundListB PRE_first_tail_x15_r0_body.s433 PRE_first_tail_x15_r0_body.cl44 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK44 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s431.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli44.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst44 : Conv.sstListB 1936 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s433.ffi).mlx PRE_first_tail_x15_r0_body.cln44 PRE_first_tail_x15_r0_body.clo44 PRE_first_tail_x15_r0_body.cli44 = true

end Host.Load.Run.Tpl
