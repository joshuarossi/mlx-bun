import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC16
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl16`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl16 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo16 : List Nat := []
def PRE_first_tail_x15_r0_body.cln16 : List Nat := []
def PRE_first_tail_x15_r0_body.cli16 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap16 : PRE_first_tail_x15_r0_body.s170.heap = Stage.setAll PRE_first_tail_x15_r0_body.s168.heap (PRE_first_tail_x15_r0_body.cl16.filterMap fun a => (PRE_first_tail_x15_r0_body.s170.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe16 : Nat.ble PRE_first_tail_x15_r0_body.s168.next PRE_first_tail_x15_r0_body.s170.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP16 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s168 PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp16 : Conv.suppListB PRE_first_tail_x15_r0_body.s170 764 PRE_first_tail_x15_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound16 : Conv.boundListB PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.cl16 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK16 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s168.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli16.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst16 : Conv.sstListB 764 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s170.ffi).mlx PRE_first_tail_x15_r0_body.cln16 PRE_first_tail_x15_r0_body.clo16 PRE_first_tail_x15_r0_body.cli16 = true

end Host.Load.Run.Tpl
