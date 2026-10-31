import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC15
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl15`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl15 : List Nat := [2665, 2672336, 2673467, 2686305, 2686850, 2687106, 2687131, 2687132, 2687133, 2687134, 2687135, 2687136]
def PRE_first_tail_x15_r0_body.clo15 : List Nat := [18489, 18502, 18508, 18509, 18510, 18511]
def PRE_first_tail_x15_r0_body.cln15 : List Nat := [15578, 15579, 15580, 15581, 15582, 15583, 15584, 15585, 15586, 15587, 15588, 15589, 15590, 15591, 15592, 15593, 15594, 15595, 15596, 15597, 15598, 15599, 15600, 15601, 15602, 15603, 15604]
def PRE_first_tail_x15_r0_body.cli15 : List Nat := [15578, 15579, 15580, 15581, 15582, 15583, 15584, 15585, 15586, 15587, 15588, 15589, 15590, 15591, 15592, 15593, 15594, 15595, 15596, 15597, 15598, 15599, 15600, 15601, 15602, 15603, 15604]
kernel_rfl PRE_first_tail_x15_r0_body.cheap15 : PRE_first_tail_x15_r0_body.s148.heap = Stage.setAll PRE_first_tail_x15_r0_body.s146.heap (PRE_first_tail_x15_r0_body.cl15.filterMap fun a => (PRE_first_tail_x15_r0_body.s148.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe15 : Nat.ble PRE_first_tail_x15_r0_body.s146.next PRE_first_tail_x15_r0_body.s148.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP15 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s146 PRE_first_tail_x15_r0_body.s148 PRE_first_tail_x15_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp15 : Conv.suppListB PRE_first_tail_x15_r0_body.s148 743 PRE_first_tail_x15_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound15 : Conv.boundListB PRE_first_tail_x15_r0_body.s148 PRE_first_tail_x15_r0_body.cl15 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s146.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s146.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK15 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s146.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli15.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst15 : Conv.sstListB 743 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s148.ffi).mlx PRE_first_tail_x15_r0_body.cln15 PRE_first_tail_x15_r0_body.clo15 PRE_first_tail_x15_r0_body.cli15 = true

end Host.Load.Run.Tpl
