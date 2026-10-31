import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC101
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl101`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl101 : List Nat := [2665, 2673467, 2753835]
def PRE_first_tail_x15_r0_body.clo101 : List Nat := []
def PRE_first_tail_x15_r0_body.cln101 : List Nat := []
def PRE_first_tail_x15_r0_body.cli101 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap101 : PRE_first_tail_x15_r0_body.s894.heap = Stage.setAll PRE_first_tail_x15_r0_body.s892.heap (PRE_first_tail_x15_r0_body.cl101.filterMap fun a => (PRE_first_tail_x15_r0_body.s894.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe101 : Nat.ble PRE_first_tail_x15_r0_body.s892.next PRE_first_tail_x15_r0_body.s894.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP101 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s892 PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp101 : Conv.suppListB PRE_first_tail_x15_r0_body.s894 4372 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound101 : Conv.boundListB PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.cl101 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK101 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s892.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli101.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst101 : Conv.sstListB 4372 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s894.ffi).mlx PRE_first_tail_x15_r0_body.cln101 PRE_first_tail_x15_r0_body.clo101 PRE_first_tail_x15_r0_body.cli101 = true

end Host.Load.Run.Tpl
