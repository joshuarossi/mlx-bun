import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC117
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl117`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl117 : List Nat := [2665, 2672601, 2673467, 2767244, 2767245, 2767246, 2767247, 2767248, 2767249, 2767250, 2767251, 2767252, 2767253, 2767254, 2767255, 2767256, 2767257, 2767258]
def PRE_first_tail_x15_r0_body.clo117 : List Nat := [20517, 20518, 20519, 20520]
def PRE_first_tail_x15_r0_body.cln117 : List Nat := [17609, 17610, 17611, 17612, 17613, 17614]
def PRE_first_tail_x15_r0_body.cli117 : List Nat := [17609, 17610, 17611, 17612, 17613, 17614]
kernel_rfl PRE_first_tail_x15_r0_body.cheap117 : PRE_first_tail_x15_r0_body.s1139.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1137.heap (PRE_first_tail_x15_r0_body.cl117.filterMap fun a => (PRE_first_tail_x15_r0_body.s1139.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe117 : Nat.ble PRE_first_tail_x15_r0_body.s1137.next PRE_first_tail_x15_r0_body.s1139.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP117 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1137 PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp117 : Conv.suppListB PRE_first_tail_x15_r0_body.s1139 5100 PRE_first_tail_x15_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound117 : Conv.boundListB PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.cl117 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK117 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1137.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli117.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst117 : Conv.sstListB 5100 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1139.ffi).mlx PRE_first_tail_x15_r0_body.cln117 PRE_first_tail_x15_r0_body.clo117 PRE_first_tail_x15_r0_body.cli117 = true

end Host.Load.Run.Tpl
