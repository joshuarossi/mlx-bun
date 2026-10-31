import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC126
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl126`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl126 : List Nat := [2665, 2672620, 2673467, 2773309, 2773854, 2774110, 2774135, 2774136, 2774137, 2774138, 2774139, 2774140]
def PRE_first_tail_x15_r0_body.clo126 : List Nat := [20670, 20683, 20689, 20690, 20691, 20692]
def PRE_first_tail_x15_r0_body.cln126 : List Nat := [17774, 17775, 17776, 17777, 17778, 17779, 17780, 17781, 17782, 17783, 17784, 17785, 17786, 17787, 17788, 17789, 17790, 17791, 17792, 17793, 17794, 17795, 17796, 17797, 17798, 17799, 17800]
def PRE_first_tail_x15_r0_body.cli126 : List Nat := [17774, 17775, 17776, 17777, 17778, 17779, 17780, 17781, 17782, 17783, 17784, 17785, 17786, 17787, 17788, 17789, 17790, 17791, 17792, 17793, 17794, 17795, 17796, 17797, 17798, 17799, 17800]
kernel_rfl PRE_first_tail_x15_r0_body.cheap126 : PRE_first_tail_x15_r0_body.s1226.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1224.heap (PRE_first_tail_x15_r0_body.cl126.filterMap fun a => (PRE_first_tail_x15_r0_body.s1226.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe126 : Nat.ble PRE_first_tail_x15_r0_body.s1224.next PRE_first_tail_x15_r0_body.s1226.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP126 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1224 PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp126 : Conv.suppListB PRE_first_tail_x15_r0_body.s1226 5489 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound126 : Conv.boundListB PRE_first_tail_x15_r0_body.s1226 PRE_first_tail_x15_r0_body.cl126 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK126 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1224.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli126.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst126 : Conv.sstListB 5489 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1226.ffi).mlx PRE_first_tail_x15_r0_body.cln126 PRE_first_tail_x15_r0_body.clo126 PRE_first_tail_x15_r0_body.cli126 = true

end Host.Load.Run.Tpl
