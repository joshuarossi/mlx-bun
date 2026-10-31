import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC75
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl75`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl75 : List Nat := [2665, 2672491, 2673467, 2733389, 2733934, 2734190, 2734215, 2734216, 2734217, 2734218, 2734219, 2734220]
def PRE_first_tail_x15_r0_body.clo75 : List Nat := [19669, 19682, 19688, 19689, 19690, 19691]
def PRE_first_tail_x15_r0_body.cln75 : List Nat := [16763, 16764, 16765, 16766, 16767, 16768, 16769, 16770, 16771, 16772, 16773, 16774, 16775, 16776, 16777, 16778, 16779, 16780, 16781, 16782, 16783, 16784, 16785, 16786, 16787, 16788, 16789]
def PRE_first_tail_x15_r0_body.cli75 : List Nat := [16763, 16764, 16765, 16766, 16767, 16768, 16769, 16770, 16771, 16772, 16773, 16774, 16775, 16776, 16777, 16778, 16779, 16780, 16781, 16782, 16783, 16784, 16785, 16786, 16787, 16788, 16789]
kernel_rfl PRE_first_tail_x15_r0_body.cheap75 : PRE_first_tail_x15_r0_body.s673.heap = Stage.setAll PRE_first_tail_x15_r0_body.s671.heap (PRE_first_tail_x15_r0_body.cl75.filterMap fun a => (PRE_first_tail_x15_r0_body.s673.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe75 : Nat.ble PRE_first_tail_x15_r0_body.s671.next PRE_first_tail_x15_r0_body.s673.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP75 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s671 PRE_first_tail_x15_r0_body.s673 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp75 : Conv.suppListB PRE_first_tail_x15_r0_body.s673 3308 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound75 : Conv.boundListB PRE_first_tail_x15_r0_body.s673 PRE_first_tail_x15_r0_body.cl75 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK75 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s671.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli75.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst75 : Conv.sstListB 3308 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s673.ffi).mlx PRE_first_tail_x15_r0_body.cln75 PRE_first_tail_x15_r0_body.clo75 PRE_first_tail_x15_r0_body.cli75 = true

end Host.Load.Run.Tpl
