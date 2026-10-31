import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC72
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl72`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl72 : List Nat := [2665, 2672486, 2673467, 2731133, 2731678, 2731934, 2731959, 2731960, 2731961, 2731962, 2731963, 2731964]
def PRE_first_tail_x15_r0_body.clo72 : List Nat := [19612, 19625, 19631, 19632, 19633, 19634]
def PRE_first_tail_x15_r0_body.cln72 : List Nat := [16700, 16701, 16702, 16703, 16704, 16705, 16706, 16707, 16708, 16709, 16710, 16711, 16712, 16713, 16714, 16715, 16716, 16717, 16718, 16719, 16720, 16721, 16722, 16723, 16724, 16725, 16726]
def PRE_first_tail_x15_r0_body.cli72 : List Nat := [16700, 16701, 16702, 16703, 16704, 16705, 16706, 16707, 16708, 16709, 16710, 16711, 16712, 16713, 16714, 16715, 16716, 16717, 16718, 16719, 16720, 16721, 16722, 16723, 16724, 16725, 16726]
kernel_rfl PRE_first_tail_x15_r0_body.cheap72 : PRE_first_tail_x15_r0_body.s708.heap = Stage.setAll PRE_first_tail_x15_r0_body.s706.heap (PRE_first_tail_x15_r0_body.cl72.filterMap fun a => (PRE_first_tail_x15_r0_body.s708.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe72 : Nat.ble PRE_first_tail_x15_r0_body.s706.next PRE_first_tail_x15_r0_body.s708.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP72 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s706 PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp72 : Conv.suppListB PRE_first_tail_x15_r0_body.s708 3179 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound72 : Conv.boundListB PRE_first_tail_x15_r0_body.s708 PRE_first_tail_x15_r0_body.cl72 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK72 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s706.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli72.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst72 : Conv.sstListB 3179 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s708.ffi).mlx PRE_first_tail_x15_r0_body.cln72 PRE_first_tail_x15_r0_body.clo72 PRE_first_tail_x15_r0_body.cli72 = true

end Host.Load.Run.Tpl
