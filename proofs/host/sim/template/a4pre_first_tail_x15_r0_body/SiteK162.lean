import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC162
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl162`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl162 : List Nat := [2665, 2672713, 2673467, 2801565, 2802110, 2802366, 2802391, 2802392, 2802393, 2802394, 2802395, 2802396]
def PRE_first_tail_x15_r0_body.clo162 : List Nat := [21378, 21391, 21397, 21398, 21399, 21400]
def PRE_first_tail_x15_r0_body.cln162 : List Nat := [18485, 18486, 18487, 18488, 18489, 18490, 18491, 18492, 18493, 18494, 18495, 18496, 18497, 18498, 18499, 18500, 18501, 18502, 18503, 18504, 18505, 18506, 18507, 18508, 18509, 18510, 18511]
def PRE_first_tail_x15_r0_body.cli162 : List Nat := [18485, 18486, 18487, 18488, 18489, 18490, 18491, 18492, 18493, 18494, 18495, 18496, 18497, 18498, 18499, 18500, 18501, 18502, 18503, 18504, 18505, 18506, 18507, 18508, 18509, 18510, 18511]
kernel_rfl PRE_first_tail_x15_r0_body.cheap162 : PRE_first_tail_x15_r0_body.s1435.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1433.heap (PRE_first_tail_x15_r0_body.cl162.filterMap fun a => (PRE_first_tail_x15_r0_body.s1435.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe162 : Nat.ble PRE_first_tail_x15_r0_body.s1433.next PRE_first_tail_x15_r0_body.s1435.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP162 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1433 PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp162 : Conv.suppListB PRE_first_tail_x15_r0_body.s1435 7028 PRE_first_tail_x15_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound162 : Conv.boundListB PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.cl162 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK162 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1433.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli162.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst162 : Conv.sstListB 7028 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1435.ffi).mlx PRE_first_tail_x15_r0_body.cln162 PRE_first_tail_x15_r0_body.clo162 PRE_first_tail_x15_r0_body.cli162 = true

end Host.Load.Run.Tpl
