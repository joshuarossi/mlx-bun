import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC39
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl39`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl39 : List Nat := [2665, 2672398, 2673467, 2705133, 2705678, 2705934, 2705959, 2705960, 2705961, 2705962, 2705963, 2705964]
def PRE_first_tail_x15_r0_body.clo39 : List Nat := [18961, 18974, 18980, 18981, 18982, 18983]
def PRE_first_tail_x15_r0_body.cln39 : List Nat := [16052, 16053, 16054, 16055, 16056, 16057, 16058, 16059, 16060, 16061, 16062, 16063, 16064, 16065, 16066, 16067, 16068, 16069, 16070, 16071, 16072, 16073, 16074, 16075, 16076, 16077, 16078]
def PRE_first_tail_x15_r0_body.cli39 : List Nat := [16052, 16053, 16054, 16055, 16056, 16057, 16058, 16059, 16060, 16061, 16062, 16063, 16064, 16065, 16066, 16067, 16068, 16069, 16070, 16071, 16072, 16073, 16074, 16075, 16076, 16077, 16078]
kernel_rfl PRE_first_tail_x15_r0_body.cheap39 : PRE_first_tail_x15_r0_body.s392.heap = Stage.setAll PRE_first_tail_x15_r0_body.s390.heap (PRE_first_tail_x15_r0_body.cl39.filterMap fun a => (PRE_first_tail_x15_r0_body.s392.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe39 : Nat.ble PRE_first_tail_x15_r0_body.s390.next PRE_first_tail_x15_r0_body.s392.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP39 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s390 PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp39 : Conv.suppListB PRE_first_tail_x15_r0_body.s392 1769 PRE_first_tail_x15_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound39 : Conv.boundListB PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.cl39 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK39 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK39 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK39 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s390.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli39.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst39 : Conv.sstListB 1769 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s392.ffi).mlx PRE_first_tail_x15_r0_body.cln39 PRE_first_tail_x15_r0_body.clo39 PRE_first_tail_x15_r0_body.cli39 = true

end Host.Load.Run.Tpl
