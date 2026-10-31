import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC37
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl37`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl37 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo37 : List Nat := []
def PRE_first_tail_x15_r0_body.cln37 : List Nat := []
def PRE_first_tail_x15_r0_body.cli37 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap37 : PRE_first_tail_x15_r0_body.s371.heap = Stage.setAll PRE_first_tail_x15_r0_body.s369.heap (PRE_first_tail_x15_r0_body.cl37.filterMap fun a => (PRE_first_tail_x15_r0_body.s371.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe37 : Nat.ble PRE_first_tail_x15_r0_body.s369.next PRE_first_tail_x15_r0_body.s371.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP37 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s369 PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp37 : Conv.suppListB PRE_first_tail_x15_r0_body.s371 1661 PRE_first_tail_x15_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound37 : Conv.boundListB PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.cl37 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK37 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s369.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli37.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst37 : Conv.sstListB 1661 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s371.ffi).mlx PRE_first_tail_x15_r0_body.cln37 PRE_first_tail_x15_r0_body.clo37 PRE_first_tail_x15_r0_body.cli37 = true

end Host.Load.Run.Tpl
