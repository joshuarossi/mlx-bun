import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC189
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl189`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl189 : List Nat := [2665, 2672787, 2673467, 2823768, 2823769, 2823770, 2823771, 2823772, 2823773, 2823774, 2823775, 2823776, 2823777, 2823778, 2823779, 2823780, 2823781, 2823782]
def PRE_first_tail_x15_r0_body.clo189 : List Nat := [21933, 21934, 21935, 21936]
def PRE_first_tail_x15_r0_body.cln189 : List Nat := [19031, 19032, 19033, 19034, 19035, 19036]
def PRE_first_tail_x15_r0_body.cli189 : List Nat := [19031, 19032, 19033, 19034, 19035, 19036]
kernel_rfl PRE_first_tail_x15_r0_body.cheap189 : PRE_first_tail_x15_r0_body.s1829.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1827.heap (PRE_first_tail_x15_r0_body.cl189.filterMap fun a => (PRE_first_tail_x15_r0_body.s1829.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe189 : Nat.ble PRE_first_tail_x15_r0_body.s1827.next PRE_first_tail_x15_r0_body.s1829.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP189 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp189 : Conv.suppListB PRE_first_tail_x15_r0_body.s1829 8178 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound189 : Conv.boundListB PRE_first_tail_x15_r0_body.s1829 PRE_first_tail_x15_r0_body.cl189 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1827.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst189 : Conv.sstListB 8178 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1829.ffi).mlx PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cli189 = true

end Host.Load.Run.Tpl
