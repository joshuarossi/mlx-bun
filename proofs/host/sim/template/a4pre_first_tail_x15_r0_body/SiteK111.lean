import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC111
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl111`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl111 : List Nat := [2665, 2672584, 2673467, 2761641, 2762186, 2762442, 2762467, 2762468, 2762469, 2762470, 2762471, 2762472]
def PRE_first_tail_x15_r0_body.clo111 : List Nat := [20377, 20390, 20396, 20397, 20398, 20399]
def PRE_first_tail_x15_r0_body.cln111 : List Nat := [17474, 17475, 17476, 17477, 17478, 17479, 17480, 17481, 17482, 17483, 17484, 17485, 17486, 17487, 17488, 17489, 17490, 17491, 17492, 17493, 17494, 17495, 17496, 17497, 17498, 17499, 17500]
def PRE_first_tail_x15_r0_body.cli111 : List Nat := [17474, 17475, 17476, 17477, 17478, 17479, 17480, 17481, 17482, 17483, 17484, 17485, 17486, 17487, 17488, 17489, 17490, 17491, 17492, 17493, 17494, 17495, 17496, 17497, 17498, 17499, 17500]
kernel_rfl PRE_first_tail_x15_r0_body.cheap111 : PRE_first_tail_x15_r0_body.s988.heap = Stage.setAll PRE_first_tail_x15_r0_body.s986.heap (PRE_first_tail_x15_r0_body.cl111.filterMap fun a => (PRE_first_tail_x15_r0_body.s988.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe111 : Nat.ble PRE_first_tail_x15_r0_body.s986.next PRE_first_tail_x15_r0_body.s988.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP111 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s986 PRE_first_tail_x15_r0_body.s988 PRE_first_tail_x15_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp111 : Conv.suppListB PRE_first_tail_x15_r0_body.s988 4847 PRE_first_tail_x15_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound111 : Conv.boundListB PRE_first_tail_x15_r0_body.s988 PRE_first_tail_x15_r0_body.cl111 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s986.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s986.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK111 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s986.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli111.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst111 : Conv.sstListB 4847 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s988.ffi).mlx PRE_first_tail_x15_r0_body.cln111 PRE_first_tail_x15_r0_body.clo111 PRE_first_tail_x15_r0_body.cli111 = true

end Host.Load.Run.Tpl
