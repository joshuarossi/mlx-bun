import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC156
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl156`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl156 : List Nat := [2665, 2672703, 2673467, 2797053, 2797598, 2797854, 2797879, 2797880, 2797881, 2797882, 2797883, 2797884]
def PRE_first_tail_x15_r0_body.clo156 : List Nat := [21264, 21277, 21283, 21284, 21285, 21286]
def PRE_first_tail_x15_r0_body.cln156 : List Nat := [18359, 18360, 18361, 18362, 18363, 18364, 18365, 18366, 18367, 18368, 18369, 18370, 18371, 18372, 18373, 18374, 18375, 18376, 18377, 18378, 18379, 18380, 18381, 18382, 18383, 18384, 18385]
def PRE_first_tail_x15_r0_body.cli156 : List Nat := [18359, 18360, 18361, 18362, 18363, 18364, 18365, 18366, 18367, 18368, 18369, 18370, 18371, 18372, 18373, 18374, 18375, 18376, 18377, 18378, 18379, 18380, 18381, 18382, 18383, 18384, 18385]
kernel_rfl PRE_first_tail_x15_r0_body.cheap156 : PRE_first_tail_x15_r0_body.s1381.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1379.heap (PRE_first_tail_x15_r0_body.cl156.filterMap fun a => (PRE_first_tail_x15_r0_body.s1381.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe156 : Nat.ble PRE_first_tail_x15_r0_body.s1379.next PRE_first_tail_x15_r0_body.s1381.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP156 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1379 PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp156 : Conv.suppListB PRE_first_tail_x15_r0_body.s1381 6770 PRE_first_tail_x15_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound156 : Conv.boundListB PRE_first_tail_x15_r0_body.s1381 PRE_first_tail_x15_r0_body.cl156 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK156 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1379.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli156.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst156 : Conv.sstListB 6770 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1381.ffi).mlx PRE_first_tail_x15_r0_body.cln156 PRE_first_tail_x15_r0_body.clo156 PRE_first_tail_x15_r0_body.cli156 = true

end Host.Load.Run.Tpl
