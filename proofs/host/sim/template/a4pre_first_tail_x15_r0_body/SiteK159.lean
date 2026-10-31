import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC159
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl159`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl159 : List Nat := [2665, 2672708, 2673467, 2799309, 2799854, 2800110, 2800135, 2800136, 2800137, 2800138, 2800139, 2800140]
def PRE_first_tail_x15_r0_body.clo159 : List Nat := [21321, 21334, 21340, 21341, 21342, 21343]
def PRE_first_tail_x15_r0_body.cln159 : List Nat := [18422, 18423, 18424, 18425, 18426, 18427, 18428, 18429, 18430, 18431, 18432, 18433, 18434, 18435, 18436, 18437, 18438, 18439, 18440, 18441, 18442, 18443, 18444, 18445, 18446, 18447, 18448]
def PRE_first_tail_x15_r0_body.cli159 : List Nat := [18422, 18423, 18424, 18425, 18426, 18427, 18428, 18429, 18430, 18431, 18432, 18433, 18434, 18435, 18436, 18437, 18438, 18439, 18440, 18441, 18442, 18443, 18444, 18445, 18446, 18447, 18448]
kernel_rfl PRE_first_tail_x15_r0_body.cheap159 : PRE_first_tail_x15_r0_body.s1408.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1406.heap (PRE_first_tail_x15_r0_body.cl159.filterMap fun a => (PRE_first_tail_x15_r0_body.s1408.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe159 : Nat.ble PRE_first_tail_x15_r0_body.s1406.next PRE_first_tail_x15_r0_body.s1408.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP159 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp159 : Conv.suppListB PRE_first_tail_x15_r0_body.s1408 6899 PRE_first_tail_x15_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound159 : Conv.boundListB PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.cl159 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK159 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1406.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli159.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst159 : Conv.sstListB 6899 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1408.ffi).mlx PRE_first_tail_x15_r0_body.cln159 PRE_first_tail_x15_r0_body.clo159 PRE_first_tail_x15_r0_body.cli159 = true

end Host.Load.Run.Tpl
