import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC1
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl1`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl1 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo1 : List Nat := []
def PRE_first_tail_x15_r0_body.cln1 : List Nat := []
def PRE_first_tail_x15_r0_body.cli1 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap1 : PRE_first_tail_x15_r0_body.s23.heap = Stage.setAll PRE_first_tail_x15_r0_body.s21.heap (PRE_first_tail_x15_r0_body.cl1.filterMap fun a => (PRE_first_tail_x15_r0_body.s23.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe1 : Nat.ble PRE_first_tail_x15_r0_body.s21.next PRE_first_tail_x15_r0_body.s23.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP1 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp1 : Conv.suppListB PRE_first_tail_x15_r0_body.s23 122 PRE_first_tail_x15_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound1 : Conv.boundListB PRE_first_tail_x15_r0_body.s23 PRE_first_tail_x15_r0_body.cl1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s21.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s21.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK1 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s21.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli1.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst1 : Conv.sstListB 122 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s23.ffi).mlx PRE_first_tail_x15_r0_body.cln1 PRE_first_tail_x15_r0_body.clo1 PRE_first_tail_x15_r0_body.cli1 = true

end Host.Load.Run.Tpl
