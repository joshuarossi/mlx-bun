import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC177
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl177`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl177 : List Nat := [2665, 2672756, 2673467, 2814344, 2814345, 2814346, 2814347, 2814348, 2814349, 2814350, 2814351, 2814352, 2814353, 2814354, 2814355, 2814356, 2814357, 2814358]
def PRE_first_tail_x15_r0_body.clo177 : List Nat := [21697, 21698, 21699, 21700]
def PRE_first_tail_x15_r0_body.cln177 : List Nat := [18794, 18795, 18796, 18797, 18798, 18799]
def PRE_first_tail_x15_r0_body.cli177 : List Nat := [18794, 18795, 18796, 18797, 18798, 18799]
kernel_rfl PRE_first_tail_x15_r0_body.cheap177 : PRE_first_tail_x15_r0_body.s1714.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1712.heap (PRE_first_tail_x15_r0_body.cl177.filterMap fun a => (PRE_first_tail_x15_r0_body.s1714.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe177 : Nat.ble PRE_first_tail_x15_r0_body.s1712.next PRE_first_tail_x15_r0_body.s1714.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP177 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1712 PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp177 : Conv.suppListB PRE_first_tail_x15_r0_body.s1714 7665 PRE_first_tail_x15_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound177 : Conv.boundListB PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.cl177 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK177 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1712.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli177.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst177 : Conv.sstListB 7665 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1714.ffi).mlx PRE_first_tail_x15_r0_body.cln177 PRE_first_tail_x15_r0_body.clo177 PRE_first_tail_x15_r0_body.cli177 = true

end Host.Load.Run.Tpl
