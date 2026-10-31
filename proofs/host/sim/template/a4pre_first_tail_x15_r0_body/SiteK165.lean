import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC165
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl165`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl165 : List Nat := [2665, 2672725, 2673467, 2804916, 2804917, 2804918, 2804919, 2804920, 2804921, 2804922, 2804923, 2804924, 2804925, 2804926, 2804927, 2804928, 2804929, 2804930]
def PRE_first_tail_x15_r0_body.clo165 : List Nat := [21461, 21462, 21463, 21464]
def PRE_first_tail_x15_r0_body.cln165 : List Nat := [18557, 18558, 18559, 18560, 18561, 18562]
def PRE_first_tail_x15_r0_body.cli165 : List Nat := [18557, 18558, 18559, 18560, 18561, 18562]
kernel_rfl PRE_first_tail_x15_r0_body.cheap165 : PRE_first_tail_x15_r0_body.s1599.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1597.heap (PRE_first_tail_x15_r0_body.cl165.filterMap fun a => (PRE_first_tail_x15_r0_body.s1599.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe165 : Nat.ble PRE_first_tail_x15_r0_body.s1597.next PRE_first_tail_x15_r0_body.s1599.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP165 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1597 PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp165 : Conv.suppListB PRE_first_tail_x15_r0_body.s1599 7152 PRE_first_tail_x15_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound165 : Conv.boundListB PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.cl165 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK165 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1597.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli165.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst165 : Conv.sstListB 7152 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1599.ffi).mlx PRE_first_tail_x15_r0_body.cln165 PRE_first_tail_x15_r0_body.clo165 PRE_first_tail_x15_r0_body.cli165 = true

end Host.Load.Run.Tpl
