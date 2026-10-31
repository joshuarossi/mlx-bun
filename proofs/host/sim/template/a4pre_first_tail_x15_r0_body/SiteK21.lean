import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC21
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl21`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl21 : List Nat := [2665, 2672353, 2673467, 2691908, 2691909, 2691910, 2691911, 2691912, 2691913, 2691914, 2691915, 2691916, 2691917, 2691918, 2691919, 2691920, 2691921, 2691922]
def PRE_first_tail_x15_r0_body.clo21 : List Nat := [18629, 18630, 18631, 18632]
def PRE_first_tail_x15_r0_body.cln21 : List Nat := [15713, 15714, 15715, 15716, 15717, 15718]
def PRE_first_tail_x15_r0_body.cli21 : List Nat := [15713, 15714, 15715, 15716, 15717, 15718]
kernel_rfl PRE_first_tail_x15_r0_body.cheap21 : PRE_first_tail_x15_r0_body.s219.heap = Stage.setAll PRE_first_tail_x15_r0_body.s217.heap (PRE_first_tail_x15_r0_body.cl21.filterMap fun a => (PRE_first_tail_x15_r0_body.s219.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe21 : Nat.ble PRE_first_tail_x15_r0_body.s217.next PRE_first_tail_x15_r0_body.s219.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP21 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s217 PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp21 : Conv.suppListB PRE_first_tail_x15_r0_body.s219 996 PRE_first_tail_x15_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound21 : Conv.boundListB PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.cl21 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s217.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s217.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK21 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s217.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli21.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst21 : Conv.sstListB 996 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s219.ffi).mlx PRE_first_tail_x15_r0_body.cln21 PRE_first_tail_x15_r0_body.clo21 PRE_first_tail_x15_r0_body.cli21 = true

end Host.Load.Run.Tpl
