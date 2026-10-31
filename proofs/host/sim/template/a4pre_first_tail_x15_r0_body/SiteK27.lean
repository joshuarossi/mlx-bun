import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC27
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl27`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl27 : List Nat := [2665, 2672367, 2673467, 2695717, 2696262, 2696518, 2696543, 2696544, 2696545, 2696546, 2696547, 2696548]
def PRE_first_tail_x15_r0_body.clo27 : List Nat := [18725, 18738, 18744, 18745, 18746, 18747]
def PRE_first_tail_x15_r0_body.cln27 : List Nat := [15815, 15816, 15817, 15818, 15819, 15820, 15821, 15822, 15823, 15824, 15825, 15826, 15827, 15828, 15829, 15830, 15831, 15832, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15841]
def PRE_first_tail_x15_r0_body.cli27 : List Nat := [15815, 15816, 15817, 15818, 15819, 15820, 15821, 15822, 15823, 15824, 15825, 15826, 15827, 15828, 15829, 15830, 15831, 15832, 15833, 15834, 15835, 15836, 15837, 15838, 15839, 15840, 15841]
kernel_rfl PRE_first_tail_x15_r0_body.cheap27 : PRE_first_tail_x15_r0_body.s277.heap = Stage.setAll PRE_first_tail_x15_r0_body.s275.heap (PRE_first_tail_x15_r0_body.cl27.filterMap fun a => (PRE_first_tail_x15_r0_body.s277.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe27 : Nat.ble PRE_first_tail_x15_r0_body.s275.next PRE_first_tail_x15_r0_body.s277.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP27 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp27 : Conv.suppListB PRE_first_tail_x15_r0_body.s277 1256 PRE_first_tail_x15_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound27 : Conv.boundListB PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.cl27 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s275.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s275.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK27 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s275.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli27.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst27 : Conv.sstListB 1256 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s277.ffi).mlx PRE_first_tail_x15_r0_body.cln27 PRE_first_tail_x15_r0_body.clo27 PRE_first_tail_x15_r0_body.cli27 = true

end Host.Load.Run.Tpl
