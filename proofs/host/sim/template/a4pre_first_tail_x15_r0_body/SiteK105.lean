import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC105
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl105`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl105 : List Nat := [2665, 2672570, 2673467, 2757832, 2757833, 2757834, 2757835, 2757836, 2757837, 2757838, 2757839, 2757840, 2757841, 2757842, 2757843, 2757844, 2757845, 2757846]
def PRE_first_tail_x15_r0_body.clo105 : List Nat := [20281, 20282, 20283, 20284]
def PRE_first_tail_x15_r0_body.cln105 : List Nat := [17372, 17373, 17374, 17375, 17376, 17377]
def PRE_first_tail_x15_r0_body.cli105 : List Nat := [17372, 17373, 17374, 17375, 17376, 17377]
kernel_rfl PRE_first_tail_x15_r0_body.cheap105 : PRE_first_tail_x15_r0_body.s1024.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1022.heap (PRE_first_tail_x15_r0_body.cl105.filterMap fun a => (PRE_first_tail_x15_r0_body.s1024.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe105 : Nat.ble PRE_first_tail_x15_r0_body.s1022.next PRE_first_tail_x15_r0_body.s1024.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP105 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp105 : Conv.suppListB PRE_first_tail_x15_r0_body.s1024 4587 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound105 : Conv.boundListB PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.cl105 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK105 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1022.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli105.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst105 : Conv.sstListB 4587 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1024.ffi).mlx PRE_first_tail_x15_r0_body.cln105 PRE_first_tail_x15_r0_body.clo105 PRE_first_tail_x15_r0_body.cli105 = true

end Host.Load.Run.Tpl
