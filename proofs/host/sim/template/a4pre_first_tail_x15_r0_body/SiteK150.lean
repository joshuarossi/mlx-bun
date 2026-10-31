import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC150
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl150`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl150 : List Nat := [2665, 2672682, 2673467, 2792153, 2792698, 2792954, 2792979, 2792980, 2792981, 2792982, 2792983, 2792984]
def PRE_first_tail_x15_r0_body.clo150 : List Nat := [21142, 21155, 21161, 21162, 21163, 21164]
def PRE_first_tail_x15_r0_body.cln150 : List Nat := [18248, 18249, 18250, 18251, 18252, 18253, 18254, 18255, 18256, 18257, 18258, 18259, 18260, 18261, 18262, 18263, 18264, 18265, 18266, 18267, 18268, 18269, 18270, 18271, 18272, 18273, 18274]
def PRE_first_tail_x15_r0_body.cli150 : List Nat := [18248, 18249, 18250, 18251, 18252, 18253, 18254, 18255, 18256, 18257, 18258, 18259, 18260, 18261, 18262, 18263, 18264, 18265, 18266, 18267, 18268, 18269, 18270, 18271, 18272, 18273, 18274]
kernel_rfl PRE_first_tail_x15_r0_body.cheap150 : PRE_first_tail_x15_r0_body.s1330.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1328.heap (PRE_first_tail_x15_r0_body.cl150.filterMap fun a => (PRE_first_tail_x15_r0_body.s1330.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe150 : Nat.ble PRE_first_tail_x15_r0_body.s1328.next PRE_first_tail_x15_r0_body.s1330.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP150 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1328 PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp150 : Conv.suppListB PRE_first_tail_x15_r0_body.s1330 6515 PRE_first_tail_x15_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound150 : Conv.boundListB PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.cl150 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK150 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1328.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK150 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1328.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK150 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1328.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli150.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst150 : Conv.sstListB 6515 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1330.ffi).mlx PRE_first_tail_x15_r0_body.cln150 PRE_first_tail_x15_r0_body.clo150 PRE_first_tail_x15_r0_body.cli150 = true

end Host.Load.Run.Tpl
