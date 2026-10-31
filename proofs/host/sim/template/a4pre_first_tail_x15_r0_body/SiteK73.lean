import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC73
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl73`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl73 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo73 : List Nat := []
def PRE_first_tail_x15_r0_body.cln73 : List Nat := []
def PRE_first_tail_x15_r0_body.cli73 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap73 : PRE_first_tail_x15_r0_body.s716.heap = Stage.setAll PRE_first_tail_x15_r0_body.s714.heap (PRE_first_tail_x15_r0_body.cl73.filterMap fun a => (PRE_first_tail_x15_r0_body.s716.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe73 : Nat.ble PRE_first_tail_x15_r0_body.s714.next PRE_first_tail_x15_r0_body.s716.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP73 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp73 : Conv.suppListB PRE_first_tail_x15_r0_body.s716 3200 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound73 : Conv.boundListB PRE_first_tail_x15_r0_body.s716 PRE_first_tail_x15_r0_body.cl73 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK73 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s714.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli73.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst73 : Conv.sstListB 3200 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s716.ffi).mlx PRE_first_tail_x15_r0_body.cln73 PRE_first_tail_x15_r0_body.clo73 PRE_first_tail_x15_r0_body.cli73 = true

end Host.Load.Run.Tpl
