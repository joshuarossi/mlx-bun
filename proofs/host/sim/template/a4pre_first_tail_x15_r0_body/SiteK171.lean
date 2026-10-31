import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC171
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl171`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl171 : List Nat := [2665, 2672739, 2673467, 2808733, 2809278, 2809534, 2809559, 2809560, 2809561, 2809562, 2809563, 2809564]
def PRE_first_tail_x15_r0_body.clo171 : List Nat := [21557, 21570, 21576, 21577, 21578, 21579]
def PRE_first_tail_x15_r0_body.cln171 : List Nat := [18659, 18660, 18661, 18662, 18663, 18664, 18665, 18666, 18667, 18668, 18669, 18670, 18671, 18672, 18673, 18674, 18675, 18676, 18677, 18678, 18679, 18680, 18681, 18682, 18683, 18684, 18685]
def PRE_first_tail_x15_r0_body.cli171 : List Nat := [18659, 18660, 18661, 18662, 18663, 18664, 18665, 18666, 18667, 18668, 18669, 18670, 18671, 18672, 18673, 18674, 18675, 18676, 18677, 18678, 18679, 18680, 18681, 18682, 18683, 18684, 18685]
kernel_rfl PRE_first_tail_x15_r0_body.cheap171 : PRE_first_tail_x15_r0_body.s1657.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1655.heap (PRE_first_tail_x15_r0_body.cl171.filterMap fun a => (PRE_first_tail_x15_r0_body.s1657.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe171 : Nat.ble PRE_first_tail_x15_r0_body.s1655.next PRE_first_tail_x15_r0_body.s1657.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP171 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp171 : Conv.suppListB PRE_first_tail_x15_r0_body.s1657 7412 PRE_first_tail_x15_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound171 : Conv.boundListB PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.cl171 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK171 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1655.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli171.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst171 : Conv.sstListB 7412 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1657.ffi).mlx PRE_first_tail_x15_r0_body.cln171 PRE_first_tail_x15_r0_body.clo171 PRE_first_tail_x15_r0_body.cli171 = true

end Host.Load.Run.Tpl
