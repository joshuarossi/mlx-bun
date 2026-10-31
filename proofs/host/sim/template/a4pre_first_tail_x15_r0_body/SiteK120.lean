import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC120
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl120`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl120 : List Nat := [2665, 2672610, 2673467, 2768797, 2769342, 2769598, 2769623, 2769624, 2769625, 2769626, 2769627, 2769628]
def PRE_first_tail_x15_r0_body.clo120 : List Nat := [20556, 20569, 20575, 20576, 20577, 20578]
def PRE_first_tail_x15_r0_body.cln120 : List Nat := [17648, 17649, 17650, 17651, 17652, 17653, 17654, 17655, 17656, 17657, 17658, 17659, 17660, 17661, 17662, 17663, 17664, 17665, 17666, 17667, 17668, 17669, 17670, 17671, 17672, 17673, 17674]
def PRE_first_tail_x15_r0_body.cli120 : List Nat := [17648, 17649, 17650, 17651, 17652, 17653, 17654, 17655, 17656, 17657, 17658, 17659, 17660, 17661, 17662, 17663, 17664, 17665, 17666, 17667, 17668, 17669, 17670, 17671, 17672, 17673, 17674]
kernel_rfl PRE_first_tail_x15_r0_body.cheap120 : PRE_first_tail_x15_r0_body.s1168.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1166.heap (PRE_first_tail_x15_r0_body.cl120.filterMap fun a => (PRE_first_tail_x15_r0_body.s1168.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe120 : Nat.ble PRE_first_tail_x15_r0_body.s1166.next PRE_first_tail_x15_r0_body.s1168.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP120 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1166 PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp120 : Conv.suppListB PRE_first_tail_x15_r0_body.s1168 5231 PRE_first_tail_x15_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound120 : Conv.boundListB PRE_first_tail_x15_r0_body.s1168 PRE_first_tail_x15_r0_body.cl120 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK120 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1166.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli120.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst120 : Conv.sstListB 5231 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1168.ffi).mlx PRE_first_tail_x15_r0_body.cln120 PRE_first_tail_x15_r0_body.clo120 PRE_first_tail_x15_r0_body.cli120 = true

end Host.Load.Run.Tpl
