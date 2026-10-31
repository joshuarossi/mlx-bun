import host.sim.template.a4pre_first_tail_x15_r0_body.SiteC57
import host.sim.conv.Closed
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl57`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl57 : List Nat := [2665, 2672446, 2673467, 2720168, 2720169, 2720170, 2720171, 2720172, 2720173, 2720174, 2720175, 2720176, 2720177, 2720178, 2720179, 2720180, 2720181, 2720182]
def PRE_first_tail_x15_r0_body.clo57 : List Nat := [19337, 19338, 19339, 19340]
def PRE_first_tail_x15_r0_body.cln57 : List Nat := [16424, 16425, 16426, 16427, 16428, 16429]
def PRE_first_tail_x15_r0_body.cli57 : List Nat := [16424, 16425, 16426, 16427, 16428, 16429]
kernel_rfl PRE_first_tail_x15_r0_body.cheap57 : PRE_first_tail_x15_r0_body.s514.heap = Stage.setAll PRE_first_tail_x15_r0_body.s512.heap (PRE_first_tail_x15_r0_body.cl57.filterMap fun a => (PRE_first_tail_x15_r0_body.s514.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe57 : Nat.ble PRE_first_tail_x15_r0_body.s512.next PRE_first_tail_x15_r0_body.s514.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP57 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s512 PRE_first_tail_x15_r0_body.s514 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp57 : Conv.suppListB PRE_first_tail_x15_r0_body.s514 2535 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound57 : Conv.boundListB PRE_first_tail_x15_r0_body.s514 PRE_first_tail_x15_r0_body.cl57 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s512.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s512.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK57 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s512.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli57.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst57 : Conv.sstListB 2535 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s514.ffi).mlx PRE_first_tail_x15_r0_body.cln57 PRE_first_tail_x15_r0_body.clo57 PRE_first_tail_x15_r0_body.cli57 = true

end Host.Load.Run.Tpl
