import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC103
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl103`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl103 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo103 : List Nat := []
def PRE_first_tail_x15_r0_body.cln103 : List Nat := []
def PRE_first_tail_x15_r0_body.cli103 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap103 : PRE_first_tail_x15_r0_body.s1004.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1002.heap (PRE_first_tail_x15_r0_body.cl103.filterMap fun a => (PRE_first_tail_x15_r0_body.s1004.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe103 : Nat.ble PRE_first_tail_x15_r0_body.s1002.next PRE_first_tail_x15_r0_body.s1004.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP103 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp103 : Conv.suppListB PRE_first_tail_x15_r0_body.s1004 4484 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound103 : Conv.boundListB PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.cl103 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK103 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1002.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli103.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst103 : Conv.sstListB 4484 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1004.ffi).mlx PRE_first_tail_x15_r0_body.cln103 PRE_first_tail_x15_r0_body.clo103 PRE_first_tail_x15_r0_body.cli103 = true

end Host.Load.Run.Tpl
