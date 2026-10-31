import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC160
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl160`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl160 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo160 : List Nat := []
def PRE_first_tail_x15_r0_body.cln160 : List Nat := []
def PRE_first_tail_x15_r0_body.cli160 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap160 : PRE_first_tail_x15_r0_body.s1415.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1413.heap (PRE_first_tail_x15_r0_body.cl160.filterMap fun a => (PRE_first_tail_x15_r0_body.s1415.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe160 : Nat.ble PRE_first_tail_x15_r0_body.s1413.next PRE_first_tail_x15_r0_body.s1415.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP160 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1413 PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp160 : Conv.suppListB PRE_first_tail_x15_r0_body.s1415 6920 PRE_first_tail_x15_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound160 : Conv.boundListB PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.cl160 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK160 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1413.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli160.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst160 : Conv.sstListB 6920 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1415.ffi).mlx PRE_first_tail_x15_r0_body.cln160 PRE_first_tail_x15_r0_body.clo160 PRE_first_tail_x15_r0_body.cli160 = true

end Host.Load.Run.Tpl
