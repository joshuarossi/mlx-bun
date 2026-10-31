import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC6
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl6`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl6 : List Nat := [2665, 2672310, 2673467, 2679147, 2679692, 2679948, 2679973, 2679974, 2679975, 2679976, 2679977, 2679978]
def PRE_first_tail_x15_r0_body.clo6 : List Nat := [18310, 18323, 18329, 18330, 18331, 18332]
def PRE_first_tail_x15_r0_body.cln6 : List Nat := [15404, 15405, 15406, 15407, 15408, 15409, 15410, 15411, 15412, 15413, 15414, 15415, 15416, 15417, 15418, 15419, 15420, 15421, 15422, 15423, 15424, 15425, 15426, 15427, 15428, 15429, 15430]
def PRE_first_tail_x15_r0_body.cli6 : List Nat := [15404, 15405, 15406, 15407, 15408, 15409, 15410, 15411, 15412, 15413, 15414, 15415, 15416, 15417, 15418, 15419, 15420, 15421, 15422, 15423, 15424, 15425, 15426, 15427, 15428, 15429, 15430]
kernel_rfl PRE_first_tail_x15_r0_body.cheap6 : PRE_first_tail_x15_r0_body.s76.heap = Stage.setAll PRE_first_tail_x15_r0_body.s74.heap (PRE_first_tail_x15_r0_body.cl6.filterMap fun a => (PRE_first_tail_x15_r0_body.s76.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe6 : Nat.ble PRE_first_tail_x15_r0_body.s74.next PRE_first_tail_x15_r0_body.s76.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP6 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s74 PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp6 : Conv.suppListB PRE_first_tail_x15_r0_body.s76 359 PRE_first_tail_x15_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound6 : Conv.boundListB PRE_first_tail_x15_r0_body.s76 PRE_first_tail_x15_r0_body.cl6 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK6 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s74.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli6.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst6 : Conv.sstListB 359 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s76.ffi).mlx PRE_first_tail_x15_r0_body.cln6 PRE_first_tail_x15_r0_body.clo6 PRE_first_tail_x15_r0_body.cli6 = true

end Host.Load.Run.Tpl
