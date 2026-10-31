import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC58
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl58`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl58 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo58 : List Nat := []
def PRE_first_tail_x15_r0_body.cln58 : List Nat := []
def PRE_first_tail_x15_r0_body.cli58 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap58 : PRE_first_tail_x15_r0_body.s521.heap = Stage.setAll PRE_first_tail_x15_r0_body.s519.heap (PRE_first_tail_x15_r0_body.cl58.filterMap fun a => (PRE_first_tail_x15_r0_body.s521.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe58 : Nat.ble PRE_first_tail_x15_r0_body.s519.next PRE_first_tail_x15_r0_body.s521.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP58 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp58 : Conv.suppListB PRE_first_tail_x15_r0_body.s521 2558 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound58 : Conv.boundListB PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.cl58 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK58 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s519.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli58.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst58 : Conv.sstListB 2558 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s521.ffi).mlx PRE_first_tail_x15_r0_body.cln58 PRE_first_tail_x15_r0_body.clo58 PRE_first_tail_x15_r0_body.cli58 = true

end Host.Load.Run.Tpl
