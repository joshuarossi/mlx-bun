import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC140
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl140`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl140 : List Nat := [2665, 2673467, 2784335]
def PRE_first_tail_x15_r0_body.clo140 : List Nat := []
def PRE_first_tail_x15_r0_body.cln140 : List Nat := []
def PRE_first_tail_x15_r0_body.cli140 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap140 : PRE_first_tail_x15_r0_body.s1236.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1234.heap (PRE_first_tail_x15_r0_body.cl140.filterMap fun a => (PRE_first_tail_x15_r0_body.s1236.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe140 : Nat.ble PRE_first_tail_x15_r0_body.s1234.next PRE_first_tail_x15_r0_body.s1236.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP140 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp140 : Conv.suppListB PRE_first_tail_x15_r0_body.s1236 6040 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound140 : Conv.boundListB PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1234.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst140 : Conv.sstListB 6040 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1236.ffi).mlx PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cli140 = true

end Host.Load.Run.Tpl
