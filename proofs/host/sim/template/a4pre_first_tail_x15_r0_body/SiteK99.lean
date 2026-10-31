import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC99
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl99`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl99 : List Nat := [2665, 2672553, 2673467, 2752225, 2752770, 2753026, 2753051, 2753052, 2753053, 2753054, 2753055, 2753056]
def PRE_first_tail_x15_r0_body.clo99 : List Nat := [20141, 20154, 20160, 20161, 20162, 20163]
def PRE_first_tail_x15_r0_body.cln99 : List Nat := [17237, 17238, 17239, 17240, 17241, 17242, 17243, 17244, 17245, 17246, 17247, 17248, 17249, 17250, 17251, 17252, 17253, 17254, 17255, 17256, 17257, 17258, 17259, 17260, 17261, 17262, 17263]
def PRE_first_tail_x15_r0_body.cli99 : List Nat := [17237, 17238, 17239, 17240, 17241, 17242, 17243, 17244, 17245, 17246, 17247, 17248, 17249, 17250, 17251, 17252, 17253, 17254, 17255, 17256, 17257, 17258, 17259, 17260, 17261, 17262, 17263]
kernel_rfl PRE_first_tail_x15_r0_body.cheap99 : PRE_first_tail_x15_r0_body.s967.heap = Stage.setAll PRE_first_tail_x15_r0_body.s965.heap (PRE_first_tail_x15_r0_body.cl99.filterMap fun a => (PRE_first_tail_x15_r0_body.s967.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe99 : Nat.ble PRE_first_tail_x15_r0_body.s965.next PRE_first_tail_x15_r0_body.s967.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP99 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s965 PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp99 : Conv.suppListB PRE_first_tail_x15_r0_body.s967 4334 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound99 : Conv.boundListB PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.cl99 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK99 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s965.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli99.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst99 : Conv.sstListB 4334 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s967.ffi).mlx PRE_first_tail_x15_r0_body.cln99 PRE_first_tail_x15_r0_body.clo99 PRE_first_tail_x15_r0_body.cli99 = true

end Host.Load.Run.Tpl
