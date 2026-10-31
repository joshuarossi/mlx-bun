import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC123
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl123`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl123 : List Nat := [2665, 2672615, 2673467, 2771053, 2771598, 2771854, 2771879, 2771880, 2771881, 2771882, 2771883, 2771884]
def PRE_first_tail_x15_r0_body.clo123 : List Nat := [20613, 20626, 20632, 20633, 20634, 20635]
def PRE_first_tail_x15_r0_body.cln123 : List Nat := [17711, 17712, 17713, 17714, 17715, 17716, 17717, 17718, 17719, 17720, 17721, 17722, 17723, 17724, 17725, 17726, 17727, 17728, 17729, 17730, 17731, 17732, 17733, 17734, 17735, 17736, 17737]
def PRE_first_tail_x15_r0_body.cli123 : List Nat := [17711, 17712, 17713, 17714, 17715, 17716, 17717, 17718, 17719, 17720, 17721, 17722, 17723, 17724, 17725, 17726, 17727, 17728, 17729, 17730, 17731, 17732, 17733, 17734, 17735, 17736, 17737]
kernel_rfl PRE_first_tail_x15_r0_body.cheap123 : PRE_first_tail_x15_r0_body.s1093.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1091.heap (PRE_first_tail_x15_r0_body.cl123.filterMap fun a => (PRE_first_tail_x15_r0_body.s1093.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe123 : Nat.ble PRE_first_tail_x15_r0_body.s1091.next PRE_first_tail_x15_r0_body.s1093.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP123 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1091 PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp123 : Conv.suppListB PRE_first_tail_x15_r0_body.s1093 5360 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound123 : Conv.boundListB PRE_first_tail_x15_r0_body.s1093 PRE_first_tail_x15_r0_body.cl123 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1091.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1091.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK123 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1091.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli123.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst123 : Conv.sstListB 5360 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1093.ffi).mlx PRE_first_tail_x15_r0_body.cln123 PRE_first_tail_x15_r0_body.clo123 PRE_first_tail_x15_r0_body.cli123 = true

end Host.Load.Run.Tpl
