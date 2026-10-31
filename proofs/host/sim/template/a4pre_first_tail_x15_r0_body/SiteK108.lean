import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC108
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl108`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl108 : List Nat := [2665, 2672579, 2673467, 2759385, 2759930, 2760186, 2760211, 2760212, 2760213, 2760214, 2760215, 2760216]
def PRE_first_tail_x15_r0_body.clo108 : List Nat := [20320, 20333, 20339, 20340, 20341, 20342]
def PRE_first_tail_x15_r0_body.cln108 : List Nat := [17411, 17412, 17413, 17414, 17415, 17416, 17417, 17418, 17419, 17420, 17421, 17422, 17423, 17424, 17425, 17426, 17427, 17428, 17429, 17430, 17431, 17432, 17433, 17434, 17435, 17436, 17437]
def PRE_first_tail_x15_r0_body.cli108 : List Nat := [17411, 17412, 17413, 17414, 17415, 17416, 17417, 17418, 17419, 17420, 17421, 17422, 17423, 17424, 17425, 17426, 17427, 17428, 17429, 17430, 17431, 17432, 17433, 17434, 17435, 17436, 17437]
kernel_rfl PRE_first_tail_x15_r0_body.cheap108 : PRE_first_tail_x15_r0_body.s1053.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1051.heap (PRE_first_tail_x15_r0_body.cl108.filterMap fun a => (PRE_first_tail_x15_r0_body.s1053.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe108 : Nat.ble PRE_first_tail_x15_r0_body.s1051.next PRE_first_tail_x15_r0_body.s1053.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP108 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1051 PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp108 : Conv.suppListB PRE_first_tail_x15_r0_body.s1053 4718 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound108 : Conv.boundListB PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.cl108 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK108 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1051.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli108.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst108 : Conv.sstListB 4718 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1053.ffi).mlx PRE_first_tail_x15_r0_body.cln108 PRE_first_tail_x15_r0_body.clo108 PRE_first_tail_x15_r0_body.cli108 = true

end Host.Load.Run.Tpl
