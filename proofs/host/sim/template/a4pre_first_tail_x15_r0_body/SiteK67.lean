import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC67
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl67`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl67 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo67 : List Nat := []
def PRE_first_tail_x15_r0_body.cln67 : List Nat := []
def PRE_first_tail_x15_r0_body.cli67 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap67 : PRE_first_tail_x15_r0_body.s602.heap = Stage.setAll PRE_first_tail_x15_r0_body.s600.heap (PRE_first_tail_x15_r0_body.cl67.filterMap fun a => (PRE_first_tail_x15_r0_body.s602.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe67 : Nat.ble PRE_first_tail_x15_r0_body.s600.next PRE_first_tail_x15_r0_body.s602.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP67 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s600 PRE_first_tail_x15_r0_body.s602 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp67 : Conv.suppListB PRE_first_tail_x15_r0_body.s602 2945 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound67 : Conv.boundListB PRE_first_tail_x15_r0_body.s602 PRE_first_tail_x15_r0_body.cl67 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK67 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s600.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli67.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst67 : Conv.sstListB 2945 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s602.ffi).mlx PRE_first_tail_x15_r0_body.cln67 PRE_first_tail_x15_r0_body.clo67 PRE_first_tail_x15_r0_body.cli67 = true

end Host.Load.Run.Tpl
